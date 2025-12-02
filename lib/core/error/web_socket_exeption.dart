
import 'app_exceptions.dart';

class WebSocketException extends AppException {
  final WebSocketErrorType errorType;

  WebSocketException(
    super.message, {
    required this.errorType,
    super.code,
    super.originalError,
  });

  factory WebSocketException.connectionFailed({dynamic originalError}) {
    return WebSocketException(
      'Failed to connect to WebSocket server',
      errorType: WebSocketErrorType.connectionFailed,
      code: 'CONNECTION_FAILED',
      originalError: originalError,
    );
  }

  factory WebSocketException.connectionLost({dynamic originalError}) {
    return WebSocketException(
      'WebSocket connection lost',
      errorType: WebSocketErrorType.connectionLost,
      code: 'CONNECTION_LOST',
      originalError: originalError,
    );
  }

  factory WebSocketException.invalidUrl({dynamic originalError}) {
    return WebSocketException(
      'Invalid WebSocket URL',
      errorType: WebSocketErrorType.invalidUrl,
      code: 'INVALID_URL',
      originalError: originalError,
    );
  }

  factory WebSocketException.sendFailed({dynamic originalError}) {
    return WebSocketException(
      'Failed to send message',
      errorType: WebSocketErrorType.sendFailed,
      code: 'SEND_FAILED',
      originalError: originalError,
    );
  }
}

enum WebSocketErrorType {
  connectionFailed,
  connectionLost,
  invalidUrl,
  sendFailed,
  unknown,
}