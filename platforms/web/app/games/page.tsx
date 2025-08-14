import { Header } from '@/components/layout/header';
import { GameCard } from '@/components/games/game-card';
// import { db, games } from '@/lib/db';
// import { eq, desc } from 'drizzle-orm';

export default async function GamesPage() {
  // Fetch real games from database (temporarily disabled for build)
  // const allGames = await db
  //   .select()
  //   .from(games)
  //   .where(eq(games.isPublished, true))
  //   .orderBy(desc(games.createdAt))
  //   .limit(20);
  
  // Temporary mock data for build
  const allGames: Record<string, unknown>[] = [];
  
  // If no games exist yet, we'll show an empty state
  const hasGames = allGames.length > 0;
  return (
    <div className="min-h-screen bg-gradient-to-b from-gray-900 to-black">
      <Header />
      
      <div className="container mx-auto px-4 py-8">
        <h1 className="text-4xl font-bold text-white mb-8">Browse Games</h1>
        
        {/* Filters Section */}
        <div className="flex flex-wrap gap-4 mb-8">
          <select className="bg-gray-800 text-white px-4 py-2 rounded-lg" title="Game categories">
            <option>All Categories</option>
            <option>Adventure</option>
            <option>Puzzle</option>
            <option>Strategy</option>
            <option>Action</option>
          </select>
          <select className="bg-gray-800 text-white px-4 py-2 rounded-lg" title="Sort options">
            <option>Sort by Popular</option>
            <option>Sort by New</option>
            <option>Sort by Rating</option>
          </select>
          <button className="bg-purple-600 hover:bg-purple-700 text-white px-4 py-2 rounded-lg transition">
            Token Gated Only
          </button>
        </div>
        
        {/* Games Grid */}
        {hasGames ? (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
            {/* Temporarily disabled for build */}
            {/* {allGames.map((game) => (
              <GameCard key={game.id} game={game} />
            ))} */}
          </div>
        ) : (
          <div className="text-center py-16">
            <p className="text-gray-400 text-lg mb-4">No games available yet</p>
            <p className="text-gray-500">Check back soon or create your own game!</p>
          </div>
        )}
        
        {/* Load More */}
        <div className="text-center mt-12">
          <button className="bg-gray-800 hover:bg-gray-700 text-white px-8 py-3 rounded-lg transition">
            Load More Games
          </button>
        </div>
      </div>
    </div>
  );
}