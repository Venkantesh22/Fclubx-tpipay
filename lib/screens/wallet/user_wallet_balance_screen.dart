// ignore_for_file: must_be_immutable

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frezka/components/cached_image_widget.dart';
import 'package:frezka/generated/assets.dart';
import 'package:frezka/paymentGateways/models/payment_list_model.dart';
import 'package:frezka/paymentGateways/services/flutter_wave_service.dart';
import 'package:frezka/paymentGateways/services/razor_pay_service.dart';
import 'package:frezka/utils/colors.dart';
import 'package:frezka/utils/custom_toast_widget.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../components/app_scaffold.dart';
import '../../components/price_widget.dart';
import '../../main.dart';
import '../../network/rest_apis.dart';
import '../../paymentGateways/models/payment_gateway_response.dart';
import '../../paymentGateways/services/stripe_service.dart';
import '../../utils/app_common.dart';
import '../../utils/constants.dart';
import '../../utils/images.dart';

class UserWalletBalanceScreen extends StatefulWidget {
  bool isBackScreen;

  UserWalletBalanceScreen({Key? key, this.isBackScreen = false})
      : super(key: key);

  @override
  State<UserWalletBalanceScreen> createState() =>
      _UserWalletBalanceScreenState();
}

class _UserWalletBalanceScreenState extends State<UserWalletBalanceScreen> {
  Future<List<PaymentSetting>>? future;
  TextEditingController tipController = TextEditingController();
  TextEditingController walletAmountCont = TextEditingController(text: '0');
  FocusNode walletAmountFocus = FocusNode();

  List<int> defaultAmounts = [150, 200, 500, 1000, 5000, 10000];
  PaymentSetting? currentPaymentMethod;

  List<PaymentData> payments =
      getPaymentList(includeWallet: false, includeCash: false);
  PaymentData selectedPayment = PaymentData();
  RazorPayService razorPayService = RazorPayService();
  StripeService stripeServices = StripeService();
  FlutterWaveService flutterWaveServices = FlutterWaveService();

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    appStore.setUserWalletAmount();
    await refreshPaymentList();
  }

  Future<void> refreshPaymentList() async {
    try {
      payments = getPaymentList(includeWallet: false, includeCash: false);
      if (payments.isNotEmpty) {
        selectedPayment = payments.first;
      }
      setState(() {});
    } catch (e) {
      log('Error refreshing payment list: $e');
    }
  }

  void _handleClick() async {
    log("${walletAmountCont.text}");
    if (payments.isEmpty) {
      return ShowToast.showInfo(locale.noPaymentMethodsAvailable);
    } else if (walletAmountCont.text.toDouble() == 0) {
      return ShowToast.showInfo(locale.pleaseEnterAmount);
    } else if (selectedPayment.paymentMethod == null) {
      return ShowToast.showInfo(locale.pleaseSelectPaymentMethod);
    }
    try {
      if (selectedPayment.id! == PaymentMethods.PAYMENT_METHOD_STRIPE) {
        appStore.setLoading(true);
        await stripeServices.init(
          totalAmount: walletAmountCont.text.toDouble(),
          isTest: true,
          onComplete: (res) async {
            Map req = {
              "amount": walletAmountCont.text.toDouble(),
              "transaction_type": PaymentMethods.PAYMENT_METHOD_STRIPE,
              "transaction_id": res['transaction_id'],
            };
            await walletTopUpApi(request: req);
            walletAmountCont.text = "0";
          },
        );

        await 1.seconds.delay;
        await stripeServices.stripePay().then((value) {
          appStore.setLoading(false);
        }).catchError((e) {
          appStore.setLoading(false);
          ShowToast.showError(e.toString());
        });
      } else if (selectedPayment.id! ==
          PaymentMethods.PAYMENT_METHOD_RAZORPAY) {
        appStore.setLoading(true);
        appStore.currencyCode = 'INR';
        razorPayService.init(
          razorKey: getStringAsync(PaymentKeys.RAZORPAY_PUBLIC_KEY),
          totalAmount: walletAmountCont.text.toDouble(),
          onComplete: (res) async {
            log(res);
            Map req = {
              "amount": walletAmountCont.text.toDouble(),
              "transaction_type": PaymentMethods.PAYMENT_METHOD_RAZORPAY,
              "transaction_id": res['transaction_id']
            };
            await walletTopUpApi(request: req);
            walletAmountCont.text = "0";
          },
        );

        await 1.seconds.delay;
        appStore.setLoading(false);

        razorPayService.razorPayCheckout();
      } else if (selectedPayment.id! ==
          PaymentMethods.PAYMENT_METHOD_FLUTTER_WAVE) {
        appStore.setLoading(true);

        flutterWaveServices.checkout(
          flutterWavePublicKey:
              getStringAsync(PaymentKeys.FLUTTER_WAVE_PUBLIC_KEY),
          flutterWaveSecretKey:
              getStringAsync(PaymentKeys.FLUTTER_WAVE_SECRET_KEY),
          totalAmount: walletAmountCont.text.toDouble(),
          isTestMode: true,
          onComplete: (res) async {
            Map req = {
              "amount": walletAmountCont.text.toDouble(),
              "transaction_type": PaymentMethods.PAYMENT_METHOD_FLUTTER_WAVE,
              "transaction_id": res['transaction_id']
            };
            await walletTopUpApi(request: req);
            walletAmountCont.text = "0";
          },
        );

        await 1.seconds.delay;
        appStore.setLoading(false);
      } else if (selectedPayment.paymentMethod! == locale.PAYMENT_METHOD_CASH) {
        var id = "C" + Random().nextInt(100000).toString();
        Map req = {
          "amount": walletAmountCont.text.toDouble(),
          "transaction_type": PaymentMethods.PAYMENT_METHOD_CASH,
          "transaction_id": id
        };
        await walletTopUpApi(request: req);
        walletAmountCont.text = "0";
      }
    } catch (e) {
      log('Error processing payment: $e');
    } finally {
      appStore.setLoading(false);
    }
  }

  String getPaymentMethodIcon(String value) {
    if (value == PaymentMethods.PAYMENT_METHOD_STRIPE) {
      return stripe_logo;
    } else if (value == PaymentMethods.PAYMENT_METHOD_RAZORPAY) {
      return razorpay_logo;
    } else if (value == PaymentMethods.CINET) {
      // return cinetpay_logo;
    } else if (value == PaymentMethods.PAYMENT_METHOD_FLUTTER_WAVE) {
      return flutter_wave_logo;
    } else if (value == PaymentMethods.PAYMENT_METHOD_SADAD_PAYMENT) {
      return "";
    } else if (value == PaymentMethods.PAYMENT_METHOD_PAYPAL) {
      return paypal_logo;
    } else if (value == PaymentMethods.AIRTEL_MONEY) {
      // return airtel_logo;
    } else if (value == PaymentMethods.PAYMENT_METHOD_PAYSTACK) {
      return paystack_logo;
    } else if (value == PaymentMethods.PAYMENT_METHOD_PHONEPE) {
      // return phonepe_logo;
    }

    return '';
  }

  walletTopUpApi({required Map request}) {
    walletTopUp(request).then((value) {
      if (!mounted) return;
      if (widget.isBackScreen) {
        finish(context, true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBarWidget: commonAppBarWidget(
        context,
        title: locale.topUp,
        appBarHeight: 70,
        roundCornerShape: true,
        showLeadingIcon: true,
      ),
      body: Stack(
        children: [
          AnimatedScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            listAnimationType: ListAnimationType.None,
            onSwipeRefresh: () async {
              await appStore.setUserWalletAmount();
              await refreshPaymentList();
              walletAmountCont.text = "0"; // reset amount
              setState(() {}); // rebuild
            },
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  12.height,
                  Container(
                    width: context.width(),
                    height: 115,
                    padding: EdgeInsets.all(16),
                    decoration: boxDecorationWithRoundedCorners(
                      backgroundColor: appStore.isDarkMode
                          ? darkSecondaryColor
                          : territoryButtonColor,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                          color: appStore.isDarkMode
                              ? dividerDarkColor
                              : indicatorColor,
                          width: 1),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(locale.availableBalance,
                                      style: secondaryTextStyle(size: 14)),
                                ],
                              ),
                              Observer(builder: (context) {
                                return PriceWidget(
                                    price: appStore.userWalletAmount,
                                    size: 32,
                                    isBoldText: true,
                                    color: appStore.isDarkMode
                                        ? Colors.white
                                        : black);
                              }),
                            ],
                          ),
                        ),
                        //  Image.asset(Assets.iconsIcDollar, height: 32, width: 32)
                      ],
                    ),
                  ).paddingSymmetric(horizontal: 12),
                  12.height,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 16),
                        padding: EdgeInsets.only(
                            left: 16, right: 16, top: 0, bottom: 16),
                        decoration: boxDecorationWithRoundedCorners(
                          backgroundColor: context.cardColor,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: borderColor, width: 0.5),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            16.height,
                            Text(locale.lblEnterAmount,
                                style: boldTextStyle(size: LABEL_TEXT_SIZE)),
                            8.height,
                            Text(locale.topUpAmountQuestion,
                                style: secondaryTextStyle(size: 12)),
                            AppTextField(
                              textFieldType: TextFieldType.NUMBER,
                              controller: walletAmountCont,
                              focus: walletAmountFocus,
                              textStyle: primaryTextStyle(
                                  size: 24, weight: FontWeight.w600),
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              onTap: () {
                                if (walletAmountCont.text == '0') {
                                  walletAmountCont.selection = TextSelection(
                                      baseOffset: 0,
                                      extentOffset:
                                          walletAmountCont.text.length);
                                }
                              },
                              decoration: InputDecoration(
                                prefixText: isCurrencyPositionLeft
                                    ? appStore.currencySymbol
                                    : '',
                                prefixStyle: boldTextStyle(size: 25),
                                suffixText: isCurrencyPositionRight
                                    ? appStore.currencySymbol
                                    : '',
                                suffixStyle: boldTextStyle(size: 25),
                              ),
                              onChanged: (p0) {
                                //
                              },
                            ),
                            15.height,
                            Wrap(
                              spacing: 16,
                              runSpacing: 16,
                              alignment: WrapAlignment.start,
                              children:
                                  List.generate(defaultAmounts.length, (index) {
                                return Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 6, horizontal: 12),
                                  decoration: boxDecorationDefault(
                                    color: defaultAmounts[index].toString() ==
                                            walletAmountCont.text
                                        ? primaryColor
                                        : (appStore.isDarkMode
                                            ? scaffoldSecondaryDark
                                            : primaryLightColor),
                                    borderRadius: radius(6),
                                    border: Border.all(
                                        color:
                                            defaultAmounts[index].toString() ==
                                                    walletAmountCont.text
                                                ? context.primaryColor
                                                : lavenderColor),
                                  ),
                                  child: PriceWidget(
                                    price: defaultAmounts[index],
                                    size: 14,
                                    isBoldText: false,
                                    decimalPoint: 0,
                                    color: defaultAmounts[index] ==
                                            walletAmountCont.text.toDouble()
                                        ? white
                                        : (appStore.isDarkMode
                                            ? Colors.white
                                            : black),
                                  ),
                                ).onTap(() {
                                  walletAmountCont.text =
                                      "${defaultAmounts[index]}";
                                  setState(() {});
                                });
                              }),
                            ),
                          ],
                        ),
                      ),
                      10.height,
                      Container(
                        width: context.width(),
                        padding: EdgeInsets.all(16),
                        decoration: boxDecorationWithRoundedCorners(
                          backgroundColor: context.cardColor,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: borderColor, width: 0.5),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 0,
                          children: [
                            Text(locale.paymentMethod,
                                style: boldTextStyle(
                                    size: LABEL_TEXT_SIZE,
                                    weight: FontWeight.w600,
                                    color: appStore.isDarkMode
                                        ? Colors.white
                                        : black)),
                            4.height,
                            Text(locale.selectYourPaymentMethodToAddBalance,
                                style: secondaryTextStyle(
                                    size: 12, weight: FontWeight.w400)),
                            16.height,
                            AnimatedWrap(
                              listAnimationType: ListAnimationType.None,
                              itemCount: payments.length,
                              runSpacing: 10,
                              spacing: 16,
                              itemBuilder: (context, index) {
                                if (payments[index]
                                        .paymentMethod
                                        ?.toLowerCase() ==
                                    PaymentMethods.PAYMENT_METHOD_CASH) {
                                  return Offstage();
                                }
                                return Container(
                                  decoration: boxDecorationWithRoundedCorners(
                                    borderRadius: BorderRadius.circular(6),
                                    backgroundColor: appStore.isDarkMode
                                        ? scaffoldSecondaryDark
                                        : scaffoldPrimaryLight,
                                    border: Border.all(
                                        color: borderColor, width: 0.5),
                                  ),
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
                                      visualDensity: VisualDensity.compact,
                                      fillColor: WidgetStatePropertyAll(
                                          selectedPayment == payments[index]
                                              ? primaryColor
                                              : borderColor),
                                      value: payments[index],
                                      controlAffinity:
                                          ListTileControlAffinity.trailing,
                                      contentPadding:
                                          EdgeInsets.only(left: 8, right: 4),
                                      title: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: 32,
                                            height: 32,
                                            child: Center(
                                              child: CachedImageWidget(
                                                url: payments[index]
                                                    .icon
                                                    .validate(),
                                                height: 20,
                                                width: 20,
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                          ),
                                          12.width,
                                          Text(
                                            payments[index]
                                                .paymentMethod
                                                .validate(),
                                            style: boldTextStyle(
                                                size: 14,
                                                weight: FontWeight.w600),
                                          ).expand(),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      100.height,
                    ],
                  ).paddingSymmetric(horizontal: 16),
                ],
              ),
            ],
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: AppButton(
              width: context.width(),
              height: 16,
              color: context.primaryColor,
              text: locale.proceed,
              textStyle: boldTextStyle(color: white),
              onTap: () async {
                hideKeyboard(context);
                _handleClick();
              },
            ),
          ),
        ],
      ),
    );
  }
}
