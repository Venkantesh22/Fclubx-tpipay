import 'package:flutter/material.dart';
import 'package:frezka/main.dart';
import 'package:frezka/utils/common_base.dart';
import 'package:frezka/utils/custom_toast_widget.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../components/add_review_dialog.dart';
import '../../../components/cached_image_widget.dart';
import '../../../components/cancel_booking_dialogue.dart';
import '../../../components/price_widget.dart';
import '../../../models/review_data.dart';
import '../../../utils/app_common.dart';
import '../../../utils/colors.dart';
import '../../../utils/constants.dart';
import '../../dashboard/component/booking_list_component.dart';
import '../booking_repository.dart';
import '../model/booking_list_response.dart';
import '../view/booking_detail_screen.dart';

class BookingItemComponent extends StatefulWidget {
  final BookingListData bookingData;

  BookingItemComponent({required this.bookingData});

  @override
  State<BookingItemComponent> createState() => _BookingItemComponentState();
}

class _BookingItemComponentState extends State<BookingItemComponent> {
  bool showBookingInfo = false;

  Future<ReviewData?> getBookingDetails() async {
    try {
      appStore.setLoading(true);
      final res = await getBookingDetail(bookingId: widget.bookingData.id.validate());
      return res.data?.customerReview;
    } catch (e) {
      return null;
    } finally {
      appStore.setLoading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingData = widget.bookingData;

    return InkWell(
      onTap: () {
        hideKeyboard(context);
        BookingDetailScreen(
          bookingId: bookingData.id.validate(),
          bookingStatus: bookingData.status.validate(),
        ).launch(context);
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: context.width(),
        margin: EdgeInsets.all(8),
        decoration: boxDecorationDefault(color: context.cardColor, borderRadius: BorderRadius.circular(8), border: Border.all(color: borderColor, width: 0.5)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// --- REFUND PENDING SECTION ---
            // if (bookingData.payment?.paymentStatus == SERVICE_PAYMENT_STATUS_PAID && bookingData.status == BookingStatusConst.CANCELLED)
            //   Container(
            //     width: double.infinity,
            //     padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            //     decoration: BoxDecoration(
            //       color: Color(0xFFFFEBEE),
            //       borderRadius: BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
            //     ),
            //     child: Row(
            //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //       children: [
            //         Text("Refund Pending", style: boldTextStyle(size: 14, color: Colors.red[700])),
            //         Text("\$${bookingData.sumOfServicePrices.validate()}", style: boldTextStyle(size: 14, color: Colors.black)),
            //       ],
            //     ),
            //   ),

            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text("ID: ", style: secondaryTextStyle(size: 12)),
                          Expanded(
                            child: Text(bookingData.bookingId ?? "#${bookingData.id.validate()}", style: boldTextStyle(size: 12), overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ),
                      2.height,
                      Row(
                        children: [
                          Text(locale.dateTime + ": ", style: secondaryTextStyle(size: 12)),
                          Expanded(
                            child: Text(bookingData.startDateTime.validate(), style: boldTextStyle(size: 12), overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                /// Right side: Price
                PriceWidget(price: bookingData.sumOfServicePrices.validate(), color: primaryColor, size: 14),
              ],
            ).paddingOnly(left: 16, right: 16, top: 16, bottom: 10),
            Divider(color: context.dividerColor, thickness: 0.5),

            /// --- SERVICE SECTION ---
            Row(
              children: [
                /// Service Image
                CachedImageWidget(url: bookingData.serviceList.validate().isNotEmpty ? bookingData.serviceList!.first.serviceImage.validate() : '', height: 60, width: 60, fit: BoxFit.cover, radius: defaultRadius),
                12.width,

                /// Service Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Service Tag
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: boxDecorationDefault(color: primaryLightColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: borderColor, width: 0.8)),
                        child: Text(
                          bookingData.packages != null && bookingData.packages!.isNotEmpty ? locale.package : bookingData.branchName.validate(),
                          style: boldTextStyle(size: 10, color: appTextSecondaryColor),
                        ),
                      ),
                      9.height,

                      /// Service Name
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              bookingData.serviceList.validate().isNotEmpty
                                  ? bookingData.serviceList!.first.serviceName.validate()
                                  : bookingData.packages != null && bookingData.packages!.isNotEmpty
                                      ? "${locale.package}"
                                      : "",
                              style: boldTextStyle(size: 14),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (bookingData.serviceList.validate().isNotEmpty && bookingData.serviceList!.length > 1)
                            InkWell(
                              onTap: () {
                                serviceCommonBottomSheet(
                                  context,
                                  title: locale.yourBookedServices,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      /// Service List
                                      ...bookingData.serviceList!.map(
                                        (service) => Container(
                                          margin: EdgeInsets.only(bottom: 16),
                                          child: Row(
                                            children: [
                                              /// Service Image
                                              CachedImageWidget(
                                                url: service.serviceImage.validate(),
                                                height: 50,
                                                width: 50,
                                                fit: BoxFit.cover,
                                                radius: 8,
                                              ),
                                              12.width,

                                              /// Service Details
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(service.serviceName.validate(), style: boldTextStyle(size: 14)),
                                                    4.height,
                                                    Text('${durationToString(service.durationMin.validate())}', style: secondaryTextStyle(size: 12)),
                                                  ],
                                                ),
                                              ),

                                              /// Price
                                              PriceWidget(price: service.servicePrice.validate(), color: primaryColor, size: 14),
                                            ],
                                          ),
                                        ),
                                      ),

                                      /// Bottom padding
                                      SizedBox(height: 8),
                                    ],
                                  ),
                                );
                              },
                              child: Text(
                                "+${bookingData.serviceList!.length - 1} ${locale.more}",
                                style: TextStyle(
                                  fontSize: 12,
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
            ).paddingOnly(left: 16, right: 16, top: 16),

            /// --- BOOKING INFO SECTION ---
            Container(
              padding: EdgeInsets.only(left: 16, right: 16, top: 16),
              decoration: boxDecorationWithRoundedCorners(
                backgroundColor: context.cardColor,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Booking Info Header
                  Text(
                    locale.bookingInfo,
                    style: secondaryTextStyle(size: 12),
                  ),
                  8.height,

                  /// Booking Info Card
                  Container(
                    decoration: boxDecorationWithRoundedCorners(
                      backgroundColor: context.scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: borderColor, width: 0.5),
                    ),
                    padding: EdgeInsets.all(12),
                    child: Column(
                      children: [
                        /// Specialist
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.person_outline, size: 16, color: context.iconColor),
                                4.width,
                                Text(locale.specialist, style: secondaryTextStyle(size: 12)),
                              ],
                            ),
                            Text(bookingData.employeeName.validate(), style: boldTextStyle(size: 12)),
                          ],
                        ),
                        12.height,

                        /// Booking Status
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.calendar_month, size: 16, color: context.iconColor),
                                4.width,
                                Text(locale.bookingStatus, style: secondaryTextStyle(size: 12)),
                              ],
                            ),
                            Text(
                              getBookingStatusKey(status: bookingData.status.validate()),
                              style: boldTextStyle(size: 12, color: getBookingStatusColor(status: bookingData.status.validate())),
                            ),
                          ],
                        ),
                        12.height,

                        /// Payment Status
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.monetization_on_outlined, size: 16, color: context.iconColor),
                                4.width,
                                Text(locale.paymentStatus, style: secondaryTextStyle(size: 12)),
                              ],
                            ),
                            Text(
                              bookingData.payment?.paymentStatus == 1 ? locale.paid : locale.unpaid,
                              style: boldTextStyle(size: 12, color: bookingData.payment?.paymentStatus == 1 ? Colors.green : accentOrangeColor),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            if (bookingData.status == BookingStatusConst.PENDING)
              Padding(
                padding: EdgeInsets.only(left: 16, right: 16, top: 6),
                child: Transform.translate(
                  offset: Offset(0, 3),
                  child: AppButton(
                    text: locale.cancelAppointment,
                    padding: EdgeInsets.zero,
                    height: 40,
                    width: context.width(),
                    shapeBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    textColor: Colors.white,
                    color: primaryColor,
                    textStyle: boldTextStyle(size: 12, color: Colors.white),
                    elevation: 0,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) {
                          return Dialog(
                            backgroundColor: context.cardColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            child: CancelBookingDialog(
                              onConfirm: (cancelReason) {
                                Map req = {
                                  'id': bookingData.id,
                                  'status': BookingStatusConst.CANCELLED,
                                  'cancel_reason': cancelReason,
                                };
                  
                                appStore.setLoading(true);
                  
                                bookingUpdate(req).then((value) {
                                  onBookingListUpdate.call('');
                                  appStore.setLoading(false);
                                  ShowToast.showSuccess(locale.bookingSuccessfullyUpdateMessage);
                                }).catchError((e) {
                                  appStore.setLoading(false);
                                  ShowToast.showError(e.toString());
                                });
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),

            /// --- RATING SECTION ---
            if (bookingData.status == BookingStatusConst.COMPLETED && bookingData.payment?.paymentStatus == 1)
              Container(
                margin: EdgeInsets.only(left: 16, right: 16, top: 16),
                padding: EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 10),
                decoration: boxDecorationWithRoundedCorners(
                  backgroundColor: appStore.isDarkMode ? darkSecondaryColor : territoryButtonColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: context.dividerColor, width: 1),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      locale.yourRatingHelpsUsGrow + "!",
                      style: boldTextStyle(size: 12),
                    ),
                    InkWell(
                      onTap: () async {
                        final customerReview = await getBookingDetails();
                        AddReviewDialog.show(
                          context,
                          customerReview: customerReview,
                          staffId: bookingData.employeeId,
                        );
                      },
                      child: Text(
                        locale.rateUs,
                        style: TextStyle(
                          fontSize: 12,
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
              ),
            16.height,
          ],
        ),
      ),
    );
  }
}
