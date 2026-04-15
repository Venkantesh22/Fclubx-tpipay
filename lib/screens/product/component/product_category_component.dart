import 'package:flutter/material.dart';
import 'package:frezka/screens/product/component/product_item_component.dart';
import 'package:frezka/utils/colors.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../components/empty_error_state_widget.dart';
import '../../../components/view_all_label_component.dart';
import '../../../main.dart';
import '../../category/model/category_response.dart';
import '../model/product_list_response.dart';
import '../view/product_category_screen.dart';

class ProductCategoryComponent extends StatefulWidget {
  final List<CategoryData> productCategoryList;
  final List<ProductData>? allProducts;
  final GlobalKey? cartKey;

  ProductCategoryComponent({required this.productCategoryList, this.allProducts, this.cartKey});

  @override
  State<ProductCategoryComponent> createState() => _ProductCategoryComponentState();
}

class _ProductCategoryComponentState extends State<ProductCategoryComponent> {
  String? selectedCategoryId;
  List<ProductData> filteredProducts = [];

  void filterProductsByCategory(String? categoryId) {
    if (categoryId == null) {
      filteredProducts = widget.allProducts ?? [];
    } else {
      filteredProducts = (widget.allProducts ?? []).where((product) => product.category.validate().any((cat) => cat.id.toString() == categoryId)).toList();
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    filteredProducts = widget.allProducts ?? [];
  }

  @override
  Widget build(BuildContext context) {
    if (widget.productCategoryList.isEmpty)
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 32),
        child: NoDataWidget(title: locale.noCategoryFound, imageWidget: EmptyStateWidget()),
      );

    return Column(
      children: [
        ViewAllLabel(
          label: locale.category,
          list: widget.productCategoryList,
          onTap: () {
            ProductCategoryScreen().launch(context).then((value) {
              setStatusBarColor(Colors.transparent);
            });
          },
        ).paddingOnly(left: 16, right: 8),
        8.height,
        Container(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: widget.productCategoryList.length + 1,
            itemBuilder: (context, index) {
              bool isAllCategory = index == 0;

              String categoryName = isAllCategory ? "All" : widget.productCategoryList[index - 1].name.validate();
              CategoryData? categoryData = isAllCategory ? null : widget.productCategoryList[index - 1];
              String? categoryId = isAllCategory ? null : categoryData?.id.toString();

              bool isSelected = isAllCategory ? selectedCategoryId == null : selectedCategoryId == categoryId;

              return Container(
                margin: EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () {
                    if (isAllCategory) {
                      selectedCategoryId = null;
                      filterProductsByCategory(null);
                    } else {
                      selectedCategoryId = categoryId;
                      filterProductsByCategory(categoryId);
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.only(left: 20, right: 20, top: 7, bottom: 7),
                    decoration: boxDecorationWithRoundedCorners(
                      backgroundColor: isSelected ? (appStore.isDarkMode ? darkSecondaryColor : primaryLightColor) : (appStore.isDarkMode ? scaffoldSecondaryDark : context.cardColor),
                      borderRadius: radius(4),
                      border: Border.all(
                        color: isSelected ? context.primaryColor : (appStore.isDarkMode ? charcoalColor : borderColor),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      categoryName,
                      style: primaryTextStyle(
                        color: isSelected ? context.primaryColor : (appStore.isDarkMode ? Colors.white : charcoalColor),
                        weight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        size: 12,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        12.height,
        if (filteredProducts.isNotEmpty) ...[
          HorizontalList(
            itemCount: filteredProducts.length,
            padding: EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 16),
            crossAxisAlignment: WrapCrossAlignment.start,
            itemBuilder: (_, i) {
              return ProductItemComponent(productListData: filteredProducts[i], cartKey: widget.cartKey).paddingRight(8);
            },
          ),
        ] else if (selectedCategoryId != null) ...[
          10.height,
          Divider(color: context.dividerColor),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 32),
            child: NoDataWidget(
              title: locale.noProductsFound,
              imageWidget: EmptyStateWidget(),
            ),
          ),
        ],
      ],
    );
  }
}
