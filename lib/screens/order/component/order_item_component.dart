import 'package:flutter/material.dart';
import 'package:frezka/screens/order/component/order_list_component.dart';
import 'package:frezka/utils/extensions/num_extensions.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../components/cached_image_widget.dart';
import '../../../components/price_widget.dart';
import '../../../main.dart';
import '../../../utils/colors.dart';
import '../../../utils/common_base.dart';
import '../../../utils/constants.dart';
import '../../../utils/custom_toast_widget.dart';
import '../model/order_detail_response.dart';
import '../order_repository.dart';
import '../view/order_detail_screen.dart';

class OrderItemComponent extends StatelessWidget {
  final OrderListData getOrderData;

  OrderItemComponent({required this.getOrderData});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.width(),
      decoration: boxDecorationWithRoundedCorners(
        backgroundColor: context.cardColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: borderColor, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Padding(
            padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (getOrderData.orderCode != null)
                      Row(
                        children: [
                          Text("ID: ", style: secondaryTextStyle(size: 12)),
                          56.width,
                          Text("${getOrderData.orderCode.validate()}", style: boldTextStyle(size: 12)),
                        ],
                      ),
                    4.height,
                    Row(
                      children: [
                        Text(locale.dateTime + ": ", style: secondaryTextStyle(size: 12)),
                        Text(getOrderData.orderingDate.validate(), style: boldTextStyle(size: 12)),
                      ],
                    ),
                  ],
                ),
                PriceWidget(
                  price: getOrderData.totalAmount.validate(),
                  color: primaryColor,
                  size: 14,
                ),
              ],
            ),
          ),

          // Divider
          Divider(height: 1, color: context.dividerColor),

          // Product Section
          Container(
            padding: EdgeInsets.only(left: 16, right: 16, top: 16),
            child: Column(
              children: [
                if (getOrderData.productDetails.validate().isNotEmpty)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: scaffoldPrimaryLight,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CachedImageWidget(
                            url: getOrderData.productDetails.validate().first.productImage.validate(),
                            height: 60,
                            width: 60,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      12.width,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              getOrderData.productDetails.validate().first.productName.validate(),
                              style: boldTextStyle(size: 16),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            4.height,
                            Row(
                              children: [
                                Text(
                                  'x ${getOrderData.productDetails.validate().first.qty.validate()}',
                                  style: secondaryTextStyle(size: 14),
                                ),
                                Text(' • ', style: secondaryTextStyle(size: 14)),
                                Text('\$${getOrderData.productDetails.validate().first.getProductPrice.validate().toPriceStringFormate()}', style: boldTextStyle(color: primaryColor, size: 14)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                if (getOrderData.productDetails.validate().length > 1)
                  Container(
                    padding: EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        Text(
                          '+${getOrderData.productDetails.validate().length - 1} ${locale.more} ${locale.products}',
                          style: boldTextStyle(size: 12, color: appTextSecondaryColor),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          // Order Info Section
          Container(
            padding: EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  locale.orderInfo,
                  style: secondaryTextStyle(size: 12),
                ),
                12.height,
                Container(
                  padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 16),
                  decoration: boxDecorationWithRoundedCorners(
                    backgroundColor: appStore.isDarkMode ? scaffoldPrimaryDark : scaffoldPrimaryLight,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: borderColor, width: 0.5),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 20,
                                height: 20,
                                decoration: boxDecorationWithRoundedCorners(
                                  backgroundColor: Colors.transparent,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: context.iconColor, width: 2),
                                ),
                                child: Icon(
                                  Icons.attach_money,
                                  size: 12,
                                  color: context.iconColor,
                                ),
                              ),
                              8.width,
                              Text(
                                '${locale.paymentStatus}:',
                                style: secondaryTextStyle(size: 12),
                              ),
                            ],
                          ),
                          Text(
                            getOrderData.paymentStatus == BookingStatusConst.PAID ? locale.paid : locale.unpaid,
                            style: boldTextStyle(
                              color: getOrderData.paymentStatus == BookingStatusConst.PAID ? successColor : orangeColor,
                              size: 12,
                            ),
                          ),
                        ],
                      ),
                      12.height,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.calendar_today, size: 18, color: context.iconColor),
                              8.width,
                              Text('${locale.deliveryStatus}:', style: secondaryTextStyle(size: 12)),
                            ],
                          ),
                          Text(
                            '${getOrderBookingStatus(status: getOrderData.deliveryStatus.validate()).capitalizeEachWord()}',
                            style: boldTextStyle(size: 12, color: getOrderBookingStatusColor(status: getOrderData.deliveryStatus.validate())),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Footer Section
          Column(
            children: [
              // Align(
              //   alignment: Alignment.centerLeft,
              //   child: Text(
              //     locale.viewDetail,
              //     style: TextStyle(
              //       fontSize: 12,
              //       fontWeight: FontWeight.bold,
              //       shadows: [Shadow(color: context.primaryColor, offset: Offset(0, -2))],
              //       color: Colors.transparent,
              //       decoration: TextDecoration.underline,
              //       decorationColor: context.primaryColor,
              //       decorationThickness: 1,
              //       decorationStyle: TextDecorationStyle.solid,
              //     ),
              //   ).paddingOnly(left: 16),
              // ),

              // 8.height,

              // // Rate & Review Section for Delivered Orders
              // if (getOrderData.deliveryStatus == OrderStatusConst.DELIVERED)
              //   Container(
              //     margin: EdgeInsets.only(top: 16),
              //     padding: EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 10),
              //     width: double.infinity,
              //     height: 40,
              //     decoration: boxDecorationWithRoundedCorners(
              //       backgroundColor: territoryButtonColor,
              //       borderRadius: BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
              //     ),
              //     child: Row(
              //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //       children: [
              //         Text(
              //           locale.yourRatingHelpsUsGrow,
              //           style: boldTextStyle(size: 12, color: secondaryColor),
              //         ),
              //         InkWell(
              //           onTap: () {
              //             ProductReviewDialog.show(
              //               context,
              //               productReview: null,
              //               productId: getOrderData.productDetails.validate().first.productId,
              //               productVariationId: getOrderData.productDetails.validate().first.productVariationId,
              //             );
              //           },
              //           child: Text(
              //             locale.rateUs
              //             style: boldTextStyle(size: 12, color: primaryColor, decoration: TextDecoration.underline, decorationColor: primaryColor),
              //           ),
              //         ),
              //       ],
              //     ),
              //   ),

              if (getOrderData.deliveryStatus == OrderStatusConst.PLACED && 
                  getOrderData.paymentStatus == SERVICE_PAYMENT_STATUS_UNPAID)
                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () {
                      showConfirmDialogCustom(
                        context,
                        title: '${locale.doYouWantToCancel}?',
                        primaryColor: context.primaryColor,
                        positiveText: locale.yes,
                        negativeText: locale.no,
                        dialogType: DialogType.ACCEPT,
                        onAccept: (_) {
                          appStore.setLoading(true);

                          orderUpdate(orderId: getOrderData.id.validate()).then((value) {
                            onOrderListUpdate.call('');
                            appStore.setLoading(false);
                            ShowToast.showSuccess(locale.theOrderHasBeenCancelled);
                          }).catchError((e) {
                            appStore.setLoading(false);
                            ShowToast.showError(e.toString());
                          });
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      locale.cancelOrder,
                      style: boldTextStyle(color: Colors.white),
                    ),
                  ),
                ).paddingOnly(left: 16, right: 16, bottom: 16),
            ],
          ),
        ],
      ),
    ).onTap(() {
      hideKeyboard(context);
      OrderDetailScreen(orderId: getOrderData.id.validate(), orderCode: getOrderData.orderCode.validate()).launch(context, pageRouteAnimation: PageRouteAnimation.Fade);
    }, borderRadius: BorderRadius.circular(12), highlightColor: Colors.transparent, splashColor: Colors.transparent);
  }
}
