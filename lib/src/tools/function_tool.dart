import 'dart:async';
import 'package:flutter_ai_agent_sdk/src/tools/tool.dart';

typedef ToolFunction = Future<dynamic> Function(Map<String, dynamic> args);

class FunctionTool extends Tool {
  
  FunctionTool({
    required this.name,
    required this.description,
    required this.parameters,
    required this.function,
  });
  @override
  final String name;
  
  @override
  final String description;
  
  @override
  final Map<String, dynamic> parameters;
  
  final ToolFunction function;
  
  @override
  Future<dynamic> execute(final Map<String, dynamic> arguments) async => await function(arguments);
}
