import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frezka/components/app_scaffold.dart';
import 'package:frezka/components/custom_stepper.dart';
import 'package:frezka/components/slot_widget.dart';
import 'package:frezka/components/view_all_label_component.dart';
import 'package:frezka/main.dart';
import 'package:frezka/utils/colors.dart';
import 'package:frezka/utils/common_base.dart';
import 'package:frezka/utils/constants.dart';
import 'package:frezka/utils/custom_toast_widget.dart';
import 'package:frezka/utils/extensions/date_extensions.dart';
import 'package:frezka/utils/extensions/int_extension.dart';
import 'package:frezka/utils/horizontalCalender/date_item.dart';
import 'package:frezka/utils/horizontalCalender/date_picker_controller.dart';
import 'package:frezka/utils/horizontalCalender/horizontal_date_picker.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../components/common_bottom_price_widget.dart';
import '../../../components/empty_error_state_widget.dart';
import '../../../components/loader_widget.dart';
import '../../../utils/app_common.dart';
import '../../branch/branch_repository.dart';
import '../../branch/model/branch_configuration_response.dart';
import '../../services/models/service_response.dart';
import '../booking_repository.dart';
import '../shimmer/booking_step2_shimmer.dart';
import '../view/booking_detail_screen.dart';

class BookingStep2Component extends StatefulWidget {
  final bool isFromBookingInfoDetail;
  final bool isReschedule;
  final int? bookingId;
  final int? employeeId;
  final String? selectedDate;
  final String? selectedTime;
  final List<ServiceListData>? serviceList;

  final int? branchId;

  BookingStep2Component({
    this.isFromBookingInfoDetail = false,
    this.bookingId,
    this.serviceList,
    this.employeeId,
    this.isReschedule = false,
    this.selectedDate,
    this.selectedTime,
    this.branchId,
  });

  @override
  _BookingStep2ComponentState createState() => _BookingStep2ComponentState();
}

class _BookingStep2ComponentState extends State<BookingStep2Component> {
  late DatePickerController _datePickerController;

  UniqueKey keyForSlotWidget = UniqueKey();

  Future<BranchConfigurationResponse>? future;

  DateTime selectedHorizontalDate = DateTime.now();
  bool loading = false;

  List<String> monthList = List.generate(12, (index) => (index + 1).toMonthName());
  DateTime currentMonthNumber = DateTime.now().startOfMonth;
  DateTime selectedMonthIndex = DateTime.now().startOfMonth;

  String startTime = DEFAULT_SLOT_INTERVAL_DURATION;
  String endTime = DEFAULT_SLOT_INTERVAL_DURATION;

  @override
  void initState() {
    super.initState();
    _datePickerController = DatePickerController(
      startDate: DateTime.now().startOfMonth,
      endDate: DateTime.now().startOfMonth.add(const Duration(days: 32)).startOfMonth,
    );
    init();

    DateFormat inputFormat = DateFormat(DateFormatConst.BOOK_DATE_FORMAT);

    selectedHorizontalDate = widget.selectedDate != null && inputFormat.parse(widget.selectedDate!).isAfter(DateTime.now()) ? inputFormat.parse(widget.selectedDate!) : DateTime.now();
    bookingRequestStore.setDateInRequest(selectedHorizontalDate.setFormattedDate(DateFormatConst.DATE_FORMAT_5).toString());
    bookingRequestStore.setCouponApplied(false);
    if (widget.isFromBookingInfoDetail) {
      bookingRequestStore.time = "";
    }
  }

  void init() async {
    future = getBranchConfiguration(
      widget.branchId ?? appStore.branchId.validate(),
      employeeId: bookingRequestStore.employeeId,
    );
  }

  void setCustomDate() {
    _datePickerController.startDate = selectedMonthIndex;
    _datePickerController.endDate = selectedMonthIndex.add(Duration(days: 31)).startOfMonth;

    setState(() {});

    final now = DateTime.now();
    if(selectedMonthIndex == currentMonthNumber) {
      _datePickerController.scrollToSelectedItem(DateTime(now.year, now.month, now.day));
      return;
    }

    _datePickerController.scrollToSelectedItem(DateTime.now().startOfMonth);
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      showAppBar: widget.isFromBookingInfoDetail ? true : false,
      appBarWidget: commonAppBarWidget(
        context,
        title: '${locale.date} & ${locale.time}',
        appBarHeight: 70,
        roundCornerShape: true,
        showLeadingIcon: true,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Stack(
            children: [
              SnapHelperWidget(
                future: future,
                loadingWidget: BookingStep2Shimmer(isFromBookingInfoDetail: widget.isFromBookingInfoDetail),
                errorBuilder: (error) {
                  return NoDataWidget(
                    title: error,
                    retryText: locale.reload,
                    imageWidget: ErrorStateWidget(),
                    onRetry: () {
                      appStore.setLoading(true);

                      init();
                      setState(() {});
                    },
                  );
                },
                onSuccess: (snap) {
                  if (snap.data == null) {
                    return NoDataWidget(
                      title: locale.noTimeSlots,
                      retryText: locale.reload,
                      onRetry: () {
                        appStore.setLoading(true);
                        init();
                        setState(() {});
                      },
                    );
                  }

                  bool isSelectedDateHoliday = false;
                  bool isSelectedDateFestival = false;

                  final slotList = snap.data!.slot.validate();
                  final selectedWeekDay = selectedHorizontalDate.weekday.getWeekDayName;

                  final slotForSelectedDay = slotList.firstWhere(
                    (element) => element.day == selectedWeekDay,
                    orElse: () => SlotData(), // Safe fallback
                  );

                  if (slotForSelectedDay.day == selectedWeekDay && slotForSelectedDay.isHoliday == 1) {
                    isSelectedDateHoliday = true;
                  }

                  isSelectedDateFestival = slotList.any(
                    (slot) =>
                        slot.isFestival == 1 &&
                        slot.date != null &&
                        DateTime.tryParse(slot.date!)?.isAtSameMomentAs(
                              DateTime(selectedHorizontalDate.year, selectedHorizontalDate.month, selectedHorizontalDate.day),
                            ) ==
                            true,
                  );

                  final weekDay = selectedHorizontalDate.weekday;
                  if(slotList.length >= weekDay) {
                  final slot = slotList[weekDay - 1];
                    if(slot.isDayOff == 1) {
                      selectedHorizontalDate = selectedHorizontalDate.add(const Duration(days: 1));
                      selectedMonthIndex = selectedHorizontalDate.startOfMonth;
                      WidgetsBinding.instance.addPostFrameCallback((_) => setCustomDate());
                    }
                  }

                  
                  if(!isSelectedDateHoliday) {
                    final date = selectedHorizontalDate.setFormattedDate('yyyy-MM-dd');
                    isSelectedDateFestival = snap.data?.holidayDays.contains(date) ?? false;
                  }

                  if (snap.data!.slot.validate().any((element) => element.day == selectedWeekDay)) {
                    startTime = snap.data!.slot.validate().firstWhere((element) => element.day == selectedWeekDay).startTime.validate();
                    endTime = snap.data!.slot.validate().firstWhere((element) => element.day == selectedWeekDay).endTime.validate();
                  }
                  return AnimatedScrollView(
                    padding: EdgeInsets.only(
                      left: 20,
                      right: 20,
                      top: widget.isFromBookingInfoDetail ? 10 : 60,
                      bottom: widget.isFromBookingInfoDetail ? 80 : 80,
                    ),
                    onSwipeRefresh: () async {
                      init();
                      setState(() {});
                      return await Future.delayed(Duration(seconds: 2));
                    },
                    children: [
                      ViewAllLabel(label: locale.date, isShowAll: false),
                      8.height,
                      Container(
                        decoration: boxDecorationWithRoundedCorners(
                          backgroundColor: context.cardColor,
                          borderRadius: radius(),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SettingItemWidget(
                              title: '${monthList[selectedMonthIndex.month - 1]} ${selectedMonthIndex.year}',
                              titleTextStyle: boldTextStyle(size: 14, color: textSecondaryColorGlobal),
                              padding: EdgeInsets.zero,
                              trailing: Row(
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      if (selectedMonthIndex.difference(currentMonthNumber).inDays == 0) {
                                        //
                                      } else {
                                        selectedMonthIndex = selectedMonthIndex.removeDays(1).startOfMonth;
                                        setCustomDate();
                                      }
                                    },
                                    icon: Icon(
                                      Icons.arrow_back_ios,
                                      size: ICON_SIZE,
                                      color: selectedMonthIndex.difference(currentMonthNumber).inDays == 0 ? grey : context.iconColor,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      if (selectedMonthIndex.difference(currentMonthNumber).inDays >= (365 - 31)) {
                                        //
                                      } else {
                                        selectedMonthIndex = selectedMonthIndex.addDays(31).startOfMonth;
                                        setCustomDate();
                                      }
                                    },
                                    icon: Icon(
                                      Icons.arrow_forward_ios_sharp,
                                      size: ICON_SIZE,
                                      color: selectedMonthIndex.difference(currentMonthNumber).inDays >= (365 - 31) ? grey : context.iconColor,
                                    ),
                                  ),
                                ],
                              ),
                            ).paddingOnly(left: 16),
                            Divider(height: 0, color: context.dividerColor),
                            HorizontalDatePickerWidget(
                              datePickerController: _datePickerController,
                              height: 90,
                              width: 60,
                              monthFontSize: 12,
                              startDate: selectedMonthIndex,
                              endDate: selectedMonthIndex.add(Duration(days: 31)).startOfMonth,
                              selectedDate: selectedHorizontalDate,
                              widgetWidth: context.width(),
                              selectedColor: isSelectedDateHoliday
                                  ? Colors.lightGreen.shade200
                                  : isSelectedDateFestival
                                      ? Colors.lightGreen
                                      : primaryLightColor,
                              selectedTextColor: context.primaryColor,
                              normalColor: context.cardColor,
                              disabledColor: appStore.isDarkMode ? scaffoldSecondaryDark : Colors.grey[200]!,
                              normalTextColor: dateSlotColor,
                              dateItemComponentList: [DateItem.WeekDay, DateItem.Day],
                              dayFontSize: 16,
                              weekDayFontSize: 12,
                              isDateDisabled: (date) {
                                if(!isSelectedDateHoliday) {
                                  final dateFormate = date.setFormattedDate('yyyy-MM-dd');
                                  final isSelectedDateHoliday = snap.data?.holidayDays.contains(dateFormate) ?? false;
                                  if(isSelectedDateHoliday) return true;
                                }
                                final weekDay = date.weekday;
                                if(slotList.length < weekDay) {
                                  return false;
                                }
                                final slot = slotList[weekDay - 1];
                                if(slot.isDayOff == 1) {
                                  return true;
                                }
                                return false;
                              },
                              onValueSelected: (date) {
                                selectedHorizontalDate = date;
                        
                                if (slotList.any((element) => element.day == selectedHorizontalDate.weekday.getWeekDayName)) {
                                  startTime = slotList.firstWhere((element) => element.day == selectedHorizontalDate.weekday.getWeekDayName).startTime.validate();
                                  endTime = slotList.firstWhere((element) => element.day == selectedHorizontalDate.weekday.getWeekDayName).endTime.validate();
                                }
                        
                                keyForSlotWidget = UniqueKey();
                                bookingRequestStore.setTimeInRequest('');
                                bookingRequestStore.setDateInRequest(selectedHorizontalDate.setFormattedDate(DateFormatConst.DATE_FORMAT_5).toString());
                                setState(() {});
                              },
                            ).paddingSymmetric(vertical: 5),
                          ],
                        ),
                      ),
                      16.height,
                      ...(isSelectedDateHoliday || isSelectedDateFestival
                          ? [
                              Center(
                                  child: Text(locale.noSlotsAreAvailableOnTheSelectedDateDueToAHoliday,
                                      textAlign: TextAlign.center,
                                      style: boldTextStyle(
                                        color: Colors.red,
                                      ))).paddingSymmetric(vertical: 30),
                            ]
                          : [
                              ViewAllLabel(label: locale.availableSlots, isShowAll: false),
                              8.height,
                              SlotWidget(
                                selectedTime: widget.selectedTime,
                                key: keyForSlotWidget,
                                selectedHorizontalDate: selectedHorizontalDate,
                                startTime: startTime,
                                endTime: endTime,
                                slotDuration: snap.data!.slotDuration.validate(value: DEFAULT_SLOT_INTERVAL_DURATION),
                                workingHour: slotForSelectedDay,
                                isFromBooking: true,
                              ),
                            ]),
                    ],
                  );
                },
              ),
              if (loading) LoaderWidget().center(),
              // Observer(builder: (context) => LoaderWidget().visible(bookingRequestStore.isCouponApplied)),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Observer(
              builder: (_) => CommonBottomPriceWidget(
                title: bookingRequestStore.selectedServiceList.map((e) => widget.isReschedule ? e.serviceName.validate() : e.name.validate()).toList().join(', '),
                price: bookingRequestStore.totalAmount,
                buttonText: locale.next,
                onTap: () async {
                  await appStore.setUserWalletAmount();
                  if (bookingRequestStore.time.isNotEmpty) {
                    bookingRequestStore.setDateInRequest(selectedHorizontalDate.setFormattedDate(DateFormatConst.DATE_FORMAT_5).toString());

                    /// Slot Verify API Call
                    doIfLoggedIn(context, () async {
                      loading = true;
                      setState(() {});
                      //  appStore.setLoading(true);
                      await verifySlot(bookingRequestStore.employeeId, '${bookingRequestStore.date} ${bookingRequestStore.time}:00').then((value) {
                        log(bookingRequestStore.toJson());
                        customStepperController.nextPage(duration: Duration(milliseconds: 200), curve: Curves.easeOut);
                      }).catchError((e) {
                        ShowToast.showError(e.toString());
                      });
                      loading = false;
                      setState(() {});
                      // appStore.setLoading(false);
                    });
                  } else {
                    ShowToast.showInfo(locale.pleaseSelectTimeSlotFirst);
                  }
                },
              ),
            ),
          ).visible(!widget.isFromBookingInfoDetail),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(16),
              child: SafeArea(
                child: AppButton(
                  text: locale.update,
                  textStyle: boldTextStyle(color: Colors.white),
                  color: secondaryColor,
                  width: double.infinity,
                  onTap: () {
                    showConfirmDialogCustom(
                      context,
                      title: locale.bookingTimeSlotChangeMessage,
                      positiveText: locale.yes,
                      negativeText: locale.no,
                      onAccept: (_) {
                        List<ServiceListData> selectedService = [];

                        bookingRequestStore.setEmployeeIdInRequest(widget.employeeId.validate());
                        bookingRequestStore.setDateInRequest(selectedHorizontalDate.setFormattedDate(DateFormatConst.DATE_FORMAT_5).toString());

                        widget.serviceList.validate().forEachIndexed((element, index) {
                          selectedService.add(widget.serviceList.validate()[index]);
                        });

                        bookingRequestStore.setSelectedServiceListInRequest(selectedService);

                        String tempDate = bookingRequestStore.date.validate();
                        String tempTime = bookingRequestStore.time.validate();

                        String dateString = tempDate + " " + tempTime;

                        DateTime initialDateTime = DateTime.parse(dateString);

                        String updatedDateTime = formatDate(initialDateTime.toString(), format: DateFormatConst.NEW_FORMAT);

                        bookingRequestStore.selectedServiceList.validate().forEachIndexed((element, index) {
                          if (index == 0) {
                            element.startDateTime = formatDate(initialDateTime.toString(), format: DateFormatConst.NEW_FORMAT);
                            element.previousTime = initialDateTime;
                          } else {
                            ServiceListData previousData = bookingRequestStore.selectedServiceList.validate()[index - 1];
                            element.startDateTime = formatDate(previousData.previousTime!.add(previousData.durationMin.minutes).toString(), format: DateFormatConst.NEW_FORMAT);
                            element.previousTime = previousData.previousTime!.add(previousData.durationMin.minutes);
                          }
                        });

                        appStore.setLoading(true);

                        bookingUpdate(bookingRequestStore.toJson(dateTime: updatedDateTime, bookingId: widget.bookingId, bookingStatus: BookingStatusConst.PENDING, isUpdate: true)).then((value) {
                          appStore.setLoading(false);
                          onBookingDetailUpdate.call();
                          finish(context);
                          ShowToast.showSuccess(locale.bookingSuccessfullyUpdateMessage);
                        }).catchError((e) {
                          appStore.setLoading(false);
                          ShowToast.showError(e.toString());
                        });
                      },
                      primaryColor: context.primaryColor,
                    );
                  },
                ).visible(widget.isFromBookingInfoDetail),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
