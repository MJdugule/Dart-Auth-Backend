import 'package:dart_auth_backend/core/services/token_service.dart';
import 'package:dart_auth_backend/src/auth/auth_validators.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response.json(
      statusCode: 405,
      body: {'statusCode': 405, 'data': null, 'error': 'Method not found'},
    );
  }

  final registrationToken = context.request.headers['x-registration-token'];
  if (registrationToken == null || registrationToken.isEmpty) {
    return Response.json(
      statusCode: 400,
      body: {
        'data': null,
        'error': 'Missing registration token header (x-registration-token).',
      },
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

  // final userEnteredOtp = (body['otp'] as String).trim();
  final jwt = TokenService.verifyEmailToken(registrationToken);
  if (jwt == null) {
    return Response.json(
      statusCode: 410, // Gone (The JWT token signature has expired)
      body: {
        'data': null,
        'error': 'Verification session expired. Please sign up again.',
      },
    );
  }

    return Response.json(
    body: {
      'message': 'Account verified and created successfully!',
      
    },
  );

}
