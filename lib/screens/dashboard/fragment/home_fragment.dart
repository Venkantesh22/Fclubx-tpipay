import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frezka/components/app_scaffold.dart';
import 'package:frezka/components/loader_widget.dart';
import 'package:frezka/network/rest_apis.dart';
import 'package:frezka/screens/booking/component/quick_book_component.dart';
import 'package:frezka/screens/dashboard/component/category_component.dart';
import 'package:frezka/screens/dashboard/component/common_app_component.dart';
import 'package:frezka/screens/dashboard/component/dashboard_appbar_component.dart';
import 'package:frezka/screens/dashboard/component/horizontal_slider_component.dart';
import 'package:frezka/screens/dashboard/component/near_you_component.dart';
// import 'package:frezka/screens/dashboard/component/package_list_component.dart'; // HIDDEN
import 'package:frezka/screens/dashboard/component/top_experts_component.dart';
import 'package:frezka/screens/dashboard/component/upcoming_service_component.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../components/empty_error_state_widget.dart';
import '../../../main.dart';
import '../../../services/network_service.dart';
import '../../services/view/view_all_service_screen.dart';
// import '../component/expire_soon_component.dart'; // HIDDEN
import '../dashboard_repository.dart';
import '../models/dashboard_model.dart';
import '../shimmer/dashboard_shimmer.dart';

class HomeFragment extends StatefulWidget {
  @override
  _HomeFragmentState createState() => _HomeFragmentState();
}

class _HomeFragmentState extends State<HomeFragment> {
  UniqueKey keyForBranchList = UniqueKey();
  UniqueKey keyForQuickBooking = UniqueKey();
  Future<DashboardResponse>? future;
  final NetworkService _networkService = NetworkService();

  @override
  void initState() {
    super.initState();
    init();
    afterBuildCreated(() {
      setStatusBarColor(context.primaryColor);
    });

    // Listen for network connectivity changes
    _networkService.isConnected.addListener(_onConnectivityChanged);
  }

  @override
  void dispose() {
    _networkService.isConnected.removeListener(_onConnectivityChanged);
    super.dispose();
  }

  void _onConnectivityChanged() {
    if (_networkService.isConnected.value) {
      keyForBranchList = UniqueKey();
      keyForQuickBooking = UniqueKey();
      init(); // init now handles setState
    }
  }

  void init() {
    // Check if internet is available before making API calls
    if (!_networkService.isConnected.value) return;

    setState(() {
      future = userDashboard(branchId: appStore.branchId, perPage: 15);
    });

    if (appConfigurationResponseCached == null) {
      getAppConfigurations().then((value) async { }).catchError((e) {
        log('Error in getAppConfigurations: $e');
      });
    }
  }

  Future<void> refreshAppConfiguration() async {
    try {
      await refreshConfigurationData(branchId: appStore.branchId);
      setState(() {
        future = userDashboard(branchId: appStore.branchId, perPage: 15);
      });
    } catch (e) {
      log('Error refreshing configuration: $e');
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      showAppBar: false,
      body: Stack(
        children: [
          SnapHelperWidget<DashboardResponse>(
            future: future,
            initialData: dashboardResponseCached,
            errorBuilder: (error) {
              return NoDataWidget(
                title: error,
                retryText: locale.reload,
                imageWidget: ErrorStateWidget(),
                onRetry: () {
                  appStore.setLoading(true);
                  keyForBranchList = UniqueKey();
                  keyForQuickBooking = UniqueKey();
                  init(); // future will reset inside init
                },
              );
            },
            loadingWidget: DashboardShimmer(),
            onSuccess: (snap) {
              return CommonAppComponent(
                innerWidget: DashboardAppBarComponent(
                  hintText: locale.searchForServices,
                  onTapSearch: () {
                    hideKeyboard(context);
                    ViewAllServiceScreen(serviceTitle: locale.searchServices).launch(context);
                  },
                  onRefresh: () {
                    refreshAppConfiguration();
                  },
                ),
                mainWidgetHeight: 170,
                onSwipeRefresh: () async {
                  keyForBranchList = UniqueKey();
                  keyForQuickBooking = UniqueKey();
                  await refreshAppConfiguration();
                  return await 2.seconds.delay;
                },
                subWidget: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Horizontal
                    HorizontalSliderComponent(sliderList: snap.data!.sliderData.validate()),

                    /// Package Expiring Soon - HIDDEN
                    // if (snap.expiringPackagesList != null && snap.expiringPackagesList!.isNotEmpty) ExpiringSoonComponent(expiringPackageList: snap.expiringPackagesList),

                    /// Quick Book Appointment
                    12.height,
                    QuickBookingComponent(
                      key: keyForQuickBooking,
                      serviceListData: snap.data!.service.validate(),
                      callback: () {
                        keyForQuickBooking = UniqueKey();
                        refreshAppConfiguration();
                      },
                    ),

                    if (snap.data!.upcomingBookings != null && snap.data!.upcomingBookings!.isNotEmpty) UpcomingServiceComponent(bookingData: snap.data!.upcomingBookings!.take(1).toList()),

                    ///Category List
                    CategoryComponent(categoryList: snap.data!.category),

                    // PopularServiceComponent(popularServices: snap.data!.popularServices),

                    /// Experts
                    TopExpertsComponent(topExpertList: snap.data!.topExperts.validate()),

                    /// Near You
                    NearYouComponent(title: locale.nearbyBranches, key: keyForBranchList),
                  ],
                ).paddingOnly(top: context.statusBarHeight + 24),
              );
            },
          ),
          Observer(builder: (context) => LoaderWidget().visible(appStore.isLoading)),
        ],
      ),
    );
  }
}
