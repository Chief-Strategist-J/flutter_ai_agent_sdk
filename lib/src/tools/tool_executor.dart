import 'package:flutter_ai_agent_sdk/src/tools/tool.dart';

class ToolExecutor {
  
  ToolExecutor({required List<Tool> tools})
      : _tools = {for (var tool in tools) tool.name: tool};
  final Map<String, Tool> _tools;
  
  Future<dynamic> execute(final String toolName, final Map<String, dynamic> arguments) async {
    final Tool? tool = _tools[toolName];
    if (tool == null) {
      throw Exception('Tool not found: $toolName');
    }
    
    return tool.execute(arguments);
  }
  
  bool hasTool(final String name) => _tools.containsKey(name);
  
  List<Tool> get tools => _tools.values.toList();
}
