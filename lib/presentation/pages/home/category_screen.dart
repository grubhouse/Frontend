import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:riverpodtemp/application/home/home_notifier.dart';
import 'package:riverpodtemp/application/home/home_state.dart';
import 'package:riverpodtemp/presentation/routes/app_router.dart';

import 'shimmer/category_shimmer.dart';
import 'widgets/tab_bar_item.dart';

class CategoryScreen extends StatelessWidget {
  final HomeState state;
  final HomeNotifier event;
  final RefreshController categoryController;
  final RefreshController restaurantController;

  const CategoryScreen({
    super.key,
    required this.state,
    required this.event,
    required this.categoryController,
    required this.restaurantController,
  });

  @override
  Widget build(BuildContext context) {
    return state.isCategoryLoading
        ? const CategoryShimmer()
        : Container(
            height: state.categories.isNotEmpty ? 90.h : 0,
            margin: EdgeInsets.only(
                bottom: state.categories.isNotEmpty ? 26.h : 0, right: 16.r),
            child: SmartRefresher(
              scrollDirection: Axis.horizontal,
              enablePullDown: false,
              footer: ClassicFooter(
                idleIcon: const SizedBox(),
                idleText: "",
                height: 120.w,
              ),
              enablePullUp: true,
              controller: categoryController,
              onLoading: () async {
                await event.fetchCategoriesPage(context, categoryController);
              },
              child: AnimationLimiter(
                child: ListView.builder(
                  padding: EdgeInsets.only(left: 16.r),
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemCount:
                      state.isCategoryLoading ? 5 : state.categories.length,
                  itemBuilder: (context, index) {
                    return Row(
                      children: [
                        AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: 375),
                          child: SlideAnimation(
                            verticalOffset: 50.0,
                            child: FadeInAnimation(
                                child: CategoryBarItem(
                              index: index,
                              image: state.categories[index].img ?? "",
                              title:
                                  state.categories[index].translation?.title ??
                                      "",
                              isActive: state.selectIndexCategory == index,
                              onTap: () {
                                event.setSelectCategory(index, context);
                                restaurantController.resetNoData();
                                context.pushRoute(
                                    ServiceTwoCategoryRoute(index: index));
                              },
                            )),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          );
  }
}
