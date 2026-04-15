import 'package:flutter/material.dart';
import 'package:frezka/screens/branch/model/branch_response.dart';
import 'package:frezka/utils/common_base.dart';
import 'package:frezka/utils/extensions/string_extensions.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../booking/model/booking_detail_response.dart';

class BranchConfigurationResponse {
  BranchConfigurationData? data;
  bool? status;

  BranchConfigurationResponse({this.data, this.status});

  factory BranchConfigurationResponse.fromJson(Map<String, dynamic> json) {
    return BranchConfigurationResponse(
      data: json['data'] != null ? BranchConfigurationData.fromJson(json['data']) : null,
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class BranchConfigurationData {
  List<SlotData>? slot;
  String? slotDuration;
  List<TaxPercentage>? tax;
  List<String> holidayDays;

  BranchConfigurationData({this.slot, this.slotDuration, this.tax, this.holidayDays = const []});

  factory BranchConfigurationData.fromJson(Map<String, dynamic> json) {
    return BranchConfigurationData(
      slot: json['slot'] != null ? (json['slot'] as List).map((i) => SlotData.fromJson(i)).toList() : null,
      slotDuration: json['slot_duration'],
      tax: json['tax'] != null ? (json['tax'] as List).map((i) => TaxPercentage.fromJson(i)).toList() : null,
      holidayDays: json['holiday_days'] != null ? (json['holiday_days'] as List).map((i) => i.toString()).toList() : [],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.slot != null) {
      data['slot'] = this.slot!.map((v) => v.toJson()).toList();
    }
    data['slot_duration'] = this.slotDuration;
    if (this.tax != null) {
      data['tax'] = this.tax!.map((v) => v.toJson()).toList();
    }
    data['holiday_days'] = this.holidayDays;
    return data;
  }
}

class SlotData {
  int? branchId;
  List<BranchBreaks>? breaks;
  String? createdAt;
  int? createdBy;
  String? createdGuard;
  String? day;
  String? deletedAt;
  int? deletedBy;
  String? deletedGuard;
  String? endTime;
  int? id;
  int? isHoliday;
  String? startTime;
  String? updatedAt;
  int? updatedBy;
  String? updatedGuard;
  DateTime? previousTimeSlot;
  String? sessionText;
  bool isAvailable;
  int? isFestival;
  int? isDayOff;

  String? date;
  // local
  bool slotAvailability(DateTime date) {
    // If date is in the past, slot is not available
    DateTime today = DateTime.now();
    DateTime todayDate = DateTime(today.year, today.month, today.day);
    DateTime dateOnly = DateTime(date.year, date.month, date.day);
    
    if (dateOnly.isBefore(todayDate)) {
      return false;
    }
    // If date is today, check if current time is before slot start time
    if (date.isToday) {
      return isTimeBefore(TimeOfDay.now(), startTime!.getTimeOfDay());
    }
    // If date is in the future, slot is available
    return true;
  }

  List<AvailableSlot>? availableSlots;
  SlotData({
    this.branchId,
    this.breaks,
    this.createdAt,
    this.createdBy,
    this.createdGuard,
    this.day,
    this.deletedAt,
    this.deletedBy,
    this.deletedGuard,
    this.endTime,
    this.id,
    this.isHoliday,
    this.startTime,
    this.updatedAt,
    this.updatedBy,
    this.updatedGuard,
    this.isAvailable = true,
    this.isFestival,
    this.isDayOff,
    this.date,
    this.availableSlots,
  });

  factory SlotData.fromJson(Map<String, dynamic> json) {
    return SlotData(
      branchId: json['branch_id'],
      breaks: json['breaks'] != null ? (json['breaks'] as List).map((i) => BranchBreaks.fromJson(i)).toList() : null,
      createdAt: json['created_at'],
      createdBy: json['created_by'] != null ? json['created_by'] : null,
      createdGuard: json['created_guard'],
      day: json['day'],
      deletedAt: json['deleted_at'] != null ? json['deleted_at'] : null,
      deletedBy: json['deleted_by'] != null ? json['deleted_by'] : null,
      deletedGuard: json['deleted_guard'],
      endTime: json['end_time'],
      id: json['id'],
      isHoliday: json['is_holiday'],
      startTime: json['start_time'],
      updatedAt: json['updated_at'],
      updatedBy: json['updated_by'] != null ? json['updated_by'] : null,
      updatedGuard: json['updated_guard'],
      isAvailable: json['is_available'] ?? true,
      isFestival: json['is_festival_holiday'] ?? 0,
      isDayOff: json['is_day_off'] ?? 0,
      date: json['date'],
      availableSlots: json['available_slots'] != null ? (json['available_slots'] as List).map((i) => AvailableSlot.fromJson(i)).toList() : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['branch_id'] = this.branchId;
    data['created_at'] = this.createdAt;
    data['created_guard'] = this.createdGuard;
    data['day'] = this.day;
    data['deleted_guard'] = this.deletedGuard;
    data['end_time'] = this.endTime;
    data['id'] = this.id;
    data['is_holiday'] = this.isHoliday;
    data['start_time'] = this.startTime;
    data['updated_at'] = this.updatedAt;
    data['updated_guard'] = this.updatedGuard;
    data['is_available'] = this.isAvailable;
    data['is_festival_holiday'] = this.isFestival;
    data['is_day_off'] = this.isDayOff;
    data['date'] = this.date;
    if (this.breaks != null) {
      data['breaks'] = this.breaks!.map((v) => v.toJson()).toList();
    }
    if (this.availableSlots != null) {
      data['available_slots'] = this.availableSlots!.map((v) => v.toJson()).toList();
    }
    if (this.breaks != null) {
      data['breaks'] = data['breaks'] = this.breaks!.map((v) => v.toJson()).toList();
    }
    if (this.createdBy != null) {
      data['created_by'] = this.createdBy;
    }
    if (this.deletedAt != null) {
      data['deleted_at'] = this.deletedAt;
    }
    if (this.deletedBy != null) {
      data['deleted_by'] = this.deletedBy;
    }
    if (this.updatedBy != null) {
      data['updated_by'] = this.updatedBy;
    }
    return data;
  }
}

class TaxData {
  String? createdAt;
  int? createdBy;
  String? createdGuard;
  String? deletedAt;
  int? deletedBy;
  String? deletedGuard;
  int? id;
  int? status;
  String? title;
  String? type;
  String? updatedAt;
  int? updatedBy;
  String? updatedGuard;
  int? value;

  TaxData({this.createdAt, this.createdBy, this.createdGuard, this.deletedAt, this.deletedBy, this.deletedGuard, this.id, this.status, this.title, this.type, this.updatedAt, this.updatedBy, this.updatedGuard, this.value});

  factory TaxData.fromJson(Map<String, dynamic> json) {
    return TaxData(
      createdAt: json['created_at'],
      createdBy: json['created_by'] != null ? json['created_by'] : null,
      createdGuard: json['created_guard'],
      deletedAt: json['deleted_at'] != null ? json['deleted_at'] : null,
      deletedBy: json['deleted_by'] != null ? json['deleted_by'] : null,
      deletedGuard: json['deleted_guard'],
      id: json['id'],
      status: json['status'],
      title: json['title'],
      type: json['type'],
      updatedAt: json['updated_at'],
      updatedBy: json['updated_by'] != null ? json['updated_by'] : null,
      updatedGuard: json['updated_guard'],
      value: json['value'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['created_at'] = this.createdAt;
    data['created_guard'] = this.createdGuard;
    data['deleted_guard'] = this.deletedGuard;
    data['id'] = this.id;
    data['status'] = this.status;
    data['title'] = this.title;
    data['type'] = this.type;
    data['updated_at'] = this.updatedAt;
    data['updated_guard'] = this.updatedGuard;
    data['value'] = this.value;
    if (this.createdBy != null) {
      data['created_by'] = this.createdBy;
    }
    if (this.deletedAt != null) {
      data['deleted_at'] = this.deletedAt;
    }
    if (this.deletedBy != null) {
      data['deleted_by'] = this.deletedBy;
    }
    if (this.updatedBy != null) {
      data['updated_by'] = this.updatedBy;
    }
    return data;
  }
}
