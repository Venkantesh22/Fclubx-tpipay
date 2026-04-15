import 'package:flutter/material.dart';
import 'package:frezka/components/price_widget.dart';
import 'package:frezka/main.dart';
import 'package:frezka/screens/cart/cart_repository.dart';
import 'package:frezka/screens/cart/view/cart_screen.dart';
import 'package:frezka/utils/constants.dart';
import 'package:frezka/utils/extensions/string_extensions.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../components/add_to_cart_animation.dart';
import '../../../components/cached_image_widget.dart';
import '../../../utils/colors.dart';
import '../../../utils/common_base.dart';
import '../../../utils/custom_toast_widget.dart';
import '../../../utils/images.dart';
import '../model/product_list_response.dart';
import '../view/product_detail_screen.dart';

class ProductItemComponent extends StatefulWidget {
  final ProductData productListData;
  final bool isFromWishList;
  final bool isFromProductDetail;
  final VoidCallback? onWishlistUpdated;
  final GlobalKey? cartKey;
  final GlobalKey _productImageKey = GlobalKey();

  ProductItemComponent({
    required this.productListData,
    this.isFromWishList = false,
    this.isFromProductDetail = false,
    this.onWishlistUpdated,
    this.cartKey,
  });

  @override
  State<ProductItemComponent> createState() => _ProductItemComponentState();
}

class _ProductItemComponentState extends State<ProductItemComponent> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  Future<void> onTapFavourite() async {
    appStore.setLoading(true);

    if (widget.isFromWishList || widget.productListData.inWishlist == 1) {
      await removeFromWishList(
        productId: widget.isFromWishList ? null : widget.productListData.id.validate(),
        wishListId: widget.isFromWishList ? widget.productListData.id.validate() : null,
        isFromProductDetail: widget.isFromProductDetail,
      ).then((value) {
        appStore.setLoading(false);
        if (value) {
          widget.productListData.inWishlist = 0;
          widget.onWishlistUpdated?.call();
          setState(() {});
        }
      });
    } else {
      await addToWishList(productId: widget.productListData.id.validate()).then((value) {
        appStore.setLoading(false);
        if (value) {
          widget.productListData.inWishlist = 1;
          widget.onWishlistUpdated?.call();
          setState(() {});
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentProductId = widget.isFromWishList ? widget.productListData.productId ?? widget.productListData.id : widget.productListData.id;
    final isInCart = (widget.productListData.variationData?.isEmpty ?? true) ? false : widget.productListData.variationData?.first.inCart == 1;

    return Container(
      width: context.width() / 2 - 24,
      decoration: boxDecorationDefault(
        color: context.cardColor,
        borderRadius: radius(8),
        border: Border.all(color: borderColor, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Product Image Section
          Container(
            height: 90,
            width: double.infinity,
            margin: EdgeInsets.all(12),
            decoration: boxDecorationDefault(
              color: context.cardColor,
              borderRadius: radiusOnly(topLeft: 8, topRight: 8),
            ),
            child: Stack(
              children: [
                ClipRRect(
                  key: widget._productImageKey,
                  borderRadius: radiusOnly(topLeft: 8, topRight: 8),
                  child: CachedImageWidget(
                    url: widget.productListData.productImage.validate(),
                    width: double.infinity,
                    height: 90,
                    fit: BoxFit.fill,
                  ),
                ),

                // Discount badge
                Positioned(
                  left: 8,
                  top: 8,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: boxDecorationDefault(
                      color: Colors.red,
                      borderRadius: radius(4),
                    ),
                    child: Text(
                      '${widget.productListData
                      .discountType == TaxType.FIXED ? leftCurrencyFormat() : ''}${widget.productListData.discountValue}${widget.productListData
                      .discountType == TaxType.PERCENT ? '%' : ''}${widget.productListData
                      .discountType == TaxType.FIXED ? rightCurrencyFormat() : ''} ${locale.off.toUpperCase()}',
                      style: boldTextStyle(
                        color: Colors.white,
                        size: 10,
                      ),
                    ),
                  ),
                ).visible(widget.productListData.isDiscount),

                // Out of stock badge
                Positioned(
                  left: 8,
                  top: 8,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: boxDecorationDefault(color: white, borderRadius: radius(4)),
                    child: Text(
                      locale.outOfStock,
                      style: boldTextStyle(size: 12, color: context.primaryColor),
                    ),
                  ),
                ).visible(widget.productListData.stockQty == 0),
              ],
            ),
          ),

          // Product Details Section
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Category with Heart Icon
                if (widget.productListData.category?.isNotEmpty == true)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Marquee(
                          child: Text(
                            widget.productListData.category!.first.name.validate().toUpperCase(),
                            style: secondaryTextStyle(size: 12),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(6),
                        child: widget.productListData.inWishlist == 1 ? ic_fill_heart.iconImage(color: wishListColor, size: 14) : ic_heart.iconImage(color: context.iconColor, size: 14),
                      ).onTap(() {
                        doIfLoggedIn(context, () async {
                          if (!appStore.isLoading) onTapFavourite();
                        });
                      }, highlightColor: Colors.transparent, splashColor: Colors.transparent, hoverColor: Colors.transparent),
                    ],
                  ),

                // Product Name
                Marquee(
                  child: Text(
                    widget.isFromWishList ? widget.productListData.productName.validate() : widget.productListData.name.validate(),
                    style: boldTextStyle(size: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                2.height,

                // Price Section
                if (widget.productListData.variationData.validate().isNotEmpty) ...[
                  if (widget.productListData.isDiscount) ...[
                    Row(
                      children: [
                        PriceWidget(
                          price: widget.productListData.variationData!.first.discountedProductPrice.validate(),
                          size: 16,
                          color: appStore.isDarkMode ? white : black,
                        ),
                        6.width,
                        // Original price
                        PriceWidget(
                          price: widget.productListData.variationData!.first.taxIncludeProductPrice.validate(),
                          size: 16,
                          color: textSecondaryColorGlobal,
                          isLineThroughEnabled: true,
                        ),
                      ],
                    )
                    // Discounted price
                  ] else ...[
                    PriceWidget(
                      price: widget.productListData.variationData!.first.taxIncludeProductPrice.validate(),
                      size: 16,
                      color: appStore.isDarkMode ? white : black,
                    ),
                  ],
                ],
              ],
            ),
          ),

          // Add to Cart Button: In wishlist, show only for discounted products; hide if already in cart
          if (widget.productListData.variationData.validate().isNotEmpty && (widget.isFromWishList ? widget.productListData.variationData!.first.productStockQty != 0 : widget.productListData.stockQty.validate() != 0))
            Container(
              width: double.infinity,
              margin: EdgeInsets.only(left: 12, right: 12, bottom: 10),
              child: ElevatedButton(
                onPressed: () async {
                  doIfLoggedIn(context, () async {
                    if (isInCart) {
                      CartScreen().launch(context);
                      return;
                    }
                    final variation = widget.productListData.variationData!.first;
                    final request = {
                      'product_id': currentProductId,
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
                          if (widget.cartKey != null) {
                            AddToCartAnimation.run(
                              context: context,
                              imageKey: widget._productImageKey,
                              cartKey: widget.cartKey!,
                              child: CachedImageWidget(
                                url: widget.productListData.productImage.validate(),
                                width: 50,
                                height: 50,
                                fit: BoxFit.contain,
                              ),
                              onAnimationComplete: () {
                                productStore.setCartItemCount(productStore.cartItemCount + 1);
                              },
                            );
                          } else {
                            productStore.setCartItemCount(productStore.cartItemCount + 1);
                          }
                        }
                      }
                    } catch (e) {
                      ShowToast.showError(e.toString());
                    }
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  isInCart ? locale.goToCart : locale.addToCart,
                  style: boldTextStyle(color: Colors.white, size: 11),
                ),
              ),
            ),
        ],
      ),
    ).onTap(() async {
      final isAddedToWishlist = await ProductDetailScreen(productData: widget.productListData, isFromWishList: widget.isFromWishList).launch(context);
      if (isAddedToWishlist is int) {
        widget.productListData.inWishlist = isAddedToWishlist;
        setState(() {});
      }
    }, borderRadius: radius(), splashColor: Colors.transparent, highlightColor: Colors.transparent);
  }
}
