# Artificial Arcade MCP Server

Model Context Protocol (MCP) server for the Artificial Arcade platform, providing companion interactions and memory persistence capabilities.

## Features

### Memory Management
- **Store memories** with vector embeddings for semantic search
- **Retrieve memories** using similarity search or filters
- **Consolidate memories** to manage storage efficiently
- Support for different memory types (conversation, game_state, achievement, etc.)

### Companion System  
- **Create AI companions** with unique personalities
- **Chat with companions** using context-aware responses
- **Track relationship stats** including interaction history
- Personality-driven responses with memory integration

### Game Integration
- Game session management (via playground server)
- Checkpoint save/load functionality
- State persistence across sessions

## Setup

### Prerequisites
- Node.js 18+
- PostgreSQL with pgvector extension
- OpenAI API key (optional, for embeddings and AI responses)

### Installation

1. Install dependencies:
```bash
npm install
```

2. Create `.env` file:
```bash
cp .env.example .env
```

3. Configure environment variables:
```env
DATABASE_URL=postgresql://user:password@host:5432/database
OPENAI_API_KEY=sk-your-api-key
MCP_PORT=4000
NODE_ENV=development
```

### Database Setup

Ensure your PostgreSQL database has the pgvector extension:
```sql
CREATE EXTENSION IF NOT EXISTS vector;
```

The server uses the same database schema as the main web application.

## Usage

### Start MCP Server (stdio mode)
```bash
npm start
```

### Start HTTP Server (for testing)
```bash
npm run start:http
```

### Development Mode (with auto-reload)
```bash
npm run dev
```

### Run Playground Server
```bash
npm run playground
```

## Available Tools

### Memory Tools

#### `storeMemory`
Store a memory with optional embedding generation.
- Parameters: userId, content, companionId?, gameId?, type, importance, metadata?
- Returns: memoryId, message

#### `retrieveMemories`
Retrieve relevant memories using semantic search.
- Parameters: userId, query, companionId?, gameId?, limit, includeArchived
- Returns: memories[], count

#### `consolidateMemories`
Consolidate old memories into summaries.
- Parameters: userId, olderThanDays, minMemories
- Returns: message, archivedCount

### Companion Tools

#### `createCompanion`
Create a new AI companion.
- Parameters: name, description, personality, gameId?, systemPrompt?, avatarUrl?, metadata?
- Returns: companionId, message

#### `chatWithCompanion`
Have a conversation with a companion.
- Parameters: companionId, userId, message, includeMemories, storeConversation
- Returns: response, companionName, stored

#### `getCompanionStats`
Get relationship statistics.
- Parameters: companionId, userId
- Returns: companion info, stats (totalMemories, relationshipAge, recentInteractions)

## Resources

- **companion-list**: List of all available companions
- **memory-types**: Types of memories that can be stored

## Prompts

- **companion-personality**: Generate companion personality prompts
- **memory-importance**: Evaluate memory importance scoring

## Architecture

The MCP server is designed to:
1. Provide persistent memory storage with vector embeddings
2. Enable context-aware companion interactions
3. Support game state management and checkpoints
4. Scale horizontally with database-backed storage

## Integration with Claude

This MCP server can be integrated with Claude Desktop or other MCP clients:

1. Add to Claude Desktop config:
```json
{
  "servers": {
    "artificial-arcade": {
      "command": "node",
      "args": ["/path/to/companion-memory-server.ts", "--stdio"],
      "env": {
        "DATABASE_URL": "your-database-url",
        "OPENAI_API_KEY": "your-api-key"
      }
    }
  }
}
```

2. The server will provide tools for memory management and companion interactions directly within Claude.

## Development

### Project Structure
```
mcp-server/
├── companion-memory-server.ts  # Main MCP server
├── playground-server.ts        # Game execution server
├── config.ts                   # Configuration management
├── db/
│   ├── index.ts               # Database connection
│   └── schema.ts              # Database schema
├── package.json               # Dependencies
└── .env.example              # Environment template
```

### Testing

Test the server using the HTTP mode:
```bash
npm run start:http
# Server runs on http://localhost:4000/mcp
```

Use any MCP client or SSE client to connect and test the tools.

## License

Part of the Artificial Arcade project.