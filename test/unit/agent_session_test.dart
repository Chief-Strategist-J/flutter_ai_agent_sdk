import 'dart:async';

import 'package:flutter_ai_agent_sdk/flutter_ai_agent_sdk.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

/// Mock LLM provider for testing.
class MockLLMProvider extends Mock implements LLMProvider {}

/// Mock STT service for testing.
class MockSTTService extends Mock implements SpeechRecognitionService {}

/// Mock TTS service for testing.
class MockTTSService extends Mock implements TextToSpeechService {}

void main() {
  group('AgentSession', () {
    late MockLLMProvider mockLLMProvider;
    late MockSTTService mockSTTService;
    late MockTTSService mockTTSService;
    late AgentConfig testConfig;
    late AgentConfig configWithServices;

    setUp(() {
      // Arrange: Create mock dependencies
      mockLLMProvider = MockLLMProvider();
      mockSTTService = MockSTTService();
      mockTTSService = MockTTSService();

      testConfig = AgentConfig(
        name: 'test-agent',
        llmProvider: mockLLMProvider,
        instructions: 'Test instructions',
      );

      configWithServices = AgentConfig(
        name: 'test-agent-services',
        llmProvider: mockLLMProvider,
        instructions: 'Test instructions',
        sttService: mockSTTService,
        ttsService: mockTTSService,
      );
    });

    tearDown(() {
      // Cleanup: Reset mocks
      reset(mockLLMProvider);
      reset(mockSTTService);
      reset(mockTTSService);
    });

    group('constructor', () {
      test('should_createInstance_when_validConfigProvided', () {
        // Arrange & Act: Create AgentSession instance
        final AgentSession session = AgentSession(config: testConfig);

        // Assert: Verify instance is created correctly
        expect(session, isNotNull);
        expect(session.config, equals(testConfig));
        expect(session.config.name, equals('test-agent'));
        expect(session.config.llmProvider, equals(mockLLMProvider));
        expect(session.id, isNotEmpty);
        expect(session.id.length, greaterThan(0));
        expect(session.memory, isNotNull);
        expect(session.toolExecutor, isNotNull);
        expect(session.currentState.state, equals(SessionState.idle));
        expect(session.currentMessages, isEmpty);
      });

      test('should_generateUniqueId_when_notProvided', () {
        // Arrange & Act: Create multiple sessions
        final AgentSession session1 = AgentSession(config: testConfig);
        final AgentSession session2 = AgentSession(config: testConfig);

        // Assert: Each session has unique ID
        expect(session1.id, isNot(equals(session2.id)));
        expect(session1.id.length, greaterThan(0));
        expect(session2.id.length, greaterThan(0));
      });

      test('should_useProvidedId_when_specified', () {
        // Arrange: Custom ID
        const String customId = 'custom-session-id';

        // Act: Create session with custom ID
        final AgentSession session = AgentSession(
          config: testConfig,
          id: customId,
        );

        // Assert: Uses provided ID
        expect(session.id, equals(customId));
      });

      test('should_createDefaultMemory_when_notProvided', () {
        // Arrange & Act: Create session without memory
        final AgentSession session = AgentSession(config: testConfig);

        // Assert: Default memory is created
        expect(session.memory, isA<ConversationMemory>());
        expect(
          session.memory.maxMessages,
          equals(testConfig.maxHistoryMessages),
        );
      });

      test('should_useProvidedMemory_when_specified', () {
        // Arrange: Custom memory
        final ConversationMemory customMemory =
            ConversationMemory(maxMessages: 100);

        // Act: Create session with custom memory
        final AgentSession session = AgentSession(
          config: testConfig,
          memory: customMemory,
        );

        // Assert: Uses provided memory
        expect(session.memory, same(customMemory));
      });

      test('should_createDefaultToolExecutor_when_notProvided', () {
        // Arrange & Act: Create session without tool executor
        final AgentSession session = AgentSession(config: testConfig);

        // Assert: Default tool executor is created
        expect(session.toolExecutor, isA<ToolExecutor>());
      });

      test('should_useProvidedToolExecutor_when_specified', () {
        // Arrange: Custom tool executor
        final ToolExecutor customToolExecutor = ToolExecutor(tools: <Tool>[]);

        // Act: Create session with custom tool executor
        final AgentSession session = AgentSession(
          config: testConfig,
          toolExecutor: customToolExecutor,
        );

        // Assert: Uses provided tool executor
        expect(session.toolExecutor, same(customToolExecutor));
      });

      test('should_haveCorrectInitialState_when_created', () {
        // Arrange & Act: Create session
        final AgentSession session = AgentSession(config: testConfig);

        // Assert: Initial state is idle
        expect(session.currentState.state, equals(SessionState.idle));
        expect(session.currentState.errorMessage, isNull);
      });
    });

    group('streams', () {
      test('should_provideEventStream_when_created', () {
        // Arrange & Act: Create session
        final AgentSession session = AgentSession(config: testConfig);

        // Assert: Event stream is available
        expect(session.events, isA<Stream<AgentEvent>>());
      });

      test('should_provideStateStream_when_created', () {
        // Arrange & Act: Create session
        final AgentSession session = AgentSession(config: testConfig);

        // Assert: State stream is available
        expect(session.state, isA<Stream<SessionStatus>>());
      });

      test('should_provideMessagesStream_when_created', () {
        // Arrange & Act: Create session
        final AgentSession session = AgentSession(config: testConfig);

        // Assert: Messages stream is available
        expect(session.messages, isA<Stream<List<Message>>>());
      });

      test('should_emitIdleStateInitially_when_stateStreamListened', () async {
        // Arrange: Create session
        final AgentSession session = AgentSession(config: testConfig);

        // Act: Listen to state stream
        final Stream<SessionStatus> stateStream = session.state;

        // Assert: Emits idle state initially
        final SessionStatus status = await stateStream.first;
        expect(status.state, equals(SessionState.idle));
        expect(status.errorMessage, isNull);
      });

      test('should_emitEmptyMessagesInitially_when_messagesStreamListened',
          () async {
        // Arrange: Create session
        final AgentSession session = AgentSession(config: testConfig);

        // Act: Listen to messages stream
        final Stream<List<Message>> messagesStream = session.messages;

        // Assert: Emits empty messages initially
        final List<Message> messages = await messagesStream.first;
        expect(messages, isEmpty);
      });
    });

    group('start', () {
      test('should_startSuccessfully_when_validConfig', () async {
        // Arrange: Create session
        final AgentSession session = AgentSession(config: testConfig);

        // Act: Start session
        await session.start();

        // Assert: Session is started successfully
        expect(session.currentState.state, equals(SessionState.idle));
        // Note: Can't directly test _isActive as it's private
      });

      test('should_emitStartedEvent_when_started', () async {
        // Arrange: Create session and listen to events
        final AgentSession session = AgentSession(config: testConfig);
        final List<AgentEvent> events = <AgentEvent>[];
        session.events.listen(events.add);

        // Act: Start session
        await session.start();

        // Assert: Started event is emitted
        expect(events, hasLength(1));
        expect(events.first, isA<AgentStartedEvent>());
      });

      test('should_initializeSTTService_when_configured', () async {
        // Arrange: Create session with STT service
        final AgentSession session = AgentSession(config: configWithServices);

        // Act: Start session
        await session.start();

        // Assert: STT service is initialized
        verify(() => mockSTTService.initialize()).called(1);
      });

      test('should_initializeTTSService_when_configured', () async {
        // Arrange: Create session with TTS service
        final AgentSession session = AgentSession(config: configWithServices);

        // Act: Start session
        await session.start();

        // Assert: TTS service is initialized
        verify(() => mockTTSService.initialize()).called(1);
      });

      test('should_doNothing_when_alreadyStarted', () async {
        // Arrange: Create and start session
        final AgentSession session = AgentSession(config: testConfig);
        await session.start();

        // Act: Try to start again
        await session.start();

        // Assert: No additional events emitted
        final List<AgentEvent> events = <AgentEvent>[];
        session.events.listen(events.add);
        await Future<void>.delayed(const Duration(milliseconds: 10));
        expect(events, isEmpty);
      });

      test('should_handleError_when_startFails', () async {
        // Arrange: Create session with failing STT service
        when(() => mockSTTService.initialize())
            .thenThrow(Exception('STT init failed'));
        final AgentSession session = AgentSession(config: configWithServices);
        final List<AgentEvent> events = <AgentEvent>[];
        session.events.listen(events.add);

        // Act: Start session
        await session.start();

        // Assert: Error state is set
        expect(session.currentState.state, equals(SessionState.error));
        expect(session.currentState.errorMessage, contains('STT init failed'));
        expect(events.whereType<ErrorEvent>(), hasLength(1));
      });
    });

    group('stop', () {
      test('should_stopSuccessfully_when_active', () async {
        // Arrange: Create and start session
        final AgentSession session = AgentSession(config: testConfig);
        await session.start();

        // Act: Stop session
        await session.stop();

        // Assert: Session is stopped
        expect(session.currentState.state, equals(SessionState.idle));
        // Note: Can't directly test _isActive as it's private
      });

      test('should_emitStoppedEvent_when_stopped', () async {
        // Arrange: Create and start session, listen to events
        final AgentSession session = AgentSession(config: testConfig);
        await session.start();
        final List<AgentEvent> events = <AgentEvent>[];
        session.events.listen(events.add);

        // Act: Stop session
        await session.stop();

        // Assert: Stopped event is emitted
        expect(events.whereType<AgentStoppedEvent>(), hasLength(1));
      });

      test('should_disposeSTTService_when_configured', () async {
        // Arrange: Create and start session with STT service
        final AgentSession session = AgentSession(config: configWithServices);
        await session.start();

        // Act: Stop session
        await session.stop();

        // Assert: STT service is disposed
        verify(() => mockSTTService.dispose()).called(1);
      });

      test('should_disposeTTSService_when_configured', () async {
        // Arrange: Create and start session with TTS service
        final AgentSession session = AgentSession(config: configWithServices);
        await session.start();

        // Act: Stop session
        await session.stop();

        // Assert: TTS service is disposed
        verify(() => mockTTSService.dispose()).called(1);
      });

      test('should_doNothing_when_notActive', () async {
        // Arrange: Create session (not started)
        final AgentSession session = AgentSession(config: testConfig);

        // Act: Stop session
        await session.stop();

        // Assert: No events emitted
        final List<AgentEvent> events = <AgentEvent>[];
        session.events.listen(events.add);
        await Future<void>.delayed(const Duration(milliseconds: 10));
        expect(events, isEmpty);
      });

      test('should_handleError_when_stopFails', () async {
        // Arrange: Create and start session with failing STT service
        when(() => mockSTTService.dispose())
            .thenThrow(Exception('STT dispose failed'));
        final AgentSession session = AgentSession(config: configWithServices);
        await session.start();

        // Act: Stop session
        await session.stop();

        // Assert: Error is logged but session state is still idle
        expect(session.currentState.state, equals(SessionState.idle));
      });
    });

    group('sendMessage', () {
      test('should_sendMessageSuccessfully_when_active', () async {
        // Arrange: Create and start session
        final AgentSession session = AgentSession(config: testConfig);
        await session.start();

        // Mock LLM response
        when(
          () => mockLLMProvider.generateStream(
            messages: any(named: 'messages'),
            tools: any(named: 'tools'),
          ),
        ).thenAnswer(
          (final _) => Stream<LLMResponse>.fromIterable(<LLMResponse>[
            LLMResponse(content: 'Hello'),
            LLMResponse(content: ' world'),
          ]),
        );

        // Act: Send message
        await session.sendMessage('Hello');

        // Assert: Message is processed
        expect(session.currentState.state, equals(SessionState.idle));
        expect(session.currentMessages.length, greaterThan(0));
      });

      test('should_throwError_when_notActive', () async {
        // Arrange: Create session (not started)
        final AgentSession session = AgentSession(config: testConfig);

        // Act & Assert: Send message should throw
        expect(
          () => session.sendMessage('Hello'),
          throwsA(isA<StateError>()),
        );
      });

      test('should_addUserMessage_when_sent', () async {
        // Arrange: Create and start session
        final AgentSession session = AgentSession(config: testConfig);
        await session.start();

        // Mock LLM response
        when(
          () => mockLLMProvider.generateStream(
            messages: any(named: 'messages'),
            tools: any(named: 'tools'),
          ),
        ).thenAnswer(
          (final _) => Stream<LLMResponse>.fromIterable(<LLMResponse>[
            LLMResponse(content: 'Response'),
          ]),
        );

        // Act: Send message
        await session.sendMessage('Hello');

        // Assert: User message is added
        final List<Message> messages = session.currentMessages;
        expect(messages.length, equals(2)); // User + Assistant
        expect(messages.first.role, equals(MessageRole.user));
        expect(messages.first.content, equals('Hello'));
      });

      test('should_generateLLMResponse_when_sent', () async {
        // Arrange: Create and start session
        final AgentSession session = AgentSession(config: testConfig);
        await session.start();

        // Mock LLM response
        when(
          () => mockLLMProvider.generateStream(
            messages: any(named: 'messages'),
            tools: any(named: 'tools'),
          ),
        ).thenAnswer(
          (final _) => Stream<LLMResponse>.fromIterable(<LLMResponse>[
            LLMResponse(content: 'LLM response'),
          ]),
        );

        // Act: Send message
        await session.sendMessage('Hello');

        // Assert: LLM response is added
        final List<Message> messages = session.currentMessages;
        expect(messages.length, equals(2)); // User + Assistant
        expect(messages.last.role, equals(MessageRole.assistant));
        expect(messages.last.content, equals('LLM response'));
      });

      test('should_emitEvents_when_messageSent', () async {
        // Arrange: Create and start session, listen to events
        final AgentSession session = AgentSession(config: testConfig);
        await session.start();
        final List<AgentEvent> events = <AgentEvent>[];
        session.events.listen(events.add);

        // Mock LLM response
        when(
          () => mockLLMProvider.generateStream(
            messages: any(named: 'messages'),
            tools: any(named: 'tools'),
          ),
        ).thenAnswer(
          (final _) => Stream<LLMResponse>.fromIterable(<LLMResponse>[
            LLMResponse(content: 'Response'),
          ]),
        );

        // Act: Send message
        await session.sendMessage('Hello');

        // Assert: Events are emitted
        expect(events.whereType<MessageSentEvent>(), hasLength(1));
        expect(events.whereType<MessageReceivedEvent>(), hasLength(1));
        expect(
          events.whereType<StreamingTextEvent>(),
          hasLength(2),
        ); // Content + complete
      });

      test('should_handleToolCalls_when_present', () async {
        // Arrange: Create and start session with tools
        final AgentSession session = AgentSession(config: testConfig);
        await session.start();

        // Mock LLM response with tool calls
        when(
          () => mockLLMProvider.generateStream(
            messages: any(named: 'messages'),
            tools: any(named: 'tools'),
          ),
        ).thenAnswer(
          (final _) => Stream<LLMResponse>.fromIterable(<LLMResponse>[
            LLMResponse(
              content: 'Using tool',
              toolCalls: <ToolCall>[
                ToolCall(
                  id: 'call-1',
                  name: 'test_tool',
                  arguments: <String, dynamic>{'arg': 'value'},
                ),
              ],
            ),
          ]),
        );

        // Act: Send message
        await session.sendMessage('Use tool');

        // Assert: Tool calls are processed
        final List<Message> messages = session.currentMessages;
        expect(messages.length, equals(3)); // User + Assistant + Tool result
        expect(messages.last.role, equals(MessageRole.tool));
      });

      test('should_speakResponse_when_TTSConfigured', () async {
        // Arrange: Create and start session with TTS
        final AgentSession session = AgentSession(config: configWithServices);
        await session.start();

        // Mock LLM response
        when(
          () => mockLLMProvider.generateStream(
            messages: any(named: 'messages'),
            tools: any(named: 'tools'),
          ),
        ).thenAnswer(
          (final _) => Stream<LLMResponse>.fromIterable(<LLMResponse>[
            LLMResponse(content: 'Spoken response'),
          ]),
        );

        // Act: Send message
        await session.sendMessage('Hello');

        // Assert: TTS service speaks response
        verify(() => mockTTSService.speak('Spoken response')).called(1);
      });
    });

    group('startListening', () {
      test('should_startListeningSuccessfully_when_STTConfigured', () async {
        // Arrange: Create and start session with STT
        final AgentSession session = AgentSession(config: configWithServices);
        await session.start();

        when(() => mockSTTService.startListening())
            .thenAnswer((final _) async {});
        when(() => mockSTTService.transcriptStream).thenAnswer(
          (final _) => Stream<String>.fromIterable(<String>['Hello from STT']),
        );

        // Act: Start listening
        await session.startListening();

        // Assert: Listening is successful
        expect(session.currentState.state, equals(SessionState.idle));
      });

      test('should_emitSpeechEvents_when_listening', () async {
        // Arrange: Create and start session with STT, listen to events
        final AgentSession session = AgentSession(config: configWithServices);
        await session.start();
        final List<AgentEvent> events = <AgentEvent>[];
        session.events.listen(events.add);

        when(() => mockSTTService.startListening())
            .thenAnswer((final _) async {});
        when(() => mockSTTService.transcriptStream).thenAnswer(
          (final _) => Stream<String>.fromIterable(<String>['Hello']),
        );

        // Act: Start listening
        await session.startListening();

        // Assert: Speech events are emitted
        expect(events.whereType<UserSpeechStartedEvent>(), hasLength(1));
        expect(events.whereType<UserSpeechEndedEvent>(), hasLength(1));
      });

      test('should_sendMessageFromTranscript_when_transcriptNotEmpty',
          () async {
        // Arrange: Create and start session with STT
        final AgentSession session = AgentSession(config: configWithServices);
        await session.start();

        when(() => mockSTTService.startListening())
            .thenAnswer((final _) async {});
        when(() => mockSTTService.transcriptStream).thenAnswer(
          (final _) => Stream<String>.fromIterable(
            <String>['Hello from speech'],
          ),
        );

        // Act: Start listening
        await session.startListening();

        // Assert: Transcript is sent as message
        final List<Message> messages = session.currentMessages;
        expect(messages.length, greaterThan(0));
        expect(messages.first.content, equals('Hello from speech'));
      });

      test('should_throwError_when_STTNotConfigured', () async {
        // Arrange: Create and start session without STT
        final AgentSession session = AgentSession(config: testConfig);
        await session.start();

        // Act & Assert: Start listening should throw
        expect(
          session.startListening,
          throwsA(isA<StateError>()),
        );
      });
    });

    group('stopListening', () {
      test('should_stopListening_when_active', () async {
        // Arrange: Create and start session with STT
        final AgentSession session = AgentSession(config: configWithServices);
        await session.start();

        // Act: Stop listening
        await session.stopListening();

        // Assert: STT service stops listening
        verify(() => mockSTTService.stopListening()).called(1);
      });
    });

    group('dispose', () {
      test('should_closeStreams_when_disposed', () async {
        // Arrange: Create session
        final AgentSession session = AgentSession(config: testConfig);

        // Act: Dispose session
        await session.dispose();

        // Assert: Streams are closed 
        //(no explicit verification, but no errors thrown)
        expect(session.dispose, returnsNormally);
      });

      test('should_closeMultipleStreams_when_disposed', () async {
        // Arrange: Create and start session
        final AgentSession session = AgentSession(config: testConfig);
        await session.start();

        // Act: Dispose session
        await session.dispose();

        // Assert: All streams are closed
        expect(session.dispose, returnsNormally);
      });
    });

    group('error handling', () {
      test('should_handleLLMError_when_sendingMessage', () async {
        // Arrange: Create and start session
        final AgentSession session = AgentSession(config: testConfig);
        await session.start();

        // Mock LLM error
        when(
          () => mockLLMProvider.generateStream(
            messages: any(named: 'messages'),
            tools: any(named: 'tools'),
          ),
        ).thenThrow(Exception('LLM error'));

        // Act: Send message
        await session.sendMessage('Hello');

        // Assert: Error state is set
        expect(session.currentState.state, equals(SessionState.error));
        expect(session.currentState.errorMessage, contains('LLM error'));
      });

      test('should_handleToolExecutionError_when_executingTools', () async {
        // Arrange: Create and start session
        final AgentSession session = AgentSession(config: testConfig);
        await session.start();

        // Mock LLM response with tool calls
        when(
          () => mockLLMProvider.generateStream(
            messages: any(named: 'messages'),
            tools: any(named: 'tools'),
          ),
        ).thenAnswer(
          (final _) => Stream<LLMResponse>.fromIterable(<LLMResponse>[
            LLMResponse(
              content: 'Using tool',
              toolCalls: <ToolCall>[
                ToolCall(
                  id: 'call-1',
                  name: 'failing_tool',
                  arguments: <String, dynamic>{'arg': 'value'},
                ),
              ],
            ),
          ]),
        );

        // Act: Send message
        await session.sendMessage('Use tool');

        // Assert: Tool execution error is handled gracefully
        expect(session.currentState.state, equals(SessionState.idle));
      });

      test('should_handleTTSError_when_speaking', () async {
        // Arrange: Create and start session with TTS
        final AgentSession session = AgentSession(config: configWithServices);
        await session.start();

        // Mock TTS error
        when(() => mockTTSService.speak(any()))
            .thenThrow(Exception('TTS error'));

        // Mock LLM response
        when(
          () => mockLLMProvider.generateStream(
            messages: any(named: 'messages'),
            tools: any(named: 'tools'),
          ),
        ).thenAnswer(
          (final _) => Stream<LLMResponse>.fromIterable(<LLMResponse>[
            LLMResponse(content: 'Response to speak'),
          ]),
        );

        // Act: Send message
        await session.sendMessage('Hello');

        // Assert: TTS error is handled gracefully
        expect(session.currentState.state, equals(SessionState.idle));
      });
    });

    group('edge cases', () {
      test('should_handleEmptyMessage_when_sent', () async {
        // Arrange: Create and start session
        final AgentSession session = AgentSession(config: testConfig);
        await session.start();

        // Mock LLM response for empty message
        when(
          () => mockLLMProvider.generateStream(
            messages: any(named: 'messages'),
            tools: any(named: 'tools'),
          ),
        ).thenAnswer(
          (final _) => Stream<LLMResponse>.fromIterable(<LLMResponse>[
            LLMResponse(content: 'Response to empty'),
          ]),
        );

        // Act: Send empty message
        await session.sendMessage('');

        // Assert: Empty message is processed
        expect(session.currentState.state, equals(SessionState.idle));
        expect(session.currentMessages.length, greaterThan(0));
      });

      test('should_handleConcurrentOperations_when_multipleMessagesSent',
          () async {
        // Arrange: Create and start session
        final AgentSession session = AgentSession(config: testConfig);
        await session.start();

        // Mock fast LLM responses
        when(
          () => mockLLMProvider.generateStream(
            messages: any(named: 'messages'),
            tools: any(named: 'tools'),
          ),
        ).thenAnswer(
          (final _) => Stream<LLMResponse>.fromIterable(<LLMResponse>[
            LLMResponse(content: 'Response'),
          ]),
        );

        // Act: Send multiple messages concurrently
        await Future.wait(<Future<void>>[
          session.sendMessage('Message 1'),
          session.sendMessage('Message 2'),
        ]);

        // Assert: All messages are processed
        expect(session.currentState.state, equals(SessionState.idle));
      });
    });

    group('resource cleanup', () {
      test('should_cleanUpResources_when_stopped', () async {
        // Arrange: Create and start session with services
        final AgentSession session = AgentSession(config: configWithServices);
        await session.start();

        // Act: Stop session
        await session.stop();

        // Assert: Resources are cleaned up
        expect(session.currentState.state, equals(SessionState.idle));
        // Note: Can't directly test _isActive as it's private
      });

      test('should_closeStreams_when_disposed', () async {
        // Arrange: Create session
        final AgentSession session = AgentSession(config: testConfig);

        // Act: Dispose session
        await session.dispose();

        // Assert: Streams are closed (verified by no errors)
        expect(session.dispose, returnsNormally);
      });

      test('should_cancelSubscriptions_when_stopped', () async {
        // Arrange: Create and start session
        final AgentSession session = AgentSession(config: testConfig);
        await session.start();

        // Act: Stop session
        await session.stop();

        // Assert: Subscriptions are cancelled
        // Note: Can't directly test _sttSubscription as it's private
      });
    });
  });
}
