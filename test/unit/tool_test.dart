import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ai_agent_sdk/flutter_ai_agent_sdk.dart';

void main() {
  group('FunctionTool', () {
    test('should have all required fields', () {
      final FunctionTool tool = FunctionTool(
        name: 'test_tool',
        description: 'A test tool',
        parameters: <String, dynamic>{'type': 'object'},
        function: (final Map<String, dynamic> args) async => 'result',
      );

      expect(tool.name, 'test_tool');
      expect(tool.description, 'A test tool');
      expect(tool.parameters, <String, String>{'type': 'object'});
    });

    test('should execute function', () async {
      final FunctionTool tool = FunctionTool(
        name: 'add',
        description: 'Add two numbers',
        parameters: <String, dynamic>{'type': 'object'},
        function: (final Map<String, dynamic> args) async {
          final int a = args['a'] as int;
          final int b = args['b'] as int;
          return a + b;
        },
      );

      final result = await tool.execute(<String, dynamic>{'a': 5, 'b': 3});
      expect(result, 8);
    });

    test('should convert to JSON', () {
      final FunctionTool tool = FunctionTool(
        name: 'test_tool',
        description: 'A test tool',
        parameters: <String, dynamic>{
          'type': 'object',
          'properties': <String, Map<String, String>>{
            'param': <String, String>{'type': 'string'},
          },
        },
        function: (final Map<String, dynamic> args) async => 'result',
      );

      final Map<String, dynamic> json = tool.toJson();

      expect(json['type'], 'function');
      expect(json['function']['name'], 'test_tool');
      expect(json['function']['description'], 'A test tool');
      expect(json['function']['parameters'], isNotNull);
    });
  });

  group('ToolExecutor', () {
    test('should have all required fields', () {
      final FunctionTool tool = FunctionTool(
        name: 'test',
        description: 'Test',
        parameters: <String, dynamic>{},
        function: (final Map<String, dynamic> args) async => 'result',
      );

      final ToolExecutor executor = ToolExecutor(tools: <Tool>[tool]);

      expect(executor.tools.length, 1);
      expect(executor.hasTool('test'), true);
      expect(executor.hasTool('missing'), false);
    });

    test('should execute tool by name', () async {
      final FunctionTool tool = FunctionTool(
        name: 'greet',
        description: 'Greet someone',
        parameters: <String, dynamic>{},
        function: (final Map<String, dynamic> args) async =>
            'Hello, ${args['name']}!',
      );

      final ToolExecutor executor = ToolExecutor(tools: <Tool>[tool]);
      final result =
          await executor.execute('greet', <String, dynamic>{'name': 'Alice'});

      expect(result, 'Hello, Alice!');
    });

    test('should throw error for missing tool', () async {
      final ToolExecutor executor = ToolExecutor(tools: <Tool>[]);

      expect(
        () => executor.execute('missing', <String, dynamic>{}),
        throwsA(isA<Exception>()),
      );
    });
  });
}
