import 'package:flutter/material.dart';
import 'package:frezka/components/cached_image_widget.dart';
import 'package:frezka/configs.dart';
import 'package:frezka/main.dart';
import 'package:frezka/screens/branch/model/branch_response.dart';
import 'package:frezka/utils/app_common.dart';
import 'package:frezka/utils/colors.dart';
import 'package:frezka/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../components/status_widget.dart';

class BranchInformationComponent extends StatefulWidget {
  final BranchData branchData;

  BranchInformationComponent({required this.branchData});

  @override
  State<BranchInformationComponent> createState() => _BranchInformationComponentState();
}

class _BranchInformationComponentState extends State<BranchInformationComponent> {
  @override
  void initState() {
    super.initState();
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
        // Salon name with UNISEX tag
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      widget.branchData.name.validate(),
                      style: boldTextStyle(size: 18),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  8.width,
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: boxDecorationDefault(
                      color: primaryLightColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.branchData.branchFor.validate().capitalizeFirstLetter(),
                      style: primaryTextStyle(color: appTextSecondaryColor, size: 12),
                    ),
                  ),
                  6.width,
                  if (widget.branchData.todayTime != null)
                    StatusWidget(
                      text: getBranchIsOpen(
                              startTime: widget.branchData.todayTime!.startTime.validate(),
                              endTime: widget.branchData.todayTime!.endTime.validate(),
                              isHoliday: widget.branchData.todayTime!.isHoliday.validate().getBoolInt(),
                              isFestival: widget.branchData.todayTime!.isFestival.validate().getBoolInt())
                          .$1
                          .validate(),
                      color: getBranchIsOpen(
                              startTime: widget.branchData.todayTime!.startTime.validate(),
                              endTime: widget.branchData.todayTime!.endTime.validate(),
                              isHoliday: widget.branchData.todayTime!.isHoliday.validate().getBoolInt(),
                              isFestival: widget.branchData.todayTime!.isFestival.validate().getBoolInt())
                          .$2,
                    ),
                ],
              ),
            ),
              10.width,
            // Share button
            GestureDetector(
              onTap: () async {
                SharePlus.instance.share(ShareParams(uri: Uri.parse('$DOMAIN_URL/branch-detail/${widget.branchData.id}')));
              },
              child: Container(
                padding: EdgeInsets.all(6),
                decoration: boxDecorationDefault(shape: BoxShape.circle, color: appStore.isDarkMode ? context.cardColor : primaryLightColor, border: Border.all(color: borderColor, width: 0.5)),
                child: CachedImageWidget(url: ic_ShareFat, height: 18, width: 18),
              ),
            ),
          ],
        ),
        12.height,
        // Rating section
        Row(
          children: [
            Row(
              children: List.generate(5, (index) {
                if (index < widget.branchData.ratingStar.validate().floor()) {
                  return Icon(Icons.star, size: 18, color: ratingBarColor);
                } else if (index < widget.branchData.ratingStar.validate()) {
                  return Icon(Icons.star_half, size: 18, color: ratingBarColor);
                } else {
                  return Icon(Icons.star_border, size: 18, color: ratingBarColor);
                }
              }),
            ),
            8.width,
            Text(
              widget.branchData.ratingStar.validate().toStringAsFixed(1),
              style: boldTextStyle(size: 14),
            ),
            if (widget.branchData.totalReview.validate() >= 1)
              Text(
                '(${widget.branchData.totalReview.validate()} ${locale.review}${widget.branchData.totalReview.validate() > 1 ? '${locale.s}' : ''})',
                style: secondaryTextStyle(size: 14),
              ).paddingLeft(4),
          ],
        ),
        12.height,
        // Address section
        if (widget.branchData.addressLine1.validate().isNotEmpty)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.location_on_outlined, size: 18, color: iconColor),
              12.width,
              Expanded(
                child: Text(
                  '${widget.branchData.addressLine1.validate()}, ${widget.branchData.city.validate()}, ${widget.branchData.country.validate()}',
                  style: secondaryTextStyle(size: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              GestureDetector(
                onTap: () {
                  commonLaunchUrl('https://www.google.com/maps/search/?api=1&query=${widget.branchData.latitude},${widget.branchData.longitude}', launchMode: LaunchMode.externalApplication);
                },
                child: Text(
                  locale.direction,
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
        8.height,
        // Phone section
        GestureDetector(
          onTap: () {
            launchCall(appStore.branchContactNumber);
          },
          child: Row(
            children: [
              Icon(Icons.phone_outlined, size: 18, color: iconColor),
              12.width,
              Text(
                widget.branchData.contactNumber.validate(),
                style: secondaryTextStyle(size: 14),
              ),
            ],
          ),
        ),
        8.height,
        // Email section
        GestureDetector(
          onTap: () {
            if (widget.branchData.contactEmail.validate().isNotEmpty) {
              commonLaunchUrl('mailto:${widget.branchData.contactEmail.validate()}', launchMode: LaunchMode.externalApplication);
            }
          },
          child: Row(
            children: [
              Icon(Icons.email_outlined, size: 18, color: iconColor),
              12.width,
              Text(
                widget.branchData.contactEmail.validate(),
                style: secondaryTextStyle(
                  decoration: TextDecoration.underline,
                  size: 14,
                ),
              ),
            ],
          ),
        ),
        10.height,
      ],
    ).paddingSymmetric(vertical: 16);
  }
}
