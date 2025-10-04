/// Modes for detecting user speaking turns.
enum TurnDetectionMode {
  /// Voice Activity Detection (local client-side).
  vad,

  /// Manual push-to-talk button press.
  pushToTalk,

  /// Server-side VAD (e.g., OpenAI Realtime).
  serverVad,

  /// Hybrid of VAD and silence detection.
  hybrid,
}

/// Configuration for turn detection during voice input.
///
/// Defines how the agent determines when the user starts
/// and stops speaking. Supports VAD, manual modes, and
/// threshold tuning.
class TurnDetectionConfig {
  /// Creates a new [TurnDetectionConfig].
  ///
  /// Defaults:
  /// - [mode]: [TurnDetectionMode.vad]
  /// - [silenceThreshold]: 700ms
  /// - [minSpeechDuration]: 300ms
  /// - [vadThreshold]: 0.5
  const TurnDetectionConfig({
    this.mode = TurnDetectionMode.vad,
    this.silenceThreshold = const Duration(milliseconds: 700),
    this.minSpeechDuration = const Duration(milliseconds: 300),
    this.vadThreshold = 0.5,
  }) : assert(
         vadThreshold >= 0.0 && vadThreshold <= 1.0,
         'vadThreshold must be between 0.0 and 1.0',
       );

  /// Selected turn detection mode.
  final TurnDetectionMode mode;

  /// Minimum silence duration before ending speech.
  final Duration silenceThreshold;

  /// Minimum duration required to count as speech.
  final Duration minSpeechDuration;

  /// Threshold for VAD confidence (0–1).
  final double vadThreshold;
}
