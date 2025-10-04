import 'package:logger/logger.dart';

class AgentLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      errorMethodCount: 8,
      printTime: true,
    ),
  );
  
  static void debug(final String message) {
    _logger.d(message);
  }
  
  static void info(final String message) {
    _logger.i(message);
  }
  
  static void warning(final String message) {
    _logger.w(message);
  }
  
  static void error(final String message, final Object? error, final StackTrace? stackTrace) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }
}
