import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frezka/screens/branch/branch_repository.dart';
import 'package:mobx/mobx.dart';
import 'package:nb_utils/nb_utils.dart';

import '../configs.dart';
import '../locale/app_localizations.dart';
import '../main.dart';
import '../network/rest_apis.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';

part 'app_store.g.dart';

class AppStore = _AppStore with _$AppStore;

abstract class _AppStore with Store {
  @observable
  bool isLoggedIn = false;

  @observable
  bool isInternetAvailable = true;

  @observable
  bool isDarkMode = false;

  @observable
  bool isLoading = false;

  @observable
  bool isSpeechActivated = false;

  @observable
  String selectedLanguageCode = DEFAULT_LANGUAGE;

  @observable
  String currencyCode = 'INR';

  @observable
  int countryId = 0;

  @observable
  int stateId = 0;

  @observable
  int cityId = 0;

  @observable
  String currencyCountryId = '';

  @observable
  String currencySymbol = '';

  @observable
  String termConditions = getStringAsync(TERMS_CONDITION_URL);

  @observable
  String privacyPolicy = getStringAsync(PRIVACY_POLICY_URL);

  @observable
  String fAQ = getStringAsync(FAQs_URL);

  @observable
  String inquiryEmail = '';

  @observable
  String helplineNumber = '';

  @observable
  int branchId = UNSELECTED_BRANCH_ID;

  @computed
  bool get isBranchSelected => branchId != UNSELECTED_BRANCH_ID;

  @observable
  String branchAddress = '';

  @observable
  String branchName = '';

  @observable
  String branchContactNumber = '';

  @observable
  num userWalletAmount = 0.0;

  @observable
  bool isEnableUserWallet = getBoolAsync(ENABLE_USER_WALLET);

  @observable
  String token = getStringAsync(SharedPreferenceConst.TOKEN);

  @observable
  bool onlinePaymentStatus = getBoolAsync(ONLINE_PAYMENT_STATUS);

  @observable
  bool isUserAuthorized = getBoolAsync(IS_USER_AUTHORIZED);

  @action
  Future<void> setISUserAuthorized(bool val) async {
    isUserAuthorized = val;
    await setValue(IS_USER_AUTHORIZED, val);
  }

  @action
  Future<void> setBranchAddress(String val, {bool isInitializing = false}) async {
    branchAddress = val;
    if (!isInitializing) await setValue(SharedPreferenceConst.BRANCH_ADDRESS, val);
  }

  @action
  Future<void> setBranchName(String val, {bool isInitializing = false}) async {
    branchName = val;
    if (!isInitializing) await setValue(SharedPreferenceConst.BRANCH_NAME, val);
  }

  @action
  Future<void> setBranchContactNumber(String val, {bool isInitializing = false}) async {
    branchContactNumber = val;
    if (!isInitializing) await setValue(SharedPreferenceConst.BRANCH_CONTACT_NUMBER, val);
  }

  @action
  Future<void> setBranchId(int val, {bool isInitializing = false}) async {
    branchId = val;
    if (!isInitializing) {
      await setValue(SharedPreferenceConst.BRANCH_ID, val);

      getBranchConfiguration(val).then((value) => null).catchError(onError);
    }
  }

  @action
  Future<void> setHelplineNumber(String val, {bool isInitializing = false}) async {
    helplineNumber = val;
    if (!isInitializing) await setValue(SharedPreferenceConst.HELPLINE_NUMBER, val);
  }

  @action
  Future<void> setInquiryEmail(String val, {bool isInitializing = false}) async {
    inquiryEmail = val;
    if (!isInitializing) await setValue(SharedPreferenceConst.INQUIRY_EMAIL, val);
  }

  @action
  Future<void> setTermConditions(String val) async {
    termConditions = val;
    await setValue(TERMS_CONDITION_URL, val);
  }

  @action
  Future<void> setFaq(String val) async {
    fAQ = val;
    await setValue(FAQs_URL, val);
  }
  @action
  Future<void> setPrivacyPolicy(String val) async {
    privacyPolicy = val;
    await setValue(PRIVACY_POLICY_URL, val);
  }
  @action
  Future<void> setCurrencySymbol(String val, {bool isInitializing = false}) async {
    currencySymbol = val;
    if (!isInitializing) await setValue(ConfigurationKeyConst.CURRENCY_COUNTRY_SYMBOL, val);
  }

  @action
  Future<void> setCurrencyCountryId(String val, {bool isInitializing = false}) async {
    currencyCountryId = val;
    if (!isInitializing) await setValue(ConfigurationKeyConst.CURRENCY_COUNTRY_ID, val);
  }

  @action
  Future<void> setCountryId(int val, {bool isInitializing = false}) async {
    countryId = val;
    if (!isInitializing) await setValue(SharedPreferenceConst.COUNTRY_ID, val);
  }

  @action
  Future<void> setStateId(int val, {bool isInitializing = false}) async {
    stateId = val;
    if (!isInitializing) await setValue(SharedPreferenceConst.STATE_ID, val);
  }

  @action
  Future<void> setCityId(int val, {bool isInitializing = false}) async {
    cityId = val;
    if (!isInitializing) await setValue(SharedPreferenceConst.CITY_ID, val);
  }

  @action
  Future<void> setCurrencyCode(String val, {bool isInitializing = false}) async {
    currencyCode = val;
    if (!isInitializing) await setValue(ConfigurationKeyConst.CURRENCY_COUNTRY_CODE, val);
  }

  @action
  Future<void> setLoggedIn(bool val, {bool isInitializing = false}) async {
    isLoggedIn = val;
    if (!isInitializing) await setValue(SharedPreferenceConst.IS_LOGGED_IN, val);
  }

  @action
  void setLoading(bool val) {
    isLoading = val;
  }

  @action
  void setInternetAvailable(bool val) {
    isInternetAvailable = val;
  }

  @action
  void setSpeechStatus(bool val) {
    isSpeechActivated = val;
  }



  @action
  Future<void> setDarkMode(bool val) async {
    isDarkMode = val;

    if (isDarkMode) {
      textPrimaryColorGlobal = Colors.white;
      textSecondaryColorGlobal = textSecondaryColor;
      defaultLoaderBgColorGlobal = scaffoldDarkColor;
      appButtonBackgroundColorGlobal = appButtonColorDark;
      shadowColorGlobal = Colors.white12;
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        systemNavigationBarColor: cardDarkColor,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ));
    } else {
      textPrimaryColorGlobal = textPrimaryColor;
      textSecondaryColorGlobal = textSecondaryColor;
      defaultLoaderBgColorGlobal = Colors.white;
      appButtonBackgroundColorGlobal = Colors.white;
      shadowColorGlobal = Colors.black12;
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        systemNavigationBarColor: cardColor,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ));
    }
  }

  @action
  Future<void> setLanguage(String val) async {
    selectedLanguageCode = val;
    selectedLanguageDataModel = getSelectedLanguageModel();

    await setValue(SELECTED_LANGUAGE_CODE, selectedLanguageCode);

    locale = await AppLocalizations().load(Locale(selectedLanguageCode));

    errorMessage = locale.pleaseTryAgain;
    errorSomethingWentWrong = locale.somethingWentWrong;
    errorThisFieldRequired = locale.thisFieldIsRequired;
    errorInternetNotAvailable = locale.yourInternetIsNotWorking;
  }

  @action
  Future<void> setUserWalletAmount() async {
    if (isLoggedIn) {
      userWalletAmount = await getUserWalletBalance();
    } else {
      userWalletAmount = 0.0;
    }
  }

  @action
  Future<void> setEnableUserWallet(bool val) async {
    isEnableUserWallet = val;
    await setValue(ENABLE_USER_WALLET, val);
  }

  @action
  Future<void> setToken(String val) async {
    token = val;
    await setValue(SharedPreferenceConst.TOKEN, val);
  }

  @action
  Future<void> setOnlinePaymentStatus(bool val) async {
    onlinePaymentStatus = val;
    await setValue(ONLINE_PAYMENT_STATUS, val);
  }

}