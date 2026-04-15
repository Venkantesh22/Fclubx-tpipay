import 'package:flutter/material.dart';
import 'package:frezka/screens/category/model/category_response.dart';
import 'package:frezka/screens/product/view/product_detail_screen.dart';
import 'package:frezka/screens/product/view/product_list_screen.dart';
import 'package:frezka/utils/extensions/string_extensions.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../components/cached_image_widget.dart';
import '../../../components/price_widget.dart';
import '../../../main.dart';
import '../../../screens/cart/cart_repository.dart';
import '../../../utils/colors.dart';
import '../../../utils/common_base.dart';
import '../../../utils/custom_toast_widget.dart';
import '../../../utils/images.dart';
import '../model/product_list_response.dart';

class TopProductComponent extends StatefulWidget {
  final List<ProductData> relatedProductData;
  final List<CategoryData> categories ;

  TopProductComponent({required this.relatedProductData, required this.categories});

  @override
  State<TopProductComponent> createState() => _TopProductComponentState();
}

class _TopProductComponentState extends State<TopProductComponent> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  Future<void> onTapFavourite(ProductData relatedProductData) async {
    appStore.setLoading(true);

    if (relatedProductData.inWishlist == 1) {
      relatedProductData.inWishlist = 0;
      setState(() {});

      await removeFromWishList(productId: relatedProductData.id.validate()).then((value) {
        appStore.setLoading(false);
        if (!value) {
          relatedProductData.inWishlist = 0;
          setState(() {});
        }
      });
    } else {
      relatedProductData.inWishlist = 1;
      setState(() {});

      await addToWishList(productId: relatedProductData.id.validate()).then((value) {
        appStore.setLoading(false);
        if (!value) {
          relatedProductData.inWishlist = 1;
          setState(() {});
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.relatedProductData.isEmpty) return Offstage();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              locale.relatedProducts,
              style: boldTextStyle(
                size: 14,
                weight: FontWeight.w600,
              ),
            ),
            GestureDetector(
              onTap: () {
                ProductListScreen(appBarTitleText: locale.relatedProducts, productCategoryID: widget.categories.isEmpty ? null : widget.categories.first.id).launch(context);
              },
              child: Text(
                locale.viewAll,
                style: boldTextStyle(
                  size: 12,
                  weight: FontWeight.w700,
                  decoration: TextDecoration.underline,
                  decorationColor: primaryColor,
                  color: primaryColor,
                ),
              ),
            ),
          ],
        ),
        // Product List
        HorizontalList(
          // spacing: 10,
          itemCount: widget.relatedProductData.take(6).length,
          itemBuilder: (context, index) {
            ProductData data = widget.relatedProductData[index];
            return GestureDetector(
              onTap: () {
                ProductDetailScreen(productData: data, isFromWishList: false).launch(context);
              },
              child: Container(
                width: 182,
                height: 280,
                decoration: BoxDecoration(
                  color:context.cardColor,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: borderColor, width: 0.5),
                ),
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Product Image Section
                        Container(
                          height: 130,
                          width: 162,
                          margin: EdgeInsets.only(left: 10, right: 10, top: 10),
                          decoration: BoxDecoration(
                            color: context.scaffoldBackgroundColor,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(4),
                              topRight: Radius.circular(4),
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(4),
                              topRight: Radius.circular(4),
                            ),
                            child: CachedImageWidget(
                              url: data.productImage.validate(),
                              width: 162,
                              height: 130,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),

                        // Product Info Section
                        Container(
                          width: 161,
                          margin: EdgeInsets.only(left: 10, right: 10),
                          padding: EdgeInsets.only(top: 12),
                          decoration: BoxDecoration(
                            color: context.cardColor,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(5),
                              bottomRight: Radius.circular(5),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Product Name and Wishlist Row
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      data.name.validate().capitalizeFirstLetter(),
                                      style: primaryTextStyle(
                                        size: 14,
                                        weight: FontWeight.w600,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  4.width,
                                  GestureDetector(
                                    onTap: () {
                                      doIfLoggedIn(context, () {
                                        onTapFavourite(data);
                                      });
                                    },
                                    child: Container(
                                      padding: EdgeInsets.only(top: 2),
                                      child: data.inWishlist == 1 ? ic_fill_heart.iconImage(color: wishListColor, size: 16) : ic_heart.iconImage(color: context.iconColor, size: 16),
                                    ),
                                  ),
                                ],
                              ).paddingBottom(4),

                              // Price Section
                              Row(
                                children: [
                                  if (data.isDiscount && data.variationData.validate().isNotEmpty)
                                    PriceWidget(
                                      price: data.variationData!.first.discountedProductPrice.validate(),
                                      color: appStore.isDarkMode ? white : Colors.black,
                                      size: 16,
                                      isBoldText: true,
                                    ),
                                  if (data.isDiscount && data.variationData.validate().isNotEmpty) 14.width,
                                  if (data.variationData.validate().isNotEmpty)
                                    PriceWidget(
                                      price: data.variationData!.first.taxIncludeProductPrice.validate(),
                                      color: data.isDiscount ? textSecondaryColorGlobal : (appStore.isDarkMode ? white : Colors.black),
                                      size: 16,
                                      isLineThroughEnabled: data.isDiscount,
                                    ),
                                ],
                              ).paddingBottom(10),

                              // Add to Cart Button
                              if (data.variationData.validate().isNotEmpty && data.stockQty.validate() != 0)
                                Container(
                                  width: 162,
                                  height: 38,
                                  // margin: EdgeInsets.only(bottom: 5),
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      doIfLoggedIn(context, () async {
                                        appStore.setLoading(true);
                                        final variation = data.variationData!.first;
                                        final request = {
                                          'product_id': data.id,
                                          'product_variation_id': variation.id,
                                          'qty': 1,
                                        };
                                        try {
                                          final res = await addToCart(request);

                                          ShowToast.showSuccess(res.message.validate(value: locale.addToCart));
                                          if (res.status == true) {
                                            final message = res.message?.toLowerCase() ?? '';
                                            final isAlreadyInCart = message.contains('already') || message.contains('exist') || message.contains('duplicate') || message.contains('present');
                                            if (!isAlreadyInCart && message.contains('added into cart')) {
                                              productStore.setCartItemCount(productStore.cartItemCount + 1);
                                            }
                                          }
                                        } catch (e) {
                                          ShowToast.showError(e.toString());
                                        } finally {
                                          appStore.setLoading(false);
                                        }
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryColor,
                                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: Text(
                                      locale.addToCart.capitalizeFirstLetter(),
                                      style: boldTextStyle(size: 14, color: white),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    ).paddingSymmetric(horizontal: 16);
  }
}
