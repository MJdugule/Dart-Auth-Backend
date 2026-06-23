import 'package:collection/collection.dart';
import 'package:dart_auth_backend/src/features/auth/auth_model.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();
final _users = <String, User>{};

/// find user by email
User? findUserByEmail(String email) {
  return _users.values.firstWhereOrNull((user) => user.email == email);
}

/// find user by id
User? findUserByID(String id) {
  return _users[id];
}

/// create user
User? createUser({
  required String email,
  required String hashedPassword,
  required String firstname,
  required String lastname,
  String? referralCode,
}) {
  final id = _uuid.v4();
  final user = User(
    id: id,
    email: email,
    hashedPassword: hashedPassword,
    firstname: firstname,
    lastname: lastname,
    referralCode: referralCode,
  );
  _users[id] = user;
  return user;
}
