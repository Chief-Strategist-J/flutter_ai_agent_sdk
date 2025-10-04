import 'dart:async';

/// Abstract service for speech recognition (STT).
///
/// Defines lifecycle methods for initializing, starting
/// and stopping listening, and disposing resources.
/// Exposes transcript streaming and state flags.
abstract class SpeechRecognitionService {
  /// Initializes the speech recognition engine.
  Future<void> initialize();

  /// Starts listening for speech input.
  ///
  /// Returns when listening begins. The final transcript will be
  /// emitted as the last event on [transcriptStream] before
  /// [stopListening] is called.
  Future<void> startListening();

  /// Stops listening for speech input.
  Future<void> stopListening();

  /// Stream of recognized transcript updates.
  Stream<String> get transcriptStream;

  /// Disposes the service and releases resources.
  Future<void> dispose();

  /// Whether the recognition service is available.
  bool get isAvailable;

  /// Whether the service is currently listening.
  bool get isListening;
}
