
import 'app_exceptions.dart';

class ApiException extends AppException {
  final int? statusCode;
  final Map<String, dynamic>? responseData;

  ApiException(
    super.message, {
    this.statusCode,
    this.responseData,
    super.code,
    super.originalError,
  });

  factory ApiException.fromStatusCode(int statusCode, {dynamic responseData}) {
    switch (statusCode) {
      case 400:
        return ApiException(
          'Bad Request - Invalid parameters',
          statusCode: statusCode,
          responseData: responseData,
          code: 'BAD_REQUEST',
        );
      case 401:
        return ApiException(
          'Unauthorized - Please login again',
          statusCode: statusCode,
          responseData: responseData,
          code: 'UNAUTHORIZED',
        );
      case 403:
        return ApiException(
          'Forbidden - Access denied',
          statusCode: statusCode,
          responseData: responseData,
          code: 'FORBIDDEN',
        );
      case 404:
        return ApiException(
          'Not Found - Resource not available',
          statusCode: statusCode,
          responseData: responseData,
          code: 'NOT_FOUND',
        );
      case 500:
        return ApiException(
          'Server Error - Please try again later',
          statusCode: statusCode,
          responseData: responseData,
          code: 'SERVER_ERROR',
        );
      case 503:
        return ApiException(
          'Service Unavailable - Server is down',
          statusCode: statusCode,
          responseData: responseData,
          code: 'SERVICE_UNAVAILABLE',
        );
      default:
        return ApiException(
          'Request failed with status $statusCode',
          statusCode: statusCode,
          responseData: responseData,
          code: 'HTTP_ERROR',
        );
    }
  }
}
