import '../../../../api/api_service.dart';
import '../../model/user_model.dart';

class GetUsersRemoteDataSource {
  final ApiService _apiService;

  GetUsersRemoteDataSource({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  Future<List<UserModel>> getUsers() async {
    try {
      final response = await _apiService.get('57f804ad-31df-4bdb-b722-c678211f8677');

      if (response.statusCode == 200) {
        final usersData = response.data['users'] as List;
        return usersData.map((user) => UserModel.fromJson(user)).toList();
      } else {
        throw Exception('Failed to load users: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching users: $e');
    }
  }
}
