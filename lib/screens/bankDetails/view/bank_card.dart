import 'package:flutter/material.dart';
import 'package:frezka/main.dart';
import 'package:frezka/utils/colors.dart';
import 'package:nb_utils/nb_utils.dart';

class BankCard extends StatelessWidget {
  final String bankName;
  final String cardEnding;
  final IconData icon;
  final bool isDefault;
  final VoidCallback onChange;

  const BankCard({
    required this.bankName,
    required this.cardEnding,
    required this.icon,
    this.isDefault = false,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: primaryLightColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: Icon(icon, color: lightSecondaryColor, size: 32),
            title: Row(
              children: [
                Text(bankName, style: boldTextStyle(), overflow: TextOverflow.ellipsis, maxLines: 1).expand(),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 14),
                  decoration: boxDecorationDefault(borderRadius: BorderRadius.circular(24.0), color: primaryColor),
                  child: Text(
                    locale.lbldefault,
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('**** **** **** $cardEnding'),
                TextButton(
                  onPressed: onChange,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    locale.change,
                    style: TextStyle(
                      color: Colors.purple,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
