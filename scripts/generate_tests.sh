#!/bin/bash

# Script to generate test file templates for untested source files

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}ℹ [INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}✓ [SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}⚠ [WARNING]${NC} $1"
}

echo ""
echo -e "${BLUE}═══════════════════════════════════════════════${NC}"
echo -e "${BLUE}  Test Template Generator${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════${NC}"
echo ""

# Files that need tests
UNTESTED_FILES=(
    "lib/src/core/agents/voice_agent.dart:test/unit/voice_agent_test.dart"
    "lib/src/core/sessions/agent_session.dart:test/unit/agent_session_test.dart"
    "lib/src/core/events/agent_events.dart:test/unit/agent_events_test.dart"
    "lib/src/llm/providers/llm_provider.dart:test/unit/llm_provider_test.dart"
    "lib/src/llm/providers/openai_provider.dart:test/unit/openai_provider_test.dart"
    "lib/src/llm/providers/anthropic_provider.dart:test/unit/anthropic_provider_test.dart"
    "lib/src/llm/chat/chat_context.dart:test/unit/chat_context_test.dart"
    "lib/src/llm/streaming/stream_processor.dart:test/unit/stream_processor_test.dart"
    "lib/src/memory/memory_store.dart:test/unit/memory_store_test.dart"
    "lib/src/tools/tool_executor.dart:test/unit/tool_executor_test.dart"
    "lib/src/tools/function_tool.dart:test/unit/function_tool_test.dart"
    "lib/src/voice/audio/audio_player_service.dart:test/unit/audio_player_service_test.dart"
    "lib/src/voice/audio/audio_recorder_service.dart:test/unit/audio_recorder_service_test.dart"
    "lib/src/voice/stt/speech_recognition_service.dart:test/unit/speech_recognition_service_test.dart"
    "lib/src/voice/stt/native_stt_service.dart:test/unit/native_stt_service_test.dart"
    "lib/src/voice/tts/text_to_speech_service.dart:test/unit/text_to_speech_service_test.dart"
    "lib/src/voice/tts/native_tts_service.dart:test/unit/native_tts_service_test.dart"
    "lib/src/voice/vad/voice_activity_detector.dart:test/unit/voice_activity_detector_test.dart"
    "lib/src/voice/vad/energy_based_vad.dart:test/unit/energy_based_vad_test.dart"
    "lib/src/utils/audio_utils.dart:test/unit/audio_utils_test.dart"
    "lib/src/utils/logger.dart:test/unit/logger_test.dart"
    "lib/src/core/models/turn_detection.dart:test/unit/turn_detection_test.dart"
)

CREATED_COUNT=0
SKIPPED_COUNT=0

for entry in "${UNTESTED_FILES[@]}"; do
    IFS=':' read -r source_file test_file <<< "$entry"
    
    if [ -f "$test_file" ]; then
        log_warning "Skipped: $test_file (already exists)"
        ((SKIPPED_COUNT++))
        continue
    fi
    
    # Extract class name from source file
    class_name=$(basename "$source_file" .dart | sed 's/_\([a-z]\)/\U\1/g' | sed 's/^\([a-z]\)/\U\1/')
    
    # Create test directory if needed
    mkdir -p "$(dirname "$test_file")"
    
    # Generate test template
    cat > "$test_file" << EOF
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_ai_agent_sdk/${source_file#lib/}';

void main() {
  group('${class_name}', () {
    late ${class_name} instance;
    
    setUp(() {
      // TODO: Initialize instance
      // instance = ${class_name}();
    });
    
    tearDown(() {
      // TODO: Cleanup resources
    });
    
    group('constructor', () {
      test('should create instance with valid parameters', () {
        // Arrange & Act
        // TODO: Create instance with valid parameters
        
        // Assert
        // TODO: Verify instance is created correctly
      });
      
      test('should throw exception with invalid parameters', () {
        // Arrange, Act & Assert
        // TODO: Test invalid parameter handling
      });
    });
    
    group('public methods', () {
      test('should perform expected behavior', () {
        // Arrange
        // TODO: Setup test data
        
        // Act
        // TODO: Call method under test
        
        // Assert
        // TODO: Verify expected behavior
      });
      
      test('should handle edge cases', () {
        // TODO: Test edge cases (null, empty, boundary values)
      });
      
      test('should handle errors correctly', () {
        // TODO: Test error scenarios
      });
    });
    
    group('async operations', () {
      test('should complete successfully', () async {
        // TODO: Test async operations
      });
      
      test('should handle async errors', () async {
        // TODO: Test async error handling
      });
    });
    
    group('resource cleanup', () {
      test('should dispose resources properly', () {
        // TODO: Test dispose/close/cancel methods
      });
    });
  });
}
EOF
    
    log_success "Created: $test_file"
    ((CREATED_COUNT++))
done

echo ""
echo -e "${BLUE}═══════════════════════════════════════════════${NC}"
echo -e "${GREEN}✓ Generated $CREATED_COUNT test files${NC}"
echo -e "${YELLOW}⚠ Skipped $SKIPPED_COUNT existing files${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════${NC}"
echo ""

log_info "Next steps:"
log_info "  1. Implement the TODOs in each generated test file"
log_info "  2. Run tests: flutter test"
log_info "  3. Check coverage: open coverage/html/index.html"
log_info "  4. Aim for 100% coverage!"

exit 0
