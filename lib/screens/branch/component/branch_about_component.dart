import 'package:flutter/material.dart';
import 'package:frezka/utils/colors.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../main.dart';
import '../../../utils/common_base.dart';
import '../model/branch_response.dart';

class BranchAboutComponent extends StatelessWidget {
  final String branchDescription;
  final List<WorkingHourList> workingList;

  const BranchAboutComponent({
    super.key,
    required this.branchDescription,
    required this.workingList,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Branch Description
          if (branchDescription.isNotEmpty) ...[
            Text(
              branchDescription.validate().length > 250 ? branchDescription.validate().substring(0, 250) : branchDescription.validate(),
              style: secondaryTextStyle(),
            ),
            16.height,
          ],

          /// Working Hours Section
          if (workingList.isNotEmpty)
            Container(
              width: context.width(),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.cardColor,
                borderRadius: BorderRadius.circular(2),
                border: Border.all(color: borderColor, width: 0.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Header
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 20, color: context.iconColor),
                      8.width,
                      Text(
                        locale.workingHours,
                        style: boldTextStyle(size: 16),
                      ),
                    ],
                  ),
                  16.height,

                  /// Working Hours List
                  ...workingList.take(7).map((data) {
                    bool isClosed = data.isHoliday == 1;
                    bool isFestival = data.isFestival == 1; // this represents is_festival_holiday
                    bool hasBreak = data.branchBreaks != null && data.branchBreaks!.isNotEmpty;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// Day and Time Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              data.day!.capitalizeFirstLetter(),
                              style: primaryTextStyle(size: 14),
                            ),
                            Row(
                              children: [
                                // 👉 Festival Holiday takes priority over Close
                                if (isFestival)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: boxDecorationWithRoundedCorners(
                                      backgroundColor: successDarkColor.withValues(alpha: 0.2),
                                      borderRadius: radius(16),
                                      border: Border.all(color: successDarkColor, width: 0.5),
                                    ),
                                    child: Text(
                                      locale.holiday,
                                      style: primaryTextStyle(color: successDarkColor, size: 12, weight: FontWeight.w600),
                                    ),
                                  )
                                else if (isClosed)
                                  Text(
                                    locale.close,
                                    style: boldTextStyle(color: Colors.red),
                                  )
                                else
                                  Text(
                                    formatOnlyTime(
                                      context,
                                      startTime: data.startTime,
                                      endTime: data.endTime,
                                    ),
                                    style: primaryTextStyle(size: 14),
                                  ),
                              ],
                            ),
                          ],
                        ),

                        /// Break Time (only if not closed or festival)
                        if (!isClosed && hasBreak && !isFestival)
                          Container(
                            width: context.width(),
                            margin: const EdgeInsets.only(top: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            child: Column(
                              children: data.branchBreaks!.map((breakItem) {
                                return Container(
                                  width: context.width(),
                                  margin: const EdgeInsets.only(top: 4),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                  decoration: boxDecorationWithRoundedCorners(
                                    backgroundColor: appStore.isDarkMode ? darkSecondaryColor : primaryLightColor,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: borderColor, width: 1),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.restaurant,
                                        size: 16,
                                      ),
                                      8.width,
                                      RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text: "${locale.breakTime}: ",
                                              style: boldTextStyle(size: 14),
                                            ),
                                            TextSpan(
                                              text: formatOnlyTime(
                                                context,
                                                startTime: breakItem.startBreak,
                                                endTime: breakItem.endBreak,
                                              ),
                                              style: boldTextStyle(color: context.primaryColor, size: 14),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),

                        /// Divider
                        if (data != workingList.last) ...[
                          12.height,
                          Divider(
                            height: 1,
                            color: Colors.grey.shade300,
                            thickness: 1,
                          ),
                          12.height,
                        ],
                      ],
                    );
                  }).toList(),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
