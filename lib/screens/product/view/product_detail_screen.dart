import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frezka/components/app_scaffold.dart';
import 'package:frezka/components/loader_widget.dart';
import 'package:frezka/screens/product/component/product_description_component.dart';
import 'package:frezka/screens/product/component/product_quantity_component.dart';
import 'package:frezka/screens/product/model/product_detail_response.dart';
import 'package:frezka/screens/product/view/product_wish_list_screen.dart';
import 'package:frezka/utils/app_common.dart';
import 'package:frezka/utils/extensions/string_extensions.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../components/add_to_cart_animation.dart';
import '../../../components/cached_image_widget.dart';
import '../../../components/empty_error_state_widget.dart';
import '../../../main.dart';
import '../../../utils/colors.dart';
import '../../../utils/common_base.dart';
import '../../../utils/constants.dart';
import '../../../utils/custom_toast_widget.dart';
import '../../../utils/images.dart';
import '../../../utils/model_keys.dart';
import '../../cart/cart_repository.dart';
import '../../cart/component/cart_icon_btn.dart';
import '../../cart/view/cart_screen.dart';
import '../component/product_info_component.dart';
import '../component/product_packet_component.dart';
import '../component/product_rating_review_component.dart';
import '../component/add_review_form_component.dart';
import '../component/product_slider_component.dart';
import '../component/top_product_component.dart';
import '../model/product_list_response.dart';
import '../product_repository.dart';

late VoidCallback onProductDetailUpdate;

class ProductDetailScreen extends StatefulWidget {
  final ProductData productData;
  final bool isFromWishList;

  ProductDetailScreen({
    required this.productData,
    this.isFromWishList = false,
  });

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  Future<ProductDetailResponse>? future;

  ProductDetailResponse productDetailRes = ProductDetailResponse();

  final GlobalKey _cartKey = GlobalKey();
  final GlobalKey _productImageKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();
  
  @override
  void initState() {
    super.initState();
    init();
    setStatusBarColor(Colors.transparent);
    

    onProductDetailUpdate = () {
      init(flag: true);
    };
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void init({bool flag = false}) async {
    /// Product Detail Api
    future = getProductDetail(
      productId: widget.isFromWishList ? widget.productData.productId.validate() : widget.productData.id.validate(),
      userId: appStore.isLoggedIn ? userStore.userId : null,
      onResult: (value) {
        productDetailRes = value;
        if (productDetailRes.data!.variationData.validate().isNotEmpty) {
          productStore.setSelectedVariationData(productDetailRes.data!.variationData.validate().first);
        }
      },
    );

    if (flag) setState(() {});
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  Future<void> onTapFavourite(ProductData data) async {
    appStore.setLoading(true);

    if (data.inWishlist == 1) {
      data.inWishlist = 0;
      setState(() {});

      await removeFromWishList(productId: data.id.validate()).then((value) {
        appStore.setLoading(false);
        if (!value) {
          data.inWishlist = 0;
          setState(() {});
        }
      });
    } else {
      data.inWishlist = 1;
      setState(() {});

      await addToWishList(productId: data.id.validate()).then((value) {
        appStore.setLoading(false);
        if (!value) {
          data.inWishlist = 1;
          setState(() {});
        }
      });
    }
  }

  Widget actionsWidget({required Widget widget, VoidCallback? onTap}) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: boxDecorationWithShadow(boxShape: BoxShape.circle, backgroundColor: context.cardColor),
      child: widget,
    ).onTap(() {
      onTap?.call();
    }, highlightColor: Colors.transparent, splashColor: Colors.transparent, hoverColor: Colors.transparent);
  }

  List<String> _buildProductGalleryList(ProductData productData) {
    List<String> galleryList = [];
    
    // Add product_image as first image if it exists
    if (productData.productImage.validate().isNotEmpty) {
      galleryList.add(productData.productImage!);
    }
    
    // Add gallery images (excluding duplicates)
    if (productData.productGallaryData.validate().isNotEmpty) {
      for (var galleryImage in productData.productGallaryData!) {
        if (galleryImage.validate().isNotEmpty && !galleryList.contains(galleryImage)) {
          galleryList.add(galleryImage);
        }
      }
    }
    
    return galleryList;
  }

  Future<void> addProductToCart({VoidCallback? onSuccess}) async {
    appStore.setLoading(true);

    Map request = {
      ProductModelKey.productId: widget.isFromWishList ? widget.productData.productId.validate() : widget.productData.id.validate(),
      ProductModelKey.productVariationId: productStore.selectedVariationData.id,
      ProductModelKey.qty: productStore.qty,
      ProductModelKey.locationId: 1,
    };

    await addToCart(request).then((value) {
      ShowToast.showSuccess(value.message!);
      final message = value.message?.toLowerCase() ?? '';
      final isAlreadyInCart = message.contains('already') || message.contains('exist') || message.contains('duplicate') || message.contains('present');
      if (!isAlreadyInCart && message.contains('added into cart')) {
        // Run the animation if cart key is available
        if (_cartKey.currentContext != null) {
          AddToCartAnimation.run(
            context: context,
            imageKey: _productImageKey,
            cartKey: _cartKey,
            child: CachedImageWidget(
              url: productDetailRes.data!.productGallaryData.validate().isNotEmpty ? productDetailRes.data!.productGallaryData.validate().first : '',
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

      appStore.setLoading(false);
      productStore.selectedVariationData.inCart = IN_CART;
      init(flag: true);

      onSuccess?.call();
    }).catchError((error) {
      appStore.setLoading(false);
      ShowToast.showError(error.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if(!didPop) {
          finish(context, productDetailRes.data!.inWishlist.validate());
        } 
      },
      child: AppScaffold(
        showAppBar: true,
        scaffoldBackgroundColor: context.scaffoldBackgroundColor,
        appBarWidget: commonAppBarWidget(
          context,
          title: locale.productDetail,
          titleSpacing: 0,
          appBarHeight: 70,
          roundCornerShape: true,
          showLeadingIcon: true,
          actions: [
            ic_heart.iconImage(
              size: 20,
              color: Colors.white,
            ).onTap(() {
              doIfLoggedIn(context, () async {
                ProductWishListScreen(isFromProductDetail: true).launch(context);
              });
            }, highlightColor: Colors.transparent, splashColor: Colors.transparent, hoverColor: Colors.transparent),
            4.width,
            CartIconBtnComponent(
              cartIconColor: Colors.white,
              showBGCardColor: false,
              cartKey: _cartKey,
              size: 20,
            ),
          ]
        ),
        body: SnapHelperWidget<ProductDetailResponse>(
          future: future,
          loadingWidget: LoaderWidget(),
          errorBuilder: (error) {
            return NoDataWidget(
              title: error,
              retryText: locale.reload,
              imageWidget: ErrorStateWidget(),
              onRetry: () {
                appStore.setLoading(true);

                init(flag: true);
              },
            );
          },
          onSuccess: (snap) {
            if (snap.data == null) {
              return NoDataWidget(
                title: locale.noDetailsFound,
                retryText: locale.reload,
                onRetry: () {
                  appStore.setLoading(true);

                  init(flag: true);
                },
              );
            }

            return Stack(
              children: [
                RefreshIndicator(
                  onRefresh: () async {
                    init(flag: true);
                    await 2.seconds.delay;
                  },
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    physics: AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.only(bottom: 85),
                    child: Column(
                      children: [
                        ProductSliderComponent(
                          productGalleryData: _buildProductGalleryList(snap.data!),
                          productImageKey: _productImageKey,
                        ),
                        ProductInfoComponent(productData: snap.data!),
                        ProductPacketComponent(productData: snap.data!),
                        6.height,
                        if (productStore.selectedVariationData.productStockQty != 0) ProductQuantityComponent(),
                        10.height,
                        ProductDescriptionComponent(productData: snap.data!),
                        20.height,
                        AddReviewFormComponent(
                          productData: snap.data!,
                          onReviewSubmitted: () {
                            init(flag: true);
                          },
                        ),
                        if (snap.data!.productReview.validate().isNotEmpty) ...[
                          10.height,
                          ProductRatingReviewComponent(reviewDetails: snap.data!.productReview.validate(), productReviewData: snap.data!),
                          20.height,
                        ],
                        16.height,
                        TopProductComponent(relatedProductData: snap.relatedProduct.validate(), categories: snap.data?.category ?? []),
                        20.height,
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: SizedBox(
                    width: context.width(),
                    child: Row(
                      children: [
                        AppButton(
                          color: context.cardColor,
                          width: 45,
                          height: 46,
                          splashColor: context.cardColor,
                          padding: EdgeInsets.zero,
                          child: snap.data!.inWishlist == 1 ? ic_fill_heart.iconImage(color: wishListColor, size: 26, fit: BoxFit.contain) : ic_heart.iconImage(color: primaryColor, size: 26),
                          onTap: () {
                            doIfLoggedIn(context, () {
                              onTapFavourite(snap.data!);
                            });
                          },
                        ).expand(),
                        8.width,
                        Observer(builder: (context) {

                          return AppButton(
                            color: productStore.selectedVariationData.productStockQty == 0 ? null : context.primaryColor,
                            width: 45,
                            height: 47,
                            enabled: productStore.selectedVariationData.productStockQty == 0 ? false : true,
                            disabledColor: productStore.selectedVariationData.productStockQty == 0 ? context.primaryColor.withValues(alpha: 0.8) : null,
                            splashColor: context.primaryColor,
                            padding: EdgeInsets.zero,
                            child: Text(
                              productStore.selectedVariationData.inCart == IN_CART ? locale.goToCart : locale.addToCart,
                              style: boldTextStyle(color: productStore.selectedVariationData.productStockQty == 0 ? Colors.white70 : Colors.white),
                            ),
                            onTap: () {
                              doIfLoggedIn(context, () async {
                                if (productStore.selectedVariationData.inCart == IN_CART) {
                                  await addProductToCart(
                                    onSuccess: () {
                                      CartScreen().launch(context);
                                    },
                                  );
                                } else {
                                  /// Add To Cart Api
                                  await addProductToCart();
                                }
                              });
                            },
                          ).expand(flex: 2);
                        }),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
