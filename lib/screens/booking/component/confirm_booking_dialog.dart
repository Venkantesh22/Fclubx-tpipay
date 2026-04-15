import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:frezka/configs.dart';
import 'package:frezka/generated/assets.dart';
import 'package:frezka/utils/app_common.dart';
import 'package:frezka/utils/colors.dart';
import 'package:frezka/utils/custom_toast_widget.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../components/price_widget.dart';
import '../../../main.dart';

class ConfirmBookingDialog extends StatefulWidget {
  final String? title;
  final String? subTitle;
  final bool isPackagePurchase;

  ConfirmBookingDialog(
      {this.title, this.subTitle, this.isPackagePurchase = false});

  @override
  _ConfirmBookingDialog createState() => _ConfirmBookingDialog();
}

class _ConfirmBookingDialog extends State<ConfirmBookingDialog> {
  bool isSelected = false;
  late TapGestureRecognizer _termsRecognizer;
  late TapGestureRecognizer _privacyRecognizer;

  @override
  void initState() {
    super.initState();
    init();
    _termsRecognizer = TapGestureRecognizer()..onTap = _openTerms;
    _privacyRecognizer = TapGestureRecognizer()..onTap = _openPrivacy;
  }

  void init() async {
    //
  }

  void _openTerms() async {
    commonLaunchUrl(TERMS_CONDITION_URL,
        launchMode: LaunchMode.externalApplication);
  }

  void _openPrivacy() async {
    // Use a privacy policy URL if defined, otherwise fall back to terms URL
    final url = (PRIVACY_POLICY_URL.isNotEmpty)
        ? PRIVACY_POLICY_URL
        : TERMS_CONDITION_URL;
    commonLaunchUrl(url, launchMode: LaunchMode.externalApplication);
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    _termsRecognizer.dispose();
    _privacyRecognizer.dispose();
    super.dispose();
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    bool isLast = false,
  }) {
    return Container(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(color: borderColor, width: 0.5),
              ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color:
                  appStore.isDarkMode ? darkSecondaryColor : primaryLightColor,
              shape: BoxShape.circle,
              border: Border.all(color: borderColor, width: 0.5),
            ),
            child: Icon(icon, color: context.iconColor, size: 20),
          ),
          20.width,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: secondaryTextStyle(size: 12, height: 1.83),
                ),
                0.height,
                Text(
                  value,
                  style: boldTextStyle(size: 14, height: 1.71),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRowWithWidget({
    required IconData icon,
    required String label,
    required Widget value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: appStore.isDarkMode ? darkSecondaryColor : primaryLightColor,
            shape: BoxShape.circle,
            border: Border.all(color: borderColor, width: 0.5),
          ),
          child: Icon(icon, color: context.iconColor, size: 20),
        ),
        20.width,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: secondaryTextStyle(size: 12, height: 1.83),
              ),
              0.height,
              value,
            ],
          ),
        ),
      ],
    );
  }

  String _getServiceName() {
    if (widget.isPackagePurchase) {
      return bookingRequestStore.selectedPackageList.isNotEmpty
          ? bookingRequestStore.selectedPackageList.first.name.validate()
          : "Package Service";
    } else {
      if (bookingRequestStore.selectedServiceList.isNotEmpty) {
        return bookingRequestStore.selectedServiceList
            .map((service) => service.name.validate())
            .where((name) => name.isNotEmpty)
            .join(", ");
      }
      return "Selected Services";
    }
  }

  String _getDateTime() {
    String date = bookingRequestStore.date.validate();
    String time = bookingRequestStore.time.validate();

    if (date.isNotEmpty && time.isNotEmpty) {
      return "$date at $time";
    } else if (date.isNotEmpty) {
      return date;
    } else if (time.isNotEmpty) {
      return time;
    }
    return "Date and time will be confirmed";
  }

  Widget _getTotalPriceWidget() {
    if (widget.isPackagePurchase) {
      if (bookingRequestStore.selectedPackageList.isNotEmpty) {
        return PriceWidget(
          price: bookingRequestStore.selectedPackageList.first.packagePrice
              .validate(),
          size: 14,
          color: appStore.isDarkMode ? white : black,
          isBoldText: true,
        );
      }
      return PriceWidget(
        price: 0,
        size: 14,
        color: appStore.isDarkMode ? white : black,
        isBoldText: true,
      );
    } else {
      return PriceWidget(
        price: bookingRequestStore.totalAmount.validate(),
        size: 14,
        color: appStore.isDarkMode ? white : black,
        isBoldText: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.width(),
      constraints: BoxConstraints(
        maxHeight: context.height() * 0.9,
      ),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.all(
          Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with title and close button
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title ?? locale.confirmBooking,
                  style: boldTextStyle(size: 16, height: 1.625),
                ),
                GestureDetector(
                  onTap: () {
                    finish(context);
                  },
                  child:
                      Image.asset(Assets.iconsIcClose, height: 20, width: 20),
                ),
              ],
            ),
          ),

          Divider(color: context.dividerColor, thickness: 0.5, height: 0)
              .paddingSymmetric(horizontal: 20),

          // Content
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Question text
                    Center(
                      child: Text(
                        widget.subTitle ??
                            locale.wouldYouLikeToProceedAndConfirmThisBooking +
                                "?",
                        style: boldTextStyle(size: 14, height: 1.71),
                      ),
                    ),
                    16.height,

                    // Booking details card
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: boxDecorationWithRoundedCorners(
                        backgroundColor: appStore.isDarkMode
                            ? darkSecondaryColor
                            : primaryLightColor.withAlpha(20),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: borderColor, width: 0.5),
                      ),
                      child: Column(
                        children: [
                          _buildDetailRow(
                            icon: Icons.content_cut,
                            label: '${locale.serviceName}:',
                            value: _getServiceName(),
                            isLast: false,
                          ),
                          15.height,
                          _buildDetailRow(
                            icon: Icons.calendar_today,
                            label: '${locale.dateTime}:',
                            value: _getDateTime(),
                            isLast: false,
                          ),
                          15.height,
                          _buildDetailRowWithWidget(
                            icon: Icons.currency_rupee,
                            label: '${locale.totalPrice}:',
                            value: _getTotalPriceWidget(),
                          ),
                        ],
                      ),
                    ),

                    // Terms and conditions
                    Padding(
                      padding: EdgeInsets.only(top: 20, bottom: 32),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Transform.translate(
                            offset: Offset(0, 2),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  isSelected = !isSelected;
                                });
                              },
                              child: Container(
                                width: 18,
                                height: 18,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? primaryColor
                                      : Colors.transparent, // #A82D86
                                  borderRadius: BorderRadius.circular(2),
                                  border: Border.all(
                                    color:
                                        isSelected ? primaryColor : borderColor,
                                    width: isSelected ? 1.5 : 1,
                                  ),
                                ),
                                child: isSelected
                                    ? Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 12,
                                      )
                                    : null,
                              ),
                            ),
                          ),
                          16.width,
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                text: locale.iAcceptYour + " ",
                                style:
                                    secondaryTextStyle(size: 13, height: 1.57),
                                children: [
                                  TextSpan(
                                    text: '${locale.termsConditions}',
                                    style: boldTextStyle(
                                        size: 13,
                                        height: 1.57,
                                        decoration: TextDecoration.underline,
                                        decorationColor: primaryColor,
                                        color: primaryColor),
                                    recognizer: _termsRecognizer,
                                  ),
                                  TextSpan(
                                    text: ' ${locale.and} ',
                                    style: secondaryTextStyle(
                                        size: 13, height: 1.57),
                                  ),
                                  TextSpan(
                                    text: locale.privacyPolicy,
                                    style: boldTextStyle(
                                        size: 13,
                                        height: 1.57,
                                        decoration: TextDecoration.underline,
                                        decorationColor: primaryColor,
                                        color: primaryColor),
                                    recognizer: _privacyRecognizer,
                                  ),
                                  TextSpan(
                                    text: '.',
                                    style: secondaryTextStyle(
                                        size: 13, height: 1.57),
                                    recognizer: _privacyRecognizer,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 24, vertical: 8),
                            decoration: BoxDecoration(
                              color: appStore.isDarkMode
                                  ? darkSecondaryColor
                                  : primaryLightColor, // #F2EBFF
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: borderColor, width: 1),
                            ),
                            child: TextButton(
                              onPressed: () {
                                finish(context);
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                locale.cancel,
                                style: boldTextStyle(
                                    size: 14,
                                    height: 1.71,
                                    color: appStore.isDarkMode ? white : black),
                              ),
                            ),
                          ),
                        ),
                        16.width,
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 24, vertical: 8),
                            decoration: BoxDecoration(
                              color: primaryColor, // #A82D86
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: primaryColor, width: 1),
                            ),
                            child: TextButton(
                              onPressed: () {
                                if (isSelected) {
                                  finish(context, true);
                                } else {
                                  ShowToast.showInfo(
                                      locale.pleaseAcceptTermsAndConditions);
                                }
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                locale.confirm,
                                style: boldTextStyle(
                                    size: 14, height: 1.71, color: white),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
