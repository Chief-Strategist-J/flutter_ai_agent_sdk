import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import 'package:flutter_ai_agent_sdk/src/llm/providers/llm_provider.dart';
import 'package:flutter_ai_agent_sdk/src/core/models/message.dart';
import 'package:flutter_ai_agent_sdk/src/tools/tool.dart';
import 'package:flutter_ai_agent_sdk/src/utils/logger.dart';

class OpenAIProvider extends LLMProvider {
  OpenAIProvider({
    required this.apiKey,
    this.model = 'gpt-4-turbo-preview',
    this.baseUrl = 'https://api.openai.com/v1',
  });
  final String apiKey;
  final String model;
  final String baseUrl;

  @override
  String get name => 'OpenAI';

  @override
  Future<LLMResponse> generate({
    required final List<Message> messages,
    final List<Tool>? tools,
    final Map<String, dynamic>? parameters,
  }) async {
    try {
      final http.Response response = await http.post(
        Uri.parse('$baseUrl/chat/completions'),
        headers: <String, String>{
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, dynamic>{
          'model': model,
          'messages': messages.map(_messageToJson).toList(),
          if (tools != null && tools.isNotEmpty)
            'tools': tools.map((final Tool t) => t.toJson()).toList(),
          ...?parameters,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return _parseResponse(data);
      } else {
        throw Exception('OpenAI API error: ${response.statusCode}');
      }
    } catch (e, stack) {
      AgentLogger.error('OpenAI generate failed', e, stack);
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
        Uri.parse('$baseUrl/chat/completions'),
      );

      request.headers.addAll(<String, String>{
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      });

      request.body = jsonEncode(<String, dynamic>{
        'model': model,
        'messages': messages.map(_messageToJson).toList(),
        'stream': true,
        if (tools != null && tools.isNotEmpty)
          'tools': tools.map((final Tool t) => t.toJson()).toList(),
        ...?parameters,
      });

      final http.StreamedResponse streamedResponse = await request.send();

      await for (final String chunk
          in streamedResponse.stream.transform(utf8.decoder)) {
        final List<String> lines = chunk.split('\n');
        for (final String line in lines) {
          if (line.startsWith('data: ') && line != 'data: [DONE]') {
            final String jsonStr = line.substring(6);
            try {
              final data = jsonDecode(jsonStr);
              final delta = data['choices']?[0]?['delta'];
              if (delta != null) {
                yield LLMResponse(
                  content: delta['content'],
                  toolCalls: _parseToolCalls(delta['tool_calls']),
                );
              }
            } catch (e) {
              // Skip malformed chunks
              continue;
            }
          }
        }
      }
    } catch (e, stack) {
      AgentLogger.error('OpenAI stream failed', e, stack);
      rethrow;
    }
  }

  Map<String, dynamic> _messageToJson(final Message message) => {
        'role': message.role.name,
        'content': message.content,
      };

  LLMResponse _parseResponse(final Map<String, dynamic> data) {
    final choice = data['choices']?[0];
    final message = choice?['message'];

    return LLMResponse(
      content: message?['content'],
      toolCalls: _parseToolCalls(message?['tool_calls']),
    );
  }

  List<ToolCall>? _parseToolCalls(final dynamic toolCallsJson) {
    if (toolCallsJson == null) return null;

    return (toolCallsJson as List)
        .map((final tc) => ToolCall(
              id: tc['id'] ?? const Uuid().v4(),
              name: tc['function']['name'],
              arguments: jsonDecode(tc['function']['arguments']),
            ))
        .toList();
  }
}
