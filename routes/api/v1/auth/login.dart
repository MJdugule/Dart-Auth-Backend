import 'package:bcrypt/bcrypt.dart';
import 'package:dart_auth_backend/src/core/services/token_service.dart';
import 'package:dart_auth_backend/src/features/auth/auth_service.dart';
import 'package:dart_auth_backend/src/features/auth/auth_validators.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response.json(
      statusCode: 405,
      body: {'statusCode': 405, 'data': null, 'error': 'Method not found'},
    );
  }

  // try {
  final body = await context.request.json() as Map<String, dynamic>;

  final validationErrors = AuthValidators.validateLoginBody(body);
  if (validationErrors != null) {
    return Response.json(
      statusCode: 422, // 422 Unprocessable Entity for invalid data values
      body: {
        'statusCode': 422,
        'success': false,
        'message': 'Unable to login',
        'data': null,
        'error': 'Validation failed',
        'details': validationErrors,
      },
    );
  }
  final email = body['email'] as String;
  final password = body['password'] as String;

  final user = findUserByEmail(email);
  if (user == null || !BCrypt.checkpw(password, user.hashedPassword)) {
    return Response.json(
      statusCode: 401,
      body: {
        'statusCode': 401,
        'success': false,
        'message': 'Unable to login',
        'data': null,
        'error': 'Invalid email or password',
      },
    );
  }

  final tokens = TokenService.generateTokenPair(user.id, user.email);

  return Response.json(
    body: {
      'statusCode': 200,
      'success': true,
      'message': 'Successfully logged in',
      'data': {
        'user': user.toJson(),
        'accessToken': tokens['accessToken'],
        'refreshToken': tokens['refreshToken'],
      },
    },
  );
  // } catch (e) {
  //   return Response.json(
  //     statusCode:
  //         400, // Bad Request is more appropriate for missing/malformed payloads
  //     body: {'data': null, 'error': 'Invalid or missing JSON payload'},
  //   );
  // }
}
