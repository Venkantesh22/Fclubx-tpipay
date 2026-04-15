import 'package:flutter/material.dart';
import 'package:frezka/generated/assets.dart';
import 'package:frezka/utils/app_common.dart';
import 'package:frezka/utils/colors.dart';
import 'package:frezka/utils/extensions/string_extensions.dart';
import 'package:frezka/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../components/app_scaffold.dart';
import '../../../components/cached_image_widget.dart';
import '../../../components/default_user_image_placeholder.dart';
import '../../../components/empty_error_state_widget.dart';
import '../../../components/rating_widget.dart';
import '../../../main.dart';
import '../../review/view/review_all_screen.dart';
import '../employee_repository.dart';
import '../model/employee_detail_response.dart';
import '../shimmer/employee_detail_shimmer.dart';

class EmployeeDetailScreen extends StatefulWidget {
  final int employeeId;
  final int? branchId;

  EmployeeDetailScreen({required this.employeeId, this.branchId});

  @override
  _EmployeeDetailScreenState createState() => _EmployeeDetailScreenState();
}

class _EmployeeDetailScreenState extends State<EmployeeDetailScreen> {
  Future<EmployeeDetailResponse>? future;
  Map<int, bool> _expandedReviews = {};
  int _currentReviewIndex = 0;
  ScrollController _reviewScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  void dispose() {
    _reviewScrollController.dispose();
    super.dispose();
  }

  void init() async {
    future = getEmployeeDetail(
      employeeId: widget.employeeId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBarWidget: commonAppBarWidget(
        context,
        title: locale.aboutExpert,
        appBarHeight: 70,
        roundCornerShape: true,
        showLeadingIcon: true,
      ),
      body: SnapHelperWidget<EmployeeDetailResponse>(
        future: future,
        loadingWidget: EmployeeDetailShimmer(),
        onSuccess: (snap) {
          EmployeeData employeeData = snap.data!;

          return  Container(
              color: context.scaffoldBackgroundColor,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Profile Header Card
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.fromLTRB(10, 10, 10, 8),
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: context.cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 5,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          // Profile Image and Info Row
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Profile Image
                              Container(
                                width: 70,
                                height: 70,
                                child: ClipOval(
                                  child: CachedImageWidget(
                                    url: employeeData.profileImage.validate(),
                                    height: 70,
                                    width: 70,
                                    fit: BoxFit.cover,
                                    child: DefaultUserImagePlaceholder(),
                                  ),
                                ),
                              ),
                              16.width,
                              // Name and Tags
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Name

                                    Row(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: primaryLightColor,
                                            borderRadius: BorderRadius.circular(30),
                                            border: Border.all(
                                              color: borderColor,
                                              width: 1,
                                            ),
                                          ),
                                          child: Text(
                                            employeeData.branchName.validate().capitalizeFirstLetter(),
                                            style: boldTextStyle(size: 10, color: appTextSecondaryColor, weight: FontWeight.w700),
                                          ),
                                        ),
                                        8.width,
                                        Expanded(
                                          child: Marquee(
                                            child: Text(
                                              employeeData.expert.validate().capitalizeFirstLetter(),
                                              style: boldTextStyle(size: 12, weight: FontWeight.w700, color: context.primaryColor),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        8.width,
                                      ],
                                    ),
                                    Text(employeeData.fullName.validate(), style: boldTextStyle(size: 18)),
                                    8.height,
                                    if (employeeData.expertExperience.validate().isNotEmpty) ...[
                                      8.height,
                                      RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text: "${locale.experience}: ",
                                              style: secondaryTextStyle(
                                                size: 12,
                                                color: appTextSecondaryColor,
                                              ),
                                            ),
                                            TextSpan(
                                              text: employeeData.expertExperience.validate(),
                                              style: boldTextStyle(
                                                size: 12,
                                                color: context.primaryColor,
                                                weight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ]
                                  ],
                                ),
                              ),
                              // Rating
                              RatingWidget(
                                rating: employeeData.ratingStar.validate().toDouble(),
                                showRatingNumber: true,
                                ratingNumberSize: 12,
                                maxStars: 1,
                                showOnlyOneStar: true,
                              ),
                            ],
                          ),
                          // Description
                          if (employeeData.aboutSelf.validate().isNotEmpty) ...[
                            16.height,
                            _buildExpandableDescription(employeeData.aboutSelf.validate()),
                          ],
                        ],
                      ),
                    ),
                    // Contact Information
                    if (employeeData.email.validate().isNotEmpty || employeeData.mobile.validate().isNotEmpty) ...[
                      10.height,
                      _buildContactSection(employeeData),
                    ],

                    10.height,
                    // Social Media
                    if (employeeData.facebookLink.validate().isNotEmpty || employeeData.instagramLink.validate().isNotEmpty || employeeData.twitterLink.validate().isNotEmpty || employeeData.dribbbleLink.validate().isNotEmpty)
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.only(left: 20, right: 20, top: 5, bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              locale.socialMedia,
                              style: boldTextStyle(
                                size: 14,
                              ),
                            ),
                            12.height,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              spacing: 16,
                              children: [
                                if (employeeData.facebookLink.validate().isNotEmpty)
                                  _buildSocialIconWithAsset(
                                    ic_facebook,
                                    () => commonLaunchUrl(employeeData.facebookLink.validate()),
                                  ),
                                if (employeeData.instagramLink.validate().isNotEmpty)
                                  _buildSocialIconWithAsset(
                                    ic_instagram,
                                    () => commonLaunchUrl(employeeData.instagramLink.validate()),
                                  ),
                                if (employeeData.twitterLink.validate().isNotEmpty)
                                  _buildSocialIconWithAsset(
                                    ic_twitter,
                                    () => commonLaunchUrl(employeeData.twitterLink.validate()),
                                  ),
                                if (employeeData.dribbbleLink.validate().isNotEmpty)
                                  _buildSocialIconWithAsset(
                                    ic_dribble,
                                    () => commonLaunchUrl(employeeData.dribbbleLink.validate()),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    10.height,
                    // Rating Section
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: context.scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                locale.rating,
                                style: boldTextStyle(size: 14),
                              ),
                              if (employeeData.reviewData.validate().length > 5)
                                GestureDetector(
                                  onTap: () {
                                    ReviewAllScreen(employeeId: snap.data!.id).launch(context);
                                  },
                                  child: Text(
                                    locale.viewAll,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
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
                          ).paddingSymmetric(horizontal: 16),
                          SizedBox(height: 16),

                          // Horizontal scrollable review cards
                          if (employeeData.reviewData.validate().isNotEmpty)
                            Builder(
                              builder: (context) {
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  _reviewScrollController.addListener(() {
                                    if (_reviewScrollController.hasClients) {
                                      double scrollPosition = _reviewScrollController.offset;
                                      int newIndex = (scrollPosition / 292.0).round();
                            
                                      if (newIndex >= 0 &&
                                          newIndex < employeeData.reviewData!.length &&
                                          newIndex != _currentReviewIndex) {
                                        setState(() {
                                          _currentReviewIndex = newIndex;
                                        });
                                      }
                                    }
                                  });
                                });
                            
                                return SingleChildScrollView(
                                  controller: _reviewScrollController,
                                  scrollDirection: Axis.horizontal,
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Row(
                                    children: List.generate(
                                      employeeData.reviewData!.length,
                                      (index) {
                                        final review = employeeData.reviewData![index];
                            
                                        return Padding(
                                          padding: const EdgeInsets.only(right: 12),
                                          child: _buildHorizontalReviewCard(
                                            review.username.validate(),
                                            review.rating.validate().toDouble(),
                                            review.createdAt.validate(),
                                            review.reviewMsg.validate(),
                                            index,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                );
                              },
                            )
                          else
                            SizedBox(
                              height: 130,
                              child: Center(
                                child: Text(locale.noReviewYet, style: primaryTextStyle(size: 14, color: appTextSecondaryColor)),
                              ),
                            ),
                          SizedBox(height: 12),

                          // Pagination Dots
                          if (employeeData.reviewData.validate().isNotEmpty && employeeData.reviewData!.length > 1)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                employeeData.reviewData!.length,
                                (index) => GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _currentReviewIndex = index;
                                    });
                                    _reviewScrollController.animateTo(
                                      index * 292.0, // 280 (card width) + 12 (separator)
                                      duration: Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                    );
                                  },
                                  child: AnimatedContainer(
                                    duration: Duration(milliseconds: 300),
                                    margin: EdgeInsets.symmetric(horizontal: 4),
                                    width: index == _currentReviewIndex ? 18 : 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: index == _currentReviewIndex ? context.primaryColor : context.cardColor,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: index == _currentReviewIndex ? Colors.white : context.primaryColor, width: 1),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    32.height,
                  ],
                ),
              ),
            );
        },
        errorBuilder: (error) {
          return NoDataWidget(
            title: error,
            imageWidget: ErrorStateWidget(),
            retryText: locale.reload,
            onRetry: () {
              init();
              setState(() {});
            },
          );
        },
      ),
    );
  }

  Widget _buildExpandableDescription(String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          child: Text(
            description,
            style: secondaryTextStyle(),
            softWrap: true,
            textAlign: TextAlign.left,
          ),
        ),
      ],
    );
  }

  Widget _buildContactSection(EmployeeData employeeData) {
    final List<Widget> rows = [];

    if (employeeData.email.validate().isNotEmpty) {
      rows.add(_buildContactRow(
        locale.email,
        employeeData.email.validate(),
        onTap: () => launchMail(employeeData.email.validate()),
      ));
    }

    if (employeeData.mobile.validate().isNotEmpty) {
      if (rows.isNotEmpty) rows.add(12.height);
      rows.add(_buildContactRow(
        locale.contactNumber,
        employeeData.mobile.validate(),
        onTap: () => launchCall(employeeData.mobile.validate()),
      ));
    }

    if (rows.isEmpty) return SizedBox.shrink();

    return Container(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            locale.contactInformation,
            style: boldTextStyle(size: 14),
          ).paddingSymmetric(horizontal: 16),
          12.height,
          ...rows,
        ],
      ),
    );
  }

  Widget _buildContactRow(String label, String value, {VoidCallback? onTap}) {
    // Determine icon based on label
    Widget iconWidget;
    if (label.toLowerCase().contains('email')) {
      iconWidget = Assets.iconsIcMessage.iconImage(color: Colors.white, size: 14);
    } else if (label.toLowerCase().contains('contact') || label.toLowerCase().contains('phone') || label.toLowerCase().contains('mobile')) {
      iconWidget = Assets.iconsIcCall.iconImage(color: Colors.white, size: 14);
    } else {
      iconWidget = Icon(Icons.info_outline, color: Colors.white, size: 14);
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon circle
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(color: context.primaryColor.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Center(
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: context.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(child: iconWidget),
                ),
              ),
            ),
            12.width,
            // Label + value
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: secondaryTextStyle(size: 12, color: dateSlotColor),
                  ),
                  4.height,
                  Text(value, style: primaryTextStyle(size: 14), overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialIconWithAsset(String assetPath, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: cardColor,
          shape: BoxShape.circle,
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Padding(
          padding: EdgeInsets.all(8),
          child: CachedImageWidget(
            url: assetPath,
            color: primaryColor,
            height: 14,
            width: 14,
          ),
        ),
      ),
    );
  }

  String _formatReviewTime(String createdAt) {
    try {
      DateTime reviewDate = DateTime.parse(createdAt);
      DateTime now = DateTime.now();
      Duration difference = now.difference(reviewDate);

      if (difference.inDays > 0) {
        return locale.reviewDaysAgo(difference.inDays);
      } else if (difference.inHours > 0) {
        return locale.reviewHoursAgo(difference.inHours);
      } else if (difference.inMinutes > 0) {
        return locale.reviewMinutesAgo(difference.inMinutes);
      } else {
        return locale.reviewJustNow;
      }
    } catch (e) {
      return createdAt;
    }
  }

  Widget _buildHorizontalReviewCard(String name, double rating, String time, String review, int index) {
    return Container(
      width: 280,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Rating
              RatingWidget(
                rating: rating,
                showRatingNumber: true,
                ratingNumberSize: 12,
              ),
              10.width,
              // Time
              Text(_formatReviewTime(time), style: secondaryTextStyle(size: 12)),
            ],
          ),

          12.height,

          // Review
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                review,
                style: secondaryTextStyle(
                  size: 12,
                ),
                maxLines: _expandedReviews[index] == true ? null : 3,
                overflow: _expandedReviews[index] == true ? null : TextOverflow.ellipsis,
              ),
              if (review.length > 100)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _expandedReviews[index] = !(_expandedReviews[index] ?? false);
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.only(top: 4),
                    child: Text(
                      _expandedReviews[index] == true ? locale.viewLess : locale.viewMore,
                      style: secondaryTextStyle(color: context.primaryColor, size: 11),
                    ),
                  ),
                ),
            ],
          ),

          8.height,

          // Bottom Row: User info
          Row(
            children: [
              // Profile Picture
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(color: priceColor, shape: BoxShape.circle),
                child: Center(
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : "?",
                    style: primaryTextStyle(color: Colors.white),
                  ),
                ),
              ),
              8.width,
              // Name
              Text(name, style: primaryTextStyle(size: 14), overflow: TextOverflow.ellipsis),
              8.width,
              Container(
                width: 16,
                height: 16,
                decoration: boxDecorationWithRoundedCorners(
                  backgroundColor: Colors.green,
                  borderRadius: radius(16),
                ),
                child: Icon(
                  Icons.check,
                  color: context.scaffoldBackgroundColor,
                  size: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
