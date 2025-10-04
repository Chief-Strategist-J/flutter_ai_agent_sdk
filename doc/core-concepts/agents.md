# Agent System Overview

Deep dive into the Flutter AI Agent SDK's agent architecture and core concepts.

## What is an Agent?

An agent in the Flutter AI Agent SDK is an intelligent conversational entity that can:

- **Listen** to user speech through speech-to-text
- **Understand** user intent via Large Language Models
- **Respond** using text-to-speech synthesis
- **Remember** conversation history and context
- **Execute** custom functions and tools
- **Adapt** behavior based on configuration

## Core Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        VoiceAgent                               │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐              │
│  │   STT       │  │    LLM      │  │    TTS      │              │
│  │  Service    │  │  Provider   │  │  Service    │              │
│  └─────────────┘  └─────────────┘  └─────────────┘              │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐              │
│  │ Turn Detect │  │   Memory    │  │    Tools    │              │
│  └─────────────┘  └─────────────┘  └─────────────┘              │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐              │
│  │  Events     │  │   Session   │  │  Logging    │              │
│  └─────────────┘  └─────────────┘  └─────────────┘              │
└─────────────────────────────────────────────────────────────────┘
```

## Agent Lifecycle

### 1. Initialization

```dart
// Create configuration
final config = AgentConfig(
  name: 'My Assistant',
  instructions: 'You are a helpful AI assistant.',
  llmProvider: OpenAIProvider(apiKey: 'your-key'),
  sttService: NativeSTTService(),
  ttsService: NativeTTSService(),
);

// Create agent
final agent = VoiceAgent(config: config);
```

### 2. Session Management

```dart
// Create a session for interaction
final session = await agent.createSession();

// Listen to session state changes
session.state.listen((state) {
  print('Session state: ${state.state}');
});

// Listen to events
session.events.listen((event) {
  if (event is MessageReceivedEvent) {
    print('Received: ${event.message.content}');
  }
});
```

### 3. Interaction Loop

```dart
// Start listening for user input
await session.startListening();

// Process user speech
// ... speech recognition happens automatically ...

// Generate AI response
// ... LLM processes the input ...

// Speak the response
await session.speak(responseText);

// Repeat the cycle
```

### 4. Cleanup

```dart
// Close session
await session.close();

// Dispose of agent
await agent.dispose();
```

## Key Components

### AgentConfig

The central configuration object that defines agent behavior:

```dart
class AgentConfig {
  final String name;                    // Agent identity
  final String instructions;            // System prompt
  final LLMProvider llmProvider;        // AI model provider
  final SpeechRecognitionService sttService; // Speech-to-text
  final TextToSpeechService ttsService; // Text-to-speech
  final TurnDetectionConfig turnDetection; // Voice activity detection
  final List<Tool> tools;              // Available functions
  final MemoryConfig memoryConfig;      // Memory settings
  final LoggingConfig loggingConfig;    // Logging configuration
}
```

### AgentSession

Represents an active conversation session:

```dart
class AgentSession {
  Stream<SessionState> state;          // Current state
  Stream<AgentEvent> events;           // Event notifications
  bool isListening;                    // Listening status
  bool isSpeaking;                     // Speaking status

  // Core methods
  Future<void> sendMessage(String text);
  Future<void> startListening();
  Future<void> stopListening();
  Future<void> speak(String text);
  Future<void> close();
}
```

### Event System

Events drive the reactive architecture:

```dart
// Listen to all events
session.events.listen((event) {
  switch (event) {
    case MessageReceivedEvent():
      // Handle incoming message
      break;
    case SessionStateChangedEvent():
      // Handle state changes
      break;
    case SpeechRecognizedEvent():
      // Handle speech recognition
      break;
  }
});
```

## Configuration Strategies

### Simple Configuration

```dart
final config = AgentConfig(
  name: 'Assistant',
  instructions: 'Be helpful and concise.',
  llmProvider: OpenAIProvider(apiKey: 'key'),
  sttService: NativeSTTService(),
  ttsService: NativeTTSService(),
);
```

### Advanced Configuration

```dart
final config = AgentConfig(
  name: 'Advanced Assistant',
  instructions: '''
    You are an advanced AI assistant with access to various tools.
    Always be helpful, accurate, and considerate in your responses.
  ''',
  llmProvider: OpenAIProvider(
    apiKey: 'key',
    model: 'gpt-4-turbo-preview',
    temperature: 0.7,
  ),
  sttService: NativeSTTService(
    language: 'en-US',
    continuous: true,
  ),
  ttsService: NativeTTSService(
    language: 'en-US',
    rate: 0.5,
    pitch: 1.0,
  ),
  turnDetection: TurnDetectionConfig(
    mode: TurnDetectionMode.vad,
    silenceThreshold: Duration(milliseconds: 700),
  ),
  tools: [weatherTool, calculatorTool],
  memoryConfig: MemoryConfig(
    maxShortTermMessages: 100,
    maxLongTermSummaries: 50,
  ),
);
```

## State Management

Agents maintain state throughout their lifecycle:

### Session States

```dart
enum SessionStatus {
  idle,        // Ready to start
  listening,   // Actively listening
  processing,  // Processing input
  speaking,    // Speaking response
  error,       // Error state
}
```

### State Transitions

```
idle → listening → processing → speaking → idle
  ↑           ↓           ↓           ↑
  └─── error ←───────── error ───────┘
```

## Error Handling

Robust error handling is built into the agent system:

```dart
session.events.listen((event) {
  if (event is ErrorEvent) {
    print('Error: ${event.error}');
    // Handle error appropriately
  }
});
```

## Best Practices

### 1. Proper Initialization

Always validate configuration before creating agents:

```dart
try {
  config.validate();
  final agent = VoiceAgent(config: config);
} catch (e) {
  print('Configuration error: $e');
}
```

### 2. Resource Management

Properly dispose of agents and sessions:

```dart
class MyWidget extends StatefulWidget {
  VoiceAgent? _agent;

  @override
  void dispose() {
    _agent?.dispose();
    super.dispose();
  }
}
```

### 3. Memory Management

Configure memory settings based on use case:

```dart
MemoryConfig(
  maxShortTermMessages: 50,    // For short conversations
  maxLongTermSummaries: 100,   // For long-term context
  compressionEnabled: true,    // Enable memory compression
)
```

### 4. Error Handling

Implement comprehensive error handling:

```dart
session.events.listen((event) {
  if (event is ErrorEvent) {
    // Log error
    logger.error('Agent error', error: event.error);

    // Notify user
    showErrorDialog(event.error.toString());

    // Attempt recovery
    _handleError(event.error);
  }
});
```

## Performance Considerations

### Memory Usage

- Monitor memory consumption in long-running sessions
- Use memory compression for better performance
- Clear old messages periodically if needed

### Audio Performance

- Choose appropriate audio buffer sizes
- Optimize sample rates for target devices
- Handle audio interruptions gracefully

### Network Efficiency

- Implement request batching for LLM calls
- Use streaming for real-time responses
- Handle network failures gracefully

## Integration Patterns

### Flutter Integration

```dart
class AgentProvider extends ChangeNotifier {
  VoiceAgent? _agent;
  AgentSession? _session;

  Future<void> initializeAgent() async {
    final config = await _loadConfig();
    _agent = VoiceAgent(config: config);
    notifyListeners();
  }

  Future<AgentSession> startSession() async {
    _session = await _agent!.createSession();
    notifyListeners();
    return _session!;
  }
}
```

### Widget Integration

```dart
class VoiceAgentWidget extends StatefulWidget {
  @override
  _VoiceAgentWidgetState createState() => _VoiceAgentWidgetState();
}

class _VoiceAgentWidgetState extends State<VoiceAgentWidget> {
  AgentSession? _session;
  bool _isListening = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: _toggleListening,
          child: Text(_isListening ? 'Stop' : 'Start'),
        ),
        StreamBuilder<SessionState>(
          stream: _session?.state,
          builder: (context, snapshot) {
            return Text('State: ${snapshot.data?.state ?? 'None'}');
          },
        ),
      ],
    );
  }
}
```

This comprehensive agent system provides a solid foundation for building sophisticated voice-enabled AI applications in Flutter.
