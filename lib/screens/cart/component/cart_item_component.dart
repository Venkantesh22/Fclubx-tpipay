import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frezka/main.dart';
import 'package:frezka/screens/product/model/product_list_response.dart';
import 'package:frezka/utils/constants.dart';
import 'package:frezka/utils/custom_toast_widget.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../components/cached_image_widget.dart';
import '../../../components/price_widget.dart';
import '../../../utils/colors.dart';
import '../../../utils/model_keys.dart';
import '../../product/view/product_detail_screen.dart';
import '../cart_repository.dart';
import '../model/cart_list_response.dart';
import '../view/cart_screen.dart';

class CartItemComponent extends StatefulWidget {
  final CartListData cartListData;
  final bool isSelected;
  final VoidCallback? onSelectionChanged;

  CartItemComponent({required this.cartListData, this.isSelected = false, this.onSelectionChanged});

  @override
  _CartItemComponentState createState() => _CartItemComponentState();
}

class _CartItemComponentState extends State<CartItemComponent> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  Future<void> removeCart() async {
    showConfirmDialogCustom(
      context,
      primaryColor: context.primaryColor,
      title: '${locale.areYouSureYouWantToRemove}?',
      positiveText: locale.remove,
      negativeText: locale.cancel,
      onAccept: (ctx) async {
        appStore.setLoading(true);

        await removeFromCart(cartId: widget.cartListData.id.validate()).then((value) {
          productStore.setCartItemCount(productStore.cartItemCount - 1);
          ShowToast.showSuccess(value.message!);
          appStore.setLoading(false);
          productStore.selectedVariationData.inCart = 0;

          // Defer the callback to avoid navigation lock issues
          WidgetsBinding.instance.addPostFrameCallback((_) {
            onCartListUpdate.call();
          });
        }).catchError((error) {
          appStore.setLoading(false);
          ShowToast.showError(error.toString());
        });
      },
    );
  }

  Future<void> updateCartAPi({int? previousQty}) async {
    appStore.setLoading(true);

    Map request = {
      ProductModelKey.productId: widget.cartListData.productId,
      ProductModelKey.cartId: widget.cartListData.id,
      ProductModelKey.productVariationId: widget.cartListData.productVariationId,
      ProductModelKey.qty: widget.cartListData.qty,
    };

    await updateCart(request).then((value) {
      appStore.setLoading(false);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        onCartListUpdate.call();
      });
    }).catchError((error) {
      if (previousQty != null) {
        widget.cartListData.qty = previousQty;
      }
      appStore.setLoading(false);
      ShowToast.showError(error.toString());
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.width(),
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.only(left: 16, right: 16, bottom: 16),
      decoration: boxDecorationDefault(
        color: context.cardColor,
        borderRadius: radius(6),
        border: Border.all(color: borderColor, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              Container(
                width: 80,
                height: 80,
                decoration: boxDecorationWithRoundedCorners(
                  borderRadius: radius(8),
                  backgroundColor: context.cardColor,
                  border: Border.all(color: borderColor, width: 0.5),
                ),
                child: CachedImageWidget(
                  url: widget.cartListData.productImage.validate(),
                  height: 80,
                  width: 80,
                  fit: BoxFit.cover,
                  radius: 8,
                ),
              ).onTap(onProductTap),
              16.width,
              // Product Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Name
                    Text(
                      widget.cartListData.productName.validate(),
                      style: boldTextStyle(size: 16),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ).onTap(onProductTap),
                    5.height,
                    // Pricing
                    Row(
                      children: [
                        if (widget.cartListData.productVariation != null) ...[
                          PriceWidget(
                            price: widget.cartListData.productVariation!.discountedProductPrice.validate() * widget.cartListData.qty.validate(),
                            size: 14,
                            color: appStore.isDarkMode ? white : black,
                          ),
                          if (widget.cartListData.isDiscount)...[
                            4.width,
                            PriceWidget(
                              price: widget.cartListData.productVariation!.taxIncludeProductPrice.validate() * widget.cartListData.qty.validate(),
                              size: 14,
                              color: textSecondaryColorGlobal,
                              isLineThroughEnabled: true,
                            ),
                            4.width,
                            Text(
                              widget.cartListData.discountType == 'percent' ?  '(${widget.cartListData.discountValue.validate()}% ${locale.off.toUpperCase()})': '(${leftCurrencyFormat()}${(widget.cartListData.productVariation!.taxIncludeProductPrice.validate() - (widget.cartListData.productVariation!.discountedProductPrice.validate().toDouble())).toStringAsFixed(getIntAsync(ConfigurationKeyConst.NO_OF_DECIMAL, defaultValue: DECIMAL_POINT).toInt())}${rightCurrencyFormat()} ${locale.off.toUpperCase()})',
                              style: primaryTextStyle(color: greenColor, size: 12)
                            ),
                          ],
                        ] else ...[
                          PriceWidget(
                            price: widget.cartListData.getProductPrice.validate() * widget.cartListData.qty.validate(),
                            size: 14,
                            color: appStore.isDarkMode ? white : black,
                          ),
                        ],
                      ],
                    ),
                    5.height,
                    if (widget.cartListData.productVariationValue != null)...[
                      Row(
                        children: [
                          Text(
                            '${widget.cartListData.productVariationType}: ',
                            style: secondaryTextStyle(size: 13),
                          ),
                          Text(
                            widget.cartListData.productVariationName.validate(),
                            style: primaryTextStyle(size: 13),
                          ),
                        ],
                      ),
                      5.height,
                    ],
                    // Quantity Control
                    Row(
                      children: [
                        Text(locale.quantity, style: secondaryTextStyle(size: 12, color: appStore.isDarkMode ? white : black, weight: FontWeight.w600)),
                        8.width,
                        Container(
                          height: 35,
                          width: 90,
                          padding: EdgeInsets.symmetric(horizontal: 2),
                          decoration: boxDecorationWithRoundedCorners(
                            backgroundColor: appStore.isDarkMode ? scaffoldPrimaryDark : scaffoldPrimaryLight,
                            borderRadius: radius(3),
                            border: Border.all(color: borderColor),
                          ),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  if (widget.cartListData.qty.validate() > 1) {
                                    widget.cartListData.qty = widget.cartListData.qty.validate() - 1;
                                    await updateCartAPi();
                                    setState(() {});
                                  } else {
                                    await removeCart();
                                  }
                                },
                                child: Icon(Icons.remove, color: textSecondaryColorGlobal, size: 16),
                              ),
                              14.width,
                              Text('${widget.cartListData.qty}', style: boldTextStyle(size: 16)),
                              14.width,
                              GestureDetector(
                                onTap: () async {
                                  final int prevQty = widget.cartListData.qty.validate();
                                  final int stockQty = widget.cartListData.productVariation?.productStockQty.validate() ?? 0;

                                  if (stockQty > 0 && prevQty >= stockQty) {
                                    ShowToast.showInfo(locale.onlyAvailable(stockQty));
                                    return;
                                  }

                                  widget.cartListData.qty = prevQty + 1;
                                  await updateCartAPi(previousQty: prevQty);
                                  setState(() {});
                                },
                                child: Icon(Icons.add, color: textSecondaryColorGlobal, size: 16),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    12.height,
                    // Shipping and Delivery Info
                    Observer(
                      builder: (context) {
                        final isFreeShipping = productStore.logisticZoneData.standardDeliveryCharge == 0;
                        final hasNoTax = productStore.cartPriceData.taxAmount == 0;

                        return Column(
                          children: [
                            if (isFreeShipping || hasNoTax)
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      isFreeShipping && hasNoTax
                                          ? locale.freeShippingNoTaxApplied
                                          : isFreeShipping
                                              ? locale.freeShipping
                                              : locale.noTaxApplied,
                                      style: secondaryTextStyle(size: 12, color: greenColor),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              // Remove Button
              GestureDetector(
                onTap: () async {
                  await removeCart();
                },
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: boxDecorationWithRoundedCorners(
                    borderRadius: radius(16),
                    backgroundColor: context.scaffoldBackgroundColor,
                    border: Border.all(color: borderColor),
                  ),
                  child: Icon(Icons.close, color: textSecondaryColorGlobal, size: 10),  
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void onProductTap() {
    Future.delayed(Duration(milliseconds: 100), () {
      if (context.mounted) {
        ProductDetailScreen(
            productData: ProductData(
          name: widget.cartListData.productName,
          description: widget.cartListData.productDescription,
          productId: widget.cartListData.productId,
          id: widget.cartListData.productId,
        )).launch(context);
      }
    });
  }
}
