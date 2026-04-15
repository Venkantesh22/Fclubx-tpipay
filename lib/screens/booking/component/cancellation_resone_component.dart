import 'package:flutter/material.dart';
import 'package:frezka/main.dart';
import 'package:frezka/utils/colors.dart';
import 'package:nb_utils/nb_utils.dart';

import '../model/booking_list_response.dart';

class CancellationReasonComponent extends StatelessWidget {
  final BookingListData booking;
  const CancellationReasonComponent({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(locale.cancellationReason, style: boldTextStyle()),

        const SizedBox(height: 8),

        // Card box
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cancelled on text
              Text(booking.cancellationDate.validate(), style: primaryTextStyle(color: Colors.red)),
              8.height,

              // Reason text
              Text(booking.cancellationReason.validate(), style: secondaryTextStyle()),
            ],
          ),
        ),
      ],
    );
  }
}
