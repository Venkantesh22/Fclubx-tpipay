import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frezka/components/app_common_dialog.dart';
import 'package:frezka/components/cached_image_widget.dart';
import 'package:frezka/components/common_bottom_price_widget.dart';
import 'package:frezka/components/price_widget.dart';
import 'package:frezka/paymentGateways/models/payment_gateway_response.dart';
import 'package:frezka/paymentGateways/payment_repo.dart';
import 'package:frezka/paymentGateways/services/airtel_money/airtel_money_service.dart';
import 'package:frezka/paymentGateways/services/cinet_pay_services_new.dart';
import 'package:frezka/paymentGateways/services/midtrans_service.dart';
import 'package:frezka/paymentGateways/services/paypal_service.dart';
import 'package:frezka/paymentGateways/services/phone_pe/phone_pe_service.dart';
import 'package:frezka/paymentGateways/services/sadad_services_new.dart';
import 'package:frezka/paymentGateways/services/stripe_service.dart';
import 'package:frezka/screens/booking/component/confirm_booking_dialog.dart';
import 'package:frezka/screens/booking/component/package_confirm_dialog.dart';
import 'package:frezka/screens/branch/branch_repository.dart';
import 'package:frezka/screens/coupons/component/apply_coupon_component.dart';
import 'package:frezka/utils/colors.dart';
import 'package:frezka/utils/custom_toast_widget.dart';
import 'package:frezka/utils/extensions/num_extensions.dart';
import 'package:frezka/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../components/loader_widget.dart';
import '../../../configs.dart';
import '../../../main.dart';
import '../../../paymentGateways/models/payment_list_model.dart';
import '../../../paymentGateways/services/flutter_wave_service.dart';
import '../../../paymentGateways/services/paystack_service.dart';
import '../../../paymentGateways/services/razor_pay_service.dart';
import '../../../utils/common_base.dart';
import '../../../utils/constants.dart';
import '../../../utils/model_keys.dart';
import '../../dashboard/view/dashboard_screen.dart';
import '../../services/models/service_response.dart';
import '../booking_repository.dart';

class BookingStep3Component extends StatefulWidget {
  final bool isReschedule;
  final int? branchId;

  BookingStep3Component({this.isReschedule = false, this.branchId});

  @override
  _BookingStep3ComponentState createState() => _BookingStep3ComponentState();
}

class _BookingStep3ComponentState extends State<BookingStep3Component> {
  bool _isPackageListEmpty = false;
  bool _isPaymentDropdownOpen = false;
  ScrollController scrollController = ScrollController();

  TextEditingController tipController = TextEditingController();
  TextEditingController noteController = TextEditingController();

  FocusNode tipFocusNode = FocusNode();
  FocusNode noteFocusNode = FocusNode();

  List<PaymentData> payments = getPaymentList(includeCash: true);

  PaymentData? selectedPayment;

  RazorPayService razorPayService = RazorPayService();
  StripeService stripeServices = StripeService();
  PayStackService payStackServices = PayStackService();
  PayPalService payPalServices = PayPalService();
  FlutterWaveService flutterWaveServices = FlutterWaveService();
  PaymentSetting? currentPaymentMethod;

  String tempDate = '';
  String tempTime = '';

  DateTime? initialDateTime;

  @override
  void initState() {
    super.initState();
    init(); 
  }

  void init() async {
    getBranchConfiguration(
      widget.branchId ?? appStore.branchId.validate(),
      employeeId: bookingRequestStore.employeeId,
    );
    tempDate = bookingRequestStore.date.validate();
    tempTime = bookingRequestStore.time.validate();
    // Don't auto-select first payment method
    bookingRequestStore.setCouponApplied(false);
    LiveStream().on('internet_reconnected', (p0) {
      if (mounted && appStore.isLoading) {
        appStore.setLoading(false);
      }
    });
  }

  void saveBooking() {
    if (!appStore.isInternetAvailable) {
      ShowToast.showError(locale.yourInternetIsNotWorking);
      return;
    }
    if (selectedPayment == null) {
      ShowToast.showInfo(locale.pleaseSelectPaymentMethod);
      return;
    }
    appStore.setLoading(true);
    setState(() {});
    if (bookingRequestStore.bookingId == null) {
      String dateString = tempDate + " " + tempTime;

      try {
        initialDateTime = DateTime.parse(dateString);

        // Set branchId in store before sending API call
        bookingRequestStore.setBranchIdInRequest(widget.branchId ?? appStore.branchId);

        bookingRequestStore.selectedServiceList.validate().forEachIndexed((element, index) {
          if (index == 0) {
            element.startDateTime = formatDate(initialDateTime.toString(), format: DateFormatConst.NEW_FORMAT);
            element.previousTime = initialDateTime;
          } else {
            ServiceListData previousData = bookingRequestStore.selectedServiceList.validate()[index - 1];
            element.startDateTime = formatDate(
              previousData.previousTime!.add(previousData.durationMin.minutes).toString(),
              format: DateFormatConst.NEW_FORMAT,
            );
            element.previousTime = previousData.previousTime!.add(previousData.durationMin.minutes);
          }
        });

        bookingRequestStore.setNoteInRequest(noteController.text);
      } catch (e) {
        appStore.setLoading(false);
        setState(() {});
        return ShowToast.showError(e.toString());
      }

      /// Save Booking API
      saveBookingAPI(
        bookingRequestStore.toJson(
          dateTime: formatDate(initialDateTime.toString(), format: DateFormatConst.NEW_FORMAT),
          isRescheduleBooking: widget.isReschedule,
        ),
      ).then((value) async {
        appStore.setLoading(true);
        setState(() {});
        bookingRequestStore.setBookingIdInRequest(value[CommonKey.bookingId]);

        if (selectedPayment!.id == PaymentMethods.PAYMENT_METHOD_CASH) {
          savePayment(
            bookingId: bookingRequestStore.bookingId.validate(),
            isPackageReclaim: bookingRequestStore.isPackageReclaim,
          ).then((value) {
            finish(context);
            finish(context);
            showBookingCompleteDialog();
          }).catchError((e) {
            ShowToast.showError(e.toString());
          }).whenComplete(() {
            appStore.setLoading(false);
            setState(() {});
          });
        } else {
          savePayment(bookingId: bookingRequestStore.bookingId.validate());
        }
      }).catchError((e) {
        appStore.setLoading(false);
        setState(() {});
        ShowToast.showError(e.toString());
      }).whenComplete(() {
        appStore.setLoading(false);
        setState(() {});
      });
    } else {
      savePayment(bookingId: bookingRequestStore.bookingId.validate());
    }
  }

  // void _handlePackageListEmpty() {
  //   setState(() {
  //     _isPackageListEmpty = true;
  //   });
  // }

  Future<void> savePayment({required int bookingId, bool isPackageReclaim = false}) async {
    if (selectedPayment != null && selectedPayment!.id == PaymentMethods.PAYMENT_METHOD_CASH) {
      await savePay(
        bookingId: bookingId,
        externalTransactionId: '',
        transactionType: PaymentMethods.PAYMENT_METHOD_CASH,
        discountPercentage: 0,
        discountAmount: 0,
        taxData: bookingRequestStore.taxPercentage.validate(),

        /// if package is reclaimed then set the payment is paid
        paymentStatus: isPackageReclaim ? SERVICE_PAYMENT_STATUS_PAID : '0',
      );
    } else if (selectedPayment != null && selectedPayment!.id == PaymentMethods.PAYMENT_METHOD_RAZORPAY) {
      appStore.setLoading(true);
      setState(() {});
      appStore.currencyCode = 'INR';
      razorPayService.init(
        razorKey: getStringAsync(PaymentKeys.RAZORPAY_PUBLIC_KEY),
        totalAmount: bookingRequestStore.calculateTotalAmountWithCouponAndTaxAndTip,
        onComplete: (res) async {
          log(res);
          await savePay(
            transactionType: PaymentMethods.PAYMENT_METHOD_RAZORPAY,
            paymentStatus: SERVICE_PAYMENT_STATUS_PAID,
            externalTransactionId: res['transaction_id'],
            bookingId: bookingId,
            discountAmount: 0,
            discountPercentage: 0,
            taxData: bookingRequestStore.taxPercentage.validate(),
            serviceTips: tipController.text.toDouble(),
          );
          finish(context);
          finish(context);
          showBookingCompleteDialog();
        },
      );

      await 1.seconds.delay;
      appStore.setLoading(false);
      setState(() {});

      razorPayService.razorPayCheckout();
    } else if (selectedPayment != null && selectedPayment!.id == PaymentMethods.PAYMENT_METHOD_STRIPE) {
      appStore.setLoading(true);
      setState(() {});
      await stripeServices.init(
        totalAmount: bookingRequestStore.calculateTotalAmountWithCouponAndTaxAndTip,
        isTest: true,
        onComplete: (res) async {
          await savePay(
              bookingId: bookingRequestStore.bookingId.validate(),
              discountAmount: 0,
              discountPercentage: 0,
              serviceTips: tipController.text.toDouble(),
              taxData: bookingRequestStore.taxPercentage.validate(),
              externalTransactionId: res['transaction_id'],
              transactionType: PaymentMethods.PAYMENT_METHOD_STRIPE,
              paymentStatus: SERVICE_PAYMENT_STATUS_PAID);
          finish(context);
          finish(context);
          showBookingCompleteDialog();
        },
      );

      await 1.seconds.delay;
      stripeServices.stripePay().then((value) {
      }).catchError((e) {
        ShowToast.showError(e.toString());
      }).whenComplete(() {
        appStore.setLoading(false);
        setState(() {});
      });
    } else if (selectedPayment != null && selectedPayment!.id == PaymentMethods.PAYMENT_METHOD_PAYSTACK) {
      appStore.setLoading(true);
      appStore.currencyCode = 'NGN';
      await payStackServices.init(
        context: context,
        totalAmount: bookingRequestStore.calculateTotalAmountWithCouponAndTaxAndTip,
        onComplete: (p0) async {
          log(p0);
          await savePay(
              bookingId: bookingRequestStore.bookingId.validate(),
              discountAmount: 0,
              discountPercentage: 0,
              serviceTips: tipController.text.toDouble(),
              taxData: bookingRequestStore.taxPercentage.validate(),
              externalTransactionId: p0['transaction_id'],
              transactionType: PaymentMethods.PAYMENT_METHOD_PAYSTACK,
              paymentStatus: SERVICE_PAYMENT_STATUS_PAID);
          finish(context);
          finish(context);
          showBookingCompleteDialog();
        },
      );

      await 1.seconds.delay;
      appStore.setLoading(false);

      payStackServices.checkout();
    } else if (selectedPayment!.id == PaymentMethods.PAYMENT_METHOD_PAYPAL) {
      appStore.setLoading(true);

      await payPalServices.init(
        context: context,
        isTest: true,
        totalAmount: bookingRequestStore.calculateTotalAmountWithCouponAndTaxAndTip,
        onComplete: (p0) async {
          await savePay(
              bookingId: bookingRequestStore.bookingId.validate(),
              discountAmount: 0,
              discountPercentage: 0,
              serviceTips: tipController.text.toDouble(),
              taxData: bookingRequestStore.taxPercentage.validate(),
              externalTransactionId: p0['transaction_id'],
              transactionType: PaymentMethods.PAYMENT_METHOD_PAYPAL,
              paymentStatus: SERVICE_PAYMENT_STATUS_PAID);
          finish(context);
          finish(context);
          showBookingCompleteDialog();
        },
      );

      await 1.seconds.delay;
      appStore.setLoading(false);

      payPalServices.paypalCheckOut();
    } else if (selectedPayment!.id == PaymentMethods.PAYMENT_METHOD_FLUTTER_WAVE) {
      appStore.setLoading(true);

      flutterWaveServices.checkout(
        flutterWavePublicKey: getStringAsync(PaymentKeys.FLUTTER_WAVE_PUBLIC_KEY),
        flutterWaveSecretKey: getStringAsync(PaymentKeys.FLUTTER_WAVE_SECRET_KEY),
        totalAmount: bookingRequestStore.calculateTotalAmountWithCouponAndTaxAndTip,
        isTestMode: true,
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
          finish(context);
          finish(context);
          showBookingCompleteDialog();
        },
      );

      await 1.seconds.delay;
      appStore.setLoading(false);
    } else if (selectedPayment!.id == PaymentMethods.AIRTEL_MONEY) {
      showInDialog(
        context,
        contentPadding: EdgeInsets.zero,
        barrierDismissible: false,
        builder: (context) {
          return AppCommonDialog(
            title: locale.airtelMoneyPayment,
            child: AirtelMoneyDialog(
              amount: bookingRequestStore.calculateTotalAmountWithCouponAndTaxAndTip,
              reference: APP_NAME,
              bookingId: bookingRequestStore.bookingId.validate(),
              onComplete: (res) async {
                await savePay(
                  bookingId: bookingRequestStore.bookingId.validate(),
                  discountAmount: 0,
                  discountPercentage: 0,
                  externalTransactionId: res['transaction_id'].validate(),
                  taxData: bookingRequestStore.taxPercentage.validate(),
                  transactionType: PaymentMethods.AIRTEL_MONEY,
                  paymentStatus: SERVICE_PAYMENT_STATUS_PAID,
                  serviceTips: tipController.text.toDouble(),
                );
                finish(context);
                finish(context);
                showBookingCompleteDialog();
              },
            ),
          );
        },
      ).then((value) => appStore.setLoading(false));
    } else if (selectedPayment!.id == PaymentMethods.CINET) {
      List<String> supportedCurrencies = ["XOF", "XAF", "CDF", "GNF", "USD"];

      if (!supportedCurrencies.contains(appStore.currencyCode)) {
        ShowToast.showError(locale.ciNetPayNotSupportedMessage);
        return;
      } else if (bookingRequestStore.calculateTotalAmountWithCouponAndTaxAndTip < 100) {
        return ShowToast.showError('${locale.totalAmountShouldBeMoreThan} ${100.toPriceFormat()}');
      } else if (bookingRequestStore.calculateTotalAmountWithCouponAndTaxAndTip > 1500000) {
        return ShowToast.showError('${locale.totalAmountShouldBeLessThan} ${1500000.toPriceFormat()}');
      }

      CinetPayServicesNew ciNetPayServices = CinetPayServicesNew(
        totalAmount: bookingRequestStore.calculateTotalAmountWithCouponAndTaxAndTip,
        onComplete: (res) async {
          await savePay(
            bookingId: bookingRequestStore.bookingId.validate(),
            discountAmount: 0,
            discountPercentage: 0,
            externalTransactionId: res['transaction_id'].validate(),
            taxData: bookingRequestStore.taxPercentage.validate(),
            transactionType: PaymentMethods.CINET,
            paymentStatus: SERVICE_PAYMENT_STATUS_PAID,
            serviceTips: tipController.text.toDouble(),
          );
          finish(context);
          finish(context);
          showBookingCompleteDialog();
        },
      );

      if (!appStore.isInternetAvailable) {
        appStore.setLoading(false);
        ShowToast.showError(locale.yourInternetIsNotWorking);
        return;
      }
      ciNetPayServices.payWithCinetPay(context: context);
    } else if (selectedPayment!.id == PaymentMethods.PAYMENT_METHOD_SADAD_PAYMENT) {
      SadadServicesNew saDadServices = SadadServicesNew(
        totalAmount: bookingRequestStore.calculateTotalAmountWithCouponAndTaxAndTip,
        remarks: locale.topUpWallet,
        onComplete: (res) async {
          await savePay(
            bookingId: bookingRequestStore.bookingId.validate(),
            discountAmount: 0,
            discountPercentage: 0,
            externalTransactionId: res['transaction_id'].validate(),
            taxData: bookingRequestStore.taxPercentage.validate(),
            transactionType: PaymentMethods.PAYMENT_METHOD_SADAD_PAYMENT,
            paymentStatus: SERVICE_PAYMENT_STATUS_PAID,
            serviceTips: tipController.text.toDouble(),
          );
          finish(context);
          finish(context);
          showBookingCompleteDialog();
        },
      );

      saDadServices.payWithSadad(context);
    } else if (selectedPayment!.id == PaymentMethods.PAYMENT_METHOD_MIDTRANS) {
      MidtransService midTransService = MidtransService();
      appStore.setLoading(true);
      await midTransService.initialize(
        totalAmount: bookingRequestStore.calculateTotalAmountWithCouponAndTaxAndTip,
        onComplete: (res) async {
          await savePay(
            bookingId: bookingRequestStore.bookingId.validate(),
            discountAmount: 0,
            discountPercentage: 0,
            externalTransactionId: res['transaction_id'].validate(),
            taxData: bookingRequestStore.taxPercentage.validate(),
            transactionType: PaymentMethods.PAYMENT_METHOD_MIDTRANS,
            paymentStatus: SERVICE_PAYMENT_STATUS_PAID,
            serviceTips: tipController.text.toDouble(),
          );
          finish(context);
          finish(context);
          showBookingCompleteDialog();
        },
      );
      await Future.delayed(const Duration(seconds: 1));
      midTransService.midtransPaymentCheckout().then((value) => appStore.setLoading(false));
    } else if (selectedPayment!.id == PaymentMethods.PAYMENT_METHOD_PHONEPE) {
      PhonePeServices peServices = PhonePeServices(
        totalAmount: bookingRequestStore.calculateTotalAmountWithCouponAndTaxAndTip,
        onComplete: (res) async {
          await savePay(
            bookingId: bookingRequestStore.bookingId.validate(),
            discountAmount: 0,
            discountPercentage: 0,
            externalTransactionId: res['transaction_id'].validate(),
            taxData: bookingRequestStore.taxPercentage.validate(),
            transactionType: PaymentMethods.PAYMENT_METHOD_PHONEPE,
            paymentStatus: SERVICE_PAYMENT_STATUS_PAID,
            serviceTips: tipController.text.toDouble(),
          );
          finish(context, true);
          finish(context, true);
          showBookingCompleteDialog();
        },
      );

      peServices.phonePeCheckout(context);
    } else if (selectedPayment!.id == PaymentMethods.PAYMENT_METHOD_FROM_WALLET) {
      if (bookingRequestStore.totalAmount > appStore.userWalletAmount) {
        ShowToast.showError(locale.walletBalanceIsNotSufficientForThisBooking);
      } else {
        var id = "w" + Random().nextInt(10000000).toString();
        final double serviceTip = tipController.text.split('\$').last.toDouble();
        await savePay(
          transactionType: PaymentMethods.PAYMENT_METHOD_FROM_WALLET,
          paymentStatus: SERVICE_PAYMENT_STATUS_PAID,
          externalTransactionId: id,
          bookingId: bookingId,
          discountAmount: bookingRequestStore.finalDiscountCouponAmount.validate(),
          discountPercentage: bookingRequestStore.couponDiscountPercentage.validate(),
          taxData: bookingRequestStore.taxPercentage.validate(),
          serviceTips: serviceTip,
        );
        finish(context);
        finish(context);
        // showBookingCompleteDialog();
      }
    }
  }

  Future showSelectedServicesBottomSheet(BuildContext context) {
    final services = bookingRequestStore.selectedServiceList.validate();

    return showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      isScrollControlled: true,
      builder: (_) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(locale.selectedServices, style: boldTextStyle(size: 18)),
                  IconButton(
                    icon: Icon(Icons.close, color: context.iconColor),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              16.height,

              /// List of services
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: BouncingScrollPhysics(),
                  itemCount: services.length,
                  separatorBuilder: (_, __) => 12.height,
                  itemBuilder: (context, index) {
                    final service = services[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CachedImageWidget(
                        url: service.serviceImage.validate(),
                        height: 50,
                        width: 50,
                        fit: BoxFit.cover,
                        radius: 8,
                      ),
                      title: Text(
                        widget.isReschedule ? service.serviceName.validate() : service.name.validate(),
                        style: primaryTextStyle(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text('${durationToString(service.durationMin.validate())}', style: secondaryTextStyle(size: 12)),
                      trailing: PriceWidget(price: service.defaultPrice.validate()),
                    );
                  },
                ),
              ),

              20.height,
            ],
          ),
        );
      },
    );
  }

  void showBookingCompleteDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (BuildContext context) => Container(
        margin: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        width: context.width(),
        constraints: BoxConstraints(maxHeight: context.height() * 0.6),
        decoration: boxDecorationWithRoundedCorners(
          backgroundColor: context.cardColor,
          borderRadius: radius(20),
        ),
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CachedImageWidget(url: ic_confirm_order_check, height: 72, width: 72),
              24.height,
              Text(locale.bookingSuccessful, style: boldTextStyle(size: 20), textAlign: TextAlign.center),
              16.height,
              Text(
                locale.thankYouForChoosingOurService,
                style: secondaryTextStyle(size: 14),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              32.height,
              // Done Button
              Container(
                width: 178,
                height: 40,
                decoration: BoxDecoration(color: context.primaryColor, borderRadius: BorderRadius.circular(4)),
                child: TextButton(
                  onPressed: () {
                    finish(context);
                    DashboardScreen(pageIndex: 1).launch(context, isNewTask: true);
                  },
                  child: Text(locale.done, style: boldTextStyle(size: 14, color: white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    LiveStream().dispose('internet_reconnected');
    bookingRequestStore.setCouponApplied(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          SingleChildScrollView(
            controller: scrollController,
            padding: EdgeInsets.only(left: 20, right: 20, top: 60, bottom: 200),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                8.height,

                // ///Select Package
                // if (bookingRequestStore.isPackagePurchase && !bookingRequestStore.isPackageReclaim) SelectPackageComponents(onPackageListEmpty: _handlePackageListEmpty).paddingBottom(16),

                // /// Your reclaimed Package component
                // if (bookingRequestStore.isPackagePurchase && bookingRequestStore.isPackageReclaim) YourPackageComponent(),

                /// Apply coupon component
                if (!bookingRequestStore.isPackageReclaim)
                  ApplyCouponComponent(
                    callback: () => setState(() {}),
                  ),
                32.height,
                if (!bookingRequestStore.isPackageReclaim)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(locale.payment, style: boldTextStyle(size: 16)),
                      16.height,
                      // Payment Method Dropdown
                      Container(
                        decoration: boxDecorationWithRoundedCorners(
                          backgroundColor: context.cardColor,
                          borderRadius: radius(8),
                        ),
                        child: Column(
                          children: [
                            Theme(
                              data: Theme.of(context).copyWith(dividerColor: transparentColor),
                              child: Container(
                                decoration: boxDecorationWithRoundedCorners(
                                  backgroundColor: context.cardColor,
                                  borderRadius: radius(8),
                                  border: Border.all(color: borderColor.withAlpha(125), width: 0.5),
                                ),
                                child: ClipRRect(
                                  borderRadius: radius(6),
                                  child: ExpansionTile(
                                    splashColor: Colors.transparent,
                                    tilePadding: EdgeInsets.symmetric(horizontal: 16),
                                    childrenPadding: EdgeInsets.zero,
                                    expandedCrossAxisAlignment: CrossAxisAlignment.start,
                                    expandedAlignment: Alignment.topLeft,
                                    onExpansionChanged: (expanded) {
                                      setState(() {
                                        _isPaymentDropdownOpen = expanded;
                                      });
                                    },
                                    title: Text(
                                      selectedPayment?.paymentMethod.validate() ?? locale.selectPaymentMethod,
                                      style: selectedPayment == null ? secondaryTextStyle() : primaryTextStyle(),
                                    ),
                                    trailing: AnimatedRotation(
                                      turns: _isPaymentDropdownOpen ? 0.5 : 0,
                                      duration: Duration(milliseconds: 200),
                                      child: Icon(Icons.keyboard_arrow_down, color: borderColor.withAlpha(200), size: 24),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                  if(_isPaymentDropdownOpen)...[
                    8.height,
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      decoration: boxDecorationWithRoundedCorners(
                        backgroundColor: context.cardColor,
                        borderRadius: radius(6),
                        border: Border.all(color: borderColor.withAlpha(125), width: 0.5),
                      ),
                      child: Column(
                        children: payments.map((payment) {
                          final isWallet = payment.id.validate() == PaymentMethods.PAYMENT_METHOD_FROM_WALLET;
                          final isDisabled = isWallet && appStore.userWalletAmount < bookingRequestStore.calculateTotalAmountWithCouponAndTaxAndTip;
                          final isSel = selectedPayment?.id == payment.id;

                          return InkWell(
                            onTap: () {
                              if (isDisabled) {
                                ShowToast.showError(locale.walletBalanceIsNotSufficientForThisPayment);
                              } else {
                                selectedPayment = payment;
                                if (payment.id == PaymentMethods.PAYMENT_METHOD_CASH) {
                                  tipController.text = '';
                                  bookingRequestStore.setTip(0);
                                }
                              }
                              setState(() {});
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                              child: Row(
                                children: [
                                  CachedImageWidget(url: payment.icon.validate(), height: 28, width: 28, fit: BoxFit.contain),
                                  16.width,
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          payment.paymentMethod.validate(),
                                          style: boldTextStyle(size: 14, color: isDisabled ? context.iconColor.withValues(alpha: 0.4) : null),
                                        ),
                                        if (isWallet) 4.height,
                                        if (isWallet)
                                          Text(
                                            "(${leftCurrencyFormat()}${appStore.userWalletAmount.toStringAsFixed(2)}${rightCurrencyFormat()})",
                                            style: secondaryTextStyle(size: 12, color: context.iconColor),
                                          ),
                                      ],
                                    ),
                                  ),
                                  // Custom radio button
                                  Container(
                                    width: 18,
                                    height: 18,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isSel ? context.primaryColor : context.iconColor.withValues(alpha: 0.3),
                                        width: 2,
                                      ),
                                    ),
                                    child: isSel
                                        ? Center(
                                            child: Container(
                                              width: 9,
                                              height: 9,
                                              decoration: BoxDecoration(shape: BoxShape.circle, color: context.primaryColor),
                                            ),
                                          )
                                        : null,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],                  
                8.height,
                Text(locale.optionalDetails, style: boldTextStyle()),
                if (selectedPayment != null && selectedPayment!.id != PaymentMethods.PAYMENT_METHOD_CASH)
                  AppTextField(
                    textFieldType: TextFieldType.NUMBER,
                    controller: tipController,
                    focus: tipFocusNode,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly, // Only allow numbers
                    ],
                    nextFocus: noteFocusNode,
                    decoration: inputDecoration(context, label: locale.tip),
                    onChanged: (s) {
                      int tipAmount = int.tryParse(s) ?? 0;
                      bookingRequestStore.setTip(tipAmount);
                      setState(() {
                        tipController.text = tipAmount > 0 ? "${leftCurrencyFormat()}${tipAmount.toString()}" : '';
                        tipController.selection = TextSelection.fromPosition(TextPosition(offset: tipController.text.length));
                      });
                      scrollController.animToBottom();
                    },
                    onTap: () {
                      scrollController.animToBottom();
                    },
                  ).paddingTop(16),
                16.height,
                AppTextField(
                  textFieldType: TextFieldType.MULTILINE,
                  controller: noteController,
                  focus: noteFocusNode,
                  minLines: 3,
                  maxLines: 4,
                  decoration: inputDecoration(context, label: locale.note),
                  onTap: () {
                    scrollController.animToBottom();
                  },
                  onChanged: (s) {
                    scrollController.animToBottom();
                  },
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Observer(
              builder: (_) => CommonBottomPriceWidget(
                title: bookingRequestStore.selectedServiceList.validate().map((e) => widget.isReschedule ? e.serviceName.validate() : e.name.validate()).toList().join(', '),
                price: bookingRequestStore.totalAmount,
                buttonText: locale.confirm,
                onTap: () {
                  doIfLoggedIn(context, () async {
                    if (bookingRequestStore.isPackagePurchase) {
                      bool? res = await showInDialog(
                        context,
                        backgroundColor: context.scaffoldBackgroundColor,
                        builder: (context) => PackageConfirmDialog(
                          expiryDate: bookingRequestStore.selectedPackageList.first.endDate.validate(),
                          packageName: bookingRequestStore.selectedPackageList.first.name.validate(),
                        ),
                      );

                      if (res ?? false) {
                        saveBooking();
                      }
                    } else {
                      if (selectedPayment == null) {
                        ShowToast.showInfo(locale.pleaseSelectPaymentMethod);
                        return;
                      }

                      bool? res = await showModalBottomSheet<bool>(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        useSafeArea: true,
                        builder: (context) => Container(padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8), child: ConfirmBookingDialog()),
                      );

                      if (res ?? false) {
                        saveBooking();
                      }
                    }
                  });
                },
              ),
            ).visible(!_isPackageListEmpty),
          ),
          if (appStore.isLoading)
            Positioned.fill(
              child: AbsorbPointer(
                absorbing: true,
                child: Container(
                  color: Colors.transparent,
                ),
              ),
            ),
          LoaderWidget().visible(appStore.isLoading),
        ],
      ),
    );
  }
}
