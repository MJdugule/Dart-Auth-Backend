import 'dart:io';

import 'package:dart_auth_backend/src/core/services/email_service.dart';
import 'package:dart_auth_backend/src/core/services/token_service.dart';
import 'package:dart_auth_backend/src/features/auth/auth_service.dart';
import 'package:dart_auth_backend/src/features/auth/auth_validators.dart';
import 'package:dart_frog/dart_frog.dart';

import '../../../../main.dart';

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
  final otp = body['otp'] as String;
  final referralCode = body['referralCode'] as String?;

  final authService = AuthService(globalRedis, EmailService());
  final user = await authService.findUserByEmail(globalMongo, email);
  if (user != null) {
    return Response.json(
      statusCode: 400,
      body: {
        'statusCode': 400,
        'data': null,
        'error': 'User with this email already exists',
      },
    );
  }

  final isOtpValid = await authService.verifyOtpCode(
    email: email,
    submittedOtp: otp,
  );
  if (!isOtpValid) {
    return Response.json(
      statusCode: HttpStatus.badRequest, // 400
      body: {
        'statusCode': 400,
        'data': null,
        'error': 'The verification code is invalid or has expired.',
        'message': 'The verification code is invalid or has expired.',
      },
    );
  }

  final createdUser = await authService.verifyAndRegisterUser(
    globalMongo,
    email: email,
    password: password,
    firstname: firstname,
    lastname: lastname,
    submittedOtp: otp,
    referralCode: referralCode,
  );

  if (createdUser == null) {
    return Response.json(
      statusCode: HttpStatus.badRequest, // 400
      body: {
        'statusCode': 400,
        'data': null,
        'error': 'Unable to register user',
        'message': 'The verification code is invalid or has expired.',
      },
    );
  }

  final tokens = TokenService.generateTokenPair(
    createdUser.id,
    createdUser.email,
  );

  await EmailService().sendWelcomeEmail(
    email: createdUser.email,
    name: createdUser.firstname,
  );
  return Response.json(
    statusCode: HttpStatus.created, // 201 Created
    body: {
      'statusCode': 201,
      'success': true,
      'message': 'User registration completed successfully.',
      'data': {
        'user': createdUser.toJsonForUser(),
        'accessToken': tokens['accessToken'],
        'refreshToken': tokens['refreshToken'],
      },
    },
  );
}
