import { z } from 'zod';

// Environment validation schema
const envSchema = z.object({
  // Database
  DATABASE_URL: z.string().optional(),
  
  // Auth
  NEXTAUTH_URL: z.string().url().default('http://localhost:3000'),
  NEXTAUTH_SECRET: z.string().optional(),
  
  // OpenAI
  OPENAI_API_KEY: z.string().optional(),
  
  // WalletConnect
  NEXT_PUBLIC_WALLET_CONNECT_PROJECT_ID: z.string().optional(),
  
  // Radius SDK
  RADIUS_API_KEY: z.string().optional(),
  
  // Node environment
  NODE_ENV: z.enum(['development', 'production', 'test']).default('development'),
});

// Parse and validate environment variables
const parseEnv = () => {
  try {
    return envSchema.parse(process.env);
  } catch (error) {
    if (error instanceof z.ZodError) {
      const missingVars = error.errors.map(err => err.path.join('.'));
      console.warn(`Environment validation warnings: ${missingVars.join(', ')}`);
    }
    
    // Return safe defaults for missing variables
    return {
      DATABASE_URL: process.env.DATABASE_URL,
      NEXTAUTH_URL: process.env.NEXTAUTH_URL || 'http://localhost:3000',
      NEXTAUTH_SECRET: process.env.NEXTAUTH_SECRET,
      OPENAI_API_KEY: process.env.OPENAI_API_KEY,
      NEXT_PUBLIC_WALLET_CONNECT_PROJECT_ID: process.env.NEXT_PUBLIC_WALLET_CONNECT_PROJECT_ID,
      RADIUS_API_KEY: process.env.RADIUS_API_KEY,
      NODE_ENV: (process.env.NODE_ENV as 'development' | 'production' | 'test') || 'development',
    };
  }
};

export const env = parseEnv();

// Feature flags based on environment availability
export const features = {
  database: !!env.DATABASE_URL,
  ai: !!env.OPENAI_API_KEY,
  auth: !!env.NEXTAUTH_SECRET,
  walletConnect: !!env.NEXT_PUBLIC_WALLET_CONNECT_PROJECT_ID,
  radius: !!env.RADIUS_API_KEY,
} as const;

// Configuration object
export const config = {
  app: {
    name: 'Artificial Arcade',
    version: '1.0.0',
    environment: env.NODE_ENV,
  },
  database: {
    url: env.DATABASE_URL,
    enabled: features.database,
  },
  auth: {
    url: env.NEXTAUTH_URL,
    secret: env.NEXTAUTH_SECRET,
    enabled: features.auth,
  },
  ai: {
    openaiApiKey: env.OPENAI_API_KEY,
    enabled: features.ai,
    fallbackMessages: [
      "I'm currently learning and will be able to chat soon!",
      "The AI companion is warming up. Please try again in a moment.",
      "I'm practicing my gaming skills and will be ready to chat shortly!",
    ],
  },
  web3: {
    walletConnectProjectId: env.NEXT_PUBLIC_WALLET_CONNECT_PROJECT_ID,
    enabled: features.walletConnect,
  },
  radius: {
    apiKey: env.RADIUS_API_KEY,
    enabled: features.radius,
  },
} as const;

export type Config = typeof config;
export type Features = typeof features;
