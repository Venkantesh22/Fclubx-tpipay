import 'package:flutter/material.dart';
import 'package:frezka/components/cached_image_widget.dart';
import 'package:frezka/components/rating_widget.dart';
import 'package:frezka/screens/branch/view/branch_detail_screen.dart';
import 'package:frezka/utils/colors.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../main.dart';
import '../../../utils/app_common.dart';
import '../../branch/model/branch_response.dart';

class BranchItemComponent extends StatefulWidget {
  final BranchData branchData;
  final int? selectedBranchId;
  final int? currentBranchIndex;
  final bool isFormSignIn;
  final bool isNearYou;
  final Position? position;

  BranchItemComponent({
    super.key,
    required this.branchData,
    this.selectedBranchId,
    this.currentBranchIndex,
    this.isFormSignIn = false,
    this.isNearYou = false,
    this.position,
  });

  @override
  State<BranchItemComponent> createState() => _BranchItemComponentState();
}

class _BranchItemComponentState extends State<BranchItemComponent> {
  double? cardSize;

  @override
  void initState() {
    super.initState();
  }

  double get getDistance {
    if (widget.position == null) return 0;
    if (widget.branchData.latitude == null || widget.branchData.longitude == null) return 0;

    return calculateDistance(
      widget.branchData.latitude!.toDouble(),
      widget.branchData.longitude!.toDouble(),
      widget.position!.latitude,
      widget.position!.longitude,
    );
  }

  bool get isBranchOpen {
    if (widget.branchData.todayTime == null) return false;

    final branchStatus = getBranchIsOpen(
      startTime: widget.branchData.todayTime!.startTime.validate(),
      endTime: widget.branchData.todayTime!.endTime.validate(),
      isHoliday: widget.branchData.todayTime!.isHoliday.validate().getBoolInt(),
      isFestival: widget.branchData.todayTime!.isFestival.validate().getBoolInt(),
    );

    return branchStatus.$2 == Colors.green;
  }

  String get branchStatusText {
    if (widget.branchData.todayTime == null) return locale.closed;

    final branchStatus = getBranchIsOpen(
      startTime: widget.branchData.todayTime!.startTime.validate(),
      endTime: widget.branchData.todayTime!.endTime.validate(),
      isHoliday: widget.branchData.todayTime!.isHoliday.validate().getBoolInt(),
      isFestival: widget.branchData.todayTime!.isFestival.validate().getBoolInt(),
    );

    return branchStatus.$1.validate();
  }

  @override
  Widget build(BuildContext context) {
    final isSelected = widget.currentBranchIndex == widget.selectedBranchId;

    if (widget.isNearYou) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: borderColor, width: 0.5),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildThumbnailImage(),
            _buildContentSection(),
          ],
        ),
      );
    } else {
      return AnimatedContainer(
        duration: Duration(milliseconds: 100),
        margin: EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isSelected ? context.primaryColor.withValues(alpha: 0.1) : context.cardColor,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: isSelected ? context.primaryColor : borderColor, width: 0.5),
        ),
        child: Stack(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildThumbnailImage(),
                _buildContentSection(),
                _buildSelectionIndicator(),
              ],
            ),
          ],
        ),
      );
    }
  }

  Widget _buildThumbnailImage() {
    return Container(
      width: 70,
      height: 70,
      margin: EdgeInsets.all(10),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedImageWidget(url: widget.branchData.branchImg.validate(), width: 70, height: 70, fit: BoxFit.cover, child: Icon(Icons.photo, color: grey.withAlpha(150),),),
      ).onTap(() {
        BranchDetailScreen(branchId: widget.branchData.id.validate()).launch(context);
      }, highlightColor: Colors.transparent, hoverColor: Colors.transparent, splashColor: Colors.transparent),
    );
  }

  Widget _buildContentSection() {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.only(top: 12, right: 12, bottom: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTagsRow(),
            6.height,
            _buildSalonName(),
            4.height,
            _buildAddressAndDistanceRow(),
            if (widget.position != null) ...[
              8.height,
              Text('${locale.kmAway(getDistance.toStringAsFixed(1))}', style: boldTextStyle(size: 10), textAlign: TextAlign.right),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTagsRow() {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        _buildStatusTag(),
        RatingWidget(rating: widget.branchData.ratingStar.validate().toDouble(), showRatingNumber: true, ratingNumberSize: 10, maxStars: 1),
        _buildTypeTag(),
      ],
    );
  }

  Widget _buildStatusTag() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isBranchOpen ? successColor : redColor,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Text(
        branchStatusText,
        style: secondaryTextStyle(color: Colors.white, size: 10),
      ),
    );
  }

  Widget _buildTypeTag() {
    final isSelected = widget.currentBranchIndex == widget.selectedBranchId;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : primaryLightColor,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: borderColor, width: 0.5),
      ),
      child: Text(
        widget.branchData.branchFor.validate().toUpperCase(),
        style: primaryTextStyle(
          size: 10,
          weight: FontWeight.w700,
          color: appTextSecondaryColor,
        ),
      ),
    );
  }

  Widget _buildSalonName() {
    final isSelected = widget.currentBranchIndex == widget.selectedBranchId;
    return Text(
      widget.branchData.name.validate(),
      style: boldTextStyle(
        size: 15,
        weight: isSelected ? FontWeight.bold : FontWeight.w700,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildAddressAndDistanceRow() {
    return Marquee(
      child: Text(
        '${widget.branchData.addressLine1.validate()}, ${widget.branchData.city.validate()}, ${widget.branchData.state.validate()}, ${widget.branchData.country.validate()}',
        style: secondaryTextStyle(size: 11),
        maxLines: 2,
        overflow: TextOverflow.visible,
      ),
    );
  }

  Widget _buildSelectionIndicator() {
    final isSelected = widget.currentBranchIndex == widget.selectedBranchId;

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: isSelected ? context.primaryColor : borderColor, width: 1),
        ),
        child: isSelected
            ? Center(
                child: Container(width: 10, height: 10, decoration: BoxDecoration(color: context.primaryColor, shape: BoxShape.circle)),
              )
            : null,
      ),
    ).paddingAll(14);
  }
}
