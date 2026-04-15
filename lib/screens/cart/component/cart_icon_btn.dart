import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frezka/main.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../../utils/colors.dart';
import '../../../../utils/common_base.dart';
import '../view/cart_screen.dart';

class CartIconBtnComponent extends StatelessWidget {
  final bool showBGCardColor;
  final Color? cartIconColor;
  final GlobalKey? cartKey;
  final double? size;

  const CartIconBtnComponent({super.key, this.showBGCardColor = false, this.cartIconColor, this.cartKey, this.size});

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (context) {
      return Container(
        height: showBGCardColor ? 40 : null,
        decoration: showBGCardColor ? boxDecorationWithShadow(boxShape: BoxShape.circle, backgroundColor: context.cardColor) : null,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              key: cartKey,
              icon: Icon(Icons.shopping_cart_outlined, color: cartIconColor ?? Colors.white, size: size ?? 25),
              onPressed: () {
                doIfLoggedIn(context, () {
                  CartScreen().launch(context);
                });
              },
            ),
            Positioned(
              top: showBGCardColor ? -10 : -4,
              right: showBGCardColor ? 2 : 4,
              child: Observer(builder: (context) {
                return Container(
                  padding: EdgeInsets.all(productStore.cartItemCount < 10 ? 5 : 4),
                  decoration: boxDecorationDefault(color: secondaryColor, shape: BoxShape.circle),
                  child: FittedBox(
                    child: Text(
                      '${productStore.cartItemCount}',
                      style: primaryTextStyle(size: 12, color: white),
                    ),
                  ),
                ).visible(productStore.cartItemCount > 0);
              }),
            ),
          ],
        ),
      ).paddingRight(productStore.cartItemCount > 0 ? 5 : 0);
    });
  }
}
