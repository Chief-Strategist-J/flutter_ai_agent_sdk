import 'package:json_annotation/json_annotation.dart';

part 'message.g.dart';

enum MessageRole {
  user,
  assistant,
  system,
  tool,
}

enum MessageType {
  text,
  audio,
  toolCall,
  toolResult,
}

@JsonSerializable()
class Message {
  Message({
    required this.id,
    required this.role,
    required this.type,
    required this.content,
    this.metadata,
    DateTime? timestamp,
    this.toolCalls,
    this.audioUrl,
  }) : timestamp = timestamp ?? DateTime.now();

  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);
  final String id;
  final MessageRole role;
  final MessageType type;
  final String content;
  final Map<String, dynamic>? metadata;
  final DateTime timestamp;
  final List<ToolCall>? toolCalls;
  final String? audioUrl;
  Map<String, dynamic> toJson() => _$MessageToJson(this);

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

@JsonSerializable()
class ToolCall {
  ToolCall({
    required this.id,
    required this.name,
    required this.arguments,
  });

  factory ToolCall.fromJson(Map<String, dynamic> json) =>
      _$ToolCallFromJson(json);
  final String id;
  final String name;
  final Map<String, dynamic> arguments;
  Map<String, dynamic> toJson() => _$ToolCallToJson(this);
}
