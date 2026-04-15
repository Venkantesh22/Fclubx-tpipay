import 'package:flutter/material.dart';
import 'package:frezka/components/view_all_label_component.dart';
import 'package:frezka/main.dart';
import 'package:frezka/utils/colors.dart';
import 'package:frezka/utils/custom_toast_widget.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:url_launcher/url_launcher.dart';
import '../model/order_detail_response.dart';

class LogisticPartnerComponent extends StatelessWidget {
  final OrderListData orderData;

  LogisticPartnerComponent({required this.orderData});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ViewAllLabel(label: locale.logisticPartner, isShowAll: false, labelSize: 16),
        4.height,
        Container(
          width: context.width(),
          decoration: boxDecorationDefault(
            color: context.cardColor,
            borderRadius: radius(4),
            border: Border.all(color: borderColor, width: 0.5),
          ),
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              // Logistic Partner Logo/Icon
              Container(
                width: 40,
                height: 40,
                decoration: boxDecorationWithRoundedCorners(
                  backgroundColor: _getLogisticColor(),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: _getLogisticIcon(),
                ),
              ),
              16.width,
              // Logistic Partner Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getLogisticName(),
                      style: boldTextStyle(size: 16),
                    ),
                    4.height,
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: context.iconColor,
                        ),
                        4.width,
                        Expanded(
                          child: Text(
                            _getLogisticLocation(),
                            style: secondaryTextStyle(size: 14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (_getLogisticContact().isNotEmpty) ...[
                      4.height,
                      Row(
                        children: [
                          Icon(
                            Icons.phone_outlined,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          4.width,
                          Text(
                            _getLogisticContact(),
                            style: secondaryTextStyle(size: 12),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              // Call Button
              if (_getLogisticContact().isNotEmpty)
                GestureDetector(
                  onTap: () {
                    _makeCall(_getLogisticContact());
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: boxDecorationWithRoundedCorners(
                      backgroundColor: Colors.green,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.phone,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  String _getLogisticName() {
    String name = orderData.logisticName.validate();
    if (name.isEmpty) return locale.logisticPartner;
    return name.capitalizeFirstLetter();
  }

  String _getLogisticLocation() {
    if (orderData.logisticAddress.validate().isNotEmpty) {
      return orderData.logisticAddress.validate();
    }
    return locale.locationNotAvailable;
  }

  String _getLogisticContact() {
    return orderData.logisticContact.validate();
  }

  Color _getLogisticColor() {
    String name = orderData.logisticName.validate().toLowerCase();
    if (name.contains('fedex')) return Colors.purple;
    if (name.contains('dhl')) return Colors.red;
    if (name.contains('ups')) return Colors.brown;
    if (name.contains('amazon')) return Colors.orange;
    return Colors.blue;
  }

  Widget _getLogisticIcon() {
    String name = orderData.logisticName.validate().toLowerCase();
    if (name.contains('fedex')) {
      return Text(
        'FX',
        style: boldTextStyle(
          size: 14,
          color: Colors.white,
        ),
      );
    }
    if (name.contains('dhl')) {
      return Text(
        'DH',
        style: boldTextStyle(
          size: 14,
          color: Colors.white,
        ),
      );
    }
    if (name.contains('ups')) {
      return Text(
        'UP',
        style: boldTextStyle(
          size: 14,
          color: Colors.white,
        ),
      );
    }
    if (name.contains('amazon')) {
      return Text(
        'AZ',
        style: boldTextStyle(
          size: 14,
          color: Colors.white,
        ),
      );
    }

    // Default initials
    String initials = _getLogisticInitials();
    return Text(
      initials,
      style: boldTextStyle(
        size: 14,
        color: Colors.white,
      ),
    );
  }

  String _getLogisticInitials() {
    String name = orderData.logisticName.validate();
    if (name.isEmpty) return 'LP';

    List<String> words = name.split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    return name.substring(0, 1).toUpperCase();
  }

  void _makeCall(String phoneNumber) async {
    try {
      String cleanNumber = phoneNumber.replaceAll(RegExp(r'[\s\-\(\)]'), '');
      String phoneUrl = 'tel:$cleanNumber';
      if (await canLaunchUrl(Uri.parse(phoneUrl))) {
        await launchUrl(Uri.parse(phoneUrl));
      } else {
        ShowToast.showError(locale.cannotMakePhoneCallsOnThisDevice);
      }
    } catch (e) {
      ShowToast.showError('Error making call: $e');
    }
  }
}
