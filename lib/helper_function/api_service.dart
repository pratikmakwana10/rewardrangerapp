import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../helper_function/utility.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 50),
    receiveTimeout: const Duration(seconds: 30),
  ));

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<Map<String, dynamic>> signUp(Map<String, dynamic> userData) async {
    const String endpoint = 'https://reward-ranger-backend.onrender.com/signup';

    try {
      final Response response = await _dio.post(endpoint, data: userData);
      if (response.statusCode == 200 || response.statusCode == 201) {
        logger.i('Sign Up Response: ${response.data}');
        return response.data;
      } else {
        throw Exception('Sign up failed with status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _handleDioError(e);
    }
    return {};
  }

  Future<Map<String, dynamic>> login(Map<String, dynamic> credentials) async {
    const String endpoint = 'https://reward-ranger-backend.onrender.com/login';

    try {
      final Response response = await _dio.post(endpoint, data: credentials);
      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['status'] == true) {
          logger.i('Login Response: ${responseData['data']}');
          return responseData['data'];
        } else {
          throw Exception('Login failed: ${responseData['message']}');
        }
      } else {
        throw Exception('Login failed with status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _handleDioError(e);
    }
    return {};
  }

  Future<Map<String, dynamic>> getUserInfo() async {
    final String? token = await _getToken();
    if (token == null) {
      throw Exception('No token found');
    }

    const String endpoint = 'https://reward-ranger-backend.onrender.com/api/me';

    try {
      final Response response = await _dio.get(
        endpoint,
        options: Options(
          headers: {
            'token': token,
          },
        ),
      );

      if (response.statusCode == 200) {
        return response.data['data'];
      } else {
        throw Exception('Failed to fetch user info with status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _handleDioError(e);
    }
    return {};
  }

  Future<String?> _getToken() async {
    try {
      return await _storage.read(key: 'auth_token');
    } catch (e) {
      logger.e('Failed to get auth token: $e');
      throw Exception('Failed to get auth token: $e');
    }
  }

  void _handleDioError(DioException e) {
    if (e.response != null) {
      logger.e('DioException response data: ${e.response?.data}');
      throw Exception('Request failed: ${e.response?.data}');
    } else {
      logger.e('DioException message: ${e.message}');
      throw Exception('Request failed: ${e.message}');
    }
  }
}
