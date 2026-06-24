import 'package:bcrypt/bcrypt.dart';
import 'package:collection/collection.dart';
import 'package:dart_auth_backend/src/core/exceptions.dart';
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
    final isOtpValid = await verifyOtpCode(
      email: email,
      submittedOtp: submittedOtp,
    );
    if (!isOtpValid) {
      return null;
    }

    final usersCollection = mongoDb.collection('users');

    final existingUser = await usersCollection.findOne(
      where.eq('email', email),
    );
    if (existingUser != null) {
      throw UserAlreadyExistsException(
        'This email address is already linked to another account.',
      );
    }
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
      newUserProfile.copyWith(hashedPassword: secureHashedPassword).toJson(),
    );
    return newUserProfile;
  }
}

// const _uuid = Uuid();
final _users = <String, User>{};

/// find user by email
User? findUserByEmail(String email) {
  return _users.values.firstWhereOrNull((user) => user.email == email);
}

/// find user by id
User? findUserByID(String id) {
  return _users[id];
}

/// create user
// User? createUser({
//   required String email,
//   required String hashedPassword,
//   required String firstname,
//   required String lastname,
//   String? referralCode,
// }) {
//   final id = _uuid.v4();
//   final user = User(
//     id: id,
//     email: email,
//     hashedPassword: hashedPassword,
//     firstname: firstname,
//     lastname: lastname,
//     referralCode: referralCode,
//   );
//   _users[id] = user;
//   return user;
// }
