import 'dart:async';
import 'dart:typed_data';

abstract class AudioRecorderService {
  Future<void> initialize();
  Future<void> startRecording();
  Future<String> stopRecording();
  Future<void> pauseRecording();
  Future<void> resumeRecording();
  Future<void> dispose();
  
  Stream<Uint8List> get audioStream;
  Stream<RecorderState> get stateStream;
  bool get isRecording;
}

enum RecorderState {
  idle,
  recording,
  paused,
  stopped,
  error,
}
