import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../components/shimmer_widget.dart';
import '../../../utils/constants.dart';

class ViewAllServiceShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AnimatedScrollView(
      padding: EdgeInsets.only(top: 10, bottom: 80),
      crossAxisAlignment: CrossAxisAlignment.start,
      listAnimationType: ListAnimationType.None,
      children: [
        /// Subcategory UI
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Subcategory Label
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ShimmerWidget(height: 16, width: context.width() * 0.25),
                ShimmerWidget(height: 16, width: context.width() * 0.15),
              ],
            ).paddingLeft(16),
            8.height,
            HorizontalList(
              itemCount: 5,
              runSpacing: 16,
              spacing: 16,
              padding: EdgeInsets.only(left: 16, right: 16, top: 8),
              itemBuilder: (context, index) {
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ShimmerWidget(
                      child: Container(
                        width: context.width() / 3.5 - 20,
                        padding: EdgeInsets.zero,
                        decoration: boxDecorationWithRoundedCorners(
                          backgroundColor: context.cardColor,
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 6,
                              offset: Offset(0, 3),
                            ),
                          ],
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              // Background Image Shimmer
                              ShimmerWidget(
                                height: CATEGORY_ICON_SIZE,
                                width: context.width() / 3.5 - 20,
                                backgroundColor: context.cardColor,
                              ),
                              // Black shadow overlay at bottom
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.black.withValues(alpha: 0.8),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              // Text shimmer on top of shadow
                              Positioned(
                                bottom: 8,
                                left: 0,
                                right: 0,
                                child: ShimmerWidget(
                                  height: 14,
                                  width: context.width() * 0.2,
                                  backgroundColor: Colors.white.withValues(alpha: 0.3),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Selection indicator shimmer
                    Positioned(
                      top: 0,
                      right: 0,
                      child: ShimmerWidget(
                        child: Container(
                          padding: EdgeInsets.all(2),
                          decoration: boxDecorationDefault(color: context.primaryColor),
                          child: Icon(Icons.done, size: 16, color: Colors.white),
                        ).cornerRadiusWithClipRRect(16),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),

        /// Services UI
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            20.height,
            // Services count text
            ShimmerWidget(height: 16, width: context.width() * 0.4),
            16.height,
            AnimatedListView(
              itemCount: 8,
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (ctx, index) {
                return Container(
                  decoration: boxDecorationWithRoundedCorners(
                    backgroundColor: context.cardColor,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  margin: EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // Service image
                        ShimmerWidget(
                          height: 60,
                          width: 60,
                          backgroundColor: context.cardColor,
                        ).cornerRadiusWithClipRRect(8),
                        12.width,
                        // Service details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ShimmerWidget(height: 16, width: context.width() * 0.4),
                              8.height,
                              ShimmerWidget(height: 14, width: context.width() * 0.3),
                              8.height,
                              Row(
                                children: [
                                  ShimmerWidget(height: 12, width: 40),
                                  8.width,
                                  ShimmerWidget(height: 12, width: 30),
                                ],
                              ),
                            ],
                          ),
                        ),
                        12.width,
                        // Price and checkbox
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            ShimmerWidget(height: 16, width: 60),
                            8.height,
                            ShimmerWidget(
                              height: 20,
                              width: 20,
                              backgroundColor: context.cardColor,
                            ).cornerRadiusWithClipRRect(4),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ).paddingSymmetric(horizontal: 16),
      ],
    );
  }
}
