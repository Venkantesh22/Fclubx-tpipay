import 'package:flutter/material.dart';
import 'package:frezka/components/empty_error_state_widget.dart';
import 'package:frezka/utils/common_base.dart';
import 'package:frezka/utils/custom_toast_widget.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../../components/cached_image_widget.dart';
import '../../../components/price_widget.dart';
import '../../../main.dart';
import '../../../utils/app_common.dart';
import '../../../utils/colors.dart';
import '../../dashboard/dashboard_repository.dart';
import '../../dashboard/models/dashboard_model.dart';
import '../../services/models/service_response.dart';
import '../model/booking_request_model.dart';

class ShowServices extends StatefulWidget {
  final List<ServiceListData> serviceListData;
  final List<String> selectedServiceIds;
  final Function(List<ServiceListData> selectedServices, List<String> selectedServiceIds) onSelectionChanged;

  ShowServices({
    required this.serviceListData,
    required this.selectedServiceIds,
    required this.onSelectionChanged,
  });

  @override
  _ShowServicesState createState() => _ShowServicesState();
}

class _ShowServicesState extends State<ShowServices> {
  List<ServiceListData> selectedService = [];
  List<String> selectedServiceIdList = [];
  BookingRequestModel taxRequest = BookingRequestModel();
  num totalAmount = 0;
  ScrollController _scrollController = ScrollController();
  bool isLoading = false;
  static const int perPage = 15;
  List<ServiceListData> _serviceListData = [];
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  SpeechToText speech = SpeechToText();
  String lastWords = '';
  String lastError = '';
  String lastStatus = '';
  @override
  void initState() {
    super.initState();

    // Initialize selected IDs
    selectedServiceIdList.addAll(widget.selectedServiceIds);

    // Mark services as selected based on the passed IDs
    for (var service in widget.serviceListData) {
      if (selectedServiceIdList.contains(service.id.toString())) {
        service.isServiceChecked = true;
        selectedService.add(service);
      }
    }

    // Attach scroll listener
    _scrollController.addListener(_scrollListener);
    _serviceListData.addAll(widget.serviceListData);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Scroll listener for lazy loading
  void _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      loadMoreData();
    }
  }

  Future<void> loadMoreData() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    try {
      int newPerPage = _serviceListData.length + perPage;
      DashboardResponse newData = await userDashboard(
        branchId: appStore.branchId,
        perPage: newPerPage,
      );

      if (newData.data?.service != null) {
        final newServices = newData.data!.service!;

        for (var service in newServices) {
          if (selectedServiceIdList.contains(service.id.validate().toString())) {
            service.isServiceChecked = true;
          } else {
            service.isServiceChecked = false;
          }
        }

        setState(() {
          _serviceListData.addAll(newServices.where((newService) => !_serviceListData.any((existingService) => existingService.id == newService.id)));

          if (newServices.isEmpty || newServices.length < perPage) {
            _scrollController.removeListener(_scrollListener);
          }

          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          _scrollController.removeListener(_scrollListener);
        });
      }
    } catch (e) {
      isLoading = false;
    }
  }

  void _updateTotalAmount() {
    totalAmount = selectedService.fold(0.0, (sum, service) => sum + service.defaultPrice.validate());
  }

  void resultListener(SpeechRecognitionResult result) {
    appStore.setSpeechStatus(false);
    if (result.finalResult) {
      lastWords = result.recognizedWords;
      _searchController.text = lastWords;
      setState(() {
        _searchQuery = lastWords.trim().toLowerCase();
      });
    }
  }

  void errorListener(SpeechRecognitionError error) {
    appStore.setSpeechStatus(false);
    lastError = '${error.errorMsg} - ${error.permanent}';
    log("Speech error: $lastError");
  }

  void statusListener(String status) {
    setState(() {
      lastStatus = status;
      log("Speech status: $lastStatus");
    });

    if (status == 'done') {
      appStore.setSpeechStatus(false);
    }
  }

  void startListening() async {
    bool available = await speech.initialize(onStatus: statusListener, onError: errorListener);

    if (available) {
      appStore.setSpeechStatus(true);
      lastWords = '';
      lastError = '';
      speech.listen(
          onResult: resultListener,
          listenFor: Duration(seconds: 30),
          pauseFor: Duration(seconds: 10),
          listenOptions: SpeechListenOptions(
            listenMode: ListenMode.deviceDefault,
            cancelOnError: true,
            partialResults: true,
          ));

      setState(() {});
    } else {
      appStore.setSpeechStatus(false);
      ShowToast.showError(locale.theUserHasDeniedSpeechRecognition);
    }
  }

  void stopListening() {
    appStore.setSpeechStatus(false);
    speech.stop();
  }

  @override
  Widget build(BuildContext context) {
    final List<ServiceListData> filtered = _searchQuery.isEmpty ? _serviceListData : _serviceListData.where((s) => (s.name ?? '').toLowerCase().contains(_searchQuery)).toList();

    return Scaffold(
      appBar: commonAppBarServicesWidget(
        context,
        title: locale.allServices,
        appBarHeight: 70,
        showLeadingIcon: true,
        roundCornerShape: true,
        onLeadingIconPressed: () {
          selectedService = _serviceListData.where((service) => service.isServiceChecked).toList();
          Navigator.pop(context, {
            'selectedService': selectedService,
            'selectedServiceIds': selectedServiceIdList,
            'totalAmount': totalAmount,
          });
        },
      ),
      body: _serviceListData.isEmpty
          ? Center(child: Text(locale.noServicesAvailable))
          : Column(
              children: [
                Container(
                  padding: EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 0),
                  child: AppTextField(
                    textFieldType: TextFieldType.OTHER,
                    controller: _searchController,
                    suffix: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                          child: Icon(Icons.close, color: context.iconColor)
                        ).visible(_searchController.text.isNotEmpty),
                        6.width.visible(_searchController.text.isNotEmpty),
                        GestureDetector(
                          onTap: () {
                            startListening();
                          },
                          child: Icon(Icons.mic_none_outlined, color: context.iconColor)
                        ),
                        12.width.visible(_searchController.text.isNotEmpty),
                      ],
                    ),
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val.trim().toLowerCase();
                      });
                    },
                    onFieldSubmitted: (s) {
                      setState(() {
                        _searchQuery = s.trim().toLowerCase();
                      });
                    },
                    decoration: inputDecoration(
                      context,
                      hint: locale.searchForServices,
                      prefixIcon: Icon(Icons.search, color: context.iconColor),
                    ),
                  ),
                ),
                Expanded(
                  child: filtered.isEmpty ? 
                    Center(
                      child: NoDataWidget(
                      title: locale.noServicesFound,
                      imageWidget: EmptyStateWidget(),
                    )
                  ) : ListView.builder(
                    controller: _scrollController,
                    itemCount: filtered.length + (isLoading ? 1 : 0),
                    padding: EdgeInsets.zero,
                    physics: AlwaysScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      if (isLoading && index == (filtered.length)) {
                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Center(child: CircularProgressIndicator(color: primaryColor)),
                        );
                      }

                      var serviceData = filtered[index];
                      return serviceListWidget(serviceData: serviceData);
                    },
                  ).paddingAll(12),
                ),
                if(selectedService.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Container(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton(
                        onPressed: () {
                          selectedService = _serviceListData.where((service) => service.isServiceChecked).toList();
                          Navigator.pop(context, {
                            'selectedService': selectedService,
                            'selectedServiceIds': selectedServiceIdList,
                            'totalAmount': totalAmount,
                          });
                        },
                        child: Text(
                          locale.confirm,
                          style: boldTextStyle(color: Colors.white, size: 14, height: 1.2),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          padding: EdgeInsets.symmetric(vertical: 0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          elevation: 6,
                          shadowColor: Colors.black,
                        ),
                      ),
                    ),
                  )
              ],
            ),
    );
  }

  Widget serviceListWidget({required ServiceListData serviceData}) {
    return GestureDetector(
      onTap: () {
        setState(() {
          serviceData.isServiceChecked = !serviceData.isServiceChecked;

          if (serviceData.isServiceChecked) {
            if (!selectedService.contains(serviceData)) {
              selectedService.add(serviceData);
            }
            if (!selectedServiceIdList.contains(serviceData.id.validate().toString())) {
              selectedServiceIdList.add(serviceData.id.validate().toString());
            }
          } else {
            selectedService.removeWhere((service) => service.id == serviceData.id);
            selectedServiceIdList.remove(serviceData.id.validate().toString());
          }

          widget.onSelectionChanged(selectedService, selectedServiceIdList);
          _updateTotalAmount();
        });
      },
      child: Container(
        decoration: boxDecorationWithRoundedCorners(
          backgroundColor: context.cardColor,
          borderRadius: radius(4),
          border: Border.all(
            color: serviceData.isServiceChecked ? context.primaryColor : borderColor,
            width: serviceData.isServiceChecked ? 1.5 : 0.5,
          ),
        ),
        margin: EdgeInsets.only(bottom: 8),
        padding: EdgeInsets.only(right: 16, top: 16, bottom: 16),
        child: Row(
          children: [
            Checkbox(
              value: serviceData.isServiceChecked,
              onChanged: (bool? value) {
                setState(() {
                  serviceData.isServiceChecked = value ?? false;

                  if (serviceData.isServiceChecked) {
                    if (!selectedService.contains(serviceData)) {
                      selectedService.add(serviceData);
                    }
                    if (!selectedServiceIdList.contains(serviceData.id.validate().toString())) {
                      selectedServiceIdList.add(serviceData.id.validate().toString());
                    }
                  } else {
                    selectedService.removeWhere((service) => service.id == serviceData.id);
                    selectedServiceIdList.remove(serviceData.id.validate().toString());
                  }

                  widget.onSelectionChanged(selectedService, selectedServiceIdList);
                  _updateTotalAmount();
                });
              },
            ),
            CachedImageWidget(
              url: serviceData.serviceImage.validate(),
              height: 44,
              width: 44,
              circle: true,
              radius: 4,
            ),
            12.width,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Marquee(child: Text(serviceData.name.validate(), style: boldTextStyle(size: 14))),
                Text( '${durationToString(serviceData.durationMin.validate())}', style: secondaryTextStyle(size: 12)),
              ],
            ).expand(),
            12.width,
            PriceWidget(
              price: serviceData.defaultPrice.validate(),
              color: context.primaryColor,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
