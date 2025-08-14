import Link from 'next/link';
import Image from 'next/image';

interface GameCardProps {
  game: {
    id: string;
    title: string;
    description: string | null;
    slug: string;
    thumbnailUrl: string | null;
    category: string | null;
    playCount: number | null;
    rating: string | null;
    tokenGated: boolean | null;
  };
}

export function GameCard({ game }: GameCardProps) {
  return (
    <Link href={`/games/${game.slug}`} className="group">
      <div className="bg-gray-800/50 rounded-lg overflow-hidden backdrop-blur-sm transition-all hover:bg-gray-800/70 hover:scale-105">
        <div className="aspect-video relative bg-gray-900">
          {game.thumbnailUrl ? (
            <Image
              src={game.thumbnailUrl}
              alt={game.title}
              fill
              className="object-cover"
            />
          ) : (
            <div className="w-full h-full flex items-center justify-center">
              <span className="text-gray-600 text-4xl">🎮</span>
            </div>
          )}
          {game.tokenGated && (
            <div className="absolute top-2 right-2 bg-purple-600 text-white px-2 py-1 rounded text-xs font-semibold">
              Token Gated
            </div>
          )}
        </div>
        <div className="p-4">
          <h3 className="text-white font-semibold mb-1 group-hover:text-purple-400 transition">
            {game.title}
          </h3>
          {game.description && (
            <p className="text-gray-400 text-sm line-clamp-2 mb-2">
              {game.description}
            </p>
          )}
          <div className="flex items-center justify-between text-xs text-gray-500">
            {game.category && (
              <span className="bg-gray-700 px-2 py-1 rounded">
                {game.category}
              </span>
            )}
            {game.playCount !== null && (
              <span>{game.playCount} plays</span>
            )}
          </div>
        </div>
      </div>
    </Link>
  );
}