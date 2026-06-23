import 'package:bcrypt/bcrypt.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

///
class TokenService {
  /// Passwords section
  static String hashPassword(String password) =>
      BCrypt.hashpw(password, BCrypt.gensalt());

  /// Verify password
  static bool verifyPassword(String password, String hash) =>
      BCrypt.checkpw(password, hash);

  // Tokens configuration section
  static const _accessSecret = 'your-ultra-secure-access-secret-key';
  static const _refreshSecret = 'your-ultra-secure-refresh-secret-key';
  static const _registrationSecret =
      'your-stateless-registration-token-secret-key';

  ///For registration purpose
  static String generateRegistrationToken({
    required String firstname,
    required String lastname,
    required String email,
    required String hashedPassword,
    required String otp,
    String? referralCode,
  }) {
    final jwt = JWT({
      'email': email,
      'hashedPassword': hashedPassword,
      'firstname': firstname,
      'lastname': lastname,
      'referralCode': referralCode,
      'otp': otp,
      'purpose': 'registration',
    });

    return jwt.sign(
      SecretKey(_registrationSecret),
      // expiresIn: const Duration(minutes: 10),
    );
  }

  /// generate tokens
  static Map<String, String> generateTokenPair(String userId, String email) {
    final accessTokenJwt = JWT({
      'id': userId,
      'email': email,
      'type': 'access',
    }, issuer: 'localhost');
    final accessToken = accessTokenJwt.sign(
      SecretKey(_accessSecret),
      expiresIn: const Duration(minutes: 15),
    );

    final refreshTokenJwt = JWT({
      'id': userId,
      'type': 'refresh',
    }, issuer: 'localhost');
    final refreshToken = refreshTokenJwt.sign(
      SecretKey(_refreshSecret),
      expiresIn: const Duration(days: 7),
    );

    return {'accessToken': accessToken, 'refreshToken': refreshToken};
  }

  ///verify registration token
  static JWT? verifyEmailToken(String token) {
    try {
      final jwt = JWT.verify(token, SecretKey(_registrationSecret));
      final payload = jwt.payload as Map<String, dynamic>;

      if (payload['purpose'] == 'registration') {
        return jwt;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  ///verify tokens
  static JWT? verifyToken(String token, {required bool isRefresh}) {
    try {
      return JWT.verify(
        token,
        SecretKey(isRefresh ? _refreshSecret : _accessSecret),
      );
    } catch (_) {
      return null;
    }
  }
}
