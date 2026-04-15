import 'package:flutter/material.dart';
import 'package:frezka/app_theme.dart';
import 'package:frezka/utils/app_common.dart';
import 'package:frezka/utils/custom_toast_widget.dart';
import 'package:frezka/utils/extensions/date_extensions.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../components/new_update_dialog.dart';
import '../locale/app_localizations.dart';
import '../main.dart';
import '../screens/auth/view/sign_in_screen.dart';
import '../screens/product/product_repository.dart';
import '../screens/product/view/product_detail_screen.dart';
import '../screens/product/view/product_wish_list_screen.dart';
import 'colors.dart';
import 'constants.dart';
import 'images.dart';
import 'model_keys.dart';

ThemeMode get appThemeMode => appStore.isDarkMode ? ThemeMode.dark : ThemeMode.light;

bool get isRTL => RTL_LanguageS.contains(appStore.selectedLanguageCode);

bool get isLoginTypeUser => userStore.loginType == LoginTypeConst.LOGIN_TYPE_USER;

bool get isLoginTypeGoogle => userStore.loginType == LoginTypeConst.LOGIN_TYPE_GOOGLE;

bool get isLoginTypeApple => userStore.loginType == LoginTypeConst.LOGIN_TYPE_APPLE;

bool get isSocialLoginType => userStore.loginType == LoginTypeConst.LOGIN_TYPE_APPLE || userStore.loginType == LoginTypeConst.LOGIN_TYPE_GOOGLE;

String formatDate(String? dateTime, {String format = DateFormatConst.DATE_FORMAT_1, bool isFromMicrosecondsSinceEpoch = false, bool showDateWithTime = false, bool isLocal = false}) {
  final parsedDateTime = isFromMicrosecondsSinceEpoch ? DateTime.fromMicrosecondsSinceEpoch(dateTime.validate().toInt() * 1000) : DateTime.parse(dateTime.validate());

  if(isLocal) {
    return DateFormat(format).format(parsedDateTime.toLocal());
  }

  return DateFormat(format).format(parsedDateTime);
}

String formatOnlyTime(BuildContext context, {String? startTime, String? endTime}) {
  if (startTime != null && endTime == null) {
    return '${TimeOfDay(hour: startTime.validate().split(':')[0].toInt(), minute: startTime.validate().split(':')[1].toInt()).format(context)}';
  } else if (endTime != null && startTime == null) {
    return '${TimeOfDay(hour: endTime.validate().split(':')[0].toInt(), minute: endTime.validate().split(':')[1].toInt()).format(context)}';
  } else {
    return '${TimeOfDay(hour: startTime.validate().split(':')[0].toInt(), minute: startTime.validate().split(':')[1].toInt()).format(context)} - ${TimeOfDay(hour: endTime.validate().split(':')[0].toInt(), minute: endTime.validate().split(':')[1].toInt()).format(context)}';
  }
}

List<LanguageDataModel> languageList() {
  return [
    LanguageDataModel(id: 1, name: 'English', languageCode: 'en', fullLanguageCode: 'en-US', flag: ic_us),
    LanguageDataModel(id: 2, name: 'Hindi', languageCode: 'hi', fullLanguageCode: 'hi-IN', flag: ic_india),
    LanguageDataModel(id: 3, name: 'Arabic', languageCode: 'ar', fullLanguageCode: 'ar-AR', flag: ic_ar),
    LanguageDataModel(id: 4, name: 'French', languageCode: 'fr', fullLanguageCode: 'fr-FR', flag: ic_fr),
    LanguageDataModel(id: 5, name: 'German', languageCode: 'de', fullLanguageCode: 'de-DE', flag: ic_de),
    LanguageDataModel(id: 6, name: 'Spanish', languageCode: 'es', fullLanguageCode: 'es-ES', flag: ic_es),
  ];
}

Future<void> syncLanguageWithAdmin(BuildContext context) async {
  try {
    final String? adminLang = appConfigurationResponseCached?.applicationLanguage;
    if (adminLang != null && adminLang.isNotEmpty) {
      final localeToApply = Locale(adminLang);
      final bool isSupported = const AppLocalizations().isSupported(localeToApply);
      if (isSupported && appStore.selectedLanguageCode != adminLang) {
        await appStore.setLanguage(adminLang);
      }
    }
  } catch (e) {}
}

String getOrderBookingStatus({required String status}) {
  if (status.toLowerCase().contains(OrderStatusConst.PLACED)) {
    return locale.orderPlaced;
  } else if (status.toLowerCase().contains(OrderStatusConst.PENDING)) {
    return locale.pending;
  } else if (status.toLowerCase().contains(OrderStatusConst.PROCESSING)) {
    return locale.processing;
  } else if (status.toLowerCase().contains(OrderStatusConst.DELIVERED)) {
    return locale.delivered;
  } else if (status.toLowerCase().contains(OrderStatusConst.CANCELLED)) {
    return locale.cancelled;
  } else {
    return "";
  }
}

Color getOrderBookingStatusColor({required String status}) {
  if (status.toLowerCase().contains(OrderStatusConst.PLACED)) {
    return successDarkColor;
  } else if (status.toLowerCase().contains(OrderStatusConst.PENDING)) {
    return wishListColor;
  } else if (status.toLowerCase().contains(OrderStatusConst.PROCESSING)) {
    return orangeColor;
  } else if (status.toLowerCase().contains(OrderStatusConst.DELIVERED)) {
    return successColor;
  } else if (status.toLowerCase().contains(OrderStatusConst.CANCELLED)) {
    return wishListColor;
  } else {
    return Colors.transparent;
  }
}

String getBookingStatusKey({required String status}) {
  if (status.toLowerCase().contains(BookingStatusConst.COMPLETED)) {
    return locale.completed;
  } else if (status.toLowerCase().contains(BookingStatusConst.CONFIRMED)) {
    return locale.confirmed;
  } else if (status.toLowerCase().contains(BookingStatusConst.CANCELLED)) {
    return locale.cancelled;
  } else if (status.toLowerCase().contains(BookingStatusConst.CHECK_IN)) {
    return locale.checkIn;
  } else if (status.toLowerCase().contains(BookingStatusConst.CHECKOUT)) {
    return locale.checkOut;
  } else if (status.toLowerCase().contains(BookingStatusConst.PENDING)) {
    return locale.pending;
  } else {
    return "";
  }
}

Color getBookingStatusColor({required String status}) {
  if (status.toLowerCase().contains(BookingStatusConst.COMPLETED)) {
    return successDarkColor;
  } else if (status.toLowerCase().contains(BookingStatusConst.CONFIRMED)) {
    return confirmedStatusBlue;
  } else if (status.toLowerCase().contains(BookingStatusConst.CANCELLED)) {
    return wishListColor;
  } else if (status.toLowerCase().contains(BookingStatusConst.CHECK_IN)) {
    return checkedInColor;
  } else if (status.toLowerCase().contains(BookingStatusConst.CHECKOUT)) {
    return appStore.isDarkMode ? checkOutDarkColor : secondaryColor;
  } else if (status.toLowerCase().contains(BookingStatusConst.PENDING)) {
    return wishListColor;
  } else {
    return Colors.transparent;
  }
}

String getBookingPaymentStatus({required String status}) {
  if (status.toLowerCase().contains(SERVICE_PAYMENT_STATUS_UNPAID)) {
    return locale.unpaid;
  } else if (status.toLowerCase().contains(SERVICE_PAYMENT_STATUS_PAID)) {
    return locale.paid;
  } else {
    return "";
  }
}

InputDecoration inputDecoration(
  BuildContext context, {
  Widget? prefixIcon,
  Widget? prefix,
  String? label,
  TextStyle? labelStyle,
  String? hint,
  Color? fillColor,
  String? counterText,
  double? borderRadius,
  Widget? suffixIcon,
  Widget? suffix,
  String? prefixText,
  Color? defaultBorderColor,
  EdgeInsets? contentPadding,
  bool alignLabelWithHint = true,
}) {
  return InputDecoration(
    contentPadding:  contentPadding ?? EdgeInsets.only(left: 12, bottom: 10, top: 10, right: 10),
    hintText: hint,
    hintStyle: secondaryTextStyle(),
    labelText: label,
    labelStyle: secondaryTextStyle(),
    alignLabelWithHint: alignLabelWithHint,
    counterText: counterText,
    prefixIcon: prefixIcon,
    prefix: prefix,
    suffix: suffix,
    prefixText: prefixText,
    suffixIcon: suffixIcon,
    enabledBorder: OutlineInputBorder(
      borderRadius: radius(borderRadius ?? defaultRadius),
      borderSide: BorderSide(color: defaultBorderColor ?? Colors.transparent, width: 0.5),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: radius(borderRadius ?? defaultRadius),
      borderSide: BorderSide(color: Colors.red, width: 0.0),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: radius(borderRadius ?? defaultRadius),
      borderSide: BorderSide(color: Colors.red, width: 1.0),
    ),
    errorMaxLines: 2,
    border: OutlineInputBorder(
      borderRadius: radius(borderRadius ?? defaultRadius),
      borderSide: BorderSide(color: defaultBorderColor ?? Colors.transparent, width: 0.0),
    ),
    disabledBorder: OutlineInputBorder(
      borderRadius: radius(borderRadius ?? defaultRadius),
      borderSide: BorderSide(color: defaultBorderColor ?? Colors.transparent, width: 0.0),
    ),
    errorStyle: primaryTextStyle(color: Colors.red, size: 12),
    focusedBorder: OutlineInputBorder(
      borderRadius: radius(borderRadius ?? defaultRadius),
      borderSide: BorderSide(color: primaryColor, width: 0.0),
    ),
    filled: true,
    fillColor: fillColor ?? context.cardColor,
  );
}

NavigationDestination bottomTab({required Widget iconData, required Widget activeIconData, required String tabName}) {
  return NavigationDestination(
    icon: iconData,
    selectedIcon: activeIconData,
    label: tabName,
  );
}

Color getRatingBarColor(int rating) {
  if (rating == 1 || rating == 2) {
    return ratingBarColor;
  } else if (rating == 3) {
    return orangeColor;
  } else if (rating == 4 || rating == 5) {
    return successLightColor;
  } else {
    return ratingBarColor;
  }
}

void viewFiles(String url) {
  if (url.isNotEmpty) {
    commonLaunchUrl(url, launchMode: LaunchMode.externalApplication);
  }
}

Future<DateTime?> datePicker(BuildContext context) async {
  // Disable specific holiday dates
  final List<DateTime> holidayDates = branchConfigurationCached!.slot?.where((slot) => slot.isHoliday == 1 && slot.date != null).map((slot) => DateTime.parse(slot.date!)).toList() ?? [];

  // Disable specific festival dates
  final List<DateTime> festivalDates = branchConfigurationCached!.slot?.where((slot) => slot.isFestival == 1 && slot.date != null).map((slot) => DateTime.parse(slot.date!)).toList() ?? [];

  bool isDisabled(DateTime date) {
    bool isDisable = holidayDates.any((d) => d.year == date.year && d.month == date.month && d.day == date.day) || festivalDates.any((d) => d.year == date.year && d.month == date.month && d.day == date.day);
    if(isDisable) return true;
    final dateStr = date.setFormattedDate('yyyy-MM-dd');
    final isWeekend = branchConfigurationCached?.holidayDays.contains(dateStr) ?? false;
    if(isWeekend) return true;
    final slotList = branchConfigurationCached!.slot ?? [];
    final weekDay = date.weekday;
    if(slotList.length < weekDay) {
      return false;
    }
    final slot = slotList[weekDay - 1];
    if(slot.isDayOff == 1) {
      return true;
    }
    return false;
  }

  // pick a valid initial date (today or next available day)
  DateTime initialDate = DateTime.now();
  while (isDisabled(initialDate)) {
    initialDate = initialDate.add(const Duration(days: 1));
  }

  DateTime? newDate = await showDatePicker(
    context: context,
    initialDate: initialDate,
    firstDate: DateTime.now(),
    lastDate: DateTime(2100),
    selectableDayPredicate: (DateTime date) => !isDisabled(date),
    builder: (_, child) {
      return Theme(
        data: appStore.isDarkMode ? ThemeData.dark(useMaterial3: true) : AppTheme.lightTheme,
        child: child!,
      );
    },
  );

  return newDate;
}

Future<String?> timePicker(BuildContext context) async {
  TimeOfDay? newTime = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.now(),
    builder: (_, child) {
      return Theme(
        data: appStore.isDarkMode ? ThemeData.dark(useMaterial3: true) : AppTheme.lightTheme,
        child: child!,
      );
    },
  );

  if (newTime != null) {
    DateTime pickerTime = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, newTime.hour, newTime.minute);
    return DateFormat(DateFormatConst.HOUR_12_FORMAT).format(pickerTime);
  } else {
    return null;
  }
}

String durationToString(int minutes) {
  var d = Duration(minutes: minutes);
  List<String> parts = d.toString().split(':');

  String hour = '';
  String minute = '';

  if (!parts[0].padLeft(2, '0').contains('00')) {
    final h = int.tryParse(parts[0].padLeft(2, '0')) ?? 0;
    hour = locale.durationHours(h);
  }

  if (!parts[1].padLeft(2, '0').contains('00')) {
    final m = int.tryParse(parts[1].padLeft(2, '0')) ?? 0;
    minute = locale.durationMinutes(m);
  }

  if (hour.isNotEmpty && minute.isNotEmpty) {
    return '$hour $minute';
  } else {
    return '$hour$minute';
  }
}

void doIfLoggedIn(BuildContext context, VoidCallback callback) async {
  if (appStore.isLoggedIn) {
    callback.call();
  } else {
    bool? res = await SignInScreen(returnExpected: true).launch(context);

    if (res ?? false) {
      callback.call();
    }
  }
}

bool isTimeBefore(TimeOfDay currentTime, TimeOfDay specifiedTime) {
  final now = DateTime.now();
  final currentTimeDateTime = DateTime(now.year, now.month, now.day, currentTime.hour, currentTime.minute);
  final specifiedTimeDateTime = DateTime(now.year, now.month, now.day, specifiedTime.hour, specifiedTime.minute);

  return currentTimeDateTime.isBefore(specifiedTimeDateTime);
}

bool isTimeAfter(TimeOfDay currentTime, TimeOfDay specifiedTime) {
  final now = DateTime.now();
  final currentTimeDateTime = DateTime(now.year, now.month, now.day, currentTime.hour, currentTime.minute);
  final specifiedTimeDateTime = DateTime(now.year, now.month, now.day, specifiedTime.hour, specifiedTime.minute);

  return currentTimeDateTime.isAfter(specifiedTimeDateTime);
}

void ifNotTester(VoidCallback callback) {
  if (userStore.userEmail != DEFAULT_EMAIL) {
    callback.call();
  } else {
    ShowToast.showInfo(locale.demoUserCannotBeGrantedForThis);
  }
}

void showNewUpdateDialog(BuildContext context) async {
  showInDialog(
    context,
    contentPadding: EdgeInsets.zero,
    barrierDismissible: !(getIntAsync(ConfigurationKeyConst.IS_FORCE_UPDATE) == 1 ? true : false),
    builder: (_) {
      return NewUpdateDialog();
    },
  );
}

Future<void> showForceUpdateDialog(BuildContext context) async {
  if (getIntAsync(ConfigurationKeyConst.IS_FORCE_UPDATE) == 1) {
    getPackageInfo().then((value) {
      if (isAndroid && getIntAsync(ConfigurationKeyConst.VERSION_CODE) > value.versionCode.validate().toInt()) {
        showNewUpdateDialog(context);
      }
      /*else if (isIOS && remoteConfigDataModel.iOS != null && remoteConfigDataModel.iOS!.versionCode.validate() != value.versionCode.validate()) {
        showNewUpdateDialog(context);
      }*/
    });
  }
}

Future<bool> addToWishList({required int productId}) async {
  Map req = {ProductModelKey.productId: productId};
  return await addWishList(req).then((res) {
    ShowToast.showSuccess(res.message!);
    return true;
  }).catchError((error) {
    ShowToast.showError(error.toString());
    return false;
  });
}

Future<bool> removeFromWishList({int? wishListId, int? productId, bool isFromProductDetail = false}) async {
  return await removeWishList(wishListId: wishListId, productId: productId).then((res) {
    if (isFromProductDetail) {
      onProductDetailUpdate.call();
      onWishListUpdate.call();
    } else if (wishListId != null) {
      onWishListUpdate.call();
    } else {
      //
    }
    ShowToast.showSuccess(res.message!);
    return true;
  }).catchError((error) {
    ShowToast.showError(error.toString());
    return false;
  });
}

String getPaymentMethodIcon(String value) {
  if (value == PaymentMethods.PAYMENT_METHOD_STRIPE) {
    return stripe_logo;
  } else if (value == PaymentMethods.PAYMENT_METHOD_RAZORPAY) {
    return razorpay_logo;
  } else if (value == PaymentMethods.CINET) {
    // return cinetpay_logo;
  } else if (value == PaymentMethods.PAYMENT_METHOD_FLUTTER_WAVE) {
    return flutter_wave_logo;
  } else if (value == PaymentMethods.PAYMENT_METHOD_SADAD_PAYMENT) {
    return "";
  } else if (value == PaymentMethods.PAYMENT_METHOD_PAYPAL) {
    return paypal_logo;
  } else if (value == PaymentMethods.AIRTEL_MONEY) {
    // return airtel_logo;
  } else if (value == PaymentMethods.PAYMENT_METHOD_PAYSTACK) {
    return paystack_logo;
  } else if (value == PaymentMethods.PAYMENT_METHOD_PHONEPE) {
    // return phonepe_logo;
  } else if (value == PaymentMethods.PAYMENT_METHOD_CASH) {
    return ic_payment;
  } else if (value == PaymentMethods.PAYMENT_METHOD_FROM_WALLET) {
    return ic_wallet;
  }
  return '';
}

// Voice Search Helper Functions
SpeechToText? _voiceSearchSpeech;
String _voiceSearchLastWords = '';
String _voiceSearchLastError = '';
String _voiceSearchLastStatus = '';

Future<void> startVoiceSearch({
  Function(String, bool)? onResultCallback,
  void Function()? onError,
  void Function()? onStatusChanged,
}) async {
  final oldInstance = _voiceSearchSpeech;
  if (oldInstance != null) {
    try {
      oldInstance.stop();
    } catch (e) {
      log("Error in voice search stop: $e");
    }
    try {
      oldInstance.cancel();
    } catch (e) {
      log("Error in voice search cancel: $e");
    }
    _voiceSearchSpeech = null;
    await Future.delayed(Duration(milliseconds: 100));
  }

  _voiceSearchSpeech = SpeechToText();

  bool available = await _voiceSearchSpeech!.initialize(
    onStatus: (status) {
      try {
        _voiceSearchLastStatus = status;
        log("Voice search status: $_voiceSearchLastStatus");
        onStatusChanged?.call();

        if (status == 'done') {
          appStore.setSpeechStatus(false);
        }
      } catch (e) {
        log("Error in voice search status callback: $e");
      }
    },
    onError: (error) {
      try {
        _voiceSearchLastError = '${error.errorMsg} - ${error.permanent}';
        log("Voice search error: $_voiceSearchLastError");
        appStore.setSpeechStatus(false);
        onError?.call();
      } catch (e) {
        log("Error in voice search error callback: $e");
        appStore.setSpeechStatus(false);
      }
    },
  );

  if (available && _voiceSearchSpeech != null) {
    appStore.setSpeechStatus(true);
    _voiceSearchLastWords = '';
    _voiceSearchLastError = '';

    _voiceSearchSpeech!.listen(
      onResult: (result) {
        try {
          _voiceSearchLastWords = result.recognizedWords;
          log("Voice search result: $_voiceSearchLastWords (final: ${result.finalResult})");

          onResultCallback?.call(_voiceSearchLastWords, result.finalResult);

          if (result.finalResult) {
            appStore.setSpeechStatus(false);
          }
        } catch (e) {
          log("Error in voice search result callback: $e");
          appStore.setSpeechStatus(false);
        }
      },
      listenFor: Duration(seconds: 30),
      pauseFor: Duration(seconds: 10),
      listenOptions: SpeechListenOptions(
        listenMode: ListenMode.deviceDefault,
        cancelOnError: true,
        partialResults: true,
      ),
    );
  } else {
    appStore.setSpeechStatus(false);
    ShowToast.showError(locale.theUserHasDeniedSpeechRecognition);
  }
}

/// Stop listening for voice input
void stopVoiceSearch() {
  appStore.setSpeechStatus(false);
  try {
    if (_voiceSearchSpeech != null) {
      _voiceSearchSpeech!.stop();
    }
  } catch (e) {
    log("Error in voice search stop: $e");
  }
}

/// Cancel listening for voice input
void cancelVoiceSearch() {
  appStore.setSpeechStatus(false);
  try {
    if (_voiceSearchSpeech != null) {
      _voiceSearchSpeech!.cancel();
    }
  } catch (e) {
    // Ignore errors
  }
}

/// Get the last recognized words from voice search
String get voiceSearchLastWords => _voiceSearchLastWords;

/// Get the last error from voice search
String get voiceSearchLastError => _voiceSearchLastError;

/// Get the last status from voice search
String get voiceSearchLastStatus => _voiceSearchLastStatus;

/// Check if speech recognition is available
Future<bool> isVoiceSearchAvailable() async {
  try {
    final speech = SpeechToText();
    return await speech.initialize();
  } catch (e) {
    return false;
  }
}
