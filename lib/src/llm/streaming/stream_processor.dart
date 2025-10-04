import 'dart:async';
import 'package:flutter_ai_agent_sdk/src/llm/providers/llm_provider.dart';

/// Utility for processing streaming LLM responses.
///
/// Collects [LLMResponse] chunks into a text buffer,
/// exposes a [textStream] of partial text, and a
/// [metadataStream] for metadata updates.
class StreamProcessor {
  /// Internal controller for streaming text output.
  final StreamController<String> _textController =
      StreamController<String>.broadcast();

  /// Internal controller for streaming metadata updates.
  final StreamController<Map<String, dynamic>> _metadataController =
      StreamController<Map<String, dynamic>>.broadcast();

  /// Stream of partial text outputs.
  Stream<String> get textStream => _textController.stream;

  /// Stream of metadata emitted during processing.
  Stream<Map<String, dynamic>> get metadataStream => _metadataController.stream;

  /// Processes a stream of [LLMResponse] objects.
  ///
  /// Aggregates text content into a single string while
  /// emitting partial text and metadata via streams.
  Future<String> processStream(final Stream<LLMResponse> responseStream) async {
    final StringBuffer buffer = StringBuffer();

    await for (final LLMResponse response in responseStream) {
      if (response.content != null) {
        buffer.write(response.content);
        _textController.add(response.content!);
      }
      if (response.metadata != null) {
        _metadataController.add(response.metadata!);
      }
    }

    return buffer.toString();
  }

  /// Disposes the internal stream controllers.
  void dispose() {
    unawaited(_textController.close());
    unawaited(_metadataController.close());
  }
}
