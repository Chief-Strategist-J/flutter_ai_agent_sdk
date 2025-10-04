import 'package:flutter_ai_agent_sdk/flutter_ai_agent_sdk.dart';
import 'package:flutter_test/flutter_test.dart';

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

      final dynamic result =
          await tool.execute(<String, dynamic>{'a': 5, 'b': 3});
      expect(result, 8);
    });

    test('should convert to JSON', () async {
      final FunctionTool tool = FunctionTool(
        name: 'test_tool',
        description: 'A test tool',
        parameters: <String, dynamic>{
          'type': 'object',
          'properties': <String, dynamic>{
            'param': <String, dynamic>{'type': 'string'},
          },
        },
        function: (final Map<String, dynamic> args) async => 'result',
      );

      final Map<String, dynamic> json = tool.toJson();

      // Top-level
      expect(json['type'], equals('function'));

      // function block
      final Object? functionObj = json['function'];
      if (functionObj is! Map<String, dynamic>) {
        fail('`function` must be a Map<String, dynamic>');
      }
      final Map<String, dynamic> functionMap = functionObj;

      expect(functionMap['name'], equals('test_tool'));
      expect(functionMap['description'], equals('A test tool'));

      // parameters
      final Object? paramsObj = functionMap['parameters'];
      if (paramsObj is! Map<String, dynamic>) {
        fail('`parameters` must be a Map<String, dynamic>');
      }
      final Map<String, dynamic> params = paramsObj;

      expect(params['type'], equals('object'));

      // properties
      final Object? propsObj = params['properties'];
      if (propsObj is! Map<String, dynamic>) {
        fail('`properties` must be a Map<String, dynamic>');
      }
      final Map<String, dynamic> properties = propsObj;

      // param schema
      final Object? paramSchemaObj = properties['param'];
      if (paramSchemaObj is! Map<String, dynamic>) {
        fail('`properties.param` must be a Map<String, dynamic>');
      }
      final Map<String, dynamic> paramSchema = paramSchemaObj;

      expect(paramSchema['type'], equals('string'));
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
        function: (final Map<String, dynamic> args) async {
          final String name = args['name'] as String; // explicit cast
          return 'Hello, $name!';
        },
      );

      final ToolExecutor executor = ToolExecutor(tools: <Tool>[tool]);

      final Object? result =
          await executor.execute('greet', <String, dynamic>{'name': 'Alice'});

      expect(result, equals('Hello, Alice!'));
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
