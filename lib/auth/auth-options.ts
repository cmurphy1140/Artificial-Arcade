import { NextAuthOptions } from 'next-auth';
import CredentialsProvider from 'next-auth/providers/credentials';
import { getCsrfToken } from 'next-auth/react';
import { SiweMessage } from 'siwe';
import { db, users } from '@/lib/db';
import { eq } from 'drizzle-orm';

export const authOptions: NextAuthOptions = {
  providers: [
    CredentialsProvider({
      name: 'Ethereum',
      credentials: {
        message: {
          label: 'Message',
          type: 'text',
          placeholder: '0x0',
        },
        signature: {
          label: 'Signature',
          type: 'text',
          placeholder: '0x0',
        },
      },
      async authorize(credentials, req) {
        try {
          const siwe = new SiweMessage(JSON.parse(credentials?.message || '{}'));
          const nextAuthUrl = new URL(process.env.NEXTAUTH_URL!);

          const result = await siwe.verify({
            signature: credentials?.signature || '',
            domain: nextAuthUrl.host,
            nonce: await getCsrfToken({ req: { headers: req.headers } }),
          });

          if (result.success) {
            // Find or create user
            const address = siwe.address.toLowerCase();
            let user = await db.select().from(users).where(eq(users.walletAddress, address)).limit(1);
            
            if (user.length === 0) {
              const newUser = await db.insert(users).values({
                walletAddress: address,
              }).returning();
              user = newUser;
            }

            return {
              id: user[0].id,
              address,
              user: user[0],
            };
          }
          return null;
        } catch (e) {
          console.error('Auth error:', e);
          return null;
        }
      },
    }),
  ],
  session: {
    strategy: 'jwt',
  },
  secret: process.env.NEXTAUTH_SECRET,
  callbacks: {
    async session({ session, token }) {
      return {
        ...session,
        address: token.sub,
        user: {
          ...session.user,
          ...token.user,
        },
      };
    },
    async jwt({ token, user }) {
      if (user) {
        token.user = user.user;
      }
      return token;
    },
  },
};