import 'package:flutter/material.dart';
import 'package:frezka/components/view_all_label_component.dart';
import 'package:frezka/main.dart';
import 'package:frezka/utils/colors.dart';
import 'package:frezka/utils/common_base.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../../utils/constants.dart';
import '../model/order_detail_response.dart';

class OrderInformationComponent extends StatelessWidget {
  final OrderListData orderData;

  OrderInformationComponent({required this.orderData});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ViewAllLabel(label: locale.shippingDetail, isShowAll: false, labelSize: 16),
          ],
        ),
        Container(
          decoration: boxDecorationDefault(color: context.cardColor, borderRadius: radius(4), border: Border.all(color: borderColor, width: 0.5)),
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildShippingSection(),
              20.height,
              Divider(color: context.dividerColor, height: 1),
              20.height,
              ..._buildDynamicTimeline(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildShippingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.location_on_outlined, size: 16, color: Colors.grey[600]),
            8.width,
            Text(
              locale.shippingTo,
              style: secondaryTextStyle(
                size: 14,
                weight: FontWeight.w400,
              ),
            ),
          ],
        ),
        12.height,
        Text(
          _getShippingName(),
          style: boldTextStyle(
            size: 14,
            weight: FontWeight.w600,
          ),
        ),
        4.height,
        Text(
          _getShippingAddress(),
          style: boldTextStyle(
            size: 14,
            weight: FontWeight.w600,
          ),
        ),
        4.height,
        Text(
          _getShippingPhone(),
          style: boldTextStyle(
            size: 14,
            weight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineItem({
    required IconData icon,
    required String title,
    required String date,
    required bool isCompleted,
    required bool isActive,
    bool showConnector = false,
  }) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: boxDecorationWithRoundedCorners(
                    backgroundColor: isCompleted ? Colors.green : Colors.grey[300] ?? Colors.grey,
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                if (showConnector) ...[
                  4.height,
                  Container(
                    width: 2,
                    height: 20,
                    color: isCompleted ? Colors.green : Colors.grey[300],
                  ),
                ],
              ],
            ),
            12.width,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: boldTextStyle(
                      size: 14,
                      weight: FontWeight.w600,
                    ),
                  ),
                  if (date.isNotEmpty) ...[
                    4.height,
                    Text(
                      date,
                      style: secondaryTextStyle(
                        size: 12,
                        weight: FontWeight.w400,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        if (showConnector) 16.height,
      ],
    );
  }

  // Dynamic timeline builder
  List<Widget> _buildDynamicTimeline() {
    List<Widget> timelineItems = [];

    if(orderData.orderHistory.isEmpty) {
      // Always show Order Placed
      timelineItems.add(_buildTimelineItem(
        icon: Icons.shopping_cart_outlined,
        title: locale.orderPlaced,
        date: orderData.orderingDate,
        isCompleted: true,
        isActive: true,
        showConnector: _shouldShowDelivered(),
      ));

      if (_shouldShowDelivered()) {
        timelineItems.add(_buildTimelineItem(
          icon: Icons.check_circle_outline,
          title: locale.orderDeliveredOn,
          date: _getDeliveredDate(),
          isCompleted: _isDelivered(),
          isActive: _isDelivered(),
          showConnector: true,
        ));
      }
    } else {
      for (var element in orderData.orderHistory.reversed) {
        timelineItems.add(_buildTimelineItem(
          icon: Icons.check_circle_outline,
          title: element.status,
          date: formatDate(element.dateTime, format: DateFormatConst.BOOK_DATE_FORMAT, isLocal: true),
          isCompleted: true,
          isActive: true,
          showConnector: orderData.orderHistory.length > 1,
        ));
      }
    }

    // Add Payment to timeline
    timelineItems.add(_buildPaymentTimelineItem());

    return timelineItems;
  }

  Widget _buildPaymentTimelineItem() {
    bool isPaid = orderData.paymentStatus == SERVICE_PAYMENT_STATUS_PAID;
    String paymentMethod = orderData.paymentMethod.validate().capitalizeFirstLetter();

    return Column(
      children: [
        8.height,
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: boxDecorationWithRoundedCorners(
                    backgroundColor: isPaid ? Colors.green : Colors.orange,
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ],
            ),
            12.width,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    locale.payment,
                    style: boldTextStyle(
                      size: 14,
                      weight: FontWeight.w600,
                    ),
                  ),
                  4.height,
                  Row(
                    children: [
                      Text(
                        '$paymentMethod - ',
                        style: secondaryTextStyle(
                          size: 12,
                          weight: FontWeight.w400,
                        ),
                      ),
                      Text(
                        isPaid ? locale.paid : locale.unpaid,
                        style: boldTextStyle(
                          size: 12,
                          weight: FontWeight.w600,
                          color: isPaid ? Colors.green : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Helper methods for dynamic status checking

  bool _shouldShowDelivered() {
    return orderData.deliveryStatus == OrderStatusConst.DELIVERED;
  }


  bool _isDelivered() {
    return orderData.deliveryStatus == OrderStatusConst.DELIVERED;
  }



  String _getDeliveredDate() {
    if (_isDelivered()) {
      return orderData.deliveringDate.validate();
    }
    return '';
  }

  String _getShippingName() {
    if (orderData.userName.validate().isNotEmpty) {
      return orderData.userName.validate();
    }
    return locale.customerName;
  }

  String _getShippingAddress() {
    List<String> addressParts = [];

    if (orderData.addressLine1.validate().isNotEmpty) {
      addressParts.add(orderData.addressLine1.validate());
    }
    if (orderData.addressLine2.validate().isNotEmpty) {
      addressParts.add(orderData.addressLine2.validate());
    }
    if (orderData.city.validate().isNotEmpty) {
      addressParts.add(orderData.city.validate());
    }
    if (orderData.state.validate().isNotEmpty) {
      addressParts.add(orderData.state.validate());
    }
    if (orderData.postalCode.validate().isNotEmpty) {
      addressParts.add(orderData.postalCode.validate());
    }

    if (addressParts.isNotEmpty) {
      return addressParts.join(', ');
    }
    return locale.addressNotAvailable;
  }

  String _getShippingPhone() {
    if (orderData.phoneNo.validate().isNotEmpty) {
      return orderData.phoneNo.validate();
    }
    return '+91 0000000000';
  }
}
