import 'package:redis/redis.dart';

///
class RedisService {
  late final Command _command;
  late final PubSub _pubsub;

  /// Initialize redis
  Future<void> initialize({required String host, required int port}) async {
    try {
      final conn = RedisConnection();
      _command = await conn.connect(host, port);
      print('🚀 Connected to Redis at $host:$port successfully.');
    } catch (e) {
      print('❌ Failed to connect to Redis: $e');
      rethrow;
    }
  }

  /// Sets a value with an automatic time-to-live (TTL) expiration string
  Future<void> setValue({
    required String key,
    required String value,
    required Duration duration,
  }) async {
    // 'setex' means: SET key with EXpiration time in seconds
    await _command.send_object([
      'SETEX', 
      key, 
      duration.inSeconds.toString(), 
      value
    ]);
  }

  /// Retrieves a value. Returns null if expired or missing.
  Future<String?> getValue(String key) async {
    final response = await _command.get(key);
    return response as String?;
  }

  /// Enforces a strict 60-second cooldown window between generation checks
  Future<bool> checkOtpRateLimit(String email) async {
    final lastSentTimestamp = await getValue('cooldown:$email');
    return lastSentTimestamp == null; // True means no active cooldown, safe to proceed
  }
}
