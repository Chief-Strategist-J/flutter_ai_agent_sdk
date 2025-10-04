import 'package:flutter_ai_agent_sdk/src/core/models/message.dart';

class ChatContext {
  ChatContext({
    required this.messages,
    this.systemPrompt,
    this.metadata,
  });
  final List<Message> messages;
  final String? systemPrompt;
  final Map<String, dynamic>? metadata;

  List<Message> getMessages({final int? limit}) {
    if (limit == null || limit >= messages.length) {
      return List.unmodifiable(messages);
    }
    return List.unmodifiable(messages.sublist(messages.length - limit));
  }

  ChatContext addMessage(final Message message) => ChatContext(
        messages: [...messages, message],
        systemPrompt: systemPrompt,
        metadata: metadata,
      );

  ChatContext withSystemPrompt(final String prompt) => ChatContext(
        messages: messages,
        systemPrompt: prompt,
        metadata: metadata,
      );

  int get messageCount => messages.length;

  Message? get lastMessage => messages.isNotEmpty ? messages.last : null;
}
