import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frezka/components/app_scaffold.dart';
import 'package:frezka/components/back_widget.dart';
import 'package:frezka/components/empty_error_state_widget.dart';
import 'package:frezka/components/loader_widget.dart';
import 'package:frezka/main.dart';
import 'package:frezka/screens/dashboard/component/common_app_component.dart';
import 'package:frezka/screens/dashboard/component/dashboard_appbar_component.dart';
import 'package:frezka/screens/dashboard/component/upcoming_service_component.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../dashboard/dashboard_repository.dart';
import '../../dashboard/models/dashboard_model.dart';

class ViewAllUpcomingBookingsScreen extends StatefulWidget {
  @override
  _ViewAllUpcomingBookingsScreenState createState() => _ViewAllUpcomingBookingsScreenState();
}

class _ViewAllUpcomingBookingsScreenState extends State<ViewAllUpcomingBookingsScreen> {
  Future<DashboardResponse>? future;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() {
    setState(() {
      future = userDashboard(branchId: appStore.branchId, perPage: 15);
    });
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
                  init();
                },
              );
            },
            loadingWidget: LoaderWidget(),
            onSuccess: (snap) {
              return CommonAppComponent(
                innerWidget: DashboardAppBarComponent(
                  hintText: locale.searchForServices,
                  onTapSearch: () {
                    hideKeyboard(context);
                  },
                  onRefresh: () {
                    init();
                  },
                  innerChild: appBarWidget(
                    locale.upcomingBooking,
                    center: true,
                    color: context.primaryColor,
                    textColor: white,
                    backWidget: BackWidget(),
                  ).cornerRadiusWithClipRRectOnly(bottomLeft: 20, bottomRight: 20).paddingTop(10),
                ),
                mainWidgetHeight: 135,
                onSwipeRefresh: () async {
                  init();
                  return await 2.seconds.delay;
                },
                subWidget: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (snap.data!.upcomingBookings != null && snap.data!.upcomingBookings!.isNotEmpty)
                      UpcomingServiceComponent(bookingData: snap.data!.upcomingBookings!.validate(), showViewAllLabel: false)
                    else
                      NoDataWidget(
                        title: locale.noUpcomingBookings,
                        imageWidget: EmptyStateWidget(),
                      ).paddingTop(50),
                  ],
                ).paddingOnly(top: 20),
              );
            },
          ),
          Observer(builder: (context) => LoaderWidget().visible(appStore.isLoading)),
        ],
      ),
    );
  }
}
