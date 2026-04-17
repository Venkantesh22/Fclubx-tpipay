import 'package:frezka/configs.dart';
import 'package:frezka/models/referral_model.dart';
import 'package:frezka/network/network_utils.dart';
import 'package:frezka/screens/branch/branch_repository.dart';
import 'package:frezka/utils/custom_toast_widget.dart';
import 'package:nb_utils/nb_utils.dart';

import '../main.dart';
import '../models/bank_list_response.dart';
import '../models/base_response_model.dart';
import '../models/configuration_response.dart';
import '../models/user_wallet_history.dart';
import '../models/verify_transaction_response.dart';
import '../models/wallet_response.dart';
import '../paymentGateways/models/payment_gateway_response.dart';
import '../utils/api_end_points.dart';
import '../utils/constants.dart';

Future<void> clearPreferences() async {
  await userStore.setFirstName('');
  await userStore.setLastName('');
  await userStore.setUserId(0);
  await userStore.setUserName('');
  await userStore.setContactNumber('');
  await userStore.setCountryCode('');
  await userStore.setGenderValue('');
  await userStore.setUserProfile('');
  await userStore.setUId('');
  await userStore.setToken('');

  await appStore.setHelplineNumber('');
  await appStore.setInquiryEmail('');
  await appStore.setLoggedIn(false);
}

//region Configurations Api
Future<ConfigurationResponse> getAppConfigurations(
    {bool isCurrentLocation = false, double? lat, double? long}) async {
  try {
    int isAuthenticated = appStore.isLoggedIn == true ? 1 : 0;
    final uri =
        '${APIEndPoints.appConfiguration}?${APIParamKeysConst.isAuthenticated}=$isAuthenticated';
    appConfigurationResponseCached = ConfigurationResponse.fromJson(
        await handleResponse(
            await buildHttpResponse(uri, method: HttpMethodType.POST)));
    if (appConfigurationResponseCached!.onesignalCustomerApp != null) {
      await setValue(ConfigurationKeyConst.ONESIGNAL_API_KEY,
          appConfigurationResponseCached!.onesignalCustomerApp!.onesignalAppId);
      await setValue(
          ConfigurationKeyConst.ONESIGNAL_CHANNEL_KEY,
          appConfigurationResponseCached!
              .onesignalCustomerApp!.onesignalChannelId);
      await setValue(
          ConfigurationKeyConst.ONESIGNAL_REST_API_KEY,
          appConfigurationResponseCached!
              .onesignalCustomerApp!.onesignalRestApiKey);

      /// Initialize OneSignal if we get API Keys
      // initOneSignal();
    }

    // set cinet pay  keys
    if (appConfigurationResponseCached!.cinetPay != null) {
      await setValue(PaymentKeys.CINET_CLIENT_ID,
          appConfigurationResponseCached!.cinetPay!.cinetClientId);
      await setValue(PaymentKeys.CINET_API_KEY,
          appConfigurationResponseCached!.cinetPay!.cinetApiKey);
      await setValue(PaymentKeys.CINET_SECRET_KEY,
          appConfigurationResponseCached!.cinetPay!.cinetSecretkey);
      await setValue(PaymentKeys.CINET_SITE_ID,
          appConfigurationResponseCached!.cinetPay!.cinetSiteID);
    }
    // set sadad pay  keys
    if (appConfigurationResponseCached!.sadadPay != null) {
      await setValue(PaymentKeys.SADAD_CLIENT_ID,
          appConfigurationResponseCached!.sadadPay!.sadadClientId);
      await setValue(PaymentKeys.SADAD_SECRET_KEY,
          appConfigurationResponseCached!.sadadPay!.sadadSecretKey);
      await setValue(PaymentKeys.SADAD_DOMAIN,
          appConfigurationResponseCached!.sadadPay!.sadadDomain);
    }
    // set airtel money keys
    if (appConfigurationResponseCached!.airtelMoneyPay != null) {
      await setValue(PaymentKeys.AIRTEL_MONEY_CLIENT_ID,
          appConfigurationResponseCached!.airtelMoneyPay!.airtelMoneyClientId);
      await setValue(PaymentKeys.AIRTEL_MONEY_SECRET_KEY,
          appConfigurationResponseCached!.airtelMoneyPay!.airtelMoneySecretKey);
      await setValue(
          PaymentKeys.AIRTEL_MONEY_IS_IN_PRODUCTION,
          appConfigurationResponseCached!
              .airtelMoneyPay!.airtelMoneyIsInProduction);
    }
    // set razorpay keys
    if (appConfigurationResponseCached!.razorPay != null) {
      await setValue(PaymentKeys.RAZORPAY_SECRET_KEY,
          appConfigurationResponseCached!.razorPay!.razorpaySecretKey);
      await setValue(PaymentKeys.RAZORPAY_PUBLIC_KEY,
          appConfigurationResponseCached!.razorPay!.razorpayPublicKey);
    }
    // set stripe keys
    if (appConfigurationResponseCached!.stripePay != null) {
      await setValue(PaymentKeys.STRIPE_SECRET_KEY,
          appConfigurationResponseCached!.stripePay!.stripeSecretKey);
      await setValue(PaymentKeys.STRIPE_PUBLIC_KEY,
          appConfigurationResponseCached!.stripePay!.stripePublicKey);
    }
    // set pay stack keys
    if (appConfigurationResponseCached!.payStackPay != null) {
      await setValue(PaymentKeys.PAY_STACK_SECRET_KEY,
          appConfigurationResponseCached!.payStackPay!.payStackSecretKey);
      await setValue(PaymentKeys.PAY_STACK_PUBLIC_KEY,
          appConfigurationResponseCached!.payStackPay!.payStackPublicKey);
    }
    // set paypal keys
    if (appConfigurationResponseCached!.paypalPay != null) {
      await setValue(PaymentKeys.PAYPAL_SECRET_KEY,
          appConfigurationResponseCached!.paypalPay!.paypalSecretKey);
      await setValue(PaymentKeys.PAYPAL_CLIENT_ID,
          appConfigurationResponseCached!.paypalPay!.paypalClientId);
    }
    // set flutter wave keys
    if (appConfigurationResponseCached!.flutterWavePay != null) {
      await setValue(PaymentKeys.FLUTTER_WAVE_SECRET_KEY,
          appConfigurationResponseCached!.flutterWavePay!.flutterWaveSecretKey);
      await setValue(PaymentKeys.FLUTTER_WAVE_PUBLIC_KEY,
          appConfigurationResponseCached!.flutterWavePay!.flutterWavePublicKey);
    }

    // set phone pay  keys
    if (appConfigurationResponseCached!.phonePayPay != null) {
      await setValue(PaymentKeys.PHONE_PAY_APP_ID,
          appConfigurationResponseCached!.phonePayPay!.phonePayAppId);
      await setValue(PaymentKeys.PHONE_PAY_MERCHANT_ID,
          appConfigurationResponseCached!.phonePayPay!.phonePayMerchantId);
      await setValue(PaymentKeys.PHONE_PAY_SALT_ID,
          appConfigurationResponseCached!.phonePayPay!.phonePaySaltId);
      await setValue(PaymentKeys.PHONE_PAY_SALT_KEY,
          appConfigurationResponseCached!.phonePayPay!.phonePaySaltKey);
      await setValue(PaymentKeys.PHONE_PAY_IS_IN_PRODUCTION,
          appConfigurationResponseCached!.phonePayPay!.phonePayIsInProduction);
    }
    // set midtrance keys
    if (appConfigurationResponseCached!.midtransPay != null) {
      await setValue(PaymentKeys.MIDTRANS_CLIENT_ID,
          appConfigurationResponseCached!.midtransPay!.midtransClientId);
      await setValue(PaymentKeys.MIDTRANS_IS_IN_PRODUCTION,
          appConfigurationResponseCached!.midtransPay!.midtranceIsInProduction);
    }

    await setValue(ConfigurationKeyConst.APP_NAME,
        appConfigurationResponseCached!.appName);
    await setValue(ConfigurationKeyConst.FOOTER_TEXT,
        appConfigurationResponseCached!.footerText);
    await setValue(
        ConfigurationKeyConst.HELPLINE_NUMBER,
        appConfigurationResponseCached!.helplineNumber
            .validate(value: HELP_LINE_NUMBER));
    await setValue(ConfigurationKeyConst.COPYRIGHT,
        appConfigurationResponseCached!.copyright);
    await setValue(
        ConfigurationKeyConst.INQUIRY_EMAIL,
        appConfigurationResponseCached!.inquiryEmail
            .validate(value: INQUIRY_SUPPORT_EMAIL));
    await setValue(ConfigurationKeyConst.SITE_DESCRIPTION,
        appConfigurationResponseCached!.siteDescription);
    await setValue(ConfigurationKeyConst.PRIMARY,
        appConfigurationResponseCached!.primaryColor);
    appConfigurationResponseCached!.pages.forEach((element) async {
      if (element.slug == APIParamKeysConst.privacyPolicy) {
        await setValue(
            ConfigurationKeyConst.PRIVACY_POLICY, element.description);
      } else if (element.slug == APIParamKeysConst.termsCondition) {
        await setValue(
            ConfigurationKeyConst.TERMS_CONDITION, element.description);
      } else if (element.slug == APIParamKeysConst.faq) {
        await setValue(ConfigurationKeyConst.FAQ, element.description);
      }
    });
    await setValue(ConfigurationKeyConst.GOOGLE_MAPS_KEY,
        appConfigurationResponseCached!.googleMapsKey);
    await setValue(ConfigurationKeyConst.CUSTOMER_APP_PLAY_STORE,
        appConfigurationResponseCached!.customerAppPlayStore);
    await setValue(ConfigurationKeyConst.CUSTOMER_APP_APP_STORE,
        appConfigurationResponseCached!.customerAppAppStore);
    await setValue(ConfigurationKeyConst.GOOGLE_LOGIN_STATUS,
        appConfigurationResponseCached!.googleLoginStatus);
    await setValue(ConfigurationKeyConst.APPLE_LOGIN_STATUS,
        appConfigurationResponseCached!.appleLoginStatus);
    await setValue(ConfigurationKeyConst.OTP_LOGIN_STATUS,
        appConfigurationResponseCached!.otpLoginStatus);
    await setValue(ConfigurationKeyConst.APPLICATION_LANGUAGE,
        appConfigurationResponseCached!.applicationLanguage);
    await setValue(ConfigurationKeyConst.IS_FORCE_UPDATE,
        appConfigurationResponseCached!.isForceUpdate);
    await setValue(ConfigurationKeyConst.VERSION_CODE,
        appConfigurationResponseCached!.versionCode);

    if (appConfigurationResponseCached!.currency != null) {
      appStore.setCurrencySymbol(
          appConfigurationResponseCached!.currency!.currencySymbol.validate());
      appStore.setCurrencyCode(
          appConfigurationResponseCached!.currency!.currencyCode.validate());
      await setValue(ConfigurationKeyConst.CURRENCY_NAME,
          appConfigurationResponseCached!.currency!.currencyName);
      await setValue(ConfigurationKeyConst.CURRENCY_SYMBOL,
          appConfigurationResponseCached!.currency!.currencySymbol);
      await setValue(ConfigurationKeyConst.CURRENCY_CODE,
          appConfigurationResponseCached!.currency!.currencyCode);
      await setValue(ConfigurationKeyConst.CURRENCY_POSITION,
          appConfigurationResponseCached!.currency!.currencyPosition);
      await setValue(ConfigurationKeyConst.NO_OF_DECIMAL,
          appConfigurationResponseCached!.currency!.noOfDecimal);
      await setValue(ConfigurationKeyConst.THOUSAND_SEPARATOR,
          appConfigurationResponseCached!.currency!.thousandSeparator);
      await setValue(ConfigurationKeyConst.DECIMAL_SEPARATOR,
          appConfigurationResponseCached!.currency!.decimalSeparator);
    }

    return appConfigurationResponseCached!;
  } catch (e) {
    log(e);
    throw e;
  }
}
//endregion

//region Refresh Configuration Data
Future<void> refreshConfigurationData({int? branchId}) async {
  try {
    await getAppConfigurations();
    if (branchId != null) {
      await getBranchConfiguration(branchId);
    }
  } catch (e) {
    log('Error refreshing configuration data: $e');
    throw e;
  }
}
//endregion

//region FlutterWave Verify Transaction API
Future<VerifyTransactionResponse> verifyPayment(
    {required String transactionId,
    required String flutterWaveSecretKey}) async {
  return VerifyTransactionResponse.fromJson(
    await handleResponse(
      await buildHttpResponse(
          "https://api.flutterwave.com/v3/transactions/$transactionId/verify",
          extraKeys: {
            'isFlutterWave': true,
            'flutterWaveSecretKey': flutterWaveSecretKey,
          }),
      isFlutterWave: true,
    ),
  );
}
//endregion

//region Sadad Payment Api
Future<String> sadadLogin(Map request) async {
  try {
    var res = await handleSadadResponse(
      await buildHttpResponse(
        '${getStringAsync(PaymentKeys.SADAD_DOMAIN)}/api/userbusinesses/login',
        method: HttpMethodType.POST,
        request: request,
        header: buildHeaderForSadad(),
      ),
    );

    return res['accessToken'];
  } catch (e) {
    throw errorSomethingWentWrong;
  }
}

Future sadadCreateInvoice(
    {required Map<String, dynamic> request, required String sadadToken}) async {
  return await handleSadadResponse(await buildHttpResponse(
    '${getStringAsync(PaymentKeys.SADAD_DOMAIN)}/api/invoices/createInvoice',
    method: HttpMethodType.POST,
    request: request,
    header: buildHeaderForSadad(sadadToken: sadadToken),
  ));
}

Future<BaseResponseModel> chooseDefaulBank({required int bankId}) async {
  return BaseResponseModel.fromJson(await handleResponse(
      await buildHttpResponse('${APIEndPoints.defaultBank}?id=$bankId',
          request: {}, method: HttpMethodType.GET)));
}

Future<BaseResponseModel> deleteBank({int? bankId}) async {
  return BaseResponseModel.fromJson(await handleResponse(
      await buildHttpResponse('${APIEndPoints.deleteBank}/$bankId',
          request: {}, method: HttpMethodType.DELETE)));
}

Future<List<BankHistory>> getBankListDetail({
  required int userId,
  int? page,
  var perPage = PER_PAGE_ITEM,
  required List<BankHistory> list,
  Function(bool)? lastPageCallback,
}) async {
  BankListResponse res = BankListResponse.fromJson(
    await handleResponse(await buildHttpResponse(
        '${APIEndPoints.userBankDetail}?${APIParamKeysConst.perPage}=$perPage&${APIParamKeysConst.page}=$page&${APIParamKeysConst.userId}=$userId',
        method: HttpMethodType.GET)),
  );

  if (page == 1) list.clear();
  list.addAll(res.data.validate());

  cachedBankList = list;

  appStore.setLoading(false);

  lastPageCallback?.call(res.data.validate().length != PER_PAGE_ITEM);

  return list;
}

Future<BaseResponseModel> walletTopUp(Map req) async {
  // Delay is for showing loader again after loader was hidden from payment gateway
  await 100.milliseconds.delay;
  appStore.setLoading(true);
  try {
    var res = BaseResponseModel.fromJson(await handleResponse(
        await buildHttpResponse(APIEndPoints.walletTopUp,
            method: HttpMethodType.POST, request: req)));

    await appStore.setUserWalletAmount();

    ShowToast.showSuccess('Your Wallet Is Updated');
    appStore.setLoading(false);

    return res;
  } catch (e) {
    log(e);
    appStore.setLoading(false);
    ShowToast.showError(e.toString());
    throw e;
  }
}

Future<num> getUserWalletBalance({bool forceRefresh = false}) async {
  try {
    var res = WalletResponse.fromJson(await handleResponse(
        await buildHttpResponse(APIEndPoints.userWalletBalance,
            method: HttpMethodType.GET)));
    return res.balance.validate();
  } catch (e) {
    appStore.setLoading(false);
    log('Error fetching wallet balance: $e');
    return appStore.userWalletAmount;
  }
}

Future<List<PaymentSetting>> getPaymentGateways(
    {bool requireCOD = true,
    bool requireWallet = true,
    bool isAddWallet = false}) async {
  String isAddWalletStatus =
      isAddWallet ? '?${APIParamKeysConst.isAddWallet}=$isAddWallet' : '';

  try {
    Iterable it = await handleResponse(await buildHttpResponse(
        '${APIEndPoints.paymentGateways}$isAddWalletStatus',
        method: HttpMethodType.GET));
    List<PaymentSetting> res =
        it.map((e) => PaymentSetting.fromJson(e)).toList();

    if (!requireCOD)
      res.removeWhere(
          (element) => element.type == PaymentMethods.PAYMENT_METHOD_CASH);
    if (requireWallet && appStore.isEnableUserWallet) {
      res.add(PaymentSetting(
          title: ' wallet',
          type: PaymentMethods.PAYMENT_METHOD_FROM_WALLET,
          status: 1));
    } else {
      res.removeWhere((element) =>
          element.type == PaymentMethods.PAYMENT_METHOD_FROM_WALLET);
    }

    if (!appStore.onlinePaymentStatus) {
      res.removeWhere(
          (element) => onlinePaymentGateways.contains(element.type));
    }

    return res;
  } catch (e) {
    throw e;
  }
}

Future<BaseResponseModel> providerWithdrawMoney({required Map request}) async {
  return BaseResponseModel.fromJson(await handleResponse(
      await buildHttpResponse(APIEndPoints.withdrawMoney,
          request: request, method: HttpMethodType.POST)));
}

Future<List<WalletDataElement>> getUserWalletHistory(
  int page, {
  var perPage = PER_PAGE_ITEM,
  required List<WalletDataElement> walletDataList,
  Function(bool)? lastPageCallBack,
  Function(num)? availableBalance,
  bool forceRefresh = false,
}) async {
  appStore.setLoading(true);
  try {
    // Add timestamp to force fresh data if needed
    String endpoint =
        '${APIEndPoints.walletHistory}?${APIParamKeysConst.perPage}=$perPage&${APIParamKeysConst.page}=$page&${APIParamKeysConst.orderBy}=desc';
    if (forceRefresh) {
      endpoint += '&t=${DateTime.now().millisecondsSinceEpoch}';
    }

    var res = UserWalletHistoryResponse.fromJson(await handleResponse(
        await buildHttpResponse(endpoint, method: HttpMethodType.GET)));

    if (page == 1) walletDataList.clear();
    walletDataList.addAll(res.data.validate());
    if (res.availableBalance != null) {
      availableBalance?.call(res.availableBalance ?? 0);
    }
    lastPageCallBack?.call(res.data.validate().length != PER_PAGE_ITEM);
    cachedWalletHistoryList = walletDataList;
    appStore.setLoading(false);
  } catch (e) {
    appStore.setLoading(false);
    throw e;
  }

  return walletDataList;
}

Future<ReferralModel> getMyReferralAPI() async {
  final res = await handleResponse(
    await buildHttpResponse(
      APIEndPoints.referral,
      method: HttpMethodType.GET,
    ),
  );

  return ReferralModel.fromJson(res['data']); // 🔥 FIX HERE
}



//endregion
