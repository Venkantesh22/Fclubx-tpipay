import 'package:flutter/material.dart';
import 'package:frezka/components/shimmer_widget.dart';
import 'package:frezka/utils/colors.dart';
import 'package:nb_utils/nb_utils.dart';

class EmployeeDetailShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.scaffoldBackgroundColor,
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header Card
            Container(
              width: double.infinity,
              margin: EdgeInsets.fromLTRB(10, 10, 10, 8),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Profile Image and Info Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile Image
                      ShimmerWidget(
                        height: 70,
                        width: 70,
                        backgroundColor: context.cardColor,
                      ).cornerRadiusWithClipRRect(35),
                      16.width,

                      // Name and Tags
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Tags
                            Row(
                              children: [
                                ShimmerWidget(
                                  height: 20,
                                  width: 60,
                                  backgroundColor: context.cardColor,
                                ),
                                8.width,
                                ShimmerWidget(
                                  height: 20,
                                  width: 80,
                                  backgroundColor: context.cardColor,
                                ),
                              ],
                            ),
                            8.height,
                            // Name
                            ShimmerWidget(height: 18, width: context.width() * 0.3),
                          ],
                        ),
                      ),

                      // Rating
                      ShimmerWidget(
                        height: 24,
                        width: 50,
                        backgroundColor: context.cardColor,
                      ),
                    ],
                  ),
                  16.height,

                  // Description
                  ShimmerWidget(height: 14, width: context.width()),
                  6.height,
                  ShimmerWidget(height: 14, width: context.width() * 0.8),
                  6.height,
                  ShimmerWidget(height: 14, width: context.width() * 0.6),
                ],
              ),
            ),

            10.height,

            // Contact Information
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(left: 20, right: 20, top: 5, bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerWidget(height: 14, width: context.width() * 0.3),
                  12.height,

                  // Email
                  ShimmerWidget(height: 12, width: context.width() * 0.4),
                  12.height,

                  // Phone
                  ShimmerWidget(height: 12, width: context.width() * 0.5),
                  12.height,

                  // Date of Birth
                  ShimmerWidget(height: 12, width: context.width() * 0.3),
                ],
              ),
            ),

            10.height,

            // Social Media
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(left: 20, right: 20, top: 5, bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerWidget(height: 14, width: context.width() * 0.25),
                  12.height,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    spacing: 16,
                    children: [
                      ShimmerWidget(height: 32, width: 32).cornerRadiusWithClipRRect(16),
                      ShimmerWidget(height: 32, width: 32).cornerRadiusWithClipRRect(16),
                      ShimmerWidget(height: 32, width: 32).cornerRadiusWithClipRRect(16),
                      ShimmerWidget(height: 32, width: 32).cornerRadiusWithClipRRect(16),
                    ],
                  ),
                ],
              ),
            ),

            10.height,

            // Rating Section
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(left: 20, right: 20, top: 5, bottom: 12),
              decoration: BoxDecoration(
                color: context.scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ShimmerWidget(height: 14, width: context.width() * 0.15),
                      ShimmerWidget(height: 12, width: context.width() * 0.2),
                    ],
                  ),
                  SizedBox(height: 16),

                  // Horizontal scrollable review cards
                  SizedBox(
                    height: 110,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: 3,
                      separatorBuilder: (_, __) => SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        return Container(
                          width: 280,
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: context.cardColor,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: borderColor, width: 1.5),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  ShimmerWidget(height: 18, width: 70),
                                  ShimmerWidget(height: 10, width: 35),
                                ],
                              ),
                              SizedBox(height: 4),
                              ShimmerWidget(height: 8, width: 200),
                              1.height,
                              ShimmerWidget(height: 8, width: 160),
                              1.height,
                              ShimmerWidget(height: 8, width: 120),
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  ShimmerWidget(height: 18, width: 18).cornerRadiusWithClipRRect(9),
                                  SizedBox(width: 4),
                                  ShimmerWidget(height: 10, width: 60),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 12),

                  // Pagination Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
                      return Container(
                        margin: EdgeInsets.symmetric(horizontal: 4),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),

            32.height,
          ],
        ),
      ),
    );
  }
}
