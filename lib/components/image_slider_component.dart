import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frezka/components/cached_image_widget.dart';
import 'package:nb_utils/nb_utils.dart';

import '../configs.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';

/// A reusable image slider component that displays a list of images with auto-slide functionality.
class ImageSliderComponent extends StatefulWidget {
  final List<String> imageUrls;
  final double height;
  final double? width;
  final BoxFit fit;
  final double borderRadius;
  final EdgeInsetsGeometry padding;

  const ImageSliderComponent({
    super.key,
    required this.imageUrls,
    this.height = 200,
    this.width,
    this.fit = BoxFit.cover,
    this.borderRadius = 0,
    this.padding = EdgeInsets.zero,
  });

  @override
  State<ImageSliderComponent> createState() => _ImageSliderComponentState();
}

class _ImageSliderComponentState extends State<ImageSliderComponent> {
  PageController controller = PageController(keepPage: true, initialPage: 0);
  int currentPage = 0;
  Timer? timer;

  @override
  void initState() {
    super.initState();

    if (getBoolAsync(SharedPreferenceConst.AUTO_SLIDER_STATUS, defaultValue: true) && widget.imageUrls.length >= 2) {
      timer = Timer.periodic(Duration(seconds: DASHBOARD_AUTO_SLIDER_SECOND), (Timer timer) {
        if (currentPage < widget.imageUrls.length - 1) {
          currentPage++;
        } else {
          currentPage = 0;
        }
        controller.animateToPage(currentPage, duration: Duration(milliseconds: 950), curve: Curves.easeOutQuart);
      });

      controller.addListener(() {
        currentPage = controller.page!.toInt();
      });
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    timer?.cancel();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrls.isEmpty) return Offstage();

    // If only one image, show single image without slider
    if (widget.imageUrls.length == 1) {
      return Padding(
        padding: widget.padding,
        child: CachedImageWidget(
          url: widget.imageUrls.first,
          height: widget.height,
          width: widget.width ?? context.width(),
          fit: widget.fit,
          radius: widget.borderRadius,
        ),
      );
    }

    return SizedBox(
      height: widget.height,
      child: Stack(
        children: [
          PageView.builder(
            controller: controller,
            reverse: false,
            itemCount: widget.imageUrls.length,
            itemBuilder: (_, i) {
              return Padding(
                padding: widget.padding,
                child: CachedImageWidget(
                  url: widget.imageUrls[i],
                  height: widget.height,
                  width: widget.width ?? context.width(),
                  fit: widget.fit,
                  radius: widget.borderRadius,
                ),
              );
            },
          ),
          Positioned(
            bottom: 8,
            right: 0,
            left: 0,
            child: DotIndicator(
              pageController: controller,
              pages: widget.imageUrls,
              indicatorColor: indicatorColor,
              unselectedIndicatorColor: lightGray,
              currentDotSize: 10,
              dotSize: 8,
            ),
          ),
        ],
      ),
    );
  }
}
