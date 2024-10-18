import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rewardrangerapp/helper_function/api_constant.dart';
import '../helper_function/utility.dart';
import '../model/sign_up_model.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(
      // connectTimeout: const Duration(seconds: 8),
      // receiveTimeout: const Duration(seconds: 10),
      ));
  String? _token; // Variable to store the token

  ApiService() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        _token ??= await _getToken();
        logger.i('Interceptor Token: $_token');
        if (_token != null) {
          options.headers['Authorization'] = '$_token';
        }
        return handler.next(options);
      },
      onError: (DioException error, handler) {
        _handleDioError(error);
        return handler.next(error);
      },
    ));
  }

  Future<Map<String, dynamic>> signUp(Map<String, dynamic> userData,
      {bool isPhoneSignup = false}) async {
    return await _postRequest(ApiConstant.signup, userData);
  }

  Future<Map<String, dynamic>> login(Map<String, dynamic> credentials) async {
    final responseData = await _postRequest(ApiConstant.login, credentials);
    logger.f(responseData);
    if (responseData.isNotEmpty && responseData['status'] == true) {
      await _saveToken(responseData['data']['token']);
      _token = responseData['data']['token'];
    }
    return responseData;
  }

  Future<Map<String, dynamic>> loginWithPhone({
    required String sessionInfo,
    required String otp,
  }) async {
    return await _postRequest(ApiConstant.login, {
      'session_info': sessionInfo,
      'otp': otp,
    });
  }

  Future<Map<String, dynamic>> sendVerificationCode({
    required String phoneNumber,
    required String recaptchaToken,
  }) async {
    return await _postRequest(ApiConstant.sendVerificationCode, {
      'phone_number': phoneNumber,
      'recaptcha_token': recaptchaToken,
    });
  }

  Future<Map<String, dynamic>> verifyOtp({
    required String sessionInfo,
    required String otp,
  }) async {
    final responseData = await _postRequest(ApiConstant.verifyOtp, {
      'session_info': sessionInfo,
      'otp': otp,
    });
    if (responseData.isNotEmpty && responseData['status'] == true) {
      await _saveToken(responseData['data']['token']);
      _token = responseData['data']['token'];
    }
    return responseData;
  }

  Future<UserInfo?> getUserInfo() async {
    try {
      String? token = await _getTokenOrThrow();
      logger.f('Fetching user info with token: $token');
      final response = await _dio.get(
        ApiConstant.userInfo,
        options: Options(headers: {'token': token}),
      );
      if (response.statusCode == 200 && response.data['status'] == true) {
        return UserInfo.fromJson(response.data);
      } else {
        throw Exception(
            'Failed to fetch user info: ${response.data['message']}');
      }
    } on DioException catch (e) {
      _handleDioError(e, endpoint: ApiConstant.userInfo);
      return null;
    }
  }

  Future<Map<String, dynamic>> postScore(int score) async {
    return await _postRequest(
        ApiConstant.dashboardScore,
        {
          'score': score,
        },
        requiresToken: true);
  }

  Future<Map<String, dynamic>> verifyEmail() async {
    return await _postRequest(ApiConstant.verifyEmail, {}, requiresToken: true);
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    return await _postRequest(ApiConstant.forgotPassword, {'email': email});
  }

  Future<Map<String, dynamic>> userQuery(String queryText) async {
    return await _postRequest(
        ApiConstant.userQuery,
        {
          'query': queryText,
        },
        requiresToken: true);
  }

  // Generalized POST request handler to reduce code duplication
  Future<Map<String, dynamic>> _postRequest(
    String endpoint,
    Map<String, dynamic> data, {
    bool requiresToken = false,
  }) async {
    try {
      if (requiresToken) {
        await _getTokenOrThrow();
      }

      final response = await _dio.post(
        endpoint,
        data: data,
        options: requiresToken ? Options(headers: {'token': _token}) : null,
      );

      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        return response.data;
      } else {
        throw Exception('Request failed with status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _handleDioError(e, endpoint: endpoint);
    }
    return {};
  }

  // Token and Secure Storage handling
  Future<void> _saveToken(String token) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      logger.i('Token saved successfully');
    } catch (e) {
      logger.e('Failed to save token: $e');
      throw Exception('Failed to save token: $e');
    }
  }

  Future<String?> _getToken() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      logger.i(
          'Token retrieved: ${token != null ? '***' : 'null'}'); // Obscured for security
      return token;
    } catch (e) {
      logger.e('Failed to get token: $e');
      return null; // Return null if there’s an error
    }
  }

  Future<String?> _getTokenOrThrow() async {
    _token ??= await _getToken();
    if (_token == null) {
      logger.e('Token is not available. User may not be logged in.');
      throw Exception('Token is not available');
    }
    return _token;
  }

  // Error handling
  void _handleDioError(DioException e, {String? endpoint}) {
    if (e.type == DioExceptionType.connectionTimeout) {
      logger.e('Connection timed out while calling $endpoint');
      throw Exception('Connection timed out');
    } else if (e.type == DioExceptionType.receiveTimeout) {
      logger.e('Receive timeout in connection while calling $endpoint');
      throw Exception('Receive timeout in connection');
    } else if (e.type == DioExceptionType.unknown) {
      logger.e('Network error while calling $endpoint: ${e.message}');
      throw Exception('Network error');
    } else if (e.response != null) {
      logger.e('DioException response data: ${e.response?.data}');
      if (e.response?.statusCode == 401) {
        logger.e('Unauthorized - Token might be expired');
        // Handle token refresh logic or logout
      }
      throw Exception('Request failed: ${e.response?.data}');
    } else {
      logger.e('DioException message: ${e.message}');
      throw Exception('Request failed: ${e.message}');
    }
  }
}
