import { pgTable, text, timestamp, uuid, jsonb, vector, index, integer, boolean, decimal } from 'drizzle-orm/pg-core';
import { relations } from 'drizzle-orm';

// Users table
export const users = pgTable('users', {
  id: uuid('id').defaultRandom().primaryKey(),
  walletAddress: text('wallet_address').unique().notNull(),
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
  content: text('content').notNull(),
  embedding: vector('embedding', { dimensions: 1536 }), // OpenAI embeddings
  type: text('type'), // 'conversation', 'game_state', 'achievement', etc.
  importance: integer('importance').default(0),
  isArchived: boolean('is_archived').default(false),
  expiresAt: timestamp('expires_at'),
  createdAt: timestamp('created_at').defaultNow().notNull(),
  metadata: jsonb('metadata'),
}, (table) => ({
  userIdx: index('memory_user_idx').on(table.userId),
  companionIdx: index('memory_companion_idx').on(table.companionId),
  embeddingIdx: index('memory_embedding_idx').using('hnsw', table.embedding.op('vector_cosine_ops')),
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

// Achievements table
export const achievements = pgTable('achievements', {
  id: uuid('id').defaultRandom().primaryKey(),
  gameId: uuid('game_id').references(() => games.id),
  name: text('name').notNull(),
  description: text('description'),
  iconUrl: text('icon_url'),
  points: integer('points').default(0),
  rarity: text('rarity'), // 'common', 'rare', 'epic', 'legendary'
  condition: jsonb('condition'), // JSON defining achievement criteria
  createdAt: timestamp('created_at').defaultNow().notNull(),
}, (table) => ({
  gameIdx: index('achievement_game_idx').on(table.gameId),
}));

// User Achievements table
export const userAchievements = pgTable('user_achievements', {
  id: uuid('id').defaultRandom().primaryKey(),
  userId: uuid('user_id').references(() => users.id),
  achievementId: uuid('achievement_id').references(() => achievements.id),
  unlockedAt: timestamp('unlocked_at').defaultNow().notNull(),
  metadata: jsonb('metadata'),
}, (table) => ({
  userIdx: index('user_achievement_user_idx').on(table.userId),
  achievementIdx: index('user_achievement_achievement_idx').on(table.achievementId),
}));

// Leaderboards table
export const leaderboards = pgTable('leaderboards', {
  id: uuid('id').defaultRandom().primaryKey(),
  gameId: uuid('game_id').references(() => games.id),
  userId: uuid('user_id').references(() => users.id),
  score: integer('score').notNull(),
  rank: integer('rank'),
  period: text('period'), // 'daily', 'weekly', 'monthly', 'all-time'
  createdAt: timestamp('created_at').defaultNow().notNull(),
}, (table) => ({
  gameIdx: index('leaderboard_game_idx').on(table.gameId),
  userIdx: index('leaderboard_user_idx').on(table.userId),
  scoreIdx: index('leaderboard_score_idx').on(table.score),
}));

// Token Holdings table
export const tokenHoldings = pgTable('token_holdings', {
  id: uuid('id').defaultRandom().primaryKey(),
  userId: uuid('user_id').references(() => users.id),
  tokenAddress: text('token_address').notNull(),
  balance: decimal('balance', { precision: 78, scale: 18 }).notNull(),
  chainId: integer('chain_id').notNull(),
  updatedAt: timestamp('updated_at').defaultNow().notNull(),
}, (table) => ({
  userIdx: index('holding_user_idx').on(table.userId),
  tokenIdx: index('holding_token_idx').on(table.tokenAddress),
}));

// Relations
export const usersRelations = relations(users, ({ many }) => ({
  games: many(games),
  gameSessions: many(gameSessions),
  memories: many(memories),
  userAchievements: many(userAchievements),
  leaderboards: many(leaderboards),
  tokenHoldings: many(tokenHoldings),
}));

export const gamesRelations = relations(games, ({ one, many }) => ({
  creator: one(users, {
    fields: [games.creatorId],
    references: [users.id],
  }),
  companions: many(companions),
  gameSessions: many(gameSessions),
  achievements: many(achievements),
  leaderboards: many(leaderboards),
  memories: many(memories),
}));

export const companionsRelations = relations(companions, ({ one, many }) => ({
  game: one(games, {
    fields: [companions.gameId],
    references: [games.id],
  }),
  memories: many(memories),
  gameSessions: many(gameSessions),
}));

export const memoriesRelations = relations(memories, ({ one }) => ({
  user: one(users, {
    fields: [memories.userId],
    references: [users.id],
  }),
  companion: one(companions, {
    fields: [memories.companionId],
    references: [companions.id],
  }),
  game: one(games, {
    fields: [memories.gameId],
    references: [games.id],
  }),
}));