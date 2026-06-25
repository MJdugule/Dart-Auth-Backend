import 'package:dart_auth_backend/src/core/validators.dart';

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
      'otp',
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
    final otp = body['otp'] as String?;
    // final referralCode = body['refferalCode'] as String?;

    final emailError = Validators.email()(email);
    if (emailError != null) errors['email'] = emailError;

    final passwordError = Validators.password()(password);
    if (passwordError != null) errors['password'] = passwordError;

    final otpError = Validators.otp()(otp);
    if (otpError != null) errors['otp'] = otpError;

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

  /// Validates otp body
  static Map<String, String>? validateVerifyPayload(Map<String, dynamic> body) {
    final errors = <String, String>{};

    const fields = ['email', 'firstname', 'purpose'];
    final structuralError = Validators.checkUnknownKeys(body, fields);
    if (structuralError != null) {
      errors['body'] = structuralError;
      return errors;
    }

    final email = body['email'] as String?;
    final emailError = Validators.email()(email);
    if (emailError != null) errors['email'] = emailError;

    final purpose = body['purpose'] as String?;
    if (purpose != null &&
        purpose != 'registration' &&
        purpose != 'password_reset') {
      errors['purpose'] =
          'Purpose must be either "registration" or "password_reset".';
    }

    return errors.isEmpty ? null : errors;
  }

  /// Validates OTP code verification payloads
  static Map<String, String>? validateVerifyOtpPayload(
    Map<String, dynamic> body,
  ) {
    final errors = <String, String>{};

    const allowedFields = ['email', 'otp', 'otpKey', 'purpose'];
    final structuralError = Validators.checkUnknownKeys(body, allowedFields);
    if (structuralError != null) {
      errors['body'] = structuralError;
      return errors;
    }

    final email = body['email'] as String?;
    final emailError = Validators.email()(email);
    if (emailError != null) errors['email'] = emailError;

    final otp = body['otp'] as String?;
    final otpError = Validators.otp()(otp);
    if (otpError != null) {
      errors['otp'] = otpError;
    }

    final purpose = body['purpose'] as String?;
    if (purpose != null &&
        purpose != 'registration' &&
        purpose != 'password_reset') {
      errors['purpose'] =
          'Purpose must be either "registration" or "password_reset".';
    }

    return errors.isEmpty ? null : errors;
  }

  /// Validates delete-account payload
  static Map<String, String>? validateDeleteAccountPayload(
    Map<String, dynamic> body,
  ) {
    final errors = <String, String>{};

    const allowedFields = ['password'];
    final structuralError = Validators.checkUnknownKeys(body, allowedFields);
    if (structuralError != null) {
      errors['body'] = structuralError;
      return errors;
    }

    final password = body['password'] as String?;
    final passwordError = Validators.notEmpty()(password);
    if (passwordError != null) {
      errors['password'] = passwordError;
    }

    return errors.isEmpty ? null : errors;
  }

  /// Validates forgot-password payload
  static Map<String, String>? validateForgotPasswordPayload(
    Map<String, dynamic> body,
  ) {
    final errors = <String, String>{};

    const allowedFields = ['newPassword', 'confirmPassword'];
    final structuralError = Validators.checkUnknownKeys(body, allowedFields);
    if (structuralError != null) {
      errors['body'] = structuralError;
      return errors;
    }

    final newPassword = body['newPassword'] as String?;
    final confirmPassword = body['confirmPassword'] as String?;

    final newPasswordError = Validators.password()(newPassword);
    if (newPasswordError != null) {
      errors['newPassword'] = newPasswordError;
    }

    final confirmPasswordError = Validators.confirmPass(newPassword ?? '')(
      confirmPassword,
    );
    if (confirmPasswordError != null) {
      errors['confirmPassword'] = confirmPasswordError;
    }

    return errors.isEmpty ? null : errors;
  }
}
