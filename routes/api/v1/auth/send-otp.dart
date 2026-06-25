import 'dart:io';
import 'package:dart_auth_backend/src/core/services/email_service.dart';
import 'package:dart_auth_backend/src/features/auth/auth_service.dart';
import 'package:dart_auth_backend/src/features/auth/auth_validators.dart';
import 'package:dart_frog/dart_frog.dart';

import '../../../../main.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response.json(
      statusCode: HttpStatus.methodNotAllowed,
      body: {'statusCode': 405, 'data': null, 'error': 'Method not found'},
    );
  }



  final body = await context.request.json() as Map<String, dynamic>;
  final email = body['email'] as String;
  final firstname = body['firstname'] as String? ?? '';
  final validationErrors = AuthValidators.validateVerifyPayload(body);
  if (validationErrors != null) {
    return Response.json(
      statusCode: 422,
      body: {
        'data': null,
        'error': 'Validation failed',
        'details': validationErrors,
      },
    );
  }

  // final userEnteredOtp = (body['otp'] as String).trim();
  // final emailService = EmailService();
  final authService = AuthService(globalRedis, EmailService());

  final canSendOtp = await authService.canSendOtp(email);
  if (!canSendOtp) {
    return Response.json(
      statusCode: HttpStatus.tooManyRequests,
      body: {
        'statusCode': HttpStatus.tooManyRequests,
        'data': null,
        'error': 'Please wait before requesting another OTP. '
            'Try again in 60 seconds.',
      },
    );
  }

  final sent = await authService.generateAndSendOtp(
    email: email,
    name: firstname,
  );

  if (!sent) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {
        'statusCode': HttpStatus.internalServerError,
        'data': null,
        'error': 'Failed to send OTP email. Please try again.',
      },
    );
  }

  return Response.json(
    body: {
      'statusCode': 200,
      'success': true,
      'message':
          'Verify your email to continue',
      // 'data': {
        // 'user': user?.toJson(),
        // 'registrationToken': accessToken,
        // 'refreshToken': tokens['refreshToken'],
      // },
    },
  );

}
