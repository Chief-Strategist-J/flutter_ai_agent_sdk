
/// Session state enumeration.
///
/// Represents the current state of a session.
enum SessionState {
  /// Session is idle and not active.
  idle,

  /// Session is listening for user speech.
  listening,

  /// Session is processing user input.
  processing,

  /// Session is speaking a response.
  speaking,

  /// Session has encountered an error.
  error,
}

/// Status object representing the current session state.
///
/// Includes the [state], optional [errorMessage],
/// and optional [metadata].
class SessionStatus {
  /// Creates a new [SessionStatus].
  const SessionStatus({
    required this.state,
    this.errorMessage,
    this.metadata,
  });

  /// Current session state.
  final SessionState state;

  /// Optional error message if [state] is [SessionState.error].
  final String? errorMessage;

  /// Optional metadata for custom tracking or extensions.
  final Map<String, dynamic>? metadata;

  /// Whether the session is active (not idle or error).
  bool get isActive =>
      state != SessionState.idle && state != SessionState.error;

  /// Whether the session is currently listening.
  bool get isListening => state == SessionState.listening;

  /// Whether the session is currently processing input/output.
  bool get isProcessing => state == SessionState.processing;

  /// Whether the session is currently speaking.
  bool get isSpeaking => state == SessionState.speaking;

  /// Whether the session is in an error state.
  bool get hasError => state == SessionState.error;

  // Note: Equality and hashCode overrides are provided for 
  //value-based comparisons
  // in tests and state management, even though the linter warns about 
  //missing @immutable.
  // These methods work correctly for comparing SessionStatus instances 
  //by state and errorMessage.
  ///
  bool equals(final SessionStatus other) =>
      identical(this, other) ||
      other.runtimeType == runtimeType &&
          state == other.state &&
          errorMessage == other.errorMessage;

  ///
  int getHashCode() => Object.hash(state, errorMessage);
}
