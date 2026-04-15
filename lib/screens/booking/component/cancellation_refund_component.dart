import 'package:flutter/material.dart';
import 'package:frezka/components/cached_image_widget.dart';
import 'package:frezka/components/price_widget.dart';
import 'package:frezka/utils/colors.dart';
import 'package:frezka/utils/common_base.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../components/view_all_label_component.dart';
import '../model/booking_list_response.dart';

class CancellationRefundComponent extends StatefulWidget {
  final BookingListData booking;

  CancellationRefundComponent({required this.booking});

  @override
  State<CancellationRefundComponent> createState() => _CancellationRefundComponentState();
}

class _CancellationRefundComponentState extends State<CancellationRefundComponent> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Cancellation Reason Section
        ViewAllLabel(
          label: "Cancellation Reason",
          trailingTextColor: Colors.red,
          labelTextStyle: boldTextStyle(),
          isShowAll: false,
        ),
        2.height,
        Container(
          width: context.width(),
          decoration: boxDecorationDefault(
            color: context.cardColor,
            borderRadius: radius(6),
            border: Border.all(color: Colors.grey.shade300, width: 1),
          ),
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Cancelled On ${_formatCancellationDate()}",
                style: secondaryTextStyle(size: 12, color: Colors.red),
              ),
              8.height,
              Text(
                widget.booking.cancellationReason?.validate() ?? "No reason provided",
                style: secondaryTextStyle(size: 14),
              ),
            ],
          ),
        ),

        15.height,

        /// Refund Details Section
        ViewAllLabel(
          label: "Refund Details",
          trailingTextColor: Colors.red,
          isShowAll: false,
          labelTextStyle: boldTextStyle(),
        ),
        2.height,

        /// Combined Refund Method and Price Breakdown Card
        Container(
          decoration: boxDecorationDefault(
            color: Colors.white,
            borderRadius: radius(6),
            border: Border.all(color: Colors.grey.shade300, width: 1),
          ),
          padding: EdgeInsets.only(left: 14, right: 14, top: 12, bottom: 12),
          child: Column(
            children: [
              /// Refund Method Section
              Container(
                decoration: boxDecorationDefault(
                  color: territoryButtonColor,
                  borderRadius: radius(4),
                  border: Border.all(color: Color(0xFFE5BE86), width: 0.8),
                ),
                padding: EdgeInsets.only(left: 14, right: 0, top: 0, bottom: 14),
                child: Stack(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: boxDecorationDefault(
                            color: Colors.white,
                            borderRadius: radius(20),
                            border: Border.all(color: Colors.grey.shade300, width: 1),
                          ),
                          margin: EdgeInsets.only(top: 12.0),
                          child: Center(
                            child: CachedImageWidget(
                              url: getPaymentMethodIcon(widget.booking.payment!.transactionType.validate().toLowerCase()),
                              height: 24,
                              width: 24,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        12.width,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              10.height,
                              Text(
                                "Refund To ${widget.booking.payment?.transactionType?.validate().capitalizeFirstLetter() ?? 'Original Payment Method'}",
                                style: boldTextStyle(
                                  size: 14,
                                  color: textPrimaryColorGlobal,
                                ),
                              ),
                              4.height,
                              Text(
                                "Processing In 3-5 Business Days",
                                style: secondaryTextStyle(size: 12),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    // Pending status badge positioned at top right corner
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: boxDecorationDefault(
                          color: Colors.red,
                          borderRadius: radiusOnly(
                            topRight: 4,
                            bottomLeft: 4,
                          ),
                        ),
                        child: Text(
                          "Pending",
                          style: boldTextStyle(
                            size: 10,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              20.height,

              /// Price Breakdown Section
              Column(
                children: [
                  _buildRefundRow("Original Price", widget.booking.totalAmount.validate()),
                  _buildRefundRow("Advanced Payment(10%)", widget.booking.totalAmount.validate() * 0.1),
                  _buildRefundRow("Cancellation Fee (5%)", -widget.booking.totalAmount.validate() * 0.05, isDeduction: true),
                  13.height,
                  Divider(color: Colors.grey.shade300, thickness: 2, height: 1),
                  10.height,
                  _buildRefundRow(
                    "Refund Amount",
                    widget.booking.totalAmount.validate() * 0.95, // 95% refund after 5% cancellation fee
                    isTotal: true,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRefundRow(String title, num value, {bool isDeduction = false, bool isTotal = false}) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: isTotal ? boldTextStyle(size: 16) : secondaryTextStyle(size: 14),
          ),
          PriceWidget(price: isDeduction ? -value.abs() : value, color: isDeduction ? Colors.red : (isTotal ? Colors.green : textPrimaryColorGlobal), size: 14, isBoldText: true),
        ],
      ),
    );
  }

  String _formatCancellationDate() {
    if (widget.booking.cancellationDate == null || widget.booking.cancellationDate!.isEmpty) {
      return 'N/A';
    }

    try {
      DateTime? cancellationDateTime;
      List<String> dateFormats = [
        'yyyy-MM-dd HH:mm:ss',
        'yyyy-MM-dd',
        'dd/MM/yyyy HH:mm:ss',
        'dd/MM/yyyy',
        'MM/dd/yyyy HH:mm:ss',
        'MM/dd/yyyy',
        'yyyy-MM-ddTHH:mm:ss',
        'yyyy-MM-ddTHH:mm:ssZ',
      ];

      for (String format in dateFormats) {
        try {
          cancellationDateTime = DateFormat(format).parse(widget.booking.cancellationDate!);
          break;
        } catch (e) {
          continue;
        }
      }

      if (cancellationDateTime == null) {
        return widget.booking.cancellationDate!; // Return original if parsing fails
      }

      // Format the date and time
      String formattedDate = DateFormat('dd/MM/yyyy').format(cancellationDateTime);
      String formattedTime = DateFormat('h:mm a').format(cancellationDateTime);

      return '$formattedDate At $formattedTime';
    } catch (e) {
      return widget.booking.cancellationDate!;
    }
  }
}
