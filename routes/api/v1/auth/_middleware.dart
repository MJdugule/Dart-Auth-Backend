import 'dart:io';

import 'package:dart_frog/dart_frog.dart';

Handler middleware(Handler handler) {
  return (context) async {
    final path = context.request.uri.path;
    final isProtectedRoute =
        path.endsWith('/forgot-password') || path.endsWith('/delete-account');

    if (isProtectedRoute) {
      final authHeader = context.request.headers['authorization'];
      if (authHeader == null || !authHeader.startsWith('Bearer ')) {
        return Response.json(
          statusCode: HttpStatus.unauthorized,
          body: {
            'statusCode': HttpStatus.unauthorized,
            'data': null,
            'error': 'Unauthorized',
          },
        );
      }

      final token = authHeader.substring('Bearer '.length).trim();
      if (token.isEmpty) {
        return Response.json(
          statusCode: HttpStatus.unauthorized,
          body: {
            'statusCode': HttpStatus.unauthorized,
            'data': null,
            'error': 'Unauthorized',
          },
        );
      }
    }

    return handler(context);
  };
}
