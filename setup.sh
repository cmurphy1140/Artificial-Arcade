#!/bin/bash

# Artificial Arcade Development Setup Script

echo "🎮 Setting up Artificial Arcade development environment..."

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed. Please install Node.js 18+ first."
    exit 1
fi

# Check if Xcode is available (for iOS development)
if command -v xcodebuild &> /dev/null; then
    echo "✅ Xcode detected - iOS development available"
else
    echo "⚠️  Xcode not found - iOS development will not be available"
fi

# Install workspace dependencies
echo "📦 Installing workspace dependencies..."
npm install

# Setup web platform
echo "🌐 Setting up web platform..."
cd platforms/web
npm install
cd ../..

# Setup MCP server
echo "🤖 Setting up MCP server..."
cd services/mcp-server
npm install
cd ../..

# Create environment file if it doesn't exist
if [ ! -f "platforms/web/.env.local" ]; then
    echo "📝 Creating environment file template..."
    cat > platforms/web/.env.local << EOF
# AI Configuration
OPENAI_API_KEY=your_openai_api_key_here

# Database Configuration
DATABASE_URL=your_database_url_here

# Web3 Configuration (optional)
NEXT_PUBLIC_WALLET_CONNECT_PROJECT_ID=your_project_id_here
EOF
    echo "⚠️  Please update platforms/web/.env.local with your API keys"
fi

echo "✅ Setup complete!"
echo ""
echo "🚀 To start development:"
echo "  Web app:    npm run dev:web"
echo "  MCP server: npm run dev:mcp"
echo "  iOS app:    Open platforms/ios/ArtificialArcade.xcodeproj in Xcode"
echo ""
echo "📚 Check docs/README.md for more information"
