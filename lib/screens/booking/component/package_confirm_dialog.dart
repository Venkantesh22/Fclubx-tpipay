import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:frezka/configs.dart';
import 'package:frezka/utils/app_common.dart';
import 'package:frezka/utils/colors.dart';
import 'package:frezka/utils/constants.dart';
import 'package:frezka/utils/custom_toast_widget.dart';
import 'package:frezka/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../main.dart';

class PackageConfirmDialog extends StatefulWidget {
  final String? packageName;
  final String? expiryDate;
  final bool isPackagePurchase;

  PackageConfirmDialog({
    this.packageName,
    this.expiryDate,
    this.isPackagePurchase = false,
  });

  @override
  _PackageConfirmDialog createState() => _PackageConfirmDialog();
}

class _PackageConfirmDialog extends State<PackageConfirmDialog> {
  bool isSelected = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    //
  }

  handleClick() async {
    commonLaunchUrl(TERMS_CONDITION_URL, launchMode: LaunchMode.externalApplication);
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.width(),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Image.asset(ic_confirm_check, height: 100, width: 100, color: primaryColor),
            16.height,
            Text('Use Your Package for This Booking?', style: boldTextStyle(size: 20), textAlign: TextAlign.center),
            16.height,
            Text(
              'You have an active package that includes this service. Would you like to redeem one session from your package?',
              style: primaryTextStyle(),
              textAlign: TextAlign.center,
            ).center(),
            16.height,
            if (widget.packageName.validate().isNotEmpty)
              Container(
                width: context.width(),
                padding: EdgeInsets.all(16),
                decoration: boxDecorationDefault(
                  color: context.cardColor,
                  borderRadius: radius(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Package Name: ${widget.packageName.validate()}',
                      style: primaryTextStyle(),
                    ),
                    8.height,
                    Text(
                      'Expires On: ${widget.expiryDate.validate()}',
                      style: secondaryTextStyle(),
                    ),
                  ],
                ),
              ),
            16.height,
            CheckboxListTile(
              value: isSelected,
              onChanged: (val) async {
                await setValue(SharedPreferenceConst.IS_SELECTED, isSelected);
                isSelected = !isSelected;
                setState(() {});
              },
              title: RichText(
                text: TextSpan(
                  text: locale.iHaveReadThe.toLowerCase().capitalizeFirstLetter(),
                  style: secondaryTextStyle(),
                  children: [
                    TextSpan(
                      text: locale.termsConditions + ".",
                      style: secondaryTextStyle(color: secondaryColor, size: 15, weight: FontWeight.bold),
                      recognizer: TapGestureRecognizer()..onTap = handleClick,
                    ),
                  ],
                ),
              ),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            24.height,
            Row(
              children: [
                AppButton(
                  child: Text(locale.cancel, style: boldTextStyle()),
                  color: context.cardColor,
                  width: context.width(),
                  onTap: () {
                    finish(context);
                  },
                ).expand(),
                16.width,
                AppButton(
                  child: Text(locale.confirm, style: boldTextStyle(color: white)),
                  color: secondaryColor,
                  width: context.width(),
                  onTap: () {
                    if (isSelected) {
                      finish(context, true);
                    } else {
                      ShowToast.showInfo(locale.pleaseAcceptTermsAndConditions);
                    }
                  },
                ).expand(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
