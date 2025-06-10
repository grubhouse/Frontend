import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_remix/flutter_remix.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:riverpodtemp/infrastructure/services/app_assets.dart';
import 'package:riverpodtemp/infrastructure/services/app_helpers.dart';
import 'package:riverpodtemp/infrastructure/services/app_validators.dart';
import 'package:riverpodtemp/infrastructure/services/local_storage.dart';
import 'package:riverpodtemp/infrastructure/services/tr_keys.dart';
import 'package:riverpodtemp/presentation/components/buttons/custom_button.dart';
import 'package:riverpodtemp/presentation/components/buttons/forgot_text_button.dart';
import 'package:riverpodtemp/presentation/components/buttons/social_button.dart';
import 'package:riverpodtemp/presentation/components/keyboard_dismisser.dart';
import 'package:riverpodtemp/presentation/components/text_fields/outline_bordered_text_field.dart';
import 'package:riverpodtemp/presentation/pages/auth/register/register_page.dart';
import 'package:riverpodtemp/presentation/pages/auth/reset/reset_password_page.dart';

import '../../../../application/login/login_provider.dart';
import '../../../../infrastructure/services/app_constants.dart';
import '../../../theme/app_style.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final GlobalKey<FormState> key = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final event = ref.read(loginProvider.notifier);
    final state = ref.watch(loginProvider);
    final bool isDarkMode = LocalStorage.getAppThemeMode();
    final bool isLtr = LocalStorage.getLangLtr();
    return Scaffold(
      backgroundColor: AppStyle.bgGrey.withOpacity(0.96),
      body: Directionality(
        textDirection: isLtr ? TextDirection.ltr : TextDirection.rtl,
        child: KeyboardDismisser(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Form(
                    key: key,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.asset(
                          AppAssets.pngGrubhouse,
                          height: 150,
                        ),
                        50.verticalSpace,
                        Text(
                          AppHelpers.getTranslation(TrKeys.login),
                          style: AppStyle.interBold(
                            size: 20.sp,
                            color: AppStyle.black,
                          ),
                        ),
                        5.verticalSpace,
                        Row(
                          children: [
                            Text(
                              AppHelpers.getTranslation(TrKeys.dontHaveAnAcc),
                              style: AppStyle.interNormal(
                                size: 14.sp,
                                color: AppStyle.black,
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (ctx) => RegisterPage(
                                              isOnlyEmail: true,
                                            )));
                              },
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                child: Text(
                                  AppHelpers.getTranslation(TrKeys.signUp),
                                  style: AppStyle.interNormal(
                                    size: 14.sp,
                                    textDecoration: TextDecoration.underline,
                                    color: AppStyle.black,
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                        50.verticalSpace,
                        if (AppConstants.isSpecificNumberEnabled)
                          Directionality(
                            textDirection:
                                isLtr ? TextDirection.ltr : TextDirection.rtl,
                            child: IntlPhoneField(
                              onChanged: (phoneNum) {
                                event.setEmail(phoneNum.completeNumber);
                              },
                              disableLengthCheck:
                                  !AppConstants.isNumberLengthAlwaysSame,
                              validator: (s) {
                                if (AppConstants.isNumberLengthAlwaysSame &&
                                    (s?.isValidNumber() ?? true)) {
                                  return AppHelpers.getTranslation(
                                      TrKeys.phoneNumberIsNotValid);
                                }
                                return null;
                              },
                              keyboardType: TextInputType.phone,
                              initialCountryCode: AppConstants.countryCodeISO,
                              invalidNumberMessage: AppHelpers.getTranslation(
                                  TrKeys.phoneNumberIsNotValid),
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              showCountryFlag: AppConstants.showFlag,
                              showDropdownIcon: AppConstants.showArrowIcon,
                              autovalidateMode:
                                  AppConstants.isNumberLengthAlwaysSame
                                      ? AutovalidateMode.onUserInteraction
                                      : AutovalidateMode.disabled,
                              textAlignVertical: TextAlignVertical.center,
                              decoration: InputDecoration(
                                counterText: '',
                                enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide.merge(
                                        const BorderSide(
                                            color: AppStyle.differBorderColor),
                                        const BorderSide(
                                            color:
                                                AppStyle.differBorderColor))),
                                errorBorder: UnderlineInputBorder(
                                    borderSide: BorderSide.merge(
                                        const BorderSide(
                                            color: AppStyle.differBorderColor),
                                        const BorderSide(
                                            color:
                                                AppStyle.differBorderColor))),
                                border: const UnderlineInputBorder(),
                                focusedErrorBorder:
                                    const UnderlineInputBorder(),
                                disabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide.merge(
                                        const BorderSide(
                                            color: AppStyle.differBorderColor),
                                        const BorderSide(
                                            color:
                                                AppStyle.differBorderColor))),
                                focusedBorder: const UnderlineInputBorder(),
                              ),
                            ),
                          ),
                        if (!AppConstants.isSpecificNumberEnabled)
                          OutlinedBorderTextField(
                            prefixIcon: CountryCodePicker(
                              initialSelection: AppConstants.countryCodeISO,
                              showFlag: true,
                              alignLeft: false,
                              onChanged: (value) {
                                event.setCountryCode(value.dialCode!);
                              },
                              backgroundColor: Colors.red,
                            ),
                            label: AppHelpers.getTranslation(
                                    TrKeys.emailOrPhoneNumber)
                                .toUpperCase(),
                            onChanged: (p0) {
                              if (AppValidators.isValidEmail(p0)) {
                                event.setEmail(p0);
                              } else {
                                event.setEmail(state.countryCode + p0);
                              }
                            },
                            isError: state.isEmailNotValid,
                            validation: (s) {
                              if (s?.isEmpty ?? true) {
                                return AppHelpers.getTranslation(
                                    TrKeys.emailIsNotValid);
                              }
                              return null;
                            },
                            descriptionText: state.isEmailNotValid
                                ? AppHelpers.getTranslation(
                                    TrKeys.emailIsNotValid)
                                : null,
                          ),
                        34.verticalSpace,
                        OutlinedBorderTextField(
                          label: AppHelpers.getTranslation(TrKeys.password)
                              .toUpperCase(),
                          obscure: state.showPassword,
                          suffixIcon: IconButton(
                            splashRadius: 25,
                            icon: Icon(
                              state.showPassword
                                  ? FlutterRemix.eye_line
                                  : FlutterRemix.eye_close_line,
                              color: isDarkMode
                                  ? AppStyle.black
                                  : AppStyle.hintColor,
                              size: 20.r,
                            ),
                            onPressed: () =>
                                event.setShowPassword(!state.showPassword),
                          ),
                          onChanged: event.setPassword,
                          isError: state.isPasswordNotValid,
                          descriptionText: state.isPasswordNotValid
                              ? AppHelpers.getTranslation(TrKeys
                                  .passwordShouldContainMinimum8Characters)
                              : null,
                        ),
                        30.verticalSpace,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                  height: 20.h,
                                  width: 20.w,
                                  child: Checkbox(
                                    side: BorderSide(
                                      color: AppStyle.black,
                                      width: 2.r,
                                    ),
                                    activeColor: AppStyle.black,
                                    value: state.isKeepLogin,
                                    onChanged: (value) =>
                                        event.setKeepLogin(value!),
                                  ),
                                ),
                                8.horizontalSpace,
                                Text(
                                  AppHelpers.getTranslation(TrKeys.keepLogged),
                                  style: AppStyle.interNormal(
                                    size: 12.sp,
                                    color: AppStyle.black,
                                  ),
                                ),
                              ],
                            ),
                            ForgotTextButton(
                              title: AppHelpers.getTranslation(
                                TrKeys.forgotPassword,
                              ),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (ctx) =>
                                            const ResetPasswordPage()));
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  20.verticalSpace,
                  CustomButton(
                    isLoading: state.isLoading,
                    title: 'Login',
                    onPressed: () {
                      // context.replaceRoute(const MainRoute());

                      if (key.currentState?.validate() ?? false) {
                        event.login(context);
                      }
                    },
                  ),
                  20.verticalSpace,
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: SizedBox(
        height: 100,
        child: Column(
          children: [
            Row(children: <Widget>[
              Expanded(
                  child: Divider(
                color: AppStyle.black.withOpacity(0.5),
              )),
              Padding(
                padding: const EdgeInsets.only(right: 12, left: 12),
                child: Text(
                  AppHelpers.getTranslation(TrKeys.orAccessQuickly),
                  style: AppStyle.interNormal(
                    size: 12.sp,
                    color: AppStyle.textGrey,
                  ),
                ),
              ),
              Expanded(
                  child: Divider(
                color: AppStyle.black.withOpacity(0.5),
              )),
            ]),
            22.verticalSpace,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                if (Theme.of(context).platform == TargetPlatform.iOS)
                  SocialButton(
                      iconData: FlutterRemix.apple_fill,
                      onPressed: () {
                        event.loginWithApple(context);
                      },
                      title: "Apple"),
                SocialButton(
                    iconData: FlutterRemix.facebook_fill,
                    onPressed: () {
                      event.loginWithFacebook(context);
                    },
                    title: "Facebook"),
                SocialButton(
                    iconData: FlutterRemix.google_fill,
                    onPressed: () {
                      event.loginWithGoogle(context);
                    },
                    title: "Google"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
