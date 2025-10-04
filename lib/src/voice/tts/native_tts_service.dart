import 'dart:async';
import 'package:flutter_tts/flutter_tts.dart';

import 'package:flutter_ai_agent_sdk/src/voice/tts/text_to_speech_service.dart';
import 'package:flutter_ai_agent_sdk/src/utils/logger.dart';

class NativeTTSService implements TextToSpeechService {
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
      
      _tts.setStartHandler(() {
        _isSpeaking = true;
      });
      
      _tts.setCompletionHandler(() {
        _isSpeaking = false;
      });
      
      _tts.setErrorHandler((final msg) {
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
    await _tts.stop();
    _isSpeaking = false;
  }
  
  @override
  Future<void> setVoice(final String voiceId) async {
    await _tts.setVoice(<String, String>{'name': voiceId, 'locale': 'en-US'});
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
    final voices = await _tts.getVoices;
    return (voices as List).map((final v) => v['name'] as String).toList();
  }
  
  @override
  Future<void> dispose() async {
    await stop();
  }
}
