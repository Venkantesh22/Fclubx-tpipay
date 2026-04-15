import 'package:flutter/material.dart';
import 'package:frezka/screens/order/component/product_review_dialog.dart';
import 'package:frezka/utils/colors.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../components/cached_image_widget.dart';
import '../../../main.dart';
import '../../../utils/constants.dart';
import '../../../utils/custom_toast_widget.dart';
import '../../product/model/product_review_data_model.dart';
import '../../zoom_image_screen.dart';
import '../order_repository.dart';
import '../view/order_detail_screen.dart';

class OrderReviewComponent extends StatefulWidget {
  final String? deliveryStatus;
  final int? productId;
  final int? productVariationId;
  final ProductReviewDataModel? productReview;

  OrderReviewComponent({this.deliveryStatus, this.productId, this.productVariationId, this.productReview});

  @override
  _OrderReviewComponentState createState() => _OrderReviewComponentState();
}

class _OrderReviewComponentState extends State<OrderReviewComponent> {
  bool isLoading = false;

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '';

    try {
      DateTime date = DateTime.parse(dateString);
      return '${date.day} ${_getMonthName(date.month)}, ${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  void _setLoading(bool loading) {
    if (mounted) {
      setState(() {
        isLoading = loading;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.deliveryStatus == OrderStatusConst.DELIVERED)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.productReview == null)
                Container(
                  decoration: boxDecorationDefault(
                    color: appStore.isDarkMode ? darkSecondaryColor : territoryButtonColor,
                    borderRadius: radius(6),
                    border: Border.all(color: appStore.isDarkMode ? context.dividerColor : indicatorColor, width: 1),
                  ),
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) => Icon(Icons.star_outline, color: goldenOrangeColor, size: 20)),
                      ),
                      8.height,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(locale.youHaveNotRatedYet, style: primaryTextStyle(size: 14)),
                          8.width,
                          InkWell(
                            onTap: () {
                              ProductReviewDialog.show(
                                context,
                                productReview: null,
                                productId: widget.productId.validate(),
                                productVariationId: widget.productVariationId.validate(),
                              );
                            },
                            child: Text(
                              locale.rateNow,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                shadows: [Shadow(color: context.primaryColor, offset: Offset(0, -2))],
                                color: Colors.transparent,
                                decoration: TextDecoration.underline,
                                decorationColor: context.primaryColor,
                                decorationThickness: 1,
                                decorationStyle: TextDecorationStyle.solid,
                              ),
                            ),
                          ),
                        ],
                      ),
                      8.height,
                    ],
                  ),
                ),
              if (widget.productReview == null) 12.height,
              if (widget.productReview != null)
                Container(
                  decoration: boxDecorationDefault(color: appStore.isDarkMode ? darkSecondaryColor : territoryButtonColor, borderRadius: radius(6), border: Border.all(color: appStore.isDarkMode ? context.dividerColor : indicatorColor, width: 2)),
                  padding: EdgeInsets.only(left: 16, right: 16, top: 2, bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(locale.yourReview, style: boldTextStyle(size: 14)),
                          Spacer(),
                          PopupMenuButton<String>(
                            color: context.cardColor,
                            icon: Icon(Icons.more_horiz, color: context.iconColor),
                            onSelected: (value) {
                              if (value == 'edit') {
                                _setLoading(true);
                                ProductReviewDialog.show(
                                  context,
                                  productReview: widget.productReview,
                                  productId: widget.productId.validate(),
                                  productVariationId: widget.productVariationId.validate(),
                                );
                                // Reset loading after a short delay
                                Future.delayed(Duration(milliseconds: 500), () {
                                  _setLoading(false);
                                });
                              } else if (value == 'delete') {
                                showConfirmDialogCustom(
                                  context,
                                  title: locale.deleteReview,
                                  subTitle: locale.doYouWantToDeleteReview,
                                  positiveText: locale.yes,
                                  negativeText: locale.no,
                                  dialogType: DialogType.DELETE,
                                  onAccept: (p0) async {
                                    _setLoading(true);
                                    await deleteOrderReview(id: widget.productReview!.id.validate()).then((value) {
                                      ShowToast.showSuccess(value.message!);
                                    }).catchError((e) {
                                      ShowToast.showError(e.toString());
                                    });
                                    onOrderDetailUpdate?.call();
                                    _setLoading(false);
                                  },
                                );
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(value: 'edit', child: Text(locale.edit)),
                              PopupMenuItem(value: 'delete', child: Text(locale.delete, style: TextStyle(color: Colors.red))),
                            ],
                          ),
                        ],
                      ),
                      // Star Rating
                      Row(
                        children: [
                          Row(
                            children: List.generate(5, (index) {
                              final rating = widget.productReview!.rating.validate().toInt();
                              if (index < rating) {
                                return Icon(Icons.star, color: goldenOrangeColor, size: 20);
                              } else {
                                return Icon(Icons.star_outline, color: goldenOrangeColor, size: 20);
                              }
                            }),
                          ),
                          Spacer(),
                          Text(
                            _formatDate(widget.productReview!.createdAt.validate()),
                            style: secondaryTextStyle(size: 12),
                          ),
                        ],
                      ),
                      8.height,
                      if (widget.productReview!.reviewMsg.validate().isNotEmpty)
                        ReadMoreText(
                          widget.productReview!.reviewMsg.validate(),
                          trimLines: 3,
                          style: secondaryTextStyle(size: 12),
                          colorClickableText: primaryColor,
                          trimMode: TrimMode.Line,
                          trimCollapsedText: " ...${locale.readMore}",
                          trimExpandedText: locale.readLess,
                          locale: Localizations.localeOf(context),
                        ),
                      8.height,
                      if (widget.productReview!.gallery.validate().isNotEmpty)
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: widget.productReview!.gallery.validate().take(4).map((galleryData) {
                            return Container(
                              width: 60,
                              height: 60,
                              decoration: boxDecorationDefault(
                                borderRadius: radius(4),
                                color: context.cardColor,
                              ),
                              child: ClipRRect(
                                borderRadius: radius(4),
                                child: CachedImageWidget(
                                  url: '${galleryData.fullUrl.validate()}',
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                ).onTap(() {
                                  if (galleryData.fullUrl.validate().isNotEmpty)
                                    ZoomImageScreen(
                                      galleryImages: widget.productReview!.gallery.validate().map((e) => e.fullUrl.validate()).toList(),
                                      index: widget.productReview!.gallery.validate().indexOf(galleryData),
                                    ).launch(context);
                                }),
                              ),
                            );
                          }).toList(),
                        ),
                    ],
                  ),
                ),
            ],
          ),
      ],
    );
  }
}
