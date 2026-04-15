import 'package:flutter/material.dart';
import 'package:flutter_paypal_checkout/flutter_paypal_checkout.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../main.dart';
import '../../utils/constants.dart';
import '../../utils/custom_toast_widget.dart';

class PayPalService {
  late BuildContext ctx;
  num totalAmount = 0;
  String payPalClientId = getStringAsync(PaymentKeys.PAYPAL_CLIENT_ID);
  String secretKey = getStringAsync(PaymentKeys.PAYPAL_SECRET_KEY);
  bool isTest = false;

  late Function(Map<String, dynamic>) onComplete;

  init({
    required BuildContext context,
    required num totalAmount,
    required bool isTest,
    required Function(Map<String, dynamic>) onComplete,
  }) {
    this.ctx = context;

    this.totalAmount = totalAmount;

    this.isTest = isTest;

    this.onComplete = onComplete;
  }

  Future paypalCheckOut() async {
    PaypalCheckout(
      sandboxMode: isTest,
      clientId: payPalClientId,
      secretKey: secretKey,
      returnURL: "junedr375.github.io/junedr375-payment/",
      cancelURL: "junedr375.github.io/junedr375-payment/error.html",
      transactions: [
        {
          "amount": {
            "total": totalAmount,
            "currency":"USD",
            "details": {"subtotal": totalAmount, "shipping": '0', "shipping_discount": 0}
          },
          "description": locale.ThePaymentTransactionDescription,
        }
      ],
      note: locale.ContactUsForAnyQuestionsOnYourOrder,
      onSuccess: (Map params) async {
        log("onSuccess: $params");

        onComplete.call({
          'transaction_id': params['data']['id'],
        });
      },
      onError: (error) {
        log("onError: $error");
        ShowToast.showError("onError: $error");
        Navigator.pop(ctx);
      },
      onCancel: (params) {
        ShowToast.showInfo('cancelled');
      },
    ).launch(ctx);
  }
}
