class SignupValidationResult {
  final String? fullNameError;
  final String? phoneNumberError;
  final String? passwordError;
  final String? nationalIdError;

  const SignupValidationResult({
    this.fullNameError,
    this.phoneNumberError,
    this.passwordError,
    this.nationalIdError,
  });

  bool get isValid =>
      fullNameError == null &&
      phoneNumberError == null &&
      passwordError == null &&
      nationalIdError == null;
}

class LoginValidationResult {
  final String? phoneNumberError;
  final String? passwordError;

  const LoginValidationResult({this.phoneNumberError, this.passwordError});

  bool get isValid => phoneNumberError == null && passwordError == null;
}

class SignupUsecase {
  SignupValidationResult validate({
    required String fullName,
    required String phoneNumber,
    required String password,
  }) {
    String? fullNameError;
    String? phoneNumberError;
    String? passwordError;

    if (fullName.trim().isEmpty) {
      fullNameError = 'Full name is required';
    }

    if (phoneNumber.trim().isEmpty) {
      phoneNumberError = 'Phone number is required';
    } else if (phoneNumber.trim().length != 9) {
      phoneNumberError = 'Phone number must be 9 digits';
    }

    if (password.trim().isEmpty) {
      passwordError = 'Password is required';
    } else if (password.trim().length < 8) {
      passwordError = 'Password must be at least 8 characters';
    }

    return SignupValidationResult(
      fullNameError: fullNameError,
      phoneNumberError: phoneNumberError,
      passwordError: passwordError,
    );
  }



  LoginValidationResult validateLogin({
    required String phoneNumber,
    required String password,
  }) {
    String? phoneNumberError;
    String? passwordError;

    if (phoneNumber.trim().isEmpty) {
      phoneNumberError = 'Phone number is required';
    } else if (phoneNumber.trim().length != 9) {
      phoneNumberError = 'Phone number must be 9 digits';
    }

    if (password.trim().isEmpty) {
      passwordError = 'Password is required';
    } else if (password.trim().length < 8) {
      passwordError = 'Password must be at least 8 characters';
    }

    return LoginValidationResult(
      phoneNumberError: phoneNumberError,
      passwordError: passwordError,
    );
  }
}
