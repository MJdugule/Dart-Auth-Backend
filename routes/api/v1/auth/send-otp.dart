import 'dart:io';

import 'package:dart_auth_backend/src/core/services/email_service.dart';
import 'package:dart_auth_backend/src/features/auth/auth_service.dart';
import 'package:dart_auth_backend/src/features/auth/auth_validators.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:uuid/uuid.dart';

import '../../../../main.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response.json(
      statusCode: HttpStatus.methodNotAllowed,
      body: {'statusCode': 405, 'data': null, 'error': 'Method not found'},
    );
  }

  final body = await context.request.json() as Map<String, dynamic>;
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

  final email = (body['email'] as String).trim();
  final firstname = body['firstname'] as String? ?? '';
  final purpose = (body['purpose'] as String?)?.trim() ?? '';

  // final userEnteredOtp = (body['otp'] as String).trim();
  // final emailService = EmailService();
  final authService = AuthService(globalRedis, EmailService());

  if (purpose == 'password_reset') {
    final user = await authService.findUserByEmail(globalMongo, email);
    if (user == null) {
      return Response.json(
        statusCode: HttpStatus.notFound,
        body: {
          'statusCode': HttpStatus.notFound,
          'data': null,
          'error': 'User with this email does not exist.',
        },
      );
    }
  }

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

  // String? otpKey;
  // if (purpose == 'password_reset') {
  //   otpKey = const Uuid().v4();
  //   await globalRedis.setValue(
  //     key: 'otp-key:$otpKey',
  //     value: email,
  //     duration: const Duration(minutes: 5),
  //   );
  // }
final cachedOtp = await globalRedis.getValue('otp:$email');
  return Response.json(
    body: {
      'statusCode': 200,
      'success': true,
      'message': 'Verify your email to continue',
      'data': {
        'otp': cachedOtp, // For testing purposes only. Remove in production.
      },
    },
  );
}
