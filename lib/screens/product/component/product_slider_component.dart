import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../components/cached_image_widget.dart';
import '../../../configs.dart';
import '../../../utils/colors.dart';
import '../../../utils/constants.dart';
import '../../zoom_image_screen.dart';

class ProductSliderComponent extends StatefulWidget {
  final List<String> productGalleryData;
  final GlobalKey? productImageKey;

  ProductSliderComponent({required this.productGalleryData, this.productImageKey});

  @override
  _ProductSliderComponentState createState() => _ProductSliderComponentState();
}

class _ProductSliderComponentState extends State<ProductSliderComponent> {
  PageController controller = PageController(keepPage: true, initialPage: 0);

  int currentPage = 0;

  Timer? timer;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    if (getBoolAsync(SharedPreferenceConst.AUTO_SLIDER_STATUS, defaultValue: true) && widget.productGalleryData.validate().length >= 2) {
      timer = Timer.periodic(Duration(seconds: DASHBOARD_AUTO_SLIDER_SECOND), (Timer timer) {
        if (currentPage < widget.productGalleryData.validate().length - 1) {
          currentPage++;
        } else {
          currentPage = 0;
        }
        controller.animateToPage(currentPage, duration: Duration(milliseconds: 950), curve: Curves.easeOutQuart);
      });

      controller.addListener(() {
        currentPage = controller.page!.toInt();
        setState(() {}); 
      });
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.productGalleryData.validate().isEmpty) {
      return SizedBox(
        height: 430,
        width: context.width(),
        child: Container(
          color: scaffoldPrimaryLight,
          child: Center(child: Icon(Icons.image, size: 48, color: context.iconColor)),
        ),
      );
    }

    return SizedBox(
      height: 430,
      width: context.width(),
      child: Stack(
        children: [
          PageView.builder(
            controller: controller,
            reverse: false,
            itemCount: widget.productGalleryData.validate().length,
            itemBuilder: (_, i) {
              String productGalleryData = widget.productGalleryData.validate()[i];

              return Container(
                key: widget.productImageKey != null && i == 0 ? widget.productImageKey : null,
                width: context.width(),
                height: 430,
                color: scaffoldPrimaryLight,
                child: CachedImageWidget(url: productGalleryData.validate(), height: 430, width: context.width(), fit: BoxFit.cover),
              ).onTap(() {
                if (productGalleryData.validate().isNotEmpty) {
                  ZoomImageScreen(
                    galleryImages: widget.productGalleryData.validate().map((e) => e.validate()).toList(),
                    index: i,
                  ).launch(context);
                }
              });
            },
          ),
          if (widget.productGalleryData.validate().length > 1)
            Positioned(
              bottom: 8,
              right: 0,
              left: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.productGalleryData.validate().length,
                  (index) => Container(
                    margin: EdgeInsets.symmetric(horizontal: 3),
                    width: index == currentPage ? 18 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: index == currentPage ? primaryColor : primaryLightColor,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: primaryColor,
                        width: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
