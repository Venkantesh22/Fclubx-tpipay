import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frezka/components/app_scaffold.dart';
import 'package:frezka/components/empty_error_state_widget.dart';
import 'package:frezka/components/loader_widget.dart';
import 'package:frezka/main.dart';
// import 'package:frezka/screens/dashboard/dashboard_repository.dart';
import 'package:frezka/screens/package/component/package_card.dart';
import 'package:frezka/screens/package/model/package_list_model.dart';
// import 'package:frezka/screens/package/package_repository.dart';
import 'package:frezka/screens/services/models/service_response.dart';
import 'package:frezka/utils/app_common.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../booking/view/booking_screen.dart';

class PackageListScreen extends StatefulWidget {
  final List<PackageListData>? filterListData;
  final List<ServiceListData>? services;

  PackageListScreen({super.key, this.filterListData, this.services});

  @override
  State<PackageListScreen> createState() => _PackageListScreenState();
}

class _PackageListScreenState extends State<PackageListScreen> {
  int? selectedIndex;
  Future<List<PackageListData>>? future;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    bookingRequestStore.selectedPackageList.clear();
    // future = getPackagesList().then(
    //   (value) async {
    //     if (value.isNotEmpty) {
    //       await getUserPackagesList().then((val) {
    //         if (val.isNotEmpty) {
    //           for (var packageData in val) {
    //             if (packageData.userPackage.isNotEmpty) {
    //               if (value.any((e) => e.id == packageData.id)) {
    //                 int index = value.indexWhere((e) => e.id == packageData.id);
    //                 if (index > -1) {
    //                   value[index] = packageData;
    //                 }
    //               } else {
    //                 value.add(packageData);
    //               }
    //               dashboardResponseCached!.packagesList = value;
    //             }
    //           }
    //         } else {
    //           dashboardResponseCached!.packagesList = value;
    //         }
    //       });
    //     }
    //     // Return non-nullable value, default to an empty list if null
    //     return dashboardResponseCached?.packagesList ?? <PackageListData>[];
    //   },
    // );
  }

  // Future<List<PackageListData>> getPackagesList() async {
  //   List<PackageListData> listData = [];
  //   if (widget.filterListData != null) {
  //     listData = widget.filterListData!;
  //   } else {
  //     appStore.setLoading(true);
  //     await getPackages().then((value) {
  //       if (value.packageListData.isNotEmpty) {
  //         value.packageListData.forEach((element) {
  //           listData.add(element);
  //         });
  //         appStore.setLoading(false);
  //         return listData;
  //       }
  //       appStore.setLoading(false);
  //     }).catchError((e) {
  //       appStore.setLoading(false);
  //       toast(e.toString(), print: true);
  //       throw e;
  //     });
  //   }

  //   return listData;
  // }

  @override
  void dispose() {
    super.dispose();
    appStore.setLoading(false);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBarWidget: commonAppBarWidget(
        context,
        title: locale.packages,
        appBarHeight: 70,
        roundCornerShape: true,
        showLeadingIcon: Navigator.canPop(context),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          SnapHelperWidget<List<PackageListData>>(
            future: future,
            errorBuilder: (error) {
              return NoDataWidget(
                title: error,
                retryText: locale.reload,
                imageWidget: ErrorStateWidget(),
                onRetry: () {
                  appStore.setLoading(true);
                  init().then((value) => setState(() {}));
                },
              );
            },
            loadingWidget: Offstage(),
            onSuccess: (snap) {
              if (snap.isEmpty) {
                return NoDataWidget(
                  title: locale.noPackagesFound,
                  retryText: locale.reload,
                  imageWidget: ErrorStateWidget(),
                  onRetry: () {
                    appStore.setLoading(true);
                    init().then((value) => setState(() {}));
                  },
                );
              }
              return AnimatedListView(
                padding: EdgeInsets.only(bottom: 170),
                shrinkWrap: true,
                itemCount: snap.length,
                itemBuilder: (context, index) {
                  PackageListData package = snap[index];
                  if (package.branchId == appStore.branchId) {
                    return Observer(builder: (context) {
                      // Check if package is active (end date inclusive) and has remaining quantity
                      final DateTime endDate = DateTime.parse(package.endDate);
                      final DateTime today = DateTime.now();
                      bool isPackageActive = package.userPackage.isNotEmpty && !endDate.isBefore(DateTime(today.year, today.month, today.day));
                      final Set<num> targetServiceIds = widget.services.validate().map((s) => s.id.validate() as num).toSet();
                      bool hasRemainingQuantity = package.services.any((service) {
                        // If API doesn't provide remainingQty, assume available
                        final bool hasQty = (service.remainingQty == null) || (service.remainingQty != null && service.remainingQty! > 0);
                        if (targetServiceIds.isEmpty) return hasQty;
                        return hasQty && targetServiceIds.contains(service.serviceId);
                      });
                      bool canReclaim = isPackageActive && hasRemainingQuantity;

                      return PackageCard(
                        package: package,
                        isSelected: bookingRequestStore.selectedPackageList.contains(package),
                        isPurchased: package.userPackage.isNotEmpty,
                        showPurchaseButton: package.userPackage.isEmpty,
                        showReclaimButton: canReclaim,
                        onPurchase: () {
                          if (canReclaim) {
                            // Use existing package
                            bookingRequestStore.selectedPackageList.clear();
                            bookingRequestStore.selectedPackageList.add(package);
                            bookingRequestStore.setPackagePurchase(true);
                            bookingRequestStore.setPackageReclaim(true);
                            BookingScreen(
                              services: widget.services.validate(),
                              packages: bookingRequestStore.selectedPackageList,
                              isPackagePurchase: true,
                              isPackageReclaim: true,
                            ).launch(context).then((value) => setState(() {}));
                          } else {
                            // Purchase new package
                            bookingRequestStore.selectedPackageList.clear();
                            bookingRequestStore.selectedPackageList.add(package);
                            bookingRequestStore.setPackagePurchase(true);
                            bookingRequestStore.setPackageReclaim(false);
                            BookingScreen(
                              services: widget.services.validate(),
                              packages: bookingRequestStore.selectedPackageList,
                              isPackagePurchase: true,
                              isPackageReclaim: false,
                            ).launch(context).then((value) => setState(() {}));
                          }
                        },
                      );
                    });
                  } else {
                    return Offstage();
                  }
                },
              );
            },
          ),
          Observer(builder: (context) => LoaderWidget().center().visible(appStore.isLoading)),
        ],
      ),
    );
  }
}
