import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frezka/components/app_scaffold.dart';
import 'package:frezka/components/common_bottom_price_widget.dart';
import 'package:frezka/components/custom_stepper.dart';
import 'package:frezka/components/slot_widget.dart';
import 'package:frezka/components/view_all_label_component.dart';
import 'package:frezka/screens/experts/component/employee_list_component.dart';
import 'package:frezka/utils/colors.dart';
import 'package:frezka/utils/constants.dart';
import 'package:frezka/utils/custom_toast_widget.dart';
import 'package:frezka/utils/extensions/date_extensions.dart';
import 'package:frezka/utils/extensions/int_extension.dart';
import 'package:frezka/utils/horizontalCalender/date_item.dart';
import 'package:frezka/utils/horizontalCalender/date_picker_controller.dart';
import 'package:frezka/utils/horizontalCalender/horizontal_date_picker.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../components/empty_error_state_widget.dart';
import '../../../components/loader_widget.dart';
import '../../../main.dart';
import '../../branch/branch_repository.dart';
import '../../branch/model/branch_configuration_response.dart';
import '../../experts/employee_repository.dart';
import '../../experts/model/employee_detail_response.dart';
import '../shimmer/booking_step1_shimmer.dart';

class BookingStep1Component extends StatefulWidget {
  final bool isReschedule;
  final int? branchId;

  BookingStep1Component({this.isReschedule = false, this.branchId});

  @override
  _BookingStep1ComponentState createState() => _BookingStep1ComponentState();
}

class _BookingStep1ComponentState extends State<BookingStep1Component> {
  Future<List<EmployeeData>>? future;
  Future<BranchConfigurationResponse>? branchConfigFuture;

  List<EmployeeData> expertList = [];

  int page = 1;
  int selectedIndex = -1;
  int? employeeId;

  String serviceIds = '';

  bool isLastPage = false;

  // Date and time selection variables
  late DatePickerController _datePickerController;
  UniqueKey keyForSlotWidget = UniqueKey();
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
  }

  void init() async {
    if (widget.isReschedule) {
      serviceIds = bookingRequestStore.selectedServiceList.validate().map((e) => e.serviceId.validate()).toList().join(',');
    } else {
      serviceIds = bookingRequestStore.selectedServiceList.validate().map((e) => e.id.validate()).toList().join(',');
    }

    // Initialize date in booking store
    bookingRequestStore.setDateInRequest(selectedHorizontalDate.setFormattedDate(DateFormatConst.DATE_FORMAT_5).toString());

    future = getEmployeeList(
        branchId: widget.branchId ?? appStore.branchId.validate(),
        serviceIds: serviceIds,
        page: page,
        list: expertList,
        lastPageCallBack: (p0) {
          isLastPage = p0;
        },
        selectedDate: bookingRequestStore.date,
        selectedTime: bookingRequestStore.time);

    branchConfigFuture = getBranchConfiguration(
      widget.branchId ?? appStore.branchId.validate(),
      employeeId: null,
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
      showAppBar: false,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Stack(
            children: [
              SnapHelperWidget(
                future: branchConfigFuture,
                loadingWidget: BookingStep1Shimmer(),
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
                onSuccess: (branchConfigSnap) {
                  if (branchConfigSnap.data == null) {
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

                  final slotList = branchConfigSnap.data!.slot.validate();
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
                    isSelectedDateFestival = branchConfigSnap.data?.holidayDays.contains(date) ?? false;
                  }

                  if (slotList.any((element) => element.day == selectedWeekDay)) {
                    startTime = slotList.firstWhere((element) => element.day == selectedWeekDay).startTime.validate();
                    endTime = slotList.firstWhere((element) => element.day == selectedWeekDay).endTime.validate();
                  }
                  return AnimatedScrollView(
                    padding: EdgeInsets.only(left: 20, right: 20, top: 60, bottom: 100),
                    physics: AlwaysScrollableScrollPhysics(),
                    children: [
                      // Date Selection Section
                      ViewAllLabel(
                        label: locale.selectDate,
                        isShowAll: false,
                        labelSize: 16,
                      ),
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
                                  final isSelectedDateHoliday = branchConfigSnap.data?.holidayDays.contains(dateFormate) ?? false;
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
                      10.height,
                      // Time Selection Section
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
                              ViewAllLabel(label: locale.selectTime, isShowAll: false, labelSize: 16),
                              SlotWidget(
                                selectedTime: bookingRequestStore.time,
                                key: keyForSlotWidget,
                                selectedHorizontalDate: selectedHorizontalDate,
                                startTime: startTime,
                                endTime: endTime,
                                slotDuration: branchConfigSnap.data!.slotDuration.validate(value: DEFAULT_SLOT_INTERVAL_DURATION),
                                workingHour: slotForSelectedDay,
                                isFromBooking: true,
                              ),
                            ]),
                      // Expert Selection Section
                      ViewAllLabel(label: locale.selectExpert, isShowAll: false, labelSize: 16),
                      SnapHelperWidget<List<EmployeeData>>(
                        future: future,
                        loadingWidget: BookingStep1Shimmer(),
                        onSuccess: (list) {
                          if (list.isEmpty) {
                            return NoDataWidget(
                              title: locale.noStaffFound,
                              imageWidget: EmptyStateWidget(),
                              subTitle: '${locale.noStaffAvailableForBranchMessage}\n${locale.tryToChangeYourService}',
                              retryText: locale.goBack,
                              onRetry: () {
                                finish(context);
                              },
                            );
                          }

                          return Column(
                            children: list.map((data) {
                              int index = list.indexOf(data);
                              bool isSelected = selectedIndex == index;

                              return Container(
                                child: GestureDetector(
                                  onTap: () {
                                    selectedIndex = index;
                                    if (selectedIndex == index) {
                                      employeeId = data.id.validate();
                                    }
                                    setState(() {});
                                  },
                                  child: EmployeeListComponent(
                                    expertData: data,
                                    isSelected: isSelected,
                                    showRadioButton: true,
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        },
                        errorBuilder: (error) {
                          return NoDataWidget(
                            title: error,
                            retryText: locale.reload,
                            imageWidget: ErrorStateWidget(),
                            onRetry: () {
                              page = 1;
                              appStore.setLoading(true);
                              init();
                              setState(() {});
                            },
                          );
                        },
                      ),
                    ],
                    onSwipeRefresh: () async {
                      page = 1;
                      init();
                      setState(() {});
                      return await Future.delayed(Duration(seconds: 2));
                    },
                    onNextPage: () {
                      if (!isLastPage) {
                        page++;
                        appStore.setLoading(true);
                        init();
                        setState(() {});
                      }
                    },
                  );
                },
              ),
              if (loading) LoaderWidget().center(),
            ],
          ),
          // Bottom Price Widget
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: CommonBottomPriceWidget(
              title: bookingRequestStore.selectedServiceList.map((e) => widget.isReschedule ? e.serviceName.validate() : e.name.validate()).toList().join(', '),
              price: bookingRequestStore.totalAmount,
              buttonText: locale.next,
              onTap: () {
                if (employeeId != null && bookingRequestStore.time.isNotEmpty) {
                  Fluttertoast.cancel();
                  bookingRequestStore.setEmployeeIdInRequest(employeeId!);
                  bookingRequestStore.setDateInRequest(selectedHorizontalDate.setFormattedDate(DateFormatConst.DATE_FORMAT_5).toString());
                  customStepperController.nextPage(
                    duration: Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                  );
                  setState(() {});
                } else if (employeeId == null) {
                  ShowToast.showInfo(locale.pleaseChooseYourExpert);
                } else {
                  ShowToast.showInfo(locale.pleaseSelectTimeSlotFirst);
                }
              },
            ),
          ),
          Observer(builder: (context) => LoaderWidget().visible(appStore.isLoading)),
        ],
      ),
    );
  }
}
