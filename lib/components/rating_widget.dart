import 'package:flutter/material.dart';
import 'package:frezka/utils/colors.dart';
import 'package:nb_utils/nb_utils.dart';

class RatingWidget extends StatelessWidget {
  final double rating;
  final bool showRatingNumber;
  final double? ratingNumberSize;
  final int maxStars;
  final bool showOnlyOneStar;

  const RatingWidget({
    Key? key,
    required this.rating,
    this.showRatingNumber = true,
    this.ratingNumberSize,
    this.maxStars = 5,
    this.showOnlyOneStar = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget ratingDisplay = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Stars
        if (showOnlyOneStar)
          // Show only one star (filled if rating > 0, empty if rating = 0)
          Icon(
            Icons.star,
            size: 12,
            color: rating > 0 ? accentOrangeColor : Colors.grey,
          )
        else
          // Show multiple stars based on rating
          Row(
            children: List.generate(maxStars, (index) {
              return Icon(
                Icons.star,
                size: 12,
                color: index < rating.floor().validate() ? accentOrangeColor : Colors.grey.shade300,
              );
            }),
          ),
        if (showRatingNumber) ...[
          SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: boldTextStyle(
              size: (ratingNumberSize ?? 12).toInt(),
              color: textPrimaryColor,
            ),
          ),
        ],
      ],
    );

    // Add background container
    return Container(
      padding: EdgeInsets.only(left: 8, top: 3, bottom: 3, right: 12),
      decoration: BoxDecoration(
        color: amberLightBgColor,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: goldenYellowColor, width: 0.6),
      ),
      child: ratingDisplay,
    );
  }
}
