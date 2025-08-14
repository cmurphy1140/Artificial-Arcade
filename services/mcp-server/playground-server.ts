import { FastMCP, McpError } from 'fastmcp';
import { z } from 'zod';
import vm from 'vm';
import { db, games, gameSessions, memories } from './db';
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
mcp.addTool({
  name: 'executeGameAction',
  description: 'Execute an action in the current game',
  parameters: z.object({
    sessionId: z.string().describe('Game session ID'),
    action: z.string().describe('Action to execute'),
    parameters: z.record(z.any()).optional().describe('Action parameters'),
  }),
  execute: async function({ sessionId, action, parameters = {} }) {
    const gameContext = activeGames.get(sessionId);
    if (!gameContext) {
      throw new McpError('INVALID_SESSION', 'Game session not found');
    }

    if (!db) {
      throw new McpError('DATABASE_ERROR', 'Database not available');
    }

    // Fetch game code from database
    const game = await db.select().from(games).where(eq(games.id, gameContext.gameId)).limit(1);
    if (!game.length) {
      throw new McpError('GAME_NOT_FOUND', 'Game not found');
    }

    // Get game logic from metadata or playUrl
    const gameData = game[0];
    let gameLogic: string;
    
    // Check if game has embedded logic in metadata
    if (gameData.metadata && typeof gameData.metadata === 'object' && 'gameLogic' in gameData.metadata) {
      gameLogic = (gameData.metadata as any).gameLogic;
    } else {
      // Default game engine for games without custom logic
      // This provides a basic game framework that games can extend
      gameLogic = `
        // Default game engine
        const gameState = state || {};
        let gameScore = score || 0;
        
        // Process action based on game type
        switch(action) {
          case 'move':
            gameState.position = parameters.direction || gameState.position || 'start';
            gameState.moves = (gameState.moves || 0) + 1;
            break;
          case 'interact':
            gameState.lastInteraction = parameters.target;
            gameScore += parameters.points || 1;
            break;
          case 'collect':
            gameState.inventory = gameState.inventory || [];
            gameState.inventory.push(parameters.item);
            gameScore += parameters.value || 5;
            break;
          case 'use':
            if (gameState.inventory && gameState.inventory.includes(parameters.item)) {
              gameState.inventory = gameState.inventory.filter(i => i !== parameters.item);
              gameState.used = gameState.used || [];
              gameState.used.push(parameters.item);
              gameScore += 10;
            }
            break;
          default:
            // Allow custom actions to be stored
            gameState.lastAction = action;
            gameState.customActions = gameState.customActions || [];
            gameState.customActions.push({ action, parameters, timestamp: Date.now() });
        }
        
        // Return updated state
        ({ state: gameState, score: gameScore, message: 'Action: ' + action + ' processed' })
      `;
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
      const script = new vm.Script(gameLogic);
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
});

// Start game session tool
mcp.addTool({
  name: 'startGameSession',
  description: 'Start a new game session',
  parameters: z.object({
    gameId: z.string().describe('Game ID'),
    userId: z.string().describe('User ID'),
    companionId: z.string().optional().describe('AI Companion ID'),
  }),
  execute: async function({ gameId, userId, companionId }) {
    if (!db) {
      throw new McpError('DATABASE_ERROR', 'Database not available');
    }

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
});

// End game session tool
mcp.addTool({
  name: 'endGameSession',
  description: 'End the current game session',
  parameters: z.object({
    sessionId: z.string().describe('Game session ID'),
  }),
  execute: async function({ sessionId }) {
    const gameContext = activeGames.get(sessionId);
    if (!gameContext) {
      throw new McpError('INVALID_SESSION', 'Game session not found');
    }

    if (!db) {
      throw new McpError('DATABASE_ERROR', 'Database not available');
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
});

// Get game state tool
mcp.addTool({
  name: 'getGameState',
  description: 'Get the current game state',
  parameters: z.object({
    sessionId: z.string().describe('Game session ID'),
  }),
  execute: async function({ sessionId }) {
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
});

// Save game checkpoint tool
mcp.addTool({
  name: 'saveCheckpoint',
  description: 'Save a checkpoint in the current game',
  parameters: z.object({
    sessionId: z.string().describe('Game session ID'),
    checkpointName: z.string().describe('Name for the checkpoint'),
  }),
  execute: async function({ sessionId, checkpointName }) {
    const gameContext = activeGames.get(sessionId);
    if (!gameContext) {
      throw new McpError('INVALID_SESSION', 'Game session not found');
    }

    if (!db) {
      throw new McpError('DATABASE_ERROR', 'Database not available');
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
});

// Load game checkpoint tool
mcp.addTool({
  name: 'loadCheckpoint',
  description: 'Load a previously saved checkpoint',
  parameters: z.object({
    sessionId: z.string().describe('Game session ID'),
    checkpointName: z.string().describe('Name of the checkpoint to load'),
  }),
  execute: async function({ sessionId, checkpointName }) {
    const gameContext = activeGames.get(sessionId);
    if (!gameContext) {
      throw new McpError('INVALID_SESSION', 'Game session not found');
    }

    if (!db) {
      throw new McpError('DATABASE_ERROR', 'Database not available');
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
});

// Resources
mcp.addResource({
  name: 'game-library',
  description: 'Available games in the arcade',
  uri: 'game-library',
  mimeType: 'application/json',
  read: async function() {
    if (!db) {
      return JSON.stringify({ error: 'Database not available' }, null, 2);
    }

    const availableGames = await db.select({
      id: games.id,
      title: games.title,
      description: games.description,
      category: games.category,
      tokenGated: games.tokenGated,
    }).from(games).where(eq(games.isPublished, true));

    return JSON.stringify(availableGames, null, 2);
  }
});

mcp.addResource({
  name: 'active-sessions',
  description: 'Currently active game sessions',
  uri: 'active-sessions',
  mimeType: 'application/json',
  read: async function() {
    const sessions = Array.from(activeGames.entries()).map(([id, context]) => ({
      sessionId: id,
      gameId: context.gameId,
      userId: context.userId,
      score: context.score,
      actionsCount: context.actions.length,
    }));

    return JSON.stringify(sessions, null, 2);
  }
});

// Prompts
mcp.addPrompt({
  name: 'game-assistant',
  description: 'Act as a helpful game assistant for the player',
  arguments: [
    { name: 'gameId', description: 'Game ID' },
    { name: 'difficulty', description: 'Difficulty level', default: 'medium' }
  ],
  resolve: async function({ gameId, difficulty = 'medium' }) {
    return `You are an AI game assistant for Artificial Arcade. Help the player with:
    
1. Understanding game mechanics
2. Providing hints when stuck (adjust based on difficulty: ${difficulty})
3. Celebrating achievements
4. Suggesting strategies
5. Remembering their play style

Be encouraging and adaptive to their skill level. Game ID: ${gameId}`;
  }
});

mcp.addPrompt({
  name: 'game-narrator',
  description: 'Narrate the game story and events',
  arguments: [
    { name: 'genre', description: 'Game genre', default: 'adventure' }
  ],
  resolve: async function({ genre = 'adventure' }) {
    return `You are a dynamic game narrator for ${genre} games. Your role:
    
1. Create immersive descriptions of game environments
2. Narrate player actions with flair
3. Build tension and excitement
4. Adapt tone to match game genre
5. Make the experience memorable

Keep narration concise but impactful.`;
  }
});

// Start the server
const PORT = process.env.MCP_PORT || 4000;
mcp.serve({
  transport: 'stdio',
}).then(() => {
  console.error(`Playground MCP Server running on stdio`);
});