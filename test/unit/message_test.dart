import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ai_agent_sdk/flutter_ai_agent_sdk.dart';

void main() {
  group('Message', () {
    test('should have all required fields', () {
      final Message message = Message(
        id: 'test-id',
        role: MessageRole.user,
        type: MessageType.text,
        content: 'Test message',
      );

      expect(message.id, 'test-id');
      expect(message.role, MessageRole.user);
      expect(message.type, MessageType.text);
      expect(message.content, 'Test message');
      expect(message.timestamp, isNotNull);
    });

    test('should support copyWith', () {
      final Message message = Message(
        id: 'test-id',
        role: MessageRole.user,
        type: MessageType.text,
        content: 'Test message',
      );

      final Message copied = message.copyWith(content: 'Updated message');

      expect(copied.id, 'test-id');
      expect(copied.content, 'Updated message');
    });
  });

  group('ToolCall', () {
    test('should have all required fields', () {
      final ToolCall toolCall = ToolCall(
        id: 'tool-id',
        name: 'test_tool',
        arguments: <String, dynamic>{'param': 'value'},
      );

      expect(toolCall.id, 'tool-id');
      expect(toolCall.name, 'test_tool');
      expect(toolCall.arguments, <String, String>{'param': 'value'});
    });
  });
}
