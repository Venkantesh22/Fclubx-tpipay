import 'package:flutter/material.dart';
import 'package:frezka/main.dart';
import 'package:frezka/screens/product/component/all_review_product_component.dart';
import 'package:frezka/utils/colors.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../components/cached_image_widget.dart';
import '../model/product_list_response.dart';
import '../model/product_review_data_model.dart';

class ProductRatingReviewComponent extends StatefulWidget {
  final List<ProductReviewDataModel> reviewDetails;
  final ProductData productReviewData;

  ProductRatingReviewComponent({required this.reviewDetails, required this.productReviewData});

  @override
  _ProductRatingReviewComponentState createState() => _ProductRatingReviewComponentState();
}

class _ProductRatingReviewComponentState extends State<ProductRatingReviewComponent> {
  Map<int, bool> expandedReviews = {};

  String _formatTimeOnly(String? dateTime) {
    if (dateTime == null || dateTime.isEmpty) return '';

    try {
      DateTime date = DateTime.parse(dateTime);

      // Calculate time ago
      Duration difference = DateTime.now().difference(date);

      if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h ago';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d ago';
      } else {
        String time = '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
        return '${date.day}/${date.month} $time';
      }
    } catch (e) {
      return dateTime;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                locale.allReview(widget.reviewDetails.length.toString()),
                style: boldTextStyle(size: 16),
              ),
              if(widget.reviewDetails.length > 3)
              Text(
                locale.viewAll,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  height: 22 / 12,
                  letterSpacing: -0.01,
                  decoration: TextDecoration.underline,
                  decorationColor: primaryColor,
                  color: primaryColor,
                ),
              ).onTap(() {
                AllReviewProductComponent(productId: widget.productReviewData.id).launch(context);
              }),
            ],
          ),
          8.height,

          // Reviews List
          if (widget.reviewDetails.isEmpty)
            Container(
              padding: EdgeInsets.all(20),
              decoration: boxDecorationDefault(
                color: context.cardColor,
                borderRadius: radius(8),
                border: Border.all(color: context.dividerColor, width: 0.5),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.rate_review_outlined,
                    size: 48,
                    color: context.iconColor,
                  ),
                  8.height,
                  Text(
                    locale.noReviewYet,
                    style: boldTextStyle(size: 16),
                  ),
                  4.height,
                  Text(
                    locale.beTheFirstToReviewThisProduct,
                    style: secondaryTextStyle(),
                  ),
                ],
              ),
            )
          else
            ...widget.reviewDetails.take(3).map((reviewData) {
              return Container(
                margin: EdgeInsets.only(bottom: 14),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.cardColor,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: borderColor, width: 0.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Rating and Timestamp Row
                    Padding(
                      padding: EdgeInsets.only(bottom: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Rating Badge
                          RatingBarWidget(
                            onRatingChanged: null,
                            rating: reviewData.rating.validate().toDouble(),
                            size: 14,
                            allowHalfRating: true,
                            disable: true,
                            activeColor: accentOrangeColor,
                            inActiveColor: accentOrangeColor,
                          ),
                          Text(
                            _formatTimeOnly(reviewData.createdAt.validate()),
                            style: secondaryTextStyle(size: 12),
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.end,
                          ),
                        ],
                      ),
                    ),

                    // Review Description
                    _buildExpandableText(reviewData.reviewMsg.validate(), widget.reviewDetails.indexOf(reviewData)),
                    20.height,

                    // Reviewer Information Row
                    Row(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: white, width: 3),
                          ),
                          child: reviewData.featureImage.validate().isNotEmpty
                              ? ClipOval(
                                  child: CachedImageWidget(
                                    url: reviewData.featureImage.validate(),
                                    width: 34,
                                    height: 34,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Container(
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: context.primaryColor.withValues(alpha: 0.1),
                                  ),
                                  child: Icon(Icons.person, color: context.primaryColor, size: 17),
                                ),
                        ),
                        14.width,
                        Expanded(
                          child: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  reviewData.userName.validate(),
                                  style: boldTextStyle(size: 14),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              8.width,
                              Container(
                                width: 14,
                                height: 14,
                                decoration: BoxDecoration(
                                  color: successDarkColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 1.5),
                                ),
                                child: Icon(Icons.check, size: 8, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
        ],
      ),
    );
  }

  Widget _buildExpandableText(String text, int reviewIndex) {
    bool isExpanded = expandedReviews[reviewIndex] ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          style: secondaryTextStyle(size: 12),
          maxLines: isExpanded ? null : 3,
          overflow: isExpanded ? null : TextOverflow.ellipsis,
        ),
        if (text.length > 100)
          GestureDetector(
            onTap: () {
              setState(() {
                expandedReviews[reviewIndex] = !isExpanded;
              });
            },
            child: Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text(
                isExpanded ? locale.readLess : locale.readMore,
                style: boldTextStyle(size: 12, color: context.primaryColor),
              ),
            ),
          ),
      ],
    );
  }
}
