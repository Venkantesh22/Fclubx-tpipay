import 'package:flutter/material.dart';
import 'package:frezka/utils/colors.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../components/shimmer_widget.dart';

class BranchDetailShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          /// Image Slider Section
          ShimmerWidget(
            child: Container(
              height: 300,
              width: context.width(),
              decoration: BoxDecoration(
                color: context.cardColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
            ),
          ),

          /// Tab Navigation Section
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              children: [
                // Tab Navigation Row
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // About Tab
                      ShimmerWidget(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          decoration: boxDecorationWithRoundedCorners(
                            backgroundColor: context.cardColor,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: borderColor, width: 1),
                          ),
                          child: ShimmerWidget(height: 14, width: 40),
                        ),
                      ),
                      12.width,
                      // Services Tab
                      ShimmerWidget(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          decoration: boxDecorationWithRoundedCorners(
                            backgroundColor: context.cardColor,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: borderColor, width: 1),
                          ),
                          child: ShimmerWidget(height: 14, width: 60),
                        ),
                      ),
                      12.width,
                      // Reviews Tab
                      ShimmerWidget(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          decoration: boxDecorationWithRoundedCorners(
                            backgroundColor: context.cardColor,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: borderColor, width: 1),
                          ),
                          child: ShimmerWidget(height: 14, width: 50),
                        ),
                      ),
                      12.width,
                      // Staff Tab
                      ShimmerWidget(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          decoration: boxDecorationWithRoundedCorners(
                            backgroundColor: context.cardColor,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: borderColor, width: 1),
                          ),
                          child: ShimmerWidget(height: 14, width: 40),
                        ),
                      ),
                      12.width,
                      // Gallery Tab
                      ShimmerWidget(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          decoration: boxDecorationWithRoundedCorners(
                            backgroundColor: context.cardColor,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: borderColor, width: 1),
                          ),
                          child: ShimmerWidget(height: 14, width: 50),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          /// Content Section (About Tab by default)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Branch Description Section
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerWidget(height: 18, width: context.width() * 0.3),
                    12.height,
                    ShimmerWidget(height: 14, width: context.width()),
                    8.height,
                    ShimmerWidget(height: 14, width: context.width() * 0.8),
                    8.height,
                    ShimmerWidget(height: 14, width: context.width() * 0.6),
                  ],
                ),
                24.height,

                // Working Hours Section
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerWidget(height: 18, width: context.width() * 0.4),
                    12.height,
                    Wrap(
                      runSpacing: 8,
                      children: List.generate(7, (index) {
                        return Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: boxDecorationWithRoundedCorners(
                            backgroundColor: context.cardColor,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: borderColor, width: 0.5),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ShimmerWidget(height: 12, width: context.width() * 0.25),
                              ShimmerWidget(height: 12, width: context.width() * 0.15),
                            ],
                          ),
                        );
                      }),
                    ),
                  ],
                ),
                24.height,

                // Contact Information Section
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerWidget(height: 18, width: context.width() * 0.35),
                    12.height,
                    Row(
                      children: [
                        ShimmerWidget(height: 16, width: 16),
                        8.width,
                        ShimmerWidget(height: 14, width: context.width() * 0.4),
                      ],
                    ),
                    8.height,
                    Row(
                      children: [
                        ShimmerWidget(height: 16, width: 16),
                        8.width,
                        ShimmerWidget(height: 14, width: context.width() * 0.5),
                      ],
                    ),
                    8.height,
                    Row(
                      children: [
                        ShimmerWidget(height: 16, width: 16),
                        8.width,
                        ShimmerWidget(height: 14, width: context.width() * 0.3),
                      ],
                    ),
                  ],
                ),
                24.height,

                // Rating Section
                Row(
                  children: [
                    ShimmerWidget(height: 20, width: 20),
                    8.width,
                    ShimmerWidget(height: 16, width: context.width() * 0.2),
                    16.width,
                    ShimmerWidget(height: 16, width: context.width() * 0.3),
                  ],
                ),
                16.height,
              ],
            ),
          ),

          // Bottom padding
          SizedBox(height: 80),
        ],
      ),
    );
  }
}
