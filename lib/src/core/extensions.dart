///
extension CharacterValidation on String {
  /// Should contain upper case
  bool containsUpper() {
    for (var i = 0; i < length; i++) {
      final code = codeUnitAt(i);
      if (code >= 65 && code <= 90) return true;
    }
    return false;
  }

  /// should contain lower case
  bool containsLower() {
    for (var i = 0; i < length; i++) {
      final code = codeUnitAt(i);
      if (code >= 97 && code <= 122) return true;
    }
    return false;
  }

  /// should contain special character
  bool containsSpecialChar() {
    for (var i = 0; i < length; i++) {
      final char = this[i];
      if (r'#?!@$%^&*-_.,/[]{}|;:+='.contains(char)) return true;
    }
    return false;
  }

  /// should contain username
  bool containsUsernameSpecial() {
    for (var i = 0; i < length; i++) {
      final char = this[i];
      // ignore: prefer_single_quotes
      if (r"#?!@$%^&*,/[]{}|;:+=".contains(char)) return true;
    }
    return false;
  }

  /// should contain number
  bool containsNumber() {
    for (var i = 0; i < length; i++) {
      final code = codeUnitAt(i);
      if (code >= 48 && code <= 57) return true;
    }
    return false;
  }
}
