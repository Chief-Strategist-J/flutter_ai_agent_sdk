import 'dart:async';
import 'dart:typed_data';

/// Result of a voice activity detection (VAD) check.
///
/// Contains whether speech is present, confidence score,
/// and the time of detection.
class VADResult {
  /// Creates a [VADResult].
  ///
  /// - [isSpeech]: True if speech is detected.
  /// - [confidence]: Confidence level of detection.
  /// - [timestamp]: Time of detection. Defaults to now.
  VADResult({
    required this.isSpeech,
    required this.confidence,
    final DateTime? timestamp,
  })  : assert(
          confidence >= 0.0 && confidence <= 1.0,
          'confidence must be between 0.0 and 1.0',
        ),
        timestamp = timestamp ?? DateTime.now();

  /// Whether speech was detected.
  final bool isSpeech;

  /// Confidence score (0.0–1.0).
  final double confidence;

  /// Timestamp of when detection occurred.
  final DateTime timestamp;
}

/// Abstract interface for a voice activity detector (VAD).
///
/// Implementations analyze audio frames and determine
/// whether speech is present.
abstract class VoiceActivityDetector {
  /// Initializes the VAD service.
  Future<void> initialize();

  /// Analyzes [audioData] and returns a [VADResult].
  Future<VADResult> detectActivity(final Float32List audioData);

  /// Stream of [VADResult] updates.
  Stream<VADResult> get activityStream;

  /// Disposes the detector and releases resources.
  Future<void> dispose();
}
