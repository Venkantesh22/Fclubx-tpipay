import 'package:flutter/material.dart';
import 'package:frezka/main.dart';
import 'package:frezka/utils/constants.dart';
import 'package:frezka/utils/custom_toast_widget.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';

import '../screens/booking/component/slot_item_component.dart';
import '../screens/branch/model/branch_configuration_response.dart';
import '../screens/branch/model/branch_response.dart';
import '../utils/common_base.dart';

class SlotWidget extends StatefulWidget {
  final String slotDuration;
  final String startTime;
  final String endTime;
  final DateTime selectedHorizontalDate;
  final bool isFromQuickBooking;
  final String? selectedTime;
  final SlotData? workingHour;
  final bool isFromBooking;

  const SlotWidget({
    Key? key,
    required this.slotDuration,
    required this.startTime,
    required this.endTime,
    required this.selectedHorizontalDate,
    this.workingHour,
    this.isFromQuickBooking = false,
    this.selectedTime,
    this.isFromBooking = false,
  }) : super(key: key);

  @override
  State<SlotWidget> createState() => _SlotWidgetState();
}

class _SlotWidgetState extends State<SlotWidget> {
  Future<List<SlotData>>? future;
  int selectedIndex = -1;
  String selectedSession = '';

  @override
  void initState() {
    super.initState();
    future = init();
  }

  Future<List<SlotData>> init() async {
    if (widget.isFromBooking) {
      List<SlotData> apiSlots = [];

      if (widget.workingHour?.availableSlots != null &&
          widget.workingHour!.availableSlots!.isNotEmpty) {
        for (var apiSlot in widget.workingHour!.availableSlots!) {
          try {
            SlotData slotData = SlotData();
            DateTime parsed =
                DateFormat("yyyy-MM-dd HH:mm:ss").parse(apiSlot.value!);
            slotData.startTime = DateFormat("HH:mm").format(parsed);
            slotData.previousTimeSlot = parsed;

            int hour = parsed.hour;
            if (hour >= 20 && hour < 24) {
              slotData.sessionText = locale.night;
            } else if (hour >= 6 && hour < 12) {
              slotData.sessionText = locale.morning;
            } else if (hour >= 12 && hour < 17) {
              slotData.sessionText = locale.afternoon;
            } else {
              slotData.sessionText = locale.evening;
            }

            slotData.isAvailable = !(apiSlot.disabled ?? false);
            apiSlots.add(slotData);
          } catch (e) {
            log(e.toString());
          }
        }
      } else if (widget.workingHour != null) {
        String startTimeString = widget.workingHour!.startTime.validate();
        String endTimeString = widget.workingHour!.endTime.validate();
        String timeDuration = widget.slotDuration;

        DateTime temp = widget.selectedHorizontalDate;

        startTimeString =
            '${temp.year}-${temp.month.toString().padLeft(2, '0')}-${temp.day.toString().padLeft(2, '0')} $startTimeString';
        endTimeString =
            '${temp.year}-${temp.month.toString().padLeft(2, '0')}-${temp.day.toString().padLeft(2, '0')} $endTimeString';

        DateTime startTime = DateTime.parse(startTimeString);
        DateTime endTime = DateTime.parse(endTimeString);

        Duration duration = Duration(
          hours: int.parse(timeDuration.split(':')[0]),
          minutes: int.parse(timeDuration.split(':')[1]),
        );

        while (startTime.isBefore(endTime)) {
          bool isInBreak = false;

          if (widget.workingHour?.breaks != null) {
            for (BranchBreaks breakTime in widget.workingHour!.breaks!) {
              if (breakTime.startBreak.validate().isNotEmpty &&
                  breakTime.endBreak.validate().isNotEmpty) {
                DateTime breakStart =
                    DateFormat("HH:mm").parse(breakTime.startBreak!);
                DateTime breakEnd =
                    DateFormat("HH:mm").parse(breakTime.endBreak!);

                breakStart = DateTime(startTime.year, startTime.month,
                    startTime.day, breakStart.hour, breakStart.minute);
                breakEnd = DateTime(startTime.year, startTime.month,
                    startTime.day, breakEnd.hour, breakEnd.minute);

                if (startTime.isBefore(breakEnd) &&
                    startTime.add(duration).isAfter(breakStart)) {
                  isInBreak = true;
                  break;
                }
              }
            }
          }

          if (!isInBreak) {
            SlotData slotData = SlotData();
            slotData.startTime = formatDate(startTime.toString(),
                format: DateFormatConst.HOUR_24_FORMAT);
            slotData.previousTimeSlot = startTime;

            int hour = startTime.hour;
            if (hour >= 20 && hour < 24) {
              slotData.sessionText = locale.night;
            } else if (hour >= 6 && hour < 12) {
              slotData.sessionText = locale.morning;
            } else if (hour >= 12 && hour < 17) {
              slotData.sessionText = locale.afternoon;
            } else {
              slotData.sessionText = locale.evening;
            }

            slotData.isAvailable = true;
            apiSlots.add(slotData);
          }
          startTime = startTime.add(duration);
        }
      } else {}
      return apiSlots;
    }

    List<SlotData> slots = [];
    String startTimeString = widget.startTime.validate();
    String endTimeString = widget.endTime.validate();
    String timeDuration = widget.slotDuration;

    DateTime temp = widget.selectedHorizontalDate;

    startTimeString =
        '${temp.year}-${temp.month.toString().padLeft(2, '0')}-${temp.day.toString().padLeft(2, '0')} $startTimeString';
    endTimeString =
        '${temp.year}-${temp.month.toString().padLeft(2, '0')}-${temp.day.toString().padLeft(2, '0')} $endTimeString';

    DateTime startTime = DateTime.parse(startTimeString);
    DateTime endTime = DateTime.parse(endTimeString);

    Duration duration = Duration(
      hours: int.parse(timeDuration.split(':')[0]),
      minutes: int.parse(timeDuration.split(':')[1]),
    );
    while (startTime.isBefore(endTime)) {
      bool isInBreak = false;

      if (widget.workingHour?.breaks != null) {
        for (BranchBreaks breakTime in widget.workingHour!.breaks!) {
          if (breakTime.startBreak.validate().isNotEmpty &&
              breakTime.endBreak.validate().isNotEmpty) {
            DateTime breakStart =
                DateFormat("HH:mm").parse(breakTime.startBreak!);
            DateTime breakEnd = DateFormat("HH:mm").parse(breakTime.endBreak!);

            breakStart = DateTime(startTime.year, startTime.month,
                startTime.day, breakStart.hour, breakStart.minute);
            breakEnd = DateTime(startTime.year, startTime.month, startTime.day,
                breakEnd.hour, breakEnd.minute);

            if (startTime.isBefore(breakEnd) &&
                startTime.add(duration).isAfter(breakStart)) {
              isInBreak = true;
              break;
            }
          }
        }
      }

      if (!isInBreak) {
        SlotData slotData = SlotData();
        slotData.startTime = formatDate(startTime.toString(),
            format: DateFormatConst.HOUR_24_FORMAT);
        slotData.previousTimeSlot = startTime;

        int hour = startTime.hour;
        if (hour >= 20 && hour < 24) {
          slotData.sessionText = locale.night;
        } else if (hour >= 6 && hour < 12) {
          slotData.sessionText = locale.morning;
        } else if (hour >= 12 && hour < 17) {
          slotData.sessionText = locale.afternoon;
        } else {
          slotData.sessionText = locale.evening;
        }

        slotData.isAvailable = true; // Always available in quick booking
        slots.add(slotData);
      } else {}

      startTime = startTime.add(duration);
    }
    return slots;
  }

  String formatTimeWithoutLeadingZero(String time) {
    try {
      DateTime parsedTime = DateFormat("hh:mm a").parse(time);
      return DateFormat("h:mm a").format(parsedTime);
    } catch (e) {
      return time;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: future,
      builder: (context, snap) {
        if (snap.hasError) {
          log(snap.error.toString());
        }

        if (snap.hasData) {
          List<SlotData> slots = snap.data as List<SlotData>;

          Map<String, List<SlotData>> categorizedSlots = {};
          for (SlotData slot in slots) {
            categorizedSlots.putIfAbsent(slot.sessionText.validate(), () => []);
            categorizedSlots[slot.sessionText]!.add(slot);
          }

          return Container(
            padding: const EdgeInsets.all(16),
            width: context.width(),
            decoration: boxDecorationWithRoundedCorners(
                backgroundColor: context.cardColor, borderRadius: radius()),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: categorizedSlots.entries.map((entry) {
                String sessionText = entry.key;
                List<SlotData> sessionSlots = entry.value;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(sessionText, style: boldTextStyle()),
                    10.height,
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        mainAxisExtent: 44,
                      ),
                      itemCount: sessionSlots.length,
                      itemBuilder: (context, index) {
                        SlotData timeSlot = sessionSlots[index];

                        bool isSelected = selectedIndex == index &&
                            selectedSession == timeSlot.sessionText;

                        String formattedSelectedTime = widget.selectedTime !=
                                null
                            ? formatTimeWithoutLeadingZero(widget.selectedTime!)
                            : "";

                        return SlotItemComponent(
                          selectedTime: formattedSelectedTime,
                          timeSlot: timeSlot,
                          isSelected: isSelected,
                          selectedHorizontalDate: widget.selectedHorizontalDate,
                          isFromBooking: widget.isFromBooking,
                          onTap: () {
                            if (timeSlot.slotAvailability(
                                widget.selectedHorizontalDate)) {
                              if (isSelected) {
                                selectedIndex = -1;
                                bookingRequestStore.setTimeInRequest('');
                              } else {
                                bookingRequestStore.setTimeInRequest(
                                    timeSlot.startTime.validate());
                                selectedIndex = index;
                                selectedSession =
                                    timeSlot.sessionText.validate();

                                if (widget.isFromQuickBooking) {
                                  finish(context, bookingRequestStore.time);
                                }
                              }
                            } else {
                              ShowToast.showInfo(locale.youCannotBookPrevious);
                            }
                            setState(() {});
                          },
                        );
                      },
                    ),
                    20.height,
                  ],
                );
              }).toList(),
            ),
          );
        } else {
          return snapWidgetHelper(snap, loadingWidget: Offstage());
        }
      },
    );
  }
}
