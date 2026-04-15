import 'package:flutter/material.dart';
import 'package:frezka/components/shimmer_widget.dart';
import 'package:frezka/utils/colors.dart';
import 'package:nb_utils/nb_utils.dart';

class BranchServiceShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ViewAllLabel Section
        Container(
          margin: EdgeInsets.only(top: 16),
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ShimmerWidget(height: 16, width: context.width() * 0.3),
              ShimmerWidget(height: 16, width: context.width() * 0.15),
            ],
          ),
        ),
        16.height,
        // Service List
        AnimatedListView(
          padding: EdgeInsets.symmetric(horizontal: 16),
          itemCount: 5,
          listAnimationType: ListAnimationType.FadeIn,
          physics: AlwaysScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (ctx, index) {
            return Container(
              decoration: boxDecorationWithRoundedCorners(
                backgroundColor: context.cardColor,
                borderRadius: radius(4),
                border: Border.all(
                  color: borderColor,
                  width: 0.5,
                ),
              ),
              margin: EdgeInsets.only(bottom: 8),
              padding: EdgeInsets.only(right: 16, top: 16, bottom: 16),
              child: Row(
                children: [
                  // Checkbox
                  ShimmerWidget(
                    height: 20,
                    width: 20,
                    backgroundColor: context.cardColor,
                  ),
                  // Service Image
                  ShimmerWidget(
                    height: 44,
                    width: 44,
                    backgroundColor: context.cardColor,
                  ).cornerRadiusWithClipRRect(4),
                  12.width,
                  // Service Details
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerWidget(height: 14, width: context.width() * 0.4),
                      4.height,
                      ShimmerWidget(height: 12, width: context.width() * 0.2),
                    ],
                  ).expand(),
                  12.width,
                  // Price
                  ShimmerWidget(height: 16, width: context.width() * 0.15),
                ],
              ),
            );
          },
        ),

        // Book Now Button (conditional)
        16.height,
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: ShimmerWidget(
            child: Container(
              width: double.infinity,
              height: 48,
              decoration: boxDecorationWithRoundedCorners(
                backgroundColor: context.cardColor,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),

        // Bottom padding
        16.height,
      ],
    );
  }
}
