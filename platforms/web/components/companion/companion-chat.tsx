'use client';

import { useState, useRef, useEffect } from 'react';
import { useSession } from 'next-auth/react';

interface Message {
  id: string;
  role: 'user' | 'companion';
  content: string;
  timestamp: Date;
}

interface CompanionChatProps {
  companionId: string;
  companionName: string;
  companionAvatar?: string;
  gameContext?: Record<string, unknown>;
}

export function CompanionChat({
  companionId,
  companionName,
  companionAvatar,
  gameContext,
}: CompanionChatProps) {
  const { data: session } = useSession();
  const [messages, setMessages] = useState<Message[]>([]);
  const [input, setInput] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const messagesEndRef = useRef<HTMLDivElement>(null);

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  };

  useEffect(() => {
    scrollToBottom();
  }, [messages]);

  const sendMessage = async () => {
    if (!input.trim() || !session) return;

    const userMessage: Message = {
      id: Date.now().toString(),
      role: 'user',
      content: input,
      timestamp: new Date(),
    };

    setMessages((prev) => [...prev, userMessage]);
    setInput('');
    setIsLoading(true);

    try {
      const response = await fetch('/api/companion/chat', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          companionId,
          message: input,
          gameContext,
        }),
      });

      const data = await response.json();

      if (response.ok) {
        const companionMessage: Message = {
          id: (Date.now() + 1).toString(),
          role: 'companion',
          content: data.response,
          timestamp: new Date(),
        };
        setMessages((prev) => [...prev, companionMessage]);
      }
    } catch (error) {
      console.error('Failed to send message:', error);
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="flex flex-col h-[500px] bg-gray-900 rounded-lg border border-gray-800">
      {/* Header */}
      <div className="flex items-center gap-3 p-4 border-b border-gray-800">
        <div className="w-10 h-10 rounded-full bg-purple-600 flex items-center justify-center">
          {companionAvatar ? (
            <div className="w-8 h-8 bg-purple-500 rounded-full flex items-center justify-center text-white font-semibold">
              {companionName.charAt(0)}
            </div>
          ) : (
            <span className="text-white text-lg">🤖</span>
          )}
        </div>
        <div>
          <h3 className="text-white font-semibold">{companionName}</h3>
          <p className="text-xs text-gray-400">AI Companion</p>
        </div>
      </div>

      {/* Messages */}
      <div className="flex-1 overflow-y-auto p-4 space-y-4">
        {messages.length === 0 && (
          <div className="text-center text-gray-500 mt-8">
            <p>Start a conversation with {companionName}!</p>
            <p className="text-sm mt-2">They remember your play style and preferences.</p>
          </div>
        )}
        
        {messages.map((message) => (
          <div
            key={message.id}
            className={`flex ${
              message.role === 'user' ? 'justify-end' : 'justify-start'
            }`}
          >
            <div
              className={`max-w-[70%] p-3 rounded-lg ${
                message.role === 'user'
                  ? 'bg-purple-600 text-white'
                  : 'bg-gray-800 text-gray-200'
              }`}
            >
              <p className="text-sm">{message.content}</p>
              <p className="text-xs opacity-70 mt-1">
                {message.timestamp.toLocaleTimeString()}
              </p>
            </div>
          </div>
        ))}
        
        {isLoading && (
          <div className="flex justify-start">
            <div className="bg-gray-800 p-3 rounded-lg">
              <div className="flex gap-1">
                <span className="w-2 h-2 bg-gray-500 rounded-full animate-bounce"></span>
                <span className="w-2 h-2 bg-gray-500 rounded-full animate-bounce delay-100"></span>
                <span className="w-2 h-2 bg-gray-500 rounded-full animate-bounce delay-200"></span>
              </div>
            </div>
          </div>
        )}
        
        <div ref={messagesEndRef} />
      </div>

      {/* Input */}
      <div className="p-4 border-t border-gray-800">
        <div className="flex gap-2">
          <input
            type="text"
            value={input}
            onChange={(e) => setInput(e.target.value)}
            onKeyPress={(e) => e.key === 'Enter' && sendMessage()}
            placeholder="Type your message..."
            className="flex-1 bg-gray-800 text-white px-4 py-2 rounded-lg focus:outline-none focus:ring-2 focus:ring-purple-600"
            disabled={!session || isLoading}
          />
          <button
            onClick={sendMessage}
            disabled={!session || isLoading || !input.trim()}
            className="px-6 py-2 bg-purple-600 hover:bg-purple-700 disabled:bg-gray-700 text-white rounded-lg transition"
          >
            Send
          </button>
        </div>
      </div>
    </div>
  );
}