import 'package:logger/logger.dart';

/// Logger utility for agents.
///
/// Wraps the [Logger] package with convenience methods
/// for debug, info, warning, and error logging.
class AgentLogger {
  /// Internal logger instance with pretty printing.
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  /// Logs a debug [message].
  static void debug(final String message) {
    _logger.d(message);
  }

  /// Logs an info [message].
  static void info(final String message) {
    _logger.i(message);
  }

  /// Logs a warning [message].
  static void warning(final String message) {
    _logger.w(message);
  }

  /// Logs an error [message] with optional [error] and
  /// [stackTrace].
  static void error(
      final String message, final Object? error, final StackTrace? stackTrace) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }
}
