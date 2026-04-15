import 'dart:convert';

import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../configs.dart';
import '../../main.dart';
import '../../network/network_utils.dart';
import '../../utils/app_common.dart';
import '../../utils/colors.dart';
import '../../utils/common_base.dart';
import '../../utils/constants.dart';
import '../../utils/custom_toast_widget.dart';
import '../models/stripe_pay_model.dart';

class StripeService {
  num totalAmount = 0;
  String stripeURL = 'https://api.stripe.com/v1/payment_intents';
  String stripePaymentKey = getStringAsync(PaymentKeys.STRIPE_SECRET_KEY);
  bool isTest = false;
  late Function(Map<String, dynamic>) onComplete;

  init({
    required num totalAmount,
    required bool isTest,
    required Function(Map<String, dynamic>) onComplete,
  }) async {
    Stripe.publishableKey = getStringAsync(PaymentKeys.STRIPE_PUBLIC_KEY);
    Stripe.merchantIdentifier = 'merchant.flutter.stripe.test';

    await Stripe.instance.applySettings().catchError((e) {
      ShowToast.showError(e.toString());

      throw e.toString();
    });

    this.totalAmount = totalAmount;
    this.isTest = isTest;
    this.onComplete = onComplete;
  }

  //StripPayment
  Future<dynamic> stripePay() async {
    Request request = http.Request(HttpMethodType.POST.name, Uri.parse(stripeURL));

    request.bodyFields = {
      'amount': '${(totalAmount.toInt() * 100)}',
      'currency': await isIqonicProduct ? STRIPE_CURRENCY_CODE : '${appStore.currencyCode}',
      'description': 'Name: ${userStore.userFullName} - Email: ${userStore.userEmail}',
      'shipping[name]': '${userStore.userFullName}',
      'shipping[address][line1]': '12, White House Street, A. K. Road',
      'shipping[address][city]': 'Surat',
      'shipping[address][country]': 'IN',
      'shipping[address][postal_code]': '395008',
      'receipt_email': '${userStore.userEmail}',
    };

    request.headers.addAll(buildHeaderTokens(extraKeys: {'isStripePayment': true, 'stripeKeyPayment': stripePaymentKey}));
    log('URL: ${request.url}');
    log('Header: ${request.headers}');
    log('Request: ${request.bodyFields}');

    await request.send().then((value) {
      http.Response.fromStream(value).then((response) async {
        if (response.statusCode.isSuccessful()) {
          StripePayModel res = StripePayModel.fromJson(jsonDecode(response.body));

          SetupPaymentSheetParameters setupPaymentSheetParameters = SetupPaymentSheetParameters(
            paymentIntentClientSecret: res.clientSecret.validate(),
            style: appThemeMode,
            appearance: PaymentSheetAppearance(colors: PaymentSheetAppearanceColors(primary: primaryColor)),
            applePay: PaymentSheetApplePay(merchantCountryCode: defaultCountry().countryCode),
            googlePay: PaymentSheetGooglePay(merchantCountryCode: defaultCountry().countryCode, testEnv: isTest),
            merchantDisplayName: APP_NAME,
            customerEphemeralKeySecret: isAndroid ? res.clientSecret.validate() : null,
            setupIntentClientSecret: res.clientSecret.validate(),
            billingDetails: BillingDetails(
              name: userStore.userFullName, 
              email: userStore.userEmail,
              phone: userStore.userContactNumber,
              address: Address(
                city: 'Surat',
                country: "IN",
                line1: '12, White House Street',
                line2: 'A.K. Road',
                postalCode: "395008",
                state: 'Gujarat',
              ),
            ),
          );

          await Stripe.instance.initPaymentSheet(paymentSheetParameters: setupPaymentSheetParameters).then((value) async {
            await Stripe.instance.presentPaymentSheet().then((value) async {
              onComplete.call({
                'transaction_id': res.id,
              });
            });
          }).catchError((e) {
            log("---------------$e---------------------");
            throw errorSomethingWentWrong;
          });
        } else if (response.statusCode == 400) {
          throw errorSomethingWentWrong;
        }
      }).catchError((e) {
        throw errorSomethingWentWrong;
      });
    }).catchError((e) {
      ShowToast.showError(e.toString());

      throw e.toString();
    });
  }
}
