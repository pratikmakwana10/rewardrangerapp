import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:rewardrangerapp/helper_function/utility.dart';

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
        logger.i('Response data: ${response.data}');
        return response.data;
      } else {
        throw Exception('Sign up failed with status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        logger.i('DioException response data: ${e.response?.data}');
        throw Exception('Sign up failed: ${e.response?.data}');
      } else {
        logger.i('DioException message: ${e.message}');
        throw Exception('Sign up failed: ${e.message}');
      }
    }
  }

  Future<Map<String, dynamic>> login(Map<String, dynamic> credentials) async {
    const String endpoint = 'https://reward-ranger-backend.onrender.com/login';

    try {
      final Response response = await _dio.post(endpoint, data: credentials);
      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['status'] == true) {
          logger.i('Response data: ${responseData['data']}');
          return responseData['data'];
        } else {
          throw Exception('Login failed: ${responseData['message']}');
        }
      } else {
        throw Exception('Login failed with status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        logger.i('DioException response data: ${e.response?.data}');
        throw Exception('Login failed: ${e.response?.data}');
      } else {
        logger.i('DioException message: ${e.message}');
        throw Exception('Login failed: ${e.message}');
      }
    }
  }

  Future<Map<String, dynamic>> fetchData(String endpoint) async {
    final String? token = await _storage.read(key: 'auth_token');
    if (token == null) {
      throw Exception('No token found');
    }

    try {
      final Response response = await _dio.get(
        endpoint,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Request failed with status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        logger.i('DioException response data: ${e.response?.data}');
        throw Exception('Request failed: ${e.response?.data}');
      } else {
        logger.i('DioException message: ${e.message}');
        throw Exception('Request failed: ${e.message}');
      }
    }
  }
}
