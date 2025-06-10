class RegisterState {
  final String email;

  final String password;

  final String confirmPassword;

  final String firstName;

  final String lastName;

  final String phone;

  final String referral;

  final String countryCode;

  final bool isLoading;

  final bool isSuccess;

  final bool isEmailInvalid;

  final bool isPasswordInvalid;

  final bool isConfirmPasswordInvalid;

  final bool showPassword;

  final bool showConfirmPassword;

  final String verificationId;

  const RegisterState({
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
    this.firstName = '',
    this.lastName = '',
    this.phone = '',
    this.referral = '',
    this.countryCode = '+44',
    this.isLoading = false,
    this.isSuccess = false,
    this.isEmailInvalid = false,
    this.isPasswordInvalid = false,
    this.isConfirmPasswordInvalid = false,
    this.showPassword = false,
    this.showConfirmPassword = false,
    this.verificationId = '',
  });

  RegisterState copyWith({
    String? email,
    String? password,
    String? confirmPassword,
    String? firstName,
    String? lastName,
    String? phone,
    String? referral,
    String? countryCode,
    bool? isLoading,
    bool? isSuccess,
    bool? isEmailInvalid,
    bool? isPasswordInvalid,
    bool? isConfirmPasswordInvalid,
    bool? showPassword,
    bool? showConfirmPassword,
    String? verificationId,
  }) {
    return RegisterState(
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      referral: referral ?? this.referral,
      countryCode: countryCode ?? this.countryCode,
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      isEmailInvalid: isEmailInvalid ?? this.isEmailInvalid,
      isPasswordInvalid: isPasswordInvalid ?? this.isPasswordInvalid,
      isConfirmPasswordInvalid:
          isConfirmPasswordInvalid ?? this.isConfirmPasswordInvalid,
      showPassword: showPassword ?? this.showPassword,
      showConfirmPassword: showConfirmPassword ?? this.showConfirmPassword,
      verificationId: verificationId ?? this.verificationId,
    );
  }
}
