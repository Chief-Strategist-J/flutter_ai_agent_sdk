import 'package:flutter_ai_agent_sdk/src/core/models/message.dart';

class ConversationMemory {
  
  ConversationMemory({this.maxMessages = 50});
  final int maxMessages;
  final List<Message> _messages = <Message>[];
  
  void addMessage(final Message message) {
    _messages.add(message);
    
    // Keep only recent messages
    if (_messages.length > maxMessages) {
      _messages.removeRange(0, _messages.length - maxMessages);
    }
  }
  
  List<Message> getMessages() => List.unmodifiable(_messages);
  
  List<Message> getContext() => _messages.where((m) => 
      m.role != MessageRole.tool || m.type == MessageType.toolResult
    ).toList();
  
  void clear() {
    _messages.clear();
  }
  
  int get messageCount => _messages.length;
}
