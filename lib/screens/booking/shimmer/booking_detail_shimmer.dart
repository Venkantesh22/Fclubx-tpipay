import 'package:flutter/material.dart';
import 'package:frezka/utils/colors.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../components/shimmer_widget.dart';

class BookingDetailShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AnimatedScrollView(
      padding: EdgeInsets.all(16),
      physics: AlwaysScrollableScrollPhysics(),
      children: [
        /// Booking Information Section
        // ViewAllLabel
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ShimmerWidget(height: 16, width: context.width() * 0.4),
            ShimmerWidget(height: 14, width: context.width() * 0.15),
          ],
        ),
        16.height,

        // Booking Information Card
        Container(
          decoration: boxDecorationDefault(
            color: context.cardColor,
            border: Border.all(color: Colors.grey.shade300, width: 1),
          ),
          child: Column(
            children: [
              // Salon Header
              Container(
                decoration: boxDecorationDefault(
                  color: context.cardColor,
                  borderRadius: radiusOnly(topLeft: 6, topRight: 6),
                ),
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Branch Image
                    ShimmerWidget(height: 55, width: 55).cornerRadiusWithClipRRect(6),
                    12.width,
                    // Branch Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShimmerWidget(height: 14, width: context.width() * 0.4),
                          4.height,
                          ShimmerWidget(height: 12, width: context.width() * 0.6),
                        ],
                      ),
                    ),
                    // Action Buttons
                    Row(
                      children: [
                        ShimmerWidget(height: 36, width: 36).cornerRadiusWithClipRRect(18),
                        8.width,
                        ShimmerWidget(height: 36, width: 36).cornerRadiusWithClipRRect(18),
                      ],
                    ),
                  ],
                ),
              ),

              // About Booking Title + Status
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    ShimmerWidget(height: 14, width: context.width() * 0.3),
                    Spacer(),
                    ShimmerWidget(
                      height: 24,
                      width: 80,
                      backgroundColor: context.cardColor,
                    ).cornerRadiusWithClipRRect(20),
                  ],
                ),
              ),

              // Info Tiles
              _buildInfoTileShimmer(context, Icons.calendar_month_outlined),
              _buildInfoTileShimmer(context, Icons.payment_outlined),
              _buildInfoTileShimmer(context, null, hasImage: true),
            ],
          ),
        ),

        16.height,

        /// Service Information Section
        ShimmerWidget(height: 16, width: context.width() * 0.3),
        16.height,

        // Service List
        AnimatedListView(
          itemCount: 3,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return Container(
              decoration: boxDecorationDefault(color: context.cardColor),
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.only(bottom: 12),
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
                        ShimmerWidget(height: 16, width: context.width() * 0.5),
                        4.height,
                        ShimmerWidget(height: 12, width: context.width() * 0.3),
                        8.height,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ShimmerWidget(height: 12, width: 40),
                            ShimmerWidget(height: 14, width: 60),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),

        16.height,

        /// Price Details Section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ShimmerWidget(height: 16, width: context.width() * 0.3),
            ShimmerWidget(height: 14, width: context.width() * 0.15),
          ],
        ),
        16.height,

        // Price Details Card
        Container(
          decoration: boxDecorationDefault(
            color: context.cardColor,
            borderRadius: radius(12),
            border: Border.all(color: lightGreyColor, width: 1),
          ),
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              // Payment Method Card
              Container(
                decoration: boxDecorationDefault(
                  color: context.cardColor,
                  borderRadius: radius(6),
                  border: Border.all(color: beigeColor, width: 0.8),
                ),
                padding: EdgeInsets.all(12),
                margin: EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    // Payment Icon
                    ShimmerWidget(height: 40, width: 40).cornerRadiusWithClipRRect(20),
                    12.width,
                    // Payment Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShimmerWidget(height: 14, width: context.width() * 0.3),
                          4.height,
                          ShimmerWidget(height: 12, width: context.width() * 0.2),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Price Breakdown
              _buildPriceRowShimmer(context, "Subtotal"),
              10.height,
              _buildPriceRowShimmer(context, "Tax"),
              10.height,
              _buildPriceRowShimmer(context, "Tip"),
              10.height,
              _buildPriceRowShimmer(context, "Total", isTotal: true),
            ],
          ),
        ),

        16.height,

        /// Download Invoice Button (conditional)
        ShimmerWidget(
          child: Container(
            height: 48,
            width: context.width(),
            decoration: boxDecorationWithRoundedCorners(
              backgroundColor: context.cardColor,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),

        40.height,
      ],
    );
  }

  Widget _buildInfoTileShimmer(BuildContext context, IconData? icon, {bool hasImage = false}) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          hasImage
              ? ShimmerWidget(height: 44, width: 44).cornerRadiusWithClipRRect(22)
              : Container(
                  padding: EdgeInsets.all(10),
                  height: 44,
                  width: 44,
                  decoration: BoxDecoration(
                    color: icon == Icons.calendar_month_outlined ? primaryLightColor : lightGreenColor,
                    shape: BoxShape.circle,
                  ),
                  child: ShimmerWidget(height: 20, width: 20),
                ),
          12.width,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerWidget(height: 12, width: context.width() * 0.2),
                4.height,
                ShimmerWidget(height: 14, width: context.width() * 0.4),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRowShimmer(BuildContext context, String label, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ShimmerWidget(
          height: isTotal ? 16 : 12,
          width: context.width() * (isTotal ? 0.25 : 0.2),
        ),
        ShimmerWidget(
          height: isTotal ? 16 : 12,
          width: context.width() * (isTotal ? 0.2 : 0.15),
        ),
      ],
    );
  }
}
