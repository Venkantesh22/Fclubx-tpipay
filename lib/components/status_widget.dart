import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

class StatusWidget extends StatelessWidget {
  final String? text;
  final Color? color;

  StatusWidget({required this.text, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      alignment: Alignment.center,
      decoration: boxDecorationDefault(
        borderRadius: BorderRadius.circular(20),
        color: color != null ? color! : null,
      ),
      child: Text(text ?? '', style: boldTextStyle(color: Colors.white, size: 12)),
    );
  }
}
