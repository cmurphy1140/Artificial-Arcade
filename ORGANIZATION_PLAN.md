# Artificial Arcade - Codebase Organization Plan

## Current Structure Issues

1. Mixed platform code at root level (iOS/macOS Swift files mixed with Next.js)
2. Unclear separation between web and native implementations
3. Duplicate game logic potentially exists across platforms

## Proposed Structure

```text
Artificial Arcade/
├── platforms/                    # Platform-specific implementations
│   ├── ios/                     # iOS/macOS native app
│   │   ├── ArtificialArcade.xcodeproj/
│   │   └── ArtificialArcade/
│   │       ├── App/             # App lifecycle
│   │       ├── Scenes/          # Game scenes
│   │       ├── Managers/        # Singletons & managers
│   │       ├── Views/           # UI components
│   │       ├── Models/          # Data models
│   │       ├── Resources/       # Assets, SKS files
│   │       └── Utilities/       # Helper classes
│   │
│   └── web/                     # Next.js web app
│       ├── app/                 # App router pages
│       ├── components/          # React components
│       ├── lib/                 # Utilities & integrations
│       ├── public/              # Static assets
│       └── [config files]       # next.config.ts, etc.
│
├── shared/                      # Cross-platform shared logic
│   ├── game-logic/             # Core game algorithms
│   ├── ai/                     # AI implementations
│   └── types/                  # Shared type definitions
│
├── services/                    # Backend services
│   └── mcp-server/             # Model Context Protocol server
│
├── docs/                       # Documentation
│   ├── CLAUDE.md
│   ├── README.md
│   └── architecture/
│
└── [root config files]         # .gitignore, package.json (workspace)
```

## Benefits

1. Clear separation of concerns
2. Easier to maintain platform-specific code
3. Shared logic can be reused across platforms
4. Better scalability for adding new platforms
5. Cleaner root directory
