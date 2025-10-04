import 'dart:async';

/// Abstract service for text-to-speech (TTS).
///
/// Defines lifecycle methods for initialization,
/// speaking, stopping, and disposing. Also provides
/// configuration for voice, rate, and pitch.
abstract class TextToSpeechService {
  /// Initializes the TTS engine.
  Future<void> initialize();

  /// Speaks the given [text] aloud.
  Future<void> speak(final String text);

  /// Stops any ongoing speech.
  Future<void> stop();

  /// Disposes the service and releases resources.
  Future<void> dispose();

  /// Whether the service is currently speaking.
  bool get isSpeaking;

  /// Sets the voice by [voiceId].
  Future<void> setVoice(final String voiceId);

  /// Sets the speech [rate].
  Future<void> setRate(final double rate);

  /// Sets the speech [pitch].
  Future<void> setPitch(final double pitch);

  /// Returns a list of available voice identifiers.
  Future<List<String>> getAvailableVoices();
}
