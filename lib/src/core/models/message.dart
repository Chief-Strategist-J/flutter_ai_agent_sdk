import 'package:json_annotation/json_annotation.dart';

part 'message.g.dart';

/// Role of a [Message] in the conversation.
enum MessageRole {
  /// - [user]: Message authored by the user.
  user,

  /// - [assistant]: Message authored by the agent/LLM.
  assistant,

  /// - [system]: Instructional system message (persona, context).
  system,

  /// - [tool]: Message created by a tool invocation.
  tool,
}

/// Type of [Message] content.

enum MessageType {
  /// - [text]: Plain text message.
  text,

  /// - [audio]: Audio message with a URL.
  audio,

  /// - [toolCall]: Represents a tool request.
  toolCall,

  /// - [toolResult]: Represents the result of a tool call.
  toolResult,
}

/// Represents a single conversation message.
///
/// A [Message] can be authored by the user, assistant,
/// system, or a tool. It supports text, audio, and tool
/// call content.
@JsonSerializable()
class Message {
  /// Creates a new [Message].
  ///
  /// If [timestamp] is not provided, the current time is
  /// used by default.
  Message({
    required this.id,
    required this.role,
    required this.type,
    required this.content,
    this.metadata,
    final DateTime? timestamp,
    this.toolCalls,
    this.audioUrl,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Creates a [Message] instance from JSON.
  factory Message.fromJson(final Map<String, dynamic> json) =>
      _$MessageFromJson(json);

  /// Unique identifier for the message.
  final String id;

  /// Role of the message sender.
  final MessageRole role;

  /// Type of message content.
  final MessageType type;

  /// Text content of the message.
  final String content;

  /// Optional metadata for extensions or logging.
  final Map<String, dynamic>? metadata;

  /// Time when the message was created.
  final DateTime timestamp;

  /// List of tool calls included in the message.
  final List<ToolCall>? toolCalls;

  /// Optional audio file URL if this is an audio message.
  final String? audioUrl;

  /// Converts this message to JSON.
  Map<String, dynamic> toJson() => _$MessageToJson(this);

  /// Returns a copy of this message with updated fields.
  Message copyWith({
    final String? id,
    final MessageRole? role,
    final MessageType? type,
    final String? content,
    final Map<String, dynamic>? metadata,
    final DateTime? timestamp,
    final List<ToolCall>? toolCalls,
    final String? audioUrl,
  }) =>
      Message(
        id: id ?? this.id,
        role: role ?? this.role,
        type: type ?? this.type,
        content: content ?? this.content,
        metadata: metadata ?? this.metadata,
        timestamp: timestamp ?? this.timestamp,
        toolCalls: toolCalls ?? this.toolCalls,
        audioUrl: audioUrl ?? this.audioUrl,
      );
}

/// Represents a single tool invocation within a [Message].
@JsonSerializable()
class ToolCall {
  /// Creates a new [ToolCall].
  ToolCall({
    required this.id,
    required this.name,
    required this.arguments,
  });

  /// Creates a [ToolCall] instance from JSON.
  factory ToolCall.fromJson(final Map<String, dynamic> json) =>
      _$ToolCallFromJson(json);

  /// Unique identifier for the tool call.
  final String id;

  /// Name of the tool being invoked.
  final String name;

  /// Arguments passed to the tool.
  final Map<String, dynamic> arguments;

  /// Converts this tool call to JSON.
  Map<String, dynamic> toJson() => _$ToolCallToJson(this);
}
