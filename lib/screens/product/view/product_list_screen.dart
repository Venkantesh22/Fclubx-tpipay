import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frezka/components/app_scaffold.dart';
import 'package:frezka/components/cached_image_widget.dart';
import 'package:frezka/components/common_bottom_sheet.dart';
import 'package:frezka/components/price_widget.dart';
import 'package:frezka/screens/product/component/product_item_component.dart';
import 'package:frezka/utils/colors.dart';
import 'package:frezka/utils/common_base.dart';
import 'package:frezka/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../components/back_widget.dart';
import '../../../components/empty_error_state_widget.dart';
import '../../../components/loader_widget.dart';
import '../../../components/voice_search_component.dart';
import '../../../main.dart';
import '../../../utils/constants.dart';
import '../../cart/component/cart_icon_btn.dart';
import '../model/product_list_response.dart';
import '../product_repository.dart';

late VoidCallback onProductListUpdate;

class ProductListScreen extends StatefulWidget {
  final int? productCategoryID;
  final String? appBarTitleText;
  final String isFeatured;
  final String isBestSeller;
  final String isBestDiscounts;

  ProductListScreen({this.productCategoryID, this.appBarTitleText, this.isFeatured = '', this.isBestSeller = '', this.isBestDiscounts = ''});

  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  TextEditingController searchProductCont = TextEditingController();
  FocusNode myFocusNode = FocusNode();

  Future<List<ProductData>>? future;

  final GlobalKey _cartKey = GlobalKey();
  List<ProductData> productList = [];
  int page = 1;
  bool isLastPage = false;

  // Sorting
  String selectedSort = ProductSortConst.POPULARITY;
  List<String> sortOptions = [
    ProductSortConst.POPULARITY,
    ProductSortConst.PRICE_LOW,
    ProductSortConst.PRICE_HIGH,
    ProductSortConst.NEWEST,
    ProductSortConst.DISCOUNT,
    ProductSortConst.RATING,
  ];

  // Filters
  Map<String, bool> activeFilters = {
    ProductFilterConst.PRICE: false,
    ProductFilterConst.RATING: false,
    ProductFilterConst.DISCOUNT: false,
  };

  RangeValues priceRange = RangeValues(0, 2000);
  double minPrice = 0;
  double maxPrice = 2000;

  RangeValues ratingRange = RangeValues(1, 5);
  RangeValues discountRange = RangeValues(0, 100);

  int activeFilterCount = 0;

  @override
  void initState() {
    super.initState();
    init();

    searchProductCont.addListener(() => setState(() {}));

    onProductListUpdate = () {
      init(flag: true);
    };
  }

  void init({bool flag = false, String search = ''}) async {
    future = getProductList(
      categoryId: widget.productCategoryID != null ? widget.productCategoryID.toString() : '',
      isFeatured: widget.isFeatured,
      bestSeller: widget.isBestSeller,
      bestDiscount: widget.isBestDiscounts,
      search: searchProductCont.text.trim(),
      page: page,
      products: productList,
      lastPageCallBack: (p) {
        isLastPage = p;
      },
    );
    if (flag) setState(() {});
  }

  void _updateFilterCount() {
    activeFilterCount = activeFilters.values.where((isActive) => isActive).length;
    setState(() {});
  }

  String _sortLabel(String code) {
    switch (code) {
      case ProductSortConst.POPULARITY:
        return locale.sortPopularity;
      case ProductSortConst.PRICE_LOW:
        return locale.sortPriceLowToHigh;
      case ProductSortConst.PRICE_HIGH:
        return locale.sortPriceHighToLow;
      case ProductSortConst.NEWEST:
        return locale.sortNewestFirst;
      case ProductSortConst.DISCOUNT:
        return locale.sortDiscount;
      case ProductSortConst.RATING:
        return locale.sortAverageRating;
      default:
        return code.capitalizeFirstLetter();
    }
  }

  List<ProductData> _getClientSideFilteredProducts(List<ProductData> products) {
    List<ProductData> filteredProducts = List.from(products);
    if (activeFilters[ProductFilterConst.PRICE]!) {
      filteredProducts = filteredProducts.where((product) {
        double minP = product.minPrice.validate().toDouble();
        double maxP = product.maxPrice.validate().toDouble();
        bool matches = (minP <= priceRange.end && maxP >= priceRange.start);
        return matches;
      }).toList();
    }

    if (activeFilters[ProductFilterConst.RATING]!) {
      filteredProducts = filteredProducts.where((product) {
        double rating = product.rating.validate().toDouble();
        return rating >= ratingRange.start && rating <= ratingRange.end;
      }).toList();
    }

    if (activeFilters[ProductFilterConst.DISCOUNT]!) {
      filteredProducts = filteredProducts.where((product) {
        double discount = product.discount.validate().toDouble();
        return discount >= discountRange.start && discount <= discountRange.end;
      }).toList();
    }

    return filteredProducts;
  }

  void _showSortFilterBottomSheet() {
    CommonBottomSheet.show(
      context,
      title: locale.sortAndFilters,
      maxHeight: MediaQuery.of(context).size.height * 0.7,
      child: StatefulBuilder(
        builder: (context, setModalState) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ===== FILTERS =====
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(locale.filterPrice, style: boldTextStyle(size: 14)),
                PriceWidget(price: priceRange.start.round().toDouble(), priceText: '${priceRange.start.round()} - ${priceRange.end.round()}', size: 12),
              ],
            ),
            RangeSlider(
              values: priceRange,
              min: minPrice,
              max: maxPrice,
              divisions: 5,
              labels: RangeLabels('\$${priceRange.start.round()}', '\$${priceRange.end.round()}'),
              onChanged: (values) => setModalState(() => priceRange = values),
              activeColor: primaryColor,
            ),
            4.height,

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(locale.filterRating, style: boldTextStyle(size: 14)),
                Text('${ratingRange.start} - ${ratingRange.end}', style: secondaryTextStyle(size: 12)),
              ],
            ),
            RangeSlider(
              values: ratingRange,
              min: 0,
              max: 5,
              divisions: 3,
              labels: RangeLabels('${ratingRange.start}', '${ratingRange.end}'),
              onChanged: (values) => setModalState(() => ratingRange = values),
              activeColor: primaryColor,
            ),
            4.height,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(locale.filterDiscount, style: boldTextStyle(size: 14)),
                Text('${discountRange.start.round()}% - ${discountRange.end.round()}%', style: secondaryTextStyle(size: 12)),
              ],
            ),
            RangeSlider(
              values: discountRange,
              min: 0,
              max: 100,
              divisions: 5,
              labels: RangeLabels('${discountRange.start.round()}%', '${discountRange.end.round()}%'),
              onChanged: (values) => setModalState(() => discountRange = values),
              activeColor: primaryColor,
            ),
            6.height,

            Divider(height: 1),
            12.height,

            //Filter By
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: sortOptions.map((option) {
                return GestureDetector(
                  onTap: () {
                    setModalState(() => selectedSort = option);
                    setState(() => selectedSort = option);
                    page = 1;
                    appStore.setLoading(true);
                    init(flag: true);
                  },
                  child: Container(
                    padding: EdgeInsets.only(top: 6, bottom: 6, left: 12, right: 12),
                    decoration: boxDecorationWithRoundedCorners(
                      backgroundColor: selectedSort == option ? primaryColor : context.cardColor,
                      border: selectedSort == option ? Border.all(color: primaryColor, width: 1) : Border.all(color: borderColor, width: 1),
                      borderRadius: radius(4),
                    ),
                    child: Text(
                      _sortLabel(option),
                      style: primaryTextStyle(
                        color: selectedSort == option ? Colors.white : textSecondaryColorGlobal,
                        weight: selectedSort == option ? FontWeight.w600 : FontWeight.normal,
                        size: 12,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            8.height,

            // apply / clear button
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setModalState(() {
                        activeFilters.updateAll((key, value) => false);
                        priceRange = RangeValues(0, 2000);
                        ratingRange = RangeValues(1, 5);
                        discountRange = RangeValues(0, 100);
                        selectedSort = 'Popularity';
                      });
                      setState(() {
                        activeFilters.updateAll((key, value) => false);
                        priceRange = RangeValues(0, 2000);
                        ratingRange = RangeValues(1, 5);
                        discountRange = RangeValues(0, 100);
                        selectedSort = 'Popularity';
                        _updateFilterCount();
                      });
                      Navigator.pop(context);
                      page = 1;
                      appStore.setLoading(true);
                      init(flag: true);
                    },
                    child: Text(
                      locale.clear,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        shadows: [Shadow(color: context.primaryColor, offset: Offset(0, -2))],
                        color: Colors.transparent,
                        decoration: TextDecoration.underline,
                        decorationColor: context.primaryColor,
                        decorationThickness: 1,
                        decorationStyle: TextDecorationStyle.solid,
                      ),
                    ),
                  ),
                ),
                6.width,
                Expanded(
                  child: AppButton(
                    height: 40,
                    text: locale.apply,
                    color: primaryColor,
                    textStyle: boldTextStyle(color: Colors.white, size: 14),
                    onTap: () {
                      setState(() {
                        activeFilters[ProductFilterConst.PRICE] = priceRange.start > 0 || priceRange.end < 2000;
                        activeFilters[ProductFilterConst.RATING] = ratingRange.start > 1 || ratingRange.end < 5;
                        activeFilters[ProductFilterConst.DISCOUNT] = discountRange.start > 0 || discountRange.end < 100;
                        _updateFilterCount();
                      });
                      Navigator.pop(context);
                      setState(() {});
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  void startListening() {
    startVoiceSearch(
      onResultCallback: (text, isFinal) {
        if (isFinal) {
          searchProductCont.text = text;
          page = 1;
          appStore.setLoading(true);
          init(flag: true);
        }
      },
      onStatusChanged: () {
        if (mounted) setState(() {});
      },
    );
  }

  void stopListening() {
    stopVoiceSearch();
  }

  @override
  void dispose() {
    searchProductCont.removeListener(() {});
    searchProductCont.dispose();
    myFocusNode.dispose();
    stopVoiceSearch();
    super.dispose();
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
              decoration: boxDecorationWithRoundedCorners(borderRadius: radiusOnly(bottomLeft: 20, bottomRight: 20), backgroundColor: context.primaryColor),
              child: appBarWidget(
                widget.appBarTitleText.validate(),
                textColor: white,
                backWidget: BackWidget(),
                center: true,
                color: context.primaryColor,
                textSize: APPBAR_TEXT_SIZE,
                actions: [
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
                      focus: myFocusNode,
                      controller: searchProductCont,
                      suffix: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () {
                              hideKeyboard(context);
                              searchProductCont.clear();
                              page = 1;
                              appStore.setLoading(true);
                              init(flag: true);
                            },
                            child: Icon(Icons.close, color: context.iconColor)
                          ).visible(searchProductCont.text.isNotEmpty),
                          6.width.visible(searchProductCont.text.isNotEmpty),
                          GestureDetector(
                            onTap: () {
                              startListening();
                            },
                            child: Icon(Icons.mic_none_outlined, color: context.iconColor)),
                          12.width.visible(searchProductCont.text.isNotEmpty),
                        ],
                      ),
                      onChanged: (s) {
                        page = 1;
                        appStore.setLoading(true);
                        init(flag: true);
                      },
                      decoration: inputDecoration(
                        context,
                        hint: locale.searchForProduct,
                        prefixIcon: Icon(Icons.search, color: context.iconColor),
                      ),
                    ),
                  ),
                  16.width,
                  GestureDetector(
                    onTap: _showSortFilterBottomSheet,
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: boxDecorationDefault(color: secondaryColor),
                      child: Stack(
                        children: [
                          CachedImageWidget(
                            url: ic_filter,
                            height: 26,
                            width: 26,
                            color: Colors.white,
                          ),
                          if (activeFilterCount > 0)
                            Positioned(
                              top: -2,
                              right: -2,
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(color: primaryColor, shape: BoxShape.circle),
                                child: Center(
                                  child: Text(activeFilterCount.toString(), style: boldTextStyle(color: Colors.white, size: 8)),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          // Voice search animation - centered overlay
          Observer(
            builder: (context) {
              return appStore.isSpeechActivated
                  ? Positioned.fill(
                      child: Center(
                        child: VoiceSearchComponent(),
                      ),
                    )
                  : SizedBox.shrink();
            },
          ),
          SnapHelperWidget<List<ProductData>>(
            future: future,
            errorBuilder: (error) {
              return NoDataWidget(
                title: error,
                retryText: locale.reload,
                imageWidget: ErrorStateWidget(),
                onRetry: () {
                  page = 1;
                  appStore.setLoading(true);
                  init(flag: true);
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
                    init(flag: true);
                  },
                );
              }

              return AnimatedScrollView(
                padding: EdgeInsets.only(left: 16, right: 16, top: 40, bottom: 30),
                onSwipeRefresh: () async {
                  page = 1;
                  init(flag: true);
                  return await 2.seconds.delay;
                },
                onNextPage: () {
                  if (!isLastPage) {
                    page++;
                    appStore.setLoading(true);
                    init(flag: true);
                  }
                },
                children: [
                  AnimatedWrap(
                    itemCount: _getClientSideFilteredProducts(productList).length,
                    spacing: 16,
                    runSpacing: 16,
                    itemBuilder: (context, index) {
                      final filteredProducts = _getClientSideFilteredProducts(productList);
                      return ProductItemComponent(productListData: filteredProducts[index], cartKey: _cartKey);
                    },
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
