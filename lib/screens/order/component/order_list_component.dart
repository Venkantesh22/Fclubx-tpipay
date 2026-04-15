import 'package:flutter/material.dart';
import 'package:frezka/components/loader_widget.dart';
import 'package:frezka/utils/colors.dart';
import 'package:frezka/utils/constants.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../components/empty_error_state_widget.dart';
import '../../../main.dart';
import '../model/order_detail_response.dart';
import '../order_repository.dart';
import 'order_item_component.dart';

late Function(String) onOrderListUpdate;

class OrderListComponent extends StatefulWidget {
  final String search;

  OrderListComponent({this.search = ''});
  @override
  _OrderListComponentState createState() => _OrderListComponentState();
}

class _OrderListComponentState extends State<OrderListComponent> {
  Future<List<OrderListData>>? future;

  List<OrderListData> orders = [];
  int page = 1;
  bool isLastPage = false;
  String selectedFilter = 'all';

  List<String> filterOptions = ['all', 'placed', 'delivered', 'processing', 'cancelled'];

  @override
  void initState() {
    super.initState();
    init();

    onOrderListUpdate = (search) {
      init(flag: true, search: search);
    };
  }

  void init({bool flag = false, String search = ''}) async {
    future = getOrderList(
      status: _getStatusFromFilter(selectedFilter),
      paymentStatus: productStore.selectedPaymentStatusList.join(","),
      page: page,
      orders: orders,
      search: search,
      lastPageCallBack: (p) {
        isLastPage = p;
      },
    );
    if (flag) setState(() {});
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 40),
      child: Column(
        children: [
          // Filter Buttons
          Container(
            height: 36,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              itemCount: filterOptions.length,
              itemBuilder: (context, index) {
                String filter = filterOptions[index];
                bool isSelected = selectedFilter == filter;

                return Container(
                  margin: EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedFilter = filter;
                      });
                      _applyFilter(filter);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 7),
                      decoration: BoxDecoration(
                        color: isSelected ? appStore.isDarkMode? transparentColor: primaryLightColor : context.cardColor,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: isSelected ? context.primaryColor : borderColor,
                          width: 0.5,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        BookingStatusConst.displayText[filter] ?? filter.capitalizeFirstLetter(),
                        style: primaryTextStyle(
                              size: 12,
                              weight: FontWeight.w600,
                              color: isSelected
                                  ? context.primaryColor
                                  : appStore.isDarkMode
                                      ? Colors.white
                                      : textSecondaryColorGlobal)
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Order List
          Expanded(
            child: SnapHelperWidget<List<OrderListData>>(
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
              onSuccess: (orderList) {
                return AnimatedListView(
                  physics: AlwaysScrollableScrollPhysics(),
                  itemCount: orderList.length,
                  padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 16),
                  shrinkWrap: true,
                  emptyWidget: NoDataWidget(
                    title: locale.noOrdersFound,
                    subTitle: locale.thereAreNoOrders,
                    imageWidget: EmptyStateWidget(),
                    retryText: locale.reload,
                    onRetry: () {
                      page = 1;
                      appStore.setLoading(true);
                      init(flag: true);
                    },
                  ).paddingSymmetric(horizontal: 16),
                  itemBuilder: (_, i) => OrderItemComponent(getOrderData: orderList[i]).paddingBottom(10),
                  onNextPage: () {
                    if (!isLastPage) {
                      page++;
                      appStore.setLoading(true);
                      init(flag: true);
                    }
                  },
                  onSwipeRefresh: () async {
                    page = 1;
                    init(flag: true);
                    return await 2.seconds.delay;
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _applyFilter(String filter) {
    setState(() {
      page = 1;
      orders.clear();
    });

    future = getOrderList(
      status: _getStatusFromFilter(filter),
      paymentStatus: productStore.selectedPaymentStatusList.join(","),
      page: page,
      orders: orders,
      search: widget.search,
      lastPageCallBack: (p) {
        isLastPage = p;
      },
    );

    setState(() {});
  }

  String _getStatusFromFilter(String filter) {
    switch (filter) {
      case 'all':
        return '';
      case 'placed':
        return 'placed';
      case 'delivered':
        return 'delivered';
      case 'processing':
        return 'pending';
      case 'cancelled':
        return 'cancelled';
      default:
        return '';
    }
  }
}
