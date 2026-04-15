import 'package:flutter/material.dart';
import 'package:frezka/components/common_bottom_sheet.dart';
import 'package:frezka/components/empty_error_state_widget.dart';
import 'package:frezka/components/loader_widget.dart';
import 'package:frezka/main.dart';
import 'package:frezka/screens/coupons/component/apply_coupon_card_component.dart';
import 'package:frezka/screens/coupons/coupon_repository.dart';
import 'package:frezka/screens/coupons/model/coupon_list_model.dart';
import 'package:frezka/utils/constants.dart';
import 'package:frezka/utils/custom_toast_widget.dart';
import 'package:nb_utils/nb_utils.dart';

class CouponBottomSheetComponent extends StatefulWidget {
  final bool? isFromBooking;
  final ScrollController? scrollController;

  const CouponBottomSheetComponent({super.key, this.isFromBooking, this.scrollController});

  /// Show coupon selection bottom sheet
  static Future<void> show(BuildContext context, {bool? isFromBooking}) {
    return CommonBottomSheet.show(
      context,
      title: locale.availableCoupons,
      contentPadding: EdgeInsets.all(20),
      child: CouponBottomSheetComponent(isFromBooking: isFromBooking),
    );
  }

  @override
  State<CouponBottomSheetComponent> createState() => _CouponBottomSheetComponentState();
}

class _CouponBottomSheetComponentState extends State<CouponBottomSheetComponent> {
  List<CouponListData> couponList = [];
  Future<List<CouponListData>>? future;
  String? selectedCouponCode;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() {
    future = getCouponList();
  }

  Future<List<CouponListData>> getCouponList() async {
    setState(() {
      isLoading = true;
    });
    await getCouponListData().then((value) {
      if (value.couponListData != null) {
        couponList = value.couponListData!;
      } else {}
      setState(() {
        isLoading = false;
      });
    }).catchError((e) {
      setState(() {
        isLoading = false;
      });
      ShowToast.showError(e.toString());
    });
    return couponList;
  }

  Future<void> checkCouponData(String couponCode) async {
    hideKeyboard(context);
    setState(() {
      isLoading = true;
    });
    final isFromCart = widget.isFromBooking == false;

    if (isFromCart) {
      productStore.setCouponApplied(false);
    } else {
      bookingRequestStore.setCouponApplied(false);
    }

    await getCouponData(couponCode: Uri.encodeComponent(couponCode)).then((value) {
      if (value.couponListData != null) {
        if (isFromCart) {
          if (value.couponListData!.discountType.validate() == TaxType.FIXED) {
            productStore.setFixedCouponType(true);
            productStore.setFinalDiscountCouponAmount(value.couponListData!.discountAmount.validate());
          } else {
            productStore.setFixedCouponType(false);
            productStore.setCouponPercentage(value.couponListData!.discountPercentage!.toDouble());
            productStore.setFinalDiscountCouponAmount(0);
          }
          productStore.setCouponApplied(true);
          productStore.setDiscountCouponCode(couponCode);
        } else {
          // Apply to bookingRequestStore for booking context
          if (value.couponListData!.discountType.validate() == TaxType.FIXED) {
            bookingRequestStore.setFixedCouponType(true);
            bookingRequestStore.setFinalDiscountCouponAmount(value.couponListData!.discountAmount.validate());
          } else {
            bookingRequestStore.setFixedCouponType(false);
            bookingRequestStore.setCouponPercentage(value.couponListData!.discountPercentage!.toDouble());
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
          bookingRequestStore.setDiscountCouponCode(couponCode);
        }

        ShowToast.showSuccess(locale.couponAppliedSuccessfully);
        setState(() {
          isLoading = false;
        });
        finish(context);
      }
    }).catchError((e) {
      setState(() {
        isLoading = false;
      });
      ShowToast.showError(e.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SnapHelperWidget<List<CouponListData>>(
          future: future,
          loadingWidget: Offstage(),
          useConnectionStateForLoader: false,
          errorBuilder: (error) {
            return NoDataWidget(
              title: error,
              retryText: locale.reload,
              imageWidget: ErrorStateWidget(),
              onRetry: () {
                init();
              },
            );
          },
          onSuccess: (couponList) {
            if (couponList.isEmpty) {
              return NoDataWidget(
                title: '${locale.opps}! ${locale.noCouponsAvailable}',
                retryText: locale.reload,
                imageWidget: EmptyStateWidget(),
                onRetry: () async {
                  init();
                },
              ).paddingSymmetric(horizontal: 32).center();
            }

            return Column(
              children: couponList.map((data) {
                bool isApplied = bookingRequestStore.isCouponApplied && bookingRequestStore.discountCouponCode == data.couponCode;
                return ApplyCouponCardComponent(
                  couponCode: data.couponCode,
                  expiryDate: data.endDateTime ?? data.validUntil,
                  isFixedCoupon: data.discountType == TaxType.FIXED,
                  couponAmount: data.discountType == TaxType.FIXED ? data.discountAmount.toString() : data.discountPercentage.toString(),
                  couponDescription: data.description,
                  isApplied: isApplied,
                  onApply: (couponCode) async {
                    if (!isApplied && couponCode.trim().isNotEmpty) {
                      await checkCouponData(couponCode);
                      setState(() {});
                    }
                  },
                );
              }).toList(),
            );
          },
        ),
        LoaderWidget().visible(isLoading).center()
      ],
    );
  }
}
