import 'dart:async';

/// Base class for all tools.
///
/// A [Tool] defines metadata and an [execute] method
/// that performs the tool’s action. Tools can be
/// serialized to JSON for LLM integration.
abstract class Tool {
  /// Unique name of the tool.
  String get name;

  /// Description of what the tool does.
  String get description;

  /// JSON schema of accepted input parameters.
  ///
  /// Keep the dynamic value type to allow arbitrary JSON schema shapes.
  Map<String, dynamic> get parameters;

  /// Executes the tool with the given [arguments].
  Future<dynamic> execute(final Map<String, dynamic> arguments);

  /// Converts the tool into JSON format.
  ///
  /// Returns a function-style schema including [name],
  /// [description], and [parameters].
  Map<String, dynamic> toJson() {
    // Debug-only sanity checks (no behavior change in release).
    assert(name.isNotEmpty, 'Tool.name must be non-empty');
    assert(description.isNotEmpty, 'Tool.description must be non-empty');

    final Map<String, dynamic> functionSpec = <String, dynamic>{
      'name': name,
      'description': description,
      'parameters': parameters, // already Map<String, dynamic>
    };

    return <String, dynamic>{
      'type': 'function',
      'function': functionSpec,
    };
  }
}
