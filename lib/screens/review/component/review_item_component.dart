import 'package:flutter/material.dart';
import 'package:frezka/components/rating_widget.dart';
import 'package:frezka/main.dart';
import 'package:frezka/utils/colors.dart';
import 'package:frezka/utils/common_base.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../components/cached_image_widget.dart';
import '../../../models/review_data.dart';
import '../../../utils/constants.dart';

class ReviewItemComponent extends StatefulWidget {
  final ReviewData reviewData;

  ReviewItemComponent({required this.reviewData});

  @override
  _ReviewItemComponentState createState() => _ReviewItemComponentState();
}

class _ReviewItemComponentState extends State<ReviewItemComponent> {
  bool isExpanded = false;
  static const int maxLines = 3;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    //
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.only(bottom: 16),
      width: context.width(),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: borderColor, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Rating
              RatingWidget(
                rating: widget.reviewData.rating.validate().toDouble(),
                showRatingNumber: true,
                ratingNumberSize: 12,
              ),

              // Timestamp
              if (widget.reviewData.createdAt.validate().isNotEmpty)
                Text(
                  formatDate(widget.reviewData.createdAt.validate(), format: DateFormatConst.DATE_FORMAT_4).toString(),
                  style: secondaryTextStyle(size: 12),
                ),
            ],
          ),

          16.height,

          // Review Text
          if (widget.reviewData.reviewMsg.validate().isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.reviewData.reviewMsg.validate(),
                  style: secondaryTextStyle(
                    size: 12,
                  ),
                  maxLines: isExpanded ? null : maxLines,
                  overflow: isExpanded ? null : TextOverflow.ellipsis,
                ),

                // View More/Less Button
                if (widget.reviewData.reviewMsg.validate().length > 100)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isExpanded = !isExpanded;
                      });
                    },
                    child: Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        isExpanded ? locale.readLess : locale.readMore,
                        style: secondaryTextStyle(
                          color: context.primaryColor,
                          size: 12,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

          16.height,

          // User Profile Section
          Row(
            children: [
              // Profile Picture
              CircleAvatar(
                radius: 20,
                backgroundColor: context.scaffoldBackgroundColor,
                child: widget.reviewData.profileImage.validate().isNotEmpty
                    ? ClipOval(
                        child: CachedImageWidget(
                          url: widget.reviewData.profileImage.validate(),
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Icon(
                        Icons.person,
                        color: context.primaryColor,
                        size: 20,
                      ),
              ),

              12.width,

              // User Name and Verification
              Expanded(
                child: Row(
                  children: [
                    Text(
                      widget.reviewData.username.validate(),
                      style: boldTextStyle(size: 14),
                    ),
                    8.width,
                    // Verification Badge
                    Container(
                      width: 16,
                      height: 16,
                      decoration: boxDecorationWithRoundedCorners(
                        backgroundColor: Colors.green,
                        borderRadius: radius(16),
                      ),
                      child: Icon(
                        Icons.check,
                        color: context.scaffoldBackgroundColor,
                        size: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
