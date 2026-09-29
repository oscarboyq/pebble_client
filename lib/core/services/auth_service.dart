import 'package:dio/dio.dart';
import 'package:pebble_type/core/config/api_config.dart';
import 'package:pebble_type/core/services/api_client.dart';
import 'package:pebble_type/core/services/storage_service.dart';

class AuthService {
  static String errorMessage(DioException error, {required String fallback}) {
    final body = error.response?.data;
    if (body is Map && body.isNotEmpty) {
      final value = body.values.first;
      if (value is List && value.isNotEmpty) return value.first.toString();
      if (value is String && value.isNotEmpty) return value;
    }
    return fallback;
  }

  static Future<void> requestPasswordReset(String email) async {
    await _dio.post('auth/password-reset/', data: {'email': email.trim()});
  }

  static Future<void> confirmPasswordReset({
    required String uid,
    required String token,
    required String password,
    required String confirmation,
  }) async {
    await _dio.post(
      'auth/password-reset/confirm/',
      data: {
        'uid': uid,
        'token': token,
        'new_password': password,
        'confirm_password': confirmation,
      },
    );
  }
  //baseUrl points to your running django server
  // 10.0.2.2 is Android emulator's alias for localhost
  // change to your machine's IP when testing on a real device

  static final _dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: Duration(seconds: 10),
      receiveTimeout: Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  //Register -----------------------------------------------------------``
  static Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String phone = '',
    String gender = '',
    DateTime? birthday,
    bool newsletterOptIn = true,
    String addressLine1 = '',
    String addressLine2 = '',
    String city = '',
    String state = '',
    String zipCode = '',
    String country = 'United States',
  }) async {
    final response = await _dio.post(
      'auth/register/',
      data: {
        'email': email,
        'password': password,
        'first_name': firstName,
        'last_name': lastName,
        'phone': phone,
        'gender': gender,
        'birthday': birthday != null
            ? '${birthday.year}-${birthday.month.toString().padLeft(2, '0')}-${birthday.day.toString().padLeft(2, '0')}'
            : null,
        'newsletter_opt_in': newsletterOptIn,
        'address_line1': addressLine1,
        'address_line2': addressLine2,
        'city': city,
        'state': state,
        'zip_code': zipCode,
        'country': country,
      },
    );
    // save tokens to secure storage
    await StorageService.saveTokens(
      accessToken: response.data['access'],
      refreshToken: response.data['refresh'],
    );

    return response.data['user'] as Map<String, dynamic>;
  }

  //Login -----------------------------------------------------------
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post(
      'auth/login/',
      data: {
        'username': email, // Django simplejwt expects 'username'
        'password': password,
      },
    );
    // save tokens to secure storage
    await StorageService.saveTokens(
      accessToken: response.data['access'],
      refreshToken: response.data['refresh'],
    );

    // login doesn't return user data — fetch it separately
    return await getMe();
  }

  //Get current user -----------------------------------------------------------
  static Future<Map<String, dynamic>> getMe() async {
    final token = await StorageService.getAccessToken();
    final response = await _dio.get(
      'auth/me/',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return response.data as Map<String, dynamic>;
  }

  //Logout -----------------------------------------------------------
  static Future<void> logout() async {
    await StorageService.clearTokens();
  }

  //Update profile -----------------------------------------------------------
  static Future<Map<String, dynamic>> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? gender,
    DateTime? birthday,
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? state,
    String? zipCode,
    String? country,
  }) async {
    final data = <String, dynamic>{};
    if (firstName != null) data['first_name'] = firstName;
    if (lastName != null) data['last_name'] = lastName;
    if (phone != null) data['phone'] = phone;
    if (gender != null) data['gender'] = gender;
    if (birthday != null) {
      data['birthday'] =
          '${birthday.year}-${birthday.month.toString().padLeft(2, '0')}-${birthday.day.toString().padLeft(2, '0')}';
    }
    if (addressLine1 != null) data['address_line1'] = addressLine1;
    if (addressLine2 != null) data['address_line2'] = addressLine2;
    if (city != null) data['city'] = city;
    if (state != null) data['state'] = state;
    if (zipCode != null) data['zip_code'] = zipCode;
    if (country != null) data['country'] = country;

    final response = await ApiClient.dio.patch('auth/me/', data: data);
    return response.data as Map<String, dynamic>;
  }

  //Change password -----------------------------------------------------------
  static Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await ApiClient.dio.post(
      'auth/change-password/',
      data: {'current_password': currentPassword, 'new_password': newPassword},
    );
  }
}
