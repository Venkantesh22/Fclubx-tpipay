import 'package:flutter/material.dart';
import 'package:frezka/components/cached_image_widget.dart';
import 'package:frezka/utils/constants.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../components/price_widget.dart';
import '../../../main.dart';
import '../../services/models/service_response.dart';
import '../model/booking_detail_response.dart';

class BookingServiceInformationComponent extends StatelessWidget {
  final List<ServiceListData> serviceList;
  final List<ProductsInfo>? productList;
  final String? bookingStatus;

  BookingServiceInformationComponent({required this.serviceList, this.bookingStatus, this.productList});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (productList.validate().isNotEmpty && productList!.any((product) => product.discountedPrice.validate() > 0)) ...[
          Text(locale.parchasedProducts, style: boldTextStyle(size: LABEL_TEXT_SIZE)).paddingBottom(12),
          AnimatedWrap(
            runSpacing: 16,
            itemCount: productList.validate().where((product) => product.discountedPrice.validate() > 0).length,
            itemBuilder: (context, index) {
              ProductsInfo productData = productList.validate()[index];

              return Container(
                decoration: boxDecorationDefault(color: context.cardColor),
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CachedImageWidget(
                          url: productData.productImage.validate(),
                          height: 60,
                          width: 60,
                          fit: BoxFit.cover,
                          radius: defaultRadius,
                        ),
                        12.width,
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(productData.productName.validate(), style: boldTextStyle(), maxLines: 1, overflow: TextOverflow.ellipsis),
                            4.height,
                            Text(productData.variationName.validate(), style: primaryTextStyle()),
                            if (productData.variationName != null)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text('${locale.qty}: ', style: secondaryTextStyle(size: 13)),
                                      Text(productData.productQty.validate().toString(), style: primaryTextStyle()),
                                    ],
                                  ),
                                  PriceWidget(price: productData.discountedPrice.validate(), size: 14),
                                ],
                              ),
                          ],
                        ).expand(),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          if (productList.validate().isNotEmpty) 8.height,
        ]
      ],
    );
  }
}
