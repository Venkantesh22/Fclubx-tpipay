import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../components/shimmer_widget.dart';

class WalletHistoryShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AnimatedScrollView(
      children: [
        16.height,
        
        /// Wallet Card Section
        Container(
          width: context.width(),
          height: 170,
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: EdgeInsets.all(16),
          decoration: boxDecorationWithRoundedCorners(
            borderRadius: BorderRadius.circular(6),
            backgroundColor: context.cardColor,
            border: Border.all(color: context.cardColor, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Available Balance Label
              ShimmerWidget(height: 16, width: context.width() * 0.3),
              8.height,
              // Balance Amount
              ShimmerWidget(height: 32, width: context.width() * 0.4),
              20.height,
              // Buttons Row
              Row(
                children: [
                  // Withdraw Button
                  Expanded(
                    child: Container(
                      height: 35,
                      decoration: boxDecorationWithRoundedCorners(
                        borderRadius: BorderRadius.circular(4),
                        backgroundColor: context.cardColor,
                        border: Border.all(color: context.cardColor  , width: 1),
                      ),
                      child: Center(
                        child: ShimmerWidget(height: 14, width: 60),
                      ),
                    ),
                  ),
                  12.width,
                  // Top Up Button
                  Expanded(
                    child: Container(
                      height: 35,
                      decoration: boxDecorationWithRoundedCorners(
                        borderRadius: BorderRadius.circular(4),
                        backgroundColor: context.cardColor,
                        border: Border.all(color: context.cardColor, width: 1),
                      ),
                      child: Center(
                        child: ShimmerWidget(height: 14, width: 50),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        10.height,
        
        /// Recent Transactions Header
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: ShimmerWidget(height: 16, width: context.width() * 0.4),
        ),
        
        12.height,
        
        /// Transaction List
        AnimatedListView(
          physics: NeverScrollableScrollPhysics(),
          padding: EdgeInsets.only(bottom: 16),
          listAnimationType: ListAnimationType.FadeIn,
          itemCount: 8,
          emptyWidget: SizedBox.shrink(),
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return Container(
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: boxDecorationWithRoundedCorners(
                borderRadius: BorderRadius.circular(6),
                backgroundColor: context.cardColor,
              ),
              child: Row(
                children: [
                  // Transaction Icon
                  Container(
                    width: 40,
                    height: 40,
                    decoration: boxDecorationWithRoundedCorners(
                      boxShape: BoxShape.circle,
                      backgroundColor:context.cardColor,
                    ),
                    child: Center(
                      child: ShimmerWidget(
                        height: 20,
                        width: 20,
                        backgroundColor: context.cardColor,
                      ),
                    ),
                  ),
                  16.width,
                  
                  // Transaction Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Transaction Message
                        ShimmerWidget(height: 14, width: context.width() * 0.6),
                        4.height,
                        // Date/Time
                        ShimmerWidget(height: 12, width: context.width() * 0.4),
                      ],
                    ),
                  ),
                  
                  // Amount
                  ShimmerWidget(height: 14, width: 60),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
