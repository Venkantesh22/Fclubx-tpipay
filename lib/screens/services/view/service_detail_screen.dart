import 'package:flutter/material.dart';
import 'package:frezka/components/app_scaffold.dart';
import 'package:frezka/components/cached_image_widget.dart';
import 'package:frezka/components/image_slider_component.dart';
import 'package:frezka/components/loader_widget.dart';
import 'package:frezka/components/price_widget.dart';
import 'package:frezka/components/rating_widget.dart';
import 'package:frezka/main.dart';
import 'package:frezka/screens/booking/view/booking_screen.dart';
import 'package:frezka/screens/experts/view/employee_detail_screen.dart';
import 'package:frezka/screens/services/models/service_response.dart';
import 'package:frezka/screens/services/service_repository.dart';
import 'package:frezka/utils/colors.dart';
import 'package:frezka/utils/common_base.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../utils/app_common.dart';
import '../../branch/model/branch_response.dart';
import '../../experts/component/employee_list_component.dart';
import '../../experts/model/employee_detail_response.dart';

class ServiceDetailScreen extends StatefulWidget {
  final int serviceId;

  const ServiceDetailScreen({super.key, required this.serviceId});

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  final PageController _pageController = PageController();
  int activeIndex = 0;
  ServiceData? serviceData;
  List<BranchData> fullBranchData = [];
  Map<int, int> branchStatusMap = {};
  bool isLoading = true;
  bool isDescriptionExpanded = false;
  int staffToShow = 5;
  int branchToShow = 3;
  int? selectedBranchId;
  Position? currentLocation;

  @override
  void initState() {
    super.initState();
    getServiceData();
    getLocation();
  }

  void getLocation() {
    Geolocator.requestPermission().then((value) {
      if (value == LocationPermission.whileInUse || value == LocationPermission.always) {
        Geolocator.getCurrentPosition(
          locationSettings: LocationSettings(
            accuracy: LocationAccuracy.high,
          ),
        ).then((value) {
          setState(() {
            currentLocation = value;
          });
        }).catchError((e) {
          log("Location error: $e");
        });
      }
    });
  }

  double getDistance(BranchData branch) {
    if (currentLocation == null) return 0;
    if (branch.latitude == null || branch.longitude == null) return 0;

    return calculateDistance(
      branch.latitude!.toDouble(),
      branch.longitude!.toDouble(),
      currentLocation!.latitude,
      currentLocation!.longitude,
    );
  }

  Future<void> getServiceData() async {
    try {
      ServiceData? data = await getServiceDetail(widget.serviceId, appStore.branchId);

      if (data?.branches != null && data!.branches!.isNotEmpty) {
        List<BranchData> branches = [];
        branchStatusMap.clear();
        for (final branch in data.branches!) {
          branchStatusMap[branch.id.validate()] = branch.status ?? 0;

          try {
            List<BranchData> branchList = [];

            BranchData? fullBranchData;
            try {
              fullBranchData = branchList.firstWhere((b) => b.id == branch.id);
            } catch (e) {
              fullBranchData = null;
            }

            if (fullBranchData != null) {
              branches.add(fullBranchData);
            } else {
              branches.add(BranchData(
                id: branch.id,
                name: branch.name,
                addressLine1: branch.address,
                city: branch.city,
                country: branch.country,
                branchImg: branch.image,
                ratingStar: branch.ratingStar,
                branchFor: branch.branchFor,
                latitude: branch.latitude,
                longitude: branch.longitude,
              ));
            }
          } catch (e) {
            branches.add(BranchData(
              id: branch.id,
              name: branch.name,
              addressLine1: branch.address,
              city: branch.city,
              country: branch.country,
              branchImg: branch.image,
              ratingStar: branch.ratingStar,
              branchFor: branch.branchFor,
              latitude: branch.latitude,
              longitude: branch.longitude,
            ));
          }
        }
        fullBranchData = branches;
      }

      setState(() {
        serviceData = data;
        isLoading = false;
      });
    } catch (e) {
      log("Error: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBarWidget: commonAppBarWidget(
        context,
        title: serviceData?.name.validate() ?? locale.serviceDetail,
        appBarHeight: 70,
        roundCornerShape: true,
        showLeadingIcon: true,
      ),
      body: isLoading
          ? Center(child: LoaderWidget())
          : serviceData == null
              ? Center(child: Text(locale.noServiceDetailsFound))
              : Stack(
                  children: [
                    SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Top Image
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              // Top Image / Slider
                              Builder(
                                builder: (context) {
                                  // Build combined image list: primary image first, then multi_image
                                  final List<String> imageList = [];
                                  if (serviceData?.image.validate().isNotEmpty == true) {
                                    imageList.add(serviceData!.image!);
                                  }
                                  if (serviceData?.multiImage != null && serviceData!.multiImage!.isNotEmpty) {
                                    imageList.addAll(serviceData!.multiImage!.where((img) => img.isNotEmpty));
                                  }

                                  if (imageList.isEmpty) {
                                    return SizedBox(
                                      height: MediaQuery.of(context).size.height * 0.3,
                                      width: double.infinity,
                                      child: Placeholder(),
                                    );
                                  }

                                  return ImageSliderComponent(
                                    imageUrls: imageList,
                                    height: MediaQuery.of(context).size.height * 0.3,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  );
                                },
                              ),

                              // Floating Card
                              Positioned(
                                bottom: -70,
                                left: 16,
                                right: 16,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: context.cardColor,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Category + Price
                                        Row(
                                          children: [
                                            if (serviceData?.category.validate().isNotEmpty == true)
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: primaryLightColor,
                                                  borderRadius: BorderRadius.circular(12),
                                                  border: Border.all(color: borderColor, width: 1),
                                                ),
                                                child: Text(
                                                  "${serviceData!.category.validate()} / ${serviceData!.subCategory.validate()}",
                                                  style: secondaryTextStyle(size: 10, weight: FontWeight.w900),
                                                ),
                                              ),
                                            const Spacer(),
                                            PriceWidget(
                                              price: serviceData!.price.validate().toDouble(),
                                              size: 20,
                                              color: context.primaryColor,
                                              isBoldText: true,
                                            ),
                                          ],
                                        ),
                                        12.height,
                                        // Service Name
                                        Text(serviceData!.name.validate(), style: boldTextStyle(size: 18)),
                                        8.height,
                                        // Description

                                        // Service Attributes
                                        Row(
                                          children: [
                                            if (serviceData!.duration.validate().isNotEmpty)
                                              Row(
                                                children: [
                                                  Icon(Icons.timer_outlined, size: 16, color: context.iconColor),
                                                  6.width,
                                                  Text('${durationToString(serviceData!.duration.validate().toInt())}', style: secondaryTextStyle(size: 12)),
                                                ],
                                              ),
                                            16.width,
                                            Row(
                                              children: [
                                                Icon(Icons.people, size: 16, color: context.iconColor),
                                                6.width,
                                                Text("${serviceData!.employee?.length ?? 0} ${locale.staff}", style: secondaryTextStyle(size: 12)),
                                              ],
                                            ),
                                            16.width,
                                            Row(
                                              children: [
                                                Icon(Icons.account_tree_rounded, size: 16, color: context.iconColor),
                                                6.width,
                                                Text("${serviceData!.branches?.length ?? 0} ${locale.branches}", style: secondaryTextStyle(size: 12)),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          100.height,
                          // Description
                          if (serviceData!.description.validate().isNotEmpty)
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    serviceData!.description.validate(),
                                    style: secondaryTextStyle(size: 12),
                                    maxLines: isDescriptionExpanded ? null : 3,
                                    overflow: isDescriptionExpanded ? null : TextOverflow.ellipsis,
                                  ),
                                  if (serviceData!.description.validate().length > 100)
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          isDescriptionExpanded = !isDescriptionExpanded;
                                        });
                                      },
                                      child: Text(
                                        isDescriptionExpanded ? locale.readLess : locale.readMore,
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
                            ),
                          16.height,
                          // Staff list
                          if (serviceData?.employee?.isNotEmpty == true) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(locale.availableStaff, style: boldTextStyle(size: 16)),
                            ),
                            12.height,
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: serviceData!.employee!.length > staffToShow ? staffToShow : serviceData!.employee!.length,
                              itemBuilder: (context, index) {
                                final staff = serviceData!.employee![index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 2, right: 16, left: 16),
                                  child: EmployeeListComponent(
                                    hideRating: true,
                                    expertData: EmployeeData(
                                      id: staff.id,
                                      fullName: staff.name.validate(),
                                      profileImage: staff.image.validate(),
                                      expert: staff.expert,
                                      ratingStar: staff.rating?.toDouble(),
                                    ),
                                    onTap: () {
                                      EmployeeDetailScreen(employeeId: staff.id.validate()).launch(context);
                                    },
                                  ),
                                );
                              },
                            ),
                            if (serviceData!.employee!.length > 5)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 5),
                                child: Center(
                                    child: TextButton(
                                  onPressed: () {
                                    setState(() {
                                      if (staffToShow < serviceData!.employee!.length) {
                                        // Load More
                                        staffToShow = (staffToShow + 5).clamp(0, serviceData!.employee!.length);
                                      } else {
                                        // Load Less - show only 5
                                        staffToShow = 5;
                                      }
                                    });
                                  },
                                  child: Text(
                                    staffToShow < serviceData!.employee!.length ? locale.loadMore : locale.loadLess,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      shadows: [Shadow(color: context.primaryColor, offset: Offset(0, -2))],
                                      color: Colors.transparent,
                                      decoration: TextDecoration.underline,
                                      decorationColor: context.primaryColor,
                                      decorationThickness: 1,
                                      decorationStyle: TextDecorationStyle.solid,
                                    ),
                                  ),
                                )),
                              ),
                          ],

                          // Available in others Branches
                          if (fullBranchData.isNotEmpty) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(locale.availableInOtherBranches, style: boldTextStyle(size: 14)),
                            ),
                            12.height,
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: fullBranchData.length > branchToShow ? branchToShow : fullBranchData.length,
                              itemBuilder: (context, index) {
                                final branch = fullBranchData[index];
                                final isSelected = selectedBranchId == branch.id;
                                // Calculate distance for this branch
                                final distance = (branch.latitude != null && branch.longitude != null && currentLocation != null) ? getDistance(branch) : null;
                                final branchStatus = branchStatusMap[branch.id] ?? 0;
                                final isBranchOpen = branchStatus == 1;
                                final branchStatusText = isBranchOpen ? locale.open : locale.closed;

                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedBranchId = branch.id;
                                      });
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(20),
                                      decoration: boxDecorationWithRoundedCorners(
                                        backgroundColor: context.cardColor,
                                        borderRadius: radius(4),
                                        border: Border.all(color: borderColor, width: 0.5),
                                      ),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Branch Image
                                          Container(
                                            width: 64,
                                            height: 64,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(4),
                                              child: CachedImageWidget(
                                                url: branch.branchImg.validate(),
                                                width: 64,
                                                height: 64,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          16.width,
                                          // Content Section
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                // Tags Row
                                                Row(
                                                  children: [
                                                    Container(
                                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                      decoration: boxDecorationWithRoundedCorners(
                                                        backgroundColor: isBranchOpen ? successColor : redColor,
                                                        borderRadius: radius(26),
                                                      ),
                                                      child: Text(
                                                        branchStatusText.toUpperCase(),
                                                        style: primaryTextStyle(color: Colors.white, size: 10),
                                                      ),
                                                    ),
                                                    8.width,
                                                    RatingWidget(rating: branch.ratingStar.validate().toDouble(), showRatingNumber: true, ratingNumberSize: 10, maxStars: 1),
                                                    8.width,
                                                    Container(
                                                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                                                      decoration: BoxDecoration(
                                                        color: primaryLightColor,
                                                        borderRadius: BorderRadius.circular(26),
                                                        border: Border.all(color: borderColor, width: 0.5),
                                                      ),
                                                      child: Text(
                                                        branch.branchFor.validate().toUpperCase(),
                                                        style: secondaryTextStyle(size: 10),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                14.height,
                                                // Salon Name
                                                Text(
                                                  branch.name.validate().split(' ').map((word) => word.isNotEmpty ? word[0].toUpperCase() + word.substring(1).toLowerCase() : '').join(' '),
                                                  style: boldTextStyle(size: 14),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                // Address (at the top)
                                                Text(
                                                  '${branch.addressLine1.validate()}, ${branch.city.validate()}, ${branch.country.validate()}'
                                                      .split(' ')
                                                      .map((word) => word.isNotEmpty ? word[0].toUpperCase() + word.substring(1).toLowerCase() : '')
                                                      .join(' '),
                                                  style: secondaryTextStyle(size: 12),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                4.height,
                                                if (branch.latitude != null && branch.longitude != null)
                                                  Builder(
                                                    builder: (context) {
                                                      final calculatedDistance = distance ?? 0.0;
                                                      final distanceText = calculatedDistance > 0 ? calculatedDistance.toStringAsFixed(1) : '0.0';
                                                      return Text(
                                                        locale.kmAway(distanceText),
                                                        style: secondaryTextStyle(size: 12),
                                                      );
                                                    },
                                                  ),
                                              ],
                                            ),
                                          ),
                                          // Radio Button
                                          Container(
                                            width: 16,
                                            height: 16,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(color: borderColor, width: 1),
                                            ),
                                            child: isSelected
                                                ? Center(
                                                    child: Container(
                                                      width: 10,
                                                      height: 10,
                                                      decoration: BoxDecoration(
                                                        color: context.primaryColor,
                                                        shape: BoxShape.circle,
                                                      ),
                                                    ),
                                                  )
                                                : null,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            if (fullBranchData.length > branchToShow)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 5),
                                child: Center(
                                    child: TextButton(
                                  onPressed: () {
                                    setState(() {
                                      if (branchToShow < fullBranchData.length) {
                                        // Load More
                                        branchToShow = (branchToShow + 3).clamp(0, fullBranchData.length);
                                      } else {
                                        branchToShow = 3;
                                      }
                                    });
                                  },
                                  child: Text(
                                    branchToShow < fullBranchData.length ? locale.loadMore : locale.loadLess,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      shadows: [Shadow(color: context.primaryColor, offset: Offset(0, -2))],
                                      color: Colors.transparent,
                                      decoration: TextDecoration.underline,
                                      decorationColor: context.primaryColor,
                                      decorationThickness: 1,
                                      decorationStyle: TextDecorationStyle.solid,
                                    ),
                                  ),
                                )),
                              ),
                          ],

                          // Add bottom padding to prevent overlap with sticky button
                          SizedBox(height: 80),
                        ],
                      ),
                    ),
                    // Sticky Book Now Button at bottom
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        child: AppButton(
                          text: locale.bookNow,
                          color: context.primaryColor,
                          height: 40,
                          textStyle: boldTextStyle(color: white, height: 0.8),
                          onTap: () {
                            BookingScreen(services: [
                              ServiceListData(
                                id: serviceData!.id,
                                name: serviceData!.name,
                                defaultPrice: serviceData!.price,
                                durationMin: serviceData!.duration.toInt(),
                                serviceImage: serviceData!.image,
                              )
                            ]).launch(context);
                          },
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
