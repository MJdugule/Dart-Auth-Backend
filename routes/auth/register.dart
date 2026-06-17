import 'package:bcrypt/bcrypt.dart';
import 'package:dart_auth_backend/src/auth/auth_service.dart';
import 'package:dart_auth_backend/src/auth/auth_validators.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response.json(
      statusCode: 405,
      body: {'data': null, 'error': 'Method not found'},
    );
  }

  // try {
  final body = await context.request.json() as Map<String, dynamic>;
  final validationErrors = AuthValidators.validateRegisterBody(body);
  if (validationErrors != null) {
    return Response.json(
      statusCode: 422, // 422 Unprocessable Entity for invalid data values
      body: {
        'data': null,
        'error': 'Validation failed',
        'details': validationErrors,
      },
    );
  }
  final email = body['email'] as String;
  final password = body['password'] as String;

  // if (email == null ||
  //     email.isEmpty ||
  //     password == null ||
  //     password.isEmpty) {
  //   return Response.json(
  //     statusCode: 401,
  //     body: {'data': null, 'error': 'Email and password are required'},
  //   );
  // }

  if (findUserByEmail(email) != null) {
    return Response.json(
      statusCode: 401,
      body: {'data': null, 'error': 'User already exists'},
    );
  }

  final passwordHash = BCrypt.hashpw(password, BCrypt.gensalt());
  final user = createUser(email: email, hashedPassword: passwordHash);

  final jwt = JWT({'id': user?.id, 'email': user?.email});

  final token = jwt.sign(SecretKey('no-gode'));

  return Response.json(
    body: {
      'data': {'user': user?.toJson(), 'token': token},
    },
  );
  // } catch (e) {
  //   return Response.json(
  //     statusCode: 401,
  //     body: {
  //       'data': null,
  //       'body': {
  //         'statusCode': 400,
  //         'data': null,
  //         'error': 'Invalid or missing JSON payload',
  //       },
  //     },
  //   );
  // }
}
