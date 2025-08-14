import { drizzle } from 'drizzle-orm/neon-http';
import { neon } from '@neondatabase/serverless';
import * as schema from './schema';
import { config } from '@/lib/config/env';
import { DatabaseError } from '@/lib/utils/error-handler';

// Database connection with improved error handling
let db: ReturnType<typeof drizzle> | null = null;
let sql: ReturnType<typeof neon> | null = null;

if (config.database.enabled && config.database.url) {
  try {
    sql = neon(config.database.url);
    db = drizzle(sql, { schema });
    console.log('✅ Database connection established');
  } catch (error) {
    console.error('❌ Database connection failed:', error);
    db = null;
  }
} else {
  console.warn('⚠️ Database not configured. Running in offline mode.');
}

// Database health check
export const checkDatabaseHealth = async (): Promise<boolean> => {
  if (!db || !sql) return false;
  
  try {
    await sql`SELECT 1`;
    return true;
  } catch (error) {
    console.error('Database health check failed:', error);
    return false;
  }
};

// Safe database operations
export const safeDbOperation = async <T>(
  operation: () => Promise<T>,
  fallback?: T
): Promise<T> => {
  if (!db) {
    if (fallback !== undefined) return fallback;
    throw new DatabaseError('Database not available');
  }

  try {
    return await operation();
  } catch (error) {
    console.error('Database operation failed:', error);
    if (fallback !== undefined) return fallback;
    throw new DatabaseError('Database operation failed');
  }
};

export { db };
export * from './schema';