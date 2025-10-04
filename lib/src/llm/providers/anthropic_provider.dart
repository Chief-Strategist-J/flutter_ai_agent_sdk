import 'dart:convert';

import 'package:flutter_ai_agent_sdk/src/core/models/message.dart';
import 'package:flutter_ai_agent_sdk/src/llm/providers/llm_provider.dart';
import 'package:flutter_ai_agent_sdk/src/tools/tool.dart';
import 'package:flutter_ai_agent_sdk/src/utils/logger.dart';
import 'package:http/http.dart' as http;

/// LLM provider for Anthropic Claude models.
///
/// Supports both single response generation via [generate]
/// and streaming responses via [generateStream].
class AnthropicProvider extends LLMProvider {
  /// Creates an [AnthropicProvider].
  ///
  /// - [apiKey]: Required Anthropic API key.
  /// - [model]: Defaults to `claude-3-sonnet-20240229`.
  /// - [baseUrl]: Defaults to `https://api.anthropic.com/v1`.
  AnthropicProvider({
    required this.apiKey,
    this.model = 'claude-3-sonnet-20240229',
    this.baseUrl = 'https://api.anthropic.com/v1',
  });

  /// Anthropic API key.
  final String apiKey;

  /// Model identifier to use.
  final String model;

  /// Base URL for Anthropic API requests.
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
        final dynamic data = jsonDecode(response.body);
        return _parseResponse(data as Map<String, dynamic>);
      } else {
        throw Exception(
          'Anthropic API error: ${response.statusCode} - ${response.body}',
        );
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

      // Build a strictly-typed JSON body.
      final Map<String, Object?> body = <String, Object?>{
        'model': model,
        'messages': messages
            .map((final Message m) => _messageToJson(m) as Map<String, Object?>)
            .toList(growable: false),
        'max_tokens': (parameters?['max_tokens'] as int?) ?? 4096,
        'stream': true,
      };

      if (tools != null && tools.isNotEmpty) {
        body['tools'] = tools
            .map(
              (final Tool t) =>
                  _toolToAnthropicFormat(t) as Map<String, Object?>,
            )
            .toList(growable: false);
      }

      if (parameters != null && parameters.isNotEmpty) {
        // Safely widen Map<String, dynamic> -> Map<String, Object?> for addAll.
        body.addAll(
          parameters.map<String, Object?>(
            MapEntry<String, Object?>.new,
          ),
        );
      }

      request.body = jsonEncode(body);

      final http.StreamedResponse streamedResponse = await request.send();
      final StringBuffer buffer = StringBuffer();

      await for (final String chunk
          in streamedResponse.stream.transform(utf8.decoder)) {
        final List<String> lines = chunk.split('\n');
        for (final String line in lines) {
          if (line.startsWith('data: ')) {
            final String jsonStr = line.substring(6);
            try {
              final Object? decoded = jsonDecode(jsonStr);

              if (decoded is Map<String, dynamic>) {
                final String? type = decoded['type'] as String?;
                if (type == 'content_block_delta') {
                  final Object? deltaObj = decoded['delta'];
                  if (deltaObj is Map<String, dynamic>) {
                    final String? deltaType = deltaObj['type'] as String?;
                    if (deltaType == 'text_delta') {
                      final String? text = deltaObj['text'] as String?;
                      if (text != null) {
                        buffer.write(text);
                        yield LLMResponse(content: text);
                      }
                    }
                  }
                }
              }
            } catch (_) {
              // Ignore non-JSON lines like [DONE] or partial frames.
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

  /// Converts a [Message] to Anthropic API format.
  Map<String, dynamic> _messageToJson(final Message message) =>
      <String, dynamic>{
        'role': message.role == MessageRole.assistant ? 'assistant' : 'user',
        'content': message.content,
      };

  /// Converts a [Tool] to Anthropic API format.
  Map<String, dynamic> _toolToAnthropicFormat(final Tool tool) =>
      <String, dynamic>{
        'name': tool.name,
        'description': tool.description,
        'input_schema': tool.parameters,
      };

  LLMResponse _parseResponse(final Map<String, dynamic> data) {
    final Object? content = data['content'];
    String? textContent;

    if (content is List && content.isNotEmpty) {
      final Object? firstBlock = content.first;

      if (firstBlock is Map<String, dynamic>) {
        final String? type = firstBlock['type'] as String?;
        if (type == 'text') {
          textContent = firstBlock['text'] as String?;
        }
      }
    }

    return LLMResponse(content: textContent);
  }
}
