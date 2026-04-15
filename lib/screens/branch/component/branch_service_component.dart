import 'package:flutter/material.dart';
import 'package:frezka/components/cached_image_widget.dart';
import 'package:frezka/components/view_all_label_component.dart';
import 'package:frezka/screens/services/view/service_detail_screen.dart';
import 'package:frezka/utils/colors.dart';
import 'package:frezka/utils/common_base.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../components/empty_error_state_widget.dart';
import '../../../components/price_widget.dart';
import '../../../main.dart';
import '../../booking/component/show_services.dart';
import '../../booking/view/booking_screen.dart';
import '../../services/models/service_response.dart';
import '../branch_repository.dart';
import '../shimmer/branch_service_shimmer.dart';

class BranchServiceComponent extends StatefulWidget {
  final int branchId;

  BranchServiceComponent({required this.branchId});

  @override
  _BranchServiceComponentState createState() => _BranchServiceComponentState();
}

class _BranchServiceComponentState extends State<BranchServiceComponent> {
  Future<List<ServiceListData>>? future;

  List<ServiceListData> branchServiceList = [];
  Set<int> selectedServiceIds = {};
  int page = 1;

  bool isLastPage = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    future = getBranchServiceList(
      branchId: widget.branchId,
      page: page,
      list: branchServiceList,
      lastPageCallBack: (p0) {
        isLastPage = p0;
      },
    );
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return SnapHelperWidget<List<ServiceListData>>(
      future: future,
      initialData: branchServiceListResponseCached,
      loadingWidget: BranchServiceShimmer(),
      errorBuilder: (error) {
        return SingleChildScrollView(
          child: NoDataWidget(
            title: error,
            retryText: locale.reload,
            imageWidget: ErrorStateWidget(),
            onRetry: () {
              page = 1;
              appStore.setLoading(true);
              init();
              setState(() {});
            },
          ),
        ).center();
      },
      onSuccess: (list) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ViewAllLabel(
              label: locale.allServices,
              onTap: () async {
                final result = await ShowServices(
                  serviceListData: branchServiceList,
                  selectedServiceIds: selectedServiceIds.map((id) => id.toString()).toList(),
                  onSelectionChanged: (selectedServices, selectedServiceIds) {},
                ).launch(context, pageRouteAnimation: PageRouteAnimation.Slide);

                if (result != null) {
                  setState(() {
                    selectedServiceIds.clear();
                    selectedServiceIds.addAll(
                      (result['selectedServiceIds'] as List<String>).map((id) => int.tryParse(id) ?? 0).where((id) => id != 0),
                    );
                  });
                }
              },
            ).paddingSymmetric(horizontal: 16),
            AnimatedListView(
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemCount: list.take(5).length,
              listAnimationType: ListAnimationType.FadeIn,
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              emptyWidget: NoDataWidget(
                title: locale.noServicesFound,
                imageWidget: EmptyStateWidget(),
              ),
              itemBuilder: (ctx, index) {
                ServiceListData serviceListData = list[index];
                bool isSelected = selectedServiceIds.contains(serviceListData.id);

                return GestureDetector(
                  onTap: () {
                    ServiceDetailScreen(serviceId: serviceListData.id!).launch(context);
                  },
                  child: Container(
                    decoration: boxDecorationWithRoundedCorners(
                      backgroundColor: context.cardColor,
                      borderRadius: radius(4),
                      border: Border.all(
                        color: isSelected ? context.primaryColor : borderColor,
                        width: isSelected ? 1.5 : 0.5,
                      ),
                    ),
                    margin: EdgeInsets.only(bottom: 8),
                    padding: EdgeInsets.only(top: 16, bottom: 16),
                    child: Row(
                      children: [
                        Checkbox(
                          value: isSelected,
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                selectedServiceIds.add(serviceListData.id!);
                              } else {
                                selectedServiceIds.remove(serviceListData.id);
                              }
                            });
                          },
                        ),
                        CachedImageWidget(
                          url: serviceListData.serviceImage.validate(),
                          height: 44,
                          width: 44,
                          circle: true,
                          radius: 4,
                        ),
                        12.width,
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Marquee(child: Text(serviceListData.name.validate(), style: boldTextStyle(size: 14))),
                            Text('${durationToString(serviceListData.durationMin.validate())}', style: secondaryTextStyle(size: 12)),
                          ],
                        ).expand(),
                        12.width,
                        PriceWidget(
                          price: serviceListData.defaultPrice.validate(),
                          color: context.primaryColor,
                          size: 16,
                        ),
                        16.width,
                      ],
                    ),
                  ),
                );
              },
            ),

            // Book Now button
            if (selectedServiceIds.isNotEmpty)
              Container(
                padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
                child: AppButton(
                  text: locale.bookNow,
                  width: double.infinity,
                  color: context.primaryColor,
                  textStyle: boldTextStyle(color: white),
                  onTap: () {
                    List<ServiceListData> selectedServices = branchServiceList.where((service) => selectedServiceIds.contains(service.id)).toList();
                    BookingScreen(
                      services: selectedServices,
                      isBranchService: true,
                      branchId: widget.branchId,
                    ).launch(context);
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}
