import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frezka/components/app_scaffold.dart';
import 'package:frezka/utils/common_base.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../components/cached_image_widget.dart';
import '../../../components/empty_error_state_widget.dart';
import '../../../components/loader_widget.dart';
import '../../../components/voice_search_component.dart';
import '../../../main.dart';
import '../../../utils/constants.dart';
import '../../../utils/app_common.dart';
import '../../services/view/view_all_service_screen.dart';
import '../category_repository.dart';
import '../model/category_response.dart';
import '../shimmer/category_shimmer.dart';

class CategoryScreen extends StatefulWidget {
  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  UniqueKey key = UniqueKey();

  TextEditingController searchProductCont = TextEditingController();

  FocusNode searchFocusNode = FocusNode();
  Future<List<CategoryData>>? future;
  Future<List<CategoryData>>? searchFuture;
  List<CategoryData> categoryList = [];

  int page = 1;

  bool isLastPage = false;

  @override
  void initState() {
    super.initState();
    init();
    // Rebuild when user types so the close icon visibility updates instantly
    searchProductCont.addListener(() => setState(() {}));
  }

  void init() async {
    future = getCategoryList(
      page: page,
      list: categoryList,
      isStoreCached: true,
      lastPageCallBack: (val) {
        isLastPage = val;
      },
    );
  }

  void handleSearch({bool flag = false}) async {
    searchFuture = getCategoryList(
      search: searchProductCont.text.trim(),
      page: page,
      list: [],
      lastPageCallBack: (p) {
        isLastPage = p;
      },
    ).whenComplete(() {
      if (flag) setState(() {});
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  void startListening() {
    startVoiceSearch(
      onResultCallback: (text, isFinal) {
        if (isFinal) {
          searchProductCont.text = text;
          page = 1;
          appStore.setLoading(true);
          handleSearch(flag: true);
        }
      },
      onStatusChanged: () {
        if (mounted) setState(() {});
      },
    );
  }

  void stopListening() {
    stopVoiceSearch();
  }

  @override
  void dispose() {
    searchProductCont.removeListener(() {});
    searchProductCont.dispose();
    searchFocusNode.dispose();
    stopVoiceSearch();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBarWidget: PreferredSize(
          preferredSize: Size(context.width(), 100),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              commonAppBarWidget(
                context,
                title: locale.category,
                appBarHeight: 70,
                roundCornerShape: true,
                showLeadingIcon: true,
              ),
              Positioned(
                bottom: -20,
                left: 20,
                right: 20,
                child: AppTextField(
                  textFieldType: TextFieldType.OTHER,
                  focus: searchFocusNode,
                  controller: searchProductCont,
                  suffix: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () {
                          hideKeyboard(context);
                          searchProductCont.clear();
                          setState(() {});
                        },
                        child: Icon(Icons.close, color: context.iconColor)
                      ).visible(searchProductCont.text.isNotEmpty),
                      6.width.visible(searchProductCont.text.isNotEmpty),
                      GestureDetector(
                        onTap: () {
                          startListening();
                        },
                        child: Icon(Icons.mic_none_outlined, color: context.iconColor)),
                      12.width.visible(searchProductCont.text.isNotEmpty),
                    ],
                  ),
                  onChanged: (s) {
                    page = 1;
                    appStore.setLoading(true);
                    handleSearch(flag: true);
                  },
                  decoration: inputDecoration(context, hint: locale.searchForCategory, prefixIcon: Icon(Icons.search, color: context.iconColor)),
                ),
              ),
            ],
          )),
      body: Stack(
        children: [
          // Voice search animation - centered overlay
          Observer(
            builder: (context) {
              return appStore.isSpeechActivated
                  ? Positioned.fill(
                      child: Center(
                        child: VoiceSearchComponent(),
                      ),
                    )
                  : SizedBox.shrink();
            },
          ),
          searchProductCont.text.trim().isNotEmpty
              ? SnapHelperWidget<List<CategoryData>>(
                  future: searchFuture,
                  initialData: categoryListCached,
                  loadingWidget: CategoryShimmer(),
                  onSuccess: (list) {
                    if (list.isEmpty) {
                      return NoDataWidget(
                        title: locale.noCategoryFound,
                        retryText: locale.reload,
                        onRetry: () {
                          page = 1;
                          appStore.setLoading(true);

                          init();
                          setState(() {});
                        },
                      );
                    }

                    return AnimatedScrollView(
                      onSwipeRefresh: () async {
                        page = 1;

                        init();
                        setState(() {});

                        return await 2.seconds.delay;
                      },
                      physics: AlwaysScrollableScrollPhysics(),
                      listAnimationType: ListAnimationType.Scale,
                      padding: EdgeInsets.all(16),
                      onNextPage: () {
                        if (!isLastPage) {
                          page++;
                          appStore.setLoading(true);

                          init();
                          setState(() {});
                        }
                      },
                      children: [
                        AnimatedWrap(
                          key: key,
                          runSpacing: 16,
                          spacing: 16,
                          itemCount: list.length,
                          listAnimationType: ListAnimationType.Scale,
                          scaleConfiguration: ScaleConfiguration(duration: 300.milliseconds, delay: 50.milliseconds),
                          itemBuilder: (_, index) {
                            CategoryData? data = list[index];
                            return GestureDetector(
                              onTap: () {
                                ViewAllServiceScreen(serviceTitle: data.name.validate(), categoryId: data.id.validate()).launch(context);
                              },
                              child: MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: AnimatedContainer(
                                  duration: 200.milliseconds,
                                  curve: Curves.easeInOut,
                                  width: context.width() / 3 - 22,
                                  padding: EdgeInsets.zero,
                                  decoration: boxDecorationWithRoundedCorners(
                                    backgroundColor: context.cardColor,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 6,
                                        offset: Offset(0, 3),
                                      ),
                                    ],
                                    border: Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Stack(
                                      alignment: Alignment.bottomCenter,
                                      children: [
                                        /// Background Image
                                        CachedImageWidget(
                                          url: data.categoryImage.validate(),
                                          width: context.width() / 3 - 20,
                                          height: CATEGORY_ICON_SIZE,
                                          fit: BoxFit.cover,
                                        ),

                                        /// Black shadow overlay at bottom
                                        Positioned(
                                          bottom: 0,
                                          left: 0,
                                          right: 0,
                                          child: Container(
                                            height: 50,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                                colors: [
                                                  Colors.transparent,
                                                  Colors.black.withValues(alpha: 0.8), // darker shadow
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),

                                        /// Text on top of shadow
                                        Positioned(
                                          bottom: 8,
                                          left: 0,
                                          right: 0,
                                          child: Text(
                                            data.name.validate(),
                                            style: primaryTextStyle(size: 14, color: Colors.white),
                                            textAlign: TextAlign.center,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  },
                  errorBuilder: (error) {
                    return NoDataWidget(
                      title: error,
                      retryText: locale.reload,
                      imageWidget: ErrorStateWidget(),
                      onRetry: () {
                        page = 1;
                        appStore.setLoading(true);

                        init();
                        setState(() {});
                      },
                    );
                  },
                )
              : SnapHelperWidget<List<CategoryData>>(
                  future: future,
                  initialData: categoryListCached,
                  loadingWidget: CategoryShimmer(),
                  onSuccess: (list) {
                    if (list.isEmpty) {
                      return NoDataWidget(
                        title: locale.noCategoryFound,
                        retryText: locale.reload,
                        onRetry: () {
                          page = 1;
                          appStore.setLoading(true);

                          init();
                          setState(() {});
                        },
                      );
                    }

                    return AnimatedScrollView(
                      onSwipeRefresh: () async {
                        page = 1;

                        init();
                        setState(() {});

                        return await 2.seconds.delay;
                      },
                      physics: AlwaysScrollableScrollPhysics(),
                      listAnimationType: ListAnimationType.Scale,
                      padding: EdgeInsets.all(16),
                      onNextPage: () {
                        if (!isLastPage) {
                          page++;
                          appStore.setLoading(true);

                          init();
                          setState(() {});
                        }
                      },
                      children: [
                        AnimatedWrap(
                          key: key,
                          runSpacing: 10,
                          spacing: 10,
                          itemCount: list.length,
                          listAnimationType: ListAnimationType.Scale,
                          scaleConfiguration: ScaleConfiguration(duration: 300.milliseconds, delay: 50.milliseconds),
                          itemBuilder: (_, index) {
                            CategoryData? data = list[index];
                            return GestureDetector(
                              onTap: () {
                                ViewAllServiceScreen(serviceTitle: data.name.validate(), categoryId: data.id.validate()).launch(context);
                              },
                              child: MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: AnimatedContainer(
                                  duration: 200.milliseconds,
                                  curve: Curves.easeInOut,
                                  width: context.width() / 4 - 16,
                                  padding: EdgeInsets.zero,
                                  decoration: boxDecorationWithRoundedCorners(
                                    backgroundColor: context.cardColor,
                                    borderRadius: BorderRadius.circular(4),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 6,
                                        offset: Offset(0, 3),
                                      ),
                                    ],
                                    border: Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: Stack(
                                      alignment: Alignment.bottomCenter,
                                      children: [
                                        /// Background Image
                                        CachedImageWidget(
                                          url: data.categoryImage.validate(),
                                          width: context.width() / 4 - 16,
                                          height: CATEGORY_ICON_SIZE,
                                          fit: BoxFit.cover,
                                        ),

                                        /// Black shadow overlay at bottom
                                        Positioned(
                                          bottom: 0,
                                          left: 0,
                                          right: 0,
                                          child: Container(
                                            height: 50,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                                colors: [
                                                  Colors.transparent,
                                                  Colors.black.withValues(alpha: 0.8), // darker shadow
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),

                                        /// Text on top of shadow
                                        Positioned(
                                          bottom: 8,
                                          left: 5,
                                          right: 0,
                                          child: Marquee(
                                            child: Text(
                                              data.name.validate(),
                                              style: primaryTextStyle(size: 14, color: Colors.white),
                                              textAlign: TextAlign.center,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  },
                  errorBuilder: (error) {
                    return NoDataWidget(
                      title: error,
                      retryText: locale.reload,
                      imageWidget: ErrorStateWidget(),
                      onRetry: () {
                        page = 1;
                        appStore.setLoading(true);

                        init();
                        setState(() {});
                      },
                    );
                  },
                ),
          Observer(builder: (context) => LoaderWidget().visible(appStore.isLoading)),
        ],
      ).paddingTop(30),
    );
  }
}
