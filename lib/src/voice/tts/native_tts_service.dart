import 'dart:async';

import 'package:flutter_ai_agent_sdk/src/utils/logger.dart';
import 'package:flutter_ai_agent_sdk/src/voice/tts/text_to_speech_service.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Native implementation of [TextToSpeechService].
///
/// Uses the `flutter_tts` plugin to provide text-to-speech
/// capabilities with configurable voice, rate, and pitch.
class NativeTTSService implements TextToSpeechService {
  /// Underlying TTS engine.
  final FlutterTts _tts = FlutterTts();

  bool _isSpeaking = false;

  @override
  bool get isSpeaking => _isSpeaking;

  @override
  Future<void> initialize() async {
    try {
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.5);
      await _tts.setPitch(1);

      _tts
        ..setStartHandler(() {
          _isSpeaking = true;
        })
        ..setCompletionHandler(() {
          _isSpeaking = false;
        })
        ..setErrorHandler((final dynamic msg) {
          _isSpeaking = false;
          AgentLogger.error('TTS Error', msg, null);
        });

      AgentLogger.info('TTS initialized successfully');
    } catch (e, stack) {
      AgentLogger.error('TTS initialization failed', e, stack);
      rethrow;
    }
  }

  @override
  Future<void> speak(final String text) async {
    try {
      await _tts.speak(text);
    } catch (e, stack) {
      AgentLogger.error('TTS speak failed', e, stack);
      rethrow;
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _tts.stop();
    } finally {
      _isSpeaking = false;
    }
  }

  @override
  Future<void> setVoice(final String voiceId) async {
    // flutter_tts expects a map like {'name': <voiceName>, 'locale': <locale>}
    final Map<String, String> voiceSpec = <String, String>{
      'name': voiceId,
      'locale': 'en-US',
    };
    await _tts.setVoice(voiceSpec);
  }

  @override
  Future<void> setRate(final double rate) async {
    await _tts.setSpeechRate(rate);
  }

  @override
  Future<void> setPitch(final double pitch) async {
    await _tts.setPitch(pitch);
  }

  @override
  Future<List<String>> getAvailableVoices() async {
    // flutter_tts returns Future<dynamic>; cast defensively.
    final Object? voicesObj = await _tts.getVoices;

    if (voicesObj is! List<dynamic>) {
      // Unexpected shape; return empty list rather than throwing.
      AgentLogger.warning('TTS getVoices returned non-list payload');
      return const <String>[];
    }

    final List<String> names = <String>[];
    for (final Object? v in voicesObj) {
      if (v is Map<Object?, Object?>) {
        final Object? nameObj = v['name'];
        if (nameObj is String && nameObj.isNotEmpty) {
          names.add(nameObj);
        }
      } else if (v is Map<String, Object?>) {
        final Object? nameObj = v['name'];
        if (nameObj is String && nameObj.isNotEmpty) {
          names.add(nameObj);
        }
      }
      // If an entry is any other shape, skip it silently.
    }

    return names;
  }

  @override
  Future<void> dispose() async {
    await stop();
  }
}
