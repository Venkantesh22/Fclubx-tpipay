import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frezka/locale/language_en.dart';
import 'package:frezka/screens/auth/services/apple_login_auth_service.dart';
import 'package:frezka/screens/auth/services/auth_service.dart';
import 'package:frezka/screens/auth/services/google_sign_in_auth_service.dart';
import 'package:frezka/screens/auth/services/user_service.dart';
import 'package:frezka/screens/booking/model/booking_list_response.dart';
import 'package:frezka/screens/booking/model/booking_status_response.dart';
import 'package:frezka/screens/branch/model/branch_configuration_response.dart';
import 'package:frezka/screens/branch/model/branch_detail_response.dart';
import 'package:frezka/screens/branch/model/branch_gallery_list_response.dart';
import 'package:frezka/screens/branch/model/branch_response.dart';
import 'package:frezka/screens/category/model/category_response.dart';
import 'package:frezka/screens/dashboard/models/dashboard_model.dart';
import 'package:frezka/screens/experts/model/employee_detail_response.dart';
import 'package:frezka/screens/notifications/model/notification_model.dart';
import 'package:frezka/screens/order/model/order_detail_response.dart';
import 'package:frezka/screens/order/model/order_status_response.dart';
import 'package:frezka/screens/product/model/product_dashboard_response.dart';
import 'package:frezka/screens/product/model/product_list_response.dart';
import 'package:frezka/screens/services/models/service_response.dart';
import 'package:frezka/store/booking_request_store.dart';
import 'package:frezka/store/product_store.dart';
import 'package:frezka/store/roles_and_permission_store.dart';
import 'package:frezka/utils/constants.dart';
import 'package:frezka/utils/notification_service.dart';
import 'package:mobx/mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'app_theme.dart';
import 'configs.dart';
import 'locale/app_localizations.dart';
import 'locale/languages.dart';
import 'models/bank_list_response.dart';
import 'models/configuration_response.dart';
import 'models/review_data.dart';
import 'models/user_wallet_history.dart';
import 'screens/splash_screen.dart';
import 'components/no_internet_screen.dart';
import 'store/app_store.dart';
import 'store/user_store.dart';
import 'utils/common_base.dart';
import 'services/network_service.dart';

//region APP STORE
AppStore appStore = AppStore();
UserStore userStore = UserStore();
BookingRequestStore bookingRequestStore = BookingRequestStore();
ProductStore productStore = ProductStore();
RolesAndPermissionStore rolesAndPermissionStore = RolesAndPermissionStore();
//endregion

//region FIREBASE AUTH
final FirebaseAuth auth = FirebaseAuth.instance;
//endregion

//region USER SERVICE
UserService userService = UserService();
AuthService authService = AuthService();
GoogleSignInAuthService googleSignInAuthService = GoogleSignInAuthService();
AppleLoginAuthService appleLoginAuthService = AppleLoginAuthService();
//endregion

//region LANGUAGE
BaseLanguage locale = LanguageEn();
//endregion
 
//region Cached Responses
ConfigurationResponse? appConfigurationResponseCached;
DashboardResponse? dashboardResponseCached;
ProductDashboardResponse? productDashboardResponseCached;
List<BranchData>? branchListCached;
List<CategoryData>? categoryListCached;
List<CategoryData>? productCategoryListCached;
List<EmployeeData>? employeeListCached;
List<BookingStatusData>? bookingStatusListCached;
List<OrderStatusData>? orderStatusListCached;
List<ReviewData>? branchReviewListResponseCached;
List<EmployeeData>? branchStaffListResponseCached;
List<BranchGalleryData>? branchGalleryListResponseCached;
List<ServiceListData>? branchServiceListResponseCached;
List<NotificationData>? notificationListCached;
List<ProductData>? getWishListCached;
List<BookingListData> bookingDetailCached = [];
List<OrderListData> orderDetailCached = [];
List<(int serviceId, EmployeeDetailResponse list)?> employeeDetailCachedData = [];
List<BranchDetailResponse> branchDetailCachedData = [];
BranchConfigurationData? branchConfigurationCached;
List<BankHistory>? cachedBankList;
List<WalletDataElement>? cachedWalletHistoryList;
bool isNotificationRead = false;
  
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp().then((value) {
    NotificationService().init();
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  }).catchError(onError);

  defaultBlurRadius = 0;
  defaultSpreadRadius = 0;
  passwordLengthGlobal = 8;
  textBoldSizeGlobal = 14;
  textPrimarySizeGlobal = 14;
  textSecondarySizeGlobal = 12;

  await initialize(aLocaleLanguageList: languageList());

  await appStore.setLanguage(getStringAsync(SELECTED_LANGUAGE_CODE, defaultValue: DEFAULT_LANGUAGE));
  locale = await AppLocalizations().load(Locale(appStore.selectedLanguageCode));

  appStore.setLoggedIn(getBoolAsync(SharedPreferenceConst.IS_LOGGED_IN), isInitializing: true);
  await appStore.setBranchId(getIntAsync(SharedPreferenceConst.BRANCH_ID, defaultValue: UNSELECTED_BRANCH_ID));
  await appStore.setBranchAddress(getStringAsync(SharedPreferenceConst.BRANCH_ADDRESS));
  await appStore.setBranchName(getStringAsync(SharedPreferenceConst.BRANCH_NAME));
  await appStore.setBranchContactNumber(getStringAsync(SharedPreferenceConst.BRANCH_CONTACT_NUMBER));
  if (appStore.isLoggedIn) {
    await userStore.setUserId(getIntAsync(SharedPreferenceConst.USER_ID), isInitializing: true);
    await userStore.setFirstName(getStringAsync(SharedPreferenceConst.FIRST_NAME), isInitializing: true);
    await userStore.setLastName(getStringAsync(SharedPreferenceConst.LAST_NAME), isInitializing: true);
    await userStore.setUserEmail(getStringAsync(SharedPreferenceConst.USER_EMAIL), isInitializing: true);
    await userStore.setToken(getStringAsync(SharedPreferenceConst.TOKEN), isInitializing: true);
    await userStore.setUserProfile(getStringAsync(SharedPreferenceConst.AVTAR), isInitializing: true);
    await userStore.setLoginType(getStringAsync(SharedPreferenceConst.LOGIN_TYPE), isInitializing: true);
    await userStore.setContactNumber(getStringAsync(SharedPreferenceConst.CONTACT_NUMBER), isInitializing: true);
    await userStore.setCountryCode(getStringAsync(SharedPreferenceConst.COUNTRY_CODE), isInitializing: true);
    await appStore.setHelplineNumber(getStringAsync(SharedPreferenceConst.HELPLINE_NUMBER), isInitializing: true);
    await appStore.setInquiryEmail(getStringAsync(SharedPreferenceConst.INQUIRY_EMAIL), isInitializing: true);
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final NetworkService _networkService = NetworkService();
  bool _isInitialized = false;
  late ReactionDisposer disposer;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    _networkService.init();

    // Check initial connectivity
    await _networkService.checkInitialConnectivity();

    // Listen for connectivity changes
    _networkService.isConnected.addListener(_onConnectivityChanged);

    _isInitialized = true;
    setState(() {});
    disposer = reaction(
      (_) => appStore.selectedLanguageCode,
      (newValue) {
        setState(() { });
      },
    );
  }

  void _onConnectivityChanged() {
    if (_isInitialized) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _networkService.isConnected.removeListener(_onConnectivityChanged);
    disposer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RestartAppWidget(
      child: Observer(
        builder: (_) => ShadApp.custom(
          themeMode: appStore.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          theme: ShadThemeData(
            brightness: Brightness.light,
            colorScheme: const ShadSlateColorScheme.light(),
          ),
          darkTheme: ShadThemeData(
            brightness: Brightness.dark,
            colorScheme: const ShadSlateColorScheme.dark(),
          ),
          appBuilder: (context) {
            return MaterialApp(
              navigatorKey: navigatorKey,
              debugShowCheckedModeBanner: false,
              supportedLocales: LanguageDataModel.languageLocales(),
              localizationsDelegates: [
                const AppLocalizations(),
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              localeResolutionCallback: (locale, supportedLocales) => Locale(appStore.selectedLanguageCode),
              locale: Locale(appStore.selectedLanguageCode),
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: appStore.isDarkMode ? ThemeMode.dark : ThemeMode.light,
              builder: (context, child) {
                return ShadAppBuilder(child: child!);
              },
              home: _buildHome(),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHome() {
    if (!_isInitialized) {
      // Show loading while checking connectivity
      return Scaffold(
        body: Container(
          color: context.primaryColor,
          child: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ),
      );
    }

    if (!_networkService.isConnected.value) {
      // Show no internet screen immediately
      return NoInternetScreen(
        onRetry: () {
          _networkService.checkInitialConnectivity();
        },
      );
    }

    // Show splash screen when connected
    return SplashScreen();
  }
}
