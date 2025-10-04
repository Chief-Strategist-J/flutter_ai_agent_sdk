import 'dart:async';

abstract class Tool {
  String get name;
  String get description;
  Map<String, dynamic> get parameters;

  Future<dynamic> execute(final Map<String, dynamic> arguments);

  Map<String, dynamic> toJson() => {
        'type': 'function',
        'function': {
          'name': name,
          'description': description,
          'parameters': parameters,
        },
      };
}
