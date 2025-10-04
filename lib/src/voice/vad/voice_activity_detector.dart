import 'dart:async';
import 'dart:typed_data';

class VADResult {
  VADResult({
    required this.isSpeech,
    required this.confidence,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
  final bool isSpeech;
  final double confidence;
  final DateTime timestamp;
}

abstract class VoiceActivityDetector {
  Future<void> initialize();
  Future<VADResult> detectActivity(final Float32List audioData);
  Stream<VADResult> get activityStream;
  Future<void> dispose();
}
