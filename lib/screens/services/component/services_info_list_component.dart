import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frezka/components/price_widget.dart';
import 'package:frezka/main.dart';
import 'package:frezka/utils/colors.dart';
import 'package:frezka/utils/common_base.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../components/cached_image_widget.dart';
import '../models/service_response.dart';

class ServicesInfoListComponent extends StatefulWidget {
  final ServiceListData serviceInfo;
  final Function() onPressed;
  final Function()? onServiceTap;

  ServicesInfoListComponent({required this.serviceInfo, required this.onPressed, this.onServiceTap});

  @override
  _ServicesInfoListComponentState createState() => _ServicesInfoListComponentState();
}

class _ServicesInfoListComponentState extends State<ServicesInfoListComponent> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  bool isAddOnExpanded = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));

    _animationController.forward();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String _formattedStaff() {
    final raw = widget.serviceInfo.staffCount.validate();
    final intCount = int.tryParse(raw.toString()) ?? 0;
    return intCount > 5 ? '${intCount.toString().padLeft(2, '0')}+' : intCount.toString().padLeft(2, '0');
  }

  Widget _infoItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: context.iconColor),
        SizedBox(width: 4),
        Text(text, style: secondaryTextStyle(size: 12)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: boxDecorationWithRoundedCorners(
                backgroundColor: context.cardColor,
                borderRadius: radius(6),
                border: Border.all(color: borderColor, width: 0.5),
              ),
              margin: EdgeInsets.only(bottom: 16),
              child: GestureDetector(
                onTap: widget.onServiceTap,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Main Content Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Service Image
                        Container(
                          width: 60,
                          height: 60,
                          decoration: boxDecorationWithRoundedCorners(
                            backgroundColor: context.cardColor,
                            borderRadius: radius(6),
                          ),
                          child: widget.serviceInfo.serviceImage.validate().isNotEmpty
                              ? CachedImageWidget(
                                  url: widget.serviceInfo.serviceImage.validate(),
                                  height: 60,
                                  width: 60,
                                  fit: BoxFit.cover,
                                  radius: 6,
                                )
                              : Icon(Icons.spa, color: context.iconColor, size: 30),
                        ),

                        SizedBox(width: 12),

                        // Service Details - Expanded to take available space
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Service Name and Action Button Row
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Service Name
                                  Expanded(
                                    child: Text(
                                      widget.serviceInfo.name.validate(),
                                      style: boldTextStyle(size: 16),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),

                                  SizedBox(width: 12),

                                  // Action Button
                                  GestureDetector(
                                    onTap: () {
                                      widget.onPressed.call();
                                      HapticFeedback.lightImpact();
                                    },
                                    child: AnimatedContainer(
                                      width: 90,
                                      height: 30,
                                      duration: Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                      decoration: boxDecorationWithRoundedCorners(
                                        backgroundColor: widget.serviceInfo.isServiceChecked ? quaternaryButtonSecondColor : territoryButtonColor,
                                        borderRadius: radius(4),
                                        border: Border.all(color: widget.serviceInfo.isServiceChecked ? redColor : indicatorColor, width: 1),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          if (widget.serviceInfo.isServiceChecked) ...[
                                            Icon(Icons.delete_outline, color: redColor, size: 14),
                                            SizedBox(width: 6),
                                            Text(
                                              locale.remove,
                                              style: secondaryTextStyle(color: redColor, size: 14),
                                            ),
                                          ] else ...[
                                            Text(
                                              '${locale.lblAdd} +',
                                              style: boldTextStyle(color: secondaryColor, size: 14),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 6),

                              // Price
                              PriceWidget(price: widget.serviceInfo.defaultPrice.validate(), color: context.primaryColor, size: 16),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 12),

                    // Info Items Row - Using Wrap for better responsiveness
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: [
                        _infoItem(Icons.access_time, ' ${durationToString(widget.serviceInfo.durationMin.validate().toInt())}'),
                        _infoItem(Icons.people, '${_formattedStaff()} ${locale.staff}'),
                        _infoItem(Icons.account_tree_rounded, '${widget.serviceInfo.branchCount.validate().toString().padLeft(2, '0')} ${locale.branches}'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
