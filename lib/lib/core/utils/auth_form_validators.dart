/// Shared validators for auth form fields.
abstract final class AuthFormValidators {
  AuthFormValidators._();

  static String? emailOrPhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email or phone is required';
    }
    final trimmed = value.trim();
    final isEmail = trimmed.contains('@');
    final isPhone = RegExp(r'^[0-9+\-\s]{8,}$').hasMatch(trimmed);
    if (!isEmail && !isPhone) {
      return 'Enter a valid email or phone';
    }
    return null;
  }

  static String? requiredPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    if (!value.contains('@')) {
      return 'Enter a valid email';
    }
    return null;
  }

  static String? fullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Full name is required';
    }
    if (value.trim().length < 2) {
      return 'Enter your full name';
    }
    return null;
  }

  static String? phoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    final normalized = value.trim().replaceAll(RegExp(r'[\s\-]'), '');
    if (!RegExp(r'^\+?[0-9]{10,15}$').hasMatch(normalized)) {
      return 'Enter a valid phone number (e.g. +251921859979)';
    }
    return null;
  }
}
