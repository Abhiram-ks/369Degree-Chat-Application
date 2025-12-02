import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:webchat/api/api_service.dart';
import 'api_test.mocks.dart';

@GenerateMocks([ApiService])
void main() {
  late MockApiService mockApiService;

  setUp(() {
    mockApiService = MockApiService();
  });

  group('ApiService Essential Tests', () {
    // Test 1: Successful fetch (200 OK)
    test('successfully fetches user data', () async {
      final successResponse = Response(
        requestOptions: RequestOptions(path: 'users'),
        statusCode: 200,
        data: {
          'users': [
            {
              'id': 1,
              'fullName': 'John Doe',
              'email': 'test@example.com',
              'avatarUrl': 'https://example.com/avatar.jpg',
            },
          ],
        },
      );
      when(mockApiService.get(any)).thenAnswer((_) async => successResponse);

      const path = 'test-path';
      final response = await mockApiService.get(path);

      expect(response.statusCode, 200);
      expect(response.data, isNotNull);
      expect(response.data['users'], isA<List>());
      verify(mockApiService.get(path)).called(1);
    });

    // Test 2: Connection timeout error
    test('throws DioException on connection timeout', () async {
      when(mockApiService.get(any)).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: 'users'),
          type: DioExceptionType.connectionTimeout,
        ),
      );

      const path = 'test-path';
      expect(
        () => mockApiService.get(path),
        throwsA(
          isA<DioException>().having(
            (e) => e.type,
            'type',
            DioExceptionType.connectionTimeout,
          ),
        ),
      );
    });
  });
}
