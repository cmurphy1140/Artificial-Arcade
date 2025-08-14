import { pgTable, text, timestamp, uuid, jsonb, vector, index, integer, boolean, decimal } from 'drizzle-orm/pg-core';

// Users table
export const users = pgTable('users', {
  id: uuid('id').defaultRandom().primaryKey(),
  walletAddress: text('wallet_address').unique(),
  username: text('username').unique(),
  email: text('email'),
  avatarUrl: text('avatar_url'),
  bio: text('bio'),
  createdAt: timestamp('created_at').defaultNow().notNull(),
  updatedAt: timestamp('updated_at').defaultNow().notNull(),
  metadata: jsonb('metadata'),
});

// Games table
export const games = pgTable('games', {
  id: uuid('id').defaultRandom().primaryKey(),
  title: text('title').notNull(),
  description: text('description'),
  slug: text('slug').unique().notNull(),
  creatorId: uuid('creator_id').references(() => users.id),
  thumbnailUrl: text('thumbnail_url'),
  playUrl: text('play_url'),
  category: text('category'),
  tags: text('tags').array(),
  isPublished: boolean('is_published').default(false),
  isFeatured: boolean('is_featured').default(false),
  tokenGated: boolean('token_gated').default(false),
  requiredTokens: integer('required_tokens'),
  playCount: integer('play_count').default(0),
  rating: decimal('rating', { precision: 3, scale: 2 }),
  createdAt: timestamp('created_at').defaultNow().notNull(),
  updatedAt: timestamp('updated_at').defaultNow().notNull(),
  metadata: jsonb('metadata'),
}, (table) => ({
  slugIdx: index('game_slug_idx').on(table.slug),
  creatorIdx: index('game_creator_idx').on(table.creatorId),
}));

// AI Companions table
export const companions = pgTable('companions', {
  id: uuid('id').defaultRandom().primaryKey(),
  gameId: uuid('game_id').references(() => games.id),
  name: text('name').notNull(),
  description: text('description'),
  personality: text('personality'),
  avatarUrl: text('avatar_url'),
  systemPrompt: text('system_prompt'),
  isActive: boolean('is_active').default(true),
  createdAt: timestamp('created_at').defaultNow().notNull(),
  updatedAt: timestamp('updated_at').defaultNow().notNull(),
  metadata: jsonb('metadata'),
}, (table) => ({
  gameIdx: index('companion_game_idx').on(table.gameId),
}));

// Memories table with pgvector
export const memories = pgTable('memories', {
  id: uuid('id').defaultRandom().primaryKey(),
  userId: uuid('user_id').references(() => users.id),
  companionId: uuid('companion_id').references(() => companions.id),
  gameId: uuid('game_id').references(() => games.id),
  conversationId: uuid('conversation_id'), // NEW: Thread conversations together
  parentMemoryId: uuid('parent_memory_id'), // NEW: Link to parent memory
  content: text('content').notNull(),
  embedding: vector('embedding', { dimensions: 1536 }),
  type: text('type'),
  importance: integer('importance').default(0),
  decayRate: decimal('decay_rate', { precision: 3, scale: 2 }).default('0.95'), // NEW: Importance decay
  lastAccessedAt: timestamp('last_accessed_at').defaultNow(), // NEW: Track access
  accessCount: integer('access_count').default(0), // NEW: Access frequency
  isArchived: boolean('is_archived').default(false),
  expiresAt: timestamp('expires_at'),
  createdAt: timestamp('created_at').defaultNow().notNull(),
  metadata: jsonb('metadata'),
}, (table) => ({
  userIdx: index('memory_user_idx').on(table.userId),
  companionIdx: index('memory_companion_idx').on(table.companionId),
  conversationIdx: index('memory_conversation_idx').on(table.conversationId),
  embeddingIdx: index('memory_embedding_idx').using('hnsw', table.embedding.op('vector_cosine_ops')),
}));

// User Preferences table - NEW
export const userPreferences = pgTable('user_preferences', {
  id: uuid('id').defaultRandom().primaryKey(),
  userId: uuid('user_id').references(() => users.id).notNull(),
  companionId: uuid('companion_id').references(() => companions.id),
  preferenceKey: text('preference_key').notNull(),
  preferenceValue: jsonb('preference_value'),
  confidence: decimal('confidence', { precision: 3, scale: 2 }).default('0.5'),
  learnedAt: timestamp('learned_at').defaultNow().notNull(),
  lastUpdated: timestamp('last_updated').defaultNow().notNull(),
  metadata: jsonb('metadata'),
}, (table) => ({
  userCompanionIdx: index('pref_user_companion_idx').on(table.userId, table.companionId),
  keyIdx: index('pref_key_idx').on(table.preferenceKey),
}));

// Conversation Clusters table - NEW
export const conversationClusters = pgTable('conversation_clusters', {
  id: uuid('id').defaultRandom().primaryKey(),
  userId: uuid('user_id').references(() => users.id),
  companionId: uuid('companion_id').references(() => companions.id),
  topic: text('topic').notNull(),
  centroidEmbedding: vector('centroid_embedding', { dimensions: 1536 }),
  memoryIds: uuid('memory_ids').array(),
  summaryContent: text('summary_content'),
  createdAt: timestamp('created_at').defaultNow().notNull(),
  updatedAt: timestamp('updated_at').defaultNow().notNull(),
}, (table) => ({
  userCompanionIdx: index('cluster_user_companion_idx').on(table.userId, table.companionId),
  centroidIdx: index('cluster_centroid_idx').using('hnsw', table.centroidEmbedding.op('vector_cosine_ops')),
}));

// Game Sessions table
export const gameSessions = pgTable('game_sessions', {
  id: uuid('id').defaultRandom().primaryKey(),
  userId: uuid('user_id').references(() => users.id),
  gameId: uuid('game_id').references(() => games.id),
  companionId: uuid('companion_id').references(() => companions.id),
  startedAt: timestamp('started_at').defaultNow().notNull(),
  endedAt: timestamp('ended_at'),
  score: integer('score'),
  gameState: jsonb('game_state'),
  metadata: jsonb('metadata'),
}, (table) => ({
  userIdx: index('session_user_idx').on(table.userId),
  gameIdx: index('session_game_idx').on(table.gameId),
}));