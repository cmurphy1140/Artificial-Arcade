import { NextRequest, NextResponse } from 'next/server';
import { getServerSession } from 'next-auth';
import { authOptions } from '@/lib/auth/auth-options';
import { CompanionService } from '@/lib/ai/companion-service-simple';

export async function POST(request: NextRequest) {
  try {
    const session = await getServerSession(authOptions);
    
    if (!session?.user) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }

    const { companionId, message } = await request.json();

    if (!companionId || !message) {
      return NextResponse.json(
        { error: 'Missing required fields' },
        { status: 400 }
      );
    }

    const companionService = new CompanionService();
    const response = await companionService.generateResponse({
      companionId,
      userId: session.user.email || 'anonymous',
      message,
    });

    return NextResponse.json({ response });
  } catch (error) {
    console.error('Companion chat error:', error);
    return NextResponse.json(
      { error: 'Failed to generate response' },
      { status: 500 }
    );
  }
}