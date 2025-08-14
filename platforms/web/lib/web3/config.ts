import { getDefaultConfig } from '@rainbow-me/rainbowkit';
import { mainnet, polygon, arbitrum, optimism, base } from 'wagmi/chains';

// Validate WalletConnect Project ID
const projectId = process.env.NEXT_PUBLIC_WALLET_CONNECT_PROJECT_ID;

if (!projectId) {
  console.warn(
    'WalletConnect Project ID not configured. Get yours at https://cloud.walletconnect.com/'
  );
}

export const config = getDefaultConfig({
  appName: 'Artificial Arcade',
  projectId: projectId || 'dummy-project-id-for-development',
  chains: [mainnet, polygon, arbitrum, optimism, base],
  ssr: true,
});