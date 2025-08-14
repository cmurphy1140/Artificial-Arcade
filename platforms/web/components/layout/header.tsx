'use client';

import { ConnectButton } from '@rainbow-me/rainbowkit';
import Link from 'next/link';
import { useSession } from 'next-auth/react';

export function Header() {
  const { data: session } = useSession();

  return (
    <header className="border-b border-gray-800 bg-black/50 backdrop-blur-sm">
      <div className="container mx-auto px-4">
        <div className="flex h-16 items-center justify-between">
          <div className="flex items-center space-x-8">
            <Link href="/" className="text-xl font-bold text-white">
              Artificial Arcade
            </Link>
            <nav className="hidden md:flex space-x-6">
              <Link href="/games" className="text-gray-300 hover:text-white transition">
                Games
              </Link>
              <Link href="/create" className="text-gray-300 hover:text-white transition">
                Create
              </Link>
              <Link href="/leaderboard" className="text-gray-300 hover:text-white transition">
                Leaderboard
              </Link>
              {session && (
                <Link href="/profile" className="text-gray-300 hover:text-white transition">
                  Profile
                </Link>
              )}
            </nav>
          </div>
          <ConnectButton />
        </div>
      </div>
    </header>
  );
}