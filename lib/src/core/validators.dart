import 'package:dart_auth_backend/src/core/extensions.dart';

/// Validators
class Validators {
  /// email regex
  static final emailPattern = RegExp(
    r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@"
    '[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}'
    r'[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}'
    r'[a-zA-Z0-9])?)+\s*$',
  );

  /// phonenumber regex
  static final phonePattern = RegExp(r'^\d{10,15}$');

  /// string is not empty
  static Validator notEmpty() {
    return (String? value) {
      return (value?.trim().isEmpty ?? true)
          ? 'This field cannot be empty.'
          : null;
    };
  }

  /// confirm password
  static Validator confirmPass(String originalPassword) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return 'This field cannot be empty.';
      }
      if (originalPassword != value) {
        return 'Passwords do not match';
      }
      return null;
    };
  }

  /// phone
  static Validator phone([String? text]) {
    return (String? value) {
      if (value == null) {
        return null;
      }
      return !phonePattern.hasMatch(value)
          ? (text ?? 'Invalid phone number')
          : null;
    };
  }

  /// Validate name
  static Validator name({bool isRequired = true, String? text}) {
    return (String? value) {
      if ((value == null || value.trim().isEmpty) && isRequired) {
        return text ?? 'Field cannot be empty.';
      }
      return null;

      // if (value!.isEmpty && isRequired) {
      //   return 'Field cannot be empty.';
      // }
      // if (!value.contains(' ')) {
      //   return 'Seperate names with spaces';
      // }
      // return null;
    };
  }

  /// Validate account number
  static Validator accountNumber() {
    return (String? value) {
      return (value!.length < 10) ? 'Invalid account number.' : null;
    };
  }

  /// Validate zipcode
  static Validator zipcode([String? text]) {
    return (String? value) {
      if (value == null || value.isEmpty) return text ?? 'Invalid Postal Code';
      final ziptext = value.trim();
      if (ziptext.length < 7) {
        return 'Postal Code must be at least 7 characters';
      }

      final regex = RegExp(r'^[A-Za-z0-9]+(-[A-Za-z0-9]+)?$');
      return regex.hasMatch(ziptext) ? null : (text ?? 'Invalid Postal Code');
    };
  }

  /// Otp validatioin
  static Validator otp([String? text]) {
    return (String? value) {
      if (value == null || value.isEmpty) return text ?? 'Otp is required';
      final otptext = value.trim();
      if (otptext.length != 6) {
        return 'Otp must be 6 characters';
      }

      final regex = RegExp(r'^[A-Za-z0-9]+(-[A-Za-z0-9]+)?$');
      return regex.hasMatch(otptext) ? null : (text ?? 'Invalid otp');
    };
  }

  /// min length checker
  static Validator minLength(int minLength) {
    return (String? value) {
      if ((value?.length ?? 0) < minLength) {
        return 'Must contain a minimum of $minLength characters.';
      }
      return null;
    };
  }

  /// Validate Pin
  static bool isValid(String pin, String pin2) =>
      pin.isNotEmpty && pin2.isNotEmpty && pin == pin2;

  ///
  static Validator matchPattern(
    Pattern pattern, [
    String? patternName,
    String? text,
  ]) {
    return (String? value) {
      if (value == null || (pattern.allMatches(value).isEmpty)) {
        return text ?? 'Please enter a valid ${patternName ?? 'value'}.';
      }
      return null;
    };
  }

  /// Email validator
  static Validator email([String? text]) {
    return matchPattern(emailPattern, 'email', text);
  }

  /// Email or Phone number validator
  static Validator emailOrPhone([String? text]) {
    return (String? value) {
      if (value == null) {
        return null;
      }
      if (emailPattern.hasMatch(value)) {
        return null;
      } else if (phonePattern.hasMatch(value)) {
        return null;
      } else {
        return text ?? 'Invalid email or phone number';
      }
    };
  }

  /// Password validator
  static Validator password([int minimumLength = 8]) => multiple([
    containsUpper('Password'),
    containsLower('Password'),
    containsNumber('Password'),
    containsSpecialChar('Password'),
    minLength(minimumLength),
  ], shouldTrim: false);

  /// should contain upper case
  static Validator containsUpper([String? fieldName]) {
    return (String? value) {
      if (value != null && value.containsUpper()) return null;
      return 
      "${fieldName ?? 'Field'} must contain at least one uppercase character.";
    };
  }

  /// should contain lower case
  static Validator containsLower([String? fieldName]) {
    return (String? value) {
      if (value != null && value.containsLower()) return null;
      return 
      "${fieldName ?? 'Field'} must contain at least one lowercase character.";
    };
  }

  /// should contain number
  static Validator containsNumber([String? fieldName]) {
    return (String? value) {
      if (value != null && value.containsNumber()) return null;
      return "${fieldName ?? 'Field'} must contain at least one number.";
    };
  }

  /// should contain special character
  static Validator containsSpecialChar([String? fieldName]) {
    return (String? value) {
      if (value != null && value.containsSpecialChar()) return null;
      return 
      "${fieldName ?? 'Field'} must contain at least one special character.";
    };
  }

  /// Creates a validator that if the combination of multiple validators.
  ///
  /// The provided validators are applied in the order in which
  /// they're specified in the list.
  static Validator multiple(
    List<Validator> validators, {
    bool shouldTrim = true,
  }) {
    return (String? value) {
      final values = shouldTrim ? value?.trim() : value;
      for (final validator in validators) {
        if (validator(values) != null) {
          return validator(values);
        }
      }
      return null;
    };
  }

  /// Format number
  static String getCleanedNumber(String text) {
    final regExp = RegExp('[^0-9]');
    return text.replaceAll(regExp, '');
  }

  /// Checks for unwanted keys
  static String? checkUnknownKeys(
    Map<String, dynamic> body,
    List<String> allowedKeys,
  ) {
    for (final key in body.keys) {
      if (!allowedKeys.contains(key)) {
        return 'Unexpected property "$key" is not allowed in this request.';
      }
    }
    return null;
  }

  // static int convertYearTo4Digits(int year) {
  //   if (year < 100 && year >= 0) {
  //     final now = DateTime.now();
  //     final currentYear = now.year.toString();
  //     final prefix = currentYear.substring(0, currentYear.length - 2);
  //     year = int.parse('$prefix${year.toString().padLeft(2, '0')}');
  //   }
  //   return year;
  // }
}

///
typedef Validator = String? Function(String? value);
