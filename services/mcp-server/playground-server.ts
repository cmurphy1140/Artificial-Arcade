import { FastMCP, McpError } from 'fastmcp';
import { z } from 'zod';
import vm from 'vm';
import { db, games, gameSessions, memories } from '../lib/db';
import { eq } from 'drizzle-orm';

// Initialize FastMCP server
const mcp = new FastMCP('Artificial Arcade Playground');

// Game execution context
interface GameContext {
  gameId: string;
  userId: string;
  companionId?: string;
  state: Record<string, any>;
  score: number;
  actions: string[];
}

const activeGames = new Map<string, GameContext>();

// Execute game action tool
mcp.tool(
  'executeGameAction',
  'Execute an action in the current game',
  {
    sessionId: z.string().describe('Game session ID'),
    action: z.string().describe('Action to execute'),
    parameters: z.record(z.any()).optional().describe('Action parameters'),
  },
  async ({ sessionId, action, parameters = {} }) => {
    const gameContext = activeGames.get(sessionId);
    if (!gameContext) {
      throw new McpError('INVALID_SESSION', 'Game session not found');
    }

    // Fetch game code from database
    const game = await db.select().from(games).where(eq(games.id, gameContext.gameId)).limit(1);
    if (!game.length) {
      throw new McpError('GAME_NOT_FOUND', 'Game not found');
    }

    // Create sandbox for game execution
    const sandbox = {
      state: gameContext.state,
      score: gameContext.score,
      action,
      parameters,
      console: {
        log: (msg: string) => gameContext.actions.push(msg),
      },
      Math,
      Date,
      JSON,
    };

    try {
      // Execute game logic in sandbox
      const script = new vm.Script(`
        // Game logic would be loaded from database
        // This is a simple example
        if (action === 'move') {
          state.position = parameters.direction || 'north';
          score += 10;
        } else if (action === 'collect') {
          state.inventory = state.inventory || [];
          state.inventory.push(parameters.item);
          score += parameters.value || 5;
        }
        
        ({ state, score, message: 'Action executed: ' + action })
      `);
      
      const context = vm.createContext(sandbox);
      const result = script.runInContext(context);
      
      // Update game context
      gameContext.state = result.state;
      gameContext.score = result.score;
      gameContext.actions.push(action);
      
      return {
        success: true,
        state: result.state,
        score: result.score,
        message: result.message,
      };
    } catch (error) {
      throw new McpError('EXECUTION_ERROR', `Game execution failed: ${error}`);
    }
  }
);

// Start game session tool
mcp.tool(
  'startGameSession',
  'Start a new game session',
  {
    gameId: z.string().describe('Game ID'),
    userId: z.string().describe('User ID'),
    companionId: z.string().optional().describe('AI Companion ID'),
  },
  async ({ gameId, userId, companionId }) => {
    // Create session in database
    const session = await db.insert(gameSessions).values({
      gameId,
      userId,
      companionId,
      gameState: {},
    }).returning();

    const sessionId = session[0].id;
    
    // Initialize game context
    activeGames.set(sessionId, {
      gameId,
      userId,
      companionId,
      state: {},
      score: 0,
      actions: [],
    });

    return {
      sessionId,
      message: 'Game session started',
    };
  }
);

// End game session tool
mcp.tool(
  'endGameSession',
  'End the current game session',
  {
    sessionId: z.string().describe('Game session ID'),
  },
  async ({ sessionId }) => {
    const gameContext = activeGames.get(sessionId);
    if (!gameContext) {
      throw new McpError('INVALID_SESSION', 'Game session not found');
    }

    // Update session in database
    await db.update(gameSessions)
      .set({
        endedAt: new Date(),
        score: gameContext.score,
        gameState: gameContext.state,
      })
      .where(eq(gameSessions.id, sessionId));

    // Clean up
    activeGames.delete(sessionId);

    return {
      finalScore: gameContext.score,
      actions: gameContext.actions.length,
      message: 'Game session ended',
    };
  }
);

// Get game state tool
mcp.tool(
  'getGameState',
  'Get the current game state',
  {
    sessionId: z.string().describe('Game session ID'),
  },
  async ({ sessionId }) => {
    const gameContext = activeGames.get(sessionId);
    if (!gameContext) {
      throw new McpError('INVALID_SESSION', 'Game session not found');
    }

    return {
      state: gameContext.state,
      score: gameContext.score,
      actions: gameContext.actions,
    };
  }
);

// Save game checkpoint tool
mcp.tool(
  'saveCheckpoint',
  'Save a checkpoint in the current game',
  {
    sessionId: z.string().describe('Game session ID'),
    checkpointName: z.string().describe('Name for the checkpoint'),
  },
  async ({ sessionId, checkpointName }) => {
    const gameContext = activeGames.get(sessionId);
    if (!gameContext) {
      throw new McpError('INVALID_SESSION', 'Game session not found');
    }

    // Save checkpoint as memory
    await db.insert(memories).values({
      userId: gameContext.userId,
      companionId: gameContext.companionId,
      gameId: gameContext.gameId,
      content: JSON.stringify({
        checkpointName,
        state: gameContext.state,
        score: gameContext.score,
      }),
      type: 'checkpoint',
      importance: 5,
    });

    return {
      message: `Checkpoint '${checkpointName}' saved`,
    };
  }
);

// Load game checkpoint tool
mcp.tool(
  'loadCheckpoint',
  'Load a previously saved checkpoint',
  {
    sessionId: z.string().describe('Game session ID'),
    checkpointName: z.string().describe('Name of the checkpoint to load'),
  },
  async ({ sessionId, checkpointName }) => {
    const gameContext = activeGames.get(sessionId);
    if (!gameContext) {
      throw new McpError('INVALID_SESSION', 'Game session not found');
    }

    // Find checkpoint in memories
    const checkpoint = await db.select()
      .from(memories)
      .where(eq(memories.userId, gameContext.userId))
      .where(eq(memories.gameId, gameContext.gameId))
      .where(eq(memories.type, 'checkpoint'))
      .limit(1);

    if (!checkpoint.length) {
      throw new McpError('CHECKPOINT_NOT_FOUND', 'Checkpoint not found');
    }

    const checkpointData = JSON.parse(checkpoint[0].content);
    
    // Restore game state
    gameContext.state = checkpointData.state;
    gameContext.score = checkpointData.score;

    return {
      message: `Checkpoint '${checkpointName}' loaded`,
      state: checkpointData.state,
      score: checkpointData.score,
    };
  }
);

// Resources
mcp.resource(
  'game-library',
  'Available games in the arcade',
  async () => {
    const availableGames = await db.select({
      id: games.id,
      title: games.title,
      description: games.description,
      category: games.category,
      tokenGated: games.tokenGated,
    }).from(games).where(eq(games.isPublished, true));

    return JSON.stringify(availableGames, null, 2);
  }
);

mcp.resource(
  'active-sessions',
  'Currently active game sessions',
  async () => {
    const sessions = Array.from(activeGames.entries()).map(([id, context]) => ({
      sessionId: id,
      gameId: context.gameId,
      userId: context.userId,
      score: context.score,
      actionsCount: context.actions.length,
    }));

    return JSON.stringify(sessions, null, 2);
  }
);

// Prompts
mcp.prompt(
  'game-assistant',
  'Act as a helpful game assistant for the player',
  async ({ gameId, difficulty = 'medium' }) => {
    return `You are an AI game assistant for Artificial Arcade. Help the player with:
    
1. Understanding game mechanics
2. Providing hints when stuck (adjust based on difficulty: ${difficulty})
3. Celebrating achievements
4. Suggesting strategies
5. Remembering their play style

Be encouraging and adaptive to their skill level. Game ID: ${gameId}`;
  }
);

mcp.prompt(
  'game-narrator',
  'Narrate the game story and events',
  async ({ genre = 'adventure' }) => {
    return `You are a dynamic game narrator for ${genre} games. Your role:
    
1. Create immersive descriptions of game environments
2. Narrate player actions with flair
3. Build tension and excitement
4. Adapt tone to match game genre
5. Make the experience memorable

Keep narration concise but impactful.`;
  }
);

// Start the server
const PORT = process.env.MCP_PORT || 4000;
mcp.serve({
  transport: 'stdio',
}).then(() => {
  console.error(`Playground MCP Server running on stdio`);
});