import 'dart:async';

import 'package:flutter_ai_agent_sdk/src/utils/logger.dart';
import 'package:flutter_ai_agent_sdk/src/voice/stt/speech_recognition_service.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

/// Native implementation of [SpeechRecognitionService].
///
/// Uses the `speech_to_text` package for on-device
/// speech-to-text recognition. Provides transcript
/// streaming and manages listening state.
class NativeSTTService implements SpeechRecognitionService {
  /// Internal speech-to-text engine.
  final stt.SpeechToText _speech = stt.SpeechToText();

  /// Controller for streaming transcripts.
  final StreamController<String> _transcriptController =
      StreamController<String>.broadcast();

  bool _isListening = false;
  bool _isAvailable = false;
  String _currentTranscript = '';

  @override
  Stream<String> get transcriptStream => _transcriptController.stream;

  @override
  bool get isAvailable => _isAvailable;

  @override
  bool get isListening => _isListening;

  @override
  Future<void> initialize() async {
    try {
      _isAvailable = await _speech.initialize(
        onError: (final SpeechRecognitionError error) =>
            AgentLogger.error('STT Error', error, null),
        onStatus: (final String status) =>
            AgentLogger.info('STT Status: $status'),
      );

      if (!_isAvailable) {
        throw Exception('Speech recognition not available');
      }

      AgentLogger.info('STT initialized successfully');
    } catch (e, stack) {
      AgentLogger.error('STT initialization failed', e, stack);
      rethrow;
    }
  }

  @override
  Future<void> startListening() async {
    if (!_isAvailable) {
      throw StateError('STT not initialized');
    }

    _currentTranscript = '';
    _isListening = true;

    await _speech.listen(
      onResult: (final SpeechRecognitionResult result) {
        _currentTranscript = result.recognizedWords;
        _transcriptController.add(_currentTranscript);

        if (result.finalResult) {
          _isListening = false;
        }
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      cancelOnError: true,
    );
  }

  @override
  Future<void> stopListening() async {
    if (_isListening) {
      await _speech.stop();
      _isListening = false;
    }
  }

  @override
  Future<void> dispose() async {
    await stopListening();
    await _transcriptController.close();
  }
}
