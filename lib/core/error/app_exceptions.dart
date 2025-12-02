
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  AppException(this.message, {this.code, this.originalError});

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  NetworkException(super.message, {String? code, super.originalError})
      : super(code: code ?? 'NETWORK_ERROR');

  factory NetworkException.noInternet() {
    return NetworkException(
      'No internet connection',
      code: 'NO_INTERNET',
    );
  }

  factory NetworkException.timeout() {
    return NetworkException(
      'Request timeout - Please check your connection',
      code: 'TIMEOUT',
    );
  }
}


