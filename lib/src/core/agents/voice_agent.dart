import 'dart:async';

import 'package:flutter_ai_agent_sdk/src/core/agents/agent_config.dart';
import 'package:flutter_ai_agent_sdk/src/core/events/agent_events.dart';
import 'package:flutter_ai_agent_sdk/src/core/models/message.dart';
import 'package:flutter_ai_agent_sdk/src/core/sessions/agent_session.dart';
import 'package:flutter_ai_agent_sdk/src/core/sessions/session_state.dart';
import 'package:rxdart/rxdart.dart';

/// Represents a voice-enabled AI agent.
///
/// A [VoiceAgent] manages lifecycle, sessions, and streams for
/// messages, events, and state updates. It wraps [AgentSession]
/// and exposes a simple API to create or close sessions.
class VoiceAgent {
  /// Creates a new [VoiceAgent] with the given [config].
  VoiceAgent({required this.config});

  /// Immutable configuration for this agent.
  final AgentConfig config;

  /// Internal reference to the current agent session.
  AgentSession? _session;

  /// Stream of agent-level events.
  ///
  /// Returns an empty stream if no session is active.
  Stream<AgentEvent> get events =>
      _session?.events ?? const Stream<AgentEvent>.empty();

  /// Stream of session status updates.
  ///
  /// Emits [SessionStatus] values. Defaults to [SessionState.idle]
  /// if no session exists.
  Stream<SessionStatus> get state =>
      _session?.state ??
      BehaviorSubject<SessionStatus>.seeded(
        const SessionStatus(state: SessionState.idle),
      ).stream;

  /// Stream of agent messages.
  ///
  /// Emits conversation [Message] objects exchanged in the session.
  /// Defaults to an empty list if no session exists.
  Stream<List<Message>> get messages =>
      _session?.messages ??
      BehaviorSubject<List<Message>>.seeded(<Message>[]).stream;

  /// Creates and starts a new [AgentSession].
  ///
  /// Initializes a session with [config], starts it, and sets it
  /// as the current active session.
  Future<AgentSession> createSession() async {
    final AgentSession session = AgentSession(config: config);
    await session.start();
    _session = session;
    return session;
  }

  /// Closes the active session, if any.
  ///
  /// Stops and disposes of the current session and clears the
  /// reference.
  Future<void> closeSession() async {
    await _session?.stop();
    _session?.dispose();
    _session = null;
  }

  /// Returns the currently active session, or `null` if none exists.
  AgentSession? get currentSession => _session;
}
