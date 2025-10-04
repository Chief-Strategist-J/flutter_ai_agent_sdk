import 'package:flutter_ai_agent_sdk/src/core/models/turn_detection.dart';
import 'package:flutter_ai_agent_sdk/src/llm/providers/llm_provider.dart';
import 'package:flutter_ai_agent_sdk/src/tools/tool.dart';
import 'package:flutter_ai_agent_sdk/src/voice/stt/speech_recognition_service.dart';
import 'package:flutter_ai_agent_sdk/src/voice/tts/text_to_speech_service.dart';

/// Defines configuration options for an AI Agent.
///
/// Provides model provider, speech services, tool integration,
/// memory behavior, and metadata. Immutable.
class AgentConfig {
  /// Creates a new [AgentConfig].
  ///
  /// [name] and [llmProvider] are required.
  ///
  /// Defaults:
  /// - [turnDetection]: [TurnDetectionConfig]
  /// - [tools]: empty list
  /// - [maxHistoryMessages]: 50
  /// - [enableMemory]: true
  const AgentConfig({
    required this.name,
    this.instructions,
    required this.llmProvider,
    this.sttService,
    this.ttsService,
    this.turnDetection = const TurnDetectionConfig(),
    this.tools = const <Tool>[],
    this.maxHistoryMessages = 50,
    this.enableMemory = true,
    this.metadata,
  });

  /// Unique identifier or agent name.
  final String name;

  /// Optional system instructions or persona definition.
  final String? instructions;

  /// Provider for language model requests.
  final LLMProvider llmProvider;

  /// Optional speech-to-text service for audio input.
  final SpeechRecognitionService? sttService;

  /// Optional text-to-speech service for voice output.
  final TextToSpeechService? ttsService;

  /// Config for detecting user and agent turns.
  final TurnDetectionConfig turnDetection;

  /// List of callable tools or APIs the agent can use.
  final List<Tool> tools;

  /// Max number of past messages kept in history.
  final int maxHistoryMessages;

  /// Enables or disables agent memory across turns.
  final bool enableMemory;

  /// Custom key-value metadata for logging or extensions.
  final Map<String, dynamic>? metadata;

  /// Returns a copy of this config with updated values.
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
