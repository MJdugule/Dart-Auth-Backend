///
class User {
  ///
  const User({
    required this.id,
    required this.email,
    required this.hashedPassword,
  });

  /// userId
  final String id;

  /// email
  final String email;

  /// password
  final String hashedPassword;

  /// toJson
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
    };
  }
}
