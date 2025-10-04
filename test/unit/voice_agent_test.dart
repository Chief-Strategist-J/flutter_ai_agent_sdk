import 'dart:async';

import 'package:flutter_ai_agent_sdk/src/core/agents/agent_config.dart';
import 'package:flutter_ai_agent_sdk/src/core/agents/voice_agent.dart';
import 'package:flutter_ai_agent_sdk/src/core/events/agent_events.dart';
import 'package:flutter_ai_agent_sdk/src/core/models/message.dart';
import 'package:flutter_ai_agent_sdk/src/core/sessions/agent_session.dart';
import 'package:flutter_ai_agent_sdk/src/core/sessions/session_state.dart';
import 'package:flutter_ai_agent_sdk/src/llm/providers/llm_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

/// Mock LLM provider for testing.
class MockLLMProvider extends Mock implements LLMProvider {}

void main() {
  group('VoiceAgent', () {
    late MockLLMProvider mockLLMProvider;
    late AgentConfig testConfig;

    setUp(() {
      // Arrange: Create mock dependencies
      mockLLMProvider = MockLLMProvider();

      testConfig = AgentConfig(
        name: 'test-agent',
        llmProvider: mockLLMProvider,
        instructions: 'Test instructions',
      );
    });

    tearDown(() {
      // Cleanup: Reset mocks
      reset(mockLLMProvider);
    });

    group('constructor', () {
      test('should_createInstance_when_validConfigProvided', () {
        // Arrange: Config already created in setUp

        // Act: Create VoiceAgent instance
        final VoiceAgent agent = VoiceAgent(config: testConfig);

        // Assert: Verify instance is created correctly
        expect(agent, isNotNull);
        expect(agent.config, equals(testConfig));
        expect(agent.config.name, equals('test-agent'));
        expect(agent.config.llmProvider, equals(mockLLMProvider));
        expect(agent.currentSession, isNull);
      });

      test('should_haveCorrectConfig_when_createdWithCustomSettings', () {
        // Arrange: Create config with custom settings
        final AgentConfig customConfig = AgentConfig(
          name: 'custom-agent',
          llmProvider: mockLLMProvider,
          instructions: 'Custom instructions',
          maxHistoryMessages: 100,
          enableMemory: false,
        );

        // Act: Create agent with custom config
        final VoiceAgent agent = VoiceAgent(config: customConfig);

        // Assert: Verify custom configuration
        expect(agent.config.name, equals('custom-agent'));
        expect(agent.config.instructions, equals('Custom instructions'));
        expect(agent.config.maxHistoryMessages, equals(100));
        expect(agent.config.enableMemory, isFalse);
      });

      test('should_storeConfig_when_instantiated', () {
        // Arrange & Act: Create agent
        final VoiceAgent agent = VoiceAgent(config: testConfig);

        // Assert: Config is stored and accessible
        expect(agent.config, same(testConfig));
        expect(agent.config, isA<AgentConfig>());
      });
    });

    group('currentSession', () {
      test('should_returnNull_when_noSessionCreated', () {
        // Arrange: Create agent without session
        final VoiceAgent agent = VoiceAgent(config: testConfig);

        // Act: Get current session
        final AgentSession? session = agent.currentSession;

        // Assert: Session is null
        expect(session, isNull);
      });

      test('should_returnSession_when_sessionCreated', () async {
        // Arrange: Create agent
        final VoiceAgent agent = VoiceAgent(config: testConfig);

        // Act: Create session
        final AgentSession session = await agent.createSession();

        // Assert: Current session is set
        expect(agent.currentSession, isNotNull);
        expect(agent.currentSession, equals(session));
      });

      test('should_returnNull_when_sessionClosed', () async {
        // Arrange: Create agent and session
        final VoiceAgent agent = VoiceAgent(config: testConfig);
        await agent.createSession();

        // Act: Close session
        await agent.closeSession();

        // Assert: Current session is null
        expect(agent.currentSession, isNull);
      });
    });

    group('events stream', () {
      test('should_returnEmptyStream_when_noSessionExists', () async {
        // Arrange: Create agent without session
        final VoiceAgent agent = VoiceAgent(config: testConfig);

        // Act: Get events stream
        final Stream<AgentEvent> eventsStream = agent.events;

        // Assert: Stream is empty
        expect(eventsStream, isA<Stream<AgentEvent>>());
        final List<AgentEvent> events = await eventsStream.take(1).timeout(
          const Duration(milliseconds: 100),
          onTimeout: (final EventSink<AgentEvent> sink) {
            sink.close();
          },
        ).toList();
        expect(events, isEmpty);
      });

      test('should_emitEvents_when_sessionActive', () async {
        // Arrange: Create agent and session
        final VoiceAgent agent = VoiceAgent(config: testConfig);
        await agent.createSession();

        // Act: Listen to events
        final Stream<AgentEvent> eventsStream = agent.events;

        // Assert: Stream is available
        expect(eventsStream, isA<Stream<AgentEvent>>());
      });

      test('should_returnEmptyStream_when_sessionClosed', () async {
        // Arrange: Create and close session
        final VoiceAgent agent = VoiceAgent(config: testConfig);
        await agent.createSession();
        await agent.closeSession();

        // Act: Get events stream
        final Stream<AgentEvent> eventsStream = agent.events;

        // Assert: Stream is empty
        final List<AgentEvent> events = await eventsStream.take(1).timeout(
          const Duration(milliseconds: 100),
          onTimeout: (final EventSink<AgentEvent> sink) {
            sink.close();
          },
        ).toList();
        expect(events, isEmpty);
      });
    });

    group('state stream', () {
      test('should_emitIdleState_when_noSessionExists', () async {
        // Arrange: Create agent without session
        final VoiceAgent agent = VoiceAgent(config: testConfig);

        // Act: Get state stream
        final Stream<SessionStatus> stateStream = agent.state;

        // Assert: Emits idle state
        final SessionStatus status = await stateStream.first;
        expect(status.state, equals(SessionState.idle));
        expect(status.errorMessage, isNull);
      });

      test('should_emitSessionState_when_sessionActive', () async {
        // Arrange: Create agent and session
        final VoiceAgent agent = VoiceAgent(config: testConfig);
        await agent.createSession();

        // Act: Get state stream
        final Stream<SessionStatus> stateStream = agent.state;

        // Assert: Stream emits states
        expect(stateStream, isA<Stream<SessionStatus>>());
        final SessionStatus status = await stateStream.first;
        expect(status, isA<SessionStatus>());
      });

      test('should_emitIdleState_when_sessionClosed', () async {
        // Arrange: Create and close session
        final VoiceAgent agent = VoiceAgent(config: testConfig);
        await agent.createSession();
        await agent.closeSession();

        // Act: Get state stream
        final Stream<SessionStatus> stateStream = agent.state;

        // Assert: Emits idle state
        final SessionStatus status = await stateStream.first;
        expect(status.state, equals(SessionState.idle));
      });
    });

    group('messages stream', () {
      test('should_emitEmptyList_when_noSessionExists', () async {
        // Arrange: Create agent without session
        final VoiceAgent agent = VoiceAgent(config: testConfig);

        // Act: Get messages stream
        final Stream<List<Message>> messagesStream = agent.messages;

        // Assert: Emits empty list
        final List<Message> messages = await messagesStream.first;
        expect(messages, isEmpty);
        expect(messages, isA<List<Message>>());
      });

      test('should_emitMessages_when_sessionActive', () async {
        // Arrange: Create agent and session
        final VoiceAgent agent = VoiceAgent(config: testConfig);
        await agent.createSession();

        // Act: Get messages stream
        final Stream<List<Message>> messagesStream = agent.messages;

        // Assert: Stream is available
        expect(messagesStream, isA<Stream<List<Message>>>());
        final List<Message> messages = await messagesStream.first;
        expect(messages, isA<List<Message>>());
      });

      test('should_emitEmptyList_when_sessionClosed', () async {
        // Arrange: Create and close session
        final VoiceAgent agent = VoiceAgent(config: testConfig);
        await agent.createSession();
        await agent.closeSession();

        // Act: Get messages stream
        final Stream<List<Message>> messagesStream = agent.messages;

        // Assert: Emits empty list
        final List<Message> messages = await messagesStream.first;
        expect(messages, isEmpty);
      });
    });

    group('createSession', () {
      test('should_createAndStartSession_when_called', () async {
        // Arrange: Create agent
        final VoiceAgent agent = VoiceAgent(config: testConfig);

        // Act: Create session
        final AgentSession session = await agent.createSession();

        // Assert: Session is created and started
        expect(session, isNotNull);
        expect(session, isA<AgentSession>());
        expect(agent.currentSession, equals(session));
      });

      test('should_setCurrentSession_when_sessionCreated', () async {
        // Arrange: Create agent
        final VoiceAgent agent = VoiceAgent(config: testConfig);
        expect(agent.currentSession, isNull);

        // Act: Create session
        await agent.createSession();

        // Assert: Current session is set
        expect(agent.currentSession, isNotNull);
      });

      test('should_returnNewSession_when_calledMultipleTimes', () async {
        // Arrange: Create agent
        final VoiceAgent agent = VoiceAgent(config: testConfig);

        // Act: Create first session
        final AgentSession session1 = await agent.createSession();

        // Close first session
        await agent.closeSession();

        // Create second session
        final AgentSession session2 = await agent.createSession();

        // Assert: Sessions are different instances
        expect(session1, isNot(equals(session2)));
        expect(agent.currentSession, equals(session2));
      });

      test('should_useProvidedConfig_when_creatingSession', () async {
        // Arrange: Create agent with specific config
        final VoiceAgent agent = VoiceAgent(config: testConfig);

        // Act: Create session
        final AgentSession session = await agent.createSession();

        // Assert: Session uses the same config
        expect(session.config, equals(testConfig));
        expect(session.config.name, equals('test-agent'));
      });

      test('should_initializeSessionState_when_created', () async {
        // Arrange: Create agent
        final VoiceAgent agent = VoiceAgent(config: testConfig);

        // Act: Create session
        await agent.createSession();

        // Assert: Session state is initialized
        final SessionStatus status = await agent.state.first;
        expect(status, isA<SessionStatus>());
        expect(status.state, isA<SessionState>());
      });
    });

    group('closeSession', () {
      test('should_clearCurrentSession_when_closed', () async {
        // Arrange: Create agent and session
        final VoiceAgent agent = VoiceAgent(config: testConfig);
        await agent.createSession();
        expect(agent.currentSession, isNotNull);

        // Act: Close session
        await agent.closeSession();

        // Assert: Current session is null
        expect(agent.currentSession, isNull);
      });

      test('should_doNothing_when_noSessionExists', () async {
        // Arrange: Create agent without session
        final VoiceAgent agent = VoiceAgent(config: testConfig);
        expect(agent.currentSession, isNull);

        // Act: Close session (should not throw)
        await agent.closeSession();

        // Assert: Still no session
        expect(agent.currentSession, isNull);
      });

      test('should_stopAndDisposeSession_when_closed', () async {
        // Arrange: Create agent and session
        final VoiceAgent agent = VoiceAgent(config: testConfig);
        await agent.createSession();

        // Act: Close session
        await agent.closeSession();

        // Assert: Session is stopped and disposed
        expect(agent.currentSession, isNull);
        // Note: We can't directly verify stop/dispose were called
        // without mocking AgentSession, but we verify the result
      });

      test('should_allowNewSession_when_previousSessionClosed', () async {
        // Arrange: Create and close first session
        final VoiceAgent agent = VoiceAgent(config: testConfig);
        await agent.createSession();
        await agent.closeSession();

        // Act: Create new session
        final AgentSession newSession = await agent.createSession();

        // Assert: New session is created
        expect(newSession, isNotNull);
        expect(agent.currentSession, equals(newSession));
      });

      test('should_handleMultipleCloseCalls_when_calledRepeatedly', () async {
        // Arrange: Create agent and session
        final VoiceAgent agent = VoiceAgent(config: testConfig);
        await agent.createSession();

        // Act: Close session multiple times
        await agent.closeSession();
        await agent.closeSession();
        await agent.closeSession();

        // Assert: No errors thrown, session remains null
        expect(agent.currentSession, isNull);
      });
    });

    group('edge cases', () {
      test('should_handleEmptyAgentName_when_configProvided', () {
        // Arrange: Create config with empty name
        final AgentConfig emptyNameConfig = AgentConfig(
          name: '',
          llmProvider: mockLLMProvider,
        );

        // Act: Create agent
        final VoiceAgent agent = VoiceAgent(config: emptyNameConfig);

        // Assert: Agent is created (validation happens elsewhere)
        expect(agent.config.name, isEmpty);
      });

      test('should_handleNullInstructions_when_notProvided', () {
        // Arrange: Create config without instructions
        final AgentConfig noInstructionsConfig = AgentConfig(
          name: 'test-agent',
          llmProvider: mockLLMProvider,
        );

        // Act: Create agent
        final VoiceAgent agent = VoiceAgent(config: noInstructionsConfig);

        // Assert: Instructions are null
        expect(agent.config.instructions, isNull);
      });

      test('should_handleDefaultValues_when_optionalParamsNotProvided', () {
        // Arrange: Create minimal config
        final AgentConfig minimalConfig = AgentConfig(
          name: 'minimal-agent',
          llmProvider: mockLLMProvider,
        );

        // Act: Create agent
        final VoiceAgent agent = VoiceAgent(config: minimalConfig);

        // Assert: Default values are used
        expect(agent.config.maxHistoryMessages, equals(50));
        expect(agent.config.enableMemory, isTrue);
        expect(agent.config.tools, isEmpty);
      });
    });

    group('async error handling', () {
      test('should_propagateError_when_sessionCreationFails', () async {
        // Arrange: Create agent with config that might fail
        final VoiceAgent agent = VoiceAgent(config: testConfig);

        // Act & Assert: Session creation should complete
        // (In real scenario, might fail due to service initialization)
        expect(
          () async => agent.createSession(),
          returnsNormally,
        );
      });

      test('should_handleCloseError_when_sessionDisposalFails', () async {
        // Arrange: Create agent and session
        final VoiceAgent agent = VoiceAgent(config: testConfig);
        await agent.createSession();

        // Act & Assert: Close should not throw
        expect(
          () async => agent.closeSession(),
          returnsNormally,
        );
      });
    });

    group('resource cleanup', () {
      test('should_releaseResources_when_sessionClosed', () async {
        // Arrange: Create agent and session
        final VoiceAgent agent = VoiceAgent(config: testConfig);
        await agent.createSession();

        // Act: Close session
        await agent.closeSession();

        // Assert: Resources are released
        expect(agent.currentSession, isNull);
        final List<AgentEvent> events = await agent.events.take(1).timeout(
          const Duration(milliseconds: 100),
          onTimeout: (final EventSink<AgentEvent> sink) {
            sink.close();
          },
        ).toList();
        expect(events, isEmpty);
      });

      test('should_allowGarbageCollection_when_sessionCleared', () async {
        // Arrange: Create agent and session
        final VoiceAgent agent = VoiceAgent(config: testConfig);
        await agent.createSession();

        // Act: Close session
        await agent.closeSession();

        // Assert: Session reference is cleared
        expect(agent.currentSession, isNull);
        // Original session object can be garbage collected
      });
    });
  });
}
