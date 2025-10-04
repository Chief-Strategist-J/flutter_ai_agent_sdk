# Session Management

Understanding how agent sessions work and how to manage them effectively.

## What is a Session?

A session represents an active conversation context between a user and an AI agent. It encapsulates:

- **Conversation State**: Current status and metadata
- **Event Stream**: Real-time events and notifications
- **Resource Management**: Audio, memory, and connection handling
- **Lifecycle Control**: Start, pause, resume, and end operations

## Session Lifecycle

### 1. Creation

```dart
// Create a new session
final session = await agent.createSession();

// Session starts in idle state
print(session.state.value.state); // SessionStatus.idle
```

### 2. Activation

```dart
// Start listening for user input
await session.startListening();

// Session transitions to listening state
print(session.state.value.state); // SessionStatus.listening
```

### 3. Interaction

```dart
// Send a text message directly
await session.sendMessage('Hello, how are you?');

// Or let speech recognition handle voice input
// The session automatically processes speech and responds
```

### 4. Termination

```dart
// Stop all activity
await session.stopListening();

// Close the session
await session.close();
```

## Session States

### State Enumeration

```dart
enum SessionStatus {
  idle,        // Ready to start interaction
  listening,   // Actively listening for speech
  processing,  // Processing audio or generating response
  speaking,    // Speaking the response
  error,       // Error state
}
```

### State Transitions

```
    startListening()
idle ───────────────→ listening ───────────────→ processing
    ↑                        ↓                       ↓
    │               stopListening()         sendMessage()
    │                        ↑                       ↑
    └─── close() ←────────────┘                       ↓
         ↑                                           ↓
         └─── error ─────────────────────────────────┘
```

## Event System

Sessions emit events that you can listen to:

```dart
// Listen to all session events
session.events.listen((event) {
  print('Event: ${event.runtimeType}');
});

// Listen to state changes specifically
session.state.listen((state) {
  print('State changed to: ${state.state}');
  setState(() {
    _currentState = state.state;
    _isListening = state.isListening;
    _isSpeaking = state.isSpeaking;
  });
});
```

### Common Events

```dart
// Message received from agent
MessageReceivedEvent(message: Message(content: 'Hello!'))

// Speech recognition result
SpeechRecognizedEvent(text: 'Hello, how are you?')

// Session state changed
SessionStateChangedEvent(oldState: idle, newState: listening)

// Error occurred
ErrorEvent(error: NetworkException('Connection failed'))
```

## Session Configuration

Sessions inherit configuration from the parent agent:

```dart
final config = AgentConfig(
  // ... other config
  turnDetection: TurnDetectionConfig(
    mode: TurnDetectionMode.vad,
    silenceThreshold: Duration(milliseconds: 700),
  ),
  memoryConfig: MemoryConfig(
    maxShortTermMessages: 50,
  ),
);

final agent = VoiceAgent(config: config);
final session = await agent.createSession(); // Uses agent config
```

## Memory Integration

Sessions automatically manage conversation memory:

```dart
// Messages are automatically stored in memory
await session.sendMessage('Remember this for later');

// Retrieve conversation history
final memory = session.getMemory(); // Implementation detail
final recentMessages = await memory.getRecentMessages(limit: 10);
```

## Error Handling

Robust error handling for session operations:

```dart
try {
  await session.startListening();
} catch (e) {
  print('Failed to start listening: $e');

  // Handle specific error types
  if (e is MicrophonePermissionError) {
    // Request microphone permission
    await _requestMicrophonePermission();
  } else if (e is NetworkError) {
    // Handle network issues
    await _handleNetworkError(e);
  }
}
```

## Advanced Session Management

### Multiple Sessions

```dart
class SessionManager {
  final VoiceAgent _agent;
  final List<AgentSession> _sessions = [];

  Future<AgentSession> createSession() async {
    final session = await _agent.createSession();
    _sessions.add(session);
    return session;
  }

  Future<void> closeAllSessions() async {
    for (final session in _sessions) {
      await session.close();
    }
    _sessions.clear();
  }
}
```

### Session Persistence

For stateful applications:

```dart
class PersistentSessionManager {
  AgentSession? _currentSession;
  String? _sessionId;

  Future<void> restoreSession(String sessionId) async {
    // Restore session state from storage
    _sessionId = sessionId;
    _currentSession = await _loadSessionState(sessionId);
  }

  Future<void> saveSession() async {
    if (_currentSession != null && _sessionId != null) {
      await _saveSessionState(_sessionId!, _currentSession!);
    }
  }
}
```

## Performance Optimization

### Resource Management

```dart
class OptimizedSessionManager {
  static const int maxConcurrentSessions = 3;
  final Queue<AgentSession> _sessionPool = Queue();

  Future<AgentSession> getSession() async {
    if (_sessionPool.isNotEmpty) {
      return _sessionPool.removeFirst();
    }

    if (_sessionPool.length < maxConcurrentSessions) {
      return await _createNewSession();
    }

    // Wait for available session
    return await _waitForAvailableSession();
  }

  void returnSession(AgentSession session) {
    if (_sessionPool.length < maxConcurrentSessions) {
      _sessionPool.add(session);
    } else {
      session.close();
    }
  }
}
```

### Memory Management

```dart
// Automatic cleanup of old sessions
Timer.periodic(Duration(minutes: 30), (timer) {
  _cleanupInactiveSessions();
});

void _cleanupInactiveSessions() {
  final now = DateTime.now();
  for (final session in _inactiveSessions) {
    if (now.difference(session.lastActivity) > Duration(hours: 1)) {
      session.close();
      _inactiveSessions.remove(session);
    }
  }
}
```

## Integration with Flutter

### Provider Pattern

```dart
class AgentSessionProvider extends ChangeNotifier {
  AgentSession? _session;

  AgentSession? get session => _session;

  Future<void> initializeSession() async {
    final config = await _loadConfig();
    final agent = VoiceAgent(config: config);
    _session = await agent.createSession();

    _session!.events.listen((event) {
      notifyListeners();
    });

    _session!.state.listen((state) {
      notifyListeners();
    });

    notifyListeners();
  }

  @override
  void dispose() {
    _session?.close();
    super.dispose();
  }
}
```

### Widget Integration

```dart
class SessionStatusWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AgentSessionProvider>(
      builder: (context, provider, child) {
        final session = provider.session;
        if (session == null) return CircularProgressIndicator();

        return StreamBuilder<SessionState>(
          stream: session.state,
          builder: (context, snapshot) {
            final state = snapshot.data;
            return Column(
              children: [
                Text('Status: ${state?.state ?? 'Unknown'}'),
                if (state?.isListening ?? false)
                  Text('Listening...'),
                if (state?.isSpeaking ?? false)
                  Text('Speaking...'),
              ],
            );
          },
        );
      },
    );
  }
}
```

## Testing Sessions

### Mock Sessions

```dart
class MockSession implements AgentSession {
  @override
  Stream<SessionState> get state => _stateController.stream;

  @override
  Stream<AgentEvent> get events => _eventController.stream;

  // Simulate state changes for testing
  void simulateListening() {
    _stateController.add(SessionState(
      state: SessionStatus.listening,
      isListening: true,
      lastActivity: DateTime.now(),
    ));
  }
}
```

### Session Testing Utilities

```dart
class SessionTester {
  static Future<void> testSessionLifecycle(AgentSession session) async {
    // Test state transitions
    await session.startListening();
    assert(session.state.value.state == SessionStatus.listening);

    await session.stopListening();
    assert(session.state.value.state == SessionStatus.idle);

    // Test message sending
    await session.sendMessage('test');
    await session.close();
  }
}
```

## Best Practices

### 1. Proper Cleanup

Always close sessions when done:

```dart
@override
void dispose() {
  _session?.close();
  super.dispose();
}
```

### 2. Error Handling

Handle session errors gracefully:

```dart
session.events.listen((event) {
  if (event is ErrorEvent) {
    _handleSessionError(event.error);
  }
});
```

### 3. State Management

Use streams for reactive state management:

```dart
// Good: Reactive approach
session.state.listen(_updateUI);

// Avoid: Polling approach
// Timer.periodic(Duration(seconds: 1), (_) => _checkState());
```

### 4. Resource Awareness

Be mindful of system resources:

```dart
// Close sessions during app lifecycle changes
@override
void didChangeAppLifecycleState(AppLifecycleState state) {
  if (state == AppLifecycleState.paused) {
    _session?.stopListening();
  } else if (state == AppLifecycleState.resumed) {
    // Resume if needed
  }
}
```

This comprehensive session management system ensures reliable, efficient, and maintainable AI agent interactions in your Flutter applications.
