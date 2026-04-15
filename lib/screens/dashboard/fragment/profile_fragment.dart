import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frezka/components/logout_confirmation_dialog.dart';
import 'package:frezka/components/price_widget.dart';
import 'package:frezka/generated/assets.dart';
import 'package:frezka/main.dart';
import 'package:frezka/screens/auth/auth_repository.dart';
import 'package:frezka/screens/coupons/view/coupon_list_screen.dart';
import 'package:frezka/screens/dashboard/component/common_app_component.dart';
import 'package:frezka/screens/dashboard/component/wallet_history.dart';
import 'package:frezka/screens/dashboard/view/dashboard_screen.dart';
import 'package:frezka/screens/profile/view/about_detail_screen.dart';
import 'package:frezka/screens/profile/view/invite_and_earn_screen.dart';
import 'package:frezka/screens/profile/view/setting_screen.dart';
import 'package:frezka/utils/common_base.dart';
import 'package:frezka/utils/constants.dart';
import 'package:frezka/utils/extensions/string_extensions.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../components/cached_image_widget.dart';
import '../../../components/default_user_image_placeholder.dart';
import '../../../models/about_model.dart';
import '../../../utils/colors.dart';
import '../../../utils/images.dart';
import '../../auth/view/edit_profile_screen.dart';
import '../../bankDetails/view/bank_details.dart';
import '../../cart/view/select_address_screen.dart';
import '../../order/view/order_list_screen.dart';
import '../../profile/view/data_provider.dart';
import '../../wallet/user_wallet_balance_screen.dart';

class ProfileFragment extends StatefulWidget {
  @override
  _ProfileFragmentState createState() => _ProfileFragmentState();
}

class _ProfileFragmentState extends State<ProfileFragment> {
  List<AboutModel> aboutAppList = [];
  List<AboutModel> helpList = [];

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    afterBuildCreated(() async {
      if (appStore.isLoggedIn) {
        try {
          await viewProfile(id: userStore.userId.validate());
        } catch (e) {
          log(e.toString());
        }

        // Only fetch wallet amount when user is properly authenticated
        try {
          final String token = getStringAsync(SharedPreferenceConst.TOKEN);
          if (userStore.userId > 0 && token.isNotEmpty && appStore.isLoggedIn) {
            await appStore.setUserWalletAmount();
          } else {
            // Ensure wallet amount is zero when not authenticated
            await appStore.setUserWalletAmount();
          }
        } catch (e) {
          log('Skipping wallet fetch due to auth check failure: $e');
        }
      }
      aboutAppList = getAboutDataModel(context: context);
      helpList = await getHelpList(context: context);
      setState(() {});
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CommonAppComponent(
            innerWidget: Text(
              locale.profile,
              style: boldTextStyle(color: white, size: APPBAR_TEXT_SIZE),
              textAlign: TextAlign.center,
            ).paddingOnly(top: 50),
            mainWidgetHeight: appStore.isLoggedIn ? 100 : 100,
            profileCircleWidget: appStore.isLoggedIn
                ? SizedBox(height: 100, width: 100)
                : SizedBox(height: 120, width: 100),
            subWidget: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (appStore.isLoggedIn)
                  Observer(builder: (context) {
                    String firstName = userStore.userFirstName.trim();
                    String lastName = userStore.userLastName.trim();
                    String displayName =
                        lastName.isNotEmpty && lastName != "Unknown"
                            ? '$firstName $lastName'
                            : firstName;
                    return Container(
                      padding: EdgeInsets.only(
                          top: 16, bottom: 5, left: 16, right: 16),
                      child: SettingItemWidget(
                        title: displayName,
                        titleTextStyle: boldTextStyle(size: 18),
                        subTitle: userStore.userEmail.validate(),
                        subTitleTextStyle: secondaryTextStyle(size: 12),
                        leading: Container(
                          padding: EdgeInsets.all(2),
                          width: 60,
                          height: 60,
                          child: CachedImageWidget(
                            url: userStore.userProfileImage.validate(),
                            height: 60,
                            fit: BoxFit.cover,
                            width: 60,
                            radius: 30,
                            child: DefaultUserImagePlaceholder(),
                          ),
                        ),
                        trailing: Image.asset(ic_edit, height: 18),
                        decoration: boxDecorationWithRoundedCorners(
                            backgroundColor: context.cardColor,
                            border: Border.all(color: borderColor, width: 0.5)),
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        onTap: () {
                          EditProfileScreen().launch(context,
                              pageRouteAnimation: PageRouteAnimation.Fade);
                        },
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        splashColor: Colors.transparent,
                      ),
                    );
                  }),
                Column(
                  children: [
                    // Wallet Balance
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.only(
                              top: 16, bottom: 16, left: 16, right: 16),
                          decoration: boxDecorationWithRoundedCorners(
                              backgroundColor: lightGreenColor,
                              border: Border.all(
                                  color: successDarkColor, width: 0.5)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Image(
                                      image: AssetImage(Assets.iconsIcCard),
                                      height: 18,
                                      color: successDarkColor),
                                  8.width,
                                  Expanded(
                                      child: Text(locale.walletBalance,
                                          style: primaryTextStyle(
                                              color: successDarkColor,
                                              size: 14,
                                              weight: FontWeight.w500),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis)),
                                ],
                              ),
                              4.height,
                              Observer(builder: (context) {
                                return Text(
                                  "${leftCurrencyFormat()}${appStore.userWalletAmount.toStringAsFixed(getIntAsync(ConfigurationKeyConst.NO_OF_DECIMAL, defaultValue: DECIMAL_POINT))}${rightCurrencyFormat()}",
                                  style: boldTextStyle(
                                      color: successDarkColor, size: 20),
                                );
                              }),
                            ],
                          ),
                        )
                            .onTap(
                                () => UserWalletBalanceScreen().launch(context))
                            .expand(),
                        SizedBox().expand()
                      ],
                    ).visible(appStore.isLoggedIn),
                    if (appStore.isLoggedIn) 16.height,

                    // Quick Actions Section
                    if (appStore.isLoggedIn)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            locale.quickActions,
                            style: boldTextStyle(size: 18),
                          ).paddingOnly(bottom: 16),
                          // Responsive Grid Layout
                          LayoutBuilder(
                            builder: (context, constraints) {
                              double itemWidth =
                                  (constraints.maxWidth - 12) / 2;

                              return Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: [
                                  // My Packages
                                  // SizedBox(
                                  //   width: itemWidth,
                                  //   child: SettingItemWidget(
                                  //     title: locale.myPackages,
                                  //     titleTextStyle: boldTextStyle(size: 14),
                                  //     leading: Assets.iconsIcSealPercent.iconImage(fit: BoxFit.cover, size: 18),
                                  //     decoration: boxDecorationWithRoundedCorners(backgroundColor: context.cardColor, borderRadius: radius(6), border: Border.all(color: borderColor, width: 0.5)),
                                  //     padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  //     onTap: () {
                                  //       PackagesScreen().launch(context, pageRouteAnimation: PageRouteAnimation.Fade);
                                  //     },
                                  //     hoverColor: Colors.transparent,
                                  //     highlightColor: Colors.transparent,
                                  //     splashColor: Colors.transparent,
                                  //   ).paddingBottom(5).visible(appStore.isLoggedIn),
                                  // ),
                                  // Bank Details
                                  SizedBox(
                                    width: itemWidth,
                                    child: SettingItemWidget(
                                      title: locale.bankDetails,
                                      titleTextStyle: boldTextStyle(size: 14),
                                      leading: Image(
                                          image: AssetImage(ic_bank),
                                          height: 20,
                                          color: iconColor),
                                      decoration:
                                          boxDecorationWithRoundedCorners(
                                              backgroundColor:
                                                  context.cardColor,
                                              borderRadius: radius(6),
                                              border: Border.all(
                                                color: borderColor,
                                                width: 0.5,
                                              )),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 12),
                                      onTap: () {
                                        BankDetails().launch(context);
                                      },
                                      hoverColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      splashColor: Colors.transparent,
                                    ).visible(appStore.isLoggedIn),
                                  ),

                                  // My Address
                                  SizedBox(
                                    width: itemWidth,
                                    child: SettingItemWidget(
                                      title: locale.myAddresses,
                                      titleTextStyle: boldTextStyle(size: 14),
                                      leading: Image(
                                          image: AssetImage(ic_location),
                                          height: 20,
                                          color: iconColor),
                                      decoration:
                                          boxDecorationWithRoundedCorners(
                                        backgroundColor: context.cardColor,
                                        borderRadius: radius(6),
                                        border: Border.all(
                                            color: borderColor, width: 0.5),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 12),
                                      onTap: () {
                                        SelectAddressScreen(isFromProfile: true)
                                            .launch(context,
                                                pageRouteAnimation:
                                                    PageRouteAnimation.Fade);
                                      },
                                      hoverColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      splashColor: Colors.transparent,
                                    ).visible(appStore.isLoggedIn),
                                  ),

                                  // Rate Us
                                  SizedBox(
                                    width: itemWidth,
                                    child: SettingItemWidget(
                                      title: locale.rateUs,
                                      titleTextStyle: boldTextStyle(size: 14),
                                      leading: Image(
                                          image: AssetImage(ic_star),
                                          height: 20,
                                          color: iconColor),
                                      decoration:
                                          boxDecorationWithRoundedCorners(
                                        backgroundColor: context.cardColor,
                                        borderRadius: radius(6),
                                        border: Border.all(
                                            color: borderColor, width: 0.5),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 12),
                                      onTap: () {
                                        AboutDetailScreen(
                                                aboutModel: aboutAppList,
                                                title: locale.rateUs)
                                            .launch(context);
                                      },
                                      hoverColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      splashColor: Colors.transparent,
                                    ).visible(appStore.isLoggedIn),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),

                    if (appStore.isLoggedIn) 16.height,

                    Container(
                      decoration: boxDecorationWithRoundedCorners(
                        backgroundColor: context.cardColor,
                        borderRadius: radius(6),
                        border: Border.all(color: borderColor, width: 0.5),
                      ),
                      child: Column(
                        children: [
                          SettingItemWidget(
                            title: locale.rateUs,
                            subTitle:
                                '${locale.rateUs}, ${locale.share}, ${locale.aboutApp}',
                            titleTextStyle:
                                boldTextStyle(size: LABEL_TEXT_SIZE),
                            leading: Image(
                                image: AssetImage(ic_star),
                                height: 20,
                                color: iconColor),
                            decoration: boxDecorationWithRoundedCorners(
                                backgroundColor: context.cardColor),
                            padding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12),
                            trailing: Icon(Icons.arrow_forward_ios,
                                size: 14, color: iconColor),
                            onTap: () {
                              AboutDetailScreen(
                                      aboutModel: aboutAppList,
                                      title: locale.rateUs)
                                  .launch(context);
                            },
                            hoverColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            splashColor: Colors.transparent,
                          ).visible(!appStore.isLoggedIn),
                          if (!appStore.isLoggedIn)
                            Divider(
                                height: 1, color: borderColor, thickness: 0.5),

                          // invite and earn
                          SettingItemWidget(
                            title: locale.inviteAndEarn,
                            subTitle: locale.seeYourReferralCode,
                            titleTextStyle:
                                boldTextStyle(size: LABEL_TEXT_SIZE),
                            leading: ic_referral.iconImage(
                                fit: BoxFit.cover, size: 20, color: iconColor),
                            decoration: boxDecorationWithRoundedCorners(
                                backgroundColor: context.cardColor),
                            trailing: Icon(Icons.arrow_forward_ios,
                                size: 14, color: iconColor),
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            onTap: () {
                              InviteAndEarnScreen().launch(context,
                                  pageRouteAnimation: PageRouteAnimation.Fade);
                            },
                            hoverColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            splashColor: Colors.transparent,
                          ).visible(appStore.isLoggedIn),

                          // wallet history
                          if (appStore.isLoggedIn)
                            Divider(
                                height: 1, color: borderColor, thickness: 0.5),
                          SettingItemWidget(
                            title: locale.walletHistory,
                            subTitle: locale.seeYourWalletHistory,
                            titleTextStyle:
                                boldTextStyle(size: LABEL_TEXT_SIZE),
                            leading: ic_wallet_history.iconImage(
                                fit: BoxFit.cover, size: 20, color: iconColor),
                            decoration: boxDecorationWithRoundedCorners(
                                backgroundColor: context.cardColor),
                            trailing: Icon(Icons.arrow_forward_ios,
                                size: 14, color: iconColor),
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            onTap: () {
                              UserWalletHistoryScreen().launch(context,
                                  pageRouteAnimation: PageRouteAnimation.Fade);
                            },
                            hoverColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            splashColor: Colors.transparent,
                          ).visible(appStore.isLoggedIn),

                          if (appStore.isLoggedIn)
                            Divider(
                                height: 1, color: borderColor, thickness: 0.5),
                          // Orders
                          SettingItemWidget(
                            title: locale.orders,
                            titleTextStyle:
                                boldTextStyle(size: LABEL_TEXT_SIZE),
                            subTitle: locale.seeYourOrders,
                            leading: Image(
                                image: AssetImage(Assets.iconsIcOrders),
                                height: 20,
                                color: iconColor),
                            decoration: boxDecorationWithRoundedCorners(
                                backgroundColor: context.cardColor),
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            trailing: Icon(Icons.arrow_forward_ios,
                                size: 14, color: iconColor),
                            onTap: () {
                              OrderListScreen(showBack: true).launch(context,
                                  pageRouteAnimation: PageRouteAnimation.Fade);
                            },
                            hoverColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            splashColor: Colors.transparent,
                          ).visible(appStore.isLoggedIn),

                          // Divider
                          if (appStore.isLoggedIn)
                            Divider(
                                height: 1, color: borderColor, thickness: 0.5),

                          // Coupons
                          SettingItemWidget(
                            title: locale.coupons,
                            titleTextStyle:
                                boldTextStyle(size: LABEL_TEXT_SIZE),
                            subTitle: locale.myDiscountCoupons,
                            leading: ic_coupon.iconImage(
                                fit: BoxFit.cover, size: 20, color: iconColor),
                            decoration: boxDecorationWithRoundedCorners(
                                backgroundColor: context.cardColor),
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            trailing: Icon(Icons.arrow_forward_ios,
                                size: 16, color: iconColor),
                            onTap: () {
                              CouponListScreen().launch(context,
                                  pageRouteAnimation: PageRouteAnimation.Fade);
                            },
                            hoverColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            splashColor: Colors.transparent,
                          ).visible(appStore.isLoggedIn),

                          // Divider
                          if (appStore.isLoggedIn)
                            Divider(
                                height: 1, color: borderColor, thickness: 0.5),

                          // Setting
                          SettingItemWidget(
                            title: locale.setting,
                            titleTextStyle:
                                boldTextStyle(size: LABEL_TEXT_SIZE),
                            subTitle: (!isSocialLoginType &&
                                    appStore.isLoggedIn)
                                ? '${locale.appLanguage}, ${locale.theme}, ${locale.deleteAccount}'
                                : '${locale.appLanguage}, ${locale.theme}',
                            leading: ic_setting.iconImage(
                                fit: BoxFit.cover, size: 20, color: iconColor),
                            decoration: boxDecorationWithRoundedCorners(
                                backgroundColor: context.cardColor),
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            trailing: Icon(Icons.arrow_forward_ios,
                                size: 14, color: iconColor),
                            onTap: () {
                              SettingScreen().launch(context).then((value) {
                                final dashboardState =
                                    context.findAncestorStateOfType<
                                        DashboardScreenState>();
                                dashboardState?.setState(() {});
                                setState(() {});
                              });
                            },
                            hoverColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            splashColor: Colors.transparent,
                          ),

                          // Divider
                          Divider(
                              height: 1, color: borderColor, thickness: 0.5),

                          // About App
                          SettingItemWidget(
                            title: locale.aboutApp,
                            titleTextStyle:
                                boldTextStyle(size: LABEL_TEXT_SIZE),
                            subTitle: '${locale.shareApp}, ${locale.aboutApp}',
                            leading: ic_help.iconImage(
                                fit: BoxFit.cover, size: 20, color: iconColor),
                            decoration: boxDecorationWithRoundedCorners(
                                backgroundColor: context.cardColor),
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            trailing: Icon(Icons.arrow_forward_ios,
                                size: 14, color: iconColor),
                            onTap: () {
                              AboutDetailScreen(
                                      aboutModel: helpList,
                                      title: locale.aboutApp)
                                  .launch(context);
                            },
                            hoverColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            splashColor: Colors.transparent,
                          ).visible(helpList.length > 0),
                          if (!appStore.isLoggedIn)
                            Divider(
                                height: 1, color: borderColor, thickness: 0.5),

                          // Sign In
                          SettingItemWidget(
                            title: locale.signIn,
                            titleTextStyle:
                                boldTextStyle(size: LABEL_TEXT_SIZE),
                            subTitle: locale.signInYourAccount,
                            leading: ic_logout.iconImage(
                                fit: BoxFit.cover, size: 14, color: iconColor),
                            decoration: boxDecorationWithRoundedCorners(
                                backgroundColor: context.cardColor),
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            trailing: Icon(Icons.arrow_forward_ios,
                                size: 14, color: iconColor),
                            onTap: () {
                              doIfLoggedIn(context, () {
                                DashboardScreen(pageIndex: 0)
                                    .launch(context, isNewTask: true);
                              });
                            },
                            hoverColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            splashColor: Colors.transparent,
                          ).visible(!appStore.isLoggedIn),
                        ],
                      ),
                    ),

                    if (appStore.isLoggedIn) 32.height,
                    // Logout

                    SettingItemWidget(
                      title: locale.logout,
                      titleTextStyle:
                          boldTextStyle(size: 16, color: taxAmountColor),
                      subTitle: locale.logoutYourAccount,
                      subTitleTextStyle:
                          secondaryTextStyle(size: 12, color: taxAmountColor),
                      leading: ic_logout.iconImage(
                          fit: BoxFit.cover, size: 14, color: taxAmountColor),
                      decoration: boxDecorationWithRoundedCorners(
                          backgroundColor: context.cardColor,
                          borderRadius: radius(6),
                          border: Border.all(color: borderColor, width: 0.5)),
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      onTap: () async {
                        bool? res = await showInDialog(
                          context,
                          contentPadding: EdgeInsets.zero,
                          backgroundColor: context.scaffoldBackgroundColor,
                          transitionDuration: 100.milliseconds,
                          builder: (p0) {
                            return LogoutConfirmationDialog();
                          },
                        );

                        if (res ?? false) {
                          await 50.milliseconds.delay;

                          appStore.setLoading(true);
                          String branchAddress = appStore.branchAddress;
                          String branchName = appStore.branchName;
                          int branchId = appStore.branchId;
                          String branchContactNumber =
                              appStore.branchContactNumber;

                          await logoutApi().then((value) async {
                            //
                          }).catchError((e) {
                            log(e.toString());
                          });

                          appStore.setLoading(false);

                          await appStore.setBranchAddress(branchAddress);
                          await appStore.setBranchId(branchId);
                          await appStore.setBranchName(branchName);
                          await appStore
                              .setBranchContactNumber(branchContactNumber);
                          productStore.setCartItemCount(0);

                          DashboardScreen().launch(context,
                              isNewTask: true,
                              pageRouteAnimation: PageRouteAnimation.Fade);
                        }
                      },
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      splashColor: Colors.transparent,
                    ).visible(appStore.isLoggedIn),
                    30.height,
                    SnapHelperWidget<PackageInfoData>(
                      future: getPackageInfo(),
                      onSuccess: (data) {
                        return VersionInfoWidget(
                                prefixText: 'v',
                                textStyle: secondaryTextStyle(size: 12))
                            .center();
                      },
                    ),
                  ],
                ).paddingSymmetric(vertical: 16, horizontal: 16),
              ],
            ),
          ),
          //Observer(builder: (context) => LoaderWidget().visible(appStore.isLoading)),
        ],
      ),
    );
  }
}
