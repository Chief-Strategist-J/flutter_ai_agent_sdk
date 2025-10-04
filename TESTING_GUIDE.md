# Flutter AI Agent SDK - Testing Guide

## Overview
This guide ensures 100% code coverage and strict adherence to production-quality standards.

## Current Status

### Source Files: 29 Dart files
### Test Files: 5 test files (needs expansion to 24+ more)

## Test Coverage Requirements

### ✅ Already Tested (5/29)
1. `lib/src/core/agents/agent_config.dart` → `test/unit/agent_config_test.dart`
2. `lib/src/memory/conversation_memory.dart` → `test/unit/conversation_memory_test.dart`
3. `lib/src/core/models/message.dart` → `test/unit/message_test.dart`
4. `lib/src/core/sessions/session_state.dart` → `test/unit/session_state_test.dart`
5. `lib/src/tools/tool.dart` → `test/unit/tool_test.dart`

### ❌ Missing Tests (24 files)

#### Core Module (3 files)
- [ ] `lib/src/core/agents/voice_agent.dart`
- [ ] `lib/src/core/sessions/agent_session.dart`
- [ ] `lib/src/core/events/agent_events.dart`

#### LLM Module (4 files)
- [ ] `lib/src/llm/providers/llm_provider.dart`
- [ ] `lib/src/llm/providers/openai_provider.dart`
- [ ] `lib/src/llm/providers/anthropic_provider.dart`
- [ ] `lib/src/llm/chat/chat_context.dart`
- [ ] `lib/src/llm/streaming/stream_processor.dart`

#### Memory Module (1 file)
- [ ] `lib/src/memory/memory_store.dart`

#### Tools Module (2 files)
- [ ] `lib/src/tools/tool_executor.dart`
- [ ] `lib/src/tools/function_tool.dart`

#### Voice Module (8 files)
- [ ] `lib/src/voice/audio/audio_player_service.dart`
- [ ] `lib/src/voice/audio/audio_recorder_service.dart`
- [ ] `lib/src/voice/stt/speech_recognition_service.dart`
- [ ] `lib/src/voice/stt/native_stt_service.dart`
- [ ] `lib/src/voice/tts/text_to_speech_service.dart`
- [ ] `lib/src/voice/tts/native_tts_service.dart`
- [ ] `lib/src/voice/vad/voice_activity_detector.dart`
- [ ] `lib/src/voice/vad/energy_based_vad.dart`

#### Utils Module (2 files)
- [ ] `lib/src/utils/audio_utils.dart`
- [ ] `lib/src/utils/logger.dart`

#### Models Module (2 files)
- [ ] `lib/src/core/models/turn_detection.dart`
- [ ] `lib/src/core/models/message.g.dart` (generated - skip)

## Critical Issues to Fix

### 1. Documentation Issues
All public members must have documentation comments:

```dart
/// Manages voice agent sessions and interactions.
///
/// This class provides a high-level interface for creating and managing
/// voice agent sessions with automatic lifecycle management.
class VoiceAgent {
  /// Creates a new VoiceAgent with the given configuration.
  VoiceAgent({required this.config});
  
  /// The configuration for this voice agent.
  final AgentConfig config;
}
```

### 2. Type Annotation Issues
All variables must have explicit types:

```dart
// ❌ Bad
var result = await someFunction();

// ✅ Good
final String result = await someFunction();
```

### 3. Import Ordering
Imports must be sorted alphabetically:

```dart
// ✅ Correct order
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

import 'package:flutter_ai_agent_sdk/src/core/agents/agent_config.dart';
```

### 4. Final Parameters
All parameters should be final:

```dart
// ❌ Bad
Future<void> processMessage(Message message) async { }

// ✅ Good
Future<void> processMessage(final Message message) async { }
```

## Testing Standards

### Unit Test Structure

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_ai_agent_sdk/src/path/to/class.dart';

void main() {
  group('ClassName', () {
    late ClassName instance;
    
    setUp(() {
      instance = ClassName();
    });
    
    tearDown(() {
      // Cleanup
    });
    
    group('methodName', () {
      test('should behave correctly under normal conditions', () {
        // Arrange
        const String input = 'test';
        
        // Act
        final String result = instance.methodName(input);
        
        // Assert
        expect(result, equals('expected'));
      });
      
      test('should handle edge case', () {
        // Test edge cases
      });
      
      test('should throw exception on invalid input', () {
        expect(
          () => instance.methodName('invalid'),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}
```

### Coverage Requirements

1. **100% Line Coverage**: Every line must be executed
2. **100% Branch Coverage**: Every conditional path tested
3. **Edge Cases**: Null, empty, boundary values
4. **Error Cases**: All exceptions and error paths
5. **Async Operations**: Proper async/await testing
6. **Resource Cleanup**: Dispose, close, cancel tested

### Mock Testing Pattern

```dart
class MockLLMProvider extends Mock implements LLMProvider {}

void main() {
  group('VoiceAgent with mocks', () {
    late MockLLMProvider mockProvider;
    late VoiceAgent agent;
    
    setUp(() {
      mockProvider = MockLLMProvider();
      agent = VoiceAgent(
        config: AgentConfig(llmProvider: mockProvider),
      );
    });
    
    test('should call provider correctly', () async {
      // Setup mock
      when(() => mockProvider.generate(
        messages: any(named: 'messages'),
      )).thenAnswer((_) async => LLMResponse(content: 'response'));
      
      // Execute
      await agent.createSession();
      
      // Verify
      verify(() => mockProvider.generate(
        messages: any(named: 'messages'),
      )).called(1);
    });
  });
}
```

## Running Tests

### Local Testing

```bash
# Run the comprehensive test script
./test_local.sh

# Or manually
flutter test --coverage --reporter expanded

# View coverage
open coverage/html/index.html
```

### CI Testing
Tests run automatically on:
- Every push to main/develop
- Every pull request
- Manual workflow dispatch

## Code Quality Checklist

Before committing, ensure:

- [ ] All public APIs documented with `///` comments
- [ ] All types explicitly annotated
- [ ] All parameters marked as `final`
- [ ] Imports sorted alphabetically
- [ ] No `TODO` or `FIXME` in production code
- [ ] All tests pass: `flutter test`
- [ ] Code formatted: `dart format .`
- [ ] Analysis passes: `flutter analyze --fatal-infos`
- [ ] Coverage ≥ 80%: Check `coverage/html/index.html`
- [ ] No unused imports or variables
- [ ] All resources properly disposed

## Next Steps

1. **Phase 1**: Fix all lint errors in existing code
   - Add missing documentation
   - Fix import ordering
   - Add type annotations
   - Make parameters final

2. **Phase 2**: Create missing tests (24 files)
   - Start with critical modules (core, llm)
   - Then tools and memory
   - Finally voice and utils

3. **Phase 3**: Achieve 100% coverage
   - Identify uncovered lines
   - Add tests for edge cases
   - Test all error paths

4. **Phase 4**: Performance testing
   - Memory leak tests
   - Stress tests
   - Integration tests

## Resources

- **Test Logs**: `test_logs/`
- **Coverage Report**: `coverage/html/index.html`
- **CI Workflow**: `.github/workflows/dart-ci.yml`
- **CodeRabbit Config**: `.coderabbit.yaml`
- **Analysis Rules**: `analysis_options.yaml`
