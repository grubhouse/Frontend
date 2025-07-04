import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:riverpodtemp/infrastructure/models/models.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import '../../presentation/theme/app_style.dart';
import '../../../infrastructure/services/local_storage.dart';
import 'app_constants.dart';

class AppHelpers {
  AppHelpers._();

  static String numberFormat({num? number, String? symbol, bool? isOrder}) {
    if (LocalStorage.getSelectedCurrency()?.position == "before") {
      return NumberFormat.currency(
        customPattern: '\u00a4#,###.#',
        symbol: (isOrder ?? false)
            ? symbol
            : LocalStorage.getSelectedCurrency()?.symbol,
        decimalDigits: 2,
      ).format(number ?? 0);
    } else {
      return NumberFormat.currency(
        customPattern: '#,###.#\u00a4',
        symbol: (isOrder ?? false)
            ? symbol
            : LocalStorage.getSelectedCurrency()?.symbol,
        decimalDigits: 2,
      ).format(number ?? 0);
    }
  }

  static showNoConnectionSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    final snackBar = SnackBar(
      backgroundColor: AppStyle.brandGreen,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 3),
      content: Text(
        'No internet connection',
        style: AppStyle.interNoSemi(
          size: 14,
          color: AppStyle.white,
        ),
      ),
      action: SnackBarAction(
        label: 'Close',
        disabledTextColor: AppStyle.black,
        textColor: AppStyle.black,
        onPressed: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static ExtrasType getExtraTypeByValue(String? value) {
    switch (value) {
      case 'color':
        return ExtrasType.color;
      case 'text':
        return ExtrasType.text;
      case 'image':
        return ExtrasType.image;
      default:
        return ExtrasType.text;
    }
  }

  static OrderStatus getOrderStatus(String? value) {
    switch (value) {
      case 'new':
        return OrderStatus.open;
      case 'accepted':
        return OrderStatus.accepted;
      case 'ready':
        return OrderStatus.ready;
      case 'on_a_way':
        return OrderStatus.onWay;
      case 'delivered':
        return OrderStatus.delivered;
      case 'canceled':
        return OrderStatus.canceled;
      default:
        return OrderStatus.accepted;
    }
  }

  static String? getOrderByString(String value) {
    switch (getTranslationReverse(value)) {
      case "new":
        return "new";
      case "trust_you":
        return "trust_you";
      case 'highly_rated':
        return "high_rating";
      case 'best_sale':
        return "best_sale";
      case 'low_sale':
        return "low_sale";
      case 'low_rating':
        return "low_rating";
    }
    return null;
  }

  static String getOrderStatusText(OrderStatus value) {
    switch (value) {
      case OrderStatus.open:
        return "new";
      case OrderStatus.accepted:
        return "accepted";
      case OrderStatus.ready:
        return "ready";
      case OrderStatus.onWay:
        return "on_a_way";
      case OrderStatus.delivered:
        return "delivered";
      case OrderStatus.canceled:
        return "canceled";
      default:
        return "accepted";
    }
  }

  static showCheckTopSnackBar(BuildContext context, String text) {
    return showTopSnackBar(
        Overlay.of(context),
        CustomSnackBar.error(
          message: text.isNotEmpty ? text : "Error occurred",
        ),
        animationDuration: const Duration(milliseconds: 700),
        reverseAnimationDuration: const Duration(milliseconds: 700),
        displayDuration: const Duration(milliseconds: 700));
  }

  static showCheckTopSnackBarInfo(BuildContext context, String text,
      {VoidCallback? onTap}) {
    return showTopSnackBar(
        Overlay.of(context),
        CustomSnackBar.info(
          message: text,
        ),
        animationDuration: const Duration(milliseconds: 700),
        reverseAnimationDuration: const Duration(milliseconds: 700),
        displayDuration: const Duration(milliseconds: 700),
        onTap: onTap);
  }

  static showCheckTopSnackBarDone(BuildContext context, String text) {
    return showTopSnackBar(
        Overlay.of(context),
        CustomSnackBar.success(
          message: text,
        ),
        animationDuration: const Duration(milliseconds: 700),
        reverseAnimationDuration: const Duration(milliseconds: 700),
        displayDuration: const Duration(milliseconds: 700));
  }

  static showCheckTopSnackBarInfoCustom(BuildContext context, String text,
      {VoidCallback? onTap}) {
    return showTopSnackBar(
        Overlay.of(context),
        CustomSnackBar.info(
          message: text,
          icon: const SizedBox.shrink(),
          backgroundColor: AppStyle.brandGreen,
          textStyle: AppStyle.interNormal(),
        ),
        animationDuration: const Duration(milliseconds: 700),
        reverseAnimationDuration: const Duration(milliseconds: 700),
        displayDuration: const Duration(milliseconds: 700),
        onTap: onTap);
  }

  static double getOrderStatusProgress(String? status) {
    switch (status) {
      case 'new':
        return 0.2;
      case 'accepted':
        return 0.4;
      case 'ready':
        return 0.6;
      case 'on_a_way':
        return 0.8;
      case 'delivered':
        return 1;
      default:
        return 0.4;
    }
  }

  static String? getAppName() {
    final List<SettingsData> settings = LocalStorage.getSettingsList();
    for (final setting in settings) {
      if (setting.key == 'title') {
        return setting.value;
      }
    }
    return '';
  }

  static String? getAppLogo() {
    final List<SettingsData> settings = LocalStorage.getSettingsList();
    for (final setting in settings) {
      if (setting.key == 'logo') {
        return setting.value;
      }
    }
    return '';
  }

  static int getType() {
    if (AppConstants.isDemo) {
      return LocalStorage.getUiType() ?? 3;
    }
    final List<SettingsData> settings = LocalStorage.getSettingsList();
    for (final setting in settings) {
      if (setting.key == 'ui_type') {
        return (int.tryParse(setting.value ?? "1") ?? 1) - 1;
      }
    }
    return 3;
  }

  static bool getGroupOrder() {
    final List<SettingsData> settings = LocalStorage.getSettingsList();
    for (final setting in settings) {
      if (setting.key == 'group_order') {
        return setting.value == "1";
      }
    }
    return true;
  }

  static bool getParcel() {
    final List<SettingsData> settings = LocalStorage.getSettingsList();
    for (final setting in settings) {
      if (setting.key == 'active_parcel') {
        return setting.value == "0";
      }
    }
    return false;
  }

  static bool getReferralActive() {
    final List<SettingsData> settings = LocalStorage.getSettingsList();
    for (final setting in settings) {
      if (setting.key == 'referral_active') {
        return setting.value == "1";
      }
    }
    return false;
  }

  static String? getAppPhone() {
    final List<SettingsData> settings = LocalStorage.getSettingsList();
    for (final setting in settings) {
      if (setting.key == 'phone') {
        return setting.value;
      }
    }
    return '';
  }

  static String? getPaymentType() {
    final List<SettingsData> settings = LocalStorage.getSettingsList();
    for (final setting in settings) {
      if (setting.key == 'payment_type') {
        return setting.value;
      }
    }
    return 'admin';
  }

  static bool getPhoneRequired() {
    final List<SettingsData> settings = LocalStorage.getSettingsList();
    for (final setting in settings) {
      if (setting.key == 'before_order_phone_required') {
        return setting.value == "1";
      }
    }
    return false;
  }

  static bool getReservationEnable() {
    final List<SettingsData> settings = LocalStorage.getSettingsList();
    for (final setting in settings) {
      if (setting.key == 'reservation_enable_for_user') {
        return setting.value == "1";
      }
    }
    return false;
  }

  static String? getAppAddressName() {
    final List<SettingsData> settings = LocalStorage.getSettingsList();
    for (final setting in settings) {
      if (setting.key == 'address') {
        return setting.value;
      }
    }
    return '';
  }

  static String getTranslation(String trKey) {
    final Map<String, dynamic> translations = LocalStorage.getTranslations();
    return translations[trKey] ??
        (trKey.isNotEmpty
            ? trKey.replaceAll(".", " ").replaceAll("_", " ").replaceFirst(
            trKey.substring(0, 1), trKey.substring(0, 1).toUpperCase())
            : '');
  }

  static String getTranslationReverse(String trKey) {
    final Map<String, dynamic> translations = LocalStorage.getTranslations();
    for (int i = 0; i < translations.values.length; i++) {
      if (trKey == translations.values.elementAt(i)) {
        return translations.keys.elementAt(i);
      }
    }
    return trKey;
  }

  static bool checkIsSvg(String? url) {
    if (url == null || (url.length) < 3) {
      return false;
    }
    final length = url.length;
    return url.substring(length - 3, length) == 'svg';
  }

  static double? getInitialLatitude() {
    final List<SettingsData> settings = LocalStorage.getSettingsList();
    for (final setting in settings) {
      if (setting.key == 'location') {
        final String? latString =
            setting.value?.substring(0, setting.value?.indexOf(','));
        if (latString == null) {
          return null;
        }
        final double? lat = double.tryParse(latString);
        return lat;
      }
    }
    return null;
  }

  static double? getInitialLongitude() {
    final List<SettingsData> settings = LocalStorage.getSettingsList();
    for (final setting in settings) {
      if (setting.key == 'location') {
        final String? latString =
            setting.value?.substring(0, setting.value?.indexOf(','));
        if (latString == null) {
          return null;
        }
        final String? lonString = setting.value
            ?.substring((latString.length) + 2, setting.value?.length);
        if (lonString == null) {
          return null;
        }
        final double? lon = double.tryParse(lonString);
        return lon;
      }
    }
    return null;
  }

  static void showCustomModalBottomSheet({
    required BuildContext context,
    required Widget modal,
    required bool isDarkMode,
    double radius = 16,
    bool isDrag = true,
    bool isDismissible = true,
    double paddingTop = 200,
  }) {
    showModalBottomSheet(
      isDismissible: isDismissible,
      enableDrag: isDrag,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(radius.r),
          topRight: Radius.circular(radius.r),
        ),
      ),
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height - paddingTop.r,
      ),
      backgroundColor: AppStyle.transparent,
      context: context,
      builder: (context) => modal,
    );
  }

  static void showCustomModalBottomDragSheet({
    required BuildContext context,
    required Function(ScrollController controller) modal,
    bool isDarkMode = false,
    double radius = 16,
    bool isDrag = true,
    bool isDismissible = true,
    double paddingTop = 100,
    double maxChildSize = 0.9,
  }) {
    showModalBottomSheet(
      isDismissible: isDismissible,
      enableDrag: isDrag,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(radius.r),
          topRight: Radius.circular(radius.r),
        ),
      ),
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height - paddingTop.r,
      ),
      backgroundColor: AppStyle.transparent,
      context: context,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: maxChildSize,
        maxChildSize: maxChildSize,
        expand: false,
        builder: (BuildContext context, ScrollController scrollController) {
          return modal(scrollController);
        },
      ),
    );
  }

  static void showAlertDialog({
    required BuildContext context,
    required Widget child,
    double radius = 16,
  }) {
    AlertDialog alert = AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(radius.r),
        ),
      ),
      contentPadding: EdgeInsets.all(20.r),
      iconPadding: EdgeInsets.zero,
      content: child,
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}

extension TimeOfDayExtension on TimeOfDay {
  TimeOfDay plusMinutes({required int minute}) {
    if (minute == 0) {
      return this;
    } else {
      int mofd = hour * 60 + minute;
      int newMofd = ((minute % 1440) + mofd + 1440) % 1440;
      if (mofd == newMofd) {
        return this;
      } else {
        int newHour = newMofd ~/ 60;
        int newMinute = newMofd % 60;
        return TimeOfDay(hour: newHour, minute: newMinute);
      }
    }
  }
}

extension ExtendedIterable<E> on Iterable<E> {
  Iterable mapIndexed<T>(T Function(E e, int i) f) {
    var i = 0;
    return map((e) => f(e, i++));
  }
}