import 'dart:io';

import 'package:flutter/material.dart';
import 'package:frezka/utils/images.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../components/cached_image_widget.dart';
import '../../../components/loader_widget.dart';
import '../../../main.dart';
import '../../../utils/colors.dart';
import '../../../utils/constants.dart';
import '../../../utils/custom_toast_widget.dart';
import '../../product/model/product_review_data_model.dart';
import '../order_repository.dart';
import '../view/order_detail_screen.dart';

class ProductReviewDialog extends StatefulWidget {
  final ProductReviewDataModel? productReview;
  final int? productId;
  final int? productVariationId;

  ProductReviewDialog({this.productReview, this.productId, this.productVariationId});

  @override
  State<ProductReviewDialog> createState() => _ProductReviewDialogState();

  static Future<bool?> show(
    BuildContext context, {
    ProductReviewDataModel? productReview,
    int? productId,
    int? productVariationId,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      useSafeArea: true,
      builder: (context) => Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: ProductReviewDialog(
          productReview: productReview,
          productId: productId,
          productVariationId: productVariationId,
        ),
      ),
    );
  }
}

class _ProductReviewDialogState extends State<ProductReviewDialog> {
  double selectedRating = 0;

  TextEditingController reviewCont = TextEditingController();

  bool isUpdate = false;

  List<File> selectedImages = [];
  List<String> existingImageUrls = [];
  // final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    if (widget.productReview != null) {
      selectedRating = widget.productReview!.rating.validate().toDouble();
      reviewCont.text = widget.productReview!.reviewMsg.validate();
    }

    super.initState();
  }

  // Future<void> _pickImages() async {
  //   try {
  //     final List<XFile> images = await _picker.pickMultiImage();
  //     if (images.isNotEmpty) {
  //       setState(() {
  //         selectedImages = images.map((image) => File(image.path)).toList();
  //       });
  //     }
  //   } catch (e) {
  //     ShowToast.showError('Error picking images: $e');
  //   }
  // }

  // void _removeImage(int index) {
  //   setState(() {
  //     selectedImages.removeAt(index);
  //   });
  // }

  // void _removeExistingImage(int index) {
  //   setState(() {
  //     existingImageUrls.removeAt(index);
  //   });
  // }

  void submit() async {
    hideKeyboard(context);

    appStore.setLoading(true);

    // Handle image submission logic
    List<XFile> filesToSend = [];
    if (widget.productReview != null) {
      if (selectedImages.isNotEmpty) {
        filesToSend = selectedImages.map((file) => XFile(file.path)).toList();
      }
    } else {
      filesToSend = selectedImages.map((file) => XFile(file.path)).toList();
    }

    await updateOrderReview(
      files: filesToSend,
      reviewId: widget.productReview != null ? widget.productReview!.id.validate().toString() : '',
      productId: widget.productId.validate().toString(),
      productVariationId: widget.productVariationId.validate().toString(),
      rating: selectedRating.validate().toString(),
      reviewMsg: reviewCont.text.validate(),
      onSuccess: (data) {
        appStore.setLoading(false);
        onOrderDetailUpdate?.call();
        finish(context, true);
        ShowToast.showSuccess(locale.thanksYouForReview);
      },
    ).catchError((e) {
      appStore.setLoading(false);
      ShowToast.showError(e.toString());
      finish(context, false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return AnimatedPadding(
      padding: EdgeInsets.only(bottom: bottomInset),
      duration: 150.milliseconds,
      curve: Curves.easeOut,
      child: Container(
        decoration: boxDecorationDefault(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    children: [
                      Text(locale.rateUs, style: boldTextStyle(size: 16)).expand(),
                      GestureDetector(
                        onTap: () {
                          finish(context);
                        },
                        child: Padding(
                          padding: EdgeInsets.all(8),
                          child: CachedImageWidget(
                            url: ic_close,
                            height: 20,
                            width: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(color: context.dividerColor, height: 1).paddingSymmetric(horizontal: 16),
      
                // Content
                16.height,
                Flexible(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Add Photo Button
                        // GestureDetector(
                        //   onTap: _pickImages,
                        //   child: Container(
                        //     width: double.infinity,
                        //     padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        //     decoration: boxDecorationDefault(
                        //       color: appStore.isDarkMode ? context.cardColor : primaryLightColor,
                        //       borderRadius: radius(4),
                        //       border: Border.all(color: primaryColor, width: 0.5),
                        //     ),
                        //     child: Row(
                        //       mainAxisAlignment: MainAxisAlignment.center,
                        //       children: [
                        //         Icon(Icons.camera_alt_outlined, color: primaryColor, size: 22),
                        //         8.width,
                        //         Text(locale.addPhoto, style: boldTextStyle(color: primaryColor, size: 14)),
                        //       ],
                        //     ),
                        //   ),
                        // ),
                        // // Display Existing Images (when editing)
                        // if (existingImageUrls.isNotEmpty) ...[
                        //   16.height,
                        //   Text(locale.currentPhotos(existingImageUrls.length.toString()), style: boldTextStyle(size: 14)),
                        //   8.height,
                        //   Container(
                        //     height: 80,
                        //     child: ListView.builder(
                        //       scrollDirection: Axis.horizontal,
                        //       itemCount: existingImageUrls.length,
                        //       itemBuilder: (context, index) {
                        //         return Container(
                        //           margin: EdgeInsets.only(right: 8),
                        //           width: 80,
                        //           height: 80,
                        //           decoration: BoxDecoration(
                        //             borderRadius: BorderRadius.circular(8),
                        //             border: Border.all(color: lightBorderColor),
                        //           ),
                        //           child: Stack(
                        //             children: [
                        //               ClipRRect(
                        //                 borderRadius: BorderRadius.circular(8),
                        //                 child: CachedImageWidget(
                        //                   url: existingImageUrls[index],
                        //                   width: 80,
                        //                   height: 80,
                        //                   fit: BoxFit.cover,
                        //                 ),
                        //               ),
                        //               Positioned(
                        //                 top: 4,
                        //                 right: 4,
                        //                 child: GestureDetector(
                        //                   onTap: () => _removeExistingImage(index),
                        //                   child: Container(
                        //                     width: 20,
                        //                     height: 20,
                        //                     decoration: BoxDecoration(color: redColor, shape: BoxShape.circle),
                        //                     child: Icon(Icons.close, color: white, size: 12),
                        //                   ),
                        //                 ),
                        //               ),
                        //             ],
                        //           ),
                        //         );
                        //       },
                        //     ),
                        //   ),
                        // ],
      
                        // // Display Newly Selected Images
                        // if (selectedImages.isNotEmpty) ...[
                        //   16.height,
                        //   Text(locale.newPhotos(selectedImages.length), style: boldTextStyle(size: 14)),
                        //   8.height,
                        //   Container(
                        //     height: 80,
                        //     child: ListView.builder(
                        //       scrollDirection: Axis.horizontal,
                        //       itemCount: selectedImages.length,
                        //       itemBuilder: (context, index) {
                        //         return Container(
                        //           margin: EdgeInsets.only(right: 8),
                        //           width: 80,
                        //           height: 80,
                        //           decoration: BoxDecoration(
                        //             borderRadius: BorderRadius.circular(8),
                        //           ),
                        //           child: Stack(
                        //             children: [
                        //               ClipRRect(
                        //                 borderRadius: BorderRadius.circular(8),
                        //                 child: Image.file(
                        //                   selectedImages[index],
                        //                   width: 80,
                        //                   height: 80,
                        //                   fit: BoxFit.cover,
                        //                 ),
                        //               ),
                        //               Positioned(
                        //                 top: 4,
                        //                 right: 4,
                        //                 child: GestureDetector(
                        //                   onTap: () => _removeImage(index),
                        //                   child: Container(
                        //                     width: 20,
                        //                     height: 20,
                        //                     decoration: BoxDecoration(color: redColor, shape: BoxShape.circle),
                        //                     child: Icon(Icons.close, color: white, size: 12),
                        //                   ),
                        //                 ),
                        //               ),
                        //             ],
                        //           ),
                        //         );
                        //       },
                        //     ),
                        //   ),
                        // ],
      
                        // // Rating Section
                        // 12.height,
                        Text(locale.rating, style: boldTextStyle(size: LABEL_TEXT_SIZE)),
                        12.height,
      
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 12),
                          decoration: boxDecorationDefault(
                            color: appStore.isDarkMode ? context.cardColor : scaffoldPrimaryLight,
                            borderRadius: radius(4),
                            border: Border.all(color:appStore.isDarkMode ? context.dividerColor : borderColor, width: 0.5),
                          ),
                          child: RatingBarWidget(
                            onRatingChanged: (rating) {
                              selectedRating = rating;
                              setState(() {});
                            },
                            activeColor: ratingBarColor,
                            inActiveColor: ratingBarColor,
                            rating: selectedRating,
                            size: 24,
                          ),
                        ),
                        12.height,
                        // Write Review Section
                        Text(locale.writeReview, style: boldTextStyle(size: LABEL_TEXT_SIZE)),
                        12.height,
      
                        
                        AppTextField(
                          controller: reviewCont,
                          textFieldType: TextFieldType.OTHER,
                          minLines: 2,
                          maxLines: 4,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: InputDecoration(
                            hintText: locale.shareYourFeedbackAboutTheExperience,
                            hintStyle: secondaryTextStyle(color: appTextSecondaryColor),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: appStore.isDarkMode ? context.dividerColor:  lightBorderColor, width: 1),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: appStore.isDarkMode ? context.dividerColor:  lightBorderColor, width: 1),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: primaryColor),
                            ),
                            filled: true,
                            fillColor: appStore.isDarkMode ? context.dividerColor : white,
                          ),
                        ),
                        24.height,
                        // Submit Button
                        Container(
                          width: context.width(),
                          height: 45,
                          child: AppButton(
                            width: context.width(),
                            textColor: white,
                            text: locale.submit,
                            color: primaryColor,
                            shapeBorder: RoundedRectangleBorder(borderRadius: radius(4)),
                            textStyle: boldTextStyle(color: white, size: 14, height: 0.2),
                            onTap: () {
                              if (selectedRating == 0) {
                                ShowToast.showInfo(locale.ratingIsRequired);
                              } else {
                                submit();
                              }
                            },
                          ),
                        ),
                        10.height, // Add bottom padding for better spacing
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Center Loader
            if (appStore.isLoading)
              Container(
                child: Center(child: LoaderWidget()),
              ),
          ],
        ),
      ),
    );
  }
}
