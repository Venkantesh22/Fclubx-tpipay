import 'package:flutter/material.dart';
import 'package:frezka/main.dart';
import 'package:frezka/screens/order/order_repository.dart';
import 'package:frezka/utils/colors.dart';
import 'package:frezka/utils/custom_toast_widget.dart';
import 'package:nb_utils/nb_utils.dart';

import '../model/product_list_response.dart';

class AddReviewFormComponent extends StatefulWidget {
  final ProductData productData;
  final Function()? onReviewSubmitted;

  AddReviewFormComponent({required this.productData, this.onReviewSubmitted});

  @override
  _AddReviewFormComponentState createState() => _AddReviewFormComponentState();
}

class _AddReviewFormComponentState extends State<AddReviewFormComponent> {
  double selectedRating = 0.0;
  TextEditingController reviewController = TextEditingController();
  bool isSubmittingReview = false;

  @override
  void dispose() {
    reviewController.dispose();
    super.dispose();
  }

  Future<void> submitReview() async {
    if (selectedRating == 0.0) {
      ShowToast.showInfo(locale.pleaseSelectARating);
      return;
    }

    if (reviewController.text.trim().isEmpty) {
      ShowToast.showInfo(locale.pleaseWriteAReview);
      return;
    }

    setState(() {
      isSubmittingReview = true;
    });

    try {
      // Call actual API to submit review
      await updateOrderReview(
        productId: widget.productData.id.validate().toString(),
        productVariationId: widget.productData.variationData?.isNotEmpty == true ? widget.productData.variationData!.first.id.validate().toString() : '',
        rating: selectedRating.toString(),
        reviewMsg: reviewController.text.trim(),
        onSuccess: (data) {
          ShowToast.showSuccess(locale.reviewSubmittedSuccessfully);
          reviewController.clear();
          selectedRating = 0.0;
          // Use addPostFrameCallback to safely trigger refresh after the current frame finishes
          WidgetsBinding.instance.addPostFrameCallback((_) {
            widget.onReviewSubmitted?.call();
          });
        },
      );
    } catch (e) {
      ShowToast.showError(e.toString());
    } finally {
      setState(() {
        isSubmittingReview = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            locale.addReview,
            style: boldTextStyle(size: 16),
          ),
          24.height,

          // Rating Section
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                locale.rating + "*",
                style: boldTextStyle(size: 14),
              ),
              8.height,
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: boxDecorationDefault(
                  color: context.cardColor,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: borderColor, width: 0.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: List.generate(5, (index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedRating = (index + 1).toDouble();
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.only(right: index < 4 ? 6 : 0),
                        child: Icon(
                          index < selectedRating ? Icons.star : Icons.star_border,
                          color: accentOrangeColor,
                          size: 24,
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),

          24.height,

          // Review Text Section
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                locale.writeReview,
                style: boldTextStyle(size: 14),
              ),
              8.height,
              Container(
                height: 80,
                decoration: boxDecorationDefault(
                  color: context.cardColor,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: borderColor, width: 0.5),
                ),
                padding: EdgeInsets.all(12),
                child: AppTextField(
                  controller: reviewController,
                  minLines: 3,
                  maxLines: 10,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: locale.shareYourFeedbackAboutTheExperience,
                    hintStyle: secondaryTextStyle(size: 12),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  textFieldType: TextFieldType.OTHER,
                ),
              ),
            ],
          ),

          24.height,

          // Submit Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: isSubmittingReview ? null : submitReview,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                elevation: 0,
              ),
              child: isSubmittingReview
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: white, strokeWidth: 2),
                    )
                  : Text(
                      locale.submit,
                      style: boldTextStyle(size: 14, color: white),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
