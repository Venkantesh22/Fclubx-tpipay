import 'package:flutter/material.dart';
import 'package:frezka/components/app_scaffold.dart';
import 'package:frezka/components/cached_image_widget.dart';
import 'package:frezka/components/loader_widget.dart';
import 'package:frezka/components/price_widget.dart';
import 'package:frezka/screens/product/view/product_wish_list_screen.dart';
import 'package:frezka/utils/colors.dart';
import 'package:frezka/utils/common_base.dart';
import 'package:frezka/utils/custom_toast_widget.dart';
import 'package:frezka/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../../components/empty_error_state_widget.dart';
import '../../../main.dart';
import '../../../utils/app_common.dart';
import '../../../utils/constants.dart';
import '../../cart/cart_repository.dart';
import '../../cart/component/cart_icon_btn.dart';
import '../../cart/model/cart_list_response.dart';
import '../component/best_seller_product_component.dart';
import '../component/discount_product_component.dart';
import '../component/featured_product_component.dart';
import '../component/product_category_component.dart';
import '../component/product_item_component.dart';
import '../model/product_dashboard_response.dart';
import '../model/product_list_response.dart';
import '../product_repository.dart';

late VoidCallback onProductDashboardUpdate;

class ProductScreen extends StatefulWidget {
  @override
  _ProductScreenState createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen>
    with TickerProviderStateMixin {
  TextEditingController searchProductCont = TextEditingController();

  FocusNode searchFocusNode = FocusNode();

  Future<ProductDashboardResponse>? future;

  final GlobalKey _cartKey = GlobalKey();

  ///Search
  Future<List<ProductData>>? searchFuture;

  List<ProductData> productList = [];
  (List<CartListData>, CartListResponse) cartList = ([], CartListResponse());

  int page = 1;
  bool isLastPage = false;

  // Filters
  RangeValues priceRange = RangeValues(15, 200);
  String? sortBy; // 'price_low','price_high','newest','rating'
  bool isFilterApplied = false;

  // Voice search
  SpeechToText speech = SpeechToText();
  String lastWords = '';

  @override
  void initState() {
    super.initState();
    init();
    if (appStore.isLoggedIn) getCartList(cartList: cartList);
    onProductDashboardUpdate = () {
      init(flag: true);
    };
    searchProductCont.addListener(() => setState(() {}));
  }

  void handleSearch({bool flag = false}) async {
    searchFuture = getProductList(
      search: searchProductCont.text.trim(),
      page: page,
      products: productList,
      minPrice: isFilterApplied ? priceRange.start.toStringAsFixed(0) : '',
      maxPrice: isFilterApplied ? priceRange.end.toStringAsFixed(0) : '',
      perPage: isFilterApplied ? 1000 : PER_PAGE_ITEM,
      lastPageCallBack: (p) {
        isLastPage = p;
      },
    ).whenComplete(() {
      if (flag) setState(() {});
    });
  }

  void init({bool flag = false}) async {
    future =
        productDashboard(userId: appStore.isLoggedIn ? userStore.userId : null);

    if (flag) setState(() {});
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  RangeValues reviewRange = RangeValues(1, 5);

  void startListening() async {
    bool available = await speech.initialize(
        onStatus: statusListener, onError: errorListener);

    if (available) {
      appStore.setSpeechStatus(true);
      lastWords = '';
      speech.listen(
          onResult: resultListener,
          listenFor: Duration(seconds: 30),
          pauseFor: Duration(seconds: 10),
          listenOptions: SpeechListenOptions(
            listenMode: ListenMode.deviceDefault,
            cancelOnError: true,
            partialResults: true,
          ));

      setState(() {});
    } else {
      appStore.setSpeechStatus(false);
      ShowToast.showError(locale.theUserHasDeniedSpeechRecognition);
    }
  }

  void stopListening() {
    appStore.setSpeechStatus(false);
    speech.stop();
  }

  void resultListener(SpeechRecognitionResult result) {
    appStore.setSpeechStatus(false);
    if (result.finalResult) {
      lastWords = result.recognizedWords;
      searchProductCont.text = lastWords;
      page = 1;
      productList.clear();
      handleSearch(flag: true);
    }
  }

  void errorListener(SpeechRecognitionError error) {
    appStore.setSpeechStatus(false);
    log("Speech error: ${error.errorMsg} - ${error.permanent}");
  }

  void statusListener(String status) {
    setState(() {
      log("Speech status: $status");
    });

    if (status == 'done') {
      appStore.setSpeechStatus(false);
    }
  }

  @override
  void dispose() {
    searchProductCont.dispose();
    searchFocusNode.dispose();
    appStore.setSpeechStatus(false);
    speech.stop();
    super.dispose();
  }

  num productSortPrice(ProductData product) {
    final variations = product.variationData.validate();
    if (variations.isEmpty) return 0;
    return variations.first.taxIncludeProductPrice.validate();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBarWidget: PreferredSize(
        preferredSize: Size(context.width(), 100),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              width: context.width(),
              height: 150,
              decoration: boxDecorationWithRoundedCorners(
                  borderRadius: radiusOnly(bottomLeft: 20, bottomRight: 20),
                  backgroundColor: context.primaryColor),
              child: appBarWidget(
                locale.shop,
                center: true,
                showBack: false,
                color: context.primaryColor,
                textColor: white,
                textSize: APPBAR_TEXT_SIZE,
                actions: [
                  IconButton(
                    icon: Icon(Icons.favorite_border_outlined,
                        color: Colors.white),
                    onPressed: () async {
                      doIfLoggedIn(context, () {
                        ProductWishListScreen().launch(context).then((value) {
                          init();
                          setState(() {});
                        });
                      });
                    },
                  ),
                  CartIconBtnComponent(cartKey: _cartKey),
                ],
              ).cornerRadiusWithClipRRectOnly(bottomLeft: 20, bottomRight: 20),
            ),
            Positioned(
              bottom: -20,
              left: 20,
              right: 20,
              child: Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      textFieldType: TextFieldType.OTHER,
                      focus: searchFocusNode,
                      controller: searchProductCont,
                      suffix: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                                  onTap: () {
                                    hideKeyboard(context);
                                    searchProductCont.clear();
                                    setState(() {});
                                  },
                                  child: Icon(Icons.close,
                                      color: context.iconColor))
                              .visible(searchProductCont.text.isNotEmpty),
                          6.width.visible(searchProductCont.text.isNotEmpty),
                          GestureDetector(
                              onTap: () {
                                startListening();
                              },
                              child: Icon(Icons.mic_none_outlined,
                                  color: context.iconColor)),
                          12.width.visible(searchProductCont.text.isNotEmpty),
                        ],
                      ),
                      onChanged: (s) {
                        page = 1;
                        productList.clear();
                        handleSearch(flag: true);
                      },
                      decoration: inputDecoration(context,
                          hint: locale.searchForProduct,
                          prefixIcon:
                              Icon(Icons.search, color: context.iconColor)),
                    ),
                  ),
                  16.width,
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: boxDecorationDefault(color: secondaryColor),
                    child: CachedImageWidget(
                      url: ic_filter,
                      height: 26,
                      width: 26,
                      color: Colors.white,
                    ),
                  ).onTap(() {
                    handleFilterClick(context);
                  })
                ],
              ),
            ),
          ],
        ),
      ),
      body: searchProductCont.text.trim().isNotEmpty || isFilterApplied
          ? SnapHelperWidget<List<ProductData>>(
              future: searchFuture,
              errorBuilder: (error) {
                return NoDataWidget(
                  title: error,
                  retryText: locale.reload,
                  imageWidget: ErrorStateWidget(),
                  onRetry: () {
                    page = 1;
                    appStore.setLoading(true);
                    productList.clear();
                    handleSearch(flag: true);
                  },
                );
              },
              loadingWidget: LoaderWidget(),
              onSuccess: (productList) {
                if (productList.isEmpty) {
                  return NoDataWidget(
                    title: locale.noProductsFound,
                    retryText: locale.reload,
                    onRetry: () {
                      page = 1;
                      appStore.setLoading(true);
                      productList.clear();
                      handleSearch(flag: true);
                    },
                  );
                }
                // Apply client-side sort if requested
                List<ProductData> display = List<ProductData>.from(productList);
                if (sortBy != null) {
                  switch (sortBy) {
                    case ProductSortConst.PRICE_LOW:
                      display.sort((a, b) =>
                          productSortPrice(a).compareTo(productSortPrice(b)));
                      break;
                    case ProductSortConst.PRICE_HIGH:
                      display.sort((a, b) =>
                          productSortPrice(b).compareTo(productSortPrice(a)));
                      break;
                    case ProductSortConst.NEWEST:
                      display.sort((a, b) =>
                          (b.id.validate()).compareTo(a.id.validate()));
                      break;
                    case ProductSortConst.RATING:
                      display.sort((a, b) =>
                          (b.rating.validate()).compareTo(a.rating.validate()));
                      break;
                    case ProductSortConst.DISCOUNT:
                      display = display.where((a) => a.isDiscount).toList();
                      break;
                  }
                }

                return AnimatedScrollView(
                  padding:
                      EdgeInsets.only(left: 16, right: 16, top: 40, bottom: 30),
                  onSwipeRefresh: () async {
                    page = 1;
                    productList.clear();
                    handleSearch(flag: true);

                    return await 2.seconds.delay;
                  },
                  onNextPage: () {
                    if (!isLastPage) {
                      page++;
                      appStore.setLoading(true);

                      handleSearch(flag: true);
                    }
                  },
                  children: [
                    AnimatedWrap(
                      itemCount: display.length,
                      spacing: 16,
                      runSpacing: 16,
                      itemBuilder: (context, index) {
                        return ProductItemComponent(
                            productListData: display[index], cartKey: _cartKey);
                      },
                    ),
                  ],
                );
              },
            )
          : SnapHelperWidget<ProductDashboardResponse>(
              future: future,
              initialData: productDashboardResponseCached,
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
                if (snap.data == null ||
                    snap.data!.category.validate().isEmpty) {
                  return NoDataWidget(
                    title: locale.atThisTimeThere,
                    retryText: locale.reload,
                    imageWidget: EmptyStateWidget(),
                    onRetry: () {
                      appStore.setLoading(true);

                      init();
                      setState(() {});
                    },
                  );
                }

                return AnimatedScrollView(
                  padding: EdgeInsets.only(top: 30),
                  listAnimationType: ListAnimationType.FadeIn,
                  onSwipeRefresh: () async {
                    init(flag: true);

                    return await 2.seconds.delay;
                  },
                  children: [
                    /// Product Category Component
                    ProductCategoryComponent(
                      productCategoryList: snap.data!.category.validate(),
                      allProducts: [
                        ...snap.data!.featuredProduct.validate(),
                        ...snap.data!.bestsellerProduct.validate(),
                        ...snap.data!.discountProduct.validate(),
                      ],
                      cartKey: _cartKey,
                    ),

                    16.height,

                    /// Featured Product Component
                    FeaturedProductComponent(
                        featuredProductList:
                            snap.data!.featuredProduct.validate(),
                        cartKey: _cartKey),

                    8.height,

                    /// Best Seller Product Component
                    BestSellerProductComponent(
                        bestSellerProductList:
                            snap.data!.bestsellerProduct.validate(),
                        cartKey: _cartKey),

                    16.height,

                    /// Discount Product Component
                    DiscountProductComponent(
                        discountProductList:
                            snap.data!.discountProduct.validate(),
                        cartKey: _cartKey),
                  ],
                );
              },
            ),
    );
  }

  void handleFilterClick(BuildContext context) {
    doIfLoggedIn(
      context,
      () {
        serviceCommonBottomSheet(
          context,
          title: locale.filterBy,
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return SnapHelperWidget<ProductDashboardResponse>(
                future: future,
                loadingWidget: LoaderWidget(),
                errorBuilder: (error) {
                  return NoDataWidget(
                    title: error,
                    retryText: locale.reload,
                    imageWidget: ErrorStateWidget(),
                    onRetry: () {
                      appStore.setLoading(true);
                      // fetchBookingStatusApi();
                      setState(() {});
                      init(flag: true);
                    },
                  );
                },
                onSuccess: (statusList) {
                  // if (statusList.isEmpty) {
                  //   return NoDataWidget(
                  //     title: locale.noTimeSlots,
                  //     retryText: locale.reload,
                  //     onRetry: () {
                  //       appStore.setLoading(true);
                  //
                  //       // fetchBookingStatusApi();
                  //       setState(() {});
                  //       init(flag: true);
                  //     },
                  //   );
                  // }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                              "${locale.priceRange}: ${leftCurrencyFormat()}${priceRange.start.toInt()}${rightCurrencyFormat()} - ${leftCurrencyFormat()}${priceRange.end.toInt()}${rightCurrencyFormat()}",
                              style: secondaryTextStyle()),
                          8.height,
                          RangeSlider(
                            values: priceRange,
                            min: 15,
                            max: 200,
                            divisions: 37,
                            activeColor: primaryColor,
                            padding: EdgeInsets.zero,
                            labels: RangeLabels(
                              "${leftCurrencyFormat()}${priceRange.start.toInt()}${rightCurrencyFormat()}",
                              "${leftCurrencyFormat()}${priceRange.end.toInt()}${rightCurrencyFormat()}",
                            ),
                            onChanged: (values) {
                              setModalState(() => priceRange = values);
                            },
                          ),
                          12.height,
                          Wrap(
                            spacing: 8,
                            children: [
                              ChoiceChip(
                                label: Text(locale.priceLowHigh),
                                selected: sortBy == ProductSortConst.PRICE_LOW,
                                onSelected: (_) => setModalState(
                                    () => sortBy = ProductSortConst.PRICE_LOW),
                              ),
                              ChoiceChip(
                                label: Text(locale.priceHighLow),
                                selected: sortBy == ProductSortConst.PRICE_HIGH,
                                onSelected: (_) => setModalState(
                                    () => sortBy = ProductSortConst.PRICE_HIGH),
                              ),
                              ChoiceChip(
                                label: Text(locale.newest),
                                selected: sortBy == ProductSortConst.NEWEST,
                                onSelected: (_) => setModalState(
                                    () => sortBy = ProductSortConst.NEWEST),
                              ),
                              ChoiceChip(
                                label: Text(locale.topRated),
                                selected: sortBy == ProductSortConst.RATING,
                                onSelected: (_) => setModalState(
                                    () => sortBy = ProductSortConst.RATING),
                              ),
                              ChoiceChip(
                                label: Text(locale.discount),
                                selected: sortBy == ProductSortConst.DISCOUNT,
                                onSelected: (_) => setModalState(
                                    () => sortBy = ProductSortConst.DISCOUNT),
                              ),
                            ],
                          ),
                          16.height,
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          AppButton(
                            text: locale.clearFilter,
                            textStyle: boldTextStyle(color: Colors.white),
                            color: secondaryColor,
                            onTap: () {
                              bookingRequestStore.selectedBookingStatusList
                                  .clear();
                              finish(context);
                              appStore.setLoading(true);
                              isFilterApplied = false;
                              sortBy = null;
                              priceRange = RangeValues(15, 200);
                              searchProductCont.clear();
                              page = 1;
                              init(flag: true);
                            },
                          ).expand(),
                          16.width,
                          AppButton(
                            text: locale.apply,
                            textStyle: boldTextStyle(color: Colors.white),
                            color: primaryColor,
                            onTap: () {
                              finish(context);
                              appStore.setLoading(true);
                              isFilterApplied = true;
                              page = 1;
                              productList.clear();
                              handleSearch(flag: true);
                            },
                          ).expand(),
                        ],
                      ),
                    ],
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
