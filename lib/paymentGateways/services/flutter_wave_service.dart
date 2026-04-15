import 'package:flutterwave_standard/flutterwave.dart';
import 'package:frezka/main.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:uuid/uuid.dart';

import '../../configs.dart';
import '../../network/rest_apis.dart';
import '../../utils/constants.dart';
import '../../utils/custom_toast_widget.dart';
import '../../utils/images.dart';

class FlutterWaveService {
  final Customer customer = Customer(
    name: userStore.userName,
    phoneNumber: userStore.userContactNumber,
    email: userStore.userEmail,
  );

  void checkout({
    required String flutterWavePublicKey,
    required String flutterWaveSecretKey,
    required num totalAmount,

    required bool isTestMode,

    required Function(Map<String, dynamic>) onComplete,
  }) async {
    String transactionId = Uuid().v1();

    Flutterwave flutterWave = Flutterwave(
      context: getContext,
      publicKey: getStringAsync(PaymentKeys.FLUTTER_WAVE_PUBLIC_KEY),
      currency: appStore.currencyCode,
      redirectUrl: BASE_URL,
      txRef: transactionId,
      amount: totalAmount.validate().toStringAsFixed(DECIMAL_POINT),
      customer: customer,
      paymentOptions: "ussd, card, payattitude, barter, bank transfer",
      customization: Customization(title: locale.payWithFlutterwave, logo: app_logo),
      isTestMode: isTestMode,
    );

    await flutterWave.charge().then((value) {
      log("Value is ===>${value.toJson()}");
      if (value.status == "successful") {
        appStore.setLoading(true);

        verifyPayment(transactionId: value.transactionId.validate(), flutterWaveSecretKey: getStringAsync(PaymentKeys.FLUTTER_WAVE_SECRET_KEY)).then((v) async {
          if (v.status == "success") {
            onComplete.call(
              {
                'transaction_id': v.transactionData!.id.toString(),
              }

            );
          } else {
            appStore.setLoading(false);
            ShowToast.showError(locale.transactionFailed);
          }
        }).catchError((e) {
          appStore.setLoading(false);

          ShowToast.showError(e.toString());
        });
      } else {
        ShowToast.showInfo(locale.transactionCancelled);
        appStore.setLoading(false);
      }
    });
  }
}
