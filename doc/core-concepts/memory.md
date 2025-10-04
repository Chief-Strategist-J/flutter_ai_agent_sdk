# Memory Management

Comprehensive guide to memory management in the Flutter AI Agent SDK.

## Overview

Memory management is crucial for maintaining conversation context and providing coherent, contextual responses. The SDK provides multiple memory layers and strategies to handle different use cases.

## Memory Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                      Memory System                              │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐              │
│  │ Short-term  │  │ Long-term   │  │ Episodic    │              │
│  │  Memory     │  │  Memory     │  │  Memory     │              │
│  └─────────────┘  └─────────────┘  └─────────────┘              │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐              │
│  │ Compression │  │ Persistence │  │ Retrieval   │              │
│  └─────────────┘  └─────────────┘  └─────────────┘              │
└─────────────────────────────────────────────────────────────────┘
```

## Memory Types

### Short-term Memory

Stores recent conversation messages for immediate context:

```dart
class ShortTermMemory {
  final int maxMessages;
  final Duration retentionPeriod;

  // Automatically managed by sessions
  Future<void> addMessage(Message message);
  Future<List<Message>> getRecentMessages({int limit = 50});
  Future<void> clear();
}
```

**Use Cases:**
- Immediate conversation context
- Recent user queries and responses
- Session-based interactions

**Configuration:**
```dart
MemoryConfig(
  maxShortTermMessages: 50,        // Maximum messages to keep
  shortTermRetentionPeriod: Duration(hours: 1), // How long to retain
)
```

### Long-term Memory

Stores summarized conversation history and key information:

```dart
class LongTermMemory {
  final int maxSummaries;
  final SummaryStrategy strategy;

  Future<void> addConversation(List<Message> messages);
  Future<List<ConversationSummary>> getRelevantSummaries(String query);
  Future<void> compressSummaries();
}
```

**Use Cases:**
- Historical context across sessions
- User preferences and patterns
- Important information retention

**Configuration:**
```dart
MemoryConfig(
  maxLongTermSummaries: 100,       // Maximum summaries to keep
  summaryStrategy: SummaryStrategy.automatic, // When to create summaries
  compressionThreshold: 50,        // Messages before compression
)
```

### Episodic Memory

Stores specific events and experiences:

```dart
class EpisodicMemory {
  Future<void> recordEvent(String eventType, Map<String, dynamic> data);
  Future<List<MemoryEvent>> recallEvents(String eventType, {DateTimeRange? range});
  Future<double> getSimilarity(MemoryEvent event1, MemoryEvent event2);
}
```

## Memory Configuration

### Basic Configuration

```dart
final memoryConfig = MemoryConfig(
  maxShortTermMessages: 50,
  maxLongTermSummaries: 100,
  persistence: MemoryPersistence.memory,
  compressionEnabled: true,
);
```

### Advanced Configuration

```dart
final memoryConfig = MemoryConfig(
  maxShortTermMessages: 100,
  maxLongTermSummaries: 200,
  persistence: MemoryPersistence.file,
  memoryPath: 'data/conversations/',

  // Compression settings
  compressionEnabled: true,
  compressionThreshold: 75,
  compressionStrategy: CompressionStrategy.semantic,

  // Summary settings
  summaryStrategy: SummaryStrategy.adaptive,
  summaryFrequency: Duration(minutes: 30),

  // Retrieval settings
  retrievalStrategy: RetrievalStrategy.hybrid,
  similarityThreshold: 0.7,
);
```

## Memory Persistence

### In-Memory Storage

```dart
MemoryConfig(
  persistence: MemoryPersistence.memory,
  // Data is lost when app closes
)
```

### File-Based Storage

```dart
MemoryConfig(
  persistence: MemoryPersistence.file,
  memoryPath: await _getApplicationDocumentsDirectory(),
  // Data persists across app restarts
)
```

### Database Storage

```dart
MemoryConfig(
  persistence: MemoryPersistence.database,
  databasePath: 'conversations.db',
  // Full database features and querying
)
```

## Memory Operations

### Adding Messages

```dart
// Messages are automatically added to short-term memory
await session.sendMessage('Hello');

// Manual addition (if needed)
await memory.addMessage(Message(
  id: 'msg_123',
  role: 'user',
  content: 'Hello',
  timestamp: DateTime.now(),
));
```

### Retrieving Context

```dart
// Get recent messages
final recentMessages = await memory.getRecentMessages(limit: 10);

// Get messages by role
final userMessages = await memory.getMessagesByRole('user');

// Search messages
final searchResults = await memory.search('weather');
```

### Memory Summarization

```dart
// Manual summarization
final summary = await memory.summarizeConversation(messages);

// Automatic summarization (based on config)
await memory.autoSummarize(); // Called periodically
```

## Memory Compression

### Why Compression?

- **Performance**: Faster retrieval and processing
- **Storage**: Reduced memory footprint
- **Cost**: Lower API costs for LLM calls
- **Context**: Better context window utilization

### Compression Strategies

```dart
enum CompressionStrategy {
  none,           // No compression
  simple,         // Remove redundant messages
  semantic,       // Use semantic similarity
  hierarchical,   // Multi-level compression
}
```

### Example Implementation

```dart
class SemanticCompressor {
  Future<List<Message>> compress(List<Message> messages) async {
    // Use embeddings to find similar messages
    final embeddings = await _generateEmbeddings(messages);

    // Cluster similar messages
    final clusters = _clusterMessages(messages, embeddings);

    // Keep representative messages from each cluster
    return _selectRepresentatives(clusters);
  }
}
```

## Memory Retrieval

### Retrieval Strategies

```dart
enum RetrievalStrategy {
  recent,         // Most recent messages only
  relevant,       // Semantic similarity search
  hybrid,         // Combination of recent + relevant
  contextual,     // Context-aware retrieval
}
```

### Advanced Retrieval

```dart
class MemoryRetriever {
  Future<List<Message>> retrieve({
    String? query,
    int limit = 10,
    DateTimeRange? timeRange,
    List<String>? messageTypes,
    double relevanceThreshold = 0.7,
  }) async {
    // Implement retrieval logic
  }
}
```

## Memory Integration with LLM

### Context Injection

```dart
class ContextInjector {
  Future<String> buildContext(List<Message> messages) async {
    final contextParts = <String>[];

    // Add recent conversation
    contextParts.add(_formatRecentMessages(messages));

    // Add relevant summaries
    contextParts.add(_formatSummaries(await _getRelevantSummaries(query)));

    return contextParts.join('\n\n');
  }
}
```

### Dynamic Context

```dart
// Context adapts based on conversation
class DynamicContextBuilder {
  Future<String> buildContext(String currentQuery) async {
    final baseContext = await _getBaseContext();
    final relevantMemories = await _retrieveRelevant(currentQuery);
    final dynamicContext = await _adaptContext(baseContext, relevantMemories);

    return dynamicContext;
  }
}
```

## Memory Best Practices

### 1. Configuration Tuning

```dart
// For short conversations (chatbot)
MemoryConfig(
  maxShortTermMessages: 20,
  maxLongTermSummaries: 10,
)

// For long conversations (assistant)
MemoryConfig(
  maxShortTermMessages: 100,
  maxLongTermSummaries: 50,
  compressionEnabled: true,
)
```

### 2. Performance Optimization

```dart
// Use appropriate data structures
class OptimizedMemoryStore {
  final Map<String, Message> _messageIndex = {};
  final SplayTreeSet<Message> _timestampIndex = SplayTreeSet();

  // Efficient lookups and insertions
}
```

### 3. Privacy and Security

```dart
class SecureMemoryManager {
  Future<void> encryptSensitiveData() async {
    // Encrypt personal information
  }

  Future<void> anonymizeData() async {
    // Remove personal identifiers
  }

  Future<bool> shouldRetainData() async {
    // Check data retention policies
  }
}
```

## Memory Monitoring

### Memory Statistics

```dart
class MemoryMonitor {
  Future<MemoryStats> getStats() async {
    return MemoryStats(
      shortTermMessageCount: await _getShortTermCount(),
      longTermSummaryCount: await _getLongTermCount(),
      totalSize: await _getTotalSize(),
      compressionRatio: await _getCompressionRatio(),
    );
  }
}
```

### Memory Health Checks

```dart
class MemoryHealthChecker {
  Future<MemoryHealth> checkHealth() async {
    final stats = await memoryMonitor.getStats();
    final issues = <String>[];

    if (stats.shortTermMessageCount > 1000) {
      issues.add('Short-term memory getting large');
    }

    if (stats.compressionRatio < 0.5) {
      issues.add('Poor compression ratio');
    }

    return MemoryHealth(
      isHealthy: issues.isEmpty,
      issues: issues,
      recommendations: _generateRecommendations(issues),
    );
  }
}
```

## Memory in Practice

### Simple Usage

```dart
// Automatic memory management
final config = AgentConfig(
  memoryConfig: MemoryConfig(
    maxShortTermMessages: 50,
  ),
);

final session = await agent.createSession();
// Memory automatically handles conversation context
```

### Advanced Usage

```dart
class CustomMemoryManager {
  final ConversationMemory _memory;

  Future<void> handleMessage(Message message) async {
    // Custom preprocessing
    final processedMessage = await _preprocessMessage(message);

    // Add to memory with metadata
    await _memory.addMessage(processedMessage, metadata: {
      'processed': true,
      'sentiment': await _analyzeSentiment(message),
    });

    // Trigger summarization if needed
    if (await _shouldSummarize()) {
      await _memory.summarizeRecent();
    }
  }
}
```

## Testing Memory

### Memory Testing Utilities

```dart
class MemoryTester {
  static Future<void> testMemoryOperations() async {
    final memory = ConversationMemory(config: testConfig);

    // Test message addition
    await memory.addMessage(testMessage1);
    await memory.addMessage(testMessage2);

    // Test retrieval
    final messages = await memory.getRecentMessages(limit: 10);
    assert(messages.length >= 2);

    // Test search
    final results = await memory.search('test query');
    assert(results.isNotEmpty);
  }
}
```

## Troubleshooting

### Common Issues

**Memory Growing Too Large**
```dart
// Implement size limits and cleanup
Timer.periodic(Duration(hours: 1), (_) async {
  await memory.cleanupOldMessages();
});
```

**Poor Context Retrieval**
```dart
// Improve search algorithms
class ImprovedRetriever {
  Future<List<Message>> search(String query) async {
    // Use better similarity algorithms
    return await _semanticSearch(query);
  }
}
```

**Memory Corruption**
```dart
// Implement validation and repair
class MemoryValidator {
  Future<bool> validateMemory() async {
    // Check data integrity
    return await _checkIntegrity();
  }

  Future<void> repairMemory() async {
    // Fix corrupted data
    await _repairCorruptedData();
  }
}
```

This comprehensive memory management system ensures your AI agents maintain appropriate context while remaining performant and reliable.
