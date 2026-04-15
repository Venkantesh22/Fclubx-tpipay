import 'package:flutter/material.dart';
import 'package:frezka/components/common_bottom_sheet.dart';
import 'package:frezka/main.dart';
import 'package:frezka/screens/package/component/package_card.dart';
import 'package:frezka/screens/package/model/package_list_model.dart';
import 'package:frezka/utils/colors.dart';
import 'package:nb_utils/nb_utils.dart';

class PackageBottomSheetComponent extends StatefulWidget {
  final ScrollController? scrollController;
  final PackageListData package;
  final VoidCallback? onPurchase;
  final bool isPurchased;

  const PackageBottomSheetComponent({super.key, this.onPurchase, this.scrollController, required this.package, required this.isPurchased});

  /// Show package details bottom sheet
  static Future<void> show(
    BuildContext context, {
    required PackageListData package,
    VoidCallback? onPurchase,
    required bool isPurchased,
  }) {
    return CommonBottomSheet.show(
      context,
      title: locale.packageDetail,
      child: PackageBottomSheetComponent(
        package: package,
        onPurchase: onPurchase,
        isPurchased: isPurchased,
      ),
    );
  }

  @override
  State<PackageBottomSheetComponent> createState() => _PackageBottomSheetComponentState();
}

class _PackageBottomSheetComponentState extends State<PackageBottomSheetComponent> {
  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      final DateTime endDate = DateTime.parse(widget.package.endDate.validate());
      final DateTime today = DateTime.now();
      final bool isActive = !endDate.isBefore(DateTime(today.year, today.month, today.day));
      final bool hasRemainingQty = widget.package.services.any((s) => s.remainingQty == null || s.remainingQty! > 0);
      final bool canReclaim = isActive && (widget.isPurchased || hasRemainingQty) && hasRemainingQty;

      return PackageCard(
        package: widget.package,
        cardColor: primaryLightColor,
        isSelected: true,
        onPurchase: () {
          widget.onPurchase?.call();
        },
        showPurchaseButton: !canReclaim,
        showReclaimButton: canReclaim,
        isPurchased: widget.isPurchased || canReclaim,
      );
    });
  }
}
