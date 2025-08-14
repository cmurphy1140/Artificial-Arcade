'use client';

import { useState, useEffect } from 'react';
import { Header } from '@/components/layout/header';
import { GameCard } from '@/components/games/game-card';
import { config } from '@/lib/config/env';

// Mock games data with error handling
const mockGames = [
  {
    id: 'tic-tac-toe',
    title: 'Tic Tac Toe',
    description: 'Classic strategy game with AI opponent',
    slug: 'tic-tac-toe',
    thumbnailUrl: '/games/tic-tac-toe.png',
    category: 'Strategy',
    playCount: 1250,
    rating: '4.5',
    tokenGated: false,
    players: '1-2',
    difficulty: 'Easy',
    estimatedTime: '5 min',
    tags: ['Classic', 'Quick Play', 'Strategy'],
    isPublished: true,
    createdAt: new Date(),
  },
  {
    id: 'snake',
    title: 'Snake',
    description: 'Retro arcade classic with modern AI twists',
    slug: 'snake',
    thumbnailUrl: '/games/snake.png',
    category: 'Arcade',
    playCount: 2150,
    rating: '4.8',
    tokenGated: false,
    players: '1',
    difficulty: 'Medium',
    estimatedTime: '10 min',
    tags: ['Retro', 'Arcade', 'High Score'],
    isPublished: true,
    createdAt: new Date(),
  },
  {
    id: 'connect-four',
    title: 'Connect Four',
    description: 'Strategic falling disc game',
    slug: 'connect-four',
    thumbnailUrl: '/games/connect-four.png',
    category: 'Strategy',
    playCount: 980,
    rating: '4.3',
    tokenGated: false,
    players: '1-2',
    difficulty: 'Medium',
    estimatedTime: '15 min',
    tags: ['Strategy', 'Classic', 'Multiplayer'],
    isPublished: true,
    createdAt: new Date(),
  },
  {
    id: 'hangman',
    title: 'Hangman',
    description: 'Word guessing game with AI hints',
    slug: 'hangman',
    thumbnailUrl: '/games/hangman.png',
    category: 'Word',
    playCount: 750,
    rating: '4.1',
    tokenGated: false,
    players: '1',
    difficulty: 'Easy',
    estimatedTime: '8 min',
    tags: ['Word', 'Educational', 'AI Assisted'],
    isPublished: true,
    createdAt: new Date(),
  },
];

interface HealthStatus {
  status: string;
  services: {
    database: { status: string; enabled: boolean };
    ai: { status: string; enabled: boolean };
    auth: { status: string; enabled: boolean };
  };
}

export default function GamesPage() {
  const [healthStatus, setHealthStatus] = useState<HealthStatus | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [selectedCategory, setSelectedCategory] = useState('All Categories');

  useEffect(() => {
    const checkHealth = async () => {
      try {
        const response = await fetch('/api/health');
        if (response.ok) {
          const health = await response.json();
          setHealthStatus(health);
        } else {
          setError('Unable to check system status');
        }
      } catch (err) {
        console.error('Health check failed:', err);
        setError('System status unavailable');
      } finally {
        setLoading(false);
      }
    };

    checkHealth();
  }, []);

  const getSystemStatusBadge = () => {
    if (loading) return <div className="text-sm text-gray-400">Checking system status...</div>;
    if (error) return <div className="text-sm text-yellow-400">⚠️ {error}</div>;
    if (!healthStatus) return null;

    const { services } = healthStatus;
    const hasIssues = !services.database.enabled || !services.ai.enabled;

    return (
      <div className="text-sm mb-4">
        <div className={`${hasIssues ? 'text-yellow-400' : 'text-green-400'}`}>
          🎮 System Status: {hasIssues ? 'Limited Features' : 'All Systems Ready'}
        </div>
        {hasIssues && (
          <div className="text-xs text-gray-400 mt-1 space-y-1">
            {!services.database.enabled && <div>• Offline mode: Progress won&apos;t be saved</div>}
            {!services.ai.enabled && <div>• AI features limited</div>}
          </div>
        )}
      </div>
    );
  };

  const filteredGames = selectedCategory === 'All Categories' 
    ? mockGames 
    : mockGames.filter(game => game.category === selectedCategory);

  // Use mock games instead of database games for now
  const allGames = config.database.enabled ? [] : mockGames;
  const hasGames = allGames.length > 0;

  return (
    <div className="min-h-screen bg-gradient-to-b from-gray-900 to-black">
      <Header />
      
      <div className="container mx-auto px-4 py-8">
        <h1 className="text-4xl font-bold text-white mb-4">Browse Games</h1>
        {getSystemStatusBadge()}
        
        {/* Filters Section */}
        <div className="flex flex-wrap gap-4 mb-8">
          <select 
            className="bg-gray-800 text-white px-4 py-2 rounded-lg" 
            title="Game categories"
            value={selectedCategory}
            onChange={(e) => setSelectedCategory(e.target.value)}
          >
            <option>All Categories</option>
            <option>Strategy</option>
            <option>Arcade</option>
            <option>Word</option>
            <option>Adventure</option>
            <option>Puzzle</option>
            <option>Action</option>
          </select>
          <select className="bg-gray-800 text-white px-4 py-2 rounded-lg" title="Sort options">
            <option>Sort by Popular</option>
            <option>Sort by New</option>
            <option>Sort by Rating</option>
          </select>
          <button type="button" className="bg-purple-600 hover:bg-purple-700 text-white px-4 py-2 rounded-lg transition">
            Token Gated Only
          </button>
        </div>
        
        {/* Games Grid */}
        {hasGames ? (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
            {filteredGames.map((game) => (
              <GameCard key={game.id} game={game} />
            ))}
          </div>
        ) : (
          <div className="text-center py-16">
            <p className="text-gray-400 text-lg mb-4">No games available yet</p>
            <p className="text-gray-500">Check back soon or create your own game!</p>
          </div>
        )}

        {!config.database.enabled && (
          <div className="mt-8 p-4 bg-yellow-900/30 border border-yellow-600/50 rounded-lg">
            <h3 className="text-yellow-400 font-semibold mb-2">ℹ️ Demo Mode</h3>
            <p className="text-yellow-200 text-sm">
              Games are running in demo mode with sample data. 
              Connect a database to enable user progress, achievements, and personalized features.
            </p>
          </div>
        )}
        
        {/* Load More */}
        <div className="text-center mt-12">
          <button type="button" className="bg-gray-800 hover:bg-gray-700 text-white px-8 py-3 rounded-lg transition">
            Load More Games
          </button>
        </div>
      </div>
    </div>
  );
}