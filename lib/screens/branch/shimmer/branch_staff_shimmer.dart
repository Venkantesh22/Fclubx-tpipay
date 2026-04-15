import 'package:flutter/material.dart';
import 'package:frezka/utils/colors.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../components/shimmer_widget.dart';

class BranchStaffShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 16),
      child: AnimatedWrap(
        runSpacing: 0,
        spacing: 5,
        columnCount: 2,
        itemCount: 6,
        listAnimationType: ListAnimationType.FadeIn,
        itemBuilder: (_, i) {
          return Container(
            width: context.width() - 32,
            margin: EdgeInsets.symmetric(vertical: 5),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: boxDecorationWithRoundedCorners(
              backgroundColor: context.cardColor,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: borderColor, width: 0.5),
            ),
            child: Row(
              children: [
                // Profile Image
                ShimmerWidget(
                  height: 50,
                  width: 50,
                  backgroundColor: context.cardColor,
                ).cornerRadiusWithClipRRect(25),
                16.width,

                // Employee Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ShimmerWidget(height: 16, width: context.width() * 0.3),
                      4.height,
                      ShimmerWidget(height: 14, width: context.width() * 0.2),
                    ],
                  ),
                ),

                12.width,

                // Rating
                Container(
                  height: 25,
                  width: 60,
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: context.cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: borderColor, width: 0.5),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ShimmerWidget(height: 16, width: 16, backgroundColor: context.cardColor),
                      4.width,
                      ShimmerWidget(height: 14, width: 20, backgroundColor: context.cardColor),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
