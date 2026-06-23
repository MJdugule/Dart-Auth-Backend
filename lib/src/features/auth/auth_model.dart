///
class User {
  ///
  const User({
    required this.id,
    required this.email,
    required this.firstname,
    required this.lastname,
    required this.hashedPassword,
    this.referralCode,
  });

  /// userId
  final String id;

  /// email
  final String email;

  /// first name
  final String firstname;

  /// last name
  final String lastname;

  /// password
  final String hashedPassword;

  /// referralCode
  final String? referralCode;

  /// toJson
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstname': firstname,
      'lastname': lastname,
      if (referralCode != null) 'referralCode': referralCode,
    };
  }
}
