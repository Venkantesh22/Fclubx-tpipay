import 'package:flutter/material.dart';
import 'package:frezka/generated/assets.dart';
import 'package:frezka/main.dart';
import 'package:frezka/utils/colors.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class Referral_Container extends StatelessWidget {
  final ReferralContainerModel referralContainerModel;
  const Referral_Container({
    super.key,
    required this.referralContainerModel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: boxDecorationWithRoundedCorners(
        backgroundColor: context.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: appStore.isDarkMode ? dividerDarkColor : borderColor,
            width: 1),
      ),
      child: Row(
        children: [
          Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: primaryColor.withValues(alpha: 0.10),
              ),
              child: SvgPicture.asset(
                referralContainerModel.icon,
                width: 22,
                height: 16,
                fit: BoxFit.cover,
              )),
          16.width,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  referralContainerModel.title,
                  style: boldTextStyle(color: primaryColor),
                ),
                4.height,
                Text(referralContainerModel.subTitle,
                    overflow: TextOverflow.fade,
                    style: secondaryTextStyle(
                      color: appStore.isDarkMode ? white : blackText,
                    )),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class ReferralContainerModel {
  final String icon;
  final String title;
  final String subTitle;

  ReferralContainerModel(
      {required this.icon, required this.title, required this.subTitle});
}

List<ReferralContainerModel> referralContainersModelList = [
  ReferralContainerModel(
      icon: Assets.svgReferralIcon,
      title: "DIRECT REWARD",
      subTitle: "Earn up to ₹50 for every successful referral"),
  ReferralContainerModel(
      icon: Assets.svgReferralLifetime,
      title: "LIFETIME PERK",
      subTitle: "Enjoy up to 10% lifetime referral purchase royalty"),
];
