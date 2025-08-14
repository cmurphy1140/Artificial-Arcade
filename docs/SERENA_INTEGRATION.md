# Serena MCP Integration Guide for Artificial Arcade

## Overview
Serena MCP (Model Context Protocol) server is now integrated with the Artificial Arcade project, providing semantic code understanding and intelligent editing capabilities through VS Code and other MCP-compatible clients.

## How Serena Works

### 1. Semantic Code Understanding
Unlike traditional text-based search tools, Serena uses Language Server Protocol (LSP) to understand your code semantically:

- **Symbol Recognition**: Understands classes, functions, methods, and their relationships
- **Type-Aware**: Knows TypeScript/JavaScript types and can navigate type hierarchies
- **Cross-File Understanding**: Tracks imports, exports, and dependencies across your entire codebase

### 2. Architecture Awareness
Serena has been configured to understand your project's specific architecture:

```
Artificial Arcade/
├── platforms/web/          # Next.js 15 web application
├── platforms/ios/          # Swift iOS application  
├── services/mcp-server/    # Your custom MCP server for companions
└── shared/                 # Cross-platform shared modules
```

### 3. Intelligent Navigation Tools

#### Symbol-Based Navigation
- `get_symbols_overview`: Lists all top-level symbols in a file
- `find_symbol`: Locates specific symbols by name path
- `find_referencing_symbols`: Finds all places where a symbol is used

Example: Finding all references to your CompanionChat component:
```
find_symbol("CompanionChat")
find_referencing_symbols("CompanionChat", "components/companion/companion-chat.tsx")
```

#### Pattern-Based Search
- `search_for_pattern`: Fast regex-based search across the codebase
- `find_file`: Locates files by name patterns

### 4. Code Editing Capabilities

#### Symbol-Based Editing
- `replace_symbol_body`: Replaces entire functions/classes
- `insert_after_symbol`: Adds code after a symbol
- `insert_before_symbol`: Adds code before a symbol (useful for imports)

#### Regex-Based Editing
- `replace_regex`: Precise line-by-line edits within functions
- Preserves formatting and indentation
- Intelligent wildcard usage for larger replacements

### 5. Memory System
Serena maintains persistent knowledge about your codebase:

- **Project Memories**: Architecture decisions, patterns, conventions
- **Component Memories**: How specific components work
- **Integration Memories**: How different parts connect

Access with:
- `write_memory`: Store new knowledge
- `read_memory`: Retrieve stored knowledge
- `list_memories`: See all available memories

## Integration with Your Existing MCP Server

Your project already has an MCP server at `services/mcp-server/companion-memory-server.ts`. Here's how they work together:

### 1. Complementary Roles
- **Your MCP Server**: Handles companion AI, memory persistence, game logic
- **Serena MCP Server**: Provides code intelligence and editing capabilities

### 2. Parallel Operation
Both servers can run simultaneously:
```bash
# Your companion server
cd services/mcp-server && npm start

# Serena server (already running)
uvx --from git+https://github.com/oraios/serena serena start-mcp-server
```

### 3. VS Code Integration
VS Code can connect to multiple MCP servers:
- Your server provides domain-specific tools
- Serena provides code intelligence tools

## Practical Use Cases for Your Project

### 1. Adding New Game Components
Serena can:
- Find similar game components for reference
- Insert new components following existing patterns
- Update imports and exports automatically

### 2. Refactoring Companion System
- Track all uses of companion-related functions
- Update API calls across the codebase
- Maintain type safety during changes

### 3. Cross-Platform Code Sharing
- Identify duplicated logic between platforms
- Extract shared code to the `shared/` directory
- Update imports in both web and iOS platforms

### 4. Database Schema Updates
- Find all references to database tables
- Update queries when schema changes
- Ensure type consistency with Drizzle ORM

## VS Code Commands

After installing the MCP extension in VS Code:

1. **View Servers**: `Cmd+Shift+P` → "MCP: Show Installed Servers"
2. **Start Serena**: Click on "Serena MCP Server" to connect
3. **Use in Chat**: Serena's tools are available in Copilot Chat

## Dashboard Access

Monitor Serena's operations at: http://127.0.0.1:24282/dashboard/index.html

Features:
- Real-time logs
- Tool usage statistics
- Active project information
- Memory management

## Best Practices

### 1. Efficient Code Reading
- Use symbol overview first, then read specific bodies
- Avoid reading entire files when only parts are needed
- Leverage the memory system for frequently accessed info

### 2. Safe Editing
- Serena tracks references before making breaking changes
- Uses backward-compatible edits when possible
- Validates changes through the language server

### 3. Project Organization
- Keep the `.serena/project.yml` updated with project changes
- Store architectural decisions in memories
- Use consistent naming for better symbol recognition

## Troubleshooting

### Server Not Starting
```bash
# Check if port is in use
lsof -i :24282

# Kill existing instance
pkill -f "serena start-mcp-server"

# Restart
uvx --from git+https://github.com/oraios/serena serena start-mcp-server
```

### Configuration Issues
- Check `~/.serena/serena_config.yml` for global settings
- Verify `.serena/project.yml` in project root
- Ensure TypeScript language server is installed

### VS Code Connection
1. Restart VS Code after configuration changes
2. Check MCP extension logs: View → Output → MCP
3. Verify server is running at http://127.0.0.1:24282/dashboard/

## Summary

Serena MCP enhances your development workflow by providing:
- **Semantic understanding** of your TypeScript/JavaScript code
- **Intelligent navigation** across your multi-platform architecture
- **Safe, precise editing** with reference tracking
- **Persistent memory** of your codebase knowledge
- **Integration** with your existing MCP companion server

The combination of your domain-specific MCP server and Serena's code intelligence creates a powerful development environment tailored to the Artificial Arcade project.