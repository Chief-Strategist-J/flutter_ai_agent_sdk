enum SessionState {
  idle,
  listening,
  processing,
  speaking,
  error,
}

class SessionStatus {
  
  const SessionStatus({
    required this.state,
    this.errorMessage,
    this.metadata,
  });
  final SessionState state;
  final String? errorMessage;
  final Map<String, dynamic>? metadata;
  
  bool get isActive => state != SessionState.idle && state != SessionState.error;
  bool get isListening => state == SessionState.listening;
  bool get isProcessing => state == SessionState.processing;
  bool get isSpeaking => state == SessionState.speaking;
  bool get hasError => state == SessionState.error;
}
