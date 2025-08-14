#!/usr/bin/env node
import { FastMCP, McpError } from 'fastmcp';
import { z } from 'zod';
import OpenAI from 'openai';
import { db, memories, companions, users, gameSessions, userPreferences, conversationClusters } from './db';
import { eq, and, desc, sql, gte, lte } from 'drizzle-orm';
import { config } from './config';
import { v4 as uuidv4 } from 'uuid';

// Initialize FastMCP server
const mcp = new FastMCP('Artificial Arcade Companion & Memory Server');

// Initialize OpenAI if configured
let openai: OpenAI | null = null;
if (config.ai.enabled && config.ai.openaiApiKey) {
  openai = new OpenAI({ apiKey: config.ai.openaiApiKey });
}

// ========== MEMORY TOOLS ==========

// Enhanced store memory tool with conversation threading
mcp.addTool({
  name: 'storeMemory',
  description: 'Store a memory with conversation threading and preference learning',
  parameters: z.object({
    userId: z.string().describe('User ID'),
    content: z.string().describe('Memory content'),
    companionId: z.string().optional().describe('Companion ID'),
    gameId: z.string().optional().describe('Game ID'),
    conversationId: z.string().optional().describe('Conversation thread ID'),
    parentMemoryId: z.string().optional().describe('Parent memory ID for threading'),
    type: z.string().default('conversation').describe('Memory type'),
    importance: z.number().min(0).max(10).default(1).describe('Importance score (0-10)'),
    decayRate: z.number().min(0).max(1).default(0.95).describe('Importance decay rate'),
    metadata: z.record(z.any()).optional().describe('Additional metadata'),
  }),
  execute: async function({ userId, content, companionId, gameId, conversationId, parentMemoryId, type, importance, decayRate, metadata }) {
    if (!db) {
      throw new McpError('DATABASE_ERROR', 'Database not available');
    }

    // Generate conversation ID if not provided but parent exists
    let finalConversationId = conversationId;
    if (!conversationId && parentMemoryId) {
      const parentMemory = await db.select().from(memories)
        .where(eq(memories.id, parentMemoryId))
        .limit(1);
      if (parentMemory[0]?.conversationId) {
        finalConversationId = parentMemory[0].conversationId;
      }
    } else if (!conversationId && type === 'conversation') {
      finalConversationId = uuidv4();
    }

    let embedding: number[] | null = null;
    
    // Generate embedding if OpenAI is available
    if (openai) {
      try {
        const response = await openai.embeddings.create({
          model: 'text-embedding-3-small',
          input: content,
        });
        embedding = response.data[0].embedding;
      } catch (error) {
        console.error('Failed to generate embedding:', error);
      }
    }

    const memory = await db.insert(memories).values({
      userId,
      companionId,
      gameId,
      conversationId: finalConversationId,
      parentMemoryId,
      content,
      embedding,
      type,
      importance,
      decayRate: decayRate.toString(),
      metadata,
    }).returning();

    // Extract and learn preferences from conversation
    if (type === 'conversation' && companionId) {
      await extractPreferences(userId, companionId, content);
    }

    return {
      memoryId: memory[0].id,
      conversationId: finalConversationId,
      message: 'Memory stored successfully with threading',
    };
  }
});

// Retrieve memories tool
mcp.addTool({
  name: 'retrieveMemories',
  description: 'Retrieve relevant memories for a user',
  parameters: z.object({
    userId: z.string().describe('User ID'),
    query: z.string().describe('Query to search memories'),
    companionId: z.string().optional().describe('Filter by companion'),
    gameId: z.string().optional().describe('Filter by game'),
    limit: z.number().min(1).max(100).default(10).describe('Maximum number of memories to retrieve'),
    includeArchived: z.boolean().default(false).describe('Include archived memories'),
  }),
  execute: async function({ userId, query, companionId, gameId, limit, includeArchived }) {
    if (!db) {
      throw new McpError('DATABASE_ERROR', 'Database not available');
    }

    let queryEmbedding: number[] | null = null;
    
    // Generate query embedding if OpenAI is available
    if (openai && query) {
      try {
        const response = await openai.embeddings.create({
          model: 'text-embedding-3-small',
          input: query,
        });
        queryEmbedding = response.data[0].embedding;
      } catch (error) {
        console.error('Failed to generate query embedding:', error);
      }
    }

    // Build query conditions
    const conditions = [eq(memories.userId, userId)];
    
    if (companionId) {
      conditions.push(eq(memories.companionId, companionId));
    }
    
    if (gameId) {
      conditions.push(eq(memories.gameId, gameId));
    }
    
    if (!includeArchived) {
      conditions.push(eq(memories.isArchived, false));
    }

    let relevantMemories;
    
    if (queryEmbedding) {
      // Use vector similarity search
      relevantMemories = await db
        .select()
        .from(memories)
        .where(and(...conditions))
        .orderBy(
          sql`${memories.embedding} <=> ${JSON.stringify(queryEmbedding)}::vector`
        )
        .limit(limit);
    } else {
      // Fallback to recency-based retrieval
      relevantMemories = await db
        .select()
        .from(memories)
        .where(and(...conditions))
        .orderBy(desc(memories.createdAt))
        .limit(limit);
    }

    return {
      memories: relevantMemories.map(m => ({
        id: m.id,
        content: m.content,
        type: m.type,
        importance: m.importance,
        createdAt: m.createdAt,
        metadata: m.metadata,
      })),
      count: relevantMemories.length,
    };
  }
});

// Consolidate memories tool
mcp.addTool({
  name: 'consolidateMemories',
  description: 'Consolidate old memories into summaries to save space',
  parameters: z.object({
    userId: z.string().describe('User ID'),
    olderThanDays: z.number().min(1).default(30).describe('Consolidate memories older than this many days'),
    minMemories: z.number().min(10).default(50).describe('Minimum number of memories before consolidation'),
  }),
  execute: async function({ userId, olderThanDays, minMemories }) {
    if (!db || !openai) {
      throw new McpError('SERVICE_ERROR', 'Database and OpenAI required for consolidation');
    }

    const cutoffDate = new Date();
    cutoffDate.setDate(cutoffDate.getDate() - olderThanDays);

    // Get old memories
    const oldMemories = await db
      .select()
      .from(memories)
      .where(
        and(
          eq(memories.userId, userId),
          eq(memories.isArchived, false),
          sql`${memories.createdAt} < ${cutoffDate}`
        )
      )
      .orderBy(memories.createdAt);

    if (oldMemories.length < minMemories) {
      return {
        message: `Not enough memories to consolidate (${oldMemories.length} < ${minMemories})`,
      };
    }

    // Group memories by type and companion
    const groups = new Map<string, typeof oldMemories>();
    for (const memory of oldMemories) {
      const key = `${memory.type}_${memory.companionId}_${memory.gameId}`;
      if (!groups.has(key)) {
        groups.set(key, []);
      }
      groups.get(key)!.push(memory);
    }

    let consolidatedCount = 0;
    
    for (const [key, groupMemories] of groups.entries()) {
      if (groupMemories.length < 10) continue;

      // Summarize memories using OpenAI
      const content = groupMemories.map(m => m.content).join('\n---\n');
      
      const response = await openai.chat.completions.create({
        model: 'gpt-3.5-turbo',
        messages: [
          {
            role: 'system',
            content: 'Summarize these memories, preserving key information and emotional moments.',
          },
          {
            role: 'user',
            content,
          },
        ],
        temperature: 0.5,
        max_tokens: 500,
      });

      const summary = response.choices[0].message.content || 'Consolidated memories';

      // Generate embedding for the consolidated memory
      let consolidatedEmbedding: number[] | null = null;
      if (openai) {
        try {
          const embeddingResponse = await openai.embeddings.create({
            model: 'text-embedding-3-small',
            input: summary,
          });
          consolidatedEmbedding = embeddingResponse.data[0].embedding;
        } catch (error) {
          console.error('Failed to generate embedding for consolidated memory:', error);
        }
      }

      // Store consolidated memory
      await db.insert(memories).values({
        userId,
        content: summary,
        embedding: consolidatedEmbedding,
        companionId: groupMemories[0].companionId,
        gameId: groupMemories[0].gameId,
        type: 'consolidated',
        importance: 5,
        metadata: {
          originalCount: groupMemories.length,
          dateRange: {
            from: groupMemories[0].createdAt,
            to: groupMemories[groupMemories.length - 1].createdAt,
          },
        },
      }).returning();

      // Archive old memories
      const memoryIds = groupMemories.map(m => m.id);
      await db
        .update(memories)
        .set({ isArchived: true })
        .where(sql`${memories.id} IN (${sql.join(memoryIds, sql`, `)})`);

      consolidatedCount += groupMemories.length;
    }

    return {
      message: `Consolidated ${consolidatedCount} memories into summaries`,
      archivedCount: consolidatedCount,
    };
  }
});

// ========== COMPANION TOOLS ==========

// Create companion tool
mcp.addTool({
  name: 'createCompanion',
  description: 'Create a new AI companion',
  parameters: z.object({
    name: z.string().describe('Companion name'),
    description: z.string().describe('Companion description'),
    personality: z.string().describe('Personality traits'),
    gameId: z.string().optional().describe('Associated game ID'),
    systemPrompt: z.string().optional().describe('System prompt for AI behavior'),
    avatarUrl: z.string().optional().describe('Avatar image URL'),
    metadata: z.record(z.any()).optional().describe('Additional metadata'),
  }),
  execute: async function({ name, description, personality, gameId, systemPrompt, avatarUrl, metadata }) {
    if (!db) {
      throw new McpError('DATABASE_ERROR', 'Database not available');
    }

    const companion = await db.insert(companions).values({
      name,
      description,
      personality,
      gameId,
      systemPrompt,
      avatarUrl,
      metadata,
    }).returning();

    return {
      companionId: companion[0].id,
      message: `Companion '${name}' created successfully`,
    };
  }
});

// Chat with companion tool
mcp.addTool({
  name: 'chatWithCompanion',
  description: 'Have a conversation with an AI companion',
  parameters: z.object({
    companionId: z.string().describe('Companion ID'),
    userId: z.string().describe('User ID'),
    message: z.string().describe('User message'),
    includeMemories: z.boolean().default(true).describe('Include relevant memories in context'),
    storeConversation: z.boolean().default(true).describe('Store conversation as memory'),
  }),
  execute: async function({ companionId, userId, message, includeMemories, storeConversation }) {
    if (!db) {
      throw new McpError('DATABASE_ERROR', 'Database not available');
    }

    if (!openai) {
      return {
        response: "I'm currently offline, but I'll remember our conversation for later!",
        stored: false,
      };
    }

    // Get companion details
    const companion = await db
      .select()
      .from(companions)
      .where(eq(companions.id, companionId))
      .limit(1);

    if (!companion.length) {
      throw new McpError('NOT_FOUND', 'Companion not found');
    }

    const comp = companion[0];
    let memoryContext = '';

    // Retrieve relevant memories if requested
    if (includeMemories) {
      // Call retrieveMemories logic directly
      const relevantMemories = await (async () => {
        let queryEmbedding: number[] | null = null;
        
        if (openai) {
          try {
            const response = await openai.embeddings.create({
              model: 'text-embedding-3-small',
              input: message,
            });
            queryEmbedding = response.data[0].embedding;
          } catch (error) {
            console.error('Failed to generate query embedding:', error);
          }
        }

        const conditions = [
          eq(memories.userId, userId),
          eq(memories.companionId, companionId),
          eq(memories.isArchived, false)
        ];

        let mems;
        if (queryEmbedding) {
          mems = await db
            .select()
            .from(memories)
            .where(and(...conditions))
            .orderBy(
              sql`${memories.embedding} <=> ${JSON.stringify(queryEmbedding)}::vector`
            )
            .limit(5);
        } else {
          mems = await db
            .select()
            .from(memories)
            .where(and(...conditions))
            .orderBy(desc(memories.createdAt))
            .limit(5);
        }

        return {
        userId,
        companionId,
          memories: mems.map(m => ({
            id: m.id,
            content: m.content,
            type: m.type,
            importance: m.importance,
            createdAt: m.createdAt,
            metadata: m.metadata,
          })),
          count: mems.length,
        };
      })();
      
      if (relevantMemories.memories?.length > 0) {
        memoryContext = '\n\nRelevant memories:\n' + 
          relevantMemories.memories.map((m: any) => `[${m.type}] ${m.content}`).join('\n');
      }
    }

    // Generate response using OpenAI
    const response = await openai.chat.completions.create({
      model: 'gpt-4-turbo-preview',
      messages: [
        {
          role: 'system',
          content: comp.systemPrompt || `You are ${comp.name}. ${comp.description}`,
        },
        {
          role: 'system',
          content: `Personality: ${comp.personality}${memoryContext}`,
        },
        {
          role: 'user',
          content: message,
        },
      ],
      temperature: 0.7,
      max_tokens: 500,
    });

    const companionResponse = response.choices[0].message.content || '';

    // Store conversation as memory if requested
    if (storeConversation) {
      // Store memory directly
      let embedding: number[] | null = null;
      const memContent = `User: ${message}\n${comp.name}: ${companionResponse}`;
      
      if (openai) {
        try {
          const response = await openai.embeddings.create({
            model: 'text-embedding-3-small',
            input: memContent,
          });
          embedding = response.data[0].embedding;
        } catch (error) {
          console.error('Failed to generate embedding:', error);
        }
      }

      await db.insert(memories).values({
        userId,
        companionId,
        content: memContent,
        embedding,
        type: 'conversation',
        importance: 2,
      }).returning();
    }

    return {
      response: companionResponse,
      companionName: comp.name,
      stored: storeConversation,
    };
  }
});

// Get companion stats tool
mcp.addTool({
  name: 'getCompanionStats',
  description: 'Get statistics about a companion relationship',
  parameters: z.object({
    companionId: z.string().describe('Companion ID'),
    userId: z.string().describe('User ID'),
  }),
  execute: async function({ companionId, userId }) {
    if (!db) {
      throw new McpError('DATABASE_ERROR', 'Database not available');
    }

    // Get companion info
    const companion = await db
      .select()
      .from(companions)
      .where(eq(companions.id, companionId))
      .limit(1);

    if (!companion.length) {
      throw new McpError('NOT_FOUND', 'Companion not found');
    }

    // Count memories
    const memoryCount = await db
      .select({ count: sql`count(*)::int` })
      .from(memories)
      .where(
        and(
          eq(memories.companionId, companionId),
          eq(memories.userId, userId)
        )
      );

    // Get first memory
    const firstMemory = await db
      .select({ createdAt: memories.createdAt })
      .from(memories)
      .where(
        and(
          eq(memories.companionId, companionId),
          eq(memories.userId, userId)
        )
      )
      .orderBy(memories.createdAt)
      .limit(1);

    // Get recent memories
    const recentMemories = await db
      .select({
        content: memories.content,
        type: memories.type,
        createdAt: memories.createdAt,
      })
      .from(memories)
      .where(
        and(
          eq(memories.companionId, companionId),
          eq(memories.userId, userId),
          eq(memories.isArchived, false)
        )
      )
      .orderBy(desc(memories.createdAt))
      .limit(5);

    return {
      companion: {
        id: companion[0].id,
        name: companion[0].name,
        description: companion[0].description,
        personality: companion[0].personality,
      },
      stats: {
        totalMemories: memoryCount[0]?.count || 0,
        relationshipAge: firstMemory[0]?.createdAt || new Date(),
        recentInteractions: recentMemories,
      },
    };
  }
});

// ========== RESOURCES ==========

mcp.addResource({
  name: 'companion-list',
  description: 'List of all available companions',
  uri: 'companion-list',
  mimeType: 'application/json',
  read: async function() {
    if (!db) {
      return JSON.stringify({ error: 'Database not available' }, null, 2);
    }

    const companionList = await db
      .select({
        id: companions.id,
        name: companions.name,
        description: companions.description,
        personality: companions.personality,
        gameId: companions.gameId,
        isActive: companions.isActive,
      })
      .from(companions)
      .where(eq(companions.isActive, true));

    return JSON.stringify(companionList, null, 2);
  }
});

mcp.addResource({
  name: 'memory-types',
  description: 'Types of memories that can be stored',
  uri: 'memory-types',
  mimeType: 'application/json',
  read: async function() {
    return JSON.stringify({
      types: [
        { type: 'conversation', description: 'Dialog between user and companion' },
        { type: 'game_state', description: 'Important game state or progress' },
        { type: 'achievement', description: 'User achievements or milestones' },
        { type: 'preference', description: 'User preferences and settings' },
        { type: 'checkpoint', description: 'Game checkpoint or save state' },
        { type: 'consolidated', description: 'Summarized older memories' },
        { type: 'emotion', description: 'Emotional moments or reactions' },
        { type: 'story', description: 'Narrative or story elements' },
      ],
    }, null, 2);
  }
});

// ========== PROMPTS ==========

mcp.addPrompt({
  name: 'companion-personality',
  description: 'Generate a companion personality prompt',
  arguments: [
    { name: 'traits', description: 'Personality traits', default: 'helpful, friendly' },
    { name: 'backstory', description: 'Character backstory', default: '' }
  ],
  resolve: async function({ traits = 'helpful, friendly', backstory = '' }) {
    return `You are an AI companion with the following traits: ${traits}.
    
${backstory ? `Your backstory: ${backstory}\n\n` : ''}
Guidelines:
1. Stay in character consistently
2. Remember past interactions through the memory system
3. Adapt your responses based on user preferences
4. Be helpful while maintaining your personality
5. Create engaging and meaningful interactions
6. Learn and grow from each conversation

Always prioritize the user's emotional well-being and enjoyment.`;
  }
});

mcp.addPrompt({
  name: 'memory-importance',
  description: 'Evaluate the importance of a memory',
  arguments: [
    { name: 'content', description: 'Memory content to evaluate' },
    { name: 'type', description: 'Type of memory', default: 'conversation' }
  ],
  resolve: async function({ content, type = 'conversation' }) {
    return `Evaluate the importance of this ${type} memory on a scale of 0-10:

"${content}"

Consider:
- Emotional significance (moments of joy, achievement, frustration)
- Information value (preferences, facts about the user)
- Relationship development (bonding moments, trust building)
- Game progression (major achievements, story beats)
- Future relevance (information that will be useful later)

Provide a score and brief explanation.`;
  }
});

// ========== NEW ENHANCED TOOLS ==========

// Learn user preferences from conversations
mcp.addTool({
  name: 'learnPreferences',
  description: 'Learn and update user preferences based on interactions',
  parameters: z.object({
    userId: z.string().describe('User ID'),
    companionId: z.string().describe('Companion ID'),
    preferenceKey: z.string().describe('Preference key (e.g., "play_style", "humor_level")'),
    preferenceValue: z.any().describe('Preference value'),
    confidence: z.number().min(0).max(1).default(0.5).describe('Confidence in this preference'),
  }),
  execute: async function({ userId, companionId, preferenceKey, preferenceValue, confidence }) {
    if (!db) {
      throw new McpError('DATABASE_ERROR', 'Database not available');
    }

    // Check if preference exists
    const existing = await db.select().from(userPreferences)
      .where(and(
        eq(userPreferences.userId, userId),
        eq(userPreferences.companionId, companionId),
        eq(userPreferences.preferenceKey, preferenceKey)
      ))
      .limit(1);

    if (existing.length > 0) {
      // Update existing preference with weighted average
      const newConfidence = Math.min(1, (parseFloat(existing[0].confidence) + confidence) / 2 + 0.1);
      await db.update(userPreferences)
        .set({
          preferenceValue,
          confidence: newConfidence.toString(),
          lastUpdated: new Date(),
        })
        .where(eq(userPreferences.id, existing[0].id));
    } else {
      // Create new preference
      await db.insert(userPreferences).values({
        userId,
        companionId,
        preferenceKey,
        preferenceValue,
        confidence: confidence.toString(),
      });
    }

    return {
      message: 'Preference learned successfully',
      key: preferenceKey,
      value: preferenceValue,
    };
  }
});

// Cluster similar memories into topics
mcp.addTool({
  name: 'clusterMemories',
  description: 'Group similar memories into topic clusters',
  parameters: z.object({
    userId: z.string().describe('User ID'),
    companionId: z.string().describe('Companion ID'),
    minClusterSize: z.number().min(2).default(3).describe('Minimum memories per cluster'),
  }),
  execute: async function({ userId, companionId, minClusterSize }) {
    if (!db || !openai) {
      throw new McpError('SERVICE_ERROR', 'Required services not available');
    }

    // Get recent memories with embeddings
    const recentMemories = await db.select().from(memories)
      .where(and(
        eq(memories.userId, userId),
        eq(memories.companionId, companionId),
        eq(memories.isArchived, false),
        sql`${memories.embedding} IS NOT NULL`
      ))
      .orderBy(desc(memories.createdAt))
      .limit(100);

    if (recentMemories.length < minClusterSize) {
      return { message: 'Not enough memories to cluster' };
    }

    // Simple clustering: group by similarity threshold
    const clusters: Map<string, typeof recentMemories> = new Map();
    const threshold = 0.8;

    for (const memory of recentMemories) {
      let assigned = false;
      
      for (const [clusterId, clusterMemories] of clusters) {
        if (clusterMemories.length > 0 && memory.embedding && clusterMemories[0].embedding) {
          // Calculate cosine similarity
          const similarity = cosineSimilarity(
            memory.embedding as number[],
            clusterMemories[0].embedding as number[]
          );
          
          if (similarity > threshold) {
            clusterMemories.push(memory);
            assigned = true;
            break;
          }
        }
      }
      
      if (!assigned) {
        clusters.set(memory.id, [memory]);
      }
    }

    // Save significant clusters
    const savedClusters = [];
    for (const [_, clusterMemories] of clusters) {
      if (clusterMemories.length >= minClusterSize) {
        // Generate cluster summary
        const summary = await summarizeCluster(clusterMemories);
        
        // Calculate centroid embedding
        const centroid = calculateCentroid(clusterMemories.map(m => m.embedding as number[]));
        
        const cluster = await db.insert(conversationClusters).values({
          userId,
          companionId,
          topic: summary.topic,
          centroidEmbedding: centroid,
          memoryIds: clusterMemories.map(m => m.id),
          summaryContent: summary.content,
        }).returning();
        
        savedClusters.push(cluster[0]);
      }
    }

    return {
      message: 'Memories clustered successfully',
      clustersCreated: savedClusters.length,
      topics: savedClusters.map(c => c.topic),
    };
  }
});

// Decay memory importance over time
mcp.addTool({
  name: 'decayMemoryImportance',
  description: 'Apply time-based decay to memory importance scores',
  parameters: z.object({
    userId: z.string().describe('User ID'),
    daysOld: z.number().min(1).default(30).describe('Decay memories older than this many days'),
  }),
  execute: async function({ userId, daysOld }) {
    if (!db) {
      throw new McpError('DATABASE_ERROR', 'Database not available');
    }

    const cutoffDate = new Date();
    cutoffDate.setDate(cutoffDate.getDate() - daysOld);

    // Apply decay to old memories
    const updated = await db.update(memories)
      .set({
        importance: sql`GREATEST(0, ${memories.importance} * CAST(${memories.decayRate} AS NUMERIC))`,
      })
      .where(and(
        eq(memories.userId, userId),
        lte(memories.lastAccessedAt, cutoffDate),
        gte(memories.importance, 1)
      ))
      .returning({ id: memories.id });

    // Archive memories with very low importance
    await db.update(memories)
      .set({ isArchived: true })
      .where(and(
        eq(memories.userId, userId),
        lte(memories.importance, 1)
      ));

    return {
      message: 'Memory importance decayed',
      memoriesUpdated: updated.length,
    };
  }
});

// ========== HELPER FUNCTIONS ==========

async function extractPreferences(userId: string, companionId: string, content: string) {
  if (!openai) return;
  
  try {
    const response = await openai.chat.completions.create({
      model: 'gpt-3.5-turbo',
      messages: [
        {
          role: 'system',
          content: 'Extract user preferences from this conversation. Return JSON with format: {preferences: [{key: string, value: any, confidence: number}]}'
        },
        { role: 'user', content }
      ],
      response_format: { type: 'json_object' },
      temperature: 0.3,
    });
    
    const result = JSON.parse(response.choices[0].message.content || '{}');
    
    if (result.preferences && Array.isArray(result.preferences)) {
      for (const pref of result.preferences) {
        await db.insert(userPreferences).values({
          userId,
          companionId,
          preferenceKey: pref.key,
          preferenceValue: pref.value,
          confidence: pref.confidence.toString(),
        }).onConflictDoNothing();
      }
    }
  } catch (error) {
    console.error('Failed to extract preferences:', error);
  }
}

function cosineSimilarity(a: number[], b: number[]): number {
  let dotProduct = 0;
  let normA = 0;
  let normB = 0;
  
  for (let i = 0; i < a.length; i++) {
    dotProduct += a[i] * b[i];
    normA += a[i] * a[i];
    normB += b[i] * b[i];
  }
  
  return dotProduct / (Math.sqrt(normA) * Math.sqrt(normB));
}

function calculateCentroid(embeddings: number[][]): number[] {
  if (embeddings.length === 0) return [];
  
  const dimensions = embeddings[0].length;
  const centroid = new Array(dimensions).fill(0);
  
  for (const embedding of embeddings) {
    for (let i = 0; i < dimensions; i++) {
      centroid[i] += embedding[i];
    }
  }
  
  return centroid.map(val => val / embeddings.length);
}

async function summarizeCluster(memories: any[]): Promise<{ topic: string; content: string }> {
  if (!openai) {
    return {
      topic: 'Conversation',
      content: memories.map(m => m.content).join(' '),
    };
  }
  
  try {
    const response = await openai.chat.completions.create({
      model: 'gpt-3.5-turbo',
      messages: [
        {
          role: 'system',
          content: 'Summarize these related memories into a topic and brief summary. Return JSON: {topic: string, content: string}'
        },
        {
          role: 'user',
          content: memories.map(m => m.content).join('\n\n')
        }
      ],
      response_format: { type: 'json_object' },
      temperature: 0.5,
    });
    
    return JSON.parse(response.choices[0].message.content || '{"topic": "Conversation", "content": ""}');
  } catch (error) {
    console.error('Failed to summarize cluster:', error);
    return {
      topic: 'Conversation',
      content: memories.map(m => m.content).slice(0, 3).join(' '),
    };
  }
}

// Start the server
const PORT = parseInt(config.app.port);

async function startServer() {
  if (process.argv.includes('--stdio')) {
    // Run in stdio mode for MCP protocol
    await mcp.serve({
      transport: 'stdio',
    });
    console.error(`Companion & Memory MCP Server running on stdio`);
  } else {
    // Run as HTTP server for testing
    const server = await mcp.serve({
      transport: 'sse',
      httpPath: '/mcp',
      port: PORT,
    });
    console.log(`Companion & Memory MCP Server running on http://localhost:${PORT}/mcp`);
  }
}

startServer().catch((error) => {
  console.error('Failed to start MCP server:', error);
  process.exit(1);
});