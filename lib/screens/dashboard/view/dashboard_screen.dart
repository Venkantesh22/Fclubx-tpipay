import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frezka/screens/auth/view/sign_in_screen.dart';
import 'package:frezka/utils/colors.dart';
import 'package:frezka/utils/extensions/string_extensions.dart';
import 'package:frezka/utils/images.dart';
import 'package:frezka/utils/notification_service.dart' show onNotificationTap;
import 'package:nb_utils/nb_utils.dart';
import 'package:playx_version_update/playx_version_update.dart';

import '../../../components/cached_image_widget.dart';
import '../../../components/new_update_dialogue.dart';
import '../../../components/voice_search_component.dart';
import '../../../main.dart';
import '../../../utils/common_base.dart';
import '../../../utils/constants.dart';
import '../../branch/view/select_branch_screen.dart';
import '../../order/view/order_list_screen.dart';
import '../../product/view/product_dashboard_screen.dart';
import '../fragment/booking_fragment.dart';
import '../fragment/home_fragment.dart';
import '../fragment/profile_fragment.dart';

class DashboardScreen extends StatefulWidget {
  final int pageIndex;

  const DashboardScreen({super.key, this.pageIndex = 0});

  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> with WidgetsBindingObserver {
  int currentPosition = 0;

  List<Widget> fragmentList = [
    HomeFragment(),
    Observer(builder: (context) => appStore.isLoggedIn ? BookingFragment() : SignInScreen(isFromDashboard: true)),
    ProductScreen(),
    Observer(builder: (context) => appStore.isLoggedIn ? OrderListScreen(showBack: false) : SignInScreen(isFromDashboard: true)),
    ProfileFragment(),
  ];

  @override
  void initState() {
    currentPosition = widget.pageIndex;
    if (getIntAsync(THEME_MODE_INDEX) == ThemeConst.THEME_MODE_SYSTEM) {
      WidgetsBinding.instance.addObserver(this);
    }
    super.initState();
    init();
  }

  void init() async {
    notificationTap();
    afterBuildCreated(() async {
      /// Changes System theme when changed
      if (getIntAsync(THEME_MODE_INDEX) == ThemeConst.THEME_MODE_SYSTEM) {
        appStore.setDarkMode(context.platformBrightness() == Brightness.dark);
      }

      /*View.of(context).platformDispatcher.onPlatformBrightnessChanged = () async {
        if (getIntAsync(THEME_MODE_INDEX) == ThemeConst.THEME_MODE_SYSTEM) {
          appStore.setDarkMode(MediaQuery.of(context).platformBrightness == Brightness.light);
        }
      };*/

      //WidgetsBinding.instance.handlePlatformBrightnessChanged();
    });

    /// ForceUpdate Dialog
    await 3.seconds.delay;
    showForceUpdateDialog(context);
    await _checkAndShowDialog(context, true);

    if (!appStore.isBranchSelected) {
      SelectBranchScreen().launch(context, isNewTask: true);
    }
  }

  void notificationTap() async {
    if(isNotificationRead) return;
    isNotificationRead = true;
    final notification = await FirebaseMessaging.instance.getInitialMessage();
    if (notification != null) {
      onNotificationTap(notification.data);
      return;
    }
    final localNotification = await FlutterLocalNotificationsPlugin().getNotificationAppLaunchDetails();
    if(localNotification == null) return;
    if(!localNotification.didNotificationLaunchApp) return;
    if(localNotification.notificationResponse == null) return;
    if(localNotification.notificationResponse!.payload == null) return;
    onNotificationTap(jsonDecode(localNotification.notificationResponse?.payload ?? '{}'));
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  Future<void> _checkAndShowDialog(BuildContext context, bool isAutoUpdateOn) async {
    if (!isAutoUpdateOn) return;

    if (appConfigurationResponseCached == null) {
      debugPrint("appConfigurationResponseCached is null — skipping update check.");
      return;
    }

    if (!mounted) return;

    final result = await PlayxVersionUpdate.checkVersion(
      options: PlayxUpdateOptions(
        androidPackageName: PackageInfoData().packageName,
        iosBundleId: PackageInfoData().packageName,
        minVersion: appConfigurationResponseCached!.versionCode?.toString(),
        forceUpdate: appConfigurationResponseCached!.isForceUpdate.validate().getBoolInt(),
      ),
    );

    result.when(
      success: (info) {
        if (!info.canUpdate) return;

        if (!mounted) return;

        showDialog(
          context: context,
          builder: (dialogContext) => NewUpdateDialog(
            version: info.newVersion,
            updates: [info.releaseNotes.toString()],
            onUpdate: () {
              if (mounted) Navigator.pop(dialogContext);
              PlayxVersionUpdate.openStore(
                storeUrl: 'https://play.google.com/store/apps/details?id=com.frezka.customer&hl=en_IN',
              );
            },
            onCancel: () {
              if (mounted) Navigator.pop(dialogContext);
            },
          ),
        );
      },
      error: (error) {
        debugPrint('Error checking for update: ${error.message}');
      },
    );
  }

  @override
  void didChangePlatformBrightness() {
    if (getIntAsync(THEME_MODE_INDEX) == ThemeConst.THEME_MODE_SYSTEM) {
      appStore.setDarkMode(MediaQuery.of(context).platformBrightness == Brightness.light);
    }
    super.didChangePlatformBrightness();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DoublePressBackWidget(
      message: locale.pressBackAgainToExitApp,
      child: Scaffold(
        bottomNavigationBar: Blur(
          blur: 30,
          borderRadius: radius(0),
          child: NavigationBarTheme(
            data: NavigationBarThemeData(
              backgroundColor: context.primaryColor.withValues(alpha: 0.02),
              indicatorColor: context.primaryColor.withValues(alpha: 0.1),
              labelTextStyle: WidgetStateProperty.all(primaryTextStyle(size: 12)),
              surfaceTintColor: Colors.transparent,
              shadowColor: Colors.transparent,
            ),
            child: NavigationBar(
              selectedIndex: currentPosition,
              onDestinationSelected: (index) {
                currentPosition = index;
                setState(() {});
              },
              destinations: [
                bottomTab(
                  iconData: ic_unselected_home.iconImage(color: appTextSecondaryColor, size: 18),
                  activeIconData: ic_selected_home.iconImage(color: context.primaryColor, size: 18),
                  tabName: locale.home,
                ),
                bottomTab(
                  iconData: ic_unselected_booking.iconImage(color: appTextSecondaryColor, size: 18),
                  activeIconData: ic_selected_booking.iconImage(color: context.primaryColor, size: 18),
                  tabName: locale.booking,
                ),
                bottomTab(
                  iconData: ic_unselected_shop.iconImage(color: appTextSecondaryColor, size: 20),
                  activeIconData: ic_selected_shop.iconImage(color: context.primaryColor, size: 20),
                  tabName: locale.shop,
                ),
                bottomTab(
                  iconData: ic_order.iconImage(color: appTextSecondaryColor, size: 20),
                  activeIconData: ic_selected_order.iconImage(color: context.primaryColor, size: 20),
                  tabName: locale.orders,
                ),
                Observer(builder: (context) {
                  return bottomTab(
                    iconData: appStore.isLoggedIn
                        ? CachedImageWidget(
                            url: userStore.userProfileImage.validate(),
                            height: 26,
                            fit: BoxFit.cover,
                            width: 26,
                            radius: 30,
                            child: ic_unselected_profile.iconImage(color: appTextSecondaryColor, size: 18),
                          )
                        : ic_unselected_profile.iconImage(color: appTextSecondaryColor, size: 18),
                    activeIconData: appStore.isLoggedIn
                        ? CachedImageWidget(
                            url: userStore.userProfileImage.validate(),
                            height: 26,
                            fit: BoxFit.cover,
                            width: 26,
                            radius: 30,
                            child: ic_selected_profile.iconImage(color: context.primaryColor, size: 18),
                          )
                        : ic_selected_profile.iconImage(color: context.primaryColor, size: 18),
                    tabName: locale.profile,
                  );
                }),
              ],
            ),
          ),
        ),
        // Voice search animation - centered overlay
        body: Stack(
          children: [
            fragmentList[currentPosition],
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
          ],
        ),
      ),
    );
  }
}
