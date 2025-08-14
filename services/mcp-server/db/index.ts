import { drizzle } from 'drizzle-orm/neon-http';
import { neon } from '@neondatabase/serverless';
import * as schema from './schema';
import { config } from '../config';

// Database connection
let db: ReturnType<typeof drizzle> | null = null;
let sql: ReturnType<typeof neon> | null = null;

if (config.database.url) {
  try {
    sql = neon(config.database.url);
    db = drizzle(sql, { schema });
    console.log('✅ MCP Server: Database connection established');
  } catch (error) {
    console.error('❌ MCP Server: Database connection failed:', error);
    db = null;
  }
} else {
  console.warn('⚠️ MCP Server: Database not configured. Running in offline mode.');
}

export { db, sql };
export * from './schema';
export { userPreferences, conversationClusters } from './schema';