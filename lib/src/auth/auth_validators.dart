import 'package:dart_auth_backend/core/validators.dart';

///
extension AuthValidators on Validator {
  /// Validates registration body
  static Map<String, String>? validateRegisterBody(
    Map<String, dynamic> body,
  ) {
    final errors = <String, String>{};

    final email = body['email'] as String?;
    final password = body['password'] as String?;
    final name = body['name'] as String?;

    final emailError = Validators.email()(email);
    if (emailError != null) errors['email'] = emailError;

    final passwordError = Validators.password()(password);
    if (passwordError != null) errors['password'] = passwordError;

    final nameError = Validators.name(isRequired: false)(name);
    if (nameError != null) errors['name'] = nameError;

    return errors.isEmpty ? null : errors;
  }

  /// Validates login body
  static Map<String, String>? validateLoginBody(Map<String, dynamic> body) {
    final errors = <String, String>{};

    final email = body['email'] as String?;
    final password = body['password'] as String?;

    final identityError = Validators.email(
    )(email);
    if (identityError != null) errors['email'] = identityError;

    final passwordError = Validators.notEmpty()(password);
    if (passwordError != null) errors['password'] = passwordError;

    return errors.isEmpty ? null : errors;
  }
}
