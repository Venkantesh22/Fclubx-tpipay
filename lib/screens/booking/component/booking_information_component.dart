import 'package:flutter/material.dart';
import 'package:frezka/components/view_all_label_component.dart';
import 'package:frezka/generated/assets.dart';
import 'package:frezka/screens/booking/component/booking_step2_component.dart';
import 'package:frezka/screens/booking/component/customer_review_component.dart';
import 'package:frezka/screens/services/models/service_response.dart';
import 'package:frezka/utils/common_base.dart';
import 'package:frezka/utils/extensions/string_extensions.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../components/cached_image_widget.dart';
import '../../../main.dart';
import '../../../utils/app_common.dart';
import '../../../utils/colors.dart';
import '../../../utils/constants.dart';
import '../model/booking_list_response.dart';
import '../../branch/view/branch_detail_screen.dart';
import '../../experts/view/employee_detail_screen.dart';

class BookingInformationComponent extends StatefulWidget {
  final BookingListData booking;
  final String? bookingStatus;
  final List<ServiceListData> serviceList;

  BookingInformationComponent({required this.booking, this.bookingStatus, required this.serviceList});

  @override
  State<BookingInformationComponent> createState() => _BookingInformationComponentState();
}

class _BookingInformationComponentState extends State<BookingInformationComponent> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomerReviewComponent(
          booking: widget.booking,
          bookingStatus: widget.booking.status,
          staffId: widget.booking.employeeId,
          customerReview: widget.booking.customerReview,
          employeeName: widget.booking.employeeName.validate(),
        ),
        ViewAllLabel(
          label: locale.slonAndBookingDetail,
          trailingText: locale.change,
          trailingTextColor: lightPrimaryColor,
          isShowAll: widget.booking.statusLabel == BookingStatusConst.PENDING[0].toUpperCase() + BookingStatusConst.PENDING.substring(1),
          onTap: () {
            BookingStep2Component(
              selectedDate: widget.booking.bookingDate,
              selectedTime: widget.booking.bookingTime,
              isFromBookingInfoDetail: true,
              bookingId: widget.booking.id,
              employeeId: widget.booking.employeeId,
              serviceList: widget.serviceList,
            ).launch(context , pageRouteAnimation: PageRouteAnimation.Fade);
          },
        ),
        Container(
          decoration: BoxDecoration(
            color: context.cardColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor, width: 0.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Salon Header
              Container(
                decoration: BoxDecoration(
                  color: appStore.isDarkMode ? darkSecondaryColor : primaryLightColor,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
                ),
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    CachedImageWidget(
                      url: widget.booking.branchImage.validate(),
                      height: 55,
                      width: 55,
                      fit: BoxFit.cover,
                      radius: 6,
                    ),
                    12.width,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.booking.branchName.validate(), style: boldTextStyle(size: 14)),
                        4.height,
                        Text(widget.booking.addressLine1.validate(), style: secondaryTextStyle(size: 12)),
                      ],
                    ).expand(),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: successDarkColor,
                          child: Assets.iconsIcCall.iconImage(color: white, size: 18),
                        ).onTap(() {
                          launchCall(appStore.branchContactNumber);
                        }),
                        8.width,
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: context.primaryColor,
                          child: Assets.iconsIcMessage.iconImage(color: white, size: 18),
                        ).onTap(() {
                          commonLaunchUrl('mailto:${widget.booking.branchEmail.validate()}', launchMode: LaunchMode.externalApplication);
                        }),
                      ],
                    )
                  ],
                ).onTap(() {
                  if (widget.booking.branchId.validate() != 0) {
                    BranchDetailScreen(branchId: widget.booking.branchId.validate()).launch(context, pageRouteAnimation: PageRouteAnimation.Fade);
                  }
                }),
              ),

              // About Booking Title + Status
              Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      locale.aboutBooking.split(' ').map((word) => word.isNotEmpty ? word[0].toUpperCase() + word.substring(1).toLowerCase() : '').join(' '),
                      style: primaryTextStyle(
                        size: 14,
                        weight: FontWeight.w600,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      decoration: boxDecorationWithRoundedCorners(
                        backgroundColor: getBookingStatusColor(status: widget.booking.status.validate()).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: getBookingStatusColor(status: widget.booking.status.validate()), width: 1),
                      ),
                      child: Text(
                        widget.booking.statusLabel.validate().split(' ').map((word) => word.isNotEmpty ? word[0].toUpperCase() + word.substring(1).toLowerCase() : '').join(' '),
                        style: primaryTextStyle(
                          size: 12,
                          weight: FontWeight.w600,
                          color: getBookingStatusColor(status: widget.booking.status.validate()),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Booking Info Items
              Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date & Time
                    _infoTile(
                      icon: Icons.calendar_month_outlined,
                      title: locale.dateTime,
                      value: '${widget.booking.bookingDate} ${locale.lblAt.toPascalCase()} ${widget.booking.bookingTime}',
                    ),
                    10.height,

                    // Payment Status
                    if (widget.booking.payment != null) ...[
                      _infoTile(
                        icon: Icons.payment_outlined,
                        title: locale.paymentStatus,
                        value: widget.booking.payment!.paymentStatus == 1 ? locale.paid : locale.unpaid,
                        valueColor: widget.booking.payment!.paymentStatus == 1 ? successDarkColor : Colors.red,
                      ),
                      10.height,
                    ],

                    // Specialist
                    _infoTile(
                      title: locale.specialist,
                      value: widget.booking.employeeName.validate().toPascalCase(),
                      imageUrl: widget.booking.employeeImage.validate(),
                      onTap: () {
                        if (widget.booking.employeeId.validate() != 0) {
                          EmployeeDetailScreen(branchId: widget.booking.branchId.validate(), employeeId: widget.booking.employeeId.validate()).launch(context, pageRouteAnimation: PageRouteAnimation.Fade);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (widget.booking.note.validate().isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              24.height,
              Text(locale.serviceNote, style: boldTextStyle(size: LABEL_TEXT_SIZE)),
              8.height,
              Container(
                decoration: boxDecorationDefault(color: context.cardColor),
                padding: EdgeInsets.all(16),
                width: context.width(),
                child: ReadMoreText(widget.booking.note.validate(), style: primaryTextStyle(), textAlign: TextAlign.justify, colorClickableText: primaryColor),
              ),
            ],
          ),
      ],
    );
  }

  Widget _infoTile({
    IconData? icon,
    required String title,
    required String value,
    Color? valueColor,
    String? imageUrl,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 0),
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          imageUrl != null
              ? ClipOval(
                  child: CachedImageWidget(
                    url: imageUrl,
                    height: 44,
                    width: 44,
                    fit: BoxFit.cover,
                  ),
                )
              : Container(
                  padding: EdgeInsets.all(10),
                  height: 44,
                  width: 44,
                  decoration: BoxDecoration(
                    color: icon == Icons.calendar_month_outlined ? primaryLightColor : (icon == Icons.payment_outlined ? lightGreenColor : primaryLightColor),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: icon == Icons.calendar_month_outlined ? primaryColor : (icon == Icons.payment_outlined ? successDarkColor : primaryColor),
                    size: 16,
                  ),
                ),
          20.width,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.split(' ').map((word) => word.isNotEmpty ? word[0].toUpperCase() + word.substring(1).toLowerCase() : '').join(' '),
                  style: secondaryTextStyle(
                    size: 12,
                  ),
                ),
                0.height,
                Text(
                  value,
                  style: primaryTextStyle(
                    size: 14,
                    weight: FontWeight.w600,
                    color: valueColor ?? appTextSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ).onTap(() {
        onTap?.call();
      }, borderRadius: BorderRadius.circular(12)),
    );
  }
}
