import 'dart:async';

/// Abstract service for audio playback.
///
/// Defines lifecycle methods for playing audio from
/// URLs or raw bytes, and exposes playback state.
abstract class AudioPlayerService {
  /// Initializes the audio player.
  Future<void> initialize();

  /// Plays audio from a given [audioUrl].
  Future<void> playAudio(final String audioUrl);

  /// Plays audio from raw [audioBytes].
  Future<void> playBytes(final List<int> audioBytes);

  /// Stops the current audio playback.
  Future<void> stop();

  /// Pauses the current audio playback.
  Future<void> pause();

  /// Resumes audio playback if paused.
  Future<void> resume();

  /// Disposes the player and releases resources.
  Future<void> dispose();

  /// Stream of [PlayerState] updates.
  Stream<PlayerState> get stateStream;

  /// Whether the player is currently playing audio.
  bool get isPlaying;
}

/// Represents the state of the [AudioPlayerService].
enum PlayerState {
  /// No audio loaded or playing.
  idle,

  /// Audio is actively playing.
  playing,

  /// Audio playback is paused.
  paused,

  /// Audio playback has been stopped.
  stopped,

  /// An error occurred during playback.
  error,
}
