import dotenv from 'dotenv';
import { z } from 'zod';

// Load environment variables
dotenv.config();

// Environment validation schema
const envSchema = z.object({
  DATABASE_URL: z.string().optional(),
  OPENAI_API_KEY: z.string().optional(),
  MCP_PORT: z.string().default('4000'),
  NODE_ENV: z.enum(['development', 'production', 'test']).default('development'),
});

// Parse and validate environment variables
const env = envSchema.parse(process.env);

// Configuration object
export const config = {
  app: {
    name: 'Artificial Arcade MCP Server',
    version: '1.0.0',
    environment: env.NODE_ENV,
    port: env.MCP_PORT,
  },
  database: {
    url: env.DATABASE_URL,
    enabled: !!env.DATABASE_URL,
  },
  ai: {
    openaiApiKey: env.OPENAI_API_KEY,
    enabled: !!env.OPENAI_API_KEY,
  },
} as const;

export type Config = typeof config;