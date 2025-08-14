// Export all game logic modules
export * from './tic-tac-toe';

// Common game utilities
export interface GameMove {
  valid: boolean;
  error?: string;
}

export interface GameScore {
  player1: number;
  player2: number;
}

// Base class for all games (optional, for consistency)
export abstract class BaseGame {
  protected players: string[];
  protected currentPlayerIndex: number;
  protected gameOver: boolean;
  protected winner: string | null;

  constructor(players: string[]) {
    this.players = players;
    this.currentPlayerIndex = 0;
    this.gameOver = false;
    this.winner = null;
  }

  public getCurrentPlayer(): string {
    return this.players[this.currentPlayerIndex];
  }

  public isGameOver(): boolean {
    return this.gameOver;
  }

  public getWinner(): string | null {
    return this.winner;
  }

  protected switchPlayer(): void {
    this.currentPlayerIndex = (this.currentPlayerIndex + 1) % this.players.length;
  }

  public abstract makeMove(move: any): GameMove;
  public abstract getGameState(): any;
  public abstract reset(): void;
}