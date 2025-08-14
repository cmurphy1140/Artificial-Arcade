import { NextRequest, NextResponse } from 'next/server';
import { z } from 'zod';
import { CompanionService } from '@/lib/ai/companion-service';
import { AppError } from '@/lib/utils/error-handler';

const companionService = new CompanionService();

// Schema for memory operations
const MemoryRequestSchema = z.object({
  action: z.enum(['store', 'retrieve', 'history', 'decay']),
  userId: z.string().uuid(),
  companionId: z.string().uuid().optional(),
  gameId: z.string().uuid().optional(),
  conversationId: z.string().uuid().optional(),
  parentMemoryId: z.string().uuid().optional(),
  content: z.string().optional(),
  query: z.string().optional(),
  type: z.string().default('conversation'),
  importance: z.number().min(0).max(10).default(5),
  limit: z.number().min(1).max(100).default(10),
});

export async function POST(request: NextRequest) {
  try {
    const body = await request.json();
    const validated = MemoryRequestSchema.parse(body);

    switch (validated.action) {
      case 'store': {
        if (!validated.content) {
          throw new AppError('Content is required for storing memory', 400);
        }

        const memory = await companionService.storeMemory({
          userId: validated.userId,
          companionId: validated.companionId,
          gameId: validated.gameId,
          content: validated.content,
          type: validated.type,
          importance: validated.importance,
          conversationId: validated.conversationId,
          parentMemoryId: validated.parentMemoryId,
        });

        return NextResponse.json({
          success: true,
          memory,
        });
      }

      case 'retrieve': {
        if (!validated.query) {
          throw new AppError('Query is required for retrieving memories', 400);
        }

        const memories = await companionService.retrieveMemories({
          userId: validated.userId,
          companionId: validated.companionId,
          query: validated.query,
          limit: validated.limit,
        });

        return NextResponse.json({
          success: true,
          memories,
          count: memories.length,
        });
      }

      case 'history': {
        const history = await companionService.getConversationHistory({
          userId: validated.userId,
          companionId: validated.companionId,
          conversationId: validated.conversationId,
          limit: validated.limit,
        });

        return NextResponse.json({
          success: true,
          history,
          count: history.length,
        });
      }

      case 'decay': {
        // This would typically be called by a scheduled job
        // For now, return a placeholder response
        return NextResponse.json({
          success: true,
          message: 'Memory decay operation queued',
        });
      }

      default:
        throw new AppError('Invalid action', 400);
    }
  } catch (error) {
    console.error('Memory API error:', error);
    
    if (error instanceof z.ZodError) {
      return NextResponse.json(
        {
          success: false,
          error: 'Invalid request data',
          details: error.errors,
        },
        { status: 400 }
      );
    }

    if (error instanceof AppError) {
      return NextResponse.json(
        {
          success: false,
          error: error.message,
        },
        { status: error.statusCode }
      );
    }

    return NextResponse.json(
      {
        success: false,
        error: 'Internal server error',
      },
      { status: 500 }
    );
  }
}

export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url);
    const userId = searchParams.get('userId');
    const companionId = searchParams.get('companionId');
    const conversationId = searchParams.get('conversationId');
    const limit = parseInt(searchParams.get('limit') || '20');

    if (!userId) {
      throw new AppError('User ID is required', 400);
    }

    const history = await companionService.getConversationHistory({
      userId,
      companionId: companionId || undefined,
      conversationId: conversationId || undefined,
      limit,
    });

    return NextResponse.json({
      success: true,
      history,
      count: history.length,
    });
  } catch (error) {
    console.error('Memory GET API error:', error);
    
    if (error instanceof AppError) {
      return NextResponse.json(
        {
          success: false,
          error: error.message,
        },
        { status: error.statusCode }
      );
    }

    return NextResponse.json(
      {
        success: false,
        error: 'Internal server error',
      },
      { status: 500 }
    );
  }
}