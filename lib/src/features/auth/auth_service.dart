import 'package:bcrypt/bcrypt.dart';
import 'package:dart_auth_backend/src/core/services/email_service.dart';
import 'package:dart_auth_backend/src/core/services/redis_service.dart';
import 'package:dart_auth_backend/src/features/auth/auth_model.dart';
import 'package:mongo_dart/mongo_dart.dart';

///
class AuthService {
  ///
  AuthService(this.redisService, this.emailService);

  /// Redis Class
  final RedisService redisService;

  /// Email Class
  final EmailService emailService;

  // final Mongo

  /// Handles the orchestration of generating, saving, and emailing the OTP
  Future<bool> generateAndSendOtp({
    required String email,
    required String name,
  }) async {
    final otp = emailService.generateOtp();

    await redisService.setValue(
      key: 'otp:$email',
      value: otp,
      duration: const Duration(minutes: 5),
    );

    await redisService.setValue(
      key: 'cooldown:$email',
      value: DateTime.now().toIso8601String(),
      duration: const Duration(seconds: 60),
    );

    return emailService.sendOtpEmail(email: email, name: name, otp: otp);
  }

  /// Checks whether an OTP can be sent based on the cooldown window.
  Future<bool> canSendOtp(String email) async {
    return redisService.checkOtpRateLimit(email);
  }

  /// verify otp code
  Future<bool> verifyOtpCode({
    required String email,
    required String submittedOtp,
  }) async {
    final cachedOtp = await redisService.getValue('otp:$email');
    if (cachedOtp == null) {
      return false;
    }

    if (cachedOtp == submittedOtp) {
      await redisService.setValue(
        key: 'otp:$email',
        value: '',
        duration: const Duration(seconds: 1),
      );
      return true;
    }

    return false;
  }

  /// verify and register users
  Future<User?> verifyAndRegisterUser(
    Db mongoDb, {
    required String email,
    required String password,
    required String firstname,
    required String lastname,
    required String submittedOtp,
    String? referralCode,
  }) async {
    final usersCollection = mongoDb.collection('users');
    final secureHashedPassword = BCrypt.hashpw(
      password,
      BCrypt.gensalt(),
    );

    final newUserProfile = User(
      id: ObjectId().oid,
      email: email,
      firstname: firstname,
      lastname: lastname,
      referralCode: referralCode,
      isActive: true,
      createdAt: DateTime.now().toIso8601String(),
    );

    await usersCollection.insertOne(
      newUserProfile
          .copyWith(hashedPassword: secureHashedPassword)
          .toJsonForDataBase(),
    );
    return newUserProfile;
  }

  /// find user by email
  Future<User?> findUserByEmail(Db mongoDb, String email) async {
    final usersCollection = mongoDb.collection('users');
    final user = await usersCollection.findOne(where.eq('email', email));
    if (user != null) {
      return User.fromJson(user);
    }
    return null;
  }

  /// find user by id
  Future<User?> findUserById(Db mongoDb, String id) async {
    final usersCollection = mongoDb.collection('users');
    final user = await usersCollection.findOne(where.eq('id', id));
    if (user != null) {
      return User.fromJson(user);
    }
    return null;
  }

  /// delete user by id
  Future<bool> deleteUserById(Db mongoDb, String id) async {
    final usersCollection = mongoDb.collection('users');
    await usersCollection.deleteOne(where.eq('id', id));
    final user = await usersCollection.findOne(where.eq('id', id));
    return user == null;
  }
}
