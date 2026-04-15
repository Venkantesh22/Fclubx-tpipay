import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frezka/components/price_widget.dart';
import 'package:frezka/screens/booking/view/booking_detail_screen.dart';
import 'package:frezka/screens/dashboard/component/wallet_history_shimmer.dart';
import 'package:frezka/utils/colors.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../components/app_scaffold.dart';
import '../../../components/empty_error_state_widget.dart';
import '../../../components/loader_widget.dart';
import '../../../main.dart';
import '../../../models/user_wallet_history.dart';
import '../../../network/rest_apis.dart';

import '../../../utils/app_common.dart';
import '../../../utils/common_base.dart';
import '../../../utils/constants.dart';
import '../../wallet/component/wallet_card.dart';
import 'package:frezka/screens/order/view/order_detail_screen.dart';

class UserWalletHistoryScreen extends StatefulWidget {
  const UserWalletHistoryScreen({Key? key}) : super(key: key);

  @override
  State<UserWalletHistoryScreen> createState() => _UserWalletHistoryScreenState();
}

class _UserWalletHistoryScreenState extends State<UserWalletHistoryScreen> {
  Future<List<WalletDataElement>>? future;

  List<WalletDataElement> walletHistoryList = [];
  int page = 1;
  bool isLastPage = false;
  num availableBalance = 0;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    future = getUserWalletHistory(
      page,
      walletDataList: walletHistoryList,
      availableBalance: (p0) {
        availableBalance = p0;
      },
      lastPageCallBack: (p) {
        isLastPage = p;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBarWidget: commonAppBarWidget(
        context,
        title: locale.walletHistory,
        appBarHeight: 70,
        roundCornerShape: true,
        showLeadingIcon: true,
      ),
      body: Container(
        color: context.scaffoldBackgroundColor,
        child: Stack(
          children: [
            SnapHelperWidget<List<WalletDataElement>>(
              initialData: cachedWalletHistoryList,
              future: future,
              loadingWidget: WalletHistoryShimmer(),
              onSuccess: (snap) {
                return AnimatedScrollView(
                  children: [
                    16.height,
                    WalletCard(
                        availableBalance: availableBalance,
                        callback: (value) {
                          if (value ?? false) {
                            init();
                            setState(() {});
                          }
                        }),
                    10.height,
                    // Recent Transactions Header
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        locale.recentTransactions,
                        style: primaryTextStyle(size: 16, weight: FontWeight.w600),
                      ),
                    ),
                    12.height,
                    AnimatedListView(
                      physics: NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.only(bottom: 16),
                      listAnimationType: ListAnimationType.FadeIn,
                      fadeInConfiguration: FadeInConfiguration(duration: 2.seconds),
                      itemCount: snap.length,
                      emptyWidget: NoDataWidget(title: locale.noDataAvailable, imageWidget: EmptyStateWidget()),
                      shrinkWrap: true,
                      disposeScrollController: true,
                      itemBuilder: (BuildContext context, index) {
                        WalletDataElement data = snap[index];

                        return GestureDetector(
                          onTap: () {
                            final activity = data.activityData;
                            if (activity == null) return;

                            final String type = activity.transactionType.validate().toLowerCase();
                            final String message = data.activityMessage.validate().toLowerCase();

                            int? extractHashId(String src) {
                              final match = RegExp(r"#(\d+)").firstMatch(src);
                              return match != null ? int.tryParse(match.group(1)!) : null;
                            }

                            // Navigate to Booking Detail
                            if (type.contains('booking') || message.contains('booking #') || activity.bookingId > 0) {
                              final int bookingId = activity.bookingId > 0 ? activity.bookingId : (extractHashId(message) ?? data.id);
                              BookingDetailScreen(bookingId: bookingId).launch(context);
                              return;
                            }

                            // Navigate to Order Detail
                            if (type.contains('order') || message.contains('order #') || activity.orderId > 0) {
                              final int? orderId = activity.orderId > 0 ? activity.orderId : extractHashId(message);
                              if (orderId != null) {
                                OrderDetailScreen(orderId: orderId, orderCode: '#$orderId').launch(context);
                              }
                              return;
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.all(16),
                            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            decoration: boxDecorationWithRoundedCorners(
                              borderRadius: BorderRadius.circular(6),
                              backgroundColor: Colors.white,
                            ),
                            child: Row(
                              children: [
                                // Transaction Icon
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: boxDecorationWithRoundedCorners(
                                    boxShape: BoxShape.circle,
                                    backgroundColor: data.activityData!.transactionType.isEmptyOrNull
                                        ? Colors.redAccent.withAlpha(40)
                                        : data.activityData!.transactionType.toLowerCase().contains(PAYMENT_STATUS_DEBIT)
                                            ? Colors.redAccent.withAlpha(40)
                                            : Color(0xFFD0F2E1),
                                  ),
                                  child: Icon(
                                    data.activityData!.transactionType.isEmptyOrNull
                                        ? Icons.arrow_outward_outlined
                                        : data.activityData!.transactionType.toLowerCase().contains(PAYMENT_STATUS_DEBIT)
                                            ? Icons.arrow_outward_outlined
                                            : Icons.south_west,
                                    size: 20,
                                    color: data.activityData!.transactionType.isEmptyOrNull
                                        ? Colors.red
                                        : data.activityData!.transactionType.toLowerCase().contains(PAYMENT_STATUS_DEBIT)
                                            ? Colors.red
                                            : Colors.green,
                                  ),
                                ),
                                16.width,
                                // Transaction Details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (data.activityMessage.validate().isNotEmpty)
                                        Text(
                                          data.activityMessage.validate(),
                                          style: primaryTextStyle(
                                            size: 14,
                                            weight: FontWeight.w600,
                                            color: charcoalColor,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      4.height,
                                      Text(
                                        formatDate(data.datetime, showDateWithTime: true),
                                        style: secondaryTextStyle(
                                          size: 12,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                // Amount
                                PriceWidget(
                                  price: data.activityData!.creditDebitAmount.validate(),
                                  color: data.activityData!.transactionType.isEmptyOrNull
                                      ? Colors.red
                                      : data.activityData!.transactionType.toLowerCase().contains(PAYMENT_STATUS_DEBIT)
                                          ? Colors.red
                                          : Colors.green,
                                  size: 14,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                  onNextPage: () {
                    if (!isLastPage) {
                      page++;
                      init();
                      setState(() {});
                    }
                  },
                  onSwipeRefresh: () async {
                    page = 1;
                    init();
                    setState(() {});
                    return await 2.seconds.delay;
                  },
                );
              },
              errorBuilder: (error) {
                return NoDataWidget(
                  title: error,
                  imageWidget: ErrorStateWidget(),
                  retryText: locale.reload,
                  onRetry: () {
                    page = 1;
                    appStore.setLoading(true);

                    init();
                    setState(() {});
                  },
                );
              },
            ),
            Observer(builder: (_) => LoaderWidget().visible(appStore.isLoading && page != 1)),
          ],
        ),
      ),
    );
  }
}
