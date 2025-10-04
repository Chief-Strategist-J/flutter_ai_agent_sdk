import 'dart:async';

abstract class TextToSpeechService {
  Future<void> initialize();
  Future<void> speak(final String text);
  Future<void> stop();
  Future<void> dispose();
  bool get isSpeaking;
  
  Future<void> setVoice(final String voiceId);
  Future<void> setRate(final double rate);
  Future<void> setPitch(final double pitch);
  Future<List<String>> getAvailableVoices();
}
