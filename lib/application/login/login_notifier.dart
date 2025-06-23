// ignore_for_file: empty_catches

import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_login_facebook/flutter_login_facebook.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpodtemp/domain/iterface/auth.dart';
import 'package:riverpodtemp/domain/iterface/user.dart';
import 'package:riverpodtemp/infrastructure/models/data/address_new_data.dart';
import 'package:riverpodtemp/infrastructure/models/data/address_old_data.dart';
import 'package:riverpodtemp/infrastructure/models/models.dart';
import 'package:riverpodtemp/infrastructure/services/app_connectivity.dart';
import 'package:riverpodtemp/infrastructure/services/app_constants.dart';
import 'package:riverpodtemp/infrastructure/services/app_helpers.dart';
import 'package:riverpodtemp/infrastructure/services/app_validators.dart';
import 'package:riverpodtemp/infrastructure/services/local_storage.dart';
import 'package:riverpodtemp/presentation/routes/app_router.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../domain/iterface/settings.dart';
import 'login_state.dart';

class LoginNotifier extends StateNotifier<LoginState> {
  final AuthRepositoryFacade _authRepository;
  final SettingsRepositoryFacade _settingsRepository;
  final UserRepositoryFacade _userRepositoryFacade;

  LoginNotifier(
    this._authRepository,
    this._settingsRepository,
    this._userRepositoryFacade,
  ) : super(const LoginState(countryCode: "+44"));

  void setPassword(String text) {
    state = state.copyWith(
      password: text.trim(),
      isLoginError: false,
      isEmailNotValid: false,
      isPasswordNotValid: false,
    );
  }

  void setEmail(String text) {
    state = state.copyWith(
      email: text.trim(),
      isLoginError: false,
      isEmailNotValid: false,
      isPasswordNotValid: false,
    );
  }

  void setCountryCode(String countryCode) {
    state = state.copyWith(countryCode: countryCode);
  }

  void setShowPassword(bool show) {
    state = state.copyWith(showPassword: show);
  }

  void setKeepLogin(bool keep) {
    state = state.copyWith(isKeepLogin: keep);
  }

  Future<void> checkLanguage(BuildContext context) async {
    final lang = LocalStorage.getLanguage();
    if (lang == null) {
      state = state.copyWith(isSelectLanguage: false);
    } else {
      final connect = await AppConnectivity.connectivity();
      if (connect) {
        final response = await _settingsRepository.getLanguages();
        response.when(
          success: (data) {
            state = state.copyWith(list: data.data ?? []);
            final List<LanguageData> languages = data.data ?? [];
            for (int i = 0; i < languages.length; i++) {
              if (languages[i].id == lang.id) {
                state = state.copyWith(
                  isSelectLanguage: true,
                );
                break;
              }
            }
          },
          failure: (failure, status) {
            state = state.copyWith(isSelectLanguage: false);
            AppHelpers.showCheckTopSnackBar(
              context,
              failure,
            );
          },
        );
      } else {
        if (context.mounted) {
          AppHelpers.showNoConnectionSnackBar(context);
        }
      }
    }
  }

  checkEmail() {
    return AppValidators.checkEmail(state.email);
  }

  Future<void> login(BuildContext context) async {
    final connected = await AppConnectivity.connectivity();
    if (connected) {
      if (checkEmail()) {
        if (!AppValidators.isValidEmail(state.email)) {
          state = state.copyWith(isEmailNotValid: true);
          return;
        }
      }

      if (!AppValidators.isValidPassword(state.password)) {
        state = state.copyWith(isPasswordNotValid: true);
        return;
      }
      state = state.copyWith(isLoading: true);
      final response = await _authRepository.login(
        email: state.email,
        password: state.password,
      );
      response.when(
        success: (data) async {
          LocalStorage.setToken(data.data?.accessToken ?? '');
          LocalStorage.setAddressSelected(AddressData(
              title: data.data?.user?.addresses?.firstWhere(
                      (element) => element.active ?? false, orElse: () {
                    return AddressNewModel();
                  }).title ??
                  "",
              address: data.data?.user?.addresses
                      ?.firstWhere((element) => element.active ?? false,
                          orElse: () {
                        return AddressNewModel();
                      })
                      .address
                      ?.address ??
                  "",
              location: LocationModel(
                  longitude: data.data?.user?.addresses
                      ?.firstWhere((element) => element.active ?? false,
                          orElse: () {
                        return AddressNewModel();
                      })
                      .location
                      ?.last,
                  latitude: data.data?.user?.addresses
                      ?.firstWhere((element) => element.active ?? false,
                          orElse: () {
                        return AddressNewModel();
                      })
                      .location
                      ?.first)));
          if (AppConstants.isDemo) {
            context.replaceRoute(UiTypeRoute());
          } else {
            context.replaceRoute(const MainRoute());
          }
          String? fcmToken = await FirebaseMessaging.instance.getToken();
          _userRepositoryFacade.updateFirebaseToken(fcmToken);
          state = state.copyWith(isLoading: false);
        },
        failure: (failure, status) {
          state = state.copyWith(isLoading: false, isLoginError: true);
          AppHelpers.showCheckTopSnackBar(
            context,
            failure,
          );
        },
      );
    } else {
      if (context.mounted) {
        AppHelpers.showNoConnectionSnackBar(context);
      }
    }
  }

  Future<void> loginWithGoogle(BuildContext context) async {
    try {
      await GoogleSignIn().signOut();
    // ignore:used_catch_stack
    } catch (e) {
    }
    final connected = await AppConnectivity.connectivity();
    if (connected) {
      state = state.copyWith(isLoading: true);
      GoogleSignInAccount? googleUser;
      try {
        googleUser = await GoogleSignIn().signIn();
      } catch (e) {
        state = state.copyWith(isLoading: false);
      }
      if (googleUser == null) {
        state = state.copyWith(isLoading: false);
        return;
      }

      final response = await _authRepository.loginWithGoogle(
        email: googleUser.email,
        displayName: googleUser.displayName ?? '',
        id: googleUser.id,
        avatar: googleUser.photoUrl ?? "",
      );
      response.when(
        success: (data) async {
          state = state.copyWith(isLoading: false);
          LocalStorage.setToken(data.data?.accessToken ?? '');
          LocalStorage.setAddressSelected(AddressData(
              title: data.data?.user?.addresses?.firstWhere(
                      (element) => element.active ?? false, orElse: () {
                    return AddressNewModel();
                  }).title ??
                  "",
              address: data.data?.user?.addresses
                      ?.firstWhere((element) => element.active ?? false,
                          orElse: () {
                        return AddressNewModel();
                      })
                      .address
                      ?.address ??
                  "",
              location: LocationModel(
                  longitude: data.data?.user?.addresses
                      ?.firstWhere((element) => element.active ?? false,
                          orElse: () {
                        return AddressNewModel();
                      })
                      .location
                      ?.last,
                  latitude: data.data?.user?.addresses
                      ?.firstWhere((element) => element.active ?? false,
                          orElse: () {
                        return AddressNewModel();
                      })
                      .location
                      ?.first)));
          context.router.popUntilRoot();
          if (AppConstants.isDemo) {
            context.replaceRoute(UiTypeRoute());
          } else {
            context.replaceRoute(const MainRoute());
          }
          String? fcmToken = await FirebaseMessaging.instance.getToken();
          _userRepositoryFacade.updateFirebaseToken(fcmToken);
        },
        failure: (failure, status) {
          state = state.copyWith(isLoading: false);
          AppHelpers.showCheckTopSnackBar(
            context,
            failure,
          );
        },
      );
    } else {
      if (context.mounted) {
        AppHelpers.showNoConnectionSnackBar(context);
      }
    }
  }

  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  String generateNonce([int length = 32]) {
    // Define the character set to be used in the nonce
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-.';
    // Create a secure random number generator
    final random = Random.secure();

    // Generate a string of the specified length using random characters from the charset
    return String.fromCharCodes(List.generate(
        length, (index) => charset.codeUnitAt(random.nextInt(charset.length))));
  }

  Future<void> loginWithFacebook(BuildContext context) async {
    final connected = await AppConnectivity.connectivity();
    if (connected) {
      state = state.copyWith(isLoading: true);
      try {
        // Trigger the sign-in flow
        final rawNonce = generateNonce();

        final nonce = sha256ofString(rawNonce);
        await FacebookAuth.instance.logOut();
        final result = await FacebookAuth.instance.login(
          loginTracking: LoginTracking.enabled,
          nonce: nonce,
        );
        if (result.status == LoginStatus.success) {
          final token = result.accessToken as LimitedToken;
          // Create a credential from the access token
          OAuthCredential credential = OAuthCredential(
            providerId: 'facebook.com',
            signInMethod: 'oauth',
            idToken: token.tokenString,
            rawNonce: rawNonce,
          );
          final UserCredential userCredential =
              await FirebaseAuth.instance.signInWithCredential(credential);
          if (userCredential.user != null) {
            final response = await _authRepository.loginWithGoogle(
              email: userCredential.user?.email ?? "",
              displayName: userCredential.user?.displayName ?? "",
              id: userCredential.user?.uid ?? "",
              avatar: userCredential.user?.photoURL ?? "",
            );
            response.when(
              success: (data) async {
                state = state.copyWith(isLoading: false);
                LocalStorage.setToken(data.data?.accessToken ?? '');
                LocalStorage.setAddressSelected(AddressData(
                    title: data.data?.user?.addresses?.firstWhere(
                            (element) => element.active ?? false, orElse: () {
                          return AddressNewModel();
                        }).title ??
                        "",
                    address: data.data?.user?.addresses
                            ?.firstWhere((element) => element.active ?? false,
                                orElse: () {
                              return AddressNewModel();
                            })
                            .address
                            ?.address ??
                        "",
                    location: LocationModel(
                        longitude: data.data?.user?.addresses
                            ?.firstWhere((element) => element.active ?? false,
                                orElse: () {
                              return AddressNewModel();
                            })
                            .location
                            ?.last,
                        latitude: data.data?.user?.addresses
                            ?.firstWhere((element) => element.active ?? false,
                                orElse: () {
                              return AddressNewModel();
                            })
                            .location
                            ?.first)));
                context.router.popUntilRoot();
                if (AppConstants.isDemo) {
                  context.replaceRoute(UiTypeRoute());
                } else {
                  context.replaceRoute(const MainRoute());
                }
                String? fcmToken = await FirebaseMessaging.instance.getToken();
                _userRepositoryFacade.updateFirebaseToken(fcmToken);
              },
              failure: (failure, status) {
                state = state.copyWith(isLoading: false);
                AppHelpers.showCheckTopSnackBar(
                  context,
                  failure,
                );
              },
            );
          } else {
            state = state.copyWith(isLoading: false);
            if (context.mounted) {
              AppHelpers.showCheckTopSnackBar(
                context,
                "Facebook login failed. Please try again user null.",
              );
            }
          }
        } else if (result.status == LoginStatus.failed) {
          state = state.copyWith(isLoading: false);
          if (context.mounted) {
            AppHelpers.showCheckTopSnackBar(
              context,
              "Facebook login failed. Please try again.",
            );
          }
        } else {
          state = state.copyWith(isLoading: false);
        }
      } catch (e) {
        state = state.copyWith(isLoading: false);
        debugPrint('===> login with Facebook exception: $e');
        if (context.mounted) {
          AppHelpers.showCheckTopSnackBar(
            context,
            "An error occurred while logging in with Facebook.",
          );
        }
      }
    } else {
      if (context.mounted) {
        AppHelpers.showNoConnectionSnackBar(context);
      }
    }
  }

  Future<void> loginWithFacebookold(BuildContext context) async {
    final connected = await AppConnectivity.connectivity();
    if (connected) {
      state = state.copyWith(isLoading: true);
      try {
        final rawNonce = generateNonce();
        final nonce = sha256ofString(rawNonce);
        final LoginResult result = await FacebookAuth.instance.login(
          permissions: ['email'],
          loginTracking: LoginTracking.limited,
          nonce: nonce,
        );
        if (result.status == LoginStatus.success) {
          final AccessToken? accessToken = result.accessToken;
          final OAuthCredential credential =
              FacebookAuthProvider.credential(accessToken!.tokenString);

          final UserCredential userCredential =
              await FirebaseAuth.instance.signInWithCredential(credential);
          //final user = userCredential.user;

          final response = await _authRepository.loginWithGoogle(
            email: userCredential.user?.email ?? "",
            displayName: userCredential.user?.displayName ?? "",
            id: userCredential.user?.uid ?? "",
            avatar: userCredential.user?.photoURL ?? "",
          );

          response.when(
            success: (data) async {
              state = state.copyWith(isLoading: false);
              LocalStorage.setToken(data.data?.accessToken ?? '');
              LocalStorage.setAddressSelected(AddressData(
                  title: data.data?.user?.addresses?.firstWhere(
                          (element) => element.active ?? false, orElse: () {
                        return AddressNewModel();
                      }).title ??
                      "",
                  address: data.data?.user?.addresses
                          ?.firstWhere((element) => element.active ?? false,
                              orElse: () {
                            return AddressNewModel();
                          })
                          .address
                          ?.address ??
                      "",
                  location: LocationModel(
                      longitude: data.data?.user?.addresses
                          ?.firstWhere((element) => element.active ?? false,
                              orElse: () {
                            return AddressNewModel();
                          })
                          .location
                          ?.last,
                      latitude: data.data?.user?.addresses
                          ?.firstWhere((element) => element.active ?? false,
                              orElse: () {
                            return AddressNewModel();
                          })
                          .location
                          ?.first)));
              context.router.popUntilRoot();
              if (AppConstants.isDemo) {
                context.replaceRoute(UiTypeRoute());
              } else {
                context.replaceRoute(const MainRoute());
              }
              String? fcmToken = await FirebaseMessaging.instance.getToken();
              _userRepositoryFacade.updateFirebaseToken(fcmToken);
            },
            failure: (failure, status) {
              state = state.copyWith(isLoading: false);
              AppHelpers.showCheckTopSnackBar(
                context,
                failure,
              );
            },
          );
        } else if (result.status == LoginStatus.failed) {
          state = state.copyWith(isLoading: false);
          if (context.mounted) {
            AppHelpers.showCheckTopSnackBar(
              context,
              "Facebook login failed. Please try again.",
            );
          }
        } else {
          state = state.copyWith(isLoading: false);
        }
      } catch (e) {
        state = state.copyWith(isLoading: false);
        debugPrint('===> login with Facebook exception: $e');
        if (context.mounted) {
          AppHelpers.showCheckTopSnackBar(
            context,
            "An error occurred while logging in with Facebook.",
          );
        }
      }
    } else {
      if (context.mounted) {
        AppHelpers.showNoConnectionSnackBar(context);
      }
    }
  }

  Future<void> loginWithApple(BuildContext context) async {
    final connected = await AppConnectivity.connectivity();
    if (connected) {
      state = state.copyWith(isLoading: true);

      try {
        final credential = await SignInWithApple.getAppleIDCredential(
          scopes: [
            AppleIDAuthorizationScopes.email,
            AppleIDAuthorizationScopes.fullName,
          ],
        );

        OAuthProvider oAuthProvider = OAuthProvider("apple.com");
        final AuthCredential credentialApple = oAuthProvider.credential(
          idToken: credential.identityToken,
          accessToken: credential.authorizationCode,
        );

        final userObj =
            await FirebaseAuth.instance.signInWithCredential(credentialApple);

        final response = await _authRepository.loginWithGoogle(
            email: credential.email ?? userObj.user?.email ?? "",
            displayName:
                credential.givenName ?? userObj.user?.displayName ?? "",
            id: credential.userIdentifier ?? userObj.user?.uid ?? "",
            avatar: userObj.user?.displayName ?? "");
        response.when(
          success: (data) async {
            state = state.copyWith(isLoading: false);
            LocalStorage.setToken(data.data?.accessToken ?? '');
            LocalStorage.setAddressSelected(AddressData(
                title: data.data?.user?.addresses?.firstWhere(
                        (element) => element.active ?? false, orElse: () {
                      return AddressNewModel();
                    }).title ??
                    "",
                address: data.data?.user?.addresses
                        ?.firstWhere((element) => element.active ?? false,
                            orElse: () {
                          return AddressNewModel();
                        })
                        .address
                        ?.address ??
                    "",
                location: LocationModel(
                    longitude: data.data?.user?.addresses
                        ?.firstWhere((element) => element.active ?? false,
                            orElse: () {
                          return AddressNewModel();
                        })
                        .location
                        ?.last,
                    latitude: data.data?.user?.addresses
                        ?.firstWhere((element) => element.active ?? false,
                            orElse: () {
                          return AddressNewModel();
                        })
                        .location
                        ?.first)));
            context.router.popUntilRoot();
            if (AppConstants.isDemo) {
              context.replaceRoute(UiTypeRoute());
            } else {
              context.replaceRoute(const MainRoute());
            }
            String? fcmToken = await FirebaseMessaging.instance.getToken();
            _userRepositoryFacade.updateFirebaseToken(fcmToken);
          },
          failure: (failure, s) {
            state = state.copyWith(isLoading: false);
            AppHelpers.showCheckTopSnackBar(
              context,
              failure,
            );
          },
        );
      } catch (e) {
        state = state.copyWith(isLoading: false);
        debugPrint('===> login with apple exception: $e');
      }
    } else {
      if (context.mounted) {
        AppHelpers.showNoConnectionSnackBar(context);
      }
    }
  }

  void setLoginType({required bool isEmailLogin}) {}

  void setPhone(String completeNumber) {}
}
