import 'dart:collection';
import 'package:flutter_ai_agent_sdk/src/core/models/message.dart';

class MemoryStore {
  
  MemoryStore({
    this.shortTermLimit = 10,
    this.longTermLimit = 100,
  });
  final Queue<Message> _shortTermMemory = Queue();
  final List<Message> _longTermMemory = <Message>[];
  final int shortTermLimit;
  final int longTermLimit;
  
  void addToShortTerm(final Message message) {
    _shortTermMemory.add(message);
    if (_shortTermMemory.length > shortTermLimit) {
      final Message old = _shortTermMemory.removeFirst();
      _promoteToLongTerm(old);
    }
  }
  
  void _promoteToLongTerm(final Message message) {
    _longTermMemory.add(message);
    if (_longTermMemory.length > longTermLimit) {
      _longTermMemory.removeAt(0);
    }
  }
  
  List<Message> getShortTerm() => _shortTermMemory.toList();
  List<Message> getLongTerm() => List.unmodifiable(_longTermMemory);
  
  void clear() {
    _shortTermMemory.clear();
    _longTermMemory.clear();
  }
}

