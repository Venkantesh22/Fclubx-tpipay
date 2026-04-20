import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frezka/screens/branch/view/select_branch_screen.dart';
import 'package:frezka/components/no_internet_screen.dart';
import 'package:frezka/screens/dashboard/view/dashboard_screen.dart';
import 'package:frezka/services/network_service.dart';
import 'package:frezka/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';

import '../components/no_branch_error_widget.dart';
import '../locale/app_localizations.dart';
import '../main.dart';
import '../network/rest_apis.dart';
import '../utils/constants.dart';
import 'branch/branch_repository.dart';
import 'walkThrough/view/walk_through_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final NetworkService _networkService = NetworkService();

  @override
  void initState() {
    init();
    super.initState();

    // Listen for connectivity changes
    _networkService.isConnected.addListener(_onConnectivityChanged);
  }

  @override
  void dispose() {
    _networkService.isConnected.removeListener(_onConnectivityChanged);
    super.dispose();
  }

  void _onConnectivityChanged() {
    if (_networkService.isConnected.value) {
      // Internet is back, retry initialization
      init();
    }
  }

  void init() async {
    // Check if internet is available before making API calls
    if (!_networkService.isConnected.value) {
      // If no internet, show no internet screen
      push(NoInternetScreen(
        onRetry: () {
          init(); // Retry when internet is back
        },
      ), isNewTask: true);
      return;
    }
    afterBuildCreated(() {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        systemNavigationBarColor: context.primaryColor,
        systemNavigationBarDividerColor: Colors.transparent,
      ));
    });

    await getBranchList(branchList: []).then((value) {
      if (value.isNotEmpty) {
        if (value.length == 1) {
          setBranchAndRedirectToDashboard(value.first);
        } else {
          bool isIdAvailable = value.any((element) =>
              element.id.toString() == appStore.branchId.toString());
          if (!isIdAvailable && appStore.branchId != UNSELECTED_BRANCH_ID) {
            appStore.setBranchId(UNSELECTED_BRANCH_ID);
          }
        }
      }
    }).catchError((e) {
      /// When error occurs in Branch List API
      push(NoBranchErrorWidget(errorMessage: e.toString()),
          isNewTask: true, pageRouteAnimation: PageRouteAnimation.Fade);
    });

    int themeModeIndex = getIntAsync(THEME_MODE_INDEX);
    if (themeModeIndex == ThemeConst.THEME_MODE_LIGHT) {
      appStore.setDarkMode(false);
    } else if (themeModeIndex == ThemeConst.THEME_MODE_DARK) {
      appStore.setDarkMode(true);
    }

    bool isFirstTime =
        getBoolAsync(SharedPreferenceConst.IS_FIRST_TIME, defaultValue: true);

    ///Set app configurations
    getAppConfigurations().then((value) async {
      final String? adminLang =
          appConfigurationResponseCached?.applicationLanguage;
      if (adminLang != null && adminLang.isNotEmpty) {
        final localeToApply = Locale(adminLang);
        final bool isSupported =
            const AppLocalizations().isSupported(localeToApply);
        if (isSupported &&
            appStore.selectedLanguageCode != adminLang &&
            isFirstTime) {
          await appStore.setLanguage(adminLang);
        }
      }

      // Check if user is unauthorized but still logged in; if so, clear preferences and cached data
      if (!appStore.isUserAuthorized && appStore.isLoggedIn) {
        // await clearData(clearBranchData: false);
        push(DashboardScreen(), isNewTask: true);
      }
    }).catchError((e) {
      log(e);
    });

    if (getBoolAsync(SharedPreferenceConst.IS_FIRST_TIME, defaultValue: true)) {
      WalkThroughScreen().launch(context, isNewTask: true);
    } else if (appStore.isBranchSelected) {
      DashboardScreen().launch(context, isNewTask: true);
    } else {
      SelectBranchScreen(isFromDashboard: true)
          .launch(context, isNewTask: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: context.primaryColor,
        height: context.height(),
        width: context.width(),
        child: Container(
          decoration: boxDecorationDefault(shape: BoxShape.circle),
          child: Container(
            height: 120,
            width: 120,
            decoration: BoxDecoration(
              border: Border.all(width: 2, color: white),
              shape: BoxShape.circle,
              image: DecorationImage(
                image: AssetImage(app_logo), // ✅ correct
                fit: BoxFit.cover,
              ),
            ),
          ),
        ).center(),
      ),
    );
  }
}
