import 'package:flutter/material.dart';
import 'package:frezka/components/cached_image_widget.dart';
import 'package:frezka/components/price_widget.dart';
import 'package:frezka/utils/colors.dart';
import 'package:frezka/utils/common_base.dart';
import 'package:frezka/utils/constants.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../components/view_all_label_component.dart';
import '../../../main.dart';
import '../../dashboard/component/booking_list_component.dart';
import '../model/booking_list_response.dart';
import '../view/booking_detail_screen.dart';
import '../view/complete_payment_screen.dart';

class PaymentInformationComponent extends StatefulWidget {
  final BookingListData booking;

  PaymentInformationComponent({required this.booking});

  @override
  State<PaymentInformationComponent> createState() => _PaymentInformationComponentState();
}

class _PaymentInformationComponentState extends State<PaymentInformationComponent> {
  bool isPackage = false;
  double subtotal = 0.0;
  bool isTaxExpanded = false;

  @override
  void initState() {
    super.initState();
    if (widget.booking.packages != null && widget.booking.packages!.isNotEmpty) {
      isPackage = widget.booking.packages!.isNotEmpty;
    }
    subtotal = isPackage ? widget.booking.sumOfPackagesPrices.validate() - widget.booking.couponAmount.validate().toDouble() : widget.booking.sumOfServicePrices.validate() - widget.booking.couponAmount.validate().toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ViewAllLabel(
          label: locale.paymentDetails,
          trailingTextColor: Colors.red,
          isShowAll: false,
          onTap: () {},
        ),

        /// --------- PRICE DETAILS CARD ----------
        Container(
          decoration: boxDecorationDefault(
            color: context.cardColor,
            borderRadius: radius(12),
            border: Border.all(color: lightGreyColor, width: 1),
          ),
          padding: EdgeInsets.all(16),
          margin: EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Payment Method card (like screenshot top box)
              if (widget.booking.payment != null) ...[
                Container(
                  decoration: boxDecorationDefault(
                    color: appStore.isDarkMode ? territoryButtonDarkColor : territoryButtonColor,
                    borderRadius: radius(6),
                    border: Border.all(color: beigeColor, width: 0.8),
                  ),
                  padding: EdgeInsets.all(12),
                  margin: EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: lightGreyColor, width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: CachedImageWidget(
                            url: getPaymentMethodIcon(widget.booking.payment!.transactionType.validate().toLowerCase()),
                            height: 20,
                            width: 20,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      12.width,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(locale.paymentMethod, style: secondaryTextStyle(size: 12)),
                          Text(
                            widget.booking.payment!.transactionType.validate().capitalizeFirstLetter(),
                            style: boldTextStyle(size: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],

              /// Subtotal (Service price)
              _buildRow(locale.total, widget.booking.sumOfServicePrices.validate().toDouble(), color: textPrimaryColorGlobal),

              /// Package Amount (if applicable)
              if (isPackage)
                _buildRow(
                  '${locale.package} ${locale.total}',
                  widget.booking.sumOfPackagesPrices.validate() - widget.booking.couponAmount.validate(),
                  color: textPrimaryColorGlobal,
                ),

              /// Coupon Discount
              if (widget.booking.couponAmount.validate() != 0) _buildRow(locale.couponDiscount, -widget.booking.couponAmount.validate(), color: Colors.green),
              
              if (widget.booking.couponAmount.validate() != 0) _buildRow(locale.subtotal, widget.booking.sumOfServicePrices.validate().toDouble() - widget.booking.couponAmount.validate(), color: textPrimaryColorGlobal),

              /// Product Amount
              if (widget.booking.sumOfProductPrices != 0) _buildRow(locale.productAmount, widget.booking.sumOfProductPrices.validate(), color: textPrimaryColorGlobal),

              /// Taxes - Collapsible Section
              if (widget.booking.taxDetails != null && widget.booking.taxDetails!.isNotEmpty) ...[
                8.height,
                // Tax header row with dropdown
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isTaxExpanded = !isTaxExpanded;
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
                          Icon(
                            isTaxExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                            color: context.iconColor,
                            size: 18,
                          ),
                          8.width,
                          PriceWidget(price: widget.booking.taxDetails!.fold(0.0, (sum, tax) => sum + tax.taxAmount.validate()).validate(), color: taxAmountColor, size: 14),
                        ],
                      ),
                    ],
                  ),
                ),
                8.height,

                // Expandable tax details
                AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  height: isTaxExpanded ? null : 0,
                  child: isTaxExpanded
                      ? Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: context.scaffoldBackgroundColor,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: borderColor, width: 0.5),
                          ),
                          child: Column(
                            children: widget.booking.taxDetails!.map((tax) {
                              String title = tax.taxName.validate();
                              if (tax.taxType != TaxType.FIXED) {
                                title += ' (${tax.taxValue}%)';
                              }
                              return Padding(
                                padding: EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      title,
                                      style: secondaryTextStyle(size: 12),
                                    ),
                                    PriceWidget(price: tax.taxAmount.validate(), color: taxAmountColor, size: 12),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        )
                      : SizedBox.shrink(),
                ),
              ],

              /// Tip
              Builder(
                builder: (context) {
                  if ((widget.booking.payment?.tipAmount != null && widget.booking.payment!.tipAmount! > 0) || (widget.booking.tip != null && widget.booking.tip! > 0)) {
                    return _buildRow(locale.tip, widget.booking.payment?.tipAmount ?? widget.booking.tip ?? 0, color: Colors.green);
                  }
                  return SizedBox.shrink();
                },
              ),

              Divider(
                color: context.dividerColor,
                thickness: 1,
                height: 24,
              ),

              /// Total
              _buildRow(locale.total, widget.booking.totalAmount.validate(), color: Colors.purple, isBold: true),
            ],
          ),
        ),

        /// --------- ONLY PAY NOW BUTTON ----------
        if (widget.booking.status == BookingStatusConst.COMPLETED && (widget.booking.payment == null || widget.booking.payment!.paymentStatus == 0))
          Column(
            children: [
              16.height,
              AppButton(
                text: locale.payNow,
                textColor: white,
                color: secondaryColor,
                width: context.width(),
                onTap: () async {
                  bool? res = await CompletePaymentScreen(widget.booking).launch(context);

                  if (res ?? false) {
                    onBookingDetailUpdate.call();
                    onBookingListUpdate.call('');
                  }
                },
              ),
            ],
          ),
      ],
    );
  }

  /// helper row builder
  Widget _buildRow(String title, num value, {Color? color, bool isBold = false, String? customText}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: isBold ? boldTextStyle(size: 16) : secondaryTextStyle(size: 14)),
          customText != null ? Text(customText, style: isBold ? boldTextStyle(size: 16, color: color ?? textPrimaryColorGlobal) : primaryTextStyle(size: 14)) : PriceWidget(price: value, color: color ?? primaryColor, size: 14, isBoldText: isBold),
        ],
      ),
    );
  }
}
