import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frezka/main.dart';
import 'package:frezka/utils/colors.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../utils/constants.dart';

class ProductQuantityComponent extends StatefulWidget {
  @override
  _ProductQuantityComponentState createState() => _ProductQuantityComponentState();
}

class _ProductQuantityComponentState extends State<ProductQuantityComponent> {
  @override
  void initState() {
    super.initState();
    init();
  }

  void init({bool flag = false}) async {
    //
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    productStore.setProductQuantity(DEFAULT_QUANTITY);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                locale.quantity + ":",
                style: boldTextStyle(size: 14),
              ),
              12.width,
              Observer(builder: (context) {
                return Container(
                  width: 112,
                  height: 41,
                  decoration: BoxDecoration(
                    color:context.cardColor,
                    borderRadius: BorderRadius.circular(3),
                    border: Border.all(color: borderColor, width: 0.5),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 11),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          if (productStore.qty > 1) {
                            productStore.qty--;
                          }
                          setState(() {});
                        },
                        child: Icon(Icons.remove, size: 16, color: appTextSecondaryColor),
                      ),
                      Text(
                        productStore.qty.toString(),
                        style: boldTextStyle(size: 16),
                      ),
                      GestureDetector(
                        onTap: () async {
                          if (productStore.qty < productStore.selectedVariationData.productStockQty.validate()) {
                            productStore.qty++;
                          }
                          setState(() {});
                        },
                        child: Icon(Icons.add, size: 16, color: appTextSecondaryColor),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }
}
