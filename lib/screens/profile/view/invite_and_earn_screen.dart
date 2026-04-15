import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frezka/models/referral_model.dart';
import 'package:frezka/utils/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:share_plus/share_plus.dart';

import '../../../components/app_scaffold.dart';
import '../../../components/loader_widget.dart';
import '../../../main.dart';
import '../../../network/rest_apis.dart';

import '../../../utils/app_common.dart';

class InviteAndEarnScreen extends StatefulWidget {
  const InviteAndEarnScreen({Key? key}) : super(key: key);

  @override
  State<InviteAndEarnScreen> createState() => _InviteAndEarnScreenState();
}

class _InviteAndEarnScreenState extends State<InviteAndEarnScreen> {
  Future<ReferralModel>? future;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    future = getMyReferralAPI();
    // postGetReferralDateApi(request: request);
  }

  void copyReferralCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    toast("Referral code copied");
  }

  void shareReferral(String code, String link) {
    final message = """
🔥 Join me on FClubX!

Use my referral code: $code

Sign up here:
$link
""";

    Share.share(message);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBarWidget: commonAppBarWidget(
        context,
        title: "Referral",
        appBarHeight: 70,
        roundCornerShape: true,
        showLeadingIcon: true,
      ),
      body: Container(
        color: context.scaffoldBackgroundColor,
        child: Stack(
          children: [
            SnapHelperWidget<ReferralModel>(
              future: future,
              onSuccess: (data) {
                return AnimatedScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 22, vertical: 16),
                  children: [
                    32.height,
                    Text(
                      "THE ATELIER REFERRAL",
                      style: GoogleFonts.lexend(
                        textStyle: TextStyle(
                          color: appStore.isDarkMode
                              ? Colors.white
                              : primaryLightColorLight,
                          letterSpacing: .5,
                        ),
                      ),
                    ),
                    8.height,
                    RichText(
                      text: TextSpan(
                        text: "Hello, ",
                        style: GoogleFonts.lexend(
                          textStyle: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 36,
                            color: appStore.isDarkMode ? Colors.white : black,
                          ),
                        ),
                        children: [
                          TextSpan(
                            text: data.name ?? "null",
                            style: GoogleFonts.lexend(
                              textStyle: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 36,
                                color: appStore.isDarkMode
                                    ? Colors.white
                                    : LightPrimaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    18.height,
                    Text(
                      "Elevate your friends' style and earn exclusive atelier credits for every new member you bring into the Fclubx circle.",
                      style: GoogleFonts.lexend(
                        textStyle: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          color: appStore.isDarkMode
                              ? Colors.white
                              : primaryLightColorLight,
                        ),
                      ),
                    ),
                    40.height,
                    Container(
                      padding: EdgeInsets.all(40),
                      decoration: boxDecorationWithRoundedCorners(
                        backgroundColor: context.cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: appStore.isDarkMode
                                ? dividerDarkColor
                                : borderColor,
                            width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "YOUR PERSONAL CODE",
                            style: GoogleFonts.lexend(
                              textStyle: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 10,
                                color: appStore.isDarkMode
                                    ? Colors.white
                                    : primaryLightColorLight,
                              ),
                            ),
                          ),
                          4.height,
                          Text(
                            data.referralCode ?? "null",
                            style: GoogleFonts.lexend(
                              textStyle: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 24,
                                color: appStore.isDarkMode
                                    ? Colors.white
                                    : textPrimaryColor,
                              ),
                            ),
                          ),
                          AppButton(
                            width: context.width(),
                            height: 16,
                            color: context.primaryColor,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.copy,
                                  color: white,
                                ),
                                8.width,
                                Text(
                                  "Copy Code",
                                  style: GoogleFonts.lexend(
                                    textStyle: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                      color: white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            textStyle: boldTextStyle(color: white),
                            onTap: () async {
                              copyReferralCode(data.referralCode ?? "null");
                              // _handleClick();
                            },
                          ),
                        ],
                      ),
                    ),
                    24.height,
                    Container(
                      padding: EdgeInsets.all(40),
                      decoration: boxDecorationWithRoundedCorners(
                        backgroundColor: context.cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: appStore.isDarkMode
                                ? dividerDarkColor
                                : borderColor,
                            width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "INVITE LINK",
                            style: GoogleFonts.lexend(
                              textStyle: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 10,
                                color: appStore.isDarkMode
                                    ? Colors.white
                                    : primaryLightColorLight,
                              ),
                            ),
                          ),
                          4.height,
                          Text(
                            data.referralLink ?? "null",
                            style: GoogleFonts.lexend(
                              textStyle: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                color: appStore.isDarkMode
                                    ? Colors.white
                                    : textPrimaryColor,
                              ),
                            ),
                          ),
                          16.height,
                          AppButton(
                            width: context.width(),
                            height: 16,
                            color: context.primaryColor,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.share,
                                  color: white,
                                ),
                                8.width,
                                Text(
                                  "Share Link",
                                  style: GoogleFonts.lexend(
                                    textStyle: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                      color: white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            textStyle: boldTextStyle(color: white),
                            onTap: () async {
                              shareReferral(data.referralCode ?? "",
                                  data.referralLink ?? "");
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
            Observer(
                builder: (_) => LoaderWidget().visible(appStore.isLoading)),
          ],
        ),
      ),
    );
  }
}
