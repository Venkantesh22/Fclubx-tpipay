import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:frezka/main.dart';
import 'package:frezka/screens/product/component/product_item_component.dart';
import 'package:frezka/screens/product/model/product_list_response.dart';
import 'package:frezka/screens/product/view/product_list_screen.dart';
import 'package:frezka/utils/colors.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../components/view_all_label_component.dart';

class DiscountProductComponent extends StatelessWidget {
  final List<ProductData> discountProductList;
  final GlobalKey? cartKey;

  DiscountProductComponent({required this.discountProductList, this.cartKey});

  @override
  Widget build(BuildContext context) {
    if (discountProductList.isEmpty) return Offstage();

    return Container(
      color: appStore.isDarkMode ? territoryButtonDarkColor : territoryButtonColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ViewAllLabel(
            label: locale.dealsForYou,
            list: discountProductList,
            onTap: () {
              SchedulerBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) {
                  ProductListScreen(appBarTitleText: locale.dealsForYou, isBestDiscounts: '1').launch(context);
                }
              });
            },
          ).paddingOnly(left: 16, right: 8),
          HorizontalList(
            itemCount: discountProductList.length,
            padding: EdgeInsets.only(left: 16, right: 16, top: 0, bottom: 30),
            crossAxisAlignment: WrapCrossAlignment.start,
            itemBuilder: (context, i) {
              return ProductItemComponent(productListData: discountProductList[i], cartKey: cartKey).paddingRight(8);
            },
          )
        ],
      ),
    );
  }
}
