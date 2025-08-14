import OpenAI from 'openai';
import { db, memories, companions, safeDbOperation } from '@/lib/db';
import { eq, and, desc, sql } from 'drizzle-orm';
import { config } from '@/lib/config/env';
import { AppError } from '@/lib/utils/error-handler';

export class CompanionService {
  private openai: OpenAI | null = null;
  private fallbackResponses: readonly string[];

  constructor() {
    this.fallbackResponses = config.ai.fallbackMessages;
    
    if (config.ai.enabled && config.ai.openaiApiKey) {
      this.openai = new OpenAI({
        apiKey: config.ai.openaiApiKey,
      });
    } else {
      console.warn('⚠️ OpenAI API not configured. Using fallback responses.');
    }
  }

  private isDatabaseAvailable(): boolean {
    return db !== null && config.database.enabled;
  }

  async generateEmbedding(text: string): Promise<number[]> {
    if (!this.openai) {
      throw new AppError('OpenAI API not configured', 503);
    }
    
    try {
      const response = await this.openai.embeddings.create({
        model: 'text-embedding-3-small',
        input: text,
      });
      return response.data[0].embedding;
    } catch (error) {
      console.error('Failed to generate embedding:', error);
      throw new AppError('Failed to generate embedding', 500);
    }
  }

  async storeMemory({
    userId,
    companionId,
    gameId,
    content,
    type = 'conversation',
    importance = 0,
    conversationId,
    parentMemoryId,
  }: {
    userId: string;
    companionId?: string;
    gameId?: string;
    content: string;
    type?: string;
    importance?: number;
    conversationId?: string;
    parentMemoryId?: string;
  }) {
    if (!this.isDatabaseAvailable()) {
      console.warn('Database not available, skipping memory storage');
      return null;
    }

    if (!this.openai) {
      console.warn('OpenAI not available, skipping memory storage with embeddings');
      return null;
    }

    // Generate conversation ID for threaded conversations
    let finalConversationId = conversationId;
    if (!conversationId && parentMemoryId) {
      const parentMemory = await db!.select().from(memories)
        .where(eq(memories.id, parentMemoryId))
        .limit(1);
      if (parentMemory[0]?.conversationId) {
        finalConversationId = parentMemory[0].conversationId;
      }
    } else if (!conversationId && type === 'conversation') {
      finalConversationId = crypto.randomUUID();
    }

    const embedding = await this.generateEmbedding(content);
    
    const memory = await db!.insert(memories).values({
      userId,
      companionId,
      gameId,
      conversationId: finalConversationId,
      parentMemoryId,
      content,
      embedding,
      type,
      importance,
      decayRate: '0.95',
      lastAccessedAt: new Date(),
      accessCount: 0,
    }).returning();

    // Update access count for retrieved memories
    if (parentMemoryId) {
      await db!.update(memories)
        .set({
          accessCount: sql`${memories.accessCount} + 1`,
          lastAccessedAt: new Date(),
        })
        .where(eq(memories.id, parentMemoryId));
    }

    return memory[0];
  }

  async retrieveMemories({
    userId,
    companionId,
    query,
    limit = 10,
  }: {
    userId: string;
    companionId?: string;
    query: string;
    limit?: number;
  }) {
    if (!this.isDatabaseAvailable()) {
      console.warn('Database not available, returning empty memories');
      return [];
    }

    if (!this.openai) {
      console.warn('OpenAI not available, cannot retrieve memories with embeddings');
      return [];
    }

    const queryEmbedding = await this.generateEmbedding(query);
    
    const relevantMemories = await db!
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

    // Update access count and last accessed time
    if (relevantMemories.length > 0) {
      const memoryIds = relevantMemories.map(m => m.id);
      await db!.update(memories)
        .set({
          accessCount: sql`${memories.accessCount} + 1`,
          lastAccessedAt: new Date(),
        })
        .where(sql`${memories.id} = ANY(${memoryIds})`);
    }

    return relevantMemories;
  }

  async getConversationHistory({
    userId,
    companionId,
    conversationId,
    limit = 20,
  }: {
    userId: string;
    companionId?: string;
    conversationId?: string;
    limit?: number;
  }) {
    if (!this.isDatabaseAvailable()) {
      return [];
    }

    const conditions = [
      eq(memories.userId, userId),
      eq(memories.type, 'conversation'),
    ];

    if (companionId) conditions.push(eq(memories.companionId, companionId));
    if (conversationId) conditions.push(eq(memories.conversationId, conversationId));

    const history = await db!
      .select()
      .from(memories)
      .where(and(...conditions))
      .orderBy(desc(memories.createdAt))
      .limit(limit);

    return history.reverse(); // Return in chronological order
  }

  async generateResponse({
    companionId,
    userId,
    message,
  }: {
    companionId: string;
    userId: string;
    message: string;
  }): Promise<string> {
    // Input validation
    if (!message?.trim()) {
      throw new AppError('Message cannot be empty', 400);
    }

    if (message.length > 1000) {
      throw new AppError('Message too long. Please keep it under 1000 characters.', 400);
    }

    // If no database or OpenAI, use fallback
    if (!this.isDatabaseAvailable() || !this.openai) {
      return this.getFallbackResponse();
    }

    // Try to fetch companion from database
    const companion = await safeDbOperation(
      async () => {
        const result = await db!
          .select()
          .from(companions)
          .where(eq(companions.id, companionId))
          .limit(1);
        return result[0];
      },
      null
    );

    // Get companion personality config
    const companionPersonality = companion ? {
      systemPrompt: companion.systemPrompt,
      personality: companion.personality,
      name: companion.name
    } : {
      systemPrompt: this.getDefaultSystemPrompt(companionId),
      personality: 'helpful and enthusiastic',
      name: 'AI Companion'
    };

    // Try to retrieve memories if database is available
    const relevantMemories = await safeDbOperation(
      async () => this.retrieveMemories({
        userId,
        companionId,
        query: message,
        limit: 5,
      }),
      []
    );

    const memoryContext = relevantMemories
      .map(m => `[${m.type}] ${m.content}`)
      .join('\n');

    try {
      const response = await this.openai!.chat.completions.create({
        model: 'gpt-3.5-turbo',
        messages: [
          {
            role: 'system',
            content: companionPersonality.systemPrompt || this.getDefaultSystemPrompt(companionId),
          },
          ...(memoryContext ? [{
            role: 'system' as const,
            content: `Personality: ${companionPersonality.personality}\nCompanion Name: ${companionPersonality.name}\n\nRelevant memories:\n${memoryContext}`,
          }] : []),
          {
            role: 'user',
            content: message,
          },
        ],
        temperature: 0.7,
        max_tokens: 150,
      }, {
        timeout: 10000, // 10 second timeout
      });

      const companionResponse = response.choices[0].message.content || '';

      // Try to store memory if database is available
      await safeDbOperation(
        async () => this.storeMemory({
          userId,
          companionId,
          content: `User: ${message}\nCompanion: ${companionResponse}`,
          type: 'conversation',
          importance: 1,
        }),
        null
      );

      return companionResponse;
    } catch (error) {
      console.error('Failed to generate response:', error);
      
      // Handle specific errors
      if (error instanceof Error) {
        if (error.message.includes('rate limit')) {
          return "I'm thinking really hard right now! Please give me a moment and try again.";
        }
        if (error.message.includes('timeout')) {
          return "My thoughts are moving a bit slow today. Let's try that again!";
        }
      }
      
      return this.getFallbackResponse();
    }
  }

  private getDefaultSystemPrompt(companionId: string): string {
    // Generate companion-specific personality based on ID
    const personalities = [
      'enthusiastic and supportive gaming buddy',
      'strategic and analytical game coach',
      'friendly and encouraging teammate',
      'competitive but fair rival',
      'wise and experienced mentor'
    ];
    
    // Use companion ID to consistently select a personality
    const personalityIndex = companionId.split('').reduce((acc, char) => acc + char.charCodeAt(0), 0) % personalities.length;
    const personality = personalities[personalityIndex];
    
    return `You are a ${personality} in the Artificial Arcade gaming platform. 
    Your unique ID is ${companionId}. Stay in character and help players enjoy their gaming experience.
    Keep responses concise, relevant, and engaging. Use appropriate gaming terminology.
    Adapt your responses based on the conversation context and player's needs.`;
  }

  private getFallbackResponse(): string {
    const randomIndex = Math.floor(Math.random() * this.fallbackResponses.length);
    return this.fallbackResponses[randomIndex];
  }

  async consolidateMemories(userId: string) {
    if (!this.isDatabaseAvailable()) {
      console.warn('Database not available');
      return;
    }

    const userMemories = await db!
      .select()
      .from(memories)
      .where(
        and(
          eq(memories.userId, userId),
          eq(memories.isArchived, false)
        )
      )
      .orderBy(desc(memories.createdAt));

    const memoryGroups: Map<string, typeof userMemories> = new Map();
    
    for (const memory of userMemories) {
      const key = `${memory.type}_${memory.companionId}_${memory.gameId}`;
      if (!memoryGroups.has(key)) {
        memoryGroups.set(key, []);
      }
      memoryGroups.get(key)!.push(memory);
    }

    for (const group of memoryGroups.values()) {
      if (group.length > 100) {
        const toConsolidate = group.slice(50);
        const summary = await this.summarizeMemories(toConsolidate);
        
        await this.storeMemory({
          userId,
          companionId: toConsolidate[0].companionId || undefined,
          gameId: toConsolidate[0].gameId || undefined,
          content: summary,
          type: 'consolidated',
          importance: 5,
        });

        const memoryIds = toConsolidate.map(m => m.id);
        await db!
          .update(memories)
          .set({ isArchived: true })
          .where(sql`${memories.id} IN ${memoryIds}`);
      }
    }
  }

  private async summarizeMemories(memoriesToSummarize: Array<{content: string}>): Promise<string> {
    if (!this.openai) {
      return 'Consolidated memories';
    }
    
    const content = memoriesToSummarize
      .map(m => m.content)
      .join('\n---\n');

    try {
      const response = await this.openai.chat.completions.create({
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
    } catch (error) {
      console.error('Failed to summarize memories:', error);
      return 'Consolidated memories';
    }
  }

  async getCompanionStats(companionId: string, userId: string) {
    if (!this.isDatabaseAvailable()) {
      return {
        totalMemories: 0,
        relationshipAge: new Date(),
      };
    }

    const memoryCount = await db!
      .select({ count: sql`count(*)` })
      .from(memories)
      .where(
        and(
          eq(memories.companionId, companionId),
          eq(memories.userId, userId)
        )
      );

    const firstMemory = await db!
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
      totalMemories: Number(memoryCount[0]?.count || 0),
      relationshipAge: firstMemory[0]?.createdAt || new Date(),
    };
  }

  // Health check method
  async checkHealth(): Promise<boolean> {
    if (!this.openai) return false;
    
    try {
      await this.openai.chat.completions.create({
        model: 'gpt-3.5-turbo',
        messages: [{ role: 'user', content: 'test' }],
        max_tokens: 1,
      });
      return true;
    } catch {
      return false;
    }
  }
}