import 'package:dio/dio.dart';
import 'package:webchat/core/error/api_exceptions.dart';
import 'package:webchat/core/error/web_socket_exeption.dart';
import 'app_exceptions.dart';

class ErrorHandler {
  static AppException handleApiError(dynamic error) {
    if (error is DioException) {
      return _handleDioException(error);
    } else if (error is ApiException) {
      return error;
    } else {
      return ApiException(
        error.toString(),
        code: 'UNKNOWN_API_ERROR',
        originalError: error,
      );
    }
  }

  static AppException handleWebSocketError(dynamic error) {
    if (error is WebSocketException) {
      return error;
    }

    final errorString = error.toString().toLowerCase();

    if (errorString.contains('connection') || errorString.contains('connect')) {
      return WebSocketException.connectionFailed(originalError: error);
    } else if (errorString.contains('timeout')) {
      return NetworkException.timeout();
    } else if (errorString.contains('network') || errorString.contains('internet')) {
      return NetworkException.noInternet();
    } else if (errorString.contains('url') || errorString.contains('uri')) {
      return WebSocketException.invalidUrl(originalError: error);
    } else {
      return WebSocketException(
        'WebSocket error: ${error.toString()}',
        errorType: WebSocketErrorType.unknown,
        code: 'UNKNOWN_WEBSOCKET_ERROR',
        originalError: error,
      );
    }
  }

  static AppException _handleDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException.timeout();

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode != null) {
          return ApiException.fromStatusCode(
            statusCode,
            responseData: error.response?.data,
          );
        }
        return ApiException(
          'Invalid server response',
          code: 'INVALID_RESPONSE',
          originalError: error,
        );

      case DioExceptionType.cancel:
        return ApiException(
          'Request cancelled',
          code: 'REQUEST_CANCELLED',
          originalError: error,
        );

      case DioExceptionType.connectionError:
        return NetworkException.noInternet();

      case DioExceptionType.badCertificate:
        return ApiException(
          'SSL certificate error',
          code: 'SSL_ERROR',
          originalError: error,
        );

      case DioExceptionType.unknown:
        if (error.message?.toLowerCase().contains('network') ?? false) {
          return NetworkException.noInternet();
        }
        return ApiException(
          error.message ?? 'Unknown error occurred',
          code: 'UNKNOWN_ERROR',
          originalError: error,
        );
    }
  }

}

