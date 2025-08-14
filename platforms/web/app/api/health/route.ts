import { NextResponse } from 'next/server';
import { checkDatabaseHealth } from '@/lib/db';
import { CompanionService } from '@/lib/ai/companion-service';
import { config } from '@/lib/config/env';

export async function GET() {
  const startTime = Date.now();
  
  try {
    // Check database health
    const dbHealth = await checkDatabaseHealth();
    
    // Check AI service health
    const companionService = new CompanionService();
    const aiHealth = await companionService.checkHealth();
    
    const responseTime = Date.now() - startTime;
    
    const health = {
      status: 'healthy',
      timestamp: new Date().toISOString(),
      responseTime: `${responseTime}ms`,
      version: config.app.version,
      environment: config.app.environment,
      services: {
        database: {
          status: dbHealth ? 'healthy' : 'unavailable',
          enabled: config.database.enabled,
        },
        ai: {
          status: aiHealth ? 'healthy' : 'degraded',
          enabled: config.ai.enabled,
        },
        auth: {
          status: config.auth.enabled ? 'healthy' : 'disabled',
          enabled: config.auth.enabled,
        },
        walletConnect: {
          status: config.web3.enabled ? 'healthy' : 'disabled',
          enabled: config.web3.enabled,
        },
      },
      features: {
        database: config.database.enabled,
        ai: config.ai.enabled,
        auth: config.auth.enabled,
        walletConnect: config.web3.enabled,
        radius: config.radius.enabled,
      },
    };

    const status = dbHealth && aiHealth ? 200 : 207; // 207 Multi-Status for partial availability
    
    return NextResponse.json(health, { status });
  } catch (error) {
    console.error('Health check failed:', error);
    
    return NextResponse.json({
      status: 'unhealthy',
      timestamp: new Date().toISOString(),
      error: 'Health check failed',
      responseTime: `${Date.now() - startTime}ms`,
    }, { status: 503 });
  }
}
