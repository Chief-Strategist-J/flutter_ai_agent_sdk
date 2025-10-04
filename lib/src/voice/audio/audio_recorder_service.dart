import 'dart:async';
import 'dart:typed_data';

/// Abstract service for audio recording.
///
/// Defines lifecycle methods for starting, stopping,
/// pausing, resuming, and disposing recordings. Exposes
/// both audio data and state streams.
abstract class AudioRecorderService {
  /// Initializes the recorder.
  Future<void> initialize();

  /// Starts recording audio.
  Future<void> startRecording();

  /// Stops recording and returns the saved file path.
  Future<String> stopRecording();

  /// Pauses the current recording.
  Future<void> pauseRecording();

  /// Resumes a paused recording.
  Future<void> resumeRecording();

  /// Disposes the recorder and releases resources.
  Future<void> dispose();

  /// Stream of raw audio chunks as [Uint8List].
  Stream<Uint8List> get audioStream;

  /// Stream of [RecorderState] updates.
  Stream<RecorderState> get stateStream;

  /// Whether the recorder is currently active.
  bool get isRecording;
}

/// Represents the state of the [AudioRecorderService].
enum RecorderState {
  /// Recorder is idle and not recording.
  idle,

  /// Recorder is actively recording audio.
  recording,

  /// Recorder is paused mid-recording.
  paused,

  /// Recorder has been stopped.
  stopped,

  /// Recorder has encountered an error.
  error,
}
