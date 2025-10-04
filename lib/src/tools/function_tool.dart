import 'dart:async';
import 'package:flutter_ai_agent_sdk/src/tools/tool.dart';

/// Signature for a tool function.
///
/// Accepts a map of arguments and returns a future
/// resolving to any result type.
typedef ToolFunction = Future<dynamic> Function(Map<String, dynamic> args);

/// A [Tool] implemented as a callable function.
///
/// Wraps a Dart function with metadata such as [name],
/// [description], and [parameters].
class FunctionTool extends Tool {
  /// Creates a [FunctionTool].
  ///
  /// - [name]: Unique identifier for the tool.
  /// - [description]: Explanation of what the tool does.
  /// - [parameters]: Schema for accepted arguments.
  /// - [function]: The function to execute.
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

  /// The underlying function implementation.
  final ToolFunction function;

  @override
  Future<dynamic> execute(final Map<String, dynamic> arguments) =>
      function(arguments);
}
