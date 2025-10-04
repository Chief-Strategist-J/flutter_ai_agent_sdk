import 'package:flutter_ai_agent_sdk/src/core/models/turn_detection.dart';
import 'package:flutter_ai_agent_sdk/src/llm/providers/llm_provider.dart';
import 'package:flutter_ai_agent_sdk/src/tools/tool.dart';
import 'package:flutter_ai_agent_sdk/src/voice/stt/speech_recognition_service.dart';
import 'package:flutter_ai_agent_sdk/src/voice/tts/text_to_speech_service.dart';

class AgentConfig {
  const AgentConfig({
    required this.name,
    this.instructions,
    required this.llmProvider,
    this.sttService,
    this.ttsService,
    this.turnDetection = const TurnDetectionConfig(),
    this.tools = const [],
    this.maxHistoryMessages = 50,
    this.enableMemory = true,
    this.metadata,
  });
  final String name;
  final String? instructions;
  final LLMProvider llmProvider;
  final SpeechRecognitionService? sttService;
  final TextToSpeechService? ttsService;
  final TurnDetectionConfig turnDetection;
  final List<Tool> tools;
  final int maxHistoryMessages;
  final bool enableMemory;
  final Map<String, dynamic>? metadata;

  AgentConfig copyWith({
    final String? name,
    final String? instructions,
    final LLMProvider? llmProvider,
    final SpeechRecognitionService? sttService,
    final TextToSpeechService? ttsService,
    final TurnDetectionConfig? turnDetection,
    final List<Tool>? tools,
    final int? maxHistoryMessages,
    final bool? enableMemory,
    final Map<String, dynamic>? metadata,
  }) =>
      AgentConfig(
        name: name ?? this.name,
        instructions: instructions ?? this.instructions,
        llmProvider: llmProvider ?? this.llmProvider,
        sttService: sttService ?? this.sttService,
        ttsService: ttsService ?? this.ttsService,
        turnDetection: turnDetection ?? this.turnDetection,
        tools: tools ?? this.tools,
        maxHistoryMessages: maxHistoryMessages ?? this.maxHistoryMessages,
        enableMemory: enableMemory ?? this.enableMemory,
        metadata: metadata ?? this.metadata,
      );
}
