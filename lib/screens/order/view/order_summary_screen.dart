import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frezka/components/app_scaffold.dart';
import 'package:frezka/components/common_product_bottom_price_widget.dart';
import 'package:frezka/configs.dart';
import 'package:frezka/generated/assets.dart';
import 'package:frezka/main.dart';
import 'package:frezka/utils/custom_toast_widget.dart';
import 'package:frezka/utils/extensions/string_extensions.dart';
import 'package:frezka/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../components/cached_image_widget.dart';
import '../../../components/common_bottom_sheet.dart';
import '../../../components/price_widget.dart';
import '../../../paymentGateways/models/payment_list_model.dart';
import '../../../utils/app_common.dart';
import '../../../utils/colors.dart';
import '../../../utils/common_base.dart';
import '../../../utils/constants.dart';
import '../../cart/model/cart_list_response.dart';
import '../../cart/view/select_address_screen.dart';
import '../../dashboard/view/dashboard_screen.dart';
import '../../order/orderPaymentGateways/order_flutter_wave_service.dart';
import '../../order/orderPaymentGateways/order_paypal_service.dart';
import '../../order/orderPaymentGateways/order_paystack_service.dart';
import '../../order/orderPaymentGateways/order_razor_pay_service.dart';
import '../../order/orderPaymentGateways/order_stripe_service.dart';
import '../../order/order_repository.dart';

class OrderSummaryScreen extends StatefulWidget {
  @override
  _OrderSummaryScreenState createState() => _OrderSummaryScreenState();
}

class _OrderSummaryScreenState extends State<OrderSummaryScreen> {
  List<PaymentData> payments = getPaymentList();
  late PaymentData selectedPayment;

  OrderRazorPayService razorPayService = OrderRazorPayService();
  OrderStripeService stripeServices = OrderStripeService();
  OrderPayStackService paystackServices = OrderPayStackService();
  OrderPayPalService payPalServices = OrderPayPalService();
  OrderFlutterWaveService flutterWaveServices = OrderFlutterWaveService();
  late TapGestureRecognizer _termsRecognizer;
  late TapGestureRecognizer _privacyRecognizer;

  @override
  void initState() {
    super.initState();
    if (payments.isNotEmpty) {
      selectedPayment = payments.first;
    }
    _termsRecognizer = TapGestureRecognizer()..onTap = _openTerms;
    _privacyRecognizer = TapGestureRecognizer()..onTap = _openPrivacy;
  }

  void _openTerms() async {
    commonLaunchUrl(TERMS_CONDITION_URL, launchMode: LaunchMode.externalApplication);
  }

  void _openPrivacy() async {
    // Use a privacy policy URL if defined, otherwise fall back to terms URL
    final url = (PRIVACY_POLICY_URL.isNotEmpty) ? PRIVACY_POLICY_URL : TERMS_CONDITION_URL;
    commonLaunchUrl(url, launchMode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBarWidget: commonAppBarWidget(context, title: locale.orderSummary, appBarHeight: 70, showLeadingIcon: true, roundCornerShape: true),
      body: Stack(
        children: [
          AnimatedScrollView(
            padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 80),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    locale.deliveryAddress,
                    style: boldTextStyle(size: 14),
                  ),
                  TextButton(
                    onPressed: () {
                      SelectAddressScreen().launch(context, pageRouteAnimation: PageRouteAnimation.Fade);
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      foregroundColor: Colors.transparent,
                    ),
                    child: Text(
                      locale.change,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        shadows: [Shadow(color: context.primaryColor, offset: Offset(0, -2))],
                        color: Colors.transparent,
                        decoration: TextDecoration.underline,
                        decorationColor: context.primaryColor,
                        decorationThickness: 1,
                        decorationStyle: TextDecorationStyle.solid,
                      ),
                    ),
                  ),
                ],
              ),
              12.height,
              Container(
                width: context.width(),
                decoration: boxDecorationDefault(color: context.cardColor, borderRadius: radius(4), border: Border.all(color: lightBorderColor, width: 0.5)),
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with "Delivered To" and "Change" button

                    12.height,

                    // Address Card Content
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Profile Picture
                        Container(
                          width: 40,
                          height: 40,
                          child: ClipRRect(
                            borderRadius: radius(20),
                            child: CachedImageWidget(
                              url: userStore.userProfileImage.validate(),
                              height: 40,
                              width: 40,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        12.width,

                        // Address Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Full Address (conditionally build so separators don't appear for empty parts)
                              Text(
                                (() {
                                  final a = productStore.addressData;
                                  final parts = <String>[];
                                  final line1 = a.addressLine1.validate().trim();
                                  final line2 = a.addressLine2.validate().trim();
                                  final city = a.cityName.validate().trim();
                                  final postal = a.postalCode.validate().trim();
                                  final state = a.stateName.validate().trim();
                                  final country = a.countryName.validate().trim();

                                  if (line1.isNotEmpty) parts.add(line1);
                                  if (line2.isNotEmpty) parts.add(line2);

                                  if (city.isNotEmpty && postal.isNotEmpty) {
                                    parts.add('$city - $postal');
                                  } else if (city.isNotEmpty) {
                                    parts.add(city);
                                  } else if (postal.isNotEmpty) {
                                    parts.add(postal);
                                  }

                                  if (state.isNotEmpty) parts.add(state);
                                  if (country.isNotEmpty) parts.add(country);

                                  return parts.join(', ');
                                })(),
                                style: secondaryTextStyle(size: 13),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                              6.height,

                              // Phone Number
                              Text(
                                productStore.addressData.contactNumber.validate().trim(),
                                style: secondaryTextStyle(size: 13),
                              ),
                              // Alternate contact number if available
                              if (productStore.alternateContactNumber.validate().isNotEmpty) ...[
                                4.height,
                                Text(
                                  productStore.alternateContactNumber.validate().trim(),
                                  style: secondaryTextStyle(size: 13),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              16.height,
              // Items In Cart Header
              Text(
                locale.itemsInCart,
                style: boldTextStyle(size: 14),
              ),
              12.height,

              AnimatedWrap(
                runSpacing: 16,
                itemCount: productStore.productCartListData.length,
                listAnimationType: ListAnimationType.None,
                itemBuilder: (context, index) {
                  CartListData productData = productStore.productCartListData.validate()[index];

                  return Container(
                    decoration: boxDecorationDefault(color: context.cardColor, borderRadius: radius(4), border: Border.all(color: borderColor, width: 0.5)),
                    padding: EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Product Image
                        CachedImageWidget(
                          url: productData.productImage.validate(),
                          height: 60,
                          width: 60,
                          fit: BoxFit.cover,
                          radius: defaultRadius,
                        ),
                        12.width,

                        // Product Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Product Name
                              Text(
                                productData.productName.validate(),
                                style: boldTextStyle(size: 16),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              5.height,
                              // Quantity
                              Row(
                                children: [
                                  Text(locale.quantity, style: secondaryTextStyle(size: 13)),
                                  4.width,
                                  Text(
                                    productData.qty.validate().toString().padLeft(2, '0'),
                                    style: boldTextStyle(size: 13),
                                  ),
                                ],
                              ),
                              4.height,
                              if (productData.productVariationType.validate().isNotEmpty)...[
                                Row(
                                  children: [
                                    Text(
                                      '${productData.productVariationType.validate()}: ',
                                      style: secondaryTextStyle(size: 13),
                                    ),
                                    Text(
                                      productData.productVariationName.validate(),
                                      style: primaryTextStyle(size: 13),
                                    ),
                                  ],
                                ),
                                4.height,
                              ],
                              if (productData.productVariation != null)...[
                                Marquee(
                                  child: Row(
                                    children: [
                                      PriceWidget(
                                        price: productData.productVariation!.discountedProductPrice.validate(),
                                        color: primaryColor,
                                        size: 14,
                                        isBoldText: true,
                                      ),
                                      if (productData.isDiscount) ...[
                                        4.width,
                                        PriceWidget(
                                          price: productData.productVariation!.taxIncludeProductPrice.validate(),
                                          isLineThroughEnabled: true,
                                          size: 12,
                                          color: textSecondaryColorGlobal,
                                        ),
                                        3.width,
                                        Text(
                                          productData.discountType == 'percent' ?  '(${productData.discountValue.validate()}% ${locale.off.toUpperCase()})': '(${leftCurrencyFormat()}${(productData.productVariation!.taxIncludeProductPrice.validate() - (productData.productVariation!.discountedProductPrice.validate().toDouble())).toStringAsFixed(getIntAsync(ConfigurationKeyConst.NO_OF_DECIMAL, defaultValue: DECIMAL_POINT).toInt())}${rightCurrencyFormat()} ${locale.off.toUpperCase()})',
                                          style: primaryTextStyle(color: greenColor, size: 12)
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                5.height,
                              ],
                              // Shipping and Tax Info
                              Observer(
                                builder: (context) {
                                  final isFreeShipping = productStore.logisticZoneData.standardDeliveryCharge == 0;
                                  final hasNoTax = productStore.cartPriceData.taxAmount.validate() == 0;

                                  String statusText = '';
                                  if (isFreeShipping && hasNoTax) {
                                    statusText = locale.freeShippingNoTaxApplied;
                                  } else if (isFreeShipping) {
                                    statusText = locale.freeShipping;
                                  } else if (hasNoTax) {
                                    statusText = locale.noTaxApplied;
                                  }

                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (statusText.isNotEmpty) ...[
                                        Text(
                                          statusText,
                                          style: primaryTextStyle(color: greenColor, size: 12),
                                        ),
                                      ],
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              16.height,

              // Choose Payment Section - Matching Image Design
              Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Text(locale.choosePayment, style: boldTextStyle(size: 14)),
                    16.height,

                    // Select Method Dropdown
                    // Container(
                    //   decoration: boxDecorationDefault(color: context.cardColor, borderRadius: radius(4), border: Border.all(color: borderColor, width: 0.5)),
                    //   padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    //   child: Row(
                    //     children: [
                    //       Text(
                    //         locale.selectMethod,
                    //         style: secondaryTextStyle(size: 14),
                    //       ),
                    //     ], 
                    //   ),
                    // ),
                    // 10.height,

                    // Payment Methods List
                    ...payments.asMap().entries.map((entry) {
                      final index = entry.key;
                      final payment = entry.value;
                      final isWallet = payment.id.validate() == PaymentMethods.PAYMENT_METHOD_FROM_WALLET;
                      final isDisabled = isWallet && appStore.userWalletAmount < productStore.totalAmount;

                      return Container(
                        margin: EdgeInsets.only(bottom: index < payments.length - 1 ? 4 : 0),
                        decoration: boxDecorationDefault(color: context.cardColor, borderRadius: radius(4), border: Border.all(color: borderColor, width: 0.5)),
                        child: DecoratedBox(
                          decoration: boxDecorationWithRoundedCorners(borderRadius: radius(), backgroundColor: context.cardColor),
                          child: RadioGroup<PaymentData>(
                            groupValue: selectedPayment,
                            onChanged: (value) {
                              if (isDisabled) {
                                ShowToast.showInfo(locale.walletBalanceIsNotSufficientForThisPayment);
                              } else {
                                selectedPayment = payment;
                                setState(() {});
                              }
                            },
                            child: RadioListTile(
                              value: payment,
                              controlAffinity: ListTileControlAffinity.trailing,
                              fillColor: WidgetStatePropertyAll(primaryColor),
                              title: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                spacing: 16,
                                children: [
                                  CachedImageWidget(
                                    url: payment.icon.validate(),
                                    height: 22,
                                    width: 22,
                                    fit: BoxFit.contain,
                                  ),
                                  Text(
                                    isWallet ? "${payment.paymentMethod.validate()} (${appStore.currencySymbol}${appStore.userWalletAmount})" : payment.paymentMethod.validate(),
                                    style: boldTextStyle(size: 14).copyWith(
                                      color: isDisabled ? (appStore.isDarkMode ? Colors.white38 : Colors.black38) : (appStore.isDarkMode ? Colors.white : Colors.black),
                                    ),
                                  ).expand(),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                    16.height,
                  ],
                ),
              ),
              16.height,
            ],
          ),
          if (productStore.productCartListData.isNotEmpty && productStore.addressData.id != null && productStore.addressData.id != 0) ...[
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Observer(
                builder: (context) => CommonProductBottomPriceWidget(
                  title: productStore.productCartListData.map((item) => item.productName).toList().join(', '),
                  price: productStore.totalAmount,
                  buttonText: locale.placeOrder,
                  cartListData: productStore.productCartListData,
                  cartPriceData: productStore.cartPriceData,
                  onTap: () {
                    final List<CartListData> items = productStore.productCartListData;
                    productStore.setCartListData(items);

                    final num subtotal = productStore.cartPriceData.taxIncludedAmount.validate();
                    final num tax = productStore.cartPriceData.taxAmount.validate();

                    CartTaxData? originalTaxData = productStore.cartPriceData.taxData;

                    productStore.setCartPriceData(CartPriceData(
                      taxIncludedAmount: subtotal,
                      taxAmount: tax,
                      totalAmount: subtotal + tax,
                      totalPayableAmount: subtotal + tax,
                      taxData: originalTaxData,
                    ));

                    doIfLoggedIn(context, () {
                      showConfirmOrderBottomSheet();
                    });
                  },
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  int getLogisticZoneId() {
    int id;
    if (productStore.logisticZoneData.cities != null && productStore.logisticZoneData.cities!.isNotEmpty) {
      if (productStore.logisticZoneData.cities!.first.pivot!.logisticZoneId != null) {
        id = productStore.logisticZoneData.cities!.first.pivot!.logisticZoneId.validate();
        return id;
      } else {
        id = productStore.logisticZoneData.logisticId.validate();
        return id;
      }
    } else {
      id = productStore.logisticZoneData.logisticId.validate();
      return id;
    }
  }

  void placeOrder({required String txnId, required String paymentType, required String paymentStatus}) {
    appStore.setLoading(true);

    Map request = {
      "location_id": 1,
      "shipping_address_id": productStore.addressData.id,
      "billing_address_id": productStore.addressData.id,
      "phone": productStore.addressData.contactNumber,
      "alternative_phone": productStore.alternateContactNumber.isNotEmpty ? productStore.alternateContactNumber : '',
      "chosen_logistic_zone_id": productStore.logisticZoneData.id,
      "shipping_delivery_type": SHIPPING_DELIVERY_TYPE_REGULAR,
      "payment_method": paymentType,
      "payment_details": txnId.isNotEmpty ? txnId : '',
      "payment_status": paymentStatus,
    };

    // Add coupon data if coupon is applied
    if (productStore.isCouponApplied && productStore.discountCouponCode.isNotEmpty) {
      request["coupon_code"] = productStore.discountCouponCode;
      request["coupon_discount_amount"] = productStore.finalDiscountCouponAmount;
      request["is_fixed_discount"] = productStore.isFixedDiscountCoupon ? 1 : 0;
      if (productStore.couponDiscountPercentage > 0) {
        request["coupon_discount_percentage"] = productStore.couponDiscountPercentage;
      }
    } else {}
    log("request : ${request}");
    appStore.setLoading(false);

    /// Place Order API
    placeOrderAPI(request).then((value) async {
      productStore.setCartItemCount(0);
      appStore.setLoading(false);
      if (!mounted) return;
      showOrderCompleteDialog();
    }).catchError((e) {
      appStore.setLoading(false);
      ShowToast.showError(e.toString());
    });
  }

  Future<void> savePayment() async {
    if (selectedPayment.id == PaymentMethods.PAYMENT_METHOD_CASH) {
      placeOrder(
        txnId: '',
        paymentType: PaymentMethods.PAYMENT_METHOD_CASH,
        paymentStatus: SERVICE_PAYMENT_STATUS_UNPAID,
      );
    } else if (selectedPayment.id == PaymentMethods.PAYMENT_METHOD_RAZORPAY) {
      appStore.setLoading(true);

      razorPayService.init(
        razorKey: getStringAsync(PaymentKeys.RAZORPAY_PUBLIC_KEY),
        totalAmount: productStore.totalAmount,
        onComplete: (res) {
          log(res);

          placeOrder(
            txnId: res,
            paymentType: PaymentMethods.PAYMENT_METHOD_RAZORPAY,
            paymentStatus: SERVICE_PAYMENT_STATUS_PAID,
          );
        },
      );

      await 1.seconds.delay;
      appStore.setLoading(false);

      razorPayService.razorPayCheckout();
    } else if (selectedPayment.id == PaymentMethods.PAYMENT_METHOD_STRIPE) {
      appStore.setLoading(true);

      await stripeServices.init(
        totalAmount: productStore.totalAmount,
        isTest: true,
        onComplete: (res) {
          log(res);

          placeOrder(
            txnId: res,
            paymentType: PaymentMethods.PAYMENT_METHOD_STRIPE,
            paymentStatus: SERVICE_PAYMENT_STATUS_PAID,
          );
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
      appStore.setLoading(true);

      await paystackServices.init(
        context: context,
        totalAmount: productStore.totalAmount,
        onComplete: (response) {
          log(response);

          placeOrder(
            txnId: response,
            paymentType: PaymentMethods.PAYMENT_METHOD_PAYSTACK,
            paymentStatus: SERVICE_PAYMENT_STATUS_PAID,
          );
        },
      );

      await 1.seconds.delay;
      appStore.setLoading(false);
      finish(context);
      finish(context);
      paystackServices.checkout();
    } else if (selectedPayment.id == PaymentMethods.PAYMENT_METHOD_PAYPAL) {
      appStore.setLoading(true);

      await payPalServices.init(
        context: context,
        isTest: true,
        totalAmount: productStore.totalAmount,
        onComplete: (response) {
          log(response);

          placeOrder(
            txnId: response,
            paymentType: PaymentMethods.PAYMENT_METHOD_PAYPAL,
            paymentStatus: SERVICE_PAYMENT_STATUS_PAID,
          );
        },
      );

      await 1.seconds.delay;
      appStore.setLoading(false);

      payPalServices.paypalCheckOut();
    } else if (selectedPayment.id == PaymentMethods.PAYMENT_METHOD_FLUTTER_WAVE) {
      appStore.setLoading(true);

      flutterWaveServices.checkout(
        flutterWavePublicKey: getStringAsync(PaymentKeys.FLUTTER_WAVE_PUBLIC_KEY),
        flutterWaveSecretKey: getStringAsync(PaymentKeys.FLUTTER_WAVE_SECRET_KEY),
        totalAmount: productStore.totalAmount,
        isTestMode: true,
        onComplete: (res) {
          log(res);

          placeOrder(
            txnId: res,
            paymentType: PaymentMethods.PAYMENT_METHOD_FLUTTER_WAVE,
            paymentStatus: SERVICE_PAYMENT_STATUS_PAID,
          );
        },
      );

      await 1.seconds.delay;
      appStore.setLoading(false);
    } else if (selectedPayment.id == PaymentMethods.PAYMENT_METHOD_FROM_WALLET) {
      if (productStore.totalAmount > appStore.userWalletAmount) {
        ShowToast.showInfo(locale.walletBalanceIsNotSufficientForThisBooking);
      } else {
        var id = "w" + Random().nextInt(10000000).toString();
        placeOrder(
          txnId: id,
          paymentType: PaymentMethods.PAYMENT_METHOD_FROM_WALLET,
          paymentStatus: SERVICE_PAYMENT_STATUS_PAID,
        );
      }
    }
  }

  void showOrderCompleteDialog() {
    CommonBottomSheet.show(
      context,
      showCloseButton: false,
      isDismissible: false,
      enableDrag: false,
      contentPadding: EdgeInsets.all(32),
      child: SizedBox(
        width: context.width(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Green Checkmark Icon with wavy border
            CachedImageWidget(url: ic_confirm_order_check, height: 60, width: 60),
            24.height,
        
            // Title
            Text(
              locale.orderPlacedSuccessfully,
              style: boldTextStyle(size: 20),
              textAlign: TextAlign.center,
            ),
            12.height,
        
            // Message
            Text(
              locale.thankYouForChoosingOurService,
              style: secondaryTextStyle(size: 14),
              textAlign: TextAlign.center,
            ),
            32.height,
        
            // Done Button
            AppButton(
              width: 170,
              height: 40,
              text: locale.done,
              textStyle: boldTextStyle(size: 16, color: Colors.white),
              color: primaryColor,
              shapeBorder: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              onTap: () {
                Navigator.of(context).pop();
        
                Navigator.of(getContext).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (_) => DashboardScreen(),
                  ),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void showConfirmOrderBottomSheet() {
    bool isTermsAccepted = false;

    CommonBottomSheet.show(
      context,
      showCloseButton: false,
      isDismissible: true,
      enableDrag: true,
      contentPadding: EdgeInsets.all(24),
      child: StatefulBuilder(
        builder: (context, setState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Green Checkmark Icon
              Container(
                width: 60,
                height: 60,
                child: Assets.iconsIcConfirmOrderCheck.iconImage(color: greenColor, size: 30),
              ),
              20.height,

              // Title
              Text(
                locale.confirmYourOrder,
                style: boldTextStyle(size: 20),
                textAlign: TextAlign.center,
              ),
              12.height,

              // Description
              Text(
                locale.youAreAboutToPlaceYourOrderForSelectedProducts,
                style: secondaryTextStyle(size: 14),
                textAlign: TextAlign.center,
              ),
              24.height,

              // Terms & Conditions Checkbox
              Row(
                children: [
                  Checkbox(
                    value: isTermsAccepted,
                    onChanged: (value) {
                      setState(() {
                        isTermsAccepted = value ?? false;
                      });
                    },
                    activeColor: primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: radius(4)),
                  ),
                  8.width,
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        text: locale.iAcceptYour + " ",
                        style: secondaryTextStyle(size: 12),
                        children: [
                          TextSpan(
                            text: '${locale.termsConditions}',
                            style: secondaryTextStyle(size: 12, color: context.primaryColor, weight: FontWeight.w700).copyWith(
                              decoration: TextDecoration.underline,
                              decorationColor: context.primaryColor,
                              decorationThickness: 1,
                            ),
                            recognizer: _termsRecognizer,
                          ),
                          TextSpan(text: ' ${locale.and} ', style: secondaryTextStyle(size: 12)),
                          TextSpan(
                            text: locale.privacyPolicy,
                            style: secondaryTextStyle(size: 12, color: context.primaryColor, weight: FontWeight.w700).copyWith(
                              decoration: TextDecoration.underline,
                              decorationColor: context.primaryColor,
                              decorationThickness: 1,
                            ),
                            recognizer: _privacyRecognizer,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              24.height,

              // Action Buttons
              Row(
                children: [
                  // Cancel Button
                  Expanded(
                    child: AppButton(
                      text: locale.cancel,
                      textStyle: boldTextStyle(size: 14, color: black),
                      color: appStore.isDarkMode ? white : Colors.grey.shade200,
                      shapeBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                  12.width,

                  // Confirm Button
                  Expanded(
                    child: AppButton(
                      text: locale.confirm,
                      textStyle: boldTextStyle(size: 14, color: isTermsAccepted ? white : null),
                      color: isTermsAccepted ? primaryColor  : appStore.isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300,
                      shapeBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      onTap: isTermsAccepted
                          ? () {
                              Navigator.of(context).pop();
                              savePayment();
                              appStore.setLoading(true);
                            }
                          : () {
                              ShowToast.showInfo(locale.termsConditionsMessage);
                            },
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
