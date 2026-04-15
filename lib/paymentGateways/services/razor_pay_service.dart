import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../configs.dart';
import '../../main.dart';
import '../../utils/custom_toast_widget.dart';

class RazorPayService {
  static late Razorpay razorPay;
  static late String razorKeys;
  num totalAmount = 0;
  late Function(Map<String, dynamic>) onComplete;



  init({
    required String razorKey,
    required num totalAmount,
    required Function(Map<String, dynamic>) onComplete,
  }) {
    razorPay = Razorpay();
    razorPay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlePaymentSuccess);
    razorPay.on(Razorpay.EVENT_PAYMENT_ERROR, handlePaymentError);
    razorPay.on(Razorpay.EVENT_EXTERNAL_WALLET, handleExternalWallet);
    razorKeys = razorKey;
    this.totalAmount = totalAmount;
    this.onComplete = onComplete;
  }

  Future handlePaymentSuccess(PaymentSuccessResponse response) async {
    onComplete.call(
      {
        'transaction_id': response.paymentId,
      }
    );
  }

  void handlePaymentError(PaymentFailureResponse response) {
    ShowToast.showError(response.message.validate());
  }

  void handleExternalWallet(ExternalWalletResponse response) {
    ShowToast.showInfo("${locale.externalWallet} " + response.walletName!);
  }

  void razorPayCheckout() async {
    var options = await{
      'key': razorKeys,
      'amount': (totalAmount * 100).toInt(),
      'name': APP_NAME,
      'theme.color': '#A82D86',
      'description': APP_NAME,
      'image': 'https://razorpay.com/assets/razorpay-glyph.svg',
      'currency': STRIPE_CURRENCY_CODE,
      'prefill': {'contact': userStore.userContactNumber, 'email': userStore.userEmail},
      'external': {
        'wallets': ['paytm']
      }
    };
    try {
      razorPay.open(options);
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
