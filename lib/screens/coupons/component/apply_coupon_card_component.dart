import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frezka/components/price_widget.dart';
import 'package:frezka/main.dart';
import 'package:frezka/utils/colors.dart';
import 'package:frezka/utils/custom_toast_widget.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';

class ApplyCouponCardComponent extends StatelessWidget {
  final String? couponCode;
  final String? couponAmount;
  final String? couponDescription;
  final bool? isFixedCoupon;
  final String? expiryDate;
  final Function(String)? onApply;
  final bool isApplied;

  const ApplyCouponCardComponent({super.key, this.couponAmount, this.couponCode, this.isFixedCoupon, this.expiryDate, this.onApply, this.isApplied = false, this.couponDescription});

  String _formatExpiryDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMMM dd, yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.only(bottom: 16),
      decoration: boxDecorationWithRoundedCorners(
        backgroundColor: context.dividerColor.withAlpha(20),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: context.dividerColor, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and Description Section
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Discount Title
              Text(
                isFixedCoupon == false ? "${couponAmount.validate()}% ${locale.off.toUpperCase()}" : "${leftCurrencyFormat()}${couponAmount.validate()}${rightCurrencyFormat()} ${locale.off.toUpperCase()}",
                style: boldTextStyle(size: 16),
              ),
              2.height,
              // Description
              if (couponDescription.validate().isNotEmpty)
                Text(
                  couponDescription.validate(),
                  style: secondaryTextStyle(size: 12),
                ),
            ],
          ),
          18.height,
          // Coupon Code Section
          Container(
            decoration: BoxDecoration(
              color: appStore.isDarkMode ? darkSecondaryColor : primaryLightColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: CustomPaint(
              painter: DashedBorderPainter(color: context.dividerColor, strokeWidth: 0.5, borderRadius: 4, dashWidth: 5.0, dashSpace: 3.0),
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        couponCode.validate().toUpperCase(),
                        style: boldTextStyle(size: 12),
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        await Clipboard.setData(ClipboardData(text: couponCode.validate().toUpperCase()));
                        ShowToast.showSuccess(locale.couponCodeCopied);
                      },
                      child: Icon(
                        Icons.copy_outlined,
                        size: 20,
                        color: iconColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          16.height,
          // Validity and Apply Button Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Validity Date
              if (expiryDate.validate().isNotEmpty)
                Expanded(
                  child: Text(
                    "${locale.validUntil} ${_formatExpiryDate(expiryDate)}",
                    style: secondaryTextStyle(size: 12),
                  ),
                )
              else
                Spacer(),
              24.width,
              // Apply Button
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: TextButton(
                  onPressed: () async {
                    onApply?.call(couponCode.validate());
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    isApplied ? locale.applied : locale.apply,
                    style: boldTextStyle(
                      size: 12,
                      height: 1.83,
                      letterSpacing: -0.01,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double borderRadius;
  final double dashWidth;
  final double dashSpace;

  DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.borderRadius,
    this.dashWidth = 5.0,
    this.dashSpace = 3.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    final halfStroke = strokeWidth / 2;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(halfStroke, halfStroke, size.width - strokeWidth, size.height - strokeWidth),
      Radius.circular(borderRadius),
    );

    // Draw dashed border
    final path = Path()..addRRect(rrect);
    final pathMetrics = path.computeMetrics();

    for (final pathMetric in pathMetrics) {
      double distance = 0;
      while (distance < pathMetric.length) {
        final length = (distance + dashWidth < pathMetric.length) ? dashWidth : pathMetric.length - distance;
        final extractPath = pathMetric.extractPath(distance, distance + length);
        canvas.drawPath(extractPath, paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
