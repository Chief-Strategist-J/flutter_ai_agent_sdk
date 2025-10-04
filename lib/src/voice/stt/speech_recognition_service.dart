import 'dart:async';

abstract class SpeechRecognitionService {
  Future<void> initialize();
  Future<String> startListening();
  Future<void> stopListening();
  Stream<String> get transcriptStream;
  Future<void> dispose();
  bool get isAvailable;
  bool get isListening;
}
