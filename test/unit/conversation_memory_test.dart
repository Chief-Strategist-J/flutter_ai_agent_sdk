import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ai_agent_sdk/flutter_ai_agent_sdk.dart';

void main() {
  group('ConversationMemory', () {
    test('should have all required fields', () {
      final ConversationMemory memory = ConversationMemory();

      expect(memory.maxMessages, 50);
      expect(memory.messageCount, 0);
    });

    test('should add messages', () {
      final ConversationMemory memory = ConversationMemory();

      final Message message = Message(
        id: 'test-id',
        role: MessageRole.user,
        type: MessageType.text,
        content: 'Test',
      );

      memory.addMessage(message);

      expect(memory.messageCount, 1);
      expect(memory.getMessages().first, message);
    });

    test('should respect max messages limit', () {
      final ConversationMemory memory = ConversationMemory(maxMessages: 2);

      for (int i = 0; i < 5; i++) {
        memory.addMessage(
          Message(
            id: 'id-$i',
            role: MessageRole.user,
            type: MessageType.text,
            content: 'Message $i',
          ),
        );
      }

      expect(memory.messageCount, 2);
      expect(memory.getMessages().last.content, 'Message 4');
    });

    test('should clear messages', () {
      final ConversationMemory memory = ConversationMemory();

      memory.addMessage(
        Message(
          id: 'test-id',
          role: MessageRole.user,
          type: MessageType.text,
          content: 'Test',
        ),
      );

      expect(memory.messageCount, 1);

      memory.clear();

      expect(memory.messageCount, 0);
    });
  });
}
