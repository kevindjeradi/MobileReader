// token_service.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile_reader_front/helpers/logger.dart';

class TokenService {
  static const _storage = FlutterSecureStorage();

  static const String _tokenKey = 'jwt_token';

  Future<void> saveToken(String token) async {
    Log.logger.i(token);
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }
}
