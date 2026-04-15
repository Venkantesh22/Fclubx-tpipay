import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../components/cached_image_widget.dart';
import '../model/category_response.dart';

class CategoryItemWidget extends StatelessWidget {
  final double? width;
  final CategoryData categoryData;
  final bool? isForDashboard;

  CategoryItemWidget({this.width, required this.categoryData, this.isForDashboard = false});

  @override
  Widget build(BuildContext context) {
    double cardWidth = isForDashboard! ? width ?? context.width() / 4 - 16 : 90;
    double cardHeight = 103;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Container(
        width: cardWidth,
        height: cardHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              /// Background Image
              CachedImageWidget(
                url: categoryData.categoryImage.validate(),
                width: cardWidth,
                height: cardHeight,
                fit: BoxFit.cover,
              ),

              /// Black shadow overlay at bottom with gradient
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: cardHeight * 0.6,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black],
                    ),
                  ),
                ),
              ),

              /// Text centered at bottom
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: Text(
                  categoryData.name.validate().split(' ').map((word) => word.isNotEmpty ? word[0].toUpperCase() + word.substring(1).toLowerCase() : '').join(' '),
                  style: primaryTextStyle(
                    size: 12,
                    height: 1.33,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
