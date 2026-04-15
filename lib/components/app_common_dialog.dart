import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

class AppCommonDialog extends StatelessWidget {
  final String title;
  final Widget child;

  AppCommonDialog({required this.title, required this.child});

  static Future<T?> show<T>(BuildContext context, {
    required String title,
    required Widget child,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AppCommonDialog(
        title: title,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: boxDecorationDefault(
        color: context.cardColor,
        borderRadius: radiusOnly(
          topLeft: 20,
          topRight: 20,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: EdgeInsets.fromLTRB(16, 12, 8, 12),
            width: context.width(),
            decoration: boxDecorationDefault(
              color: context.primaryColor,
              borderRadius: radiusOnly(topRight: defaultRadius, topLeft: defaultRadius),
            ),
            child: Row(
              children: [
                Text(title, style: boldTextStyle(color: Colors.white)).expand(),
                CloseButton(color: Colors.white),
              ],
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
