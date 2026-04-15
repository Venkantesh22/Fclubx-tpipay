import 'package:flutter/material.dart';
import 'package:frezka/screens/booking/model/booking_list_response.dart';
import 'package:frezka/utils/colors.dart';
import 'package:frezka/utils/custom_toast_widget.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../components/add_review_dialog.dart';
import '../../../components/cached_image_widget.dart';
import '../../../main.dart';
import '../../../models/review_data.dart';
import '../../../utils/common_base.dart';
import '../../../utils/constants.dart';
import '../../review/review_repository.dart';
import '../view/booking_detail_screen.dart';

class CustomerReviewComponent extends StatefulWidget {
  final String? bookingStatus;
  final int? staffId;
  final ReviewData? customerReview;
  final String employeeName;
  final BookingListData booking;

  CustomerReviewComponent({required this.booking ,this.bookingStatus, this.staffId, this.customerReview, this.employeeName = ''});

  @override
  _CustomerReviewComponentState createState() => _CustomerReviewComponentState();
}

class _CustomerReviewComponentState extends State<CustomerReviewComponent> {
  bool isExpanded = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    //
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.bookingStatus == BookingStatusConst.COMPLETED)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.customerReview != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: boxDecorationDefault(
                        color: appStore.isDarkMode ? darkSecondaryColor : territoryButtonColor,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.amber.withValues(alpha: 0.2), width: 2),
                      ),
                      padding: EdgeInsets.only(bottom: 16, left: 16, right: 16),
                      width: context.width(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header with title and menu
                          Row(
                            children: [
                              Text(
                                locale.yourReview,
                                style: boldTextStyle(size: 14),
                              ).expand(),
                              PopupMenuButton<String>(
                                icon: Icon(Icons.more_horiz_outlined, color: context.iconColor, size: 20),
                                color: context.cardColor,
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    AddReviewDialog.show(
                                      context,
                                      customerReview: widget.customerReview,
                                      staffId: widget.staffId,
                                    );
                                  } else if (value == 'delete') {
                                    showConfirmDialogCustom(
                                      context,
                                      title: locale.deleteReview,
                                      subTitle: locale.doYouWantToDeleteReview,
                                      positiveText: locale.yes,
                                      negativeText: locale.no,
                                      dialogType: DialogType.DELETE,
                                      onAccept: (p0) async {
                                        appStore.setLoading(true);
                                        await deleteReview(id: widget.customerReview!.id.validate()).then((value) {
                                          ShowToast.showSuccess(value.message!);
                                          widget.booking.customerReview = null;
                                        }).catchError((e) {
                                          ShowToast.showError(e.toString());
                                        });
                                        onBookingDetailUpdate.call();
                                      },
                                    );
                                  }
                                },
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Text(locale.editReview, style: secondaryTextStyle()),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Text(locale.deleteReview, style: secondaryTextStyle()),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          12.height,
                          // Rating and Date
                          Row(
                            children: [
                              // Star Rating
                              Row(
                                children: List.generate(5, (index) {
                                  double rating = widget.customerReview!.rating.validate().toDouble();
                                  if (index < rating.floor()) {
                                    return Icon(Icons.star, size: 20, color: Colors.amber);
                                  } else if (index < rating) {
                                    return Icon(Icons.star_half, size: 20, color: Colors.amber);
                                  } else {
                                    return Icon(Icons.star_border, size: 20, color: Colors.amber);
                                  }
                                }),
                              ),
                              Spacer(),
                              Text(
                                formatDate(widget.customerReview!.createdAt.validate(), format: DateFormatConst.DATE_FORMAT_1, isLocal: true),
                                style: secondaryTextStyle(size: 12),
                              ),
                            ],
                          ),
                          12.height,
                          // Review Text
                          if (widget.customerReview!.reviewMsg.validate().isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.customerReview!.reviewMsg!,
                                  style: secondaryTextStyle(size: 12),
                                  maxLines: isExpanded ? null : 3,
                                  overflow: isExpanded ? null : TextOverflow.ellipsis,
                                ),
                                if (widget.customerReview!.reviewMsg!.length > 100)
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        isExpanded = !isExpanded;
                                      });
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.only(top: 4),
                                      child: Text(
                                        isExpanded ? locale.readLess : locale.readMore,
                                        style: boldTextStyle(
                                          size: 11,
                                          color: primaryColor,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          // Display Images if available
                          if (widget.customerReview!.images != null && widget.customerReview!.images!.isNotEmpty) ...[
                            12.height,
                            Container(
                              height: 60,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: widget.customerReview!.images!.length,
                                itemBuilder: (context, index) {
                                  return Container(
                                    margin: EdgeInsets.only(right: 8),
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: lightBorderColor),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: CachedImageWidget(
                                        url: widget.customerReview!.images![index],
                                        height: 60,
                                        width: 60,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                )
              else
                Container(
                  padding: EdgeInsets.only(top: 24, bottom: 20, left: 16, right: 16),
                  decoration: BoxDecoration(
                    color: appStore.isDarkMode ? darkSecondaryColor : territoryButtonColor,
                    borderRadius: radius(6),
                    border: Border.all(color: Colors.amber.withValues(alpha: 0.4), width: 2),
                  ),
                  width: context.width(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          5,
                          (index) => Icon(Icons.star_border, size: 24, color: Colors.amber),
                        ),
                      ),
                      12.height,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(locale.youHaveNotRatedYet + ".", style: secondaryTextStyle(size: 14, weight: FontWeight.w600)),
                          8.width,
                          GestureDetector(
                            onTap: () {
                              AddReviewDialog.show(
                                context,
                                staffId: widget.staffId,
                                customerReview: widget.customerReview,
                              );
                            },
                            child: Text(
                              locale.rateNow,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                shadows: [Shadow(color: context.primaryColor, offset: Offset(0, -2))],
                                color: Colors.transparent,
                                decoration: TextDecoration.underline,
                                decorationColor: context.primaryColor,
                                decorationThickness: 1,
                                decorationStyle: TextDecorationStyle.solid,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
      ],
    );
  }
}
