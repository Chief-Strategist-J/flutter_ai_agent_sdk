import 'dart:async';
import 'package:rxdart/rxdart.dart';

import 'package:flutter_ai_agent_sdk/src/core/agents/agent_config.dart';
import 'package:flutter_ai_agent_sdk/src/core/sessions/agent_session.dart';
import 'package:flutter_ai_agent_sdk/src/core/events/agent_events.dart';
import 'package:flutter_ai_agent_sdk/src/core/models/message.dart';
import 'package:flutter_ai_agent_sdk/src/core/sessions/session_state.dart';

class VoiceAgent {
  VoiceAgent({required this.config});
  final AgentConfig config;
  AgentSession? _session;

  Stream<AgentEvent> get events => _session?.events ?? const Stream.empty();
  Stream<SessionStatus> get state =>
      _session?.state ??
      BehaviorSubject<SessionStatus>.seeded(
        const SessionStatus(state: SessionState.idle),
      ).stream;
  Stream<List<Message>> get messages =>
      _session?.messages ??
      BehaviorSubject<List<Message>>.seeded(<Message>[]).stream;

  Future<AgentSession> createSession() async {
    final AgentSession session = AgentSession(config: config);
    await session.start();
    _session = session;
    return session;
  }

  Future<void> closeSession() async {
    await _session?.stop();
    _session?.dispose();
    _session = null;
  }

  AgentSession? get currentSession => _session;
}
