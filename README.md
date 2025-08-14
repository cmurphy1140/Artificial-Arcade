# 🎮 Artificial Arcade

A multi-platform arcade game collection featuring AI-powered opponents and cross-platform gameplay.

## 🏗️ Project Structure

```
Artificial Arcade/
├── platforms/                    # Platform-specific implementations
│   ├── ios/                     # iOS/macOS native app (Swift/SpriteKit)
│   │   ├── ArtificialArcade.xcodeproj/
│   │   └── ArtificialArcade/
│   │       ├── App/             # App lifecycle (AppDelegate, GameViewController)
│   │       ├── Scenes/          # Game scenes (SpriteKit)
│   │       ├── Managers/        # Singletons & managers
│   │       ├── Views/           # UI components
│   │       ├── Resources/       # Assets, SKS files, localizations
│   │       └── Utilities/       # Helper classes
│   │
│   └── web/                     # Next.js web app (React/TypeScript)
│       ├── app/                 # App router pages
│       ├── components/          # React components
│       ├── lib/                 # Utilities & integrations
│       └── public/              # Static assets
│
├── shared/                      # Cross-platform shared logic
│   ├── ai/                     # AI implementations
│   ├── game-logic/             # Core game algorithms
│   └── types/                  # Shared type definitions
│
├── services/                    # Backend services
│   └── mcp-server/             # Model Context Protocol server
│
└── docs/                       # Documentation
    ├── README.md               # This file
    ├── CLAUDE.md               # AI assistant guidelines
    └── ORGANIZATION_PLAN.md    # Restructure documentation
```

## 🚀 Getting Started

### Prerequisites

- **iOS Development**: Xcode 15+ (for iOS/macOS)
- **Web Development**: Node.js 18+ and npm
- **AI Features**: OpenAI API key

### Development Setup

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd artificial-arcade
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Web Development**
   ```bash
   npm run dev:web
   ```

4. **iOS Development**
   - Open `platforms/ios/ArtificialArcade.xcodeproj` in Xcode
   - Build and run

5. **MCP Server Development**
   ```bash
   npm run dev:mcp
   ```

## 🎯 Games Available

- **Tic-Tac-Toe**: Classic 3x3 grid game with AI opponent
- **Connect Four**: Connect 4 pieces in a row with strategic AI
- **Snake**: Classic snake game with AI-powered difficulty scaling
- **Hangman**: Word guessing game with AI-generated hints

## 🤖 AI Features

- Adaptive difficulty adjustment
- Smart opponent strategies
- Real-time game analytics
- Player behavior learning

## 🛠️ Development Commands

| Command | Description |
|---------|-------------|
| `npm run dev:web` | Start Next.js development server |
| `npm run build:web` | Build web app for production |
| `npm run dev:mcp` | Start MCP server in development |
| `npm run lint` | Run linting checks |
| `npm run type-check` | TypeScript type checking |

## 📱 Platform Features

### iOS/macOS Native
- SpriteKit-powered graphics
- Native performance
- iOS-specific UI patterns
- GameCenter integration

### Web Application
- Cross-platform compatibility
- Progressive Web App (PWA)
- Real-time multiplayer (planned)
- Web3 integration (planned)

## 🔧 Technology Stack

### iOS/macOS
- **Language**: Swift
- **Framework**: SpriteKit
- **Architecture**: MVC/MVVM

### Web
- **Framework**: Next.js 14+ (App Router)
- **Language**: TypeScript
- **Styling**: Tailwind CSS
- **Database**: Drizzle ORM
- **AI**: OpenAI API

### Backend
- **Server**: Model Context Protocol (MCP)
- **Runtime**: Node.js/TypeScript

## 📄 License

[Add your license information here]

## 🤝 Contributing

[Add contribution guidelines here]

## 📞 Support

[Add support/contact information here]
