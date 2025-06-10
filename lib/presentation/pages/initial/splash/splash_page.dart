import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpodtemp/presentation/routes/app_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../application/splash/splash_provider.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import '../../../../infrastructure/services/app_constants.dart';
import '../../auth/reset/set_password_page.dart';

@RoutePage()
class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      ref.read(splashProvider.notifier).getTranslations(context);
      ref.read(splashProvider.notifier).getToken(context, goMain: () async {
        FlutterNativeSplash.remove();
        /*bool shouldRedirect = await checkResetPasswordState();
        if(shouldRedirect)
        context.replaceRoute(const SetPasswordPage());
        else*/
        context.replaceRoute(const MainRoute());
      }, goLogin: () {
        FlutterNativeSplash.remove();
        if (AppConstants.isDemo) {
          context.pushRoute(UiTypeRoute());
          return;
        }
        context.replaceRoute(const LoginRoute());
      }, goNoInternet: () {
        FlutterNativeSplash.remove();
        context.replaceRoute(const NoConnectionRoute());
      });
    });
  }
  Future<bool> checkResetPasswordState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool resetPending = prefs.getBool('reset_password_pending') ?? false;
    return resetPending;
  }
  @override
  Widget build(BuildContext context) {
    return Image.asset(
      "assets/images/splash.png",
      fit: BoxFit.fill,
    );
  }
}
