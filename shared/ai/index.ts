// Export AI utilities
export * from './difficulty-manager';

// Common AI utilities for all games
export interface AIDecision {
  move: any;
  confidence: number;
  reasoning?: string;
}

export interface AIPersonality {
  aggressiveness: number; // 0-1, how likely to take risky moves
  defensiveness: number; // 0-1, how likely to block opponent
  patience: number; // 0-1, how likely to wait for better opportunities
  unpredictability: number; // 0-1, how likely to make unexpected moves
}

// Personality presets for different AI companions
export const AI_PERSONALITIES = {
  aggressive: {
    aggressiveness: 0.9,
    defensiveness: 0.3,
    patience: 0.2,
    unpredictability: 0.4
  },
  defensive: {
    aggressiveness: 0.3,
    defensiveness: 0.9,
    patience: 0.7,
    unpredictability: 0.2
  },
  balanced: {
    aggressiveness: 0.5,
    defensiveness: 0.5,
    patience: 0.5,
    unpredictability: 0.3
  },
  chaotic: {
    aggressiveness: 0.7,
    defensiveness: 0.3,
    patience: 0.1,
    unpredictability: 0.9
  },
  strategic: {
    aggressiveness: 0.6,
    defensiveness: 0.6,
    patience: 0.8,
    unpredictability: 0.1
  }
};

// Utility functions for AI decision making
export class AIUtils {
  // Minimax algorithm for perfect play (used in games like TicTacToe, ConnectFour)
  static minimax(
    gameState: any,
    depth: number,
    isMaximizing: boolean,
    evaluateFunction: (state: any) => number,
    getMovesFunction: (state: any) => any[],
    makeMoveFunction: (state: any, move: any) => any
  ): { score: number; move: any } {
    if (depth === 0 || getMovesFunction(gameState).length === 0) {
      return { score: evaluateFunction(gameState), move: null };
    }

    const moves = getMovesFunction(gameState);
    let bestMove = moves[0];
    let bestScore = isMaximizing ? -Infinity : Infinity;

    for (const move of moves) {
      const newState = makeMoveFunction(gameState, move);
      const result = this.minimax(
        newState,
        depth - 1,
        !isMaximizing,
        evaluateFunction,
        getMovesFunction,
        makeMoveFunction
      );

      if (isMaximizing && result.score > bestScore) {
        bestScore = result.score;
        bestMove = move;
      } else if (!isMaximizing && result.score < bestScore) {
        bestScore = result.score;
        bestMove = move;
      }
    }

    return { score: bestScore, move: bestMove };
  }

  // Add randomness to AI decisions based on personality
  static applyPersonality(
    moves: any[],
    scores: number[],
    personality: AIPersonality
  ): any {
    if (moves.length === 0) return null;
    
    // Apply unpredictability
    if (Math.random() < personality.unpredictability) {
      // Sometimes make a random move
      return moves[Math.floor(Math.random() * moves.length)];
    }

    // Weight moves based on personality traits
    const weightedScores = scores.map((score, index) => {
      let weight = score;
      
      // Adjust weights based on personality
      // (This would need game-specific implementation)
      
      return weight;
    });

    // Select move based on weighted scores
    const maxScore = Math.max(...weightedScores);
    const bestMoves = moves.filter((_, i) => weightedScores[i] === maxScore);
    
    return bestMoves[Math.floor(Math.random() * bestMoves.length)];
  }

  // Simulate thinking time for more natural gameplay
  static async simulateThinking(milliseconds: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, milliseconds));
  }

  // Calculate win probability for adaptive difficulty
  static calculateWinProbability(
    wins: number,
    losses: number,
    draws: number
  ): number {
    const total = wins + losses + draws;
    if (total === 0) return 0.5;
    return wins / total;
  }
}