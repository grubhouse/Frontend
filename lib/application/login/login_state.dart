import 'package:riverpodtemp/infrastructure/models/response/languages_response.dart';

class LoginState {
  final String email;

  final String password;

  final bool isLoading;

  final bool isLoginError;

  final bool isEmailNotValid;

  final bool isPasswordNotValid;

  final bool showPassword;

  final bool isKeepLogin;

  final bool isSelectLanguage;

  final List<LanguageData> list;

  final String countryCode;

  const LoginState({
    this.email = '',
    this.password = '',
    this.isLoading = false,
    this.isLoginError = false,
    this.isEmailNotValid = false,
    this.isPasswordNotValid = false,
    this.showPassword = false,
    this.isKeepLogin = false,
    this.isSelectLanguage = false,
    this.list = const [],
    this.countryCode = '+44',
  });

  LoginState copyWith({
    String? email,
    String? password,
    bool? isLoading,
    bool? isLoginError,
    bool? isEmailNotValid,
    bool? isPasswordNotValid,
    bool? showPassword,
    bool? isKeepLogin,
    bool? isSelectLanguage,
    List<LanguageData>? list,
    String? countryCode,
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      isLoading: isLoading ?? this.isLoading,
      isLoginError: isLoginError ?? this.isLoginError,
      isEmailNotValid: isEmailNotValid ?? this.isEmailNotValid,
      isPasswordNotValid: isPasswordNotValid ?? this.isPasswordNotValid,
      showPassword: showPassword ?? this.showPassword,
      isKeepLogin: isKeepLogin ?? this.isKeepLogin,
      isSelectLanguage: isSelectLanguage ?? this.isSelectLanguage,
      list: list ?? this.list,
      countryCode: countryCode ?? this.countryCode,
    );
  }
}
