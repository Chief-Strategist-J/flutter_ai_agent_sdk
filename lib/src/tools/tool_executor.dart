import 'dart:collection' show UnmodifiableListView;
import 'package:flutter_ai_agent_sdk/src/tools/tool.dart';

/// Executes registered [Tool] instances by name.
///
/// Provides a simple interface to check for tools and
/// run them with given arguments.
class ToolExecutor {
  /// Creates a [ToolExecutor] with the given [tools].
  ///
  /// Tools are stored in a map keyed by their [Tool.name].
  /// Names must be non-empty and unique.
  ToolExecutor({required final List<Tool> tools})
      : assert(
          tools.every((final Tool t) => t.name.isNotEmpty),
          'Tool names must be non-empty',
        ),
        _tools = <String, Tool>{
          for (final Tool tool in tools) tool.name: tool,
        };

  /// Internal map of tools by name.
  final Map<String, Tool> _tools;

  /// Executes the tool with [toolName] and [arguments].
  ///
  /// Throws an [Exception] if the tool is not found.
  Future<dynamic> execute(
    final String toolName,
    final Map<String, dynamic> arguments,
  ) async {
    final Tool? tool = _tools[toolName];
    if (tool == null) {
      throw Exception('Tool not found: $toolName');
    }
    // Keep original API: arguments typed as Map<String, dynamic>,
    //return dynamic.
    return tool.execute(arguments);
  }

  /// Returns true if a tool with the given [name] exists.
  bool hasTool(final String name) => _tools.containsKey(name);

  /// Returns a list of all registered tools (read-only view).
  List<Tool> get tools => UnmodifiableListView<Tool>(_tools.values);
}
