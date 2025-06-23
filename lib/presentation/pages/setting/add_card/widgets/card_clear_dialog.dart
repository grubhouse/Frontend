import 'package:flutter/material.dart';
import 'package:flutter_remix/flutter_remix.dart';
import 'package:riverpodtemp/infrastructure/services/app_helpers.dart';
import 'package:riverpodtemp/infrastructure/services/tr_keys.dart';
import 'package:riverpodtemp/presentation/theme/app_style.dart';

class CartClearDialog extends StatelessWidget {
  final VoidCallback onConfirm;

  const CartClearDialog({super.key, required this.onConfirm, required Null Function() clear, required Null Function() cancel, required bool isLoading});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      // --- Proactive UX Improvement: Added Icon ---
      icon: const Icon(FlutterRemix.error_warning_line, color: AppStyle.red, size: 48),
      // --- Text Update: New, clearer title ---
      title: Text(
        AppHelpers.getTranslation(TrKeys.areYouSureYouWantToClearYourBasket),
        textAlign: TextAlign.center,
        style: AppStyle.interNormal(size: 18),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton(
              child: Text(AppHelpers.getTranslation(TrKeys.cancel)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: Text(AppHelpers.getTranslation(TrKeys.confirm)),
              onPressed: () {
                onConfirm();
                Navigator.of(context).pop();
              },
            ),
          ],
        )
      ],
    );
  }
}