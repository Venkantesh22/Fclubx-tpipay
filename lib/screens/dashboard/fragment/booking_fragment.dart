import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frezka/components/app_scaffold.dart';
import 'package:frezka/components/loader_widget.dart';
// import 'package:frezka/utils/app_common.dart';
import 'package:frezka/utils/colors.dart';
import 'package:frezka/utils/common_base.dart';
import 'package:frezka/utils/custom_toast_widget.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

// import '../../../components/empty_error_state_widget.dart';
import '../../../main.dart';
import '../../../utils/constants.dart';
import '../../booking/booking_repository.dart';
import '../../booking/model/booking_status_response.dart';
import '../component/booking_list_component.dart';

class BookingFragment extends StatefulWidget {
  @override
  _BookingFragmentState createState() => _BookingFragmentState();
}

class _BookingFragmentState extends State<BookingFragment> {
  TextEditingController searchBookingCont = TextEditingController();

  FocusNode searchFocusNode = FocusNode();

  // Voice search
  SpeechToText speech = SpeechToText();
  String lastWords = '';

  Future<List<BookingStatusData>>? future;
  List<BookingStatusData> statusList = [];
  bool isSelected = bookingRequestStore.selectedBookingStatusList.contains(BookingStatusConst.ALL);

  @override
  void initState() {
    super.initState();
    init();

    statusList = [
      BookingStatusData(status: BookingStatusConst.ALL),
      BookingStatusData(status: BookingStatusConst.UPCOMING),
      BookingStatusData(status: BookingStatusConst.COMPLETED),
      BookingStatusData(status: BookingStatusConst.PENDING),
      BookingStatusData(status: BookingStatusConst.CANCELLED),
      BookingStatusData(status: BookingStatusConst.PAID),
      BookingStatusData(status: BookingStatusConst.UNPAID),
    ];

    /// ✅ Set default to "all"
    if (bookingRequestStore.selectedBookingStatusList.isEmpty) {
      bookingRequestStore.selectedBookingStatusList.add(BookingStatusConst.ALL);
    }

    // Rebuild when user types so the close icon visibility updates instantly
    searchBookingCont.addListener(() => setState(() {}));
  }

  String getBookingStatusKey({required String status}) {
    return BookingStatusConst.displayText[status] ?? status.capitalizeFirstLetter();
  }

  void init({bool flag = false}) async {
    //
    if (flag) setState(() {});
  }

  Future<List<BookingStatusData>>? fetchBookingStatusApi() {
    future = getBookingStatus();

    return future;
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  void startListening() async {
    bool available = await speech.initialize(onStatus: statusListener, onError: errorListener);

    if (available) {
      appStore.setSpeechStatus(true);
      lastWords = '';
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

  void resultListener(SpeechRecognitionResult result) {
    appStore.setSpeechStatus(false);
    if (result.finalResult) {
      lastWords = result.recognizedWords;
      searchBookingCont.text = lastWords;
      appStore.setLoading(true);
      onBookingListUpdate.call(searchBookingCont.text);
      setState(() {});
    }
  }

  void errorListener(SpeechRecognitionError error) {
    appStore.setSpeechStatus(false);
    log("Speech error: ${error.errorMsg} - ${error.permanent}");
  }

  void statusListener(String status) {
    setState(() {
      log("Speech status: $status");
    });

    if (status == 'done') {
      appStore.setSpeechStatus(false);
    }
  }

  @override
  void dispose() {
    searchBookingCont.removeListener(() {});
    searchBookingCont.dispose();
    searchFocusNode.dispose();
    appStore.setSpeechStatus(false);
    speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBarWidget: PreferredSize(
        preferredSize: Size(context.width(), 100),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              width: context.width(),
              height: 150,
              decoration: boxDecorationWithRoundedCorners(
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
                backgroundColor: context.primaryColor,
              ),
              child: appBarWidget(
                locale.booking,
                center: true,
                showBack: false,
                color: context.primaryColor,
                textColor: white,
                textSize: APPBAR_TEXT_SIZE,
              ).cornerRadiusWithClipRRectOnly(bottomLeft: 20, bottomRight: 20),
            ),
            Positioned(
              bottom: -20,
              left: 20,
              right: 20,
              child: AppTextField(
                controller: searchBookingCont,
                textFieldType: TextFieldType.OTHER,
                focus: searchFocusNode,
                suffix: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () {
                        hideKeyboard(context);
                        searchBookingCont.clear();
                        appStore.setLoading(true);
                        onBookingListUpdate.call(searchBookingCont.text);
                        setState(() {});
                      },
                      child: Icon(Icons.close, color: context.iconColor)
                    ).visible(searchBookingCont.text.isNotEmpty),
                    6.width.visible(searchBookingCont.text.isNotEmpty),
                    GestureDetector(
                      onTap: () {
                        startListening();
                      },
                      child: Icon(Icons.mic_none_outlined, color: context.iconColor)),
                    12.width.visible(searchBookingCont.text.isNotEmpty),
                  ],
                ),
                onChanged: (s) {
                  appStore.setLoading(true);
                  onBookingListUpdate.call(searchBookingCont.text);
                  setState(() {});
                },
                decoration: inputDecoration(context, hint: locale.searchBooking, prefixIcon: Icon(Icons.search, color: context.iconColor)),
              ),
            )
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          40.height,
          if (statusList.isNotEmpty)
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                // no vertical padding
                itemCount: statusList.length,
                separatorBuilder: (_, __) => 12.width,
                itemBuilder: (context, index) {
                  return Observer(builder: (_) {
                    BookingStatusData statusData = statusList[index];
                    bool isSelected = bookingRequestStore.selectedBookingStatusList.contains(statusData.status);

                    return GestureDetector(
                      onTap: () {
                        if (statusData.status == BookingStatusConst.ALL) {
                          bookingRequestStore.selectedBookingStatusList = [BookingStatusConst.ALL];
                        } else if (isSelected) {
                          bookingRequestStore.selectedBookingStatusList = [BookingStatusConst.ALL];
                        } else {
                          bookingRequestStore.selectedBookingStatusList = [statusData.status.validate()];
                        }
                        if (bookingRequestStore.selectedBookingStatusList.isEmpty) {
                          bookingRequestStore.selectedBookingStatusList.add(BookingStatusConst.ALL);
                        }

                        appStore.setLoading(true);
                        onBookingListUpdate.call('');
                        setState(() {});
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 7),
                        decoration: BoxDecoration(
                          color: isSelected ? appStore.isDarkMode? transparentColor: primaryLightColor : context.cardColor,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: isSelected ? context.primaryColor : borderColor,
                            width: 0.5,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          getBookingStatusKey(status: statusData.status.validate()).split(' ').map((word) => word.isNotEmpty ? word[0].toUpperCase() + word.substring(1).toLowerCase() : '').join(' '),
                          style: primaryTextStyle(
                              size: 12,
                              weight: FontWeight.w600,
                              color: isSelected
                                  ? context.primaryColor
                                  : appStore.isDarkMode
                                      ? Colors.white
                                      : textSecondaryColorGlobal)
                        ),
                      ),
                    );
                  });
                },
              ),
            ),
          12.height,
          Expanded(
            child: Stack(
              children: [
                BookingListComponent(),
                Observer(builder: (context) => LoaderWidget().visible(bookingRequestStore.isLoading)),
              ],
            ),
          ),
        ],
      ),
    );
  }

// void handleFilterClick(BuildContext context) {
//   doIfLoggedIn(context, () {
//     serviceCommonBottomSheet(
//       context,
//       title: 'locale.filters',
//       child: Container(
//         width: context.width(),
//         constraints: BoxConstraints(minWidth: context.height() * 0.65, maxHeight: context.height() * 0.45),
//         decoration: BoxDecoration(
//           color: context.scaffoldBackgroundColor,
//           borderRadius: BorderRadius.only(topLeft: Radius.circular(30.0), topRight: Radius.circular(30.0)),
//         ),
//         child: SnapHelperWidget<List<BookingStatusData>>(
//           future: fetchBookingStatusApi(),
//           initialData: bookingStatusListCached,
//           loadingWidget: LoaderWidget(),
//           errorBuilder: (error) {
//             return NoDataWidget(
//               title: error,
//               retryText: locale.reload,
//               imageWidget: ErrorStateWidget(),
//               onRetry: () {
//                 appStore.setLoading(true);
//
//                 fetchBookingStatusApi();
//                 setState(() {});
//               },
//             );
//           },
//           onSuccess: (statusList) {
//             if (statusList.isEmpty) {
//               return NoDataWidget(
//                 title: locale.noTimeSlots,
//                 retryText: locale.reload,
//                 onRetry: () {
//                   appStore.setLoading(true);
//
//                   fetchBookingStatusApi();
//                   setState(() {});
//                 },
//               );
//             }
//
//             return Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 30.height,
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(locale.filterBy, style: primaryTextStyle(size: 18)).paddingOnly(left: 25),
//                     CloseButton(
//                       onPressed: () {
//                         hideKeyboard(context);
//                         finish(context);
//                       },
//                     ).paddingOnly(right: 16),
//                   ],
//                 ),
//                 10.height,
//                 Divider(color: context.dividerColor, height: 0).paddingSymmetric(horizontal: 16),
//                 22.height,
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(locale.bookingStatus, style: secondaryTextStyle()).paddingSymmetric(horizontal: 16),
//                     16.height,
//                     AnimatedWrap(
//                       runSpacing: 10,
//                       spacing: 10,
//                       itemCount: statusList.length,
//                       listAnimationType: ListAnimationType.None,
//                       itemBuilder: (context, index) {
//                         BookingStatusData statusData = statusList[index];
//
//                         return Observer(builder: (context) {
//                           return GestureDetector(
//                             onTap: () {
//                               if (bookingRequestStore.selectedBookingStatusList.contains(statusData.status)) {
//                                 bookingRequestStore.selectedBookingStatusList.remove(statusData.status);
//                               } else {
//                                 bookingRequestStore.selectedBookingStatusList.add(statusData.status.validate());
//                               }
//                             },
//                             child: Container(
//                               width: context.width() / 3.7,
//                               alignment: Alignment.center,
//                               padding: EdgeInsets.symmetric(vertical: 12),
//                               decoration: boxDecorationDefault(
//                                 color: bookingRequestStore.selectedBookingStatusList.contains(statusData.status)
//                                     ? appStore.isDarkMode
//                                         ? primaryColor
//                                         : lightPrimaryColor
//                                     : appStore.isDarkMode
//                                         ? primaryColor.withValues(alpha: 0.1)
//                                         : Colors.grey.shade100,
//                               ),
//                               child: Row(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   Icon(
//                                     Icons.check,
//                                     size: 14,
//                                     color: Colors.white,
//                                   ).visible(bookingRequestStore.selectedBookingStatusList.contains(statusData.status)),
//                                   4.width.visible(bookingRequestStore.selectedBookingStatusList.contains(statusData.status)),
//                                   Text(
//                                     getBookingStatusKey(status: statusData.status.validate()),
//                                     style: secondaryTextStyle(
//                                       color: bookingRequestStore.selectedBookingStatusList.contains(statusData.status) ? Colors.white : null,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           );
//                         });
//                       },
//                     ).paddingSymmetric(horizontal: 16).expand(),
//                     16.height,
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: [
//                         AppButton(
//                           text: locale.clearFilter,
//                           textStyle: boldTextStyle(color: Colors.white),
//                           color: secondaryColor,
//                           onTap: () {
//                             bookingRequestStore.selectedBookingStatusList.clear();
//                             finish(context);
//                             appStore.setLoading(true);
//                             onBookingListUpdate.call('');
//                           },
//                         ).expand(),
//                         16.width,
//                         AppButton(
//                           text: locale.apply,
//                           textStyle: boldTextStyle(color: Colors.white),
//                           color: primaryColor,
//                           onTap: () {
//                             finish(context);
//                             appStore.setLoading(true);
//                             onBookingListUpdate.call('');
//                           },
//                         ).expand(),
//                       ],
//                     ).paddingOnly(left: 16, right: 16, bottom: 16),
//                   ],
//                 ).expand(),
//               ],
//             );
//           },
//         ),
//       ),
//     );
//   });
// }
}
