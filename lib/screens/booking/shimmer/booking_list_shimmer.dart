import 'package:flutter/material.dart';
import 'package:frezka/components/shimmer_widget.dart';
import 'package:frezka/utils/colors.dart';
import 'package:nb_utils/nb_utils.dart';

class BookingListShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AnimatedListView(
      physics: AlwaysScrollableScrollPhysics(),
      itemCount: 8,
      padding: EdgeInsets.only(left: 8, right: 8, bottom: 12),
      listAnimationType: ListAnimationType.FadeIn,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return Container(
          width: context.width(),
          margin: EdgeInsets.all(8),
          decoration: boxDecorationWithRoundedCorners(
            backgroundColor: context.cardColor,
            border: Border.all(color: borderColor, width: 0.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Booking Header (ID, Date, Price)
              Container(
                padding: EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            ShimmerWidget(height: 12, width: 20),
                            56.width,
                            ShimmerWidget(height: 12, width: 60),
                          ],
                        ),
                        4.height,
                        Row(
                          children: [
                            ShimmerWidget(height: 12, width: 40),
                            ShimmerWidget(height: 12, width: 80),
                          ],
                        ),
                      ],
                    ),
                    // Price
                    ShimmerWidget(height: 14, width: 50),
                  ],
                ),
              ),

              Divider(color: context.dividerColor, height: 0).paddingSymmetric(horizontal: 16),
              12.height,

              // Service Section
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    // Service Image
                    ShimmerWidget(height: 60, width: 60).cornerRadiusWithClipRRect(8),
                    12.width,

                    // Service Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Service Tag
                          ShimmerWidget(
                            height: 20,
                            width: 80,
                            backgroundColor: context.cardColor,
                          ).cornerRadiusWithClipRRect(12),
                          9.height,

                          // Service Name
                          ShimmerWidget(height: 14, width: context.width() * 0.6),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              2.height,

              // Booking Info Section
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Booking Info Header
                    ShimmerWidget(height: 12, width: context.width() * 0.2),
                    8.height,

                    // Booking Info Card
                    Container(
                      decoration: boxDecorationDefault(
                        color: context.cardColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[200]!, width: 1),
                      ),
                      padding: EdgeInsets.all(12),
                      child: Column(
                        children: [
                          // Specialist
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  ShimmerWidget(height: 16, width: 16),
                                  4.width,
                                  ShimmerWidget(height: 12, width: 60),
                                ],
                              ),
                              ShimmerWidget(height: 12, width: 80),
                            ],
                          ),
                          12.height,

                          // Booking Status
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  ShimmerWidget(height: 16, width: 16),
                                  4.width,
                                  ShimmerWidget(height: 12, width: 70),
                                ],
                              ),
                              ShimmerWidget(height: 12, width: 60),
                            ],
                          ),
                          12.height,

                          // Payment Status
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  ShimmerWidget(height: 16, width: 16),
                                  4.width,
                                  ShimmerWidget(height: 12, width: 80),
                                ],
                              ),
                              ShimmerWidget(height: 12, width: 50),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              5.height,

              // Booking Actions
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    // Booking Details Link
                    Align(
                      alignment: Alignment.topLeft,
                      child: ShimmerWidget(height: 12, width: 100),
                    ),
                    8.height,

                    // Cancel Button (conditional)
                    ShimmerWidget(
                      child: Container(
                        height: 40,
                        width: context.width(),
                        decoration: boxDecorationWithRoundedCorners(
                          backgroundColor: context.cardColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    8.height,
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
