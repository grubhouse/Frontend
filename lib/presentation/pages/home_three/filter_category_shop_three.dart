import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:riverpodtemp/application/home/home_notifier.dart';
import 'package:riverpodtemp/application/home/home_state.dart';
import 'package:riverpodtemp/infrastructure/services/app_helpers.dart';
import 'package:riverpodtemp/infrastructure/services/tr_keys.dart';
import 'package:riverpodtemp/presentation/components/buttons/animation_button_effect.dart';
import 'package:riverpodtemp/presentation/components/loading.dart';
import 'package:riverpodtemp/presentation/components/title_icon.dart';
import 'package:riverpodtemp/presentation/pages/home/filter/filter_page.dart';
import 'package:riverpodtemp/presentation/pages/home_three/widgets/market_three_item.dart';

import '../../theme/app_style.dart';
import 'shimmer/news_shop_shimmer.dart';
import 'widgets/tab_bar_item_three.dart';

class FilterCategoryShopThree extends StatefulWidget {
  final HomeState state;
  final HomeNotifier event;
  final RefreshController shopController;
  final Function onClear;

  const FilterCategoryShopThree(
      {super.key,
      required this.state,
      required this.event,
      required this.shopController,
      required this.onClear});

  @override
  State<FilterCategoryShopThree> createState() =>
      _FilterCategoryShopThreeState();
}

class _FilterCategoryShopThreeState extends State<FilterCategoryShopThree> {
  @override
  Widget build(BuildContext context) {
    debugPrint('===> build FilterCategoryShopThree');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(
              height: 46.r,
              child: ListView.builder(
                padding: EdgeInsets.only(bottom: 8.r, left: 16.r),
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                itemCount: (widget
                            .state
                            .categories[widget.state.selectIndexCategory]
                            .children
                            ?.length ??
                        0) +
                    1,
                itemBuilder: (BuildContext context, int index) {
                  final category =
                      widget.state.categories[widget.state.selectIndexCategory];
                  return index == 0
                      ? AnimationButtonEffect(
                          child: InkWell(
                            onTap: () {
                              AppHelpers.showCustomModalBottomDragSheet(
                                context: context,
                                modal: (c) => FilterPage(
                                  controller: c,
                                  categoryId:
                                      (widget.state.selectIndexSubCategory != -1
                                              ? (widget
                                                  .state
                                                  .categories[
                                                      widget.state
                                                          .selectIndexCategory]
                                                  .children?[widget.state
                                                      .selectIndexSubCategory]
                                                  .id)
                                              : widget
                                                  .state
                                                  .categories[widget.state
                                                      .selectIndexCategory]
                                                  .id) ??
                                          0,
                                ),
                                isDarkMode: false,
                                isDrag: false,
                                radius: 12,
                              );
                            },
                            child: Container(
                              margin: EdgeInsets.only(right: 8.r),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16.r, vertical: 6.r),
                              decoration: BoxDecoration(
                                color: AppStyle.bgGrey,
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Row(
                                children: [
                                  SvgPicture.asset("assets/svgs/filter.svg"),
                                  6.horizontalSpace,
                                  Text(
                                    AppHelpers.getTranslation(TrKeys.filter),
                                    style: AppStyle.interNormal(
                                      size: 13,
                                      color: AppStyle.black,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        )
                      : TabBarItemThree(
                          isShopTabBar:
                              index - 1 == widget.state.selectIndexSubCategory,
                          title: category
                                  .children?[index - 1].translation?.title ??
                              "",
                          index: index - 1,
                          currentIndex: widget.state.selectIndexSubCategory,
                          onTap: () => widget.event
                              .setSelectSubCategory(index - 1, context),
                        );
                },
              ),
            ),
            Container(
              height: 46.r,
              padding: EdgeInsets.only(bottom: 8.r, left: 16.r),
              child: TabBarItemThree(
                  isShopTabBar: false,
                  title: "Clear",
                  index: 0,
                  currentIndex: widget.state.selectIndexSubCategory,
                  onTap: () {
                    widget.onClear();
                    // widget.state.copyWith(selectIndexCategory:  -1);
                  }),
            ),
          ],
        ),
        widget.state.isSelectCategoryLoading == -1
            ? const Loading()
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  widget.state.isShopLoading
                      ? NewsShopShimmer(
                          title: AppHelpers.getTranslation(TrKeys.shops),
                        )
                      : widget.state.filterMarket.isNotEmpty
                          ? Column(
                              children: [
                                TitleAndIcon(
                                  title:
                                      AppHelpers.getTranslation(TrKeys.shops),
                                  rightTitle:
                                      "${AppHelpers.getTranslation(TrKeys.found)} ${widget.state.totalShops} ${AppHelpers.getTranslation(TrKeys.results)}",
                                ),
                                12.verticalSpace,
                                SizedBox(
                                    height: 246.h,
                                    child: SmartRefresher(
                                      scrollDirection: Axis.horizontal,
                                      footer: ClassicFooter(
                                        idleIcon: const SizedBox(),
                                        idleText: "",
                                        height: 120.w,
                                      ),
                                      controller: widget.shopController,
                                      enablePullDown: false,
                                      enablePullUp: true,
                                      onLoading: () async {},
                                      child: ListView.builder(
                                        padding: EdgeInsets.only(left: 16.r),
                                        shrinkWrap: false,
                                        scrollDirection: Axis.horizontal,
                                        itemCount:
                                            widget.state.filterMarket.length,
                                        itemBuilder: (context, index) =>
                                            MarketThreeItem(
                                          shop:
                                              widget.state.filterMarket[index],
                                        ),
                                      ),
                                    )),
                                16.verticalSpace,
                              ],
                            )
                          : const SizedBox.shrink(),
                  TitleAndIcon(
                    title: AppHelpers.getTranslation(TrKeys.restaurants),
                    rightTitle:
                        "${AppHelpers.getTranslation(TrKeys.found)} ${widget.state.filterShops.length.toString()} ${AppHelpers.getTranslation(TrKeys.results)}",
                  ),
                  widget.state.filterShops.isNotEmpty
                      ? ListView.builder(
                          padding: EdgeInsets.only(top: 6.h),
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          scrollDirection: Axis.vertical,
                          itemCount: widget.state.filterShops.length,
                          itemBuilder: (context, index) => MarketThreeItem(
                            shop: widget.state.filterShops[index],
                            isSimpleShop: true,
                          ),
                        )
                      : Padding(
                          padding: EdgeInsets.only(top: 24.h),
                          child: Center(child: _resultEmpty()),
                        ),
                ],
              ),
      ],
    );
  }
}

Widget _resultEmpty() {
  return Column(
    children: [
      Image.asset("assets/images/notFound.png"),
      Text(
        AppHelpers.getTranslation(TrKeys.nothingFound),
        style: AppStyle.interSemi(size: 18.sp),
      ),
      Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 32.w,
        ),
        child: Text(
          AppHelpers.getTranslation(TrKeys.trySearchingAgain),
          style: AppStyle.interRegular(size: 14.sp),
          textAlign: TextAlign.center,
        ),
      ),
    ],
  );
}
