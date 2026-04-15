import 'package:flutter/cupertino.dart';
import 'package:frezka/main.dart';
import 'package:frezka/network/rest_apis.dart';
import 'package:frezka/paymentGateways/screens/payment_webview_screen.dart';
import 'package:frezka/utils/constants.dart';
import 'package:frezka/utils/custom_toast_widget.dart';
import 'package:nb_utils/nb_utils.dart';

class SadadServicesNew {
  String remarks;
  num totalAmount;
  late Function(Map<String, dynamic>) onComplete;

  SadadServicesNew({
    //required this.paymentSetting,
    required this.totalAmount,
    this.remarks = "",
    required Function(Map) onComplete,
  });

  Future<void> payWithSadad(BuildContext context) async {
    String sadadId = getStringAsync(PaymentKeys.SADAD_CLIENT_ID);
    String sadadKey = getStringAsync(PaymentKeys.SADAD_SECRET_KEY);
    String sadadDomain = getStringAsync(PaymentKeys.SADAD_DOMAIN);

    if (sadadId.isEmpty || sadadKey.isEmpty || sadadDomain.isEmpty) throw locale.accessDeniedContactYourAdmin;

    Map request = {
      "sadadId": sadadId,
      "secretKey": sadadKey,
      "domain": sadadDomain,
    };
    appStore.setLoading(true);
    await sadadLogin(request).then((accessToken) async {
      await createInvoice(context, accessToken: accessToken).then((value) async {
        //
      }).catchError((e) {
        appStore.setLoading(false);
        ShowToast.showError(e.toString());
      });
    }).catchError((e) {
      appStore.setLoading(false);
      ShowToast.showError(e.toString());
    });
  }

  Future<void> createInvoice(BuildContext context, {required String accessToken}) async {
    Map<String, dynamic> req = {
      "countryCode": 974,
      "clientname": userStore.userName.validate(),
      "cellnumber": userStore.userContactNumber.validate().splitAfter('-'),
      "invoicedetails": [
        {
          "description": 'Name: ${userStore.userFullName} - Email: ${userStore.userEmail}',
          "quantity": 1,
          "amount": totalAmount,
        },
      ],
      "status": 2,
      "remarks": remarks,
      "amount": totalAmount,
    };
    sadadCreateInvoice(request: req, sadadToken: accessToken).then((value) async {
      appStore.setLoading(false);
      log('val:${value[0]['shareUrl']}');

      String? res = await PaymentWebViewScreen(url: value[0]['shareUrl'], accessToken: accessToken).launch(context, pageRouteAnimation: PageRouteAnimation.Fade);

      if (res.validate().isNotEmpty) {
        onComplete.call(
          {
            'transaction_id': res,
          },
        );
      } else {
        ShowToast.showError(locale.transactionFailed);
      }
    }).catchError((e) {
      appStore.setLoading(false);
      ShowToast.showError('Error: $e');
    });
  }
}
// Handle CinetPayment
