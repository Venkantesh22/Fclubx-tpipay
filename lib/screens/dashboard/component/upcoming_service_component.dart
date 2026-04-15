import 'package:flutter/material.dart';
import 'package:frezka/components/view_all_label_component.dart';
import 'package:frezka/main.dart';
import 'package:frezka/utils/common_base.dart';
import 'package:frezka/utils/custom_toast_widget.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../components/cached_image_widget.dart';
import '../../../components/cancel_booking_dialogue.dart';
import '../../../components/price_widget.dart';
import '../../../utils/colors.dart';
import '../../../utils/constants.dart';
import '../../booking/booking_repository.dart';
import '../../booking/view/booking_detail_screen.dart';
import '../../booking/view/view_all_upcoming_bookings_screen.dart';
import '../models/upcoming_service_model.dart';

class UpcomingServiceComponent extends StatefulWidget {
  final List<UpcomingBooking> bookingData;
  final bool showViewAllLabel;

  UpcomingServiceComponent({required this.bookingData, this.showViewAllLabel = true});

  @override
  State<UpcomingServiceComponent> createState() => _UpcomingServiceComponentState();
}

class _UpcomingServiceComponentState extends State<UpcomingServiceComponent> {
  bool showBookingInfo = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showViewAllLabel)
          ViewAllLabel(
              label: locale.upcomingBooking,
              onTap: () {
                ViewAllUpcomingBookingsScreen().launch(context);
              }).paddingOnly(left: 16, right: 16),
        ListView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.only(bottom: 8, left: 8, right: 8),
          physics: NeverScrollableScrollPhysics(),
          itemCount: widget.bookingData.length,
          itemBuilder: (context, index) {
            final booking = widget.bookingData[index];

            return InkWell(
              onTap: () {
                hideKeyboard(context);
                BookingDetailScreen(
                  bookingId: booking.id.validate(),
                  bookingStatus: booking.status.validate(),
                ).launch(context);
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: context.width(),
                margin: EdgeInsets.only(bottom: 8, left: 8, right: 8),
                decoration: boxDecorationWithRoundedCorners(backgroundColor: context.cardColor, border: Border.all(color: borderColor, width: 0.5)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                                    child: Text("#${booking.id.validate()}", style: boldTextStyle(size: 12), overflow: TextOverflow.ellipsis),
                                  ),
                                ],
                              ),
                              2.height,
                              Row(
                                children: [
                                  Text(locale.dateTime + ": ", style: secondaryTextStyle(size: 12)),
                                  Expanded(
                                    child: Text(booking.startDateTime.validate(), style: boldTextStyle(size: 12), overflow: TextOverflow.ellipsis),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        /// Right side: Price
                        PriceWidget(price: booking.sumOfServicePrices.validate(), color: primaryColor, size: 14),
                      ],
                    ).paddingAll(16),
                    Divider(color: context.dividerColor, height: 0).paddingSymmetric(horizontal: 16),
                    12.height,

                    /// --- SERVICE SECTION ---
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          /// Service Image
                          CachedImageWidget(url: booking.services.validate().isNotEmpty ? booking.services.first.serviceImage.validate() : '', height: 60, width: 60, fit: BoxFit.cover, radius: defaultRadius),
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
                                    booking.packages.isNotEmpty ? locale.package : booking.branchName.validate(),
                                    style: boldTextStyle(size: 10, color: appTextSecondaryColor),
                                  ),
                                ),
                                9.height,

                                /// Service Name
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        booking.services.validate().isNotEmpty
                                            ? booking.services.first.serviceName.validate()
                                            : booking.packages.isNotEmpty
                                                ? "${locale.package}"
                                                : "",
                                        style: boldTextStyle(size: 14),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (booking.services.validate().isNotEmpty && booking.services.length > 1)
                                      InkWell(
                                        onTap: () {
                                          showModalBottomSheet(
                                            context: context,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                                            ),
                                            builder: (_) {
                                              return Container(
                                                padding: EdgeInsets.all(20),
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    /// Header with close button
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Text(
                                                          locale.yourBookedServices,
                                                          style: boldTextStyle(size: 18, color: Colors.black),
                                                        ),
                                                        GestureDetector(
                                                          onTap: () => Navigator.pop(context),
                                                          child: Container(
                                                            width: 24,
                                                            height: 24,
                                                            decoration: BoxDecoration(
                                                              color: Colors.transparent,
                                                              shape: BoxShape.circle,
                                                              border: Border.all(color: context.iconColor.withValues(alpha: 0.4), width: 2),
                                                            ),
                                                            child: Icon(Icons.close, size: 16, color: context.iconColor.withValues(alpha: 0.4)),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    16.height,

                                                    /// Divider
                                                    Divider(color: context.dividerColor, height: 0).paddingSymmetric(horizontal: 16),
                                                    16.height,

                                                    /// Service List
                                                    ...booking.services.map(
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
                                                                  Text(service.serviceName.validate(), style: boldTextStyle(size: 14, color: Colors.black)),
                                                                  4.height,
                                                                  Text( '${durationToString(service.durationMin.validate())}', style: secondaryTextStyle(size: 12)),
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
                                          );
                                        },
                                        child: Text(
                                          "+${booking.services.length - 1} ${locale.more}",
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
                      ),
                    ),

                    2.height,

                    /// --- BOOKING INFO SECTION ---
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// Booking Info Header
                        Text(locale.bookingInfo, style: secondaryTextStyle(size: 12)),
                        8.height,

                        /// Booking Info Card
                        Container(
                          decoration: boxDecorationDefault(
                            color: context.scaffoldBackgroundColor,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: context.dividerColor, width: 1),
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
                                  Text(booking.employeeName.validate(), style: boldTextStyle(size: 12)),
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
                                    getBookingStatusKey(status: booking.status.validate()),
                                    style: boldTextStyle(size: 12, color: getBookingStatusColor(status: booking.status.validate())),
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
                                    booking.payment.paymentStatus == 1 ? locale.paid : locale.unpaid,
                                    style: boldTextStyle(size: 12, color: booking.payment.paymentStatus == 1 ? Colors.green : Color(0xFFF79E00)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ).paddingAll(16),
                    if (booking.status == BookingStatusConst.PENDING && (booking.payment.paymentStatus != 1))
                      AppButton(
                        text: locale.cancelAppointment,
                        margin: EdgeInsets.symmetric(horizontal: 16),
                        padding: EdgeInsets.symmetric(vertical: 6),
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
                                      'id': booking.id,
                                      'status': BookingStatusConst.CANCELLED,
                                      'cancel_reason': cancelReason,
                                    };
                    
                                    appStore.setLoading(true);
                    
                                    bookingUpdate(req).then((value) {
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

                    8.height,
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
