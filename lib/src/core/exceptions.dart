///
class RouteNotFoundException implements Exception {

  ///
  RouteNotFoundException(this.path);
  ///
  final String path;

  @override
  String toString() =>
      'RouteNotFoundException: No route found for path "$path"';
}

///
class UserAlreadyExistsException implements Exception {
  ///
  UserAlreadyExistsException(this.message);
  ///
  final String message;
  
  
  @override
  String toString() => message;
}
