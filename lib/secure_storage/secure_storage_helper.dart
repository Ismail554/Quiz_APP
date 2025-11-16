import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageHelper {
  static const _storage = FlutterSecureStorage();
  static const _verificationTokenKey = 'verification_token';

  static Future<void> setToken(String token) async {
    await _storage.write(key: 'token', value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: 'token');
  }

  static Future<void> setRefreshToken(String token) async {
    await _storage.write(key: 'refresh_token', value: token);
  }

  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: 'refresh_token');
  }

  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  static Future<void> setVerificationToken(String token) async =>
      await _storage.write(key: _verificationTokenKey, value: token);

  static Future<String?> getVerificationToken() async =>
      await _storage.read(key: _verificationTokenKey);

  static Future<void> setResetPasswordEmail(String email) async =>
      await _storage.write(key: 'reset_password_email', value: email);

  static Future<String?> getResetPasswordEmail() async =>
      await _storage.read(key: 'reset_password_email');
}
