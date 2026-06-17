import 'package:bcrypt/bcrypt.dart';
import 'package:dart_auth_backend/src/auth/auth_service.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response.json(
      statusCode: 405,
      body: {'statusCode': 405, 'data': null, 'error': 'Method not found'},
    );
  }

  // try {
    final body = await context.request.json() as Map<String, dynamic>;
    final email = body['email'] as String?;
    final password = body['password'] as String?;

    if (email == null ||
        email.isEmpty ||
        password == null ||
        password.isEmpty) {
      return Response.json(
        statusCode: 401,
        body: {'data': null, 'error': 'Email and password are required'},
      );
    }

    final user = findUserByEmail(email);
    if (user == null || !BCrypt.checkpw(password, user.hashedPassword)) {
      return Response.json(
        statusCode: 401,
        body: {'data': null, 'error': 'Invalid email or password'},
      );
    }

    final jwt = JWT({'id': user.id, 'email': user.email});

    final token = jwt.sign(SecretKey('no-gode'));

    return Response.json(
      body: {
        'data': {'user': user.toJson(), 'token': token},
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
