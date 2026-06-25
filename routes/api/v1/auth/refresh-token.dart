import 'dart:io';

import 'package:dart_auth_backend/src/core/services/email_service.dart';
import 'package:dart_auth_backend/src/core/services/token_service.dart';
import 'package:dart_auth_backend/src/features/auth/auth_service.dart';
import 'package:dart_frog/dart_frog.dart';

import '../../../../main.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response.json(
      statusCode: 405,
      body: {'statusCode': 405, 'data': null, 'error': 'Method not found'},
    );
  }

  final body = await context.request.json() as Map<String, dynamic>;
  final refreshToken = body['refreshToken'] as String?;

  if (refreshToken == null || refreshToken.isEmpty) {
    return Response.json(
      statusCode: 400,
      body: {
        'statusCode': 400,
        'success': false,
        'message': 'Unable to refresh session',
        'data': null, 'error': 'Refresh token is required.'},
    );
  }

  final jwt = TokenService.verifyToken(refreshToken, isRefresh: true);
  if (jwt == null ||
      (jwt.payload as Map<String, dynamic>)['type'] != 'refresh') {
    return Response.json(
      statusCode: HttpStatus.unauthorized,
      body: {
        'statusCode': HttpStatus.unauthorized,
        'success': false,
        'message': 'Invalid or expired refresh token.',
        'data': null, 'error': 'Invalid or expired refresh token.'},
    );
  }

  final userId = (jwt.payload as Map<String, dynamic>)['id'] as String;
  final authService = AuthService(globalRedis, EmailService());
  final user = await authService.findUserById(globalMongo, userId);

  if (user == null) {
    return Response.json(
      statusCode: HttpStatus.unauthorized,
      body: {
        'statusCode': HttpStatus.unauthorized,
        'success': false,
        'message': 'Invalid refresh token subject.',
        'data': null,
        'error': 'Invalid refresh token subject.',
      },
    );
  }

  final newTokens = TokenService.generateTokenPair(user.id, user.email);

  return Response.json(
    body: {
      'statusCode': 200,
      'success': true,
      'message': 'Successful',
      'data': {
        'accessToken': newTokens['accessToken'],
        'refreshToken': newTokens['refreshToken'],
      },
    },
  );
}
