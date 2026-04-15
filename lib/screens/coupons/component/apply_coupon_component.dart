import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frezka/components/loader_widget.dart';
import 'package:frezka/components/price_widget.dart';
import 'package:frezka/main.dart';
import 'package:frezka/screens/booking/model/booking_request_model.dart';
import 'package:frezka/screens/coupons/component/coupon_bottom_sheet_component.dart';
import 'package:frezka/screens/coupons/coupon_repository.dart';
import 'package:frezka/utils/colors.dart';
import 'package:frezka/utils/constants.dart';
import 'package:frezka/utils/custom_toast_widget.dart';
import 'package:nb_utils/nb_utils.dart';

class ApplyCouponComponent extends StatefulWidget {
  final VoidCallback? callback;
  final BookingRequestModel? taxRequest;
  final bool isFromBookingStep3;
  final bool isApplied;
  final bool isFromCart;
  final num? cartTotal; // Cart total for percentage discount calculation
  const ApplyCouponComponent({
    super.key,
    this.isFromBookingStep3 = false,
    this.callback,
    this.taxRequest,  
    this.isApplied = false,
    this.isFromCart = false,
    this.cartTotal,
  });

  @override
  State<ApplyCouponComponent> createState() => _ApplyCouponComponentState();
}

class _ApplyCouponComponentState extends State<ApplyCouponComponent> {
  final TextEditingController _couponController = TextEditingController();
  bool _isApplying = false;

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  void _updateCouponDiscountAfterBuild() {
    if (widget.isFromCart && productStore.isCouponApplied && !productStore.isFixedDiscountCoupon) {
      final cartTotal = _calculateCartTotal();
      final discountAmount = cartTotal * productStore.couponDiscountPercentage / 100;
      productStore.setFinalDiscountCouponAmount(discountAmount);
    }
  }

  void _applyCoupon() async {
    if (_couponController.text.trim().isEmpty) {
      ShowToast.showInfo(locale.pleaseAddCouponCode);
      return;
    }

    setState(() {
      _isApplying = true;
    });

    try {
      // Call the real coupon validation API
      final couponData = await getCouponData(couponCode: Uri.encodeComponent(_couponController.text.trim()));

      if (couponData.couponListData != null) {
        final coupon = couponData.couponListData!;

        // Apply coupon to appropriate store based on context
        if (widget.isFromCart) {
          productStore.setCouponApplied(true);
          productStore.setDiscountCouponCode(_couponController.text.trim());

          // Calculate discount based on coupon type
          if (coupon.discountType == TaxType.FIXED) {
            productStore.setFixedCouponType(true);
            productStore.setFinalDiscountCouponAmount(coupon.discountAmount.validate());
          } else {
            productStore.setFixedCouponType(false);
            productStore.setCouponPercentage(coupon.discountPercentage!.toDouble());
            // Calculate percentage discount based on cart total
            final cartTotal = _calculateCartTotal();
            final discountAmount = cartTotal * coupon.discountPercentage! / 100;
            productStore.setFinalDiscountCouponAmount(discountAmount);
          }
        } else {
          if (couponData.couponListData!.discountType.validate() == TaxType.FIXED) {
            bookingRequestStore.setFixedCouponType(true);
            bookingRequestStore.setFinalDiscountCouponAmount(couponData.couponListData!.discountAmount.validate());
          } else {
            bookingRequestStore.setFixedCouponType(false);
            bookingRequestStore.setCouponPercentage(couponData.couponListData!.discountPercentage!.toDouble());
            bookingRequestStore.setFinalDiscountCouponAmount(bookingRequestStore.calculateTotalDiscountCouponAmount);
            if (bookingRequestStore.selectedServiceList.isNotEmpty) {
              bookingRequestStore.selectedServiceList.forEach((service) {
                service.defaultPrice.validate();
              });
            }

            if (bookingRequestStore.isPackagePurchase) {
              final packagePrice = bookingRequestStore.selectedPackageList.first.packagePrice.validate();
              final calculatedDiscount = packagePrice * bookingRequestStore.couponDiscountPercentage / 100;
              bookingRequestStore.setFinalDiscountCouponAmount(calculatedDiscount);
            }
          }
          bookingRequestStore.setCouponApplied(true);
          bookingRequestStore.setDiscountCouponCode(_couponController.text.trim());
        }

        ShowToast.showSuccess(locale.couponAppliedSuccessfully);
        widget.callback?.call();
        setState(() {});
      } else {
        ShowToast.showError(locale.theCouponAmountExceeds);
      }
    } catch (e) {
      if(e is String) {
        ShowToast.showError(e);
        return;
      }
      ShowToast.showError(locale.theCouponAmountExceeds);
    } finally {
      setState(() {
        _isApplying = false;
      });
    }
  }

  // Helper method to calculate cart total for percentage discounts
  num _calculateCartTotal() {
    // Use the passed cart total or fallback to a default value
    return widget.cartTotal ?? 100.0;
  }

  void _removeCoupon() {
    if (widget.isFromCart) {
      productStore.setCouponApplied(false);
      productStore.setDiscountCouponCode('');
    } else {
      bookingRequestStore.setCouponApplied(false);
      bookingRequestStore.setDiscountCouponCode('');
    }
    _couponController.clear();
    ShowToast.showInfo(locale.couponIsRemoved);
    widget.callback?.call();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // Update coupon discount after build phase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateCouponDiscountAfterBuild();
    });

    return Observer(
      builder: (context) {
        return AnimatedContainer(
          duration: Duration(seconds: 1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(locale.coupons, style: boldTextStyle(size: 16)),
                  Spacer(),
                  Text(
                    (widget.isFromCart ? productStore.isCouponApplied : bookingRequestStore.isCouponApplied) ? locale.changeCoupon : locale.selectCoupon,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(color: context.primaryColor, offset: Offset(0, -2))],
                      color: Colors.transparent,
                      decoration: TextDecoration.underline,
                      decorationColor: context.primaryColor,
                      decorationThickness: 1,
                      decorationStyle: TextDecorationStyle.solid,
                    ),
                  ).onTap(
                    () {
                      if (widget.isFromCart ||
                          widget.taxRequest != null && widget.taxRequest!.selectedServiceList != null ||
                          bookingRequestStore.selectedServiceList.isNotEmpty ||
                          bookingRequestStore.selectedPackageList.isNotEmpty) {
                        CouponBottomSheetComponent.show(context, isFromBooking: !widget.isFromCart).then((value) {
                          widget.callback?.call();
                        });
                      } else {
                        ShowToast.showInfo(locale.pleaseSelectService);
                      }
                    },
                  ),
                ],
              ),
              16.height,
              if (widget.isFromCart ? productStore.isCouponApplied : bookingRequestStore.isCouponApplied) ...[
                // Applied Coupon Display - Updated to match design
                Container(
                  decoration: boxDecorationWithRoundedCorners(
                    borderRadius: radius(8),
                    border: Border.all(color: context.dividerColor),
                    backgroundColor: context.cardColor,
                  ),
                  child: Row(
                    children: [
                      // Coupon tag with dashed border
                      Container(
                        height: 30,
                        margin: EdgeInsets.all(8),
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: boxDecorationWithRoundedCorners(
                          backgroundColor:  lightGreenColor,
                          borderRadius: radius(4),
                          border: Border.all(
                            color: successDarkColor,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          "#${widget.isFromCart ? productStore.discountCouponCode.validate() : bookingRequestStore.discountCouponCode.validate()}",
                          textAlign: TextAlign.center,
                          style: boldTextStyle(color: successDarkColor, size: 12, height: 0.6),
                        ),
                      ),
                      Spacer(),
                      // Remove button
                      Container(
                        margin: EdgeInsets.only(right: 8, top: 4, bottom: 4),
                        decoration: boxDecorationWithRoundedCorners(borderRadius: radius(4), backgroundColor: context.primaryColor),
                        height: 30,
                        width: 70,
                        child: InkWell(
                          borderRadius: radius(4),
                          onTap: _removeCoupon,
                          child: Container(
                            alignment: Alignment.center,
                            child: Text(locale.remove, style: boldTextStyle(color: Colors.white, size: 12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                8.height,
                // Savings information
                Builder(
                  builder: (context) {
                    num couponDiscount = 0;
                    if (widget.isFromCart) {
                      if (productStore.isCouponApplied) {
                        if (productStore.isFixedDiscountCoupon) {
                          couponDiscount = productStore.finalDiscountCouponAmount.validate();
                        } else {
                          // Calculate percentage discount without updating store during build
                          final cartTotal = _calculateCartTotal();
                          couponDiscount = cartTotal * productStore.couponDiscountPercentage / 100;
                        }
                      }
                    } else {
                      couponDiscount = (widget.taxRequest?.totalCouponDiscount ?? bookingRequestStore.finalDiscountCouponAmount).validate();
                    }

                    return Row(
                      children: [
                        Text("${locale.youSaved} ", style: boldTextStyle(color: successDarkColor, size: 12)),
                        PriceWidget(price: couponDiscount, color: successDarkColor, size: 12, isBoldText: true, decimalPoint: couponDiscount % 1 == 0 ? null : 2),
                      ],
                    );
                  },
                ),
              ] else ...[
                // Coupon Input Section
                Container(
                  decoration: boxDecorationWithRoundedCorners(
                    borderRadius: radius(8),
                    border: Border.all(color: borderColor.withAlpha(125), width: 0.5),
                    backgroundColor: context.cardColor,
                  ),
                  child: Row(
                    children: [
                      // Text input field
                      Expanded(
                        child: AppTextField(
                          controller: _couponController,
                          textFieldType: TextFieldType.OTHER,
                          decoration: InputDecoration(
                            hintText: locale.enterCouponCode,
                            hintStyle: secondaryTextStyle(color: Colors.grey),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          ),
                        ),
                      ),
                      // Apply button
                      Container(
                        margin: EdgeInsets.only(right: 8, top: 4, bottom: 4, left: 8),
                        decoration: boxDecorationWithRoundedCorners(borderRadius: radius(4), backgroundColor: context.primaryColor),
                        height: 35,
                        width: 70,
                        child: InkWell(
                          borderRadius: radius(4),
                          onTap: _isApplying ? null : _applyCoupon,
                          child: Container(
                            // padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            alignment: Alignment.center,
                            child: _isApplying
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: LoaderWidget(color: Colors.white),
                                  )
                                : Text(locale.apply, style: boldTextStyle(color: Colors.white, size: 12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
