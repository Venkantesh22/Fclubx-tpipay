import 'dart:math';

import 'package:cinetpay/cinetpay.dart';
import 'package:flutter/material.dart';
import 'package:frezka/main.dart';
import 'package:frezka/utils/constants.dart';
import 'package:frezka/utils/custom_toast_widget.dart';
import 'package:nb_utils/nb_utils.dart';

class CinetPayServicesNew {
  //late PaymentSetting paymentSetting;
  num totalAmount;
  late Function(Map<String, dynamic>) onComplete;

  // Local Variable
  Map<String, dynamic>? response;

  CinetPayServicesNew({
    // required this.paymentSetting,
    required this.totalAmount,
    required Function(Map) onComplete,
  });

  final String transactionId = Random().nextInt(100000000).toString();

  Future<void> payWithCinetPay({required BuildContext context}) async {
    await Navigator.push(getContext, MaterialPageRoute(builder: (_) => cinetPay()));
    appStore.setLoading(false);
  }

  Widget cinetPay() {
    return CinetPayCheckout(
      title: locale.lblCheckOutWithCiNetPay,
      configData: <String, dynamic>{
        'apikey': getStringAsync(PaymentKeys.CINET_API_KEY),
        'site_id': getStringAsync(PaymentKeys.CINET_SITE_ID),
        'notify_url': 'http://mondomaine.com/notify/',
        'mode': 'PRODUCTION',
      },
      paymentData: <String, dynamic>{
        'transaction_id': transactionId,
        'amount': totalAmount,
        'currency': appStore.currencyCode,
        'channels': 'ALL',
        'description': 'Email: ${userStore.userEmail}',
      },
      waitResponse: (data) async {
        response = data;
        log(response);

        if (data['status'] == "REFUSED") {
          ShowToast.showError(locale.yourPaymentFailedPleaseTryAgain);
        } else if (data['status'] == "ACCEPTED") {
          ShowToast.showSuccess(locale.yourPaymentHasBeenMadeSuccessfully);
          appStore.setLoading(false);
            onComplete.call(
              {
                'transaction_id': transactionId,
              },
            );

          log('Payment was successful. Ref: $transactionId');
        }
      },
      onError: (data) {
        response = data;
        log(response);
        appStore.setLoading(false);
      },
    );
  }
}
