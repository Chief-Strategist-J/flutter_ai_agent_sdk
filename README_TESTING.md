# Testing Infrastructure - Quick Start

## 🚀 Quick Start

### Run All Tests Locally
```bash
# Comprehensive test suite with detailed logs
./test_local.sh
```

This will:
- ✅ Validate environment
- ✅ Run all tests with coverage
- ✅ Generate HTML coverage report
- ✅ Check for lint errors
- ✅ Validate package structure
- ✅ Create detailed logs in `test_logs/`

### View Coverage Report
```bash
# After running tests
open coverage/html/index.html  # macOS
xdg-open coverage/html/index.html  # Linux
```

## 📊 Current Status

### Test Coverage
- **Current**: ~17% (5/29 files tested)
- **Target**: 100%
- **Files Tested**: 5
- **Files Need Tests**: 24

### Code Quality
- **Lint Errors**: 200+ (must fix)
- **Documentation**: ~10% complete
- **Package Score**: TBD (run `./test_local.sh`)

## 🔧 Development Workflow

### Before Coding
```bash
# Ensure clean state
flutter clean
flutter pub get
```

### While Coding
```bash
# Auto-format on save (configure your IDE)
# Or manually:
dart format .
```

### Before Committing
```bash
# 1. Format
dart format .

# 2. Analyze
flutter analyze --fatal-infos

# 3. Test
./test_local.sh

# 4. Review coverage
open coverage/html/index.html
```

### Commit
```bash
git add .
git commit -m "feat: add feature X with tests"
git push
```

## 📝 Create Missing Tests

### Generate Test Templates
```bash
# Creates 24 test file templates
./scripts/generate_tests.sh
```

This generates test files with TODO markers for:
- Constructor tests
- Public method tests
- Edge case tests
- Error handling tests
- Async operation tests
- Resource cleanup tests

### Implement Tests

1. **Open generated test file**
   ```bash
   # Example
   code test/unit/voice_agent_test.dart
   ```

2. **Replace TODOs with actual tests**
   ```dart
   test('should create instance with valid parameters', () {
     // Arrange
     final AgentConfig config = AgentConfig(
       llmProvider: mockProvider,
     );
     
     // Act
     final VoiceAgent agent = VoiceAgent(config: config);
     
     // Assert
     expect(agent, isNotNull);
     expect(agent.config, equals(config));
   });
   ```

3. **Run specific test**
   ```bash
   flutter test test/unit/voice_agent_test.dart
   ```

4. **Check coverage**
   ```bash
   flutter test --coverage
   open coverage/html/index.html
   ```

## 🎯 Testing Standards

### Test Structure
```dart
group('ClassName', () {
  late ClassName instance;
  late MockDependency mockDep;
  
  setUp(() {
    mockDep = MockDependency();
    instance = ClassName(dependency: mockDep);
  });
  
  tearDown(() {
    // Clean up resources
  });
  
  test('should do something', () {
    // Arrange - Set up test data
    const String input = 'test';
    
    // Act - Execute the code under test
    final String result = instance.method(input);
    
    // Assert - Verify the result
    expect(result, equals('expected'));
  });
});
```

### Coverage Goals
- **Line Coverage**: 100%
- **Branch Coverage**: 100%
- **Edge Cases**: All tested
- **Error Paths**: All tested
- **Async Operations**: All tested
- **Resource Cleanup**: All tested

## 🐛 Common Issues

### Tests Fail
```bash
# Run with verbose output
flutter test --reporter expanded

# Run single test
flutter test test/unit/specific_test.dart

# Debug specific test
flutter test test/unit/specific_test.dart --name "test name"
```

### Coverage Not Generated
```bash
# Ensure lcov is installed
brew install lcov  # macOS
sudo apt-get install lcov  # Linux

# Generate coverage manually
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

### Analysis Errors
```bash
# See all errors
flutter analyze > errors.txt
cat errors.txt

# Fix common issues
dart format .  # Fix formatting
# Then fix remaining manually
```

## 📚 Documentation

- **Complete Guide**: `TESTING_GUIDE.md`
- **CodeRabbit Setup**: `CODERABBIT_SETUP.md`
- **Setup Summary**: `SETUP_COMPLETE.md`
- **Analysis Rules**: `analysis_options.yaml`

## 🤖 CI/CD

Tests run automatically on:
- Every push to `main` or `develop`
- Every pull request
- Manual workflow dispatch

View results at: https://github.com/Chief-Strategist-J/flutter_ai_agent_sdk/actions

## 💡 Tips

1. **Write tests first** (TDD approach)
2. **Test edge cases** (null, empty, max, min)
3. **Test error paths** (exceptions, failures)
4. **Mock external dependencies**
5. **Clean up resources** (dispose, close)
6. **Use descriptive test names**
7. **One assertion per test** (when possible)
8. **Keep tests simple and readable**

## 🎓 Example Test

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_ai_agent_sdk/src/tools/tool_executor.dart';
import 'package:flutter_ai_agent_sdk/src/tools/tool.dart';

class MockTool extends Mock implements Tool {}

void main() {
  group('ToolExecutor', () {
    late ToolExecutor executor;
    late MockTool mockTool;
    
    setUp(() {
      mockTool = MockTool();
      when(() => mockTool.name).thenReturn('test_tool');
      executor = ToolExecutor(tools: [mockTool]);
    });
    
    group('execute', () {
      test('should execute tool successfully', () async {
        // Arrange
        final Map<String, dynamic> args = {'param': 'value'};
        when(() => mockTool.execute(any()))
            .thenAnswer((_) async => 'result');
        
        // Act
        final dynamic result = await executor.execute('test_tool', args);
        
        // Assert
        expect(result, equals('result'));
        verify(() => mockTool.execute(args)).called(1);
      });
      
      test('should throw when tool not found', () {
        // Arrange
        final Map<String, dynamic> args = {};
        
        // Act & Assert
        expect(
          () => executor.execute('unknown_tool', args),
          throwsA(isA<Exception>()),
        );
      });
    });
    
    group('hasTool', () {
      test('should return true for existing tool', () {
        expect(executor.hasTool('test_tool'), isTrue);
      });
      
      test('should return false for non-existing tool', () {
        expect(executor.hasTool('unknown'), isFalse);
      });
    });
  });
}
```

## 🎯 Your Next Steps

1. **Fix lint errors** (200+)
   - Add documentation
   - Fix imports
   - Add type annotations

2. **Generate test templates**
   ```bash
   ./scripts/generate_tests.sh
   ```

3. **Implement tests** (start with core)
   - VoiceAgent
   - AgentSession
   - LLMProvider implementations

4. **Run tests**
   ```bash
   ./test_local.sh
   ```

5. **Review coverage**
   ```bash
   open coverage/html/index.html
   ```

6. **Repeat until 100% coverage**

## 📞 Help

- Review `TESTING_GUIDE.md` for detailed patterns
- Check existing tests in `test/unit/` for examples
- Run `./test_local.sh` for detailed logs
- CI logs available on GitHub Actions

---

**Happy Testing! 🧪**
