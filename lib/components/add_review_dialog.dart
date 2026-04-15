import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:frezka/screens/booking/view/booking_detail_screen.dart';
import 'package:frezka/utils/constants.dart';
import 'package:frezka/utils/custom_toast_widget.dart';
import 'package:nb_utils/nb_utils.dart';

import '../main.dart';
import '../models/review_data.dart';
import '../screens/review/review_repository.dart';
import '../utils/colors.dart';
import '../utils/images.dart';
import 'cached_image_widget.dart';
import 'loader_widget.dart';

class AddReviewDialog extends StatefulWidget {
  final ReviewData? customerReview;
  final int? staffId;

  AddReviewDialog({
    this.staffId,
    this.customerReview,
  });

  @override
  State<AddReviewDialog> createState() => _AddReviewDialogState();

  static Future<bool?> show(
    BuildContext context, {
    ReviewData? customerReview,
    int? staffId,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (context) => Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: AddReviewDialog(
          customerReview: customerReview,
          staffId: staffId,
        ),
      ),
    );
  }
}

class _AddReviewDialogState extends State<AddReviewDialog> {
  double selectedRating = 0;

  TextEditingController reviewCont = TextEditingController();

  bool isUpdate = false;
  bool isSubmitting = false;

  List<File> selectedImages = [];
  // final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    if (widget.customerReview != null) {
      selectedRating = widget.customerReview!.rating.validate().toDouble();
      reviewCont.text = widget.customerReview!.reviewMsg.validate();
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

  void submit() async {
    hideKeyboard(context);
    Map<String, dynamic> req = {};

    req = {
      "id": widget.customerReview != null
          ? widget.customerReview!.id.validate()
          : null,
      "employee_id": widget.staffId.validate(),
      "rating": selectedRating.validate(),
      "review_msg": reviewCont.text.validate(),
    };

    if (selectedImages.isNotEmpty) {
      List<String> imageBase64List = [];
      for (File imageFile in selectedImages) {
        try {
          List<int> imageBytes = await imageFile.readAsBytes();
          String base64Image = base64Encode(imageBytes);
          imageBase64List.add(base64Image);
        } catch (e) {
          log('Error converting image to base64: $e');
        }
      }
      if (imageBase64List.isNotEmpty) {
        req["images"] = imageBase64List;
      }
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      final value = await updateReview(req);
      if (!mounted) return;
      onBookingDetailUpdate.call();
      finish(context, true);
      ShowToast.showSuccess(value.message!);
    } catch (e) {
      if (!mounted) return;
      ShowToast.showError(e.toString());
      finish(context, false);
    } finally {
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
      }
    }
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
                // Header
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    children: [
                      Text(locale.rateUs, style: boldTextStyle(size: 16))
                          .expand(),
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
                Divider(color: context.dividerColor, height: 1)
                    .paddingSymmetric(horizontal: 16),

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
                        //       color: appStore.isDarkMode ? darkSecondaryColor : primaryLightColor,
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
                        // // Display Selected Images
                        // if (selectedImages.isNotEmpty) ...[
                        //   16.height,
                        //   Text(locale.selectedPhotos(selectedImages.length), style: boldTextStyle(size: 14, color: black)),
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
                        //           decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: lightBorderColor)),
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
                        //                     decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle),
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

                        // 12.height,
                        // Rating Section
                        Text(locale.rating,
                            style: boldTextStyle(size: LABEL_TEXT_SIZE)),
                        12.height,
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.only(
                              left: 16, right: 16, top: 12, bottom: 12),
                          decoration: boxDecorationDefault(
                            color: appStore.isDarkMode
                                ? darkSecondaryColor
                                : primaryLightColor,
                            borderRadius: radius(4),
                            border: Border.all(color: borderColor, width: 0.5),
                          ),
                          child: RatingBarWidget(
                            onRatingChanged: (rating) {
                              selectedRating = rating;
                              setState(() {});
                            },
                            activeColor: Colors.amber,
                            inActiveColor: Colors.amber,
                            rating: selectedRating,
                            size: 24,
                          ),
                        ),
                        12.height,
                        // Write Review Section
                        Text(locale.writeReview,
                            style: boldTextStyle(size: LABEL_TEXT_SIZE)),
                        8.height,
                        AppTextField(
                          controller: reviewCont,
                          textFieldType: TextFieldType.OTHER,
                          minLines: 2,
                          maxLines: 4,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: InputDecoration(
                            hintText:
                                locale.shareYourFeedbackAboutTheExperience,
                            hintStyle: primaryTextStyle(
                              size: 12,
                              color: appTextSecondaryColor,
                            ),
                            contentPadding: EdgeInsets.all(12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              borderSide:
                                  BorderSide(color: borderColor, width: 0.5),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              borderSide:
                                  BorderSide(color: borderColor, width: 0.5),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              borderSide:
                                  BorderSide(color: borderColor, width: 0.5),
                            ),
                            filled: true,
                            fillColor: appStore.isDarkMode
                                ? darkSecondaryColor
                                : primaryLightColor,
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
                            text: locale.submit
                                .split(' ')
                                .map((word) => word.isNotEmpty
                                    ? word[0].toUpperCase() +
                                        word.substring(1).toLowerCase()
                                    : '')
                                .join(' '),
                            color: primaryColor,
                            shapeBorder:
                                RoundedRectangleBorder(borderRadius: radius(4)),
                            textStyle: primaryTextStyle(
                              weight: FontWeight.w700,
                              size: 14,
                              color: white,
                            ),
                            padding: EdgeInsets.symmetric(
                                vertical: 8, horizontal: 24),
                            onTap: () {
                              if (selectedRating == 0) {
                                ShowToast.showInfo(locale.ratingIsRequired);
                              } else {
                                submit();
                              }
                            },
                          ),
                        ),
                        10.height,
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (isSubmitting)
              Positioned.fill(
                child: IgnorePointer(
                  ignoring: false,
                  child: Container(
                    color: context.cardColor.withValues(alpha: 0.6),
                    alignment: Alignment.center,
                    child: LoaderWidget(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
