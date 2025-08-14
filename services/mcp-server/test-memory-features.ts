#!/usr/bin/env tsx
/**
 * Test script for enhanced memory features
 * Run with: tsx test-memory-features.ts
 */

import { FastMCP } from 'fastmcp';

// Test configuration
const TEST_USER_ID = 'test-user-' + Date.now();
const TEST_COMPANION_ID = 'test-companion-' + Date.now();
const TEST_GAME_ID = 'test-game-' + Date.now();

async function testMemoryFeatures() {
  console.log('🧪 Testing Enhanced Memory Features\n');
  
  // Connect to MCP server
  const client = new FastMCP('Test Client');
  
  try {
    // Test 1: Store memory with conversation threading
    console.log('📝 Test 1: Storing threaded memories...');
    
    const conversation1 = await client.callTool('storeMemory', {
      userId: TEST_USER_ID,
      companionId: TEST_COMPANION_ID,
      content: 'Hello! I love playing puzzle games.',
      type: 'conversation',
      importance: 7,
    });
    
    console.log('✅ Stored initial memory:', conversation1.conversationId);
    
    // Store follow-up in same conversation
    const conversation2 = await client.callTool('storeMemory', {
      userId: TEST_USER_ID,
      companionId: TEST_COMPANION_ID,
      content: 'My favorite is Tetris, but I also enjoy match-3 games.',
      type: 'conversation',
      importance: 8,
      parentMemoryId: conversation1.memoryId,
    });
    
    console.log('✅ Stored threaded memory:', conversation2.conversationId);
    
    // Test 2: Learn preferences
    console.log('\n🎯 Test 2: Learning user preferences...');
    
    await client.callTool('learnPreferences', {
      userId: TEST_USER_ID,
      companionId: TEST_COMPANION_ID,
      preferenceKey: 'favorite_game_genre',
      preferenceValue: 'puzzle',
      confidence: 0.8,
    });
    
    await client.callTool('learnPreferences', {
      userId: TEST_USER_ID,
      companionId: TEST_COMPANION_ID,
      preferenceKey: 'play_style',
      preferenceValue: 'casual',
      confidence: 0.6,
    });
    
    console.log('✅ Preferences learned successfully');
    
    // Test 3: Store more memories for clustering
    console.log('\n📚 Test 3: Storing memories for clustering...');
    
    const memoryTopics = [
      'I really enjoy the strategic thinking in puzzle games',
      'Puzzle games help me relax after work',
      'I like games that challenge my problem-solving skills',
      'My high score in Tetris is 500,000 points',
      'I play games mostly on weekends',
      'Weekend gaming sessions are my favorite',
    ];
    
    for (const content of memoryTopics) {
      await client.callTool('storeMemory', {
        userId: TEST_USER_ID,
        companionId: TEST_COMPANION_ID,
        content,
        type: 'conversation',
        importance: Math.floor(Math.random() * 5) + 3,
      });
    }
    
    console.log('✅ Stored', memoryTopics.length, 'additional memories');
    
    // Test 4: Cluster memories
    console.log('\n🔮 Test 4: Clustering similar memories...');
    
    const clusters = await client.callTool('clusterMemories', {
      userId: TEST_USER_ID,
      companionId: TEST_COMPANION_ID,
      minClusterSize: 2,
    });
    
    console.log('✅ Created clusters:', clusters);
    
    // Test 5: Retrieve memories
    console.log('\n🔍 Test 5: Retrieving relevant memories...');
    
    const retrieved = await client.callTool('retrieveMemories', {
      userId: TEST_USER_ID,
      companionId: TEST_COMPANION_ID,
      query: 'What games does the user like?',
      limit: 5,
    });
    
    console.log('✅ Retrieved memories:', retrieved.count);
    
    // Test 6: Apply memory decay
    console.log('\n⏰ Test 6: Testing memory decay...');
    
    const decayResult = await client.callTool('decayMemoryImportance', {
      userId: TEST_USER_ID,
      daysOld: 0, // Decay all memories for testing
    });
    
    console.log('✅ Memory decay applied:', decayResult);
    
    // Test 7: Get companion stats
    console.log('\n📊 Test 7: Getting companion statistics...');
    
    const stats = await client.callTool('getCompanionStats', {
      companionId: TEST_COMPANION_ID,
      userId: TEST_USER_ID,
    });
    
    console.log('✅ Companion stats:', {
      name: stats.companion.name,
      totalMemories: stats.stats.totalMemories,
      recentInteractions: stats.stats.recentInteractions.length,
    });
    
    console.log('\n🎉 All tests completed successfully!');
    
  } catch (error) {
    console.error('❌ Test failed:', error);
    process.exit(1);
  }
}

// Run tests
testMemoryFeatures().catch(console.error);