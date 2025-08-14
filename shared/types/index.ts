// Shared type definitions for cross-platform compatibility

// Game types
export type GameId = 'tic-tac-toe' | 'connect-four' | 'snake' | 'hangman';

export interface Game {
  id: GameId;
  title: string;
  description: string;
  category: 'strategy' | 'puzzle' | 'arcade' | 'word';
  minPlayers: number;
  maxPlayers: number;
  aiEnabled: boolean;
}

// Player types
export interface Player {
  id: string;
  name: string;
  isAI: boolean;
  symbol?: string; // For games like TicTacToe
  color?: string;
  score?: number;
}

// Game state
export interface GameState {
  gameId: GameId;
  players: Player[];
  currentPlayerId: string;
  status: 'waiting' | 'playing' | 'paused' | 'finished';
  winner?: string;
  turn: number;
  startedAt?: Date;
  finishedAt?: Date;
}

// Move types
export interface Move {
  playerId: string;
  timestamp: Date;
  data: any; // Game-specific move data
}

// AI difficulty levels
export enum AIDifficulty {
  Easy = 'easy',
  Medium = 'medium',
  Hard = 'hard',
  Expert = 'expert'
}

// Score and achievements
export interface Score {
  playerId: string;
  gameId: GameId;
  value: number;
  timestamp: Date;
}

export interface Achievement {
  id: string;
  gameId?: GameId;
  name: string;
  description: string;
  icon?: string;
  points: number;
  rarity: 'common' | 'rare' | 'epic' | 'legendary';
}

// Game results
export interface GameResult {
  gameId: GameId;
  players: Array<{
    playerId: string;
    position: number;
    score: number;
  }>;
  duration: number; // in seconds
  moves: number;
  timestamp: Date;
}

// Companion/AI types
export interface CompanionConfig {
  id: string;
  name: string;
  personality: string;
  difficulty: AIDifficulty;
  gameSpecialties?: GameId[];
}

// WebSocket event types for multiplayer
export interface GameEvent {
  type: 'move' | 'join' | 'leave' | 'start' | 'end' | 'chat';
  gameId: string;
  playerId: string;
  data: any;
  timestamp: Date;
}