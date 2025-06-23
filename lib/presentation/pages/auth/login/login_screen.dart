import 'dart:io';

import 'package:flutter/material.dart';
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
import 'package:riverpodtemp/application/login/login_provider.dart';
import 'package:riverpodtemp/application/login/login_notifier.dart';
import 'package:riverpodtemp/application/login/login_state.dart';
import 'package:riverpodtemp/infrastructure/services/app_constants.dart';
import 'package:riverpodtemp/presentation/theme/app_style.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

// Add SingleTickerProviderStateMixin for TabController animation
class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loginProvider);
    final event = ref.read(loginProvider.notifier);
    final isLtr = LocalStorage.getLangLtr();

    return Scaffold(
      backgroundColor: AppStyle.bgGrey.withOpacity(0.96),
      body: Directionality(
        textDirection: isLtr ? TextDirection.ltr : TextDirection.rtl,
        child: KeyboardDismisser(
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    32.verticalSpace,
                    Image.asset(AppAssets.pngGrubhouse, height: 120.h),
                    40.verticalSpace,
                    _buildHeader(),
                    30.verticalSpace,
                    _buildTabBar(),
                    20.verticalSpace,
                    _buildTabBarView(event, state, isLtr),
                    20.verticalSpace,
                    _buildPasswordInput(event, state),
                    20.verticalSpace,
                    _buildKeepLoggedInRow(event, state),
                    30.verticalSpace,
                    _buildLoginButton(event, state),
                    40.verticalSpace,
                    _buildSocialLoginSeparator(),
                    22.verticalSpace,
                    _buildSocialButtons(event),
                    20.verticalSpace,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppHelpers.getTranslation(TrKeys.login),
          style: AppStyle.interBold(size: 24.sp, color: AppStyle.black),
        ),
        5.verticalSpace,
        InkWell(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterPage(isOnlyEmail: false,))),
          child: Row(
            children: [
              Text(
                AppHelpers.getTranslation(TrKeys.dontHaveAnAcc),
                style: AppStyle.interNormal(size: 14.sp, color: AppStyle.black),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Text(
                  AppHelpers.getTranslation(TrKeys.signUp),
                  style: AppStyle.interSemi(size: 14.sp, color: AppStyle.brandColor, decoration: TextDecoration.underline),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppStyle.bgGrey,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppStyle.brandColor,
          borderRadius: BorderRadius.circular(10.r),
        ),
        labelColor: AppStyle.white,
        unselectedLabelColor: AppStyle.black,
        tabs: [
          Tab(text: AppHelpers.getTranslation(TrKeys.email)),
          Tab(text: AppHelpers.getTranslation(TrKeys.phoneNumber)),
        ],
      ),
    );
  }
  
  Widget _buildTabBarView(LoginNotifier event, LoginState state, bool isLtr) {
    return SizedBox(
      height: 90.h, // Provides consistent height for the fields
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildEmailLogin(event, state),
          _buildPhoneLogin(event, state, isLtr),
        ],
      ),
    );
  }

  Widget _buildEmailLogin(LoginNotifier event, LoginState state) {
    return OutlinedBorderTextField(
      label: AppHelpers.getTranslation(TrKeys.email).toUpperCase(),
      onChanged: event.setEmail,
      validator: (value) {
        if (value == null || value.isEmpty) return 'Email cannot be empty.';
        if (!AppValidators.isValidEmail(value)) return 'Please enter a valid email.';
        return null;
      },
    );
  }

  Widget _buildPhoneLogin(LoginNotifier event, LoginState state, bool isLtr) {
    return Directionality(
      textDirection: isLtr ? TextDirection.ltr : TextDirection.rtl,
      child: IntlPhoneField(
        onChanged: (phone) => event.setPhone(phone.completeNumber),
        initialCountryCode: AppConstants.countryCodeISO,
        decoration: InputDecoration(
          labelText: AppHelpers.getTranslation(TrKeys.phoneNumber),
          border: const OutlineInputBorder(),
        ),
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (phone) {
          if (phone == null || phone.number.isEmpty) return 'Phone number cannot be empty.';
          return null;
        },
      ),
    );
  }
  
  Widget _buildPasswordInput(LoginNotifier event, LoginState state) {
    return OutlinedBorderTextField(
      label: AppHelpers.getTranslation(TrKeys.password).toUpperCase(),
      obscure: state.showPassword,
      onChanged: event.setPassword,
      suffixIcon: IconButton(
        icon: Icon(state.showPassword ? FlutterRemix.eye_line : FlutterRemix.eye_close_line),
        onPressed: () => event.setShowPassword(!state.showPassword),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Password cannot be empty.';
        if (value.length < 8) return 'Password must be at least 8 characters.';
        return null;
      },
    );
  }

  Widget _buildKeepLoggedInRow(LoginNotifier event, LoginState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SizedBox(
              height: 24.w,
              width: 24.w,
              child: Checkbox(
                value: state.isKeepLogin,
                onChanged: (value) => event.setKeepLogin(value ?? false),
              ),
            ),
            8.horizontalSpace,
            Text(AppHelpers.getTranslation(TrKeys.keepLogged)),
          ],
        ),
        ForgotTextButton(
          title: AppHelpers.getTranslation(TrKeys.forgotPassword),
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ResetPasswordPage())),
        ),
      ],
    );
  }

  Widget _buildLoginButton(LoginNotifier event, LoginState state) {
    return CustomButton(
      title: AppHelpers.getTranslation(TrKeys.login),
      isLoading: state.isLoading,
      onPressed: () {
        if (_formKey.currentState?.validate() ?? false) {
          event.setLoginType(isEmailLogin: _tabController.index == 0);
          event.login(context);
        }
      },
    );
  }

  Widget _buildSocialLoginSeparator() {
    return Row(
      children: <Widget>[
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Text(
            AppHelpers.getTranslation(TrKeys.orAccessQuickly),
            style: AppStyle.interNormal(size: 12.sp, color: AppStyle.textGrey),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }

  Widget _buildSocialButtons(LoginNotifier event) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        if (Platform.isIOS)
          SocialButton(
            iconData: FlutterRemix.apple_fill,
            onPressed: () => event.loginWithApple(context),
            title: "Apple",
          ),
        SocialButton(
          iconData: FlutterRemix.facebook_fill,
          onPressed: () => event.loginWithFacebook(context),
          title: "Facebook",
        ),
        SocialButton(
          iconData: FlutterRemix.google_fill,
          onPressed: () => event.loginWithGoogle(context),
          title: "Google",
        ),
      ],
    );
  }
}