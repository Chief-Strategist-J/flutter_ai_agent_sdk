import 'dart:async';
import 'dart:convert';

import 'package:flutter_ai_agent_sdk/src/core/models/message.dart';
import 'package:flutter_ai_agent_sdk/src/llm/providers/llm_provider.dart';
import 'package:flutter_ai_agent_sdk/src/tools/tool.dart';
import 'package:flutter_ai_agent_sdk/src/utils/logger.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

/// LLM provider for OpenAI Chat models.
///
/// Supports both response generation with [generate]
/// and streaming responses with [generateStream].
class OpenAIProvider extends LLMProvider {
  /// Creates an [OpenAIProvider].
  ///
  /// - [apiKey]: Required OpenAI API key.
  /// - [model]: Defaults to `gpt-4-turbo-preview`.
  /// - [baseUrl]: Defaults to `https://api.openai.com/v1`.
  OpenAIProvider({
    required this.apiKey,
    this.model = 'gpt-4-turbo-preview',
    this.baseUrl = 'https://api.openai.com/v1',
  });

  /// OpenAI API key.
  final String apiKey;

  /// Model identifier to use.
  final String model;

  /// Base URL for OpenAI API requests.
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
      final Map<String, Object?> body = <String, Object?>{
        'model': model,
        'messages': messages
            .map((final Message m) => _messageToJson(m) as Map<String, Object?>)
            .toList(growable: false),
      };

      if (tools != null && tools.isNotEmpty) {
        body['tools'] = tools
            .map((final Tool t) => t.toJson() as Map<String, Object?>)
            .toList(growable: false);
      }

      if (parameters != null && parameters.isNotEmpty) {
        body.addAll(
          parameters.map<String, Object?>(
            (final String k, final dynamic v) =>
                MapEntry<String, Object?>(k, v as Object?),
          ),
        );
      }

      final http.Response response = await http
          .post(
            Uri.parse('$baseUrl/chat/completions'),
            headers: <String, String>{
              'Authorization': 'Bearer $apiKey',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(
            const Duration(seconds: 60),
            onTimeout: () =>
                throw TimeoutException('OpenAI API request timed out'),
          );

      if (response.statusCode == 200) {
        final String raw = response.body;
        if (raw.isEmpty) {
          throw const FormatException('Empty response body from API.');
        }

        Object? decoded;
        try {
          decoded = jsonDecode(raw);
        } on FormatException catch (fe) {
          throw FormatException('Invalid JSON from API: ${fe.message}');
        }

        if (decoded is! Map<String, dynamic>) {
          throw const FormatException('Expected top-level JSON object.');
        }

        return _parseResponse(decoded);
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

      final Map<String, Object?> body = <String, Object?>{
        'model': model,
        'messages': messages
            .map((final Message m) => _messageToJson(m) as Map<String, Object?>)
            .toList(growable: false),
        'stream': true,
      };

      if (tools != null && tools.isNotEmpty) {
        body['tools'] = tools
            .map((final Tool t) => t.toJson() as Map<String, Object?>)
            .toList(growable: false);
      }

      if (parameters != null && parameters.isNotEmpty) {
        body.addAll(
          parameters.map<String, Object?>(
            (final String k, final dynamic v) =>
                MapEntry<String, Object?>(k, v as Object?),
          ),
        );
      }

      request.body = jsonEncode(body);

      final http.StreamedResponse streamedResponse = await request
          .send()
          .timeout(
            const Duration(seconds: 60),
            onTimeout: () =>
                throw TimeoutException('OpenAI streaming request timed out'),
          );

      await for (final String chunk
          in streamedResponse.stream.transform(utf8.decoder)) {
        final List<String> lines = chunk.split('\n');
        for (final String line in lines) {
          if (line.startsWith('data: ') && line.trim() != 'data: [DONE]') {
            final String jsonStr = line.substring(6);
            try {
              final Object? decoded = jsonDecode(jsonStr);

              if (decoded is Map<String, dynamic>) {
                final List<dynamic>? choicesDyn =
                    decoded['choices'] as List<dynamic>?;
                if (choicesDyn != null && choicesDyn.isNotEmpty) {
                  final Map<String, dynamic>? firstChoice =
                      choicesDyn.whereType<Map<String, dynamic>>().firstOrNull;

                  if (firstChoice != null) {
                    final Object? deltaObj = firstChoice['delta'];
                    if (deltaObj is Map<String, dynamic>) {
                      final Map<String, dynamic> deltaMap = deltaObj;

                      final String? content = deltaMap['content'] as String?;
                      final Object? toolCallsRaw = deltaMap['tool_calls'];

                      yield LLMResponse(
                        content: content,
                        toolCalls: _parseToolCalls(toolCallsRaw),
                      );
                    }
                  }
                }
              }
            } catch (_) {
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

  Map<String, dynamic> _messageToJson(final Message message) =>
      <String, dynamic>{
        'role': message.role.name,
        'content': message.content,
      };

  LLMResponse _parseResponse(final Map<String, dynamic> data) {
    final Object? choicesObj = data['choices'];
    Map<String, dynamic>? messageMap;

    if (choicesObj is List<dynamic>) {
      final Map<String, dynamic>? firstChoice =
          choicesObj.whereType<Map<String, dynamic>>().firstOrNull;

      if (firstChoice != null) {
        final Object? msgObj = firstChoice['message'];
        if (msgObj is Map<String, dynamic>) {
          messageMap = msgObj;
        }
      }
    }

    final String? content =
        messageMap != null ? messageMap['content'] as String? : null;
    final Object? toolCallsRaw =
        messageMap != null ? messageMap['tool_calls'] : null;

    return LLMResponse(
      content: content,
      toolCalls: _parseToolCalls(toolCallsRaw),
    );
  }

  List<ToolCall>? _parseToolCalls(final Object? toolCallsJson) {
    if (toolCallsJson == null) {
      return null;
    }
    if (toolCallsJson is! List<dynamic>) {
      return null;
    }

    final List<ToolCall> out = <ToolCall>[];

    for (final Object? tcObj in toolCallsJson) {
      if (tcObj is! Map<String, dynamic>) {
        continue;
      }

      final String id =
          (tcObj['id'] is String) ? tcObj['id'] as String : const Uuid().v4();

      final Object? funcObj = tcObj['function'];
      if (funcObj is! Map<String, dynamic>) {
        continue;
      }

      final String? name = funcObj['name'] as String?;
      if (name == null) {
        continue;
      }

      final Object? argsRaw = funcObj['arguments'];
      Map<String, dynamic>? arguments;

      if (argsRaw is String) {
        try {
          final Object? decoded = jsonDecode(argsRaw);
          if (decoded is Map<String, dynamic>) {
            arguments = decoded;
          } else {
            continue;
          }
        } catch (_) {
          continue;
        }
      } else if (argsRaw is Map<String, dynamic>) {
        arguments = argsRaw;
      } else {
        continue;
      }

      out.add(
        ToolCall(
          id: id,
          name: name,
          arguments: arguments,
        ),
      );
    }

    return out;
  }
}
