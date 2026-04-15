import 'package:flutter/material.dart';
import 'package:frezka/screens/order/model/order_detail_response.dart';
import 'package:frezka/utils/colors.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../components/price_widget.dart';
import '../../../components/view_all_label_component.dart';
import '../../../main.dart';
import '../../../utils/constants.dart';

class OrderPaymentInfoComponent extends StatelessWidget {
  final OrderListData orderData;

  OrderPaymentInfoComponent({required this.orderData});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Payment Details Section
        ViewAllLabel(label: locale.priceDetails, isShowAll: false, labelSize: 14),
        Container(
          decoration: boxDecorationDefault(color: context.cardColor),
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // if (orderData.paymentMethod.validate().isNotEmpty)
              //   SettingItemWidget(
              //     title: locale.paymentMethod,
              //     titleTextStyle: secondaryTextStyle(),
              //     padding: EdgeInsets.zero,
              //     trailing: Marquee(
              //       child: Text(
              //         orderData.paymentMethod.validate().capitalizeFirstLetter(),
              //         style: primaryTextStyle(size: 14),
              //       ),
              //     ),
              //   ).paddingBottom(10),

              // SettingItemWidget(
              //   title: locale.paymentStatus,
              //   titleTextStyle: secondaryTextStyle(),
              //   padding: EdgeInsets.zero,
              //   trailing: Marquee(
              //     child: PriceWidget(
              //       price: 0,
              //       priceText: getBookingPaymentStatus(status: orderData.paymentStatus.validate()),
              //       color: orderData.paymentStatus.validate().toLowerCase() == SERVICE_PAYMENT_STATUS_PAID ? greenColor : wishListColor,
              //       size: 14,
              //     ),
              //   ),
              // ),
              // Divider(height: 20),

              /// Subtotal
              SettingItemWidget(
                title: locale.subtotal,
                titleTextStyle: secondaryTextStyle(),
                padding: EdgeInsets.zero,
                trailing: Marquee(
                  child: PriceWidget(
                    price: orderData.subTotalAmount.validate(),
                    color: textPrimaryColorGlobal,
                    size: 14,
                  ),
                ),
              ),
              10.height,

              /// Tax Details - Show individual taxes with names and amounts
              if (orderData.taxDetails != null && orderData.taxDetails!.isNotEmpty)
                ...orderData.taxDetails!.map((taxDetail) {
                  return SettingItemWidget(
                    title: '${taxDetail.taxName.validate()} ${taxDetail.taxType == TaxType.PERCENT ? '(${taxDetail.taxValue.validate()}%)' : ''}',
                    titleTextStyle: secondaryTextStyle(),
                    padding: EdgeInsets.zero,
                    trailing: Marquee(
                      child: PriceWidget(
                        price: taxDetail.taxAmount.validate(),
                        size: 14,
                        color: textPrimaryColorGlobal,
                      ),
                    ),
                  ).paddingBottom(10);
                }).toList()
              else if (orderData.totalTaxAmount != null && orderData.totalTaxAmount! > 0)
                SettingItemWidget(
                  title: locale.tax,
                  titleTextStyle: secondaryTextStyle(),
                  padding: EdgeInsets.zero,
                  trailing: Marquee(
                    child: PriceWidget(
                      price: orderData.totalTaxAmount.validate(),
                      size: 14,
                      color: textPrimaryColorGlobal,
                    ),
                  ),
                ).paddingBottom(10),

              /// Delivery Charge
              if (orderData.standardDeliverycharge != 0 && orderData.standardDeliverycharge != null)
                SettingItemWidget(
                  title: locale.deliveryCharge,
                  titleTextStyle: secondaryTextStyle(),
                  padding: EdgeInsets.zero,
                  trailing: Marquee(
                    child: PriceWidget(
                      price: orderData.standardDeliverycharge.validate(),
                      color: textPrimaryColorGlobal,
                      size: 14,
                    ),
                  ),
                ).paddingBottom(10),

              /// Total Amount (highlighted)
              SettingItemWidget(
                title: locale.total,
                titleTextStyle: boldTextStyle(),
                padding: EdgeInsets.zero,
                trailing: Marquee(
                  child: PriceWidget(
                    price: orderData.totalAmount.validate(),
                    color: primaryColor,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        ),

        8.height,

        /// Delivery Address Section
      ],
    );
  }
}
