import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_response.dart';
import 'notification_service.dart';

class ApiService {
  static const String baseUrl = 'https://api-zynergy.gevannoyoh.com/api';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final NotificationService _notificationService = NotificationService();

  Future<ApiResponse> register(String name, String email, String password, String confirmPassword) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'confirm_password': confirmPassword,
      }),
    );

    return ApiResponse.fromJson(jsonDecode(response.body));
  }

  Future<ApiResponse> signInGoogle(String? accessToken) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/google/callback'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(
          {'provider': 'google', 'access_provider_token': accessToken}),
    );

    return ApiResponse.fromJson(jsonDecode(response.body));
  }

  Future<ApiResponse> verifyEmail(String otp) async {
    try {
      final token = await getToken();
      if (token == null) {
        return ApiResponse(success: false, message: 'Token not found', data: null);
      }

      final response = await http.post(
        Uri.parse('$baseUrl/verify-email'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'otp': otp}),
      );

      final responseData = jsonDecode(response.body);
      return ApiResponse.fromJson(responseData);
    } catch (e) {
      return ApiResponse(success: false, message: 'Failed to verify email', data: null);
    }
  }

  Future<bool> isEmailVerified() async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Token not found');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/user'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final userData = jsonDecode(response.body);
      return userData['email_verified_at'] != null;
    } else {
      throw Exception('Failed to check email verification status');
    }
  }

  Future<ApiResponse> resendOTP() async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('Token not found');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/resend-otp'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        return ApiResponse(success: true, message: 'OTP sent successfully');
      } else {
        return ApiResponse(success: false, message: 'Failed to send OTP');
      }
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    print('Login Response: ${response.body}'); // Cetak respons API untuk debugging

    final apiResponse = ApiResponse.fromJson(jsonDecode(response.body));

    if (apiResponse.success) {
      // Simpan token ke SharedPreferences
      await saveToken(apiResponse.data['token']);

      // Periksa apakah `name` ada di dalam `data`
      if (apiResponse.data['name'] != null) {
        await saveUserName(apiResponse.data['name']); // Simpan nama pengguna
      } else {
        throw Exception('User name is missing in the response');
      }
    }

    return apiResponse;
  }

  Future<void> saveUserName(String userName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', userName);
  }

  Future<void> saveToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  Future<void> logout() async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Token not found');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/logout'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      await _storage.delete(key: 'auth_token');
      await _storage.delete(key: 'user_data'); // Hapus data pengguna saat logout
    } else {
      final responseBody = jsonDecode(response.body);
      throw Exception('Failed to logout: ${responseBody['message'] ?? 'Unknown error'}');
    }
  }

  Future<int> getUserId() async {
    final userData = await getLocalUserData();
    if (userData != null && userData.containsKey('id')) {
      return userData['id'];
    } else {
      throw Exception('User ID not found');
    }
  }

  Future<bool> hasPersonalizationData() async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Token not found');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/check-personalization-data'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['has_data'];
    } else {
      throw Exception('Failed to check personalization data');
    }
  }

  Future<Map<String, dynamic>> getUserData() async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Token not found');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/user'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final userData = jsonDecode(response.body);
      await _storage.write(key: 'user_data', value: jsonEncode(userData)); // Simpan data pengguna secara lokal
      return userData;
    } else {
      throw Exception('Failed to load user data');
    }
  }

  Future<Map<String, dynamic>?> getLocalUserData() async {
    final userDataString = await _storage.read(key: 'user_data');
    if (userDataString != null) {
      return jsonDecode(userDataString);
    }
    return null;
  }

  Future<ApiResponse> updateGender(String gender) async {
    final token = await getToken();
    if (token == null) {
      return ApiResponse(success: false, message: 'Token not found', data: null);
    }

    final response = await http.post(
      Uri.parse('$baseUrl/user/update-gender'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'gender': gender}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return ApiResponse(success: true, message: 'Gender updated successfully', data: data);
    } else {
      final errorMessage = response.body;
      return ApiResponse(success: false, message: errorMessage, data: null);
    }
  }

  Future<List<Map<String, dynamic>>> getInterests() async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Token not found');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/personalize/interests'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => item as Map<String, dynamic>).toList();
    } else {
      throw Exception('Failed to load interests');
    }
  }

  Future<List<Map<String, dynamic>>> getFavorites() async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Token not found');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/personalize/favorites'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => item as Map<String, dynamic>).toList();
    } else {
      throw Exception('Failed to load favorites');
    }
  }

  Future<List<Map<String, dynamic>>> getDiseases() async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Token not found');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/diseases'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => item as Map<String, dynamic>).toList();
    } else {
      throw Exception('Failed to load diseases');
    }
  }

  Future<List<Map<String, dynamic>>> getAllergies() async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Token not found');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/allergies'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => item as Map<String, dynamic>).toList();
    } else {
      throw Exception('Failed to load allergies');
    }
  }

  Future<void> savePersonalizationData({
    required List<int> interests,
    required List<int> favorites,
    required List<int> diseases,
    required List<int> allergies,
  }) async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Token not found');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/save-personalization'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'interests': interests,
        'favorites': favorites,
        'diseases': diseases,
        'allergies': allergies,
      }),
    );

    if (response.statusCode != 200) {
      final responseBody = jsonDecode(response.body);
      throw Exception('Failed to save personalization data: ${responseBody['message'] ?? 'Unknown error'}');
    }
  }

  // API Reminders
  Future<int> saveMealReminder(Map<String, dynamic> mealReminder) async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Token not found');
    }

    // Log the meal reminder data to check for null values
    print('Meal Reminder Data: $mealReminder');

    // Ensure all required fields have valid values
    if (mealReminder['meal_name'] == null || mealReminder['meal_name'].isEmpty) {
      throw Exception('Meal name is required');
    }
    if (mealReminder['meal_hour'] == null || mealReminder['meal_hour'] < 0 || mealReminder['meal_hour'] > 23) {
      throw Exception('Meal hour must be between 0 and 23');
    }
    if (mealReminder['meal_minute'] == null || mealReminder['meal_minute'] < 0 || mealReminder['meal_minute'] > 59) {
      throw Exception('Meal minute must be between 0 and 59');
    }
    if (mealReminder['meal_frequency'] == null || (mealReminder['meal_frequency'] != 0 && mealReminder['meal_frequency'] != 1)) {
      throw Exception('Meal frequency must be 0 (once) or 1 (daily)');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/meal-reminders'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(mealReminder),
    );

    if (response.statusCode != 201) {
      try {
        final responseBody = jsonDecode(response.body);
        throw Exception('Failed to save meal reminder: ${responseBody['message'] ?? 'Unknown error'}');
      } catch (e) {
        throw Exception('Failed to save meal reminder: ${response.body}');
      }
    } else {
      final responseData = jsonDecode(response.body);
      final int id = responseData['id']; // Ambil id dari respons API

      // Schedule notification after successfully saving meal reminder
      final now = DateTime.now();
      final mealHour = mealReminder['meal_hour'];
      final mealMinute = mealReminder['meal_minute'];
      final mealFrequency = mealReminder['meal_frequency'];

      DateTime scheduledDate = DateTime(now.year, now.month, now.day, mealHour, mealMinute);

      if (scheduledDate.isBefore(now)) {
        if (mealFrequency == 0) {
          scheduledDate = scheduledDate.add(Duration(days: 1));
        }
      }

      print('Scheduling notification: id=$id, frequency=$mealFrequency');
      _notificationService.scheduleNotification(
        id, // Gunakan id sebagai notification_id
        'Pengingat Makan',
        'Ingatlah untuk makan sesuai jadwal!',
        scheduledDate,
        mealFrequency == 1 ? 'Harian' : 'Sekali',
      );

      return id; // Kembalikan id yang baru saja disimpan
    }
  }

  Future<void> updateMealReminder(int id, Map<String, dynamic> mealReminder) async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Token not found');
    }

    final response = await http.put(
      Uri.parse('$baseUrl/meal-reminders/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(mealReminder),
    );

    if (response.statusCode != 200) {
      try {
        final responseBody = jsonDecode(response.body);
        throw Exception('Failed to update meal reminder: ${responseBody['message'] ?? 'Unknown error'}');
      } catch (e) {
        throw Exception('Failed to update meal reminder: ${response.body}');
      }
    }
  }

  Future<void> updateToggleValue(int id, int toggleValue) async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Token not found');
    }

    final response = await http.put(
      Uri.parse('$baseUrl/meal-reminders/$id/toggle'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'toggle_value': toggleValue}),
    );

    if (response.statusCode != 200) {
      try {
        final responseBody = jsonDecode(response.body);
        throw Exception('Failed to update toggle value: ${responseBody['message'] ?? 'Unknown error'}');
      } catch (e) {
        throw Exception('Failed to update toggle value: ${response.body}');
      }
    }
  }

  Future<List<Map<String, dynamic>>> getSpecialSchedules() async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Token not found');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/meal-reminders'), // Pastikan URL ini benar
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => item as Map<String, dynamic>).toList();
    } else {
      try {
        final responseBody = jsonDecode(response.body);
        throw Exception('Failed to load special schedules: ${responseBody['message'] ?? 'Unknown error'}');
      } catch (e) {
        throw Exception('Failed to load special schedules: ${response.body}');
      }
    }
  }

  Future<void> deleteMealReminder(int id) async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Token not found');
    }

    final response = await http.delete(
      Uri.parse('$baseUrl/meal-reminders/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete meal reminder');
    }
  }

  Future<ApiResponse> saveSleepReminder(Map<String, dynamic> sleepReminder) async {
    final token = await getToken();
    if (token == null) {
      return ApiResponse(success: false, message: 'Token not found', data: null);
    }

    final response = await http.post(
      Uri.parse('$baseUrl/sleep-reminders'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(sleepReminder),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final int id = data['id']; // Ambil id dari respons API

      // Schedule notification after successfully saving sleep reminder
      final now = DateTime.now();
      final sleepHour = sleepReminder['sleep_hour'];
      final sleepMinute = sleepReminder['sleep_minute'];
      final wakeHour = sleepReminder['wake_hour'];
      final wakeMinute = sleepReminder['wake_minute'];
      final sleepFrequency = sleepReminder['sleep_frequency'] == 0 ? 'Sekali' : 'Harian';

      DateTime sleepScheduledDate = DateTime(now.year, now.month, now.day, sleepHour, sleepMinute);
      DateTime wakeScheduledDate = DateTime(now.year, now.month, now.day, wakeHour, wakeMinute);

      if (sleepScheduledDate.isBefore(now)) {
        if (sleepFrequency == 'Sekali') {
          sleepScheduledDate = sleepScheduledDate.add(Duration(days: 1));
        }
      }

      if (wakeScheduledDate.isBefore(now)) {
        if (sleepFrequency == 'Sekali') {
          wakeScheduledDate = wakeScheduledDate.add(Duration(days: 1));
        }
      }

      print('Scheduling sleep notification: id=$id, frequency=$sleepFrequency');
      _notificationService.scheduleNotification(
        id, // Gunakan id sebagai notification_id
        'Pengingat Tidur',
        'Ingatlah untuk tidur sesuai jadwal!',
        sleepScheduledDate,
        sleepFrequency,
      );

      print('Scheduling wake notification: id=$id, frequency=$sleepFrequency');
      _notificationService.scheduleNotificationWithCustomSound(
        id + 1, // Gunakan id + 1 sebagai notification_id untuk alarm bangun
        'Pengingat Bangun',
        'Ingatlah untuk bangun sesuai jadwal!',
        wakeScheduledDate,
        sleepFrequency,
      );

      return ApiResponse(success: true, message: 'Success', data: data);
    } else {
      return ApiResponse(success: false, message: 'Failed to fetch sleep reminders', data: null);
    }
  }

  Future<ApiResponse> updateSleepReminder(int id, Map<String, dynamic> sleepReminder) async {
    final token = await getToken();
    if (token == null) {
      return ApiResponse(success: false, message: 'Token not found', data: null);
    }

    final response = await http.put(
      Uri.parse('$baseUrl/sleep-reminders/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(sleepReminder),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return ApiResponse(success: true, message: 'Success', data: data);
    } else {
      return ApiResponse(success: false, message: 'Failed to fetch sleep reminders', data: null);
    }
  }

  Future<void> updateToggleValueSleepReminder(int id, int toggleValue) async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Token not found');
    }

    final response = await http.put(
      Uri.parse('$baseUrl/sleep-reminders/$id/toggle'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'toggle_value': toggleValue}),
    );

    if (response.statusCode != 200) {
      try {
        final responseBody = jsonDecode(response.body);
        throw Exception('Failed to update toggle value: ${responseBody['message'] ?? 'Unknown error'}');
      } catch (e) {
        throw Exception('Failed to update toggle value: ${response.body}');
      }
    }
  }

  Future<ApiResponse> getSleepReminders() async {
    final token = await getToken();
    if (token == null) {
      return ApiResponse(success: false, message: 'Token not found', data: null);
    }

    final response = await http.get(
      Uri.parse('$baseUrl/sleep-reminders'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return ApiResponse(success: true, message: 'Success', data: data);
    } else {
      return ApiResponse(success: false, message: 'Failed to fetch sleep reminders', data: null);
    }
  }

  Future<ApiResponse> deleteSleepReminder(int id) async {
    final token = await getToken();
    if (token == null) {
      return ApiResponse(success: false, message: 'Token not found', data: null);
    }

    final response = await http.delete(
      Uri.parse('$baseUrl/sleep-reminders/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return ApiResponse(success: true, message: 'Success', data: null);
    } else {
      return ApiResponse(success: false, message: 'Failed to delete sleep reminder', data: null);
    }
  }

  Future<ApiResponse> saveLightActivityReminder(Map<String, dynamic> lightActivityReminder) async {
    final token = await getToken();
    if (token == null) {
      return ApiResponse(success: false, message: 'Token not found', data: null);
    }

    final response = await http.post(
      Uri.parse('$baseUrl/light-activity-reminders'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(lightActivityReminder),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return ApiResponse(success: true, message: 'Success', data: data);
    } else {
      final errorMessage = response.body;
      return ApiResponse(success: false, message: errorMessage, data: null);
    }
  }

  Future<List<Map<String, dynamic>>> fetchLightActivityReminders() async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Token not found');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/light-activity-reminders'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => item as Map<String, dynamic>).toList();
    } else {
      throw Exception('Failed to load light activity reminders');
    }
  }

  Future<ApiResponse> updateLightActivityReminder(int id, Map<String, dynamic> lightActivityReminder) async {
    final token = await getToken();
    if (token == null) {
      return ApiResponse(success: false, message: 'Token not found', data: null);
    }

    final response = await http.put(
      Uri.parse('$baseUrl/light-activity-reminders/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(lightActivityReminder),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return ApiResponse(success: true, message: 'Success', data: data);
    } else {
      final errorMessage = response.body;
      return ApiResponse(success: false, message: errorMessage, data: null);
    }
  }

  Future<void> updateToggleValueLightActivityReminder(int id, int toggleValue) async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Token not found');
    }

    final response = await http.put(
      Uri.parse('$baseUrl/light-activity-reminders/$id/toggle'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'toggle_value': toggleValue}),
    );

    if (response.statusCode != 200) {
      try {
        final responseBody = jsonDecode(response.body);
        throw Exception('Failed to update toggle value: ${responseBody['message'] ?? 'Unknown error'}');
      } catch (e) {
        throw Exception('Failed to update toggle value: ${response.body}');
      }
    }
  }

  Future<ApiResponse> deleteLightActivityReminder(int id) async {
    final token = await getToken();
    if (token == null) {
      return ApiResponse(success: false, message: 'Token not found', data: null);
    }

    final response = await http.delete(
      Uri.parse('$baseUrl/light-activity-reminders/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return ApiResponse(success: true, message: 'Success', data: null);
    } else {
      final errorMessage = response.body;
      return ApiResponse(success: false, message: errorMessage, data: null);
    }
  }

  Future<ApiResponse> saveHealthCheckupReminder(Map<String, dynamic> healthCheckupReminder) async {
    final token = await getToken();
    if (token == null) {
      return ApiResponse(success: false, message: 'Token not found', data: null);
    }

    final response = await http.post(
      Uri.parse('$baseUrl/health-checkup-reminders'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(healthCheckupReminder),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return ApiResponse(success: true, message: 'Success', data: data);
    } else {
      final errorMessage = response.body;
      return ApiResponse(success: false, message: errorMessage, data: null);
    }
  }

  Future<ApiResponse> updateHealthCheckupReminder(int id, Map<String, dynamic> updatedData) async {
    final token = await getToken();
    if (token == null) {
      return ApiResponse(success: false, message: 'Token not found', data: null);
    }

    final response = await http.put(
      Uri.parse('$baseUrl/health-checkup-reminders/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(updatedData),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return ApiResponse(success: true, message: 'Success', data: data);
    } else {
      return ApiResponse(success: false, message: 'Failed to update health checkup reminder', data: null);
    }
  }

  Future<ApiResponse> getHealthCheckupReminders() async {
    final token = await getToken();
    if (token == null) {
      return ApiResponse(success: false, message: 'Token not found', data: null);
    }

    final response = await http.get(
      Uri.parse('$baseUrl/health-checkup-reminders'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return ApiResponse(success: true, message: 'Success', data: data);
    } else {
      return ApiResponse(success: false, message: 'Failed to fetch health checkup reminders', data: null);
    }
  }

  Future<ApiResponse> deleteHealthCheckupReminder(int id) async {
    final token = await getToken();
    if (token == null) {
      return ApiResponse(success: false, message: 'Token not found', data: null);
    }

    final response = await http.delete(
      Uri.parse('$baseUrl/health-checkup-reminders/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return ApiResponse(success: true, message: 'Success', data: null);
    } else {
      return ApiResponse(success: false, message: 'Failed to delete health checkup reminder', data: null);
    }
  }


  // Custom Notification fetch Data
  Future<List<Map<String, dynamic>>> getSuggestMenus() async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Token not found');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/meal-reminders/suggest'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => item as Map<String, dynamic>).toList();
    } else {
      throw Exception('Failed to load suggest menus');
    }
  }

  Future<List<Map<String, dynamic>>> getSuggestAvoids() async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Token not found');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/meal-reminders/suggest-avoids'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => item as Map<String, dynamic>).toList();
    } else {
      throw Exception('Failed to load suggest avoids');
    }
  }

  // Semua tentang Artikel
  Future<List<Map<String, dynamic>>> getSuggestedArticles() async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Token not found');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/articles/suggest'),
      headers: {'Authorization': 'Bearer $token'},
    );

    // Log status code dan body dari respons
    print("Status Code: ${response.statusCode}");
    print("Response Body: ${response.body}");

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((article) => article as Map<String, dynamic>).toList();
    } else {
      throw Exception('Failed to load articles: ${response.statusCode}');
    }
  }

  Future<List<Map<String, dynamic>>> getGeneralArticles() async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Token not found');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/articles/general'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((article) => article as Map<String, dynamic>).toList();
    } else {
      throw Exception('Failed to load general articles: ${response.statusCode}');
    }
  }
}