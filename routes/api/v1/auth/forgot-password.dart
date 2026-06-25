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

  final authHeader = context.request.headers['authorization']!;
  final accessToken = authHeader.substring('Bearer '.length).trim();
  final jwt = TokenService.verifyToken(accessToken, isRefresh: false);
  if (jwt == null) {
    return Response.json(
      statusCode: HttpStatus.unauthorized,
      body: {
        'statusCode': HttpStatus.unauthorized,
        'data': null,
        'error': 'Unauthorized: Invalid or expired access token.',
      },
    );
  }

  final body = await context.request.json() as Map<String, dynamic>;
  final validationErrors = AuthValidators.validateForgotPasswordPayload(body);
  if (validationErrors != null) {
    return Response.json(
      statusCode: HttpStatus.unprocessableEntity,
      body: {
        'statusCode': HttpStatus.unprocessableEntity,
        'data': null,
        'error': 'Validation failed',
        'details': validationErrors,
      },
    );
  }

  final userId = (jwt.payload as Map<String, dynamic>)['id'] as String;
  final newPassword = (body['newPassword'] as String).trim();
  final authService = AuthService(globalRedis, EmailService());
  final user = await authService.findUserById(globalMongo, userId);

  if (user == null) {
    return Response.json(
      statusCode: HttpStatus.notFound,
      body: {
        'statusCode': HttpStatus.notFound,
        'data': null,
        'error': 'User account not found.',
      },
    );
  }

  final updated = await authService.updateUserPasswordById(
    globalMongo,
    id: user.id,
    newPassword: newPassword,
  );

  if (!updated) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {
        'statusCode': HttpStatus.internalServerError,
        'data': null,
        'error': 'Failed to reset password. Please try again.',
      },
    );
  }

  return Response.json(
    body: {
      'statusCode': HttpStatus.ok,
      'success': true,
      'message': 'Password reset successfully. Login with your new password.',
      // 'data': {
      //   'userId': user.id,
      // },
    },
  );
}
