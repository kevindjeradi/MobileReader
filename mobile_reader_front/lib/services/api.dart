// api.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mobile_reader_front/helpers/logger.dart';
import 'package:mobile_reader_front/provider/user_provider.dart';
import 'package:mobile_reader_front/services/token_service.dart';
import 'package:mobile_reader_front/services/user_service.dart';
import 'package:path/path.dart';

class Api {
  static final TokenService _tokenService = TokenService();
  static final _userService = UserService();
  static final String baseUrl = dotenv.env['API_URL'] ?? 'http://10.0.2.2:3000';

  Future<http.Response> _handleRequest(
      Future<http.Response> Function() action) async {
    try {
      final response = await action();
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response;
      } else {
        Log.logger.e('Request failed with status: ${response.statusCode}');
        throw Exception('Failed to complete request');
      }
    } catch (e, s) {
      Log.logger.e('Error: $e\nStack trace: $s');
      throw Exception('Failed to complete request');
    }
  }

  Future<http.Response> get(String url) async {
    final token = await _tokenService.getToken();
    return _handleRequest(() => http.get(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ));
  }

  Future<http.Response> post(String url, Map<String, dynamic> data) async {
    final token = await _tokenService.getToken();
    return _handleRequest(() => http.post(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(data),
        ));
  }

  Future<http.Response> put(String url, Map<String, dynamic> data) async {
    final token = await _tokenService.getToken();
    return _handleRequest(() => http.put(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(data),
        ));
  }

  Future<http.Response> patch(String url, Map<String, dynamic> data) async {
    final token = await _tokenService.getToken();
    return _handleRequest(() => http.patch(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(data),
        ));
  }

  Future<http.Response> delete(String url, Map<String, dynamic> data) async {
    final token = await _tokenService.getToken();
    return _handleRequest(() => http.delete(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(data),
        ));
  }

  static Future<void> populateUserProvider(UserProvider userProvider) async {
    try {
      Map<String, dynamic> userDetails =
          await _userService.fetchUserDetails(_tokenService);

      userProvider.setUserData(userDetails);
    } catch (e, s) {
      Log.logger.e("Error populating UserProvider + $e\n stack trace: $s");
    }
  }

  Future<Map<String, dynamic>> setUserProfileImage(File image) async {
    try {
      final token = await _tokenService.getToken();
      String url = '$baseUrl/user/profileImage';

      var request = http.MultipartRequest('POST', Uri.parse(url))
        ..headers['Authorization'] = 'Bearer $token'
        ..files.add(await http.MultipartFile.fromPath(
          'profileImage',
          image.path,
          contentType: MediaType('image', basename(image.path).split('.').last),
        ));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to set profile image: ${response.body}');
      }
    } catch (e) {
      Log.logger.e("An error occurred setting profile image: $e");
      rethrow;
    }
  }
}
