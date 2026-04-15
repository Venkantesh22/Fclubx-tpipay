import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frezka/components/dotted_line.dart';
import 'package:frezka/utils/colors.dart';
import 'package:frezka/utils/common_base.dart';
import 'package:frezka/utils/extensions/string_extensions.dart';
import 'package:frezka/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../main.dart';
import '../../branch/view/select_branch_screen.dart';
import '../../services/view/view_all_service_screen.dart';
import '../fragment/notification_fragment.dart';

class DashboardAppBarComponent extends StatefulWidget {
  final Widget? innerChild;
  final String? hintText;
  final Widget? positionWidget;
  final double? positionWidgetHeight;
  final VoidCallback? onTapSearch;
  final VoidCallback? onRefresh;

  DashboardAppBarComponent({this.innerChild, this.hintText, this.positionWidget, this.positionWidgetHeight, this.onTapSearch, this.onRefresh});

  @override
  _DashboardAppBarComponentState createState() => _DashboardAppBarComponentState();
}

class _DashboardAppBarComponentState extends State<DashboardAppBarComponent> {
  //Please use always final if need:: Harsh
  final TextEditingController searchController = TextEditingController();

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    searchController.dispose();
    stopVoiceSearch();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        if (widget.innerChild != null)
          widget.innerChild!
        else
          Container(
            width: context.width(),
            height: 190,
            padding: EdgeInsets.only(left: 21, right: 6, top: context.statusBarHeight),
            decoration: boxDecorationWithRoundedCorners(borderRadius: radiusOnly(bottomLeft: 20, bottomRight: 20), backgroundColor: primaryColor),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Observer(builder: (context) {
                      return Text(
                        appStore.isLoggedIn ? '${locale.hey}, ${userStore.userFullName}' : locale.helloGuest,
                        style: boldTextStyle(size: 18, color: Colors.white),
                      );
                    }),
                    Image.asset(ic_hi, height: 22, fit: BoxFit.cover),
                    Spacer(),
                    IconButton(
                      onPressed: () {
                        doIfLoggedIn(context, () {
                          NotificationFragment().launch(context);
                        });
                      },
                      icon: ic_unselected_bell.iconImage(color: Colors.white, size: 20),
                    ),
                  ],
                ),
                4.height,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset(ic_location, height: 16, fit: BoxFit.cover, color: Colors.white),
                    8.width,
                    Marquee(child: Text('${appStore.branchName}, ${appStore.branchAddress}', style: primaryTextStyle(color: Colors.white))).expand(),
                    8.width,
                    Icon(Icons.keyboard_arrow_down, color: Colors.white),
                  ],
                ).paddingOnly(right: 12).onTap(() {
                  SelectBranchScreen(isFromDashboard: true).launch(context);
                }),
                10.height,
                DottedLine(dashColor: lightPrimaryColor, dashGapLength: 0).paddingOnly(right: 10),
              ],
            ),
          ),
        Positioned(
          bottom: -24,
          left: 20,
          right: 20,
          child: Container(
            height: widget.positionWidgetHeight ?? 50,
            width: context.width(),
            decoration: boxDecorationWithRoundedCorners(backgroundColor: context.cardColor),
            child: widget.positionWidget != null
                ? widget.positionWidget
                : AppTextField(
                  textFieldType: TextFieldType.NAME,
                  controller: searchController,
                  onTap: widget.onTapSearch,
                  readOnly: true,
                  suffix: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () {
                        ViewAllServiceScreen(
                          search: "",
                          serviceTitle: locale.searchServices,
                          startVoiceSearch: true,
                        ).launch(context).then((_) {
                          appStore.setSpeechStatus(false);
                        });
                      },
                      child: Icon(Icons.mic_none_outlined, color: context.iconColor)),
                  ],
                ),
                  decoration: inputDecoration(
                    context,
                    label: widget.hintText ?? '',
                    prefixIcon: Icon(Icons.search, color: context.iconColor),
                  ),
                ),
          ),
        )
      ],
    );
  }
}
