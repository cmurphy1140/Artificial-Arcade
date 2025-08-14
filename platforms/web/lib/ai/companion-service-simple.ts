import OpenAI from 'openai';

// Simplified companion service for build compatibility
const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY || 'dummy-key',
});

export class CompanionService {
  async generateResponse({
    companionId,
    userId,
    message,
  }: {
    companionId: string;
    userId: string;
    message: string;
  }) {
    try {
      // Simple response without database operations for build compatibility
      const response = await openai.chat.completions.create({
        model: 'gpt-3.5-turbo',
        messages: [
          {
            role: 'system',
            content: `You are a helpful AI companion. Respond to the user's message in a friendly and engaging way.`,
          },
          {
            role: 'user',
            content: message,
          },
        ],
        max_tokens: 150,
        temperature: 0.7,
      });

      return response.choices[0]?.message?.content || 'Sorry, I could not generate a response.';
    } catch (error) {
      console.error('OpenAI API error:', error);
      return 'I apologize, but I am currently unavailable. Please try again later.';
    }
  }
}
