import 'dart:async';
import 'package:flutter_ai_agent_sdk/src/llm/providers/llm_provider.dart';

class StreamProcessor {
  final StreamController<String> _textController = StreamController<String>.broadcast();
  final StreamController<Map<String, dynamic>> _metadataController = 
      StreamController<Map<String, dynamic>>.broadcast();
  
  Stream<String> get textStream => _textController.stream;
  Stream<Map<String, dynamic>> get metadataStream => _metadataController.stream;
  
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
  
  void dispose() {
    _textController.close();
    _metadataController.close();
  }
}
