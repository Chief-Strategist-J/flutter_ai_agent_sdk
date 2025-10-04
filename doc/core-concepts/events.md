# Events Documentation

Comprehensive guide to the Flutter AI Agent SDK's event-driven architecture.

## Overview

The event system provides a reactive, decoupled way to handle agent interactions and state changes. It enables loose coupling between components and makes the system more testable and maintainable.

## Event Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        Event System                             │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐              │
│  │ Event Bus   │  │ Event Types │  │ Event Queue │              │
│  └─────────────┘  └─────────────┘  └─────────────┘              │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐              │
│  │ Publishers  │  │ Subscribers │  │ Middleware  │              │
│  └─────────────┘  └─────────────┘  └─────────────┘              │
└─────────────────────────────────────────────────────────────────┘
```

## Event Types

### Core Events

#### MessageReceivedEvent

Fired when the agent receives a message.

```dart
class MessageReceivedEvent extends AgentEvent {
  final Message message;
  final String source; // 'user', 'agent', 'system'

  const MessageReceivedEvent({
    required this.message,
    required DateTime timestamp,
    this.source = 'agent',
  });
}
```

#### SessionStateChangedEvent

Fired when session state changes.

```dart
class SessionStateChangedEvent extends AgentEvent {
  final SessionState oldState;
  final SessionState newState;
  final String reason; // Reason for state change

  const SessionStateChangedEvent({
    required this.oldState,
    required this.newState,
    required DateTime timestamp,
    this.reason = 'unknown',
  });
}
```

## Using Events

### Basic Event Listening

```dart
class EventListener {
  final AgentSession _session;

  void startListening() {
    // Listen to all events
    _session.events.listen((event) {
      _handleEvent(event);
    });

    // Listen to specific event types
    _session.events
        .where((event) => event is MessageReceivedEvent)
        .cast<MessageReceivedEvent>()
        .listen((event) {
          _handleMessageReceived(event);
        });
  }

  void _handleEvent(AgentEvent event) {
    print('Event: ${event.runtimeType} at ${event.timestamp}');
  }

  void _handleMessageReceived(MessageReceivedEvent event) {
    print('Message: ${event.message.content}');
    // Update UI, save to database, etc.
  }
}
```

This event system provides a robust foundation for building reactive, maintainable AI agent applications.
