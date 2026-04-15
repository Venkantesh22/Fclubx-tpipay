import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frezka/components/app_scaffold.dart';
import 'package:frezka/components/loader_widget.dart';
import 'package:frezka/components/slider_component.dart';
import 'package:frezka/utils/app_common.dart';
import 'package:frezka/utils/colors.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../components/empty_error_state_widget.dart';
import '../../../main.dart';
import '../branch_repository.dart';
import '../component/branch_about_component.dart';
import '../component/branch_gallery_component.dart';
import '../component/branch_review_component.dart';
import '../component/branch_service_component.dart';
import '../component/branch_staff_component.dart';
import '../model/branch_detail_response.dart';
import '../shimmer/branch_detail_shimmer.dart';

class BranchDetailScreen extends StatefulWidget {
  final int branchId;

  BranchDetailScreen({required this.branchId});

  @override
  _BranchDetailScreenState createState() => _BranchDetailScreenState();
}

class _BranchDetailScreenState extends State<BranchDetailScreen> with TickerProviderStateMixin {
  Future<BranchDetailResponse>? future;

  List<String> sectionList = [locale.about, locale.services, locale.reviews, locale.staff, locale.gallery];

  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    init();
    setStatusBarColor(Colors.transparent);
  }

  void init() async {
    /// Branch Detail Api
    future = getBranchDetail(widget.branchId);
  }

  BranchDetailResponse? getBranchInitialData() {
    if (branchDetailCachedData.any((element) => element.data?.id == widget.branchId)) {
      return BranchDetailResponse(data: branchDetailCachedData.firstWhere((element) => element.data?.id == widget.branchId).data);
    } else {
      return null;
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    dashboardResponseCached = null;
    branchReviewListResponseCached = null;
    branchStaffListResponseCached = null;
    branchGalleryListResponseCached = null;
    branchServiceListResponseCached = null;
    bookingDetailCached = [];
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      showAppBar: true,
      appBarWidget: commonAppBarWidget(
        context,
        title: locale.salonDetail,
        appBarHeight: 70,
        showLeadingIcon: true,
        roundCornerShape: true,
      ),
      body: Stack(
        children: [
          SnapHelperWidget<BranchDetailResponse>(
            future: future,
            initialData: getBranchInitialData(),
            loadingWidget: BranchDetailShimmer(),
            onSuccess: (snap) {
              if (snap.data == null) {
                return NoDataWidget(
                  title: locale.noDetailsFound,
                  retryText: locale.reload,
                  onRetry: () {
                    appStore.setLoading(true);

                    init();
                    setState(() {});
                  },
                );
              }

              return SingleChildScrollView(
                child: Column(
                  children: [
                    // Image slider section
                    SliderComponent(branchData: snap),
                    Divider(color: context.dividerColor, height: 0),

                    // Tab navigation
                    DefaultTabController(
                      length: sectionList.length,
                      initialIndex: selectedIndex,
                      child: Column(
                        children: [
                          HorizontalList(
                            padding: EdgeInsets.only(left: 16, right: 16, top: 32, bottom: 0),
                            itemCount: sectionList.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  selectedIndex = index;
                                  setState(() {});
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 7),
                                  decoration: boxDecorationWithRoundedCorners(
                                    backgroundColor: index == selectedIndex ? appStore.isDarkMode ? transparentColor: primaryLightColor : context.cardColor,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: index == selectedIndex ? context.primaryColor : borderColor, width: 1),
                                  ),
                                  child: Text(sectionList[index], style: boldTextStyle(color: index == selectedIndex ? context.primaryColor : textPrimaryColorGlobal, size: 14)).center(),
                                ),
                              );
                            },
                          ),

                          // Content based on selected tab
                          Container(
                            key: ValueKey(selectedIndex),
                            child: () {
                              if (selectedIndex == 0) {
                                return BranchAboutComponent(branchDescription: snap.data!.description.validate(), workingList: snap.data!.workingHourList.validate());
                              } else if (selectedIndex == 1) {
                                return BranchServiceComponent(
                                  branchId: widget.branchId,
                                );
                              } else if (selectedIndex == 2) {
                                return BranchReviewComponent(branchId: widget.branchId, branchTotalReview: snap.data!.totalReview.validate());
                              } else if (selectedIndex == 3) {
                                return BranchStaffComponent(branchId: widget.branchId);
                              } else if (selectedIndex == 4) {
                                return BranchGalleryComponent(branchId: widget.branchId);
                              } else {
                                return Offstage();
                              }
                            }(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
            errorBuilder: (error) {
              return NoDataWidget(
                title: error,
                retryText: locale.reload,
                imageWidget: ErrorStateWidget(),
                onRetry: () {
                  appStore.setLoading(true);

                  init();
                  setState(() {});
                },
              );
            },
          ),
          Observer(builder: (context) => LoaderWidget().visible(appStore.isLoading)),
        ],
      ),
    );
  }
}
