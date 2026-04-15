import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frezka/utils/app_common.dart';
import 'package:frezka/utils/constants.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../components/price_widget.dart';
import '../../../main.dart';
import '../../../utils/colors.dart';
import '../model/product_list_response.dart';

class ProductInfoComponent extends StatelessWidget {
  final ProductData productData;

  ProductInfoComponent({required this.productData});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          16.height,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (productData.category != null && productData.category!.isNotEmpty)
                Text(
                  productData.category!.first.name.validate().toUpperCase(),
                  style: boldTextStyle(size: 12, color: appTextSecondaryColor),
                ),
              // Rating
              Row(
                children: [
                  RatingBarWidget(
                    onRatingChanged: (rating) {},
                    disable: true,
                    activeColor: accentOrangeColor,
                    inActiveColor: accentOrangeColor,
                    rating: productData.rating.validate().toDouble(),
                    size: 16,
                  ),
                  if (productData.rating != 0) 8.width,
                  if (productData.rating != 0)
                    Text(
                      productData.rating.toString().validate().toDouble().toStringAsPrecision(2),
                      style: boldTextStyle(size: 14),
                    ),
                ],
              ),
            ],
          ),
          12.height,
          // Product Info Content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Brand Name and Product Name Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    flex: 1,
                    child: Text(
                      productData.brandName.validate(),
                      style: secondaryTextStyle(size: 12, decoration: TextDecoration.underline, decorationColor: context.primaryColor, color: context.primaryColor),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  15.width,
                  Flexible(
                    flex: 3,
                    child: Text(
                      productData.name.validate().capitalizeFirstLetter(),
                      style: boldTextStyle(size: 16),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                ],
              ),
              4.height,
              // Product Description
              if (productData.description.validate().isNotEmpty)
                ReadMoreText(
                  parseHtmlString(productData.description),
                  trimLines: 3,
                  style: secondaryTextStyle(size: 14),
                  colorClickableText: primaryColor,
                  trimMode: TrimMode.Line,
                  trimCollapsedText: " ...${locale.readMore}",
                  trimExpandedText: locale.readLess,
                  locale: Localizations.localeOf(context),
                ),
            ],
          ),
          // Price and offer section
          Padding(
            padding: EdgeInsets.only(top: 16, bottom: 16),
            child: Container(
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: borderColor, width: 0.5)),
              ),
              padding: EdgeInsets.only(bottom: 24),
              child: Observer(builder: (context) {
                return Row(
                  children: [
                    if (productData.isDiscount)
                      PriceWidget(
                        price: productStore.selectedVariationData.discountedProductPrice.validate(),
                        color: appStore.isDarkMode ? white : black,
                        size: 20,
                        isBoldText: true,
                      ),
                    if (productData.isDiscount) 6.width,
                    PriceWidget(
                      price: productStore.selectedVariationData.taxIncludeProductPrice.validate(),
                      color: productData.isDiscount
                          ? textSecondaryColorGlobal
                          : appStore.isDarkMode
                              ? white
                              : black,
                      size: 16,
                      isLineThroughEnabled: productData.isDiscount,
                    ),
                    if (productData.isDiscount)...[
                      4.width,
                      Text(
                        productData.discountType == 'percent' ?  '(${productData.discountValue.validate()}% ${locale.off.toUpperCase()})': '(${leftCurrencyFormat()}${(productData.discountValue.validate().toDouble()).toStringAsFixed(getIntAsync(ConfigurationKeyConst.NO_OF_DECIMAL, defaultValue: DECIMAL_POINT).toInt())}${rightCurrencyFormat()} ${locale.off.toUpperCase()})',
                        style: primaryTextStyle(color: greenColor, size: 12)
                      ),
                    ] 
                  ],
                );
              }),
            ),
          ),
          if (productStore.selectedVariationData.productStockQty == 0) 16.height,
          if (productStore.selectedVariationData.productStockQty == 0) Text(locale.outOfStock, style: boldTextStyle(color: wishListColor)),
        ],
      ),
    );
  }
}
