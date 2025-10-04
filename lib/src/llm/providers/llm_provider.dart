import 'package:flutter_ai_agent_sdk/src/core/models/message.dart';
import 'package:flutter_ai_agent_sdk/src/tools/tool.dart';

class LLMResponse {
  
  LLMResponse({
    this.content,
    this.toolCalls,
    this.metadata,
  });
  final String? content;
  final List<ToolCall>? toolCalls;
  final Map<String, dynamic>? metadata;
}

abstract class LLMProvider {
  String get name;
  
  Future<LLMResponse> generate({
    required final List<Message> messages,
    final List<Tool>? tools,
    final Map<String, dynamic>? parameters,
  });
  
  Stream<LLMResponse> generateStream({
    required final List<Message> messages,
    final List<Tool>? tools,
    final Map<String, dynamic>? parameters,
  });
}
