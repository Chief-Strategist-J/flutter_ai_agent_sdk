import 'package:flutter_ai_agent_sdk/flutter_ai_agent_sdk.dart';
import 'package:flutter_test/flutter_test.dart';

class MockLLMProvider extends LLMProvider {
  @override
  String get name => 'Mock';

  @override
  Future<LLMResponse> generate({
    required final List<Message> messages,
    final List<Tool>? tools,
    final Map<String, dynamic>? parameters,
  }) async =>
      LLMResponse(content: 'Mock response');

  @override
  Stream<LLMResponse> generateStream({
    required final List<Message> messages,
    final List<Tool>? tools,
    final Map<String, dynamic>? parameters,
  }) async* {
    yield LLMResponse(content: 'Mock');
  }
}

void main() {
  group('AgentConfig', () {
    test('should have all required fields', () {
      final MockLLMProvider llmProvider = MockLLMProvider();

      final AgentConfig config = AgentConfig(
        name: 'Test Agent',
        llmProvider: llmProvider,
      );

      expect(config.name, 'Test Agent');
      expect(config.llmProvider, isNotNull);
      expect(config.turnDetection, isNotNull);
      expect(config.tools, isEmpty);
      expect(config.maxHistoryMessages, 50);
      expect(config.enableMemory, true);
    });

    test('should support copyWith', () {
      final MockLLMProvider llmProvider = MockLLMProvider();

      final AgentConfig config = AgentConfig(
        name: 'Test Agent',
        llmProvider: llmProvider,
      );

      final AgentConfig updated = config.copyWith(name: 'Updated Agent');

      expect(updated.name, 'Updated Agent');
      expect(updated.llmProvider, llmProvider);
    });
  });

  group('TurnDetectionConfig', () {
    test('should have all required fields with defaults', () {
      const TurnDetectionConfig config = TurnDetectionConfig();

      expect(config.mode, TurnDetectionMode.vad);
      expect(config.silenceThreshold, const Duration(milliseconds: 700));
      expect(config.minSpeechDuration, const Duration(milliseconds: 300));
      expect(config.vadThreshold, 0.5);
    });

    test('should allow custom values', () {
      const TurnDetectionConfig config = TurnDetectionConfig(
        mode: TurnDetectionMode.pushToTalk,
        silenceThreshold: Duration(seconds: 1),
        minSpeechDuration: Duration(milliseconds: 500),
        vadThreshold: 0.7,
      );

      expect(config.mode, TurnDetectionMode.pushToTalk);
      expect(config.silenceThreshold, const Duration(seconds: 1));
      expect(config.minSpeechDuration, const Duration(milliseconds: 500));
      expect(config.vadThreshold, 0.7);
    });
  });
}
