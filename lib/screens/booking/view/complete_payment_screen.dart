import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frezka/components/app_common_dialog.dart';
import 'package:frezka/paymentGateways/payment_repo.dart';
import 'package:frezka/paymentGateways/services/airtel_money/airtel_money_service.dart';
import 'package:frezka/paymentGateways/services/cinet_pay_services_new.dart';
import 'package:frezka/paymentGateways/services/midtrans_service.dart';
import 'package:frezka/paymentGateways/services/paypal_service.dart';
import 'package:frezka/paymentGateways/services/phone_pe/phone_pe_service.dart';
import 'package:frezka/paymentGateways/services/razor_pay_service.dart';
import 'package:frezka/paymentGateways/services/sadad_services_new.dart';
import 'package:frezka/paymentGateways/services/stripe_service.dart';
import 'package:frezka/store/booking_request_store.dart';
import 'package:frezka/utils/colors.dart';
import 'package:frezka/utils/custom_toast_widget.dart';
import 'package:frezka/utils/extensions/num_extensions.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../components/app_scaffold.dart';
import '../../../components/cached_image_widget.dart';
import '../../../components/common_app_dialog.dart';
import '../../../components/common_bottom_price_widget.dart';
import '../../../components/view_all_label_component.dart';
import '../../../configs.dart';
import '../../../main.dart';
import '../../../paymentGateways/models/payment_gateway_response.dart';
import '../../../paymentGateways/models/payment_list_model.dart';
import '../../../paymentGateways/services/flutter_wave_service.dart';
import '../../../paymentGateways/services/paystack_service.dart';
import '../../../utils/app_common.dart';
import '../../../utils/common_base.dart';
import '../../../utils/constants.dart';
import '../../branch/branch_repository.dart';
import '../model/booking_list_response.dart';

class CompletePaymentScreen extends StatefulWidget {
  final BookingListData booking;

  CompletePaymentScreen(this.booking);

  @override
  CompletePaymentScreenState createState() => CompletePaymentScreenState();
}

class CompletePaymentScreenState extends State<CompletePaymentScreen> {
  TextEditingController tipController = TextEditingController();

  FocusNode tipFocusNode = FocusNode();
  List<PaymentData> payments = getPaymentList(includeCash: false);

  late PaymentData selectedPayment;

  RazorPayService razorPayService = RazorPayService();
  StripeService stripeServices = StripeService();
  PayStackService payStackServices = PayStackService();
  PayPalService payPalServices = PayPalService();
  FlutterWaveService flutterWaveServices = FlutterWaveService();
  PaymentSetting? currentPaymentMethod;

  String paymentMethod = '';

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    selectedPayment = payments.first;
    appStore.setLoading(true);

    bookingRequestStore.setSelectedServiceListInRequest(widget.booking.serviceList.validate(), isRescheduleInRequest: true);
    bookingRequestStore.setBookingIdInRequest(widget.booking.id.validate());
    bookingRequestStore.setTaxPercentageInRequest(branchConfigurationCached!.tax.validate());

    getBranchConfiguration(appStore.branchId).then((value) {
      appStore.setLoading(false);
      bookingRequestStore.setTaxPercentageInRequest(value.data!.tax.validate());

      setState(() {});
    }).catchError((e) {
      appStore.setLoading(false);
//
    });
  }

  Future<void> savePayment() async {
    hideKeyboard(context);
    if (selectedPayment.id == PaymentMethods.PAYMENT_METHOD_RAZORPAY) {
      paymentMethod = PaymentMethods.PAYMENT_METHOD_RAZORPAY.capitalizeFirstLetter();
      appStore.setLoading(true);

      razorPayService.init(
        razorKey: getStringAsync(PaymentKeys.RAZORPAY_PUBLIC_KEY),
        totalAmount: bookingRequestStore.totalAmount,
        onComplete: (res) async {
          await savePay(
            bookingId: bookingRequestStore.bookingId.validate(),
            discountAmount: 0,
            discountPercentage: 0,
            externalTransactionId: res['transaction_id'].validate(),
            taxData: bookingRequestStore.taxPercentage.validate(),
            transactionType: PaymentMethods.PAYMENT_METHOD_FLUTTER_WAVE,
            paymentStatus: SERVICE_PAYMENT_STATUS_PAID,
            serviceTips: tipController.text.toDouble(),
          );
          showBookingCompleteDialog();
        },
      );

      await 1.seconds.delay;
      appStore.setLoading(false);

      razorPayService.razorPayCheckout();
    } else if (selectedPayment.id == PaymentMethods.PAYMENT_METHOD_STRIPE) {
      paymentMethod = PaymentMethods.PAYMENT_METHOD_STRIPE.capitalizeFirstLetter();
      appStore.setLoading(true);

        await stripeServices.init(
        totalAmount: bookingRequestStore.totalAmount,
        isTest: true,
        onComplete: (res) async {
          await savePay(
            bookingId: bookingRequestStore.bookingId.validate(),
            discountAmount: 0,
            discountPercentage: 0,
            externalTransactionId: res['transaction_id'].validate(),
            taxData: bookingRequestStore.taxPercentage.validate(),
            transactionType: PaymentMethods.PAYMENT_METHOD_FLUTTER_WAVE,
            paymentStatus: SERVICE_PAYMENT_STATUS_PAID,
            serviceTips: tipController.text.toDouble(),
          );
          showBookingCompleteDialog();
        },
      );

      await 1.seconds.delay;
      stripeServices.stripePay().then((value) {
        appStore.setLoading(false);
        //
      }).catchError((e) {
        appStore.setLoading(false);
        ShowToast.showError(e.toString());
      });
    } else if (selectedPayment.id == PaymentMethods.PAYMENT_METHOD_PAYSTACK) {
      paymentMethod = PaymentMethods.PAYMENT_METHOD_PAYSTACK.capitalizeFirstLetter();
      appStore.setLoading(true);

      await payStackServices.init(
        context: context,
        totalAmount: bookingRequestStore.totalAmount,
        onComplete: (p0) async {
          await savePay(
            bookingId: bookingRequestStore.bookingId.validate(),
            discountAmount: 0,
            discountPercentage: 0,
            externalTransactionId: p0['transaction_id'].validate(),
            taxData: bookingRequestStore.taxPercentage.validate(),
            transactionType: PaymentMethods.PAYMENT_METHOD_FLUTTER_WAVE,
            paymentStatus: SERVICE_PAYMENT_STATUS_PAID,
            serviceTips: tipController.text.toDouble(),
          );
          showBookingCompleteDialog();
        },
      );

      await 1.seconds.delay;
      appStore.setLoading(false);

      payStackServices.checkout();
    } else if (selectedPayment.id == PaymentMethods.PAYMENT_METHOD_PAYPAL) {
      paymentMethod = PaymentMethods.PAYMENT_METHOD_PAYPAL.capitalizeFirstLetter();
      appStore.setLoading(true);

      await payPalServices.init(
        context: context,
        isTest: true,
        totalAmount: bookingRequestStore.totalAmount,
        onComplete: (p0) async {
          await savePay(
            bookingId: bookingRequestStore.bookingId.validate(),
            discountAmount: 0,
            discountPercentage: 0,
            externalTransactionId: p0['transaction_id'].validate(),
            taxData: bookingRequestStore.taxPercentage.validate(),
            transactionType: PaymentMethods.PAYMENT_METHOD_FLUTTER_WAVE,
            paymentStatus: SERVICE_PAYMENT_STATUS_PAID,
            serviceTips: tipController.text.toDouble(),
          );
          showBookingCompleteDialog();
        },
      );

      await 1.seconds.delay;
      appStore.setLoading(false);

      payPalServices.paypalCheckOut();
    } else if (selectedPayment.id == PaymentMethods.PAYMENT_METHOD_FLUTTER_WAVE) {
      paymentMethod = PaymentMethods.PAYMENT_METHOD_FLUTTER_WAVE.capitalizeFirstLetter();
      appStore.setLoading(true);

      flutterWaveServices.checkout(
        flutterWavePublicKey: getStringAsync(PaymentKeys.FLUTTER_WAVE_SECRET_KEY),
        flutterWaveSecretKey: getStringAsync(PaymentKeys.FLUTTER_WAVE_PUBLIC_KEY),
        totalAmount: bookingRequestStore.totalAmount,
        isTestMode: true,
        onComplete: (p0) async {
          await savePay(
            bookingId: bookingRequestStore.bookingId.validate(),
            discountAmount: 0,
            discountPercentage: 0,
            externalTransactionId: p0['transaction_id'].validate(),
            taxData: bookingRequestStore.taxPercentage.validate(),
            transactionType: PaymentMethods.PAYMENT_METHOD_FLUTTER_WAVE,
            paymentStatus: SERVICE_PAYMENT_STATUS_PAID,
            serviceTips: tipController.text.toDouble(),
          );
          showBookingCompleteDialog();
        },
      );

      await 1.seconds.delay;
      appStore.setLoading(false);
    } else if (selectedPayment.id == PaymentMethods.AIRTEL_MONEY) {
      showInDialog(
        context,
        contentPadding: EdgeInsets.zero,
        barrierDismissible: false,
        builder: (context) {
          return AppCommonDialog(
            title: locale.airtelMoneyPayment,
            child: AirtelMoneyDialog(
              amount: bookingRequestStore.totalAmount,
              reference: APP_NAME,
              bookingId: bookingRequestStore.bookingId.validate(),
              onComplete: (res) async {
                await savePay(
                  bookingId: bookingRequestStore.bookingId.validate(),
                  discountAmount: 0,
                  discountPercentage: 0,
                  externalTransactionId: res['transaction_id'].validate(),
                  taxData: bookingRequestStore.taxPercentage.validate(),
                  transactionType: PaymentMethods.PAYMENT_METHOD_FLUTTER_WAVE,
                  paymentStatus: SERVICE_PAYMENT_STATUS_PAID,
                  serviceTips: tipController.text.toDouble(),
                );
                showBookingCompleteDialog();
              },
            ),
          );
        },
      ).then((value) => appStore.setLoading(false));
    } else if (selectedPayment.id == PaymentMethods.CINET) {
      List<String> supportedCurrencies = ["XOF", "XAF", "CDF", "GNF", "USD"];

      if (!supportedCurrencies.contains(appStore.currencyCode)) {
        ShowToast.showError(locale.ciNetPayNotSupportedMessage);
        return;
      } else if (bookingRequestStore.totalAmount < 100) {
        return ShowToast.showError('${locale.totalAmountShouldBeMoreThan} ${100.toPriceFormat()}');
      } else if (bookingRequestStore.totalAmount > 1500000) {
        return ShowToast.showError('${locale.totalAmountShouldBeLessThan} ${1500000.toPriceFormat()}');
      }

      CinetPayServicesNew ciNetPayServices = CinetPayServicesNew(
        totalAmount: bookingRequestStore.totalAmount,
        onComplete: (res) async {
          await savePay(
            bookingId: bookingRequestStore.bookingId.validate(),
            discountAmount: 0,
            discountPercentage: 0,
            externalTransactionId: res['transaction_id'].validate(),
            taxData: bookingRequestStore.taxPercentage.validate(),
            transactionType: PaymentMethods.PAYMENT_METHOD_FLUTTER_WAVE,
            paymentStatus: SERVICE_PAYMENT_STATUS_PAID,
            serviceTips: tipController.text.toDouble(),
          );
          showBookingCompleteDialog();
        },
      );

      ciNetPayServices.payWithCinetPay(context: context);
    } else if (selectedPayment.id == PaymentMethods.PAYMENT_METHOD_SADAD_PAYMENT) {
      SadadServicesNew sadadServices = SadadServicesNew(
        totalAmount: bookingRequestStore.totalAmount,
        remarks: locale.topUpWallet,
        onComplete: (res) async {
          await savePay(
            bookingId: bookingRequestStore.bookingId.validate(),
            discountAmount: 0,
            discountPercentage: 0,
            externalTransactionId: res['transaction_id'].validate(),
            taxData: bookingRequestStore.taxPercentage.validate(),
            transactionType: PaymentMethods.PAYMENT_METHOD_FLUTTER_WAVE,
            paymentStatus: SERVICE_PAYMENT_STATUS_PAID,
            serviceTips: tipController.text.toDouble(),
          );
          showBookingCompleteDialog();
        },
      );

      sadadServices.payWithSadad(context);
    } else if (selectedPayment.id == PaymentMethods.PAYMENT_METHOD_MIDTRANS) {
      MidtransService midTransService = MidtransService();
      appStore.setLoading(true);
      await midTransService.initialize(
        totalAmount: bookingRequestStore.totalAmount,
        onComplete: (res) async {
          await savePay(
            bookingId: bookingRequestStore.bookingId.validate(),
            discountAmount: 0,
            discountPercentage: 0,
            externalTransactionId: res['transaction_id'].validate(),
            taxData: bookingRequestStore.taxPercentage.validate(),
            transactionType: PaymentMethods.PAYMENT_METHOD_FLUTTER_WAVE,
            paymentStatus: SERVICE_PAYMENT_STATUS_PAID,
            serviceTips: tipController.text.toDouble(),
          );
          showBookingCompleteDialog();
        },
      );
      await Future.delayed(const Duration(seconds: 1));
      midTransService.midtransPaymentCheckout().then((value) => appStore.setLoading(false));
    } else if (selectedPayment.id == PaymentMethods.PAYMENT_METHOD_PHONEPE) {
      PhonePeServices peServices = PhonePeServices(
        totalAmount: bookingRequestStore.totalAmount,
        onComplete: (res) async {
          await savePay(
            bookingId: bookingRequestStore.bookingId.validate(),
            discountAmount: 0,
            discountPercentage: 0,
            externalTransactionId: res['transaction_id'].validate(),
            taxData: bookingRequestStore.taxPercentage.validate(),
            transactionType: PaymentMethods.PAYMENT_METHOD_FLUTTER_WAVE,
            paymentStatus: SERVICE_PAYMENT_STATUS_PAID,
            serviceTips: tipController.text.toDouble(),
          );
          showBookingCompleteDialog();
        },
      );

      peServices.phonePeCheckout(context);
    } else if (selectedPayment.id == PaymentMethods.PAYMENT_METHOD_FROM_WALLET) {
      var id = "w" + Random().nextInt(100000).toString();
      final double serviceTip = tipController.text.split('\$').last.toDouble();

      await savePay(
        transactionType: PaymentMethods.PAYMENT_METHOD_FROM_WALLET,
        paymentStatus: SERVICE_PAYMENT_STATUS_PAID,
        externalTransactionId: id,
        bookingId: bookingRequestStore.bookingId.validate(),
        discountAmount: 0,
        discountPercentage: 0,
        taxData: bookingRequestStore.taxPercentage.validate(),
        serviceTips: serviceTip,
      );
      finish(context);
      finish(context);
      showBookingCompleteDialog();
    }
  }

  void showBookingCompleteDialog() {
    CommonAppDialog.show(
      context,
      title: '${locale.paymentSuccessful}',
      subTitle: '${locale.yourPaymentIsPaidSuccessfullyMessage} $paymentMethod',
      buttonText: locale.goToBookingDetail,
      onTap: () {
        finish(context);
        finish(context, true);
      },
    );
  }

  @override
  void dispose() {
    bookingRequestStore = BookingRequestStore();
    super.dispose();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBarWidget: commonAppBarWidget(
        context,
        title: locale.pay,
        appBarHeight: 60,
        roundCornerShape: true,
        showLeadingIcon: true,
      ),
      onRetry: () {
        init();
        setState(() {});
      },
      body: Stack(
        fit: StackFit.expand,
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ViewAllLabel(label: locale.paymentMethod, isShowAll: false),
                AnimatedWrap(
                  itemCount: payments.length,
                  listAnimationType: ListAnimationType.None,
                  runSpacing: 16,
                  spacing: 16,
                  itemBuilder: (context, index) {
                    return DecoratedBox(
                      decoration: boxDecorationWithRoundedCorners(borderRadius: radius(), backgroundColor: context.cardColor),
                      child: RadioGroup<PaymentData>(
                        onChanged: (value) {
                          selectedPayment = value!;

                          if (index == 0) {
                            tipController.text = '';
                            bookingRequestStore.setTip(0);
                          }
                          setState(() {});
                        },
                        groupValue: selectedPayment,
                        child: RadioListTile(
                          value: payments[index],
                          controlAffinity: ListTileControlAffinity.trailing,
                          fillColor: WidgetStatePropertyAll(primaryColor),
                          title: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            spacing: 16,
                            children: [
                              CachedImageWidget(
                                url: payments[index].icon.validate(),
                                height: 22,
                                width: 22,
                                fit: BoxFit.contain,
                              ),
                              Text(
                                payments[index].paymentMethod.validate(),
                                style: boldTextStyle(size: 14),
                              ).expand(),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                8.height,
                Text(locale.optionalDetails, style: boldTextStyle()),
                AppTextField(
                  textFieldType: TextFieldType.NUMBER,
                  controller: tipController,
                  focus: tipFocusNode,
                  decoration: inputDecoration(context, label: locale.tip),
                  onChanged: (s) {
                    bookingRequestStore.setTip(s.toInt());
                    setState(() {});
                  },
                ).paddingTop(16),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Observer(
              builder: (_) => CommonBottomPriceWidget(
                title: bookingRequestStore.selectedServiceList.validate().map((e) => e.serviceName.validate()).toList().join(', '),
                price: bookingRequestStore.totalAmount,
                buttonText: locale.confirm,
                onTap: () {
                  doIfLoggedIn(context, () async {
                    savePayment();
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}