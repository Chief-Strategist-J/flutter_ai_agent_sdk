import 'package:flutter_ai_agent_sdk/src/core/models/message.dart';

/// Base class for all agent events.
///
/// Each [AgentEvent] has a [timestamp] indicating when it occurred.
/// Subclasses represent specific lifecycle, speech, message, tool,
/// or error events.
abstract class AgentEvent {
  /// Creates a new event with the current [DateTime.now].
  AgentEvent() : timestamp = DateTime.now();

  /// Time when the event was created.
  final DateTime timestamp;
}

/// Event emitted when the agent starts.
class AgentStartedEvent extends AgentEvent {
  /// Creates an [AgentStartedEvent].
  AgentStartedEvent();
}

/// Event emitted when the agent stops.
class AgentStoppedEvent extends AgentEvent {
  /// Creates an [AgentStoppedEvent].
  AgentStoppedEvent();
}

/// Event emitted when user speech input begins.
class UserSpeechStartedEvent extends AgentEvent {
  /// Creates a [UserSpeechStartedEvent].
  UserSpeechStartedEvent();
}

/// Event emitted when user speech input ends.
///
/// Contains the final [transcript] text.
class UserSpeechEndedEvent extends AgentEvent {
  /// Creates a [UserSpeechEndedEvent] with the given [transcript].
  UserSpeechEndedEvent(this.transcript);

  /// Transcribed text from the user’s speech.
  final String transcript;
}

/// Event emitted when the agent begins speaking.
class AgentSpeechStartedEvent extends AgentEvent {
  /// Creates an [AgentSpeechStartedEvent].
  AgentSpeechStartedEvent();
}

/// Event emitted when the agent finishes speaking.
class AgentSpeechEndedEvent extends AgentEvent {
  /// Creates an [AgentSpeechEndedEvent].
  AgentSpeechEndedEvent();
}

/// Event emitted when a message is received.
///
/// Contains the received [message].
class MessageReceivedEvent extends AgentEvent {
  /// Creates a [MessageReceivedEvent] with the given [message].
  MessageReceivedEvent(this.message);

  /// The received message object.
  final Message message;
}

/// Event emitted when a message is sent.
///
/// Contains the outgoing [message].
class MessageSentEvent extends AgentEvent {
  /// Creates a [MessageSentEvent] with the given [message].
  MessageSentEvent(this.message);

  /// The sent message object.
  final Message message;
}

/// Event emitted when a tool call starts.
///
/// Provides [toolName] and input [arguments].
class ToolCallStartedEvent extends AgentEvent {
  /// Creates a [ToolCallStartedEvent] with [toolName] and [arguments].
  ToolCallStartedEvent(this.toolName, this.arguments);

  /// The tool being called.
  final String toolName;

  /// Arguments passed to the tool.
  final Map<String, dynamic> arguments;
}

/// Event emitted when a tool call completes.
///
/// Provides [toolName] and returned [result].
class ToolCallCompletedEvent extends AgentEvent {
  /// Creates a [ToolCallCompletedEvent] with [toolName] and [result].
  ToolCallCompletedEvent(this.toolName, this.result);

  /// The tool that completed execution.
  final String toolName;

  /// Result returned by the tool.
  final dynamic result;
}

/// Event emitted when an error occurs.
///
/// Includes [error] message and optional [stackTrace].
class ErrorEvent extends AgentEvent {
  /// Creates an [ErrorEvent] with [error] and optional [stackTrace].
  ErrorEvent(this.error, [this.stackTrace]);

  /// Description of the error.
  final String error;

  /// Optional stack trace for debugging.
  final StackTrace? stackTrace;
}

/// Event emitted for streaming text updates.
///
/// [text] contains partial output, with [isComplete] marking
/// the final chunk.
class StreamingTextEvent extends AgentEvent {
  /// Creates a [StreamingTextEvent] with [text].
  ///
  /// Optionally marks completion with [isComplete].
  StreamingTextEvent(this.text, {this.isComplete = false});

  /// Partial or final text output.
  final String text;

  /// Whether this is the final text chunk.
  final bool isComplete;
}
