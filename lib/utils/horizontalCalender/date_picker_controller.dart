import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

///controller for scrolling the [HorizontalDatePickerWidget]
class DatePickerController {
  DatePickerController({required this.startDate, required this.endDate});
  ///scroll to current selected date's position
  ///[isEnableAnimation] default set as true, jump with animation
  void scrollToSelectedItem(DateTime selectedDate, [bool isEnableAnimation = true]) {
    int index = selectedDate.difference(startDate).inDays;
    _scrollToSpecificDateByIndex(index);
  }


  ///check date within the start and end date range
  bool isWithinRange(DateTime dateTime) {
    return !(DateTime.now().startOfDay.difference(dateTime).inSeconds > 0);    
  }

  ///FIELD: basically for internal use,
  ///if no need to customize as own picker, the following should have no need to modify
  ScrollController scrollController = ScrollController();

  ///padding + width of Item
  double itemWidth = 0;

  DateTime startDate;
  DateTime endDate;

  ///[index]  listview index
  ///[isEnableAnimation] default set as true, jump with animation
  void _scrollToSpecificDateByIndex(int index) {
    scrollController.animateTo((index * 80), duration: const Duration(milliseconds: 300), curve: Curves.linear);
  }
}
