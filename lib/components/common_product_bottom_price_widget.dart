import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frezka/components/price_widget.dart';
import 'package:frezka/main.dart';
import 'package:frezka/screens/cart/model/cart_list_response.dart';
import 'package:frezka/utils/constants.dart';
import 'package:nb_utils/nb_utils.dart';

import '../utils/colors.dart';

class CommonProductBottomPriceWidget extends StatefulWidget {
  final String? title;
  final num? price;
  final num? totalFixedTaxAmount;
  final num? totalPercentageTaxAmount;
  final String? buttonText;
  final CartPriceData? cartPriceData;
  final List<CartListData>? cartListData;
  final Function? onTap;
  final bool isEnabled;

  const CommonProductBottomPriceWidget({super.key, this.title, this.price, this.totalFixedTaxAmount = 0.0, this.totalPercentageTaxAmount = 0.0, this.buttonText, this.cartPriceData, this.cartListData, this.onTap, this.isEnabled = true});

  @override
  State<CommonProductBottomPriceWidget> createState() => _CommonProductBottomPriceWidgetState();
}

class _CommonProductBottomPriceWidgetState extends State<CommonProductBottomPriceWidget> {
  bool isSelect = false;
  bool _isChangingState = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _isChangingState = false;
    super.dispose();
  }

  num calculateTotalTax() {
    num taxAmount = 0.0;
    num totalCartAmount = 0.0;

    if (widget.cartListData != null) {
      for (var ele in widget.cartListData!) {
        final int quantity = ele.qty.validate(value: 1);

        if (ele.productVariation != null) {
          totalCartAmount += (ele.productVariation?.discountedProductPrice.validate() ?? 0) * quantity;
        } else {
          final num unitWithTax = ele.taxIncludeProductPrice.validate();
          final num unitBase = ele.getProductPrice.validate();
          final num lineFromApi = ele.productAmount.validate();
          totalCartAmount += (lineFromApi != 0) ? lineFromApi : ((unitBase != 0 ? unitBase : unitWithTax) * quantity);
        }
      }
    }

    num couponDiscount = calculateCouponDiscount();
    num discountedSubtotal = totalCartAmount - couponDiscount;

    if (discountedSubtotal < 0) discountedSubtotal = 0;

    final taxDetails = widget.cartPriceData?.taxData?.taxDetails;
    if (taxDetails != null) {
      for (var ele in taxDetails) {
        if (ele.taxType == TaxType.PERCENT) {
          final num percentTax = (discountedSubtotal * ele.taxValue.validate()) / 100;
          taxAmount += percentTax;
        } else {
          final num fixedTax = ele.taxValue.validate();
          taxAmount += fixedTax;
        }
      }
    }

    return taxAmount;
  }

  num calculateSubTotal() {
    num totalCartAmount = 0.0;
    if (widget.cartListData != null) {
      for (var ele in widget.cartListData!) {
        final int quantity = ele.qty.validate(value: 1);

        if (ele.productVariation != null) {
          totalCartAmount += (ele.productVariation?.discountedProductPrice.validate() ?? 0) * quantity;
        } else {
          final num unitWithTax = ele.taxIncludeProductPrice.validate();
          final num unitBase = ele.getProductPrice.validate();
          final num lineFromApi = ele.productAmount.validate();
          totalCartAmount += (lineFromApi != 0) ? lineFromApi : ((unitBase != 0 ? unitBase : unitWithTax) * quantity);
        }
      }
    }
    return totalCartAmount;
  }

  num calculateCouponDiscount() {
    if (productStore.isCouponApplied) {
      return productStore.finalDiscountCouponAmount;
    }
    return 0.0;
  }

  num calculateFinalTotal() {
    num subtotal = calculateSubTotal();
    num couponDiscount = calculateCouponDiscount();
    num discountedSubtotal = subtotal - couponDiscount;
    num tax = calculateTotalTax();
    num deliveryCharge = productStore.logisticZoneData.standardDeliveryCharge.validate();

    return discountedSubtotal + tax + deliveryCharge;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 16, right: 16, top: 16),
      decoration: boxDecorationWithRoundedCorners(
        backgroundColor: appStore.isDarkMode ? context.cardColor : primaryLightColor,
        borderRadius: radiusOnly(
          topLeft: 12,
          topRight: 12,
        ),
        border: Border(top: BorderSide(color: borderColor, width: 0.5)),
      ),
      child: Column(
        children: [
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedSwitcher(
                  duration: Duration(milliseconds: 300),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return SizeTransition(child: child, sizeFactor: animation);
                  },
                  child: isSelect ? viewDetail(context).paddingBottom(16) : SizedBox.shrink(),
                ),
              ],
            ),
          ),
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () {
                        if (_isChangingState) return;
                        _isChangingState = true;
                        Future.delayed(Duration(milliseconds: 50), () {
                          if (mounted) {
                            setState(() {
                              isSelect = !isSelect;
                            });
                            _isChangingState = false;
                          }
                        });
                      },
                      child: Row(
                        children: [
                          Text(locale.viewDetail, style: secondaryTextStyle(size: 14, color: appStore.isDarkMode ? white : black)),
                          8.width,
                          Icon(
                            isSelect ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                            color: darkGreyColor,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                    8.height,
                    Observer(
                      builder: (context) => PriceWidget(
                        price: calculateFinalTotal(),
                        color: appStore.isDarkMode ? white : priceColor,
                        size: 20,
                        isBoldText: true,
                      ),
                    ),
                    16.height,
                  ],
                ),
                ConstrainedBox(
                  constraints: BoxConstraints(minWidth: 100),
                  child: Container(
                    height: 40,
                    alignment: Alignment.center,
                    padding: EdgeInsets.only(left: 16, right: 16, top: 7, bottom: 7),
                    decoration: boxDecorationWithRoundedCorners(
                      backgroundColor: widget.isEnabled ? primaryColor : primaryColor.withValues(alpha: 0.5),
                      borderRadius: radius(4),
                    ),
                    child: Text(
                      widget.buttonText.validate(),
                      style: boldTextStyle(
                        color: widget.isEnabled ? white : white.withValues(alpha: 0.7),
                        size: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ).onTap(() {
                    if (widget.isEnabled && widget.onTap != null) {
                      widget.onTap!();
                    }
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget viewDetail(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Subtotal Section
        _buildSummaryRow(
          locale.subtotal,
          calculateSubTotal(),
          color: appStore.isDarkMode ? white : black,
        ),

        if (widget.cartListData != null && widget.cartListData!.isNotEmpty) ...[
          8.height,
          ...widget.cartListData!.map((item) => _buildCartItemWithLabel(item)).toList(),
        ],

        8.height,

        Observer(
          builder: (context) {
            final couponDiscount = calculateCouponDiscount();
            if (couponDiscount > 0) {
              return Column(
                children: [
                  _buildSummaryRow(
                    locale.coupon,
                    -couponDiscount,
                    color: successColor,
                    isDiscount: true,
                  ),
                  8.height,
                ],
              );
            }
            return SizedBox.shrink();
          },
        ),

        if (calculateTotalTax() > 0) ...[
          _buildTaxRow(),
          8.height,
        ],

        if (widget.totalPercentageTaxAmount != null && widget.totalPercentageTaxAmount! > 0) ...[
          _buildSummaryRow(
            locale.shippingCharges,
            widget.totalPercentageTaxAmount!,
            color: appStore.isDarkMode ? white : black,
          ),
          8.height,
        ],

        Observer(
          builder: (context) {
            final deliveryCharge = productStore.logisticZoneData.standardDeliveryCharge.validate();
            if (deliveryCharge > 0) {
              return Column(
                children: [
                  _buildSummaryRow(
                    locale.deliveryCharge,
                    deliveryCharge,
                    color: appStore.isDarkMode ? white : black,
                  ),
                  8.height,
                ],
              );
            }
            return SizedBox.shrink();
          },
        ),

        Container(
          padding: EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: lightBorderColor, width: 1),
            ),
          ),
          child: Observer(
            builder: (context) => _buildSummaryRow(
              locale.total,
              calculateFinalTotal(),
              color: appStore.isDarkMode ? white : black,
              isBold: true,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, num amount, {Color? color, bool isDiscount = false, bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isBold ? boldTextStyle(color: color ?? black, size: 14) : secondaryTextStyle(color: color ?? black, size: 14),
        ),
        PriceWidget(
          price: amount,
          color: isDiscount ? successColor : (color ?? black),
          size: 16,
          isBoldText: true,
        ),
      ],
    );
  }

  Widget _buildCartItemWithLabel(CartListData item) {
    final bool hasDiscount = item.isDiscount && item.productVariation != null;
    final num? originalPrice = item.productVariation?.taxIncludeProductPrice;
    final num? discountedPrice = item.productVariation?.discountedProductPrice ?? item.getProductPrice;
    final num finalPrice = (discountedPrice ?? 0) * item.qty.validate();

    // Calculate discount percentage
    String? discountBadgeText;
    if (hasDiscount && originalPrice != null && discountedPrice != null && originalPrice > 0 && originalPrice > discountedPrice) {
      if(item.discountType == TaxType.FIXED && item.discountValue.validate() != 0) {
        discountBadgeText = '${leftCurrencyFormat()}${item.discountValue.validate()}${rightCurrencyFormat()} ${locale.off.toUpperCase()}';
      } else if(item.discountType == TaxType.PERCENT && item.discountValue.validate() != 0) {
        discountBadgeText = '${item.discountValue.validate()}% ${locale.off.toUpperCase()}';
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(left: 16, bottom: 4),
          child: Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Text("•", style: secondaryTextStyle(color: appTextSecondaryColor, size: 14)),
                    8.width,
                    Flexible(
                      fit: FlexFit.loose,
                      child: Marquee(
                        child: Text(
                          item.productName?.isNotEmpty == true ? item.productName! : 'Product',
                          style: secondaryTextStyle(size: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    if (hasDiscount && discountBadgeText != null) ...[
                      10.width,
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 9, vertical: 2),
                        decoration: BoxDecoration(
                          color: successColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          discountBadgeText,
                          style: boldTextStyle(color: white, size: 10),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              8.width,
              ConstrainedBox(
                constraints: BoxConstraints(minWidth: 70, maxWidth: 200),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (hasDiscount && originalPrice != null && discountedPrice != null && originalPrice > discountedPrice) ...[
                        PriceWidget(
                          price: originalPrice * item.qty.validate(),
                          color: textSecondaryColorGlobal,
                          size: 16,
                          isLineThroughEnabled: true,
                        ),
                        8.width,
                      ],
                      PriceWidget(
                        price: finalPrice,
                        color: textSecondaryColorGlobal,
                        size: 16,
                      ),
                      // Show discount badge next to price
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTaxRow() {
    return _TaxExpandableWidget(
      cartPriceData: widget.cartPriceData,
      totalCartAmount: calculateSubTotal() - calculateCouponDiscount(),
    );
  }
}

class _TaxExpandableWidget extends StatefulWidget {
  final CartPriceData? cartPriceData;
  final num? totalCartAmount;

  _TaxExpandableWidget({this.cartPriceData, this.totalCartAmount});

  @override
  _TaxExpandableWidgetState createState() => _TaxExpandableWidgetState();
}

class _TaxExpandableWidgetState extends State<_TaxExpandableWidget> {
  bool isExpanded = false;
  bool _isChangingState = false;

  @override
  void dispose() {
    _isChangingState = false;
    super.dispose();
  }

  num _calculateTaxAmountForExpandable(TaxDetail tax) {
    num taxAmt = 0.0;
    if (tax.taxType == TaxType.PERCENT) {
      taxAmt = (widget.totalCartAmount! * tax.taxValue.validate()) / 100;
    } else {
      taxAmt = tax.taxValue.validate();
    }
    return taxAmt;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            if (_isChangingState) return;
            _isChangingState = true;
            Future.delayed(Duration(milliseconds: 50), () {
              if (mounted) {
                setState(() {
                  isExpanded = !isExpanded;
                });
                _isChangingState = false;
              }
            });
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                locale.tax,
                style: secondaryTextStyle(size: 14),
              ),
              Row(
                children: [
                  if (widget.cartPriceData?.taxData?.taxDetails?.isNotEmpty ?? false) ...[
                    8.width,
                    Icon(
                      isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      color: context.iconColor,
                      size: 16,
                    ),
                  ],
                  PriceWidget(
                    price: _calculateTotalTax(),
                    color: orangeColor,
                    size: 16,
                  ),
                ],
              ),
            ],
          ),
        ),
        if (isExpanded && (widget.cartPriceData?.taxData?.taxDetails?.isNotEmpty ?? false)) ...[
          8.height,
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: context.dividerColor, width: 1),
            ),
            child: Column(
              children: [
                ...(widget.cartPriceData?.taxData?.taxDetails ?? [])
                    .map(
                      (tax) => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            tax.taxType == TaxType.PERCENT ? '${tax.taxName} (${tax.taxValue}%)' : '${tax.taxName}',
                            style: secondaryTextStyle(size: 12),
                          ),
                          PriceWidget(
                            price: _calculateTaxAmountForExpandable(tax),
                            color: orangeColor,
                            size: 14,
                          ),
                        ],
                      ),
                    )
                    .toList(),
              ],
            ),
          ),
        ],
      ],
    );
  }

  num _calculateTotalTax() {
    num taxAmount = 0.0;
    final cartPriceData = widget.cartPriceData;
    final taxData = cartPriceData?.taxData;
    final taxDetails = taxData?.taxDetails;
    final totalAmount = widget.totalCartAmount;
    if (taxDetails != null && totalAmount != null) {
      for (var ele in taxDetails) {
        if (ele.taxType == TaxType.PERCENT) {
          final num percentTax = (totalAmount * ele.taxValue.validate()) / 100;
          taxAmount += percentTax;
        } else {
          final num fixedTax = ele.taxValue.validate();
          taxAmount += fixedTax;
        }
      }
    }
    return taxAmount;
  }
}

Widget taxDetailsWidget({required BuildContext context, CartPriceData? cartPriceData, num? totalCartAmount}) {
  final taxDetails = cartPriceData?.taxData?.taxDetails;
  if (taxDetails == null || taxDetails.isEmpty || totalCartAmount == null) {
    return const SizedBox();
  }
  return Container(
    padding: EdgeInsets.all(16),
    width: context.width(),
    decoration: boxDecorationWithRoundedCorners(backgroundColor: secondaryColor, borderRadius: radiusOnly(topLeft: defaultRadius, topRight: defaultRadius)),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(locale.appliedTaxes, style: boldTextStyle(color: white)),
        12.height,
        ListView.builder(
          shrinkWrap: true,
          physics: AlwaysScrollableScrollPhysics(),
          itemCount: taxDetails.length,
          itemBuilder: (context, index) {
            final taxDet = taxDetails[index];
            num taxAmt = 0.0;
            if (taxDet.taxType == TaxType.PERCENT) {
              taxAmt = (totalCartAmount * taxDet.taxValue.validate()) / 100;
            } else {
              taxAmt = taxDet.taxValue.validate();
            }
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  taxDet.taxType == TaxType.PERCENT ? '${taxDet.taxName} (${taxDet.taxValue}%)' : '${taxDet.taxName} (${taxDet.taxValue})',
                  style: secondaryTextStyle(color: white, size: 14),
                ),
                PriceWidget(
                  price: taxAmt,
                  color: white,
                  size: 14,
                ),
              ],
            );
          },
        ),
      ],
    ),
  );
}
