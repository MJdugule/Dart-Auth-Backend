import 'package:dart_auth_backend/core/validators.dart';

///
extension AuthValidators on Validator {
  /// Validates registration body
  static Map<String, String>? validateRegisterBody(
    Map<String, dynamic> body,
  ) {
    final errors = <String, String>{};

    const fields = [
      'email',
      'password',
      'firstname',
      'lastname',
      'referralCode',
    ];
    final bodyError = Validators.checkUnknownKeys(body, fields);

    if (bodyError != null) {
      errors['body'] = bodyError;
      return errors;
    }

    final email = body['email'] as String?;
    final password = body['password'] as String?;
    final firstname = body['firstname'] as String?;
    final lastname = body['lastname'] as String?;
    // final referralCode = body['refferalCode'] as String?;

    final emailError = Validators.email()(email);
    if (emailError != null) errors['email'] = emailError;

    final passwordError = Validators.password()(password);
    if (passwordError != null) errors['password'] = passwordError;

    final firstnameError = Validators.name(text: 'First name is required')(
      firstname,
    );
    if (firstnameError != null) errors['firstname'] = firstnameError;

    final lastNameError = Validators.name(text: 'Last name is required')(
      lastname,
    );
    if (lastNameError != null) errors['lastname'] = lastNameError;

    return errors.isEmpty ? null : errors;
  }

  /// Validates login body
  static Map<String, String>? validateLoginBody(Map<String, dynamic> body) {
    final errors = <String, String>{};

    const fields = [
      'email',
      'password',
    ];
    final bodyError = Validators.checkUnknownKeys(body, fields);

    if (bodyError != null) {
      errors['body'] = bodyError;
      return errors;
    }

    final email = body['email'] as String?;
    final password = body['password'] as String?;

    final emailError = Validators.email()(email);
    if (emailError != null) errors['email'] = emailError;

    final passwordError = Validators.notEmpty()(password);
    if (passwordError != null) errors['password'] = passwordError;

    return errors.isEmpty ? null : errors;
  }
}
