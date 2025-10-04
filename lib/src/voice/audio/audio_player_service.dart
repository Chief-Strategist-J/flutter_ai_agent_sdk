import 'dart:async';

abstract class AudioPlayerService {
  Future<void> initialize();
  Future<void> playAudio(final String audioUrl);
  Future<void> playBytes(final List<int> audioBytes);
  Future<void> stop();
  Future<void> pause();
  Future<void> resume();
  Future<void> dispose();
  
  Stream<PlayerState> get stateStream;
  bool get isPlaying;
}

enum PlayerState {
  idle,
  playing,
  paused,
  stopped,
  error,
}
