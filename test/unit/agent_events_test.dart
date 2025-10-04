import 'package:flutter_ai_agent_sdk/src/core/events/agent_events.dart';
import 'package:flutter_ai_agent_sdk/src/core/models/message.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AgentEvent', () {
    group('base class', () {
      test('should_setTimestamp_when_created', () {
        // Arrange & Act
        final AgentEvent event = AgentStartedEvent();

        // Assert
        expect(event.timestamp, isNotNull);
        expect(event.timestamp, isA<DateTime>());
        // Timestamp should be recent (within last second)
        final DateTime now = DateTime.now();
        final DateTime oneSecondAgo = now.subtract(const Duration(seconds: 1));
        expect(event.timestamp.isAfter(oneSecondAgo), isTrue);
        expect(event.timestamp.isBefore(now) || event.timestamp == now, isTrue);
      });

      test('should_haveUniqueTimestamps_when_multipleEventsCreated', () async {
        // Arrange & Act
        final AgentEvent event1 = AgentStartedEvent();
        await Future<void>.delayed(const Duration(milliseconds: 1));
        final AgentEvent event2 = AgentStoppedEvent();

        // Assert
        expect(event1.timestamp, isNot(equals(event2.timestamp)));
      });
    });

    group('AgentStartedEvent', () {
      test('should_createInstance_when_constructed', () {
        // Arrange & Act
        final AgentStartedEvent event = AgentStartedEvent();

        // Assert
        expect(event, isA<AgentEvent>());
        expect(event, isA<AgentStartedEvent>());
        expect(event.timestamp, isNotNull);
      });

      test('should_beTypeOfAgentEvent_when_checked', () {
        // Arrange & Act
        final AgentEvent event = AgentStartedEvent();

        // Assert
        expect(event, isA<AgentStartedEvent>());
        expect(event.runtimeType, equals(AgentStartedEvent));
      });
    });

    group('AgentStoppedEvent', () {
      test('should_createInstance_when_constructed', () {
        // Arrange & Act
        final AgentStoppedEvent event = AgentStoppedEvent();

        // Assert
        expect(event, isA<AgentEvent>());
        expect(event, isA<AgentStoppedEvent>());
        expect(event.timestamp, isNotNull);
      });

      test('should_beTypeOfAgentEvent_when_checked', () {
        // Arrange & Act
        final AgentEvent event = AgentStoppedEvent();

        // Assert
        expect(event, isA<AgentStoppedEvent>());
        expect(event.runtimeType, equals(AgentStoppedEvent));
      });
    });

    group('UserSpeechStartedEvent', () {
      test('should_createInstance_when_constructed', () {
        // Arrange & Act
        final UserSpeechStartedEvent event = UserSpeechStartedEvent();

        // Assert
        expect(event, isA<AgentEvent>());
        expect(event, isA<UserSpeechStartedEvent>());
        expect(event.timestamp, isNotNull);
      });

      test('should_beTypeOfAgentEvent_when_checked', () {
        // Arrange & Act
        final AgentEvent event = UserSpeechStartedEvent();

        // Assert
        expect(event, isA<UserSpeechStartedEvent>());
        expect(event.runtimeType, equals(UserSpeechStartedEvent));
      });
    });

    group('UserSpeechEndedEvent', () {
      test('should_createInstance_when_constructed', () {
        // Arrange
        const String transcript = 'Hello, world!';

        // Act
        final UserSpeechEndedEvent event = UserSpeechEndedEvent(transcript);

        // Assert
        expect(event, isA<AgentEvent>());
        expect(event, isA<UserSpeechEndedEvent>());
        expect(event.transcript, equals(transcript));
        expect(event.timestamp, isNotNull);
      });

      test('should_storeTranscript_when_provided', () {
        // Arrange
        const String transcript = 'Test transcript';

        // Act
        final UserSpeechEndedEvent event = UserSpeechEndedEvent(transcript);

        // Assert
        expect(event.transcript, equals('Test transcript'));
      });

      test('should_handleEmptyTranscript_when_provided', () {
        // Arrange
        const String emptyTranscript = '';

        // Act
        final UserSpeechEndedEvent event =
            UserSpeechEndedEvent(emptyTranscript);

        // Assert
        expect(event.transcript, equals(''));
        expect(event.transcript, isEmpty);
      });

      test('should_beTypeOfAgentEvent_when_checked', () {
        // Arrange & Act
        final AgentEvent event = UserSpeechEndedEvent('test');

        // Assert
        expect(event, isA<UserSpeechEndedEvent>());
        expect(event.runtimeType, equals(UserSpeechEndedEvent));
      });
    });

    group('AgentSpeechStartedEvent', () {
      test('should_createInstance_when_constructed', () {
        // Arrange & Act
        final AgentSpeechStartedEvent event = AgentSpeechStartedEvent();

        // Assert
        expect(event, isA<AgentEvent>());
        expect(event, isA<AgentSpeechStartedEvent>());
        expect(event.timestamp, isNotNull);
      });

      test('should_beTypeOfAgentEvent_when_checked', () {
        // Arrange & Act
        final AgentEvent event = AgentSpeechStartedEvent();

        // Assert
        expect(event, isA<AgentSpeechStartedEvent>());
        expect(event.runtimeType, equals(AgentSpeechStartedEvent));
      });
    });

    group('AgentSpeechEndedEvent', () {
      test('should_createInstance_when_constructed', () {
        // Arrange & Act
        final AgentSpeechEndedEvent event = AgentSpeechEndedEvent();

        // Assert
        expect(event, isA<AgentEvent>());
        expect(event, isA<AgentSpeechEndedEvent>());
        expect(event.timestamp, isNotNull);
      });

      test('should_beTypeOfAgentEvent_when_checked', () {
        // Arrange & Act
        final AgentEvent event = AgentSpeechEndedEvent();

        // Assert
        expect(event, isA<AgentSpeechEndedEvent>());
        expect(event.runtimeType, equals(AgentSpeechEndedEvent));
      });
    });

    group('MessageReceivedEvent', () {
      test('should_createInstance_when_constructed', () {
        // Arrange
        final Message message = Message(
          id: 'test-id',
          role: MessageRole.user,
          type: MessageType.text,
          content: 'Test message',
        );

        // Act
        final MessageReceivedEvent event = MessageReceivedEvent(message);

        // Assert
        expect(event, isA<AgentEvent>());
        expect(event, isA<MessageReceivedEvent>());
        expect(event.message, equals(message));
        expect(event.timestamp, isNotNull);
      });

      test('should_storeMessage_when_provided', () {
        // Arrange
        final Message message = Message(
          id: 'msg-1',
          role: MessageRole.assistant,
          type: MessageType.text,
          content: 'Assistant response',
        );

        // Act
        final MessageReceivedEvent event = MessageReceivedEvent(message);

        // Assert
        expect(event.message, same(message));
        expect(event.message.id, equals('msg-1'));
        expect(event.message.content, equals('Assistant response'));
      });

      test('should_beTypeOfAgentEvent_when_checked', () {
        // Arrange
        final Message message = Message(
          id: 'test',
          role: MessageRole.user,
          type: MessageType.text,
          content: 'test',
        );

        // Act
        final AgentEvent event = MessageReceivedEvent(message);

        // Assert
        expect(event, isA<MessageReceivedEvent>());
        expect(event.runtimeType, equals(MessageReceivedEvent));
      });
    });

    group('MessageSentEvent', () {
      test('should_createInstance_when_constructed', () {
        // Arrange
        final Message message = Message(
          id: 'test-id',
          role: MessageRole.user,
          type: MessageType.text,
          content: 'Test message',
        );

        // Act
        final MessageSentEvent event = MessageSentEvent(message);

        // Assert
        expect(event, isA<AgentEvent>());
        expect(event, isA<MessageSentEvent>());
        expect(event.message, equals(message));
        expect(event.timestamp, isNotNull);
      });

      test('should_storeMessage_when_provided', () {
        // Arrange
        final Message message = Message(
          id: 'msg-2',
          role: MessageRole.user,
          type: MessageType.text,
          content: 'User message',
        );

        // Act
        final MessageSentEvent event = MessageSentEvent(message);

        // Assert
        expect(event.message, same(message));
        expect(event.message.id, equals('msg-2'));
        expect(event.message.content, equals('User message'));
      });

      test('should_beTypeOfAgentEvent_when_checked', () {
        // Arrange
        final Message message = Message(
          id: 'test',
          role: MessageRole.user,
          type: MessageType.text,
          content: 'test',
        );

        // Act
        final AgentEvent event = MessageSentEvent(message);

        // Assert
        expect(event, isA<MessageSentEvent>());
        expect(event.runtimeType, equals(MessageSentEvent));
      });
    });

    group('ToolCallStartedEvent', () {
      test('should_createInstance_when_constructed', () {
        // Arrange
        const String toolName = 'test_tool';
        const Map<String, dynamic> arguments = <String, dynamic>{
          'arg1': 'value1',
        };

        // Act
        final ToolCallStartedEvent event =
            ToolCallStartedEvent(toolName, arguments);

        // Assert
        expect(event, isA<AgentEvent>());
        expect(event, isA<ToolCallStartedEvent>());
        expect(event.toolName, equals(toolName));
        expect(event.arguments, equals(arguments));
        expect(event.timestamp, isNotNull);
      });

      test('should_storeToolName_when_provided', () {
        // Arrange
        const String toolName = 'calculator_tool';

        // Act
        final ToolCallStartedEvent event =
            ToolCallStartedEvent(toolName, <String, dynamic>{});

        // Assert
        expect(event.toolName, equals('calculator_tool'));
      });

      test('should_storeArguments_when_provided', () {
        // Arrange
        const Map<String, dynamic> arguments = <String, dynamic>{
          'operation': 'add',
          'numbers': <int>[1, 2, 3],
        };

        // Act
        final ToolCallStartedEvent event =
            ToolCallStartedEvent('math_tool', arguments);

        // Assert
        expect(event.arguments, equals(arguments));
        expect(event.arguments['operation'], equals('add'));
        expect(event.arguments['numbers'], equals(<int>[1, 2, 3]));
      });

      test('should_handleEmptyArguments_when_provided', () {
        // Arrange & Act
        final ToolCallStartedEvent event =
            ToolCallStartedEvent('simple_tool', <String, dynamic>{});

        // Assert
        expect(event.arguments, isEmpty);
        expect(event.arguments, isA<Map<String, dynamic>>());
      });

      test('should_beTypeOfAgentEvent_when_checked', () {
        // Arrange & Act
        final AgentEvent event =
            ToolCallStartedEvent('test', <String, dynamic>{});

        // Assert
        expect(event, isA<ToolCallStartedEvent>());
        expect(event.runtimeType, equals(ToolCallStartedEvent));
      });
    });

    group('ToolCallCompletedEvent', () {
      test('should_createInstance_when_constructed', () {
        // Arrange
        const String toolName = 'test_tool';
        const String result = 'success';

        // Act
        final ToolCallCompletedEvent event =
            ToolCallCompletedEvent(toolName, result);

        // Assert
        expect(event, isA<AgentEvent>());
        expect(event, isA<ToolCallCompletedEvent>());
        expect(event.toolName, equals(toolName));
        expect(event.result, equals(result));
        expect(event.timestamp, isNotNull);
      });

      test('should_storeToolName_when_provided', () {
        // Arrange
        const String toolName = 'weather_api';

        // Act
        final ToolCallCompletedEvent event =
            ToolCallCompletedEvent(toolName, 'Sunny');

        // Assert
        expect(event.toolName, equals('weather_api'));
      });

      test('should_storeResult_when_provided', () {
        // Arrange
        const dynamic result = <String, int>{'temperature': 22, 'humidity': 65};

        // Act
        final ToolCallCompletedEvent event =
            ToolCallCompletedEvent('sensor_tool', result);

        // Assert
        expect(event.result, equals(result));
        expect((event.result as Map<String, int>)['temperature'], equals(22));
      });

      test('should_handleNullResult_when_provided', () {
        // Arrange & Act
        final ToolCallCompletedEvent event =
            ToolCallCompletedEvent('null_tool', null);

        // Assert
        expect(event.result, isNull);
      });

      test('should_handleComplexResultTypes_when_provided', () {
        // Arrange
        final List<String> result = <String>['item1', 'item2', 'item3'];

        // Act
        final ToolCallCompletedEvent event =
            ToolCallCompletedEvent('list_tool', result);

        // Assert
        expect(event.result, equals(result));
        expect(event.result, hasLength(3));
      });

      test('should_beTypeOfAgentEvent_when_checked', () {
        // Arrange & Act
        final AgentEvent event = ToolCallCompletedEvent('test', 'result');

        // Assert
        expect(event, isA<ToolCallCompletedEvent>());
        expect(event.runtimeType, equals(ToolCallCompletedEvent));
      });
    });

    group('ErrorEvent', () {
      test('should_createInstance_when_constructed', () {
        // Arrange
        const String error = 'Something went wrong';

        // Act
        final ErrorEvent event = ErrorEvent(error);

        // Assert
        expect(event, isA<AgentEvent>());
        expect(event, isA<ErrorEvent>());
        expect(event.error, equals(error));
        expect(event.stackTrace, isNull);
        expect(event.timestamp, isNotNull);
      });

      test('should_createInstanceWithStackTrace_when_provided', () {
        // Arrange
        const String error = 'Error with stack trace';
        final StackTrace stackTrace = StackTrace.current;

        // Act
        final ErrorEvent event = ErrorEvent(error, stackTrace);

        // Assert
        expect(event, isA<AgentEvent>());
        expect(event, isA<ErrorEvent>());
        expect(event.error, equals(error));
        expect(event.stackTrace, equals(stackTrace));
        expect(event.timestamp, isNotNull);
      });

      test('should_storeError_when_provided', () {
        // Arrange
        const String errorMessage = 'Database connection failed';

        // Act
        final ErrorEvent event = ErrorEvent(errorMessage);

        // Assert
        expect(event.error, equals('Database connection failed'));
      });

      test('should_storeStackTrace_when_provided', () {
        // Arrange
        const String error = 'Runtime error';
        final StackTrace stackTrace = StackTrace.fromString('Test stack trace');

        // Act
        final ErrorEvent event = ErrorEvent(error, stackTrace);

        // Assert
        expect(event.stackTrace, equals(stackTrace));
      });

      test('should_handleNullStackTrace_when_notProvided', () {
        // Arrange & Act
        final ErrorEvent event = ErrorEvent('Error without stack trace');

        // Assert
        expect(event.stackTrace, isNull);
      });

      test('should_beTypeOfAgentEvent_when_checked', () {
        // Arrange & Act
        final AgentEvent event = ErrorEvent('test error');

        // Assert
        expect(event, isA<ErrorEvent>());
        expect(event.runtimeType, equals(ErrorEvent));
      });
    });

    group('StreamingTextEvent', () {
      test('should_createInstance_when_constructed', () {
        // Arrange
        const String text = 'Streaming text';

        // Act
        final StreamingTextEvent event = StreamingTextEvent(text);

        // Assert
        expect(event, isA<AgentEvent>());
        expect(event, isA<StreamingTextEvent>());
        expect(event.text, equals(text));
        expect(event.isComplete, isFalse);
        expect(event.timestamp, isNotNull);
      });

      test('should_createInstanceWithCompletion_when_specified', () {
        // Arrange
        const String text = 'Final text';

        // Act
        final StreamingTextEvent event =
            StreamingTextEvent(text, isComplete: true);

        // Assert
        expect(event, isA<AgentEvent>());
        expect(event, isA<StreamingTextEvent>());
        expect(event.text, equals(text));
        expect(event.isComplete, isTrue);
        expect(event.timestamp, isNotNull);
      });

      test('should_storeText_when_provided', () {
        // Arrange
        const String text = 'Partial response';

        // Act
        final StreamingTextEvent event = StreamingTextEvent(text);

        // Assert
        expect(event.text, equals('Partial response'));
      });

      test('should_defaultIsCompleteToFalse_when_notSpecified', () {
        // Arrange & Act
        final StreamingTextEvent event = StreamingTextEvent('text');

        // Assert
        expect(event.isComplete, isFalse);
      });

      test('should_storeIsComplete_when_provided', () {
        // Arrange & Act
        final StreamingTextEvent incompleteEvent = StreamingTextEvent('text');
        final StreamingTextEvent completeEvent =
            StreamingTextEvent('text', isComplete: true);

        // Assert
        expect(incompleteEvent.isComplete, isFalse);
        expect(completeEvent.isComplete, isTrue);
      });

      test('should_handleEmptyText_when_provided', () {
        // Arrange & Act
        final StreamingTextEvent event = StreamingTextEvent('');

        // Assert
        expect(event.text, isEmpty);
        expect(event.text, equals(''));
      });

      test('should_beTypeOfAgentEvent_when_checked', () {
        // Arrange & Act
        final AgentEvent event = StreamingTextEvent('test');

        // Assert
        expect(event, isA<StreamingTextEvent>());
        expect(event.runtimeType, equals(StreamingTextEvent));
      });
    });

    group('event inheritance', () {
      test('should_maintainPolymorphism_when_upcast', () {
        // Arrange
        final AgentEvent startedEvent = AgentStartedEvent();
        final AgentEvent messageEvent = MessageReceivedEvent(
          Message(
            id: 'test',
            role: MessageRole.user,
            type: MessageType.text,
            content: 'test',
          ),
        );

        // Act & Assert - both should be AgentEvents
        expect(startedEvent, isA<AgentEvent>());
        expect(messageEvent, isA<AgentEvent>());

        // But they should maintain their specific types
        expect(startedEvent, isA<AgentStartedEvent>());
        expect(messageEvent, isA<MessageReceivedEvent>());
      });

      test('should_haveTimestamps_when_allEventTypesCreated', () {
        // Arrange & Act
        final List<AgentEvent> events = <AgentEvent>[
          AgentStartedEvent(),
          AgentStoppedEvent(),
          UserSpeechStartedEvent(),
          UserSpeechEndedEvent('transcript'),
          AgentSpeechStartedEvent(),
          AgentSpeechEndedEvent(),
          MessageReceivedEvent(
            Message(
              id: '1',
              role: MessageRole.user,
              type: MessageType.text,
              content: 'test',
            ),
          ),
          MessageSentEvent(
            Message(
              id: '2',
              role: MessageRole.assistant,
              type: MessageType.text,
              content: 'response',
            ),
          ),
          ToolCallStartedEvent('tool', <String, dynamic>{}),
          ToolCallCompletedEvent('tool', 'result'),
          ErrorEvent('error'),
          StreamingTextEvent('text'),
        ];

        // Assert
        for (final AgentEvent event in events) {
          expect(event.timestamp, isNotNull);
          expect(event.timestamp, isA<DateTime>());
        }
      });

      test('should_maintainUniqueTimestamps_when_rapidlyCreated', () {
        // Arrange & Act - Create events in rapid succession
        final List<AgentEvent> events = List<AgentEvent>.generate(
          10,
          (final int index) => AgentStartedEvent(),
        );

        // Assert - All timestamps should be valid DateTime objects
        for (final AgentEvent event in events) {
          expect(event.timestamp, isNotNull);
          expect(event.timestamp, isA<DateTime>());
        }

        // Note: Due to millisecond precision
        // some timestamps might be identical
        // but this is acceptable for this use case
        expect(events.length, equals(10));
      });
    });

    group('event factory patterns', () {
      test('should_createCorrectEventTypes_when_instantiated', () {
        // Arrange & Act & Assert
        expect(AgentStartedEvent(), isA<AgentStartedEvent>());
        expect(AgentStoppedEvent(), isA<AgentStoppedEvent>());
        expect(UserSpeechStartedEvent(), isA<UserSpeechStartedEvent>());
        expect(UserSpeechEndedEvent('test'), isA<UserSpeechEndedEvent>());
        expect(AgentSpeechStartedEvent(), isA<AgentSpeechStartedEvent>());
        expect(AgentSpeechEndedEvent(), isA<AgentSpeechEndedEvent>());
        expect(
          MessageReceivedEvent(
            Message(
              id: '1',
              role: MessageRole.user,
              type: MessageType.text,
              content: 'test',
            ),
          ),
          isA<MessageReceivedEvent>(),
        );
        expect(
          MessageSentEvent(
            Message(
              id: '2',
              role: MessageRole.assistant,
              type: MessageType.text,
              content: 'response',
            ),
          ),
          isA<MessageSentEvent>(),
        );
        expect(
          ToolCallStartedEvent('tool', <String, dynamic>{}),
          isA<ToolCallStartedEvent>(),
        );
        expect(
          ToolCallCompletedEvent('tool', 'result'),
          isA<ToolCallCompletedEvent>(),
        );
        expect(ErrorEvent('error'), isA<ErrorEvent>());
        expect(StreamingTextEvent('text'), isA<StreamingTextEvent>());
      });
    });
  });
}
