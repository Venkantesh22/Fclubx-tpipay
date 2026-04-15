import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frezka/components/app_scaffold.dart';
import 'package:frezka/components/loader_widget.dart';
import 'package:frezka/screens/order/order_repository.dart';
import 'package:frezka/utils/common_base.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../components/cached_image_widget.dart';
import '../../../components/empty_error_state_widget.dart';
import '../../../components/voice_search_component.dart';
import '../../../main.dart';
import '../../../utils/app_common.dart';
import '../../../utils/colors.dart';
import '../../../utils/constants.dart';
import '../../../utils/images.dart';
import '../component/order_item_component.dart';
import '../component/order_list_component.dart';
import '../model/order_detail_response.dart';
import '../model/order_status_response.dart';

class OrderListScreen extends StatefulWidget {
  final bool showBack;

  OrderListScreen({required this.showBack});

  @override
  _OrderListScreenState createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  TextEditingController searchProductCont = TextEditingController();

  FocusNode searchFocusNode = FocusNode();

  Future<List<OrderStatusData>>? future;

  ///Search
  Future<List<OrderListData>>? searchFuture;

  List<OrderListData> orderList = [];
  bool isFilterApplied = false;

  @override
  void initState() {
    super.initState();
    init();
    // Reactive close icon
    searchProductCont.addListener(() => setState(() {}));
  }

  void handleSearch({bool flag = false}) async {
    searchFuture = getOrderList(
      status: productStore.selectedOrderStatusList.join(","),
      paymentStatus: productStore.selectedPaymentStatusList.join(","),
      page: 1,
      orders: orderList,
      search: searchProductCont.text.trim(),
      lastPageCallBack: (p) {
        // Handle pagination if needed
      },
    ).whenComplete(() {
      if (flag) setState(() {});
    });
  }

  void init({bool flag = false}) async {
    if(searchProductCont.text.trim().isNotEmpty || isFilterApplied || productStore.selectedOrderStatusList.isNotEmpty || productStore.selectedPaymentStatusList.isNotEmpty) {
      handleSearch(flag: true);
    }
  }

  Future<List<OrderStatusData>>? fetchOrderStatusApi() {
    future = getOrderStatus();

    return future;
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  void startListening() {
    startVoiceSearch(
      onResultCallback: (text, isFinal) {
        if (isFinal) {
          searchProductCont.text = text;
          appStore.setLoading(true);
          handleSearch(flag: true);
        }
      },
      onStatusChanged: () {
        if (mounted) setState(() {});
      },
    );
  }

  void stopListening() {
    stopVoiceSearch();
  }

  @override
  void dispose() {
    searchProductCont.removeListener(() {});
    searchProductCont.dispose();
    searchFocusNode.dispose();
    stopVoiceSearch();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBarWidget: PreferredSize(
        preferredSize: Size(context.width(), 100),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              width: context.width(),
              height: 140,
              decoration: boxDecorationWithRoundedCorners(
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
                backgroundColor: context.primaryColor,
              ),
              child: commonAppBarWidget(
                context,
                title: locale.orders,
                showLeadingIcon: widget.showBack,
              ).cornerRadiusWithClipRRectOnly(bottomLeft: 20, bottomRight: 20),
            ),
            Positioned(
              bottom: -20,
              left: 20,
              right: 20,
              child: Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: searchProductCont,
                      textFieldType: TextFieldType.OTHER,
                      focus: searchFocusNode,
                      suffix: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () {
                              hideKeyboard(context);
                              searchProductCont.clear();
                              setState(() {});
                            },
                            child: Icon(Icons.close, color: context.iconColor)
                          ).visible(searchProductCont.text.isNotEmpty),
                          6.width.visible(searchProductCont.text.isNotEmpty),
                          GestureDetector(
                            onTap: () {
                              startListening();
                            },
                            child: Icon(Icons.mic_none_outlined, color: context.iconColor)),
                          12.width.visible(searchProductCont.text.isNotEmpty),
                        ],
                      ),
                      onChanged: (s) {
                        appStore.setLoading(true);
                        handleSearch(flag: true);
                      },
                      decoration: inputDecoration(context, hint: locale.searchOrder, prefixIcon: Icon(Icons.search, color: context.iconColor)),
                    ),
                  ),
                  16.width,
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: boxDecorationDefault(color: secondaryColor),
                    child: CachedImageWidget(
                      url: ic_filter,
                      height: 26,
                      width: 26,
                      color: Colors.white,
                    ),
                  ).onTap(() {
                    handleFilterClick(context);
                  }, borderRadius: radius()),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          // Voice search animation - centered overlay
          Observer(
            builder: (context) {
              return appStore.isSpeechActivated
                  ? Positioned.fill(
                      child: Center(
                        child: VoiceSearchComponent(),
                      ),
                    )
                  : SizedBox.shrink();
            },
          ),
          searchProductCont.text.trim().isNotEmpty || isFilterApplied || productStore.selectedOrderStatusList.isNotEmpty || productStore.selectedPaymentStatusList.isNotEmpty
              ? SnapHelperWidget<List<OrderListData>>(
                  future: searchFuture,
                  errorBuilder: (error) {
                    return NoDataWidget(
                      title: error,
                      retryText: locale.reload,
                      imageWidget: ErrorStateWidget(),
                      onRetry: () {
                        appStore.setLoading(true);
                        handleSearch(flag: true);
                      },
                    );
                  },
                  loadingWidget: LoaderWidget(),
                  onSuccess: (orderList) {
                    if (orderList.isEmpty) {
                      return NoDataWidget(
                        title: locale.noOrdersFound,
                        retryText: locale.reload,
                        onRetry: () {
                          appStore.setLoading(true);
                          handleSearch(flag: true);
                        },
                      );
                    }

                    return AnimatedListView(
                      physics: AlwaysScrollableScrollPhysics(),
                      itemCount: orderList.length,
                      padding: EdgeInsets.only(left: 16, right: 16, top: 40, bottom: 16),
                      shrinkWrap: true,
                      itemBuilder: (_, i) => OrderItemComponent(getOrderData: orderList[i]),
                      onSwipeRefresh: () async {
                        init(flag: true);
                        return await 2.seconds.delay;
                      },
                    );
                  },
                )
              : Stack(
                  children: [
                    OrderListComponent(search: searchProductCont.text),
                    Observer(builder: (context) => LoaderWidget().visible(appStore.isLoading)),
                  ],
                ),
        ],
      ),
    );
  }

  void handleFilterClick(BuildContext context) {
    doIfLoggedIn(context, () {
      serviceCommonBottomSheet(
        context,
        title: locale.filterBy,
        child: SnapHelperWidget<List<OrderStatusData>>(
          future: fetchOrderStatusApi(),
          initialData: orderStatusListCached,
          loadingWidget: LoaderWidget(),
          errorBuilder: (error) {
            return NoDataWidget(
              title: error,
              retryText: locale.reload,
              imageWidget: ErrorStateWidget(),
              onRetry: () {
                appStore.setLoading(true);

                fetchOrderStatusApi();
                setState(() {});
              },
            );
          },
          onSuccess: (statusList) {
            if (statusList.isEmpty) {
              return NoDataWidget(
                title: locale.noTimeSlots,
                retryText: locale.reload,
                onRetry: () {
                  appStore.setLoading(true);

                  fetchOrderStatusApi();
                  setState(() {});
                },
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(locale.deliveryStatus, style: secondaryTextStyle()),
                16.height,
                AnimatedWrap(
                  runSpacing: 10,
                  spacing: 10,
                  itemCount: statusList.length,
                  listAnimationType: ListAnimationType.None,
                  itemBuilder: (context, index) {
                    OrderStatusData statusData = statusList[index];

                    return Observer(builder: (context) {
                      return GestureDetector(
                        onTap: () {
                          if (productStore.selectedOrderStatusList.contains(statusData.name)) {
                            productStore.selectedOrderStatusList.remove(statusData.name);
                          } else {
                            productStore.selectedOrderStatusList.add(statusData.name.validate());
                          }
                        },
                        child: Container(
                          width: context.width() / 3.7,
                          alignment: Alignment.center,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          decoration: boxDecorationDefault(
                            color: productStore.selectedOrderStatusList.contains(statusData.name)
                                ? appStore.isDarkMode
                                    ? primaryColor
                                    : lightPrimaryColor
                                : appStore.isDarkMode
                                    ? darkSecondaryColor
                                    : Colors.grey.shade100,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check,
                                size: 14,
                                color: Colors.white,
                              ).visible(productStore.selectedOrderStatusList.contains(statusData.name)),
                              4.width.visible(productStore.selectedOrderStatusList.contains(statusData.name)),
                              Text(
                                getOrderBookingStatus(status: statusData.name.validate()),
                                style: secondaryTextStyle(
                                  color: productStore.selectedOrderStatusList.contains(statusData.name) ? Colors.white : textSecondaryColorGlobal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    });
                  },
                ),
                16.height,
                Divider(color: context.dividerColor, height: 0),
                16.height,
                Text(locale.paymentStatus, style: secondaryTextStyle()),
                16.height,
                AnimatedWrap(
                  runSpacing: 10,
                  spacing: 10,
                  itemCount: 2,
                  listAnimationType: ListAnimationType.None,
                  itemBuilder: (context, index) {
                    String paymentStatus = '';
                    String displayText = '';
                    switch (index) {
                      case 0:
                        paymentStatus = SERVICE_PAYMENT_STATUS_PAID;
                        displayText = locale.paid;
                        break;
                      case 1:
                        paymentStatus = SERVICE_PAYMENT_STATUS_UNPAID;
                        displayText = locale.unpaid;
                        break;
                    }

                    return Observer(builder: (context) {
                      return GestureDetector(
                        onTap: () {
                          if (productStore.selectedPaymentStatusList.contains(paymentStatus)) {
                            productStore.selectedPaymentStatusList.remove(paymentStatus);
                          } else {
                            productStore.selectedPaymentStatusList.add(paymentStatus);
                          }
                        },
                        child: Container(
                          width: context.width() / 3.7,
                          alignment: Alignment.center,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          decoration: boxDecorationDefault(
                            color: productStore.selectedPaymentStatusList.contains(paymentStatus)
                                ? appStore.isDarkMode
                                    ? primaryColor
                                    : lightPrimaryColor
                                : appStore.isDarkMode
                                    ? darkSecondaryColor
                                    : Colors.grey.shade100,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check,
                                size: 14,
                                color: Colors.white,
                              ).visible(productStore.selectedPaymentStatusList.contains(paymentStatus)),
                              4.width.visible(productStore.selectedPaymentStatusList.contains(paymentStatus)),
                              Text(
                                displayText,
                                style: secondaryTextStyle(
                                  color: productStore.selectedPaymentStatusList.contains(paymentStatus) ? Colors.white : null,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    });
                  },
                ),
                16.height,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    AppButton(
                      text: locale.clearFilter,
                      textStyle: boldTextStyle(color: Colors.white),
                      color: secondaryColor,
                      onTap: () {
                        productStore.selectedOrderStatusList.clear();
                        productStore.selectedPaymentStatusList.clear();
                        finish(context);
                        appStore.setLoading(true);
                        isFilterApplied = false;
                        setState(() {});
                      },
                    ).expand(),
                    16.width,
                    AppButton(
                      text: locale.apply,
                      textStyle: boldTextStyle(color: Colors.white),
                      color: primaryColor,
                      onTap: () {
                        finish(context);
                        appStore.setLoading(true);
                        isFilterApplied = true;
                        handleSearch(flag: true);
                      },
                    ).expand(),
                  ],
                ).paddingOnly(left: 16, right: 16, bottom: 16),
              ],
            );
          },
        ),
      );
    });
  }
}
