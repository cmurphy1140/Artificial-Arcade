# Shared Code Library

This directory contains cross-platform code that can be used by both the iOS and web platforms.

## Structure

### `/types`
- Shared TypeScript type definitions
- Game interfaces and enums
- Player, score, and achievement types
- Used by both platforms for consistency

### `/game-logic`
- Platform-agnostic game logic implementations
- Core game rules and mechanics
- AI opponent logic for each game
- Can be compiled to JavaScript for web or used as reference for Swift implementation

### `/ai`
- AI difficulty management
- Personality systems for AI opponents
- Common AI algorithms (minimax, etc.)
- Utilities for natural AI behavior

## Usage

### Web Platform (TypeScript/JavaScript)
```typescript
import { TicTacToeGame, TicTacToeAI } from '@/shared/game-logic';
import { AIDifficulty } from '@/shared/types';
import { DifficultyManager } from '@/shared/ai';
```

### iOS Platform (Swift)
The TypeScript code serves as a reference implementation. The Swift code in the iOS platform implements equivalent logic with platform-specific optimizations.

## Adding New Games

1. Create game logic in `/game-logic/[game-name].ts`
2. Add types to `/types/index.ts`
3. Export from `/game-logic/index.ts`
4. Implement platform-specific UI in respective platform directories

## Benefits

- **Consistency**: Same game rules across all platforms
- **Maintainability**: Single source of truth for game logic
- **Testing**: Can unit test game logic independently
- **Documentation**: Self-documenting code structure