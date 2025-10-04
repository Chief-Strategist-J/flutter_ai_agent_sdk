import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ai_agent_sdk/flutter_ai_agent_sdk.dart';

void main() {
  group('SessionStatus', () {
    test('should have all required fields', () {
      const SessionStatus status = SessionStatus(
        state: SessionState.idle,
      );
      
      expect(status.state, SessionState.idle);
      expect(status.errorMessage, isNull);
      expect(status.metadata, isNull);
    });
    
    test('isActive should return correct value', () {
      const SessionStatus idle = SessionStatus(state: SessionState.idle);
      const SessionStatus listening = SessionStatus(state: SessionState.listening);
      const SessionStatus processing = SessionStatus(state: SessionState.processing);
      const SessionStatus speaking = SessionStatus(state: SessionState.speaking);
      const SessionStatus error = SessionStatus(state: SessionState.error);
      
      expect(idle.isActive, false);
      expect(listening.isActive, true);
      expect(processing.isActive, true);
      expect(speaking.isActive, true);
      expect(error.isActive, false);
    });
    
    test('state-specific getters should work', () {
      const SessionStatus listening = SessionStatus(state: SessionState.listening);
      const SessionStatus processing = SessionStatus(state: SessionState.processing);
      const SessionStatus speaking = SessionStatus(state: SessionState.speaking);
      const SessionStatus error = SessionStatus(state: SessionState.error);
      
      expect(listening.isListening, true);
      expect(processing.isProcessing, true);
      expect(speaking.isSpeaking, true);
      expect(error.hasError, true);
    });
  });
}
