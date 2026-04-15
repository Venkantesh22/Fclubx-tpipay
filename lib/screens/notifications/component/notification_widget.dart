import 'package:flutter/material.dart';
import 'package:frezka/components/cached_image_widget.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:html/parser.dart' as html_parser;

import '../../../utils/common_base.dart';
import '../../../utils/images.dart';
import '../model/notification_model.dart';

class NotificationWidget extends StatefulWidget {
  final NotificationData notificationData;

  NotificationWidget({required this.notificationData});

  @override
  State<NotificationWidget> createState() => _NotificationWidgetState();
}

class _NotificationWidgetState extends State<NotificationWidget> {
  bool _isExpanded = false;

  /// Function to parse HTML string and return plain text
  String parseHtmlString(String htmlString) {
    final document = html_parser.parse(htmlString);
    return document.body?.text ?? "";
  }

  Color _getBGColor(BuildContext context) {
    if (widget.notificationData.readAt != null) {
      return context.scaffoldBackgroundColor;
    } else {
      return context.cardColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final message = parseHtmlString(
      widget.notificationData.data?.notificationDetail?.message.validate() ?? "",
    );

    return Container(
      width: context.width(),
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: boxDecorationDefault(
        color: _getBGColor(context),
        borderRadius: radius(0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CachedImageWidget(url: ic_notification_user, height: 40, width: 40).cornerRadiusWithClipRRect(20),
          16.width,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    /// Type with marquee effect
                    Expanded(
                      child: SizedBox(
                        height: 20,
                        child: Marquee(
                          child: Text(widget.notificationData.data?.notificationDetail?.type.validate() ?? "", style: boldTextStyle(size: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                        ),
                      ),
                    ),
                    8.width,
                    Text(
                      formatDate(widget.notificationData.createdAt.validate(), isLocal: true),
                      style: secondaryTextStyle(size: 12),
                    ),
                  ],
                ),

                8.height,

                /// ID + Message
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.notificationData.data?.notificationDetail?.id != null)
                      Text(
                        "#${widget.notificationData.data!.notificationDetail!.id}",
                        style: secondaryTextStyle(size: 12),
                      ),
                    8.width,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AnimatedCrossFade(
                            firstChild: Text(
                              message,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: secondaryTextStyle(size: 14),
                            ),
                            secondChild: Text(
                              message,
                              style: secondaryTextStyle(size: 14),
                            ),
                            crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                            duration: Duration(milliseconds: 300),
                          ),

                          /// Expand/Collapse button
                          if (message.length > 60) // show toggle only for long text
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isExpanded = !_isExpanded;
                                });
                              },
                              child: Text(
                                _isExpanded ? "Show less" : "Read more",
                                style: primaryTextStyle(size: 12, color: Colors.blue),
                              ).paddingTop(4),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
