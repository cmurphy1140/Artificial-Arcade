import { AIDifficulty } from '../types';

// Cross-platform AI difficulty management
export class DifficultyManager {
  private static readonly DIFFICULTY_SETTINGS = {
    [AIDifficulty.Easy]: {
      thinkTime: 500,
      mistakeRate: 0.3,
      lookAhead: 1,
      randomness: 0.4
    },
    [AIDifficulty.Medium]: {
      thinkTime: 1000,
      mistakeRate: 0.15,
      lookAhead: 2,
      randomness: 0.2
    },
    [AIDifficulty.Hard]: {
      thinkTime: 1500,
      mistakeRate: 0.05,
      lookAhead: 3,
      randomness: 0.1
    },
    [AIDifficulty.Expert]: {
      thinkTime: 2000,
      mistakeRate: 0,
      lookAhead: 5,
      randomness: 0
    }
  };

  private currentDifficulty: AIDifficulty;

  constructor(initialDifficulty: AIDifficulty = AIDifficulty.Medium) {
    this.currentDifficulty = initialDifficulty;
  }

  public setDifficulty(difficulty: AIDifficulty): void {
    this.currentDifficulty = difficulty;
  }

  public getDifficulty(): AIDifficulty {
    return this.currentDifficulty;
  }

  public getSettings() {
    return DifficultyManager.DIFFICULTY_SETTINGS[this.currentDifficulty];
  }

  public shouldMakeMistake(): boolean {
    const settings = this.getSettings();
    return Math.random() < settings.mistakeRate;
  }

  public getThinkTime(): number {
    const settings = this.getSettings();
    // Add some variation to make it feel more natural
    const variation = Math.random() * 500 - 250;
    return Math.max(300, settings.thinkTime + variation);
  }

  public shouldUseRandomMove(): boolean {
    const settings = this.getSettings();
    return Math.random() < settings.randomness;
  }

  public getLookAheadDepth(): number {
    return this.getSettings().lookAhead;
  }

  // Adaptive difficulty based on player performance
  public adjustDifficulty(playerWinRate: number): void {
    if (playerWinRate > 0.7 && this.currentDifficulty !== AIDifficulty.Expert) {
      // Player is winning too much, increase difficulty
      this.increaseDifficulty();
    } else if (playerWinRate < 0.3 && this.currentDifficulty !== AIDifficulty.Easy) {
      // Player is losing too much, decrease difficulty
      this.decreaseDifficulty();
    }
  }

  private increaseDifficulty(): void {
    const difficulties = Object.values(AIDifficulty);
    const currentIndex = difficulties.indexOf(this.currentDifficulty);
    if (currentIndex < difficulties.length - 1) {
      this.currentDifficulty = difficulties[currentIndex + 1];
    }
  }

  private decreaseDifficulty(): void {
    const difficulties = Object.values(AIDifficulty);
    const currentIndex = difficulties.indexOf(this.currentDifficulty);
    if (currentIndex > 0) {
      this.currentDifficulty = difficulties[currentIndex - 1];
    }
  }

  // Get a human-readable description of the current difficulty
  public getDifficultyDescription(): string {
    const descriptions = {
      [AIDifficulty.Easy]: "Beginner - Makes frequent mistakes and plays casually",
      [AIDifficulty.Medium]: "Intermediate - Plays well but occasionally misses opportunities",
      [AIDifficulty.Hard]: "Advanced - Rarely makes mistakes and plays strategically",
      [AIDifficulty.Expert]: "Master - Plays perfectly with deep strategic thinking"
    };
    return descriptions[this.currentDifficulty];
  }
}