import 'dart:collection' show UnmodifiableListView;
import 'package:flutter_ai_agent_sdk/src/core/models/message.dart';

/// Stores conversation history for an agent.
///
/// Maintains a bounded list of [Message] objects,
/// enforcing a [maxMessages] limit.
class ConversationMemory {
  /// Creates a [ConversationMemory] with an optional
  /// [maxMessages] limit. Defaults to 50.
  ///
  /// Negative values are disallowed.
  ConversationMemory({this.maxMessages = 50}) : assert(maxMessages >= 0);

  /// Maximum number of messages to keep in memory.
  final int maxMessages;

  /// Internal list of stored messages.
  final List<Message> _messages = <Message>[];

  /// Adds a new [message] to memory.
  ///
  /// Removes oldest messages if [maxMessages] is exceeded.
  void addMessage(final Message message) {
    _messages.add(message);

    final int overflow = _messages.length - maxMessages;
    if (overflow > 0) {
      // Remove exactly the overflow count from the front (oldest first).
      _messages.removeRange(0, overflow);
    }
  }

  /// Returns all messages as an unmodifiable view.
  ///
  /// Returned list is a read-only wrapper; internal list cannot be mutated.
  List<Message> getMessages() => UnmodifiableListView<Message>(_messages);

  /// Returns context messages for the LLM.
  ///
  /// Excludes tool messages unless of type [MessageType.toolResult].
  List<Message> getContext() => _messages
      .where(
        (final Message m) =>
            m.role != MessageRole.tool || m.type == MessageType.toolResult,
      )
      .toList(growable: false);

  /// Clears all messages from memory.
  void clear() {
    _messages.clear();
  }

  /// Number of messages currently in memory.
  int get messageCount => _messages.length;
}
