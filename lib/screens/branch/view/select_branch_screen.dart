import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frezka/components/app_scaffold.dart';
import 'package:frezka/components/loader_widget.dart';
import 'package:frezka/main.dart';
import 'package:frezka/screens/branch/model/branch_response.dart';
import 'package:frezka/utils/common_base.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../components/empty_error_state_widget.dart';
import '../../../components/voice_search_component.dart';
import '../../../utils/app_common.dart';
import '../../../utils/colors.dart';
import '../../../utils/constants.dart';
import '../../dashboard/component/branch_item_component.dart';
import '../../dashboard/view/dashboard_screen.dart';
import '../branch_repository.dart';
import '../shimmer/select_branch_shimmer.dart';

class SelectBranchScreen extends StatefulWidget {
  final bool isFromDashboard;

  SelectBranchScreen({this.isFromDashboard = false});

  @override
  State<SelectBranchScreen> createState() => _SelectBranchScreenState();
}

class _SelectBranchScreenState extends State<SelectBranchScreen> {
  Future<List<BranchData>>? future;

  List<BranchData> branchList = [];
  List<BranchData> filteredBranchList = [];
  BranchData? selectedBranch;

  int page = 1;
  int selectedBranchId = UNSELECTED_BRANCH_ID;

  bool isLastPage = false;

  Position? currentLocation;

  TextEditingController searchController = TextEditingController();
  String selectedFilter = 'All';
  bool isSearching = false;


  @override
  void initState() {
    selectedBranchId = UNSELECTED_BRANCH_ID;
    init();

    super.initState();

    getLocation();

    _loadPreviouslySelectedBranch();
  }

  void init() {
    future = getBranchList(
      page: page,
      branchList: branchList,
      selectedBranch: selectedBranch,
      lastPageCallBack: (p0) {
        isLastPage = p0;
        filterBranches();
      },
    );
  }

  void filterBranches() {
    String searchText = searchController.text.toLowerCase().trim();
    if (searchText.isEmpty) {
      filteredBranchList = List.from(branchList);
      isSearching = false;
    } else {
      isSearching = true;
      filteredBranchList = branchList.where((branch) {
        bool matchesSearch = (branch.name?.toLowerCase().contains(searchText) ?? false) ||
            (branch.addressLine1?.toLowerCase().contains(searchText) ?? false) ||
            (branch.city?.toLowerCase().contains(searchText) ?? false) ||
            (branch.country?.toLowerCase().contains(searchText) ?? false);

        return matchesSearch;
      }).toList();
      isSearching = false;
    }
    if (mounted) {
      setState(() {});
    }
  }

  void _loadPreviouslySelectedBranch() {
    // Check if there's a previously selected branch stored in appStore
    if (appStore.branchId != UNSELECTED_BRANCH_ID) {
      selectedBranchId = appStore.branchId;
      // We'll find and set the selectedBranch when the branch list loads
    }
  }

  Future<void> redirectToDashboard({required List<BranchData> branchList}) async {
    if (branchList.length == 1) {
      await appStore.setBranchId(branchList.first.id.validate(value: UNSELECTED_BRANCH_ID));
      await appStore.setBranchAddress(branchList.first.addressLine1.validate());
      await appStore.setBranchName(branchList.first.name.validate());
      await appStore.setBranchContactNumber(branchList.first.contactNumber.validate());

      DashboardScreen().launch(context, isNewTask: true, pageRouteAnimation: PageRouteAnimation.Fade);
    }
  }

  void getLocation() {
    Geolocator.requestPermission().then((value) {
      if (value == LocationPermission.whileInUse || value == LocationPermission.always) {
        Geolocator.getCurrentPosition(locationSettings: LocationSettings(accuracy: LocationAccuracy.high)).then((value) {
          currentLocation = value;
          setState(() {});
        }).catchError(onError);
      }
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  void startListening() {
    startVoiceSearch(
      onResultCallback: (text, isFinal) {
        if (isFinal) {
          searchController.text = text;
          filterBranches();
        }
      },
      onStatusChanged: () {
        if (mounted) setState(() {});
      },
    );
  }

  void stopListening() {
    stopVoiceSearch();
  }

  void dispose() {
    searchController.dispose();
    stopVoiceSearch();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: widget.isFromDashboard,
      child: AppScaffold(
        appBarWidget: commonAppBarWidget(
          context,
          title: locale.chooseBranch,
          appBarHeight: 70,
          roundCornerShape: true,
          showLeadingIcon: widget.isFromDashboard ? Navigator.canPop(context) : false,
        ),
        body: Column(
          children: [
            Column(
              children: [
                // Search Bar
                Container(
                  margin: EdgeInsets.only(left: 16, right: 16, top: 16),
                  child: AppTextField(
                    controller: searchController,
                    textFieldType: TextFieldType.OTHER,
                    suffix: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () {
                            searchController.clear();
                            filterBranches();
                          },
                          child: Icon(Icons.close, color: context.iconColor)
                        ).visible(searchController.text.isNotEmpty),
                        6.width.visible(searchController.text.isNotEmpty),
                        GestureDetector(
                          onTap: () {
                            startListening();
                          },
                          child: Icon(Icons.mic_none_outlined, color: context.iconColor)
                        ),
                        12.width.visible(searchController.text.isNotEmpty),
                      ],
                    ),
                    onChanged: (s) {
                      filterBranches();
                    },
                    decoration: inputDecoration(
                      context,
                      hint: locale.searchForBranch,
                      prefixIcon: Icon(Icons.search, color: context.iconColor),
                    ),
                  ),
                ),
                Container(
                  width: context.width(),
                  padding: EdgeInsets.only(left: 20, right: 16, top: 16),
                  child: Text(
                    locale.chooseYourSalon,
                    style: boldTextStyle(color: textPrimaryColorGlobal, size: 16),
                    textAlign: TextAlign.left,
                  ),
                ),
              ],
            ),
            // Branch List
            Expanded(
              child: Stack(
                children: [
                  if(!appStore.isSpeechActivated)...[
                    SnapHelperWidget<List<BranchData>>(
                    future: future,
                    errorBuilder: (error) {
                      return NoDataWidget(
                        title: error,
                        retryText: locale.reload,
                        imageWidget: ErrorStateWidget(),
                        onRetry: () {
                          page = 1;
                          appStore.setLoading(true);
                          init();
                          setState(() {});
                        },
                      );
                    },
                    loadingWidget: SelectBranchShimmer().paddingSymmetric(horizontal: 16),
                    onSuccess: (list) {
                      redirectToDashboard(branchList: list);
                      branchList = list;
                      if (filteredBranchList.isEmpty && searchController.text.isEmpty) {
                        filteredBranchList = List.from(list);
                      }
                      if (selectedBranchId != UNSELECTED_BRANCH_ID) {
                        selectedBranch = branchList.firstWhere(
                          (branch) => branch.id == selectedBranchId,
                          orElse: () => branchList.first,
                        );
                      }
                      return SizedBox.shrink();
                    },
                  ),
                    if (branchList.isNotEmpty)
                      isSearching
                          ? LoaderWidget()
                          : AnimatedListView(
                            padding: EdgeInsets.only(bottom: selectedBranchId != UNSELECTED_BRANCH_ID ? 80 : 16, left: 16, right: 16, top: 16),
                            physics: AlwaysScrollableScrollPhysics(),
                            itemCount: filteredBranchList.length,
                            shrinkWrap: true,
                            emptyWidget: NoDataWidget(
                              title: searchController.text.isNotEmpty ? locale.noBranchFound : locale.noBranchFound,
                              imageWidget: EmptyStateWidget(),
                              retryText: locale.reload,
                              onRetry: () {
                                page = 1;
                                appStore.setLoading(true);

                                init();
                                setState(() {});
                              },
                            ),
                            itemBuilder: (context, index) {
                              BranchData branchData = filteredBranchList[index];

                              return BranchItemComponent(
                                branchData: branchData,
                                isFormSignIn: true,
                                selectedBranchId: selectedBranchId,
                                currentBranchIndex: branchData.id,
                                position: currentLocation,
                              ).onTap(() async {
                                if (selectedBranchId == branchData.id) {
                                  selectedBranchId = UNSELECTED_BRANCH_ID;
                                  selectedBranch = null;
                                } else {
                                  selectedBranch = branchData;
                                  selectedBranchId = branchData.id!;
                                }
                                setState(() {});
                              }, highlightColor: Colors.transparent, hoverColor: Colors.transparent, splashColor: Colors.transparent);
                            },
                            onNextPage: () {
                              if (!isLastPage) {
                                page++;
                                appStore.setLoading(true);

                                init();
                                setState(() {});
                              }
                            },
                            onSwipeRefresh: () async {
                              page = 1;
                              init();
                              setState(() {});
                              return await 2.seconds.delay;
                            },
                          ),
                  ],
                  // Voice search animation - centered overlay
                  Observer(
                    builder: (context) {
                      return appStore.isSpeechActivated
                          ? Positioned.fill(
                              child: Center(
                                child: Transform.translate(offset: Offset(0, -100), child: VoiceSearchComponent()),
                              ),
                            )
                          : SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.arrow_right_alt_rounded, color: Colors.white),
          backgroundColor: secondaryColor,
          onPressed: () async {
            if (appStore.branchId != selectedBranchId) {
              showConfirmDialogCustom(
                context,
                positiveText: locale.yes,
                negativeText: locale.no,
                onAccept: (_) async {
                  dashboardResponseCached = null;
                  bookingDetailCached = [];

                  await appStore.setBranchId(selectedBranch!.id.validate(value: UNSELECTED_BRANCH_ID));
                  await appStore.setBranchAddress("${selectedBranch!.addressLine1.validate()} ${selectedBranch!.city.validate()} ${selectedBranch!.country.validate()} ");
                  await appStore.setBranchName(selectedBranch!.name.validate());
                  await appStore.setBranchContactNumber(selectedBranch!.contactNumber.validate());

                  DashboardScreen().launch(context, isNewTask: true, pageRouteAnimation: PageRouteAnimation.Fade);
                },
                title: '${locale.doYouWantExplore} ${selectedBranch!.name}?',
                primaryColor: context.primaryColor,
              );
            } else {
              DashboardScreen().launch(context, isNewTask: true, pageRouteAnimation: PageRouteAnimation.Fade);
            }
          },
        ).visible(branchList.isNotEmpty && selectedBranchId != UNSELECTED_BRANCH_ID),
      ),
    );
  }
}
