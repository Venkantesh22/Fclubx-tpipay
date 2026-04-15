import 'package:flutter/material.dart';
import 'package:frezka/components/app_scaffold.dart';
import 'package:frezka/screens/cart/cart_repository.dart';
import 'package:frezka/screens/cart/model/address_list_response.dart';
import 'package:frezka/utils/custom_toast_widget.dart';
import 'package:frezka/utils/extensions/string_extensions.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../components/empty_error_state_widget.dart';
import '../../../components/loader_widget.dart';
import '../../../main.dart';
import '../../../utils/app_common.dart';
import '../../../utils/colors.dart';
import '../../../utils/images.dart';
import 'add_address_screen.dart';

class SelectAddressScreen extends StatefulWidget {
  final bool isFromProfile;

  SelectAddressScreen({this.isFromProfile = false});

  @override
  _SelectAddressScreenState createState() => _SelectAddressScreenState();
}

class _SelectAddressScreenState extends State<SelectAddressScreen> {
  Future<List<UserAddress>>? future;

  List<UserAddress> addressList = [];

  int page = 1;

  bool isLastPage = false;

  int defaultAddressId = 0;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init({bool flag = false}) async {
    future = getAddressList(
      page: page,
      addressList: addressList,
      lastPageCallBack: (p0) {
        isLastPage = p0;
      },
    ).whenComplete(() async {
      try {
        if (addressList.isNotEmpty) {
          if (addressList.length == 1) {
            UserAddress single = addressList.first;
            single.isPrimary = 1;
            defaultAddressId = single.id.validate();
            productStore.setSelectedAddressData(single);
          } else {
            defaultAddressId = addressList.firstWhere((element) => element.isPrimary.validate().getBoolInt(), orElse: () => UserAddress()).id.validate();
            productStore.setSelectedAddressData(addressList.firstWhere((element) => element.isPrimary.validate().getBoolInt(), orElse: () => UserAddress()));
          }
        }
      } catch (e) {
        appStore.setLoading(false);
        log('Error defaultAddress: $e');
      }

      if (flag) setState(() {});
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  Widget buildIconWidget({required String icon, required VoidCallback onTap}) {
    return SizedBox(
      height: 38,
      width: 38,
      child: IconButton(padding: EdgeInsets.zero, icon: icon.iconImage(size: 18), onPressed: onTap),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBarWidget: commonAppBarWidget(context, title: locale.selectAddress, appBarHeight: 70, showLeadingIcon: true, roundCornerShape: true),
      body: Stack(
        children: [
          SnapHelperWidget<List<UserAddress>>(
            future: future,
            loadingWidget: LoaderWidget(),
            errorBuilder: (error) {
              return NoDataWidget(
                title: error,
                retryText: locale.reload,
                imageWidget: ErrorStateWidget(),
                onRetry: () {
                  page = 1;
                  appStore.setLoading(true);

                  init(flag: true);
                },
              );
            },
            onSuccess: (addressList) {
              if (addressList.isEmpty) {
                return NoDataWidget(
                  title: '${locale.opps}! ${locale.looksLikeYouHave}',
                  retryText: locale.reload,
                  imageWidget: EmptyStateWidget(),
                  onRetry: () async {
                    // final result = await AddAddressScreen().launch(context, pageRouteAnimation: PageRouteAnimation.Fade);
                    // if (result == true) {
                    //   page = 1;
                    init(flag: true);
                    // }
                  },
                ).paddingSymmetric(horizontal: 32);
              }

              return AnimatedScrollView(
                padding: EdgeInsets.only(left: 16, right: 16, bottom: 90, top: 20),
                physics: AlwaysScrollableScrollPhysics(),
                onSwipeRefresh: () async {
                  page = 1;
                  init(flag: true);
                  return await Future.delayed(const Duration(seconds: 2));
                },
                children: [
                  AnimatedListView(
                    shrinkWrap: true,
                    itemCount: addressList.length,
                    physics: NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemBuilder: (context, index) {
                      UserAddress addressData = addressList[index];

                      return GestureDetector(
                        onTap: () {
                          defaultAddressId = addressData.id.validate();

                          productStore.setSelectedAddressData(addressData);
                          setState(() {});
                        },
                        child: Stack(
                          children: [
                            Container(
                              padding: EdgeInsets.all(16),
                              decoration: boxDecorationDefault(
                                color: context.cardColor,
                                borderRadius: radius(),
                                border: Border.all(
                                  color: defaultAddressId == addressData.id.validate() ? primaryColor : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              margin: EdgeInsets.only(bottom: 16),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text("${addressData.firstName.validate()} ${addressData.lastName.validate()}", style: boldTextStyle(), maxLines: 1, overflow: TextOverflow.ellipsis),
                                            4.height,
                                            Text("${addressData.addressLine1.validate()} ${addressData.addressLine2.validate()}",
                                                style: secondaryTextStyle(size: 12), maxLines: 3, overflow: TextOverflow.ellipsis),
                                            Text("${addressData.cityName.validate()} - ${addressData.postalCode.validate()}", style: secondaryTextStyle(size: 12)),
                                            Text("${addressData.stateName.validate()}, ${addressData.countryName.validate()}", style: secondaryTextStyle(size: 12)),
                                          ],
                                        ),
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          buildIconWidget(
                                            icon: ic_edit_square,
                                            onTap: () async {
                                              final result = await AddAddressScreen(address: addressData).launch(context, pageRouteAnimation: PageRouteAnimation.Fade);
                                              if (result == true) {
                                                page = 1;
                                                appStore.setLoading(true);
                                                init(flag: true);
                                              }
                                            },
                                          ),
                                          buildIconWidget(
                                            icon: ic_delete,
                                            onTap: () => handleDeleteAddressClick(addressList, index, context),
                                          ).visible(!addressData.isPrimary.validate().getBoolInt()),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                                decoration: boxDecorationWithRoundedCorners(
                                  backgroundColor: territoryButtonColor,
                                  borderRadius: radiusOnly(bottomLeft: defaultRadius),
                                ),
                                child: Text(locale.primary, style: boldTextStyle(color: secondaryColor, size: 12)),
                              ),
                            ).visible(addressData.isPrimary.validate().getBoolInt() || addressData.isPrimary.validate().getBoolInt() == 1),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Row(
              children: [
                Container(
                  height: 50,
                  alignment: Alignment.center,
                  decoration: boxDecorationDefault(color: context.cardColor, border: Border.all(color: primaryColor)),
                  child: Text(locale.addNewAddress, style: boldTextStyle(color: primaryColor)),
                ).onTap(() async {
                  final result = await AddAddressScreen().launch(context, pageRouteAnimation: PageRouteAnimation.Fade);
                  if (result == true) {
                    page = 1;
                    appStore.setLoading(true);
                    init(flag: true);
                  }
                }, borderRadius: radius()).expand(),
                12.width,
                AppButton(
                  width: context.width(),
                  child: Text(locale.deliverHere, style: boldTextStyle(color: Colors.white)),
                  color: secondaryColor,
                  onTap: () {
                    Navigator.pop(context, true);
                  },
                ).expand(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> handleDeleteAddressClick(List<UserAddress> addressList, int index, BuildContext context) async {
    showConfirmDialogCustom(
      context,
      primaryColor: context.primaryColor,
      title: '${locale.areYouSureYouWantToDelete}?',
      positiveText: locale.delete,
      negativeText: locale.cancel,
      onAccept: (ctx) async {
        appStore.setLoading(true);
        removeAddress(addressId: addressList[index].id.validate()).then((value) {
          addressList.removeAt(index);
          if (value.message.validate().isNotEmpty) ShowToast.showSuccess(locale.addressDeleteSuccessfully);
          setState(() {});
          appStore.setLoading(false);
        }).catchError(onError);
      },
    );
  }
}
