import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import 'package:flutter_ai_agent_sdk/src/llm/providers/llm_provider.dart';
import 'package:flutter_ai_agent_sdk/src/core/models/message.dart';
import 'package:flutter_ai_agent_sdk/src/tools/tool.dart';
import 'package:flutter_ai_agent_sdk/src/utils/logger.dart';

class AnthropicProvider extends LLMProvider {
  
  AnthropicProvider({
    required this.apiKey,
    this.model = 'claude-3-sonnet-20240229',
    this.baseUrl = 'https://api.anthropic.com/v1',
  });
  final String apiKey;
  final String model;
  final String baseUrl;
  
  @override
  String get name => 'Anthropic';
  
  @override
  Future<LLMResponse> generate({
    required final List<Message> messages,
    final List<Tool>? tools,
    final Map<String, dynamic>? parameters,
  }) async {
    try {
      final http.Response response = await http.post(
        Uri.parse('$baseUrl/messages'),
        headers: <String, String>{
          'x-api-key': apiKey,
          'anthropic-version': '2023-06-01',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, dynamic>{
          'model': model,
          'messages': messages.map(_messageToJson).toList(),
          'max_tokens': parameters?['max_tokens'] ?? 4096,
          if (tools != null && tools.isNotEmpty)
            'tools': tools.map(_toolToAnthropicFormat).toList(),
          ...?parameters,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return _parseResponse(data);
      } else {
        throw Exception('Anthropic API error: ${response.statusCode}');
      }
    } catch (e, stack) {
      AgentLogger.error('Anthropic generate failed', e, stack);
      rethrow;
    }
  }
  
  @override
  Stream<LLMResponse> generateStream({
    required final List<Message> messages,
    final List<Tool>? tools,
    final Map<String, dynamic>? parameters,
  }) async* {
    try {
      final http.Request request = http.Request(
        'POST',
        Uri.parse('$baseUrl/messages'),
      );
      
      request.headers.addAll(<String, String>{
        'x-api-key': apiKey,
        'anthropic-version': '2023-06-01',
        'Content-Type': 'application/json',
      });
      
      request.body = jsonEncode(<String, dynamic>{
        'model': model,
        'messages': messages.map(_messageToJson).toList(),
        'max_tokens': parameters?['max_tokens'] ?? 4096,
        'stream': true,
        if (tools != null && tools.isNotEmpty)
          'tools': tools.map(_toolToAnthropicFormat).toList(),
        ...?parameters,
      });
      
      final http.StreamedResponse streamedResponse = await request.send();
      final StringBuffer buffer = StringBuffer();
      
      await for (final String chunk in streamedResponse.stream.transform(utf8.decoder)) {
        final List<String> lines = chunk.split('\n');
        for (final String line in lines) {
          if (line.startsWith('data: ')) {
            final String jsonStr = line.substring(6);
            try {
              final data = jsonDecode(jsonStr);
              if (data['type'] == 'content_block_delta') {
                final delta = data['delta'];
                if (delta['type'] == 'text_delta') {
                  final text = delta['text'];
                  buffer.write(text);
                  yield LLMResponse(content: text);
                }
              }
            } catch (e) {
              continue;
            }
          }
        }
      }
    } catch (e, stack) {
      AgentLogger.error('Anthropic stream failed', e, stack);
      rethrow;
    }
  }
  
  Map<String, dynamic> _messageToJson(final Message message) => {
      'role': message.role == MessageRole.assistant ? 'assistant' : 'user',
      'content': message.content,
    };
  
  Map<String, dynamic> _toolToAnthropicFormat(final Tool tool) => {
      'name': tool.name,
      'description': tool.description,
      'input_schema': tool.parameters,
    };
  
  LLMResponse _parseResponse(final Map<String, dynamic> data) {
    final content = data['content'];
    String? textContent;
    
    if (content is List && content.isNotEmpty) {
      final firstBlock = content[0];
      if (firstBlock['type'] == 'text') {
        textContent = firstBlock['text'];
      }
    }
    
    return LLMResponse(
      content: textContent,
    );
  }
}
