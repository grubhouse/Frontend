import 'dart:async';
import 'dart:developer';

import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpodtemp/domain/iterface/auth.dart';
import 'package:riverpodtemp/domain/iterface/user.dart';
import 'package:riverpodtemp/infrastructure/services/app_connectivity.dart';
import 'package:riverpodtemp/infrastructure/services/app_constants.dart';
import 'package:riverpodtemp/infrastructure/services/app_helpers.dart';
import 'package:riverpodtemp/infrastructure/services/app_validators.dart';
import 'package:riverpodtemp/infrastructure/services/tr_keys.dart';
import 'package:riverpodtemp/presentation/routes/app_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'reset_password_state.dart';

class ResetPasswordNotifier extends StateNotifier<ResetPasswordState> {
  final AuthRepositoryFacade _authRepository;
  final UserRepositoryFacade _userRepositoryFacade;

  ResetPasswordNotifier(this._authRepository, this._userRepositoryFacade)
      : super(const ResetPasswordState(countryCode: "+44"));
  void setCountryCode(String value) {
    state = state.copyWith(countryCode: value.trim());
  }

  void setEmail(String text) {
    state = state.copyWith(email: text.trim(), isEmailError: false);
  }

  void setVerifyId(String? value) {
    state = state.copyWith(verifyId: value?.trim() ?? '');
  }

  void setPassword(String password) {
    state = state.copyWith(password: password.trim(), isPasswordInvalid: false);
  }

  void setConfirmPassword(String password) {
    state = state.copyWith(
      confirmPassword: password.trim(),
      isConfirmPasswordInvalid: false,
    );
  }

  void toggleShowPassword() {
    state = state.copyWith(showPassword: !state.showPassword);
  }

  void toggleShowConfirmPassword() {
    state = state.copyWith(showConfirmPassword: !state.showConfirmPassword);
  }

  checkEmail() {
    return AppValidators.isValidEmail(state.email);
  }

  Future<void> sendCodeToNumber(BuildContext context) async {
    final connected = await AppConnectivity.connectivity();
    if (connected) {
      state = state.copyWith(isLoading: true, isSuccess: false);
      if (state.email.trim().isEmpty) {
        state = state.copyWith(isLoading: false, isSuccess: false);
        return;
      }
      log("TAG Code :${state.countryCode + state.email.trim()}");
      print("TAG Code :${state.countryCode + state.email.trim()}");
      // ✅ Step 1: Check if the phone number exists in Firebase or database
      /*  bool phoneExists = await checkIfPhoneNumberExists((state.countryCode??"+44") + state.email.trim());

      if (!phoneExists) {
        state = state.copyWith(isLoading: false, isSuccess: false);
        AppHelpers.showCheckTopSnackBar(
          context,
          "Phone number not found. Please register first.",
        );
        return;
      }
      return;*/
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: (state.countryCode ?? "+44") + state.email.trim(),
        verificationCompleted: (PhoneAuthCredential credential) {
          log("TAG Auth Completed ${credential}");
        },
        verificationFailed: (FirebaseAuthException e) {
          log("TAG ${e.message}");
          AppHelpers.showCheckTopSnackBar(
            context,
            AppHelpers.getTranslation(
                AppHelpers.getTranslation(e.message ?? "")),
          );
          state = state.copyWith(isLoading: false, isSuccess: false);
        },
        codeSent: (String verificationId, int? resendToken) async {
          log("TAG Here is the code Sent $verificationId $resendToken");
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setBool('reset_password_pending', true);
          await prefs.setString('reset_phone', state.phone ?? "");
          await prefs.setString(
              'reset_verificationId', state.verificationId ?? "");
          await prefs.setBool('reset_isLoading', state.isLoading);
          await prefs.setBool('reset_isSuccess', state.isSuccess);
          state = state.copyWith(
            phone: state.email,
            isLoading: false,
            verificationId: verificationId,
            isSuccess: true,
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } else {
      if (context.mounted) {
        AppHelpers.showNoConnectionSnackBar(context);
      }
    }
  }

  Future<void> sendCode(BuildContext context) async {
    final connected = await AppConnectivity.connectivity();
    if (connected) {
      state = state.copyWith(isLoading: true, isSuccess: false);
      bool phoneExists = await checkIfEmailAddressExists(state.email.trim());

      if (false) {
        state = state.copyWith(isLoading: false, isSuccess: false);
        AppHelpers.showCheckTopSnackBar(
          context,
          "Email Address not found. Please register first.",
        );
        return;
      }
      final response =
          await _authRepository.forgotPassword(email: state.email.trim());
      response.when(
        success: (data) async {
          state = state.copyWith(
              verifyId: data.data?.verifyId ?? '',
              isLoading: false,
              isSuccess: true);
        },
        failure: (failure, status) {
          state = state.copyWith(
              isLoading: false, isEmailError: true, isSuccess: false);
          AppHelpers.showCheckTopSnackBar(
            context,
            AppHelpers.getTranslation(status.toString()),
          );
          debugPrint('==> send otp failure: $failure');
        },
      );
    } else {
      if (context.mounted) {
        AppHelpers.showCheckTopSnackBar(
          context,
          AppHelpers.getTranslation(TrKeys.checkYourNetworkConnection),
        );
      }
    }
  }

  Future<void> setResetPassword(BuildContext context) async {
    final connected = await AppConnectivity.connectivity();
    if (connected) {
      if (!AppValidators.isValidPassword(state.password)) {
        state = state.copyWith(isPasswordInvalid: true);
        return;
      }
      if (!AppValidators.isValidConfirmPassword(
          state.password, state.confirmPassword)) {
        state = state.copyWith(isConfirmPasswordInvalid: true);
        return;
      }
      state = state.copyWith(isLoading: true, isSuccess: false);
      final response = await _userRepositoryFacade.updatePassword(
        password: state.password,
        passwordConfirmation: state.confirmPassword,
      );
      response.when(
        success: (data) async {
          state = state.copyWith(isLoading: false, isSuccess: true);
          if (AppConstants.isDemo) {
            context.replaceRoute(UiTypeRoute());
          } else {
            context.replaceRoute(const MainRoute());
          }
        },
        failure: (failure, status) {
          state = state.copyWith(isLoading: false, isSuccess: false);
          if (status == 400) {
            AppHelpers.showCheckTopSnackBar(
              context,
              AppHelpers.getTranslation(
                  AppHelpers.getTranslation(TrKeys.emailAlreadyExists)),
            );
          } else {
            AppHelpers.showCheckTopSnackBar(
              context,
              AppHelpers.getTranslation(status.toString()),
            );
          }
        },
      );
    } else {
      if (context.mounted) {
        AppHelpers.showNoConnectionSnackBar(context);
      }
    }
  }

  checkIfEmailAddressExists(String emailAddress) async {
    try {
      print("TAG SignIn Method: ${emailAddress}");

      // Fetch sign-in methods for the email address
      final list =
          await FirebaseAuth.instance.fetchSignInMethodsForEmail(emailAddress);
      print("TAG SignIn Method: ${list.toString()}");
      // In case list is not empty
      if (list.isNotEmpty) {
        return true;
      } else {
        return false;
      }
    } catch (error) {
      return true;
    }
  }

  Future<bool> checkIfPhoneNumberExists(String phoneNumber) async {
    try {
      final signInMethods = await FirebaseAuth.instance
          .fetchSignInMethodsForEmail("$phoneNumber@phone.firebase.com");

      print("TAG SignIn Method: SignIn Methods: $signInMethods");
      return signInMethods.isNotEmpty;
    } catch (error) {
      print("TAG SignIn Method: Error checking phone number: $error");
      return false;
    }
  }
}
