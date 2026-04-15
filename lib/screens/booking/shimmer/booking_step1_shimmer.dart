import 'package:flutter/material.dart';
import 'package:frezka/utils/colors.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../components/shimmer_widget.dart';

class BookingStep1Shimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AnimatedScrollView(
      padding: EdgeInsets.only(left: 20, right: 20, top: 60, bottom: 100),
      physics: AlwaysScrollableScrollPhysics(),
      children: [
        /// Date Selection Section
        // ViewAllLabel for Date
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ShimmerWidget(height: 16, width: context.width() * 0.2),
            SizedBox(width: 0), // No trailing widget
          ],
        ),
        
        // Horizontal Date Picker Shimmer
        Container(
          height: 90,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 7,
            itemBuilder: (context, index) {
              return Container(
                width: 60,
                margin: EdgeInsets.only(right: 8),
                child: Column(
                  children: [
                    // Week day
                    ShimmerWidget(height: 12, width: 40),
                    4.height,
                    // Day number
                    ShimmerWidget(
                      height: 32,
                      width: 32,
                      backgroundColor: context.cardColor,
                    ).cornerRadiusWithClipRRect(16),
                    4.height,
                    // Month
                    ShimmerWidget(height: 10, width: 30),
                  ],
                ),
              );
            },
          ),
        ),
        
        10.height,
        
        /// Time Selection Section
        // ViewAllLabel for Available Slots
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ShimmerWidget(height: 16, width: context.width() * 0.3),
            SizedBox(width: 0), // No trailing widget
          ],
        ),
        8.height,
        
        // Time Slots Grid
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 2.5,
          ),
          itemCount: 12,
          itemBuilder: (context, index) {
            return ShimmerWidget(
              child: Container(
                decoration: boxDecorationWithRoundedCorners(
                  backgroundColor: context.cardColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: borderColor, width: 0.5),
                ),
                child: Center(
                  child: ShimmerWidget(height: 12, width: 40),
                ),
              ),
            );
          },
        ),
        
        16.height,
        
        /// Expert Selection Section
        // ViewAllLabel for Choose Your Expert
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ShimmerWidget(height: 16, width: context.width() * 0.4),
            SizedBox(width: 0), // No trailing widget
          ],
        ),
        
        // Expert List
        AnimatedListView(
          itemCount: 4,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          listAnimationType: ListAnimationType.FadeIn,
          itemBuilder: (context, index) {
            return Container(
              width: context.width() - 40,
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
                  
                  // Radio Button
                  12.width,
                  ShimmerWidget(
                    height: 20,
                    width: 20,
                    backgroundColor: context.cardColor,
                  ).cornerRadiusWithClipRRect(10),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
