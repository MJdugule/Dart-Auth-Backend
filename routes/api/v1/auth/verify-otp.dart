import 'dart:io';

import 'package:dart_auth_backend/src/core/services/email_service.dart';
import 'package:dart_auth_backend/src/features/auth/auth_service.dart';
import 'package:dart_auth_backend/src/features/auth/auth_validators.dart';
import 'package:dart_frog/dart_frog.dart';

import '../../../../main.dart';

Future<Response> onRequest(RequestContext context) async{
  if (context.request.method != HttpMethod.post) {
    return Response.json(
      statusCode: HttpStatus.methodNotAllowed,
      body: {
        'statusCode': HttpStatus.methodNotAllowed, 
        'data': null, 
        'error': 'Method not found'
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
    final authService = AuthService(globalRedis, EmailService());

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
