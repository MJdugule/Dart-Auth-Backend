import 'package:bcrypt/bcrypt.dart';
import 'package:dart_auth_backend/core/services/email_service.dart';
import 'package:dart_auth_backend/core/services/token_service.dart';
import 'package:dart_auth_backend/src/auth/auth_service.dart';
import 'package:dart_auth_backend/src/auth/auth_validators.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response.json(
      statusCode: 405,
      body: {'data': null, 'error': 'Method not found'},
    );
  }

  // try {
  final body = await context.request.json() as Map<String, dynamic>;
  final validationErrors = AuthValidators.validateRegisterBody(body);
  if (validationErrors != null) {
    return Response.json(
      statusCode: 422, // 422 Unprocessable Entity for invalid data values
      body: {
        'data': null,
        'error': 'Validation failed',
        'details': validationErrors,
      },
    );
  }
  final email = body['email'] as String;
  final password = body['password'] as String;
  final firstname = body['firstname'] as String;
  final lastname = body['lastname'] as String;
  final referralCode = body['referralCode'] as String?;

  // if (email == null ||
  //     email.isEmpty ||
  //     password == null ||
  //     password.isEmpty) {
  //   return Response.json(
  //     statusCode: 401,
  //     body: {'data': null, 'error': 'Email and password are required'},
  //   );
  // }

  if (findUserByEmail(email) != null) {
    return Response.json(
      statusCode: 401,
      body: {'data': null, 'error': 'User already exists'},
    );
  }

  final passwordHash = BCrypt.hashpw(password, BCrypt.gensalt());
  final otp = EmailService.generateOtp();
  final accessToken = TokenService.generateRegistrationToken(
    firstname: firstname,
    lastname: lastname,
    email: email,
    hashedPassword: passwordHash,
    otp: otp,
    referralCode: referralCode,
  );

  

  await EmailService.sendOtpEmail(email: email, name: firstname, otp: otp);

  // final user = createUser(
  //   email: email,
  //   hashedPassword: passwordHash,
  //   firstname: firstname,
  //   lastname: lastname,
  //   referralCode: referralCode,
  // );

  // final tokens = TokenService.generateTokenPair(
  //   user?.id ?? '',
  //   user?.email ?? '',
  // );

  return Response.json(
    body: {
      'statusCode': 200,
      'success': true,
      'message':
          'Used the registration token to verify the otp sent to your email',
      'data': {
        // 'user': user?.toJson(),
        'registrationToken': accessToken,
        // 'refreshToken': tokens['refreshToken'],
      },
    },
  );
  // } catch (e) {
  //   return Response.json(
  //     statusCode: 401,
  //     body: {
  //       'data': null,
  //       'body': {
  //         'statusCode': 400,
  //         'data': null,
  //         'error': 'Invalid or missing JSON payload',
  //       },
  //     },
  //   );
  // }
}
