import 'package:flutter/material.dart';
import 'package:frezka/components/cached_image_widget.dart';
import 'package:frezka/components/rating_widget.dart';
import 'package:frezka/main.dart';
import 'package:frezka/utils/colors.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../components/default_user_image_placeholder.dart';
import '../../experts/model/employee_detail_response.dart';

class EmployeeListComponent extends StatelessWidget {
  final EmployeeData expertData;
  final double? width;
  final Decoration? decoration;
  final bool isSelected;
  final bool showRadioButton;
  final bool hideRating;
  final Function()? onTap;

  EmployeeListComponent({
    required this.expertData,
    this.width,
    this.decoration,
    this.isSelected = false,
    this.showRadioButton = false,
    this.hideRating = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width ?? context.width() - 32,
        margin: EdgeInsets.symmetric(vertical: 5),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
            color: context.cardColor,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: borderColor, width: 0.5)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Image
            CachedImageWidget(
              url: expertData.profileImage.validate(),
              height: 50,
              width: 50,
              circle: true,
              fit: BoxFit.cover,
              child: DefaultUserImagePlaceholder(),
            ),
            16.width,
            // Expert Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          expertData.fullName.validate(),
                          style: boldTextStyle(size: 16),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if(showRadioButton)...[
                        8.width,
                        // Rating (for non-booking views)
                        RatingWidget(
                          rating: expertData.ratingStar.validate().toDouble(),
                          showRatingNumber: true,
                          ratingNumberSize: 10,
                          maxStars: 1,
                          showOnlyOneStar: true,
                        ),
                      ]
                    ],
                  ),
                  4.height,
                  if (expertData.expert.validate().isNotEmpty)
                    Text(
                      expertData.expert.validate(),
                      style: secondaryTextStyle(
                          size: 14,
                          color: appStore.isDarkMode
                              ? slotAvailableBgColor
                              : textSecondaryColorGlobal),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            if (showRadioButton) ...[
              12.width,
              // Radio Button - Proper Radio Button Style
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color:
                        isSelected ? context.primaryColor : context.iconColor,
                    width: 2,
                  ),
                  color: Colors.transparent,
                ),
                child: isSelected
                    ? Center(
                        child: Container(
                          width: 9,
                          height: 9,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: context.primaryColor,
                          ),
                        ),
                      )
                    : null,
              ),
            ] else ...[
              12.width,
              // Rating (for non-booking views)
              RatingWidget(
                rating: expertData.ratingStar.validate().toDouble(),
                showRatingNumber: true,
                ratingNumberSize: 10,
                maxStars: 1,
                showOnlyOneStar: true,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
