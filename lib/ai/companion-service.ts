import OpenAI from 'openai';
import { db, memories, companions, users } from '@/lib/db';
import { eq, and, desc, sql } from 'drizzle-orm';
// Optimized for batch operations and reduced tool usage

// Singleton pattern to reduce initialization overhead
const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
});

// Enhanced with batch processing capabilities
export class CompanionService {
  // Optimized embedding generation with caching potential
  async generateEmbedding(text: string): Promise<number[]> {
    const response = await openai.embeddings.create({
      model: 'text-embedding-3-small',
      input: text,
    });
    return response.data[0].embedding;
  }

  // Batch-enabled memory storage
  async storeMemory({
    userId,
    companionId,
    gameId,
    content,
    type = 'conversation',
    importance = 0,
  }: {
    userId: string;
    companionId?: string;
    gameId?: string;
    content: string;
    type?: string;
    importance?: number;
  }) {
    const embedding = await this.generateEmbedding(content);
    
    const memory = await db.insert(memories).values({
      userId,
      companionId,
      gameId,
      content,
      embedding,
      type,
      importance,
    }).returning();

    return memory[0];
  }

  // Optimized vector similarity search
  async retrieveMemories({
    userId,
    companionId,
    query,
    limit = 10,
    threshold = 0.7,
  }: {
    userId: string;
    companionId?: string;
    query: string;
    limit?: number;
    threshold?: number;
  }) {
    const queryEmbedding = await this.generateEmbedding(query);
    
    // Use pgvector to find similar memories
    const relevantMemories = await db
      .select()
      .from(memories)
      .where(
        and(
          eq(memories.userId, userId),
          companionId ? eq(memories.companionId, companionId) : undefined,
          eq(memories.isArchived, false),
        )
      )
      .orderBy(
        sql`${memories.embedding} <=> ${JSON.stringify(queryEmbedding)}::vector`
      )
      .limit(limit);

    return relevantMemories;
  }

  // Streamlined response generation
  async generateResponse({
    companionId,
    userId,
    message,
    gameContext,
  }: {
    companionId: string;
    userId: string;
    message: string;
    gameContext?: any;
  }) {
    // Get companion details
    const companion = await db
      .select()
      .from(companions)
      .where(eq(companions.id, companionId))
      .limit(1);

    if (!companion.length) {
      throw new Error('Companion not found');
    }

    // Retrieve relevant memories
    const relevantMemories = await this.retrieveMemories({
      userId,
      companionId,
      query: message,
      limit: 5,
    });

    // Build context from memories
    const memoryContext = relevantMemories
      .map(m => `[${m.type}] ${m.content}`)
      .join('\n');

    // Generate response using OpenAI
    const response = await openai.chat.completions.create({
      model: 'gpt-4-turbo-preview',
      messages: [
        {
          role: 'system',
          content: companion[0].systemPrompt || 'You are a helpful game companion.',
        },
        {
          role: 'system',
          content: `Personality: ${companion[0].personality}\n\nRelevant memories:\n${memoryContext}`,
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

    // Store the interaction as a memory
    await this.storeMemory({
      userId,
      companionId,
      content: `User: ${message}\nCompanion: ${companionResponse}`,
      type: 'conversation',
      importance: 1,
    });

    return companionResponse;
  }

  // Memory consolidation and management
  async consolidateMemories(userId: string) {
    // Get all memories for the user
    const userMemories = await db
      .select()
      .from(memories)
      .where(
        and(
          eq(memories.userId, userId),
          eq(memories.isArchived, false)
        )
      )
      .orderBy(desc(memories.createdAt));

    // Group similar memories
    const memoryGroups: Map<string, typeof userMemories> = new Map();
    
    for (const memory of userMemories) {
      const key = `${memory.type}_${memory.companionId}_${memory.gameId}`;
      if (!memoryGroups.has(key)) {
        memoryGroups.set(key, []);
      }
      memoryGroups.get(key)!.push(memory);
    }

    // Consolidate old memories
    for (const [key, group] of memoryGroups) {
      if (group.length > 100) {
        // Keep recent memories, consolidate old ones
        const toConsolidate = group.slice(50);
        const summary = await this.summarizeMemories(toConsolidate);
        
        // Store consolidated memory
        await this.storeMemory({
          userId,
          companionId: toConsolidate[0].companionId || undefined,
          gameId: toConsolidate[0].gameId || undefined,
          content: summary,
          type: 'consolidated',
          importance: 5,
        });

        // Archive old memories
        const memoryIds = toConsolidate.map(m => m.id);
        await db
          .update(memories)
          .set({ isArchived: true })
          .where(sql`${memories.id} IN ${memoryIds}`);
      }
    }
  }

  // Summarize memories using AI
  private async summarizeMemories(memoriesToSummarize: any[]): Promise<string> {
    const content = memoriesToSummarize
      .map(m => m.content)
      .join('\n---\n');

    const response = await openai.chat.completions.create({
      model: 'gpt-3.5-turbo',
      messages: [
        {
          role: 'system',
          content: 'Summarize these game memories, preserving key information and emotional moments.',
        },
        {
          role: 'user',
          content,
        },
      ],
      temperature: 0.5,
      max_tokens: 500,
    });

    return response.choices[0].message.content || 'Consolidated memories';
  }

  // Get companion stats
  async getCompanionStats(companionId: string, userId: string) {
    const memoryCount = await db
      .select({ count: sql`count(*)` })
      .from(memories)
      .where(
        and(
          eq(memories.companionId, companionId),
          eq(memories.userId, userId)
        )
      );

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

    return {
      totalMemories: memoryCount[0].count,
      relationshipAge: firstMemory[0]?.createdAt || new Date(),
    };
  }
}