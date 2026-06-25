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
      statusCode: HttpStatus.methodNotAllowed,
      body: {
        'statusCode': HttpStatus.methodNotAllowed,
        'data': null,
        'error': 'Method not found',
      },
    );
  }

  final body = await context.request.json() as Map<String, dynamic>;

  final validationErrors = AuthValidators.validateVerifyOtpPayload(body);
  if (validationErrors != null) {
    return Response.json(
      statusCode: HttpStatus.unprocessableEntity, // 422
      body: {
        'statusCode': 422,
        'data': null,
        'error': 'Validation failed',
        'details': validationErrors,
      },
    );
  }

  final email = (body['email'] as String).trim();
  final submittedOtp = (body['otp'] as String).trim();
  final purpose = (body['purpose'] as String?)?.trim() ?? '';
  final authService = AuthService(globalRedis, EmailService());

  

  if (purpose == 'password_reset') {
    final user = await authService.findUserByEmail(globalMongo, email);
    if (user == null) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {
          'statusCode': HttpStatus.badRequest,
          'data': null,
          'error': 'User with this email does not exist.',
        },
      );
    }

    final isValid = await authService.verifyOtpCode(
    email: email,
    submittedOtp: submittedOtp,
  );

  if (!isValid) {
    return Response.json(
      statusCode: HttpStatus.badRequest, // 400
      body: {
        'statusCode': 400,
        'data': null,
        'error': 'Invalid or expired verification code.',
      },
    );
  }

    final resetToken = TokenService.generateResetToken(
      user.id,
      user.email,
    );

    return Response.json(
      body: {
        'statusCode': HttpStatus.ok,
        'success': true,
        'message': 'OTP verified successfully for password reset.',
        'data': {
          'email': user.email,
          'purpose': 'password_reset',
          'resetToken': resetToken,
        },
      },
    );
  }

  final isValid = await authService.verifyOtpCode(
    email: email,
    submittedOtp: submittedOtp,
  );

  if (!isValid) {
    return Response.json(
      statusCode: HttpStatus.badRequest, // 400
      body: {
        'statusCode': 400,
        'data': null,
        'error': 'Invalid or expired verification code.',
      },
    );
  }

  return Response.json(
    body: {
      'statusCode': 200,
      'success': true,
      'message': 'Email verified successfully.',
      'data': {
        'email': email,
        'isVerified': true,
      },
    },
  );
}
