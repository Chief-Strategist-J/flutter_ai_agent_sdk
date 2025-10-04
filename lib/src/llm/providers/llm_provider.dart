import 'package:flutter_ai_agent_sdk/src/core/models/message.dart';
import 'package:flutter_ai_agent_sdk/src/tools/tool.dart';

/// Response object returned by an [LLMProvider].
///
/// Contains optional [content], optional [toolCalls],
/// and optional [metadata].
class LLMResponse {
  /// Creates a new [LLMResponse].
  LLMResponse({
    this.content,
    this.toolCalls,
    this.metadata,
  });

  /// Generated text content, if available.
  final String? content;

  /// Tool calls suggested by the model, if any.
  final List<ToolCall>? toolCalls;

  /// Optional metadata for custom extensions.
  final Map<String, dynamic>? metadata;
}

/// Abstract base class for all LLM providers.
///
/// Implementations must provide a [name] and support both
/// [generate] and [generateStream].
abstract class LLMProvider {
  /// Display name of the provider.
  String get name;

  /// Generates a single [LLMResponse] from given [messages].
  ///
  /// Optionally uses [tools] and [parameters].
  Future<LLMResponse> generate({
    required final List<Message> messages,
    final List<Tool>? tools,
    final Map<String, dynamic>? parameters,
  });

  /// Generates a stream of [LLMResponse] chunks.
  ///
  /// Supports incremental outputs for streaming responses.
  Stream<LLMResponse> generateStream({
    required final List<Message> messages,
    final List<Tool>? tools,
    final Map<String, dynamic>? parameters,
  });
}
