import 'package:flutter/material.dart';
import 'package:frezka/components/shimmer_widget.dart';
import 'package:frezka/utils/colors.dart';
import 'package:nb_utils/nb_utils.dart';

class SelectBranchShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AnimatedListView(
      padding: EdgeInsets.only(bottom: 16, top: 16),
      physics: AlwaysScrollableScrollPhysics(),
      itemCount: 8,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.only(bottom: 10),
          decoration: boxDecorationWithRoundedCorners(
            backgroundColor: context.cardColor,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: borderColor, width: 0.5),
          ),
          child: Stack(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Branch Image
                  Container(
                    width: 70,
                    height: 70,
                    margin: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ShimmerWidget(
                      height: 70,
                      width: 70,
                      backgroundColor: context.cardColor,
                    ).cornerRadiusWithClipRRect(8),
                  ),
        
                  // Content Section
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12, right: 12, bottom: 5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Tags Row
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              // Status Tag
                              ShimmerWidget(
                                height: 20,
                                width: 50,
                                backgroundColor: context.cardColor,
                              ).cornerRadiusWithClipRRect(8),
                              // Rating Tag
                              ShimmerWidget(
                                height: 20,
                                width: 40,
                                backgroundColor: context.cardColor,
                              ).cornerRadiusWithClipRRect(8),
                              // Type Tag
                              ShimmerWidget(
                                height: 20,
                                width: 60,
                                backgroundColor: context.cardColor,
                              ).cornerRadiusWithClipRRect(8),
                            ],
                          ),
                          6.height,
        
                          // Salon Name
                          ShimmerWidget(height: 15, width: context.width() * 0.4),
                          4.height,
        
                          // Address Row
                          Row(
                            children: [
                              ShimmerWidget(height: 12, width: 12),
                              4.width,
                              Expanded(
                                child: ShimmerWidget(height: 12, width: context.width() * 0.5),
                              ),
                            ],
                          ),
                          4.height,
        
                          // Distance (if available)
                          if (index % 3 == 0) // Show distance for some items
                            Align(
                              alignment: Alignment.centerRight,
                              child: ShimmerWidget(height: 10, width: 80),
                            ),
                        ],
                      ),
                    ),
                  ),
        
                  // Selection Indicator
                  Container(
                    width: 20,
                    height: 20,
                    margin: EdgeInsets.only(top: 10, right: 10),
                    child: ShimmerWidget(
                      height: 20,
                      width: 20,
                      backgroundColor: context.cardColor,
                    ).cornerRadiusWithClipRRect(10),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
