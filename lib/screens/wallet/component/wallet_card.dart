import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frezka/components/price_widget.dart';
import 'package:frezka/main.dart';
import 'package:frezka/utils/colors.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../withdraw/wallet_request.dart';
import '../user_wallet_balance_screen.dart';

class WalletCard extends StatefulWidget {
  final num availableBalance;
  final FutureOr<dynamic> Function(dynamic)? callback;

  const WalletCard({super.key, required this.availableBalance, this.callback});

  @override
  State<WalletCard> createState() => _WalletCardState();
}

class _WalletCardState extends State<WalletCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.width(),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(16),
      decoration: boxDecorationWithRoundedCorners(borderRadius: BorderRadius.circular(6), backgroundColor: appStore.isDarkMode ? darkSecondaryColor : territoryButtonColor, border: Border.all(color: appStore.isDarkMode ? dividerDarkColor : indicatorColor, width: 1)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Available Balance Section
          Text(locale.availableBalance, style: primaryTextStyle(color: appStore.isDarkMode ? Colors.white : black)),
          8.height,
          PriceWidget(price: widget.availableBalance.validate(), color: appStore.isDarkMode ? Colors.white : black, isBoldText: true, size: 32),
          20.height,
          // Buttons
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 35,
                  decoration: boxDecorationWithRoundedCorners(borderRadius: BorderRadius.circular(4), backgroundColor: appStore.isDarkMode ? scaffoldPrimaryDark : primaryLightColor, border: Border.all(color: context.dividerColor, width: 1)),
                  child: TextButton(
                    onPressed: () {
                      WithdrawRequest(
                        availableBalance: widget.availableBalance,
                      ).launch(context).then(widget.callback!);
                    },
                    child: Text(locale.withdraw, style: primaryTextStyle(color: appStore.isDarkMode ? Colors.white : Colors.black, weight: FontWeight.w600, size: 14, height: 1.2)),
                  ),  
                ),
              ),
              12.width,
              Expanded(
                child: Container(
                  height: 35,
                  decoration: boxDecorationWithRoundedCorners(borderRadius: BorderRadius.circular(4), backgroundColor: context.primaryColor, border: Border.all(color: context.primaryColor, width: 1)),
                  child: TextButton(
                    onPressed: () {
                      UserWalletBalanceScreen(isBackScreen: true).launch(context).then(widget.callback!);
                    },
                    child: Text(locale.topUp, style: primaryTextStyle(color: Colors.white, weight: FontWeight.w600, size: 14, height: 1.2)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
