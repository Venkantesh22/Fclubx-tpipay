import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frezka/components/price_widget.dart';
import 'package:frezka/screens/booking/model/booking_detail_response.dart';
import 'package:frezka/utils/colors.dart';
import 'package:nb_utils/nb_utils.dart';

import '../main.dart';
import '../utils/constants.dart';

class CommonBottomPriceWidget extends StatefulWidget {
  final String? title;
  final num? price;
  final String? buttonText;
  final Function? onTap;

  CommonBottomPriceWidget({this.title, this.price, this.buttonText, this.onTap});

  @override
  State<CommonBottomPriceWidget> createState() => _CommonBottomPriceWidgetState();
}

class _CommonBottomPriceWidgetState extends State<CommonBottomPriceWidget> {
  bool isSelect = false;

  @override
  Widget build(BuildContext context) {
    return !bookingRequestStore.isCouponApplied
        ? Observer(builder: (context) {
            return Container(
              padding: EdgeInsets.all(16),
              decoration: boxDecorationWithRoundedCorners(
                backgroundColor: appStore.isDarkMode ? darkSecondaryColor : primaryLightColor,
                borderRadius: radiusOnly(topLeft: 12, topRight: 12),
                border: Border(top: BorderSide(color: borderColor, width: 1)),
              ),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!bookingRequestStore.isPackagePurchase) ...[
                            InkWell(
                              onTap: () {
                                setState(() {
                                  isSelect = !isSelect;
                                });
                              },
                              child: Row(
                                children: [
                                  Text(locale.viewDetail, style: secondaryTextStyle(size: 14)),
                                  8.width,
                                  Icon(
                                    isSelect ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                    color: context.iconColor,
                                    size: 16,
                                  ),
                                ],
                              ),
                            ),
                            8.height,
                            // Price amount with tax
                            Row(
                              children: [
                                PriceWidget(
                                  price: bookingRequestStore.totalAmount.validate(),
                                  color: appStore.isDarkMode ? white : priceColor,
                                  size: 14,
                                ),
                              ],
                            ),
                          ],
                          if (bookingRequestStore.isPackagePurchase) ...[
                            InkWell(
                              onTap: () {
                                setState(() {
                                  isSelect = !isSelect;
                                });
                              },
                              child: Row(
                                children: [
                                  Text(locale.viewDetail, style: secondaryTextStyle(size: 14)),
                                  8.width,
                                  Icon(
                                    isSelect ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                    color: context.iconColor,
                                    size: 16,
                                  ),
                                ],
                              ),
                            ),
                            10.height,
                            PriceWidget(
                              price: widget.price.validate(),
                              color: appStore.isDarkMode ? white : priceColor,
                              size: 20,
                            ),
                          ]
                        ],
                      ).expand(),
                      16.width,
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: boxDecorationWithRoundedCorners(
                          backgroundColor: primaryColor,
                          borderRadius: radius(4),
                        ),
                        child: Text(
                          widget.buttonText.validate(),
                          style: boldTextStyle(size: 14, color: white),
                        ),
                      ).onTap(() {
                        if (widget.onTap != null) {
                          widget.onTap!();
                        }
                      }),
                    ],
                  ),
                ],
              ),
            );
          })
        : Observer(builder: (context) {
            return Container(
              padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 10),
              decoration: boxDecorationWithRoundedCorners(
                backgroundColor: appStore.isDarkMode ? darkSecondaryColor : primaryLightColor,
                borderRadius: radiusOnly(topLeft: 12, topRight: 12),
                border: Border(
                  top: BorderSide(color: borderColor, width: 1),
                ),
              ),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!bookingRequestStore.isPackagePurchase) ...[
                            InkWell(
                              onTap: () {
                                setState(() {
                                  isSelect = !isSelect;
                                });
                              },
                              child: Row(
                                children: [
                                  Text(locale.viewDetail, style: secondaryTextStyle(size: 14)),
                                  8.width,
                                  Icon(
                                    isSelect ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                    color: context.iconColor,
                                    size: 16,
                                  ),
                                ],
                              ),
                            ),
                            8.height,
                            // Total amount with tax
                            Row(
                              children: [
                                PriceWidget(
                                  price: bookingRequestStore.calculateTotalAmountWithCouponAndTaxAndTip.validate(),
                                  color: appStore.isDarkMode ? white : priceColor,
                                  size: 20,
                                ),
                              ],
                            ),
                          ],
                          if (bookingRequestStore.isPackagePurchase) ...[
                            InkWell(
                              onTap: () {
                                setState(() {
                                  isSelect = !isSelect;
                                });
                              },
                              child: Row(
                                children: [
                                  Text(locale.viewDetail, style: secondaryTextStyle(size: 14)),
                                  8.width,
                                  Icon(
                                    isSelect ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                    color: context.iconColor,
                                    size: 16,
                                  ),
                                ],
                              ),
                            ),
                            10.height,
                            PriceWidget(
                              price: widget.price.validate(),
                              color: appStore.isDarkMode ? white : priceColor,
                              size: 20,
                            ),
                          ]
                        ],
                      ).expand(),
                      16.width,
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: boxDecorationWithRoundedCorners(
                          backgroundColor: primaryColor,
                          borderRadius: radius(4),
                        ),
                        child: Text(
                          widget.buttonText.validate(),
                          style: boldTextStyle(color: white, size: 14),
                        ),
                      ).onTap(() {
                        if (widget.onTap != null) {
                          widget.onTap!();
                        }
                      }),
                    ],
                  ),
                ],
              ),
            );
          });
  }

  Widget viewDetail(BuildContext context) {
    return Observer(builder: (context) {
      return Container(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service/Package Items
            if (bookingRequestStore.selectedServiceList.isNotEmpty) ...[
              ...bookingRequestStore.selectedServiceList
                  .map(
                    (service) => _buildServiceItem(
                      service.name ?? service.serviceName ?? '',
                      service.defaultPrice ?? service.servicePrice ?? 0,
                      isAddOn: false,
                    ),
                  )
                  .toList(),
            ],

            if (bookingRequestStore.selectedPackageList.isNotEmpty) ...[
              ...bookingRequestStore.selectedPackageList
                  .map(
                    (package) => _buildServiceItem(
                      package.name.validate(),
                      package.packagePrice.validate(),
                      isAddOn: false,
                    ),
                  )
                  .toList(),
            ],
            // Coupon Discount
            if (bookingRequestStore.isCouponApplied) ...[
              _buildSummaryRow(
                "${locale.coupon}${bookingRequestStore.couponDiscountPercentage > 0 ? ' (${bookingRequestStore.couponDiscountPercentage % 1 == 0 ? bookingRequestStore.couponDiscountPercentage.toInt() : bookingRequestStore.couponDiscountPercentage}% ${locale.off.toUpperCase()})' : ''}",
                bookingRequestStore.finalDiscountCouponAmount.validate(),
                isDiscount: true,
              ),
              8.height,
            ],

            // Subtotal
            _buildSummaryRow(
              locale.subtotal,
              bookingRequestStore.selectedServiceTotalAmount.validate(),
            ),
            8.height,
            // Tax
            if (bookingRequestStore.totalTax != 0) ...[
              _buildTaxRow(),
            ],
            8.height,
            // Tip
            if (bookingRequestStore.tipAmount > 0) ...[
              _buildSummaryRow(
                locale.tip,
                bookingRequestStore.tipAmount.validate(),
              ),
              8.height,
            ],
            // Total
            _buildTotalRow(),
          ],
        ),
      );
    });
  }

  Widget _buildServiceItem(String name, num price, {bool isAddOn = false}) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: secondaryTextStyle(size: 14)),
              ],
            ),
          ),
          PriceWidget(price: price, color: appStore.isDarkMode ? white : black, size: 16, isBoldText: true),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, num amount, {bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: secondaryTextStyle(color: appStore.isDarkMode ? white : appTextSecondaryColor, size: 14)),
        PriceWidget(
            price: amount,
            color: isDiscount
                ? successColor
                : appStore.isDarkMode
                    ? white
                    : black,
            size: 16,
            isDiscountedPrice: isDiscount),
      ],
    );
  }

  Widget _buildTaxRow() {
    return _TaxExpandableWidget();
  }

  Widget _buildTotalRow() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: lightBorderColor, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(locale.total, style: boldTextStyle(size: 16, weight: FontWeight.bold)),
          PriceWidget(price: bookingRequestStore.totalAmount.validate(), size: 16, color: appStore.isDarkMode ? white : black),
        ],
      ),
    );
  }
}

class _TaxExpandableWidget extends StatefulWidget {
  @override
  _TaxExpandableWidgetState createState() => _TaxExpandableWidgetState();
}

class _TaxExpandableWidgetState extends State<_TaxExpandableWidget> {
  bool isExpanded = false;

  num _calculateTaxAmountForExpandable(TaxPercentage tax) {
    num taxAmt = 0.0;
    if (tax.type == TaxType.PERCENT) {
      num baseAmount = bookingRequestStore.isCouponApplied ? bookingRequestStore.calculateSelectedServiceTotalAmountWithCouponDiscount : bookingRequestStore.selectedServiceTotalAmount;
      taxAmt = num.parse(((baseAmount * tax.percent.validate()) / 100).toString());
    } else {
      taxAmt = tax.taxAmount ?? 0.0;
    }
    return taxAmt;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            setState(() {
              isExpanded = !isExpanded;
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
                  if (bookingRequestStore.totalTax != 0) ...[
                    8.width,
                    Icon(isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: context.iconColor, size: 16),
                  ],
                  PriceWidget(price: bookingRequestStore.totalTax.validate(), color: taxAmountColor, size: 16, isBoldText: false),
                ],
              ),
            ],
          ),
        ),
        if (isExpanded && bookingRequestStore.totalTax != 0) ...[
          8.height,
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.cardColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: lightBorderColor, width: 1),
            ),
            child: Column(
              children: [
                ...bookingRequestStore.taxPercentage
                    .map(
                      (tax) => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${tax.name} ${tax.type == TaxType.FIXED ? '' : '(${tax.percent}%)'}', style: secondaryTextStyle(size: 12)),
                          PriceWidget(
                            price: _calculateTaxAmountForExpandable(tax),
                            color: taxAmountColor,
                            size: 14,
                            isBoldText: false,
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
}

//Tax Details Bottom Sheet
Widget taxDetailsWidget({required BuildContext context}) {
  return Container(
    padding: EdgeInsets.all(16),
    width: context.width(),
    decoration: boxDecorationWithRoundedCorners(backgroundColor: secondaryColor, borderRadius: radiusOnly(topLeft: defaultRadius, topRight: defaultRadius)),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(locale.appliedTaxes, style: boldTextStyle()),
        12.height,
        ListView.builder(
          shrinkWrap: true,
          physics: AlwaysScrollableScrollPhysics(),
          itemCount: bookingRequestStore.taxPercentage.length,
          itemBuilder: (context, index) {
            TaxPercentage taxDet = bookingRequestStore.taxPercentage[index];
            num taxAmt = 0.0;
            if (taxDet.type == TaxType.PERCENT) {
              num baseAmount = bookingRequestStore.isCouponApplied ? bookingRequestStore.calculateSelectedServiceTotalAmountWithCouponDiscount : bookingRequestStore.selectedServiceTotalAmount;
              taxAmt = num.parse(((baseAmount * taxDet.percent.validate()) / 100).toString());
            } else {
              taxAmt = taxDet.taxAmount ?? 0.0;
            }
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(taxDet.name.toString() + '${taxDet.type == TaxType.PERCENT ? '(${taxDet.percent.validate()}%)' : ''}', style: secondaryTextStyle(color: Colors.white70)),
                PriceWidget(price: taxAmt.validate(), color: white, size: 12),
              ],
            ).paddingSymmetric(vertical: 4);
          },
        ),
      ],
    ),
  );
}
