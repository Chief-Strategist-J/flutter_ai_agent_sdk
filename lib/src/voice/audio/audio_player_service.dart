import 'dart:async';
import 'dart:typed_data';

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
  Future<void> playBytes(final Uint8List audioBytes);

  /// Stops the current audio playback.
  Future<void> stop();

  /// Pauses the current audio playback.
  Future<void> pause();

  /// Resumes audio playback if paused.
  Future<void> resume();

  /// Disposes the player and releases resources.
  Future<void> dispose();

  /// Stream of [PlayerState] updates.
  ///
  /// Emits state changes throughout the player lifecycle, from initialization
  /// through disposal. The stream should be created during [initialize] and
  /// closed during [dispose]. Implementations should ensure this is a broadcast
  /// stream to support multiple listeners (e.g., UI components, analytics).
  ///
  /// Error handling: Errors during playback should transition to
  /// [PlayerState.error] rather than emitting stream errors. Stream errors
  /// should only be used for critical failures that prevent proper state
  /// management. The stream should emit events in the correct order:
  /// idle → playing/paused → stopped/error.
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
