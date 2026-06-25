///
class User {
  ///
  const User({
    required this.id,
    required this.email,
    required this.firstname,
    required this.lastname,
    required this.isActive,
    required this.createdAt,
    this.hashedPassword,
    this.referralCode,
  });

    /// fromJson factory constructor
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      firstname: json['firstname'] as String,
      lastname: json['lastname'] as String,
      isActive: json['isActive'] as bool,
      createdAt: json['createdAt'] as String,
      hashedPassword: json['hashedPassword'] as String?,
      referralCode: json['referralCode'] as String?,
    );
  }

  /// userId
  final String id;

  /// email
  final String email;

  /// first name
  final String firstname;

  /// last name
  final String lastname;

  /// password
  final String? hashedPassword;

  /// referralCode
  final String? referralCode;

  /// isActive
  final bool isActive;

  /// createdAt
  final String createdAt;

  /// Copywith constructor
  User copyWith({
    String? id,
    String? email,
    String? firstname,
    String? lastname,
    String? hashedPassword,
    String? referralCode,
    bool? isActive,
    String? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      firstname: firstname ?? this.firstname,
      lastname: lastname ?? this.lastname,
      hashedPassword: hashedPassword ?? this.hashedPassword,
      referralCode: referralCode ?? this.referralCode,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// toJson
  Map<String, dynamic> toJsonForDataBase() {
    return {
      'id': id,
      'email': email,
      'firstname': firstname,
      'lastname': lastname,
      if (hashedPassword != null) 'hashedPassword': hashedPassword,
      if (referralCode != null) 'referralCode': referralCode,
      'isActive': isActive,
      'createdAt': createdAt,
    };
  }

  /// toJson
  Map<String, dynamic> toJsonForUser() {
    return {
      'id': id,
      'email': email,
      'firstname': firstname,
      'lastname': lastname,
      if (referralCode != null) 'referralCode': referralCode,
      'isActive': isActive,
      'createdAt': createdAt,
    };
  }
}
