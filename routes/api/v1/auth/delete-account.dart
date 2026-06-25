import 'dart:async';
import 'dart:io';

import 'package:dart_auth_backend/src/core/services/email_service.dart';
import 'package:dart_auth_backend/src/core/services/token_service.dart';
import 'package:dart_auth_backend/src/features/auth/auth_service.dart';
import 'package:dart_auth_backend/src/features/auth/auth_validators.dart';
import 'package:dart_frog/dart_frog.dart';

import '../../../../main.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.delete) {
    return Response.json(
      statusCode: HttpStatus.methodNotAllowed,
      body: {
        'statusCode': HttpStatus.methodNotAllowed,
        'data': null,
        'error': 'Method not found',
      },
    );
  }

  final authHeader = context.request.headers['authorization'];
  if (authHeader == null || !authHeader.startsWith('Bearer ')) {
    return Response.json(
      statusCode: HttpStatus.unauthorized,
      body: {
        'statusCode': HttpStatus.unauthorized,
        'data': null,
        'error': 'Unauthorized access.',
      },
    );
  }

  final accessToken = authHeader.substring('Bearer '.length).trim();
  if (accessToken.isEmpty) {
    return Response.json(
      statusCode: HttpStatus.unauthorized,
      body: {
        'statusCode': HttpStatus.unauthorized,
        'data': null,
        'error': 'Unauthorized access.',
      },
    );
  }

  final jwt = TokenService.verifyToken(accessToken, isRefresh: false);
  if (jwt == null ||
      (jwt.payload as Map<String, dynamic>)['type'] != 'access') {
    return Response.json(
      statusCode: HttpStatus.unauthorized,
      body: {
        'statusCode': HttpStatus.unauthorized,
        'data': null,
        'error': 'Invalid or expired access token.',
      },
    );
  }

  final body = await context.request.json() as Map<String, dynamic>;
  final validationErrors = AuthValidators.validateDeleteAccountPayload(body);
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
  final password = (body['password'] as String).trim();

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

  if (!TokenService.verifyPassword(password, user.hashedPassword ?? '')) {
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: {
        'statusCode': HttpStatus.badRequest,
        'data': null,
        'error': 'Invalid password.',
      },
    );
  }

  final deleted = await authService.deleteUserById(globalMongo, userId);
  if (!deleted) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {
        'statusCode': HttpStatus.internalServerError,
        'data': null,
        'error': 'Unable to delete account at this time.',
      },
    );
  }

  unawaited(
    EmailService().sendGoodbyeEmail(
      email: user.email,
      name: user.firstname,
    ),
  );

  return Response.json(
    body: {
      'statusCode': HttpStatus.ok,
      'success': true,
      'message': 'Account deleted successfully.',
      'data': null,
    },
  );
}
