import 'package:flutter_ai_agent_sdk/src/core/models/message.dart';

/// Represents the conversation context for the agent.
///
/// Stores a list of [Message] objects, an optional
/// [systemPrompt], and optional [metadata].
class ChatContext {
  /// Creates a new [ChatContext].
  ChatContext({
    required this.messages,
    this.systemPrompt,
    this.metadata,
  });

  /// List of messages in the conversation.
  final List<Message> messages;

  /// Optional system prompt for guiding responses.
  final String? systemPrompt;

  /// Optional metadata for extensions or logging.
  final Map<String, dynamic>? metadata;

  /// Returns messages, optionally limited to the last [limit].
  ///
  /// If [limit] is null or larger than the total messages,
  /// all messages are returned.
  List<Message> getMessages({final int? limit}) {
    if (limit == null || limit >= messages.length) {
      return List<Message>.unmodifiable(messages);
    }
    return List<Message>.unmodifiable(
      messages.sublist(messages.length - limit),
    );
  }

  /// Returns a new [ChatContext] with [message] added.
  ChatContext addMessage(final Message message) => ChatContext(
        messages: <Message>[...messages, message],
        systemPrompt: systemPrompt,
        metadata: metadata,
      );

  /// Returns a new [ChatContext] with a new [systemPrompt].
  ChatContext withSystemPrompt(final String prompt) => ChatContext(
        messages: messages,
        systemPrompt: prompt,
        metadata: metadata,
      );

  /// Number of messages in the context.
  int get messageCount => messages.length;

  /// The last message in the context, or null if empty.
  Message? get lastMessage => messages.isNotEmpty ? messages.last : null;
}
