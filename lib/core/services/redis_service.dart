import 'dart:convert';

import 'package:redis/redis.dart';

///
class RedisService {
  static late Command _redisCommand;

  /// Initializing redis
  static Future<void> initialize() async {
    final conn = RedisConnection();
    _redisCommand = await conn.connect('localhost', 6379);
  }

  /// Saves user registration details temporarily
  static Future<void> savePendingRegistration({
    required String email,
    required String firstname,
    required String lastname,

    required String hashedPassword,
    required String otp,
    String? referralCode,
  }) async {
    final key = 'user:$email';
    final payload = jsonEncode({
      'firstname': firstname,
      'lastname': lastname,
      'email': email,
      if (referralCode != null) 'referralCode': referralCode,
      'hashedPassword': hashedPassword,
      'otp': otp,
    });

    // Save to Redis for 10min
    await _redisCommand.send_object(['SET', key, payload]);
    await _redisCommand.send_object(['EXPIRE', key, 600]);
  }

  /// Retrieves a pending payload map
  static Future<Map<String, dynamic>?> getPendingRegistration(
    String email,
  ) async {
    final key = 'pending_user:$email';
    final data = await _redisCommand.send_object(['GET', key]) as String?;

    if (data == null) return null;
    return jsonDecode(data) as Map<String, dynamic>;
  }

  /// Deletes the cache key
  static Future<void> removePendingRegistration(String email) async {
    final key = 'pending_user:$email';
    await _redisCommand.send_object(['DEL', key]);
  }
}
