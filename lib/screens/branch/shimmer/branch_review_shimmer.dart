import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../components/shimmer_widget.dart';
import '../../../utils/colors.dart';

class BranchReviewShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(left: 16, right: 16, top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ViewAllLabel Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  ShimmerWidget(height: 16, width: context.width() * 0.2),
                  4.width,
                  ShimmerWidget(height: 14, width: context.width() * 0.3),
                ],
              ),
              ShimmerWidget(height: 16, width: context.width() * 0.15),
            ],
          ),
          16.height,

          // Review Items
          AnimatedListView(
            itemCount: 5,
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: NeverScrollableScrollPhysics(),
            listAnimationType: ListAnimationType.FadeIn,
            itemBuilder: (context, index) {
              return Container(
                margin: EdgeInsets.only(bottom: 12),
                padding: EdgeInsets.all(16),
                decoration: boxDecorationWithRoundedCorners(
                  backgroundColor: context.cardColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: borderColor, width: 0.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User Info and Rating
                    Row(
                      children: [
                        // User Avatar
                        ShimmerWidget(
                          height: 40,
                          width: 40,
                          backgroundColor: context.cardColor,
                        ).cornerRadiusWithClipRRect(20),
                        12.width,

                        // User Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ShimmerWidget(height: 16, width: context.width() * 0.3),
                              4.height,
                              ShimmerWidget(height: 12, width: context.width() * 0.2),
                            ],
                          ),
                        ),

                        // Rating Stars
                        Row(
                          children: List.generate(5, (starIndex) {
                            return Padding(
                              padding: EdgeInsets.only(right: 2),
                              child: ShimmerWidget(
                                height: 16,
                                width: 16,
                                backgroundColor: context.cardColor,
                              ),
                            );
                          }),
                        ),
                      ],
                    ),

                    12.height,

                    // Review Content
                    ShimmerWidget(height: 14, width: context.width()),
                    6.height,
                    ShimmerWidget(height: 14, width: context.width() * 0.8),
                    6.height,
                    ShimmerWidget(height: 14, width: context.width() * 0.6),

                    12.height,

                    // Review Date
                    ShimmerWidget(height: 12, width: context.width() * 0.25),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
