import 'package:flutter/material.dart';
import 'package:frezka/screens/auth/view/change_password_screen.dart';
import 'package:frezka/utils/colors.dart';
import 'package:frezka/utils/common_base.dart';
import 'package:frezka/utils/custom_toast_widget.dart';
import 'package:frezka/utils/extensions/string_extensions.dart';
import 'package:frezka/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../components/app_scaffold.dart';
import '../../../main.dart';
import '../../../network/rest_apis.dart';
import '../../../utils/app_common.dart';
import '../../app_language_screen.dart';
import '../../auth/auth_repository.dart';
import '../../dashboard/view/dashboard_screen.dart';
import '../components/theme_selection_dialog.dart';

class SettingScreen extends StatefulWidget {
  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBarWidget: commonAppBarWidget(
        context,
        title: locale.setting,
        appBarHeight: 70,
        showLeadingIcon: true,
        roundCornerShape: true,
      ),
      body: AnimatedScrollView(
        padding: EdgeInsets.symmetric(vertical: 8),
        listAnimationType: ListAnimationType.None,
        children: [
          SettingItemWidget(
            leading: ic_app_language.iconImage(size: 16),
            title: locale.language,
            trailing: ic_arrow_right.iconImage(size: 16),
            splashColor: Colors.transparent,
            decoration: boxDecorationWithRoundedCorners(backgroundColor: context.cardColor, border: Border.all(color: borderColor, width: 0.5)),
            onTap: () {
              AppLanguageScreen().launch(context).then((value) {
                setState(() {});
              });
            },
          ).paddingSymmetric(horizontal: 16, vertical: 8),
          SettingItemWidget(
            leading: ic_dark_mode.iconImage(size: 16),
            title: locale.appTheme,
            trailing: ic_arrow_right.iconImage(size: 16),
            decoration: boxDecorationWithRoundedCorners(backgroundColor: context.cardColor, border: Border.all(color: borderColor, width: 0.5)),
            onTap: () async {
              await showInDialog(
                context,
                backgroundColor: context.scaffoldBackgroundColor,
                builder: (context) => ThemeSelectionDaiLog(),
                contentPadding: EdgeInsets.zero,
              );
            },
          ).paddingSymmetric(horizontal: 16, vertical: 8),
          if (appStore.isLoggedIn)
            SettingItemWidget(
              leading: ic_lock.iconImage(size: 16),
              title: locale.changePassword,
              trailing: ic_arrow_right.iconImage(size: 16),
              splashColor: Colors.transparent,

              decoration: boxDecorationWithRoundedCorners(backgroundColor: context.cardColor, border: Border.all(color: borderColor, width: 0.5)),
              onTap: () {
                doIfLoggedIn(context, () {
                  setState(() {});
                  ChangePasswordScreen().launch(context);
                });
              },
            ).paddingSymmetric(horizontal: 16, vertical: 8),
          if (appStore.isLoggedIn)
            SettingItemWidget(
              leading: ic_delete_account.iconImage(size: 16),
              paddingBeforeTrailing: 4,
              title: locale.deleteAccount,

              decoration: boxDecorationWithRoundedCorners(backgroundColor: context.cardColor, border: Border.all(color: borderColor, width: 0.5)),
              onTap: () {
                showConfirmDialogCustom(
                  context,
                  negativeText: locale.cancel,
                  positiveText: locale.delete,
                  onAccept: (_) {
                    ifNotTester(() {
                      appStore.setLoading(true);

                      deleteAccountCompletely().then((value) async {
                        await clearPreferences();
                        appStore.setLoading(false);

                        ShowToast.showSuccess(value.message!);

                        push(DashboardScreen(), isNewTask: true, pageRouteAnimation: PageRouteAnimation.Fade);
                      }).catchError((e) {
                        appStore.setLoading(false);
                        ShowToast.showError(e.toString());
                      });
                    });
                  },
                  dialogType: DialogType.DELETE,
                  title: locale.deleteAccountConfirmation,
                );
              },
            ).paddingSymmetric(horizontal: 16, vertical: 8),
        ],
      ),
    );
  }
}
