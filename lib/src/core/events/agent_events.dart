import 'package:flutter_ai_agent_sdk/src/core/models/message.dart';

abstract class AgentEvent {
  AgentEvent() : timestamp = DateTime.now();
  final DateTime timestamp;
}

class AgentStartedEvent extends AgentEvent {}

class AgentStoppedEvent extends AgentEvent {}

class UserSpeechStartedEvent extends AgentEvent {}

class UserSpeechEndedEvent extends AgentEvent {
  UserSpeechEndedEvent(this.transcript);
  final String transcript;
}

class AgentSpeechStartedEvent extends AgentEvent {}

class AgentSpeechEndedEvent extends AgentEvent {}

class MessageReceivedEvent extends AgentEvent {
  MessageReceivedEvent(this.message);
  final Message message;
}

class MessageSentEvent extends AgentEvent {
  MessageSentEvent(this.message);
  final Message message;
}

class ToolCallStartedEvent extends AgentEvent {
  ToolCallStartedEvent(this.toolName, this.arguments);
  final String toolName;
  final Map<String, dynamic> arguments;
}

class ToolCallCompletedEvent extends AgentEvent {
  ToolCallCompletedEvent(this.toolName, this.result);
  final String toolName;
  final dynamic result;
}

class ErrorEvent extends AgentEvent {
  ErrorEvent(this.error, [this.stackTrace]);
  final String error;
  final StackTrace? stackTrace;
}

class StreamingTextEvent extends AgentEvent {
  StreamingTextEvent(this.text, {this.isComplete = false});
  final String text;
  final bool isComplete;
}
