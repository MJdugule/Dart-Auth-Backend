import 'package:dart_frog/dart_frog.dart';

Handler middleware(Handler handler){
  return (context) async {
    try {
      return await handler(context);
    } on FormatException catch (e) {
      return Response.json(
        statusCode: 400,
        body: {
          'statusCode': 400,
          'data': null,
          'error': 'Malformed body payload: ${e.message}',
        },
      );
    } catch (error) {
      // print('CRITICAL ERROR: $error\n$stackTrace');
      return Response.json(
        statusCode: 500,
        body: {
          'statusCode': 500,
          'data': null,
          'error': 'Internal server error occurred.',
        },
      );
    }
  };
}
