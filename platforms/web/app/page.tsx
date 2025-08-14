import { Header } from '@/components/layout/header';
import Link from 'next/link';

export default function HomePage() {
  return (
    <div className="min-h-screen bg-gradient-to-b from-gray-900 to-black">
      <Header />
      
      {/* Hero Section */}
      <section className="container mx-auto px-4 py-16">
        <div className="text-center">
          <h1 className="text-5xl md:text-7xl font-bold text-white mb-6">
            Welcome to <span className="bg-gradient-to-r from-purple-500 to-pink-500 bg-clip-text text-transparent">Artificial Arcade</span>
          </h1>
          <p className="text-xl text-gray-300 mb-8 max-w-2xl mx-auto">
            Play, create, and explore AI-enhanced games with intelligent companions that remember and evolve with you
          </p>
          <div className="flex gap-4 justify-center">
            <Link 
              href="/games" 
              className="px-8 py-3 bg-purple-600 hover:bg-purple-700 text-white rounded-lg font-semibold transition"
            >
              Browse Games
            </Link>
            <Link 
              href="/create" 
              className="px-8 py-3 bg-gray-800 hover:bg-gray-700 text-white rounded-lg font-semibold transition"
            >
              Create Game
            </Link>
          </div>
        </div>
      </section>

      {/* Features Section */}
      <section className="container mx-auto px-4 py-16">
        <h2 className="text-3xl font-bold text-white mb-12 text-center">Platform Features</h2>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
          <div className="bg-gray-800/50 p-6 rounded-lg backdrop-blur-sm">
            <h3 className="text-xl font-semibold text-white mb-3">AI Companions</h3>
            <p className="text-gray-300">
              Intelligent game companions that remember your play style and evolve with you
            </p>
          </div>
          <div className="bg-gray-800/50 p-6 rounded-lg backdrop-blur-sm">
            <h3 className="text-xl font-semibold text-white mb-3">Token-Gated Content</h3>
            <p className="text-gray-300">
              Access exclusive games and features with your Web3 tokens
            </p>
          </div>
          <div className="bg-gray-800/50 p-6 rounded-lg backdrop-blur-sm">
            <h3 className="text-xl font-semibold text-white mb-3">Create & Share</h3>
            <p className="text-gray-300">
              Build your own AI-powered games and share them with the community
            </p>
          </div>
        </div>
      </section>

      {/* Coming Soon Section */}
      <section className="container mx-auto px-4 py-16">
        <div className="bg-gradient-to-r from-purple-900/50 to-pink-900/50 p-8 rounded-2xl backdrop-blur-sm">
          <h2 className="text-2xl font-bold text-white mb-4 text-center">Coming Soon</h2>
          <p className="text-gray-300 text-center max-w-2xl mx-auto">
            We&apos;re building an amazing collection of AI-powered games. Connect your wallet to be notified when new games launch!
          </p>
        </div>
      </section>
    </div>
  );
}
