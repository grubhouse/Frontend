import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:riverpodtemp/presentation/theme/theme.dart';

class OrderContainer extends StatelessWidget {
  final Widget icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const OrderContainer(
      {super.key,
      required this.icon,
      required this.title,
      required this.description,
        required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
            color: AppStyle.bgGrey,
            borderRadius: BorderRadius.all(Radius.circular(10.r))),
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
        child: Row(
          children: [
            icon,
            14.horizontalSpace,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppStyle.interNormal(
                    size: 12,
                    color: AppStyle.textGrey,
                  ),
                ),
                SizedBox(
                  width: MediaQuery.sizeOf(context).width-164.w,
                  child: Text(
                    description,
                    style: AppStyle.interBold(
                      size: 14,
                      color: AppStyle.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const Spacer(),
            const Icon(Icons.keyboard_arrow_right)
          ],
        ),
      ),
    );
  }
}
