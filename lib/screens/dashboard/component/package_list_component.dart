import 'package:flutter/material.dart';
import 'package:frezka/components/cached_image_widget.dart';
import 'package:frezka/components/price_widget.dart';
import 'package:frezka/components/view_all_label_component.dart';
import 'package:frezka/main.dart';
import 'package:frezka/screens/booking/view/booking_screen.dart';
import 'package:frezka/screens/package/model/package_list_model.dart';
import 'package:frezka/screens/package/view/package_list_screen.dart';
import 'package:frezka/utils/colors.dart';
import 'package:frezka/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';

import 'package_bottom_sheet_component.dart';

class PackageListComponent extends StatefulWidget {
  final List<PackageListData> packagesList;

  const PackageListComponent({super.key, required this.packagesList});

  @override
  State<PackageListComponent> createState() => _PackageListComponentState();
}

class _PackageListComponentState extends State<PackageListComponent> {
  List<PackageListData> filteredPackagesList = [];

  @override
  void initState() {
    super.initState();
    filteredPackagesList = widget.packagesList.where((data) => data.branchId == appStore.branchId).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ViewAllLabel(
          label: locale.ourPackages,
          list: widget.packagesList,
          onTap: () {
            PackageListScreen().launch(context).then((value) {
              setStatusBarColor(Colors.transparent);
            });
          },
        ).paddingSymmetric(horizontal: 16).visible(filteredPackagesList.isNotEmpty),
        HorizontalList(
            padding: EdgeInsets.symmetric(horizontal: 16),
            itemCount: widget.packagesList.length > 10 ? widget.packagesList.take(10).length : widget.packagesList.length,
            spacing: widget.packagesList.where((data) => data.branchId == appStore.branchId).length == 1 ? 2 : 14,
            itemBuilder: (context, index) {
              PackageListData data = widget.packagesList[index];
              return InkWell(
                onTap: () {
                  bool isPackageActive = data.userPackage.isNotEmpty && DateTime.parse(data.endDate).isAfter(DateTime.now());
                  bool hasRemainingQuantity = data.services.any((service) => service.remainingQty == null || service.remainingQty! > 0);
                  bool canReclaim = isPackageActive && hasRemainingQuantity;

                  PackageBottomSheetComponent.show(
                    context,
                    package: data,
                    isPurchased: data.userPackage.isNotEmpty,
                    onPurchase: () {
                      Navigator.of(context).pop();
                      bookingRequestStore.selectedPackageList.clear();
                      bookingRequestStore.selectedPackageList.add(data);
                      bookingRequestStore.setPackagePurchase(true);
                      bookingRequestStore.setPackageReclaim(canReclaim);
                      BookingScreen(
                        services: [],
                        packages: bookingRequestStore.selectedPackageList,
                        isPackagePurchase: true,
                        isPackageReclaim: canReclaim,
                      ).launch(context).then((value) => setState(() {}));
                    },
                  );
                },
                child: Container(
                  width: 180,
                  decoration: BoxDecoration(
                    color: index.isEven
                        ? appStore.isDarkMode
                            ? context.cardColor
                            : primaryLightColor
                        : context.cardColor,
                    borderRadius: BorderRadius.circular(defaultRadius),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        // Ensures the overlay can extend beyond the boundaries
                        children: [
                          CachedImageWidget(
                            url: data.packageImage.toString(),
                            width: context.width(),
                            height: 100,
                            fit: BoxFit.cover,
                            radius: 12.0,
                          ).paddingOnly(top: 5, bottom: 12, left: 5, right: 5),
                          Positioned(
                            bottom: 0,
                            right: 10,
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(
                                color: context.cardColor,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: PriceWidget(
                                price: data.packagePrice.validate(),
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Marquee(
                          child: Text(
                        data.name.validate(),
                        style: boldTextStyle(color: appStore.isDarkMode ? white : black),
                      )).paddingOnly(right: 16, left: 16, bottom: 8, top: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(locale.explore, style: primaryTextStyle(color: context.primaryColor)).onTap(() {
                            PackageListScreen().launch(context).then((value) {
                              setStatusBarColor(Colors.transparent);
                            });
                          }).paddingOnly(right: 16, left: 16, bottom: 12),
                          CachedImageWidget(
                            url: ic_card_off,
                            height: 22,
                            width: 22,
                            fit: BoxFit.cover,
                            color: context.iconColor,
                          ).paddingOnly(right: 16, left: 16, bottom: 16),
                        ],
                      ),
                    ],
                  ),
                ),
              ).visible(data.branchId == appStore.branchId);
            }),
      ],
    );
  }
}
