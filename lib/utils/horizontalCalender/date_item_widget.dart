import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'date_item.dart';
import 'date_item_state.dart';

class DateItemWidget extends StatelessWidget {
  ///display [DateTime]
  final DateTime dateTime;

  ///State of the date
  final DateItemState dateItemState;

  final String locale;

  ///padding of the item widget
  final double padding;

  final double width;
  final double height;

  final double? monthFontSize;
  final double? dayFontSize;
  final double? weekDayFontSize;
  final Color? normalColor;
  final Color? selectedColor;
  final Color? disabledColor;
  final Color? normalTextColor;
  final Color? selectedTextColor;
  final Color? disabledTextColor;

  final List<DateItem> dateItemComponentList;

  DateItemWidget({
    required this.dateTime,
    required this.dateItemState,
    required this.width,
    required this.height,
    required this.dateItemComponentList,
    required this.locale,
    this.padding = 0.0,
    this.normalColor,
    this.selectedColor,
    this.disabledColor,
    this.normalTextColor,
    this.selectedTextColor,
    this.disabledTextColor,
    this.monthFontSize,
    this.dayFontSize,
    this.weekDayFontSize,
  }) : assert(dateItemComponentList.isNotEmpty, 'dateItemComponentList cannot be empty');

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width + padding,
      margin: EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      height: height,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _getContainerColorByState(dateItemState),
        borderRadius: BorderRadius.circular(12),
        border: dateItemState == DateItemState.ACTIVE ? Border.all(color: Color(0xFFE5E7EB), width: 1) : null,
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List<Widget>.generate(this.dateItemComponentList.length, (index) {
          switch (this.dateItemComponentList[index]) {
            case DateItem.WeekDay:
              return Text(DateFormat.E(this.locale).format(this.dateTime), style: TextStyle(color: _getTextColorByState(dateItemState), fontSize: this.weekDayFontSize, fontWeight: FontWeight.w500));
            case DateItem.Day:
              return Text(
                DateFormat.d().format(this.dateTime),
                style: TextStyle(color: _getTextColorByState(dateItemState), fontSize: this.dayFontSize, fontWeight: FontWeight.bold),
              );
            default:
              return Offstage();
          }
        }),
      ),
    );
  }

  Color? _getContainerColorByState(DateItemState state) {
    switch (state) {
      case DateItemState.ACTIVE:
        return normalColor;
      case DateItemState.SELECTED:
        return selectedColor;
      default:
        return disabledColor;
    }
  }

  Color? _getTextColorByState(DateItemState state) {
    switch (state) {
      case DateItemState.ACTIVE:
        return normalTextColor;
      case DateItemState.SELECTED:
        return selectedTextColor;
      default:
        return disabledTextColor;
    }
  }
}
