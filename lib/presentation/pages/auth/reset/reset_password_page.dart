import 'dart:developer';

import 'package:auto_route/auto_route.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:riverpodtemp/infrastructure/models/data/user.dart';
import 'package:riverpodtemp/infrastructure/services/app_constants.dart';
import 'package:riverpodtemp/infrastructure/services/app_helpers.dart';
import 'package:riverpodtemp/infrastructure/services/local_storage.dart';
import 'package:riverpodtemp/infrastructure/services/tr_keys.dart';
import 'package:riverpodtemp/presentation/components/buttons/custom_button.dart';
import 'package:riverpodtemp/presentation/components/keyboard_dismisser.dart';
import 'package:riverpodtemp/presentation/components/text_fields/outline_bordered_text_field.dart';
import 'package:riverpodtemp/presentation/pages/auth/confirmation/register_confirmation_page.dart';

import '../../../../application/reser_password/reset_password_provider.dart';
import '../../../../infrastructure/services/app_assets.dart';
import '../../../theme/theme.dart';

@RoutePage()
class ResetPasswordPage extends ConsumerWidget {
  const ResetPasswordPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(resetPasswordProvider.notifier);
    final state = ref.watch(resetPasswordProvider);
    final bool isDarkMode = LocalStorage.getAppThemeMode();
    final bool isLtr = LocalStorage.getLangLtr();
    ref.listen(resetPasswordProvider, (previous, next) {
      if (previous!.isSuccess != next.isSuccess && next.isSuccess) {
        Navigator.pop(context);
        AppHelpers.showCustomModalBottomSheet(
          context: context,
          modal: RegisterConfirmationPage(
            countryCode: state.countryCode,
            verificationId: next.verificationId,
            userModel: UserModel(email: state.email),
            isResetPassword: true,
          ),
          isDarkMode: isDarkMode,
        );
      }
    });
    return Scaffold(
      backgroundColor: AppStyle.bgGrey.withOpacity(0.96),
      body: Directionality(
        textDirection: isLtr ? TextDirection.ltr : TextDirection.rtl,
        child: AbsorbPointer(
          absorbing: state.isLoading,
          child: KeyboardDismisser(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.asset(
                          AppAssets.pngGrubhouse,
                          height: 150,
                        ),
                        50.verticalSpace,
                        Text(
                          AppHelpers.getTranslation(TrKeys.resetPassword),
                          style: AppStyle.interBold(
                            size: 20.sp,
                            color: AppStyle.black,
                          ),
                        ),
                        5.verticalSpace,
                        Text(
                          AppHelpers.getTranslation(TrKeys.resetPasswordText),
                          style: AppStyle.interRegular(
                            size: 14.sp,
                            color: AppStyle.black,
                          ),
                        ),
                        40.verticalSpace,
                        if (AppConstants.isSpecificNumberEnabled)
                          Directionality(
                            textDirection:
                                isLtr ? TextDirection.ltr : TextDirection.rtl,
                            child: IntlPhoneField(
                              disableLengthCheck:
                                  !AppConstants.isNumberLengthAlwaysSame,
                              onChanged: (phoneNum) {
                                notifier.setEmail(phoneNum.completeNumber);
                              },
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
                            label: AppHelpers.getTranslation(
                                    TrKeys.emailOrPhoneNumber)
                                .toUpperCase(),
                            onChanged: notifier.setEmail,
                            prefixIcon: CountryCodePicker(
                              favorite: const ['+44', 'GB'],
                              initialSelection: AppConstants.countryCodeISO,
                              showFlag: true,
                              alignLeft: false,
                              onChanged: (value) {
                                log("TAG code ${value.toString()}");
                                notifier.setCountryCode(value.dialCode!);
                              },
                              backgroundColor: Colors.red,
                            ),
                            isError: !state.isSuccess,
                            descriptionText:
                                AppHelpers.getTranslation(TrKeys.canNotBeEmpty), validator: (value) {
                                  return null;
                                  },
                          ),
                      ],
                    ),
                    35.verticalSpace,
                    CustomButton(
                      isLoading: state.isLoading,
                      title: AppHelpers.getTranslation(TrKeys.send),
                      onPressed: () {
                        notifier.checkEmail()
                            ? notifier.sendCode(context)
                            : notifier.sendCodeToNumber(context);
                      },
                      background: AppStyle.brandGreen,
                      textColor: AppStyle.black,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
