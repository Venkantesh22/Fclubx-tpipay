import 'package:flutter/material.dart';
import 'package:frezka/components/price_widget.dart';
import 'package:frezka/components/view_all_label_component.dart';
import 'package:frezka/utils/colors.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../main.dart';
import '../model/booking_list_response.dart';

class ServiceInformationComponent extends StatefulWidget {
  final BookingListData booking;

  ServiceInformationComponent({required this.booking});

  @override
  State<ServiceInformationComponent> createState() => _ServiceInformationComponentState();
}

class _ServiceInformationComponentState extends State<ServiceInformationComponent> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ViewAllLabel(
          label: locale.services,
          trailingTextColor: Colors.red,
          isShowAll: false,
        ),
        Container(
          decoration: boxDecorationDefault(color: context.cardColor, border: Border.all(color: Colors.grey.shade300, width: 1)),
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ///  Show each service with price
              if (widget.booking.packages != null && widget.booking.packages!.isNotEmpty)
                Container(
                  padding: EdgeInsets.only(bottom: 12, top: 12, left: 12, right: 12),
                  decoration: boxDecorationDefault(color: territoryButtonColor, borderRadius: BorderRadius.circular(4), border: Border.all(color: beigeColor, width: 0.8)),
                  child: Row(
                    children: [
                      Text(
                        "✨",
                        style: TextStyle(fontSize: 15),
                      ),
                      4.width,
                      Expanded(
                        child: Text(
                          locale.membershipIncludesAllServices,
                          style: boldTextStyle(
                            size: 10,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      8.height,
                    ],
                  ),
                ),
              ...?widget.booking.serviceList?.map((service) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(service.serviceName.validate() + ":", style: secondaryTextStyle(), maxLines: 2, overflow: TextOverflow.ellipsis),
                      PriceWidget(
                        price: service.servicePrice.validate(),
                        color: appStore.isDarkMode ? white : blackColor,
                        size: 14,
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ],
    );
  }
}
