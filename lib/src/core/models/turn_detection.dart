enum TurnDetectionMode {
  vad, // Voice Activity Detection
  pushToTalk, // Manual button press
  serverVad, // Server-side VAD (e.g., OpenAI Realtime)
  hybrid, // Combined VAD + silence detection
}

class TurnDetectionConfig {
  const TurnDetectionConfig({
    this.mode = TurnDetectionMode.vad,
    this.silenceThreshold = const Duration(milliseconds: 700),
    this.minSpeechDuration = const Duration(milliseconds: 300),
    this.vadThreshold = 0.5,
  });
  final TurnDetectionMode mode;
  final Duration silenceThreshold;
  final Duration minSpeechDuration;
  final double vadThreshold;
}
