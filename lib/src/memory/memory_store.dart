import 'dart:collection';
import 'package:flutter_ai_agent_sdk/src/core/models/message.dart';

/// Stores short-term and long-term memory for messages.
///
/// Uses a queue for short-term memory with promotion
/// to long-term storage when limits are exceeded.
class MemoryStore {
  /// Creates a [MemoryStore] with optional limits.
  ///
  /// - [shortTermLimit]: Defaults to 10.
  /// - [longTermLimit]: Defaults to 100.
  ///
  /// Negative limits are disallowed.
  MemoryStore({
    this.shortTermLimit = 10,
    this.longTermLimit = 100,
  })  : assert(shortTermLimit >= 0, 'shortTermLimit must be >= 0'),
        assert(longTermLimit >= 0, 'longTermLimit must be >= 0');

  /// Queue holding short-term memory messages.
  final Queue<Message> _shortTermMemory = Queue<Message>();

  /// List holding long-term memory messages.
  final List<Message> _longTermMemory = <Message>[];

  /// Maximum short-term memory size.
  final int shortTermLimit;

  /// Maximum long-term memory size.
  final int longTermLimit;

  /// Adds a [message] to short-term memory.
  ///
  /// If the limit is exceeded, the oldest message is
  /// promoted to long-term memory.
  void addToShortTerm(final Message message) {
    _shortTermMemory.add(message);

    if (_shortTermMemory.length > shortTermLimit) {
      final Message old = _shortTermMemory.removeFirst();
      _promoteToLongTerm(old);
    }
  }

  /// Promotes a [message] to long-term memory.
  ///
  /// Removes the oldest entry if the limit is exceeded.
  void _promoteToLongTerm(final Message message) {
    _longTermMemory.add(message);

    if (_longTermMemory.length > longTermLimit) {
      // remove oldest
      _longTermMemory.removeAt(0);
    }
  }

  /// Returns the current short-term memory.
  ///
  /// Note: returns a copy; mutations won’t affect internal queue.
  List<Message> getShortTerm() => _shortTermMemory.toList();

  /// Returns the current long-term memory (unmodifiable view).
  List<Message> getLongTerm() => List<Message>.unmodifiable(_longTermMemory);

  /// Clears both short-term and long-term memory.
  void clear() {
    _shortTermMemory.clear();
    _longTermMemory.clear();
  }
}
