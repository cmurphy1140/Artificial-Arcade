import { AIDifficulty } from '../types';

// TicTacToe game logic - cross-platform implementation
export type TicTacToeBoard = (string | null)[][];
export type TicTacToePlayer = 'X' | 'O';

export class TicTacToeGame {
  private board: TicTacToeBoard;
  private currentPlayer: TicTacToePlayer;
  private moveCount: number;
  private gameOver: boolean;
  private winner: TicTacToePlayer | 'draw' | null;

  constructor() {
    this.board = this.createEmptyBoard();
    this.currentPlayer = 'X';
    this.moveCount = 0;
    this.gameOver = false;
    this.winner = null;
  }

  private createEmptyBoard(): TicTacToeBoard {
    return Array(3).fill(null).map(() => Array(3).fill(null));
  }

  public getBoard(): TicTacToeBoard {
    return this.board.map(row => [...row]);
  }

  public getCurrentPlayer(): TicTacToePlayer {
    return this.currentPlayer;
  }

  public isGameOver(): boolean {
    return this.gameOver;
  }

  public getWinner(): TicTacToePlayer | 'draw' | null {
    return this.winner;
  }

  public makeMove(row: number, col: number): boolean {
    if (this.gameOver || row < 0 || row > 2 || col < 0 || col > 2) {
      return false;
    }

    if (this.board[row][col] !== null) {
      return false;
    }

    this.board[row][col] = this.currentPlayer;
    this.moveCount++;

    // Check for winner
    if (this.checkWinner(this.currentPlayer)) {
      this.gameOver = true;
      this.winner = this.currentPlayer;
    } else if (this.moveCount === 9) {
      this.gameOver = true;
      this.winner = 'draw';
    } else {
      this.currentPlayer = this.currentPlayer === 'X' ? 'O' : 'X';
    }

    return true;
  }

  private checkWinner(player: TicTacToePlayer): boolean {
    // Check rows
    for (let row = 0; row < 3; row++) {
      if (this.board[row].every(cell => cell === player)) {
        return true;
      }
    }

    // Check columns
    for (let col = 0; col < 3; col++) {
      if (this.board.every(row => row[col] === player)) {
        return true;
      }
    }

    // Check diagonals
    if (this.board[0][0] === player && 
        this.board[1][1] === player && 
        this.board[2][2] === player) {
      return true;
    }

    if (this.board[0][2] === player && 
        this.board[1][1] === player && 
        this.board[2][0] === player) {
      return true;
    }

    return false;
  }

  public getAvailableMoves(): Array<{row: number, col: number}> {
    const moves: Array<{row: number, col: number}> = [];
    for (let row = 0; row < 3; row++) {
      for (let col = 0; col < 3; col++) {
        if (this.board[row][col] === null) {
          moves.push({row, col});
        }
      }
    }
    return moves;
  }

  public reset(): void {
    this.board = this.createEmptyBoard();
    this.currentPlayer = 'X';
    this.moveCount = 0;
    this.gameOver = false;
    this.winner = null;
  }
}

// AI implementation for TicTacToe
export class TicTacToeAI {
  private difficulty: AIDifficulty;
  private aiPlayer: TicTacToePlayer;

  constructor(difficulty: AIDifficulty = AIDifficulty.Medium, aiPlayer: TicTacToePlayer = 'O') {
    this.difficulty = difficulty;
    this.aiPlayer = aiPlayer;
  }

  public getMove(game: TicTacToeGame): {row: number, col: number} | null {
    const availableMoves = game.getAvailableMoves();
    
    if (availableMoves.length === 0) {
      return null;
    }

    switch (this.difficulty) {
      case AIDifficulty.Easy:
        return this.getRandomMove(availableMoves);
      
      case AIDifficulty.Medium:
        // 70% chance of best move, 30% random
        return Math.random() < 0.7 
          ? this.getBestMove(game) 
          : this.getRandomMove(availableMoves);
      
      case AIDifficulty.Hard:
      case AIDifficulty.Expert:
        return this.getBestMove(game);
      
      default:
        return this.getRandomMove(availableMoves);
    }
  }

  private getRandomMove(moves: Array<{row: number, col: number}>): {row: number, col: number} {
    const randomIndex = Math.floor(Math.random() * moves.length);
    return moves[randomIndex];
  }

  private getBestMove(game: TicTacToeGame): {row: number, col: number} | null {
    const board = game.getBoard();
    const opponent = this.aiPlayer === 'X' ? 'O' : 'X';

    // Try to win
    const winMove = this.findWinningMove(board, this.aiPlayer);
    if (winMove) return winMove;

    // Block opponent's winning move
    const blockMove = this.findWinningMove(board, opponent);
    if (blockMove) return blockMove;

    // Take center if available
    if (board[1][1] === null) {
      return {row: 1, col: 1};
    }

    // Take corners
    const corners = [
      {row: 0, col: 0},
      {row: 0, col: 2},
      {row: 2, col: 0},
      {row: 2, col: 2}
    ];
    const availableCorners = corners.filter(corner => 
      board[corner.row][corner.col] === null
    );
    if (availableCorners.length > 0) {
      return this.getRandomMove(availableCorners);
    }

    // Take any available edge
    return this.getRandomMove(game.getAvailableMoves());
  }

  private findWinningMove(board: TicTacToeBoard, player: TicTacToePlayer): {row: number, col: number} | null {
    for (let row = 0; row < 3; row++) {
      for (let col = 0; col < 3; col++) {
        if (board[row][col] === null) {
          // Simulate move
          board[row][col] = player;
          
          // Check if this move wins
          if (this.checkWin(board, player)) {
            board[row][col] = null; // Undo simulation
            return {row, col};
          }
          
          // Undo simulation
          board[row][col] = null;
        }
      }
    }
    return null;
  }

  private checkWin(board: TicTacToeBoard, player: TicTacToePlayer): boolean {
    // Check rows
    for (let row = 0; row < 3; row++) {
      if (board[row].every(cell => cell === player)) {
        return true;
      }
    }

    // Check columns
    for (let col = 0; col < 3; col++) {
      if (board.every(row => row[col] === player)) {
        return true;
      }
    }

    // Check diagonals
    if (board[0][0] === player && board[1][1] === player && board[2][2] === player) {
      return true;
    }
    if (board[0][2] === player && board[1][1] === player && board[2][0] === player) {
      return true;
    }

    return false;
  }
}