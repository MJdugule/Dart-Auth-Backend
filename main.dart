import 'dart:io';

import 'package:dart_auth_backend/src/core/services/redis_service.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:dotenv/dotenv.dart';
import 'package:mongo_dart/mongo_dart.dart';

final RedisService globalRedis = RedisService();
late final Db globalMongo; // Exposed globally to your app

Future<void> init(InternetAddress ip, int port) async {
  print('--- Launching Monolith Services Startup Sequence ---');

  final env = DotEnv(includePlatformEnvironment: true)..load();

   // 2. Fetch configurations with clear fallback rules
  final redisHost = env['REDIS_HOST'] ?? 'localhost';
  final redisPortStr = env['REDIS_PORT'] ?? '6379';
  final mongoUri = env['MONGO_URI'];

  if (mongoUri == null || mongoUri.isEmpty) {
    throw StateError('CRITICAL CONFIGURATION ERROR: "MONGO_URI" is missing in your .env file.');
  }
  
  // 3. Connect to Redis with .env variables
  final redisPort = int.tryParse(redisPortStr) ?? 6379;
  await globalRedis.initialize(host: redisHost, port: redisPort);

  // 4. Connect to MongoDB with .env variables
  globalMongo = await Db.create(mongoUri);
  await globalMongo.open();
  
  print('💾 Connected to MongoDB successfully.');
}

Future<HttpServer> run(Handler handler, InternetAddress ip, int port) {
  return serve(handler, ip, port);
}