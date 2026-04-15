import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../../main.dart';
import '../../../utils/colors.dart';
import '../../../utils/custom_toast_widget.dart';
import '../../../utils/images.dart';

class CancelBookingDialog extends StatefulWidget {
  final Function(String reason) onConfirm;

  CancelBookingDialog({required this.onConfirm});

  @override
  State<CancelBookingDialog> createState() => _CancelBookingDialogState();
}

class _CancelBookingDialogState extends State<CancelBookingDialog> {
  String cancelReason = '';
  final TextEditingController reasonController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.width(),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(borderRadius: radius(16)),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(ic_confirm_check, height: 80, width: 80, color: primaryColor),
            16.height,
            Text(locale.doYouWantToCancelBooking, style: boldTextStyle(size: 20), textAlign: TextAlign.center),
            16.height,
            AppTextField(
              controller: reasonController,
              textFieldType: TextFieldType.MULTILINE,
              minLines: 1,
              maxLines: 5,
              decoration: InputDecoration(
                hint: Text(
                  locale.enterReasonForCancellation,
                  style: secondaryTextStyle(),
                ),
              ),
              onChanged: (val) {
                cancelReason = val;
              },
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
                    if (cancelReason.trim().isEmpty) {
                      ShowToast.showInfo(locale.pleaseEnterReasonForCancellation);
                      return;
                    }
                    widget.onConfirm(cancelReason.trim());
                    finish(context);
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
