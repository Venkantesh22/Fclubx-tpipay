import 'package:flutter/material.dart';
import 'package:frezka/main.dart';
import 'package:frezka/screens/order/component/order_review_component.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../components/cached_image_widget.dart';
import '../../../components/price_widget.dart';
import '../../../components/view_all_label_component.dart';
import '../../../utils/colors.dart';
import '../../../utils/constants.dart';
import '../../cart/model/cart_list_response.dart';

class AboutProductComponent extends StatelessWidget {
  final List<CartListData> orderList;
  final String? deliveryStatus;
  final VoidCallback? onReviewUpdate;

  AboutProductComponent({
    required this.orderList,
    this.deliveryStatus,
    this.onReviewUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ViewAllLabel(
          label: locale.aboutProduct,
          isShowAll: false,
          labelSize: 14,
        ),
        16.height,
        ListView.separated(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: orderList.validate().length,
          separatorBuilder: (context, index) => 12.height,
          itemBuilder: (context, index) {
            CartListData orderData = orderList.validate()[index];

            return Container(
              decoration: boxDecorationDefault(
                color: context.cardColor,
                borderRadius: radius(4),
                border: Border.all(color: borderColor, width: 0.5),
              ),
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Product info row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Image
                      Container(
                        width: 75,
                        height: 75,
                        decoration: boxDecorationDefault(
                          color: scaffoldPrimaryLight,
                          borderRadius: radius(8),
                          border: Border.all(color: borderColor, width: 0.5),
                        ),
                        child: ClipRRect(
                          borderRadius: radius(4),
                          child: CachedImageWidget(
                            url: orderData.productImage.validate(),
                            height: 75,
                            width: 75,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      12.width,

                      // Product Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Product Name
                            Text(
                              orderData.productName.validate(),
                              style: boldTextStyle(size: 16),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            8.height,

                            // Quantity and Price Row
                            Row(
                              children: [
                                Text(
                                  'x ${orderData.qty.validate()}',
                                  style: secondaryTextStyle(size: 14),
                                ),
                                Container(
                                  width: 4,
                                  height: 4,
                                  margin: EdgeInsets.symmetric(horizontal: 8),
                                  decoration: BoxDecoration(
                                    color: mediumGreyColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                PriceWidget(
                                  price: orderData.getProductPrice.validate(),
                                  color: primaryColor,
                                  size: 14,
                                  isBoldText: true,
                                ),
                              ],
                            ),
                            8.height,

                            // Weight/Variation
                            if (orderData.productVariationType != null && orderData.productVariationValue.validate().isNotEmpty)
                              Row(
                                children: [
                                  Text(
                                    '${orderData.productVariationType.validate()}: ',
                                    style: secondaryTextStyle(size: 14),
                                  ),
                                  Text(
                                    orderData.productVariationValue.validate(),
                                    style: primaryTextStyle(size: 14),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  8.height,
                  /// Review section
                  if (deliveryStatus == OrderStatusConst.DELIVERED)
                    OrderReviewComponent(
                      deliveryStatus: deliveryStatus,
                      productId: orderData.productId.validate(),
                      productVariationId: orderData.productVariationId.validate(),
                      productReview: orderData.productReviewData,
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
