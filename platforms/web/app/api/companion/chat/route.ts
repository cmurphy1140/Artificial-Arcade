import { NextRequest, NextResponse } from 'next/server';
import { getServerSession } from 'next-auth';
import { authOptions } from '@/lib/auth/auth-options';
import { CompanionService } from '@/lib/ai/companion-service';
import { handleApiError, validateRequired, ValidationError } from '@/lib/utils/error-handler';
import { config } from '@/lib/config/env';

export async function POST(request: NextRequest) {
  try {
    const session = await getServerSession(authOptions);
    
    // Allow anonymous access if auth is not configured
    const userId = session?.user?.email || 'anonymous';
    if (config.auth.enabled && !session?.user) {
      return NextResponse.json({ error: 'Authentication required' }, { status: 401 });
    }

    const body = await request.json();
    const { companionId, message } = body;

    // Validate required fields
    validateRequired(body, ['companionId', 'message']);

    // Additional validation
    if (typeof message !== 'string' || message.trim().length === 0) {
      throw new ValidationError('Message must be a non-empty string');
    }

    if (typeof companionId !== 'string' || companionId.trim().length === 0) {
      throw new ValidationError('Companion ID must be a non-empty string');
    }

    const companionService = new CompanionService();
    const response = await companionService.generateResponse({
      companionId: companionId.trim(),
      userId: userId,
      message: message.trim(),
    });

    return NextResponse.json({ 
      response,
      timestamp: new Date().toISOString(),
      companionId: companionId.trim(),
    });
  } catch (error) {
    return handleApiError(error);
  }
}