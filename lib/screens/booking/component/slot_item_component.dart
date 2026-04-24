import 'package:flutter/material.dart';
import 'package:frezka/main.dart';
import 'package:frezka/screens/branch/model/branch_configuration_response.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../utils/colors.dart';
import '../../../utils/common_base.dart';

class SlotItemComponent extends StatefulWidget {
  final SlotData timeSlot;
  final bool isSelected;
  final DateTime selectedHorizontalDate;
  final VoidCallback? onTap;
  final String? selectedTime;
  final bool isFromBooking;

  SlotItemComponent(
      {required this.timeSlot,
      required this.isSelected,
      this.onTap,
      required this.selectedHorizontalDate,
      this.selectedTime,
      this.isFromBooking = false});

  @override
  State<SlotItemComponent> createState() => _SlotItemComponentState();
}

class _SlotItemComponentState extends State<SlotItemComponent> {
  @override
  Widget build(BuildContext context) {
    final bool isAvailable =
        widget.timeSlot.slotAvailability(widget.selectedHorizontalDate);

    return GestureDetector(
      onTap: () async {
        widget.onTap?.call();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: widget.isSelected
              ? appStore.isDarkMode
                  ? transparentColor
                  : primaryLightColor
              : context.cardColor,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color: widget.isSelected
                ? primaryColor
                : isAvailable
                    ? appStore.isDarkMode
                        ? borderColor
                        : appTextSecondaryColor
                    : appStore.isDarkMode
                        ? appTextSecondaryColor
                        : borderColor,
            width: 0.5,
          ),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            formatOnlyTime(context, startTime: widget.timeSlot.startTime),
            maxLines: 1,
            softWrap: false,
            style: primaryTextStyle(
              size: 12,
              weight: FontWeight.w600,
              color: widget.isSelected
                  ? primaryColor
                  : isAvailable
                      ? appStore.isDarkMode
                          ? borderColor
                          : appTextSecondaryColor
                      : appStore.isDarkMode
                          ? appTextSecondaryColor
                          : borderColor,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
