# Artificial Arcade - AI-Powered Gaming Platform

An innovative gaming platform that combines AI companions, Web3 authentication, and intelligent memory persistence to create unique, evolving gaming experiences.

## Features

- **AI Companions**: Intelligent game companions with persistent memory using pgvector
- **Web3 Authentication**: Secure wallet-based authentication with RainbowKit
- **Game Playground**: MCP server for game execution and state management
- **Memory Persistence**: Vector-based memory storage and retrieval for personalized experiences
- **Token-Gated Content**: Premium features accessible with Web3 tokens
- **Social Features**: Achievements, leaderboards, and community interaction

## Tech Stack

- **Frontend**: Next.js 15, TypeScript, Tailwind CSS
- **Database**: PostgreSQL with Drizzle ORM and pgvector
- **Authentication**: NextAuth with SIWE (Sign-In with Ethereum)
- **Web3**: RainbowKit, Wagmi, Viem
- **AI**: OpenAI API for embeddings and companion responses
- **MCP**: Model Context Protocol for game execution

## Prerequisites

- Node.js 20+
- PostgreSQL with pgvector extension
- OpenAI API key
- WalletConnect Project ID

## Setup Instructions

1. **Clone the repository**
```bash
git clone <repository-url>
cd "Artificial Arcade"
```

2. **Install dependencies**
```bash
npm install
```

3. **Configure environment variables**

Copy `.env.local` and fill in your actual values:
```bash
# Database (PostgreSQL with pgvector)
DATABASE_URL=postgresql://user:password@localhost:5432/artificial_arcade

# Generate secure secret: openssl rand -base64 32
NEXTAUTH_SECRET=your-generated-secret

# Get from: https://platform.openai.com/api-keys
OPENAI_API_KEY=your-openai-api-key

# Get from: https://cloud.walletconnect.com/
NEXT_PUBLIC_WALLET_CONNECT_PROJECT_ID=your-project-id
```

4. **Setup PostgreSQL with pgvector**

For local development:
```sql
CREATE DATABASE artificial_arcade;
\c artificial_arcade;
CREATE EXTENSION IF NOT EXISTS vector;
```

For production, use a managed PostgreSQL service like:
- [Neon](https://neon.tech) (recommended - serverless PostgreSQL)
- [Supabase](https://supabase.com)
- [Amazon RDS](https://aws.amazon.com/rds/postgresql/)

5. **Run database migrations**
```bash
npm run db:generate
npm run db:push
```

6. **Start the development server**
```bash
npm run dev
```

Open [http://localhost:3000](http://localhost:3000) to see the application.

## Database Commands

```bash
# Generate migrations from schema
npm run db:generate

# Apply migrations to database
npm run db:migrate

# Push schema directly (development)
npm run db:push

# Open Drizzle Studio (database GUI)
npm run db:studio
```

## MCP Server

The MCP server handles game execution and state management:

```bash
cd mcp-server
npm install
npm start
```

## Project Structure

```
artificial-arcade/
├── app/                    # Next.js app directory
│   ├── api/               # API routes
│   ├── games/             # Game pages
│   └── page.tsx           # Homepage
├── components/            # React components
│   ├── companion/         # AI companion components
│   ├── games/             # Game-related components
│   └── layout/            # Layout components
├── lib/                   # Core libraries
│   ├── ai/                # AI companion service
│   ├── auth/              # Authentication config
│   ├── db/                # Database schema and config
│   └── web3/              # Web3 configuration
├── mcp-server/            # MCP game execution server
└── public/                # Static assets
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

MIT License - see LICENSE file for details

## Support

For issues and questions, please open a GitHub issue or contact the maintainers.
