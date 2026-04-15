import 'package:frezka/screens/booking/model/booking_detail_response.dart';
import 'package:frezka/screens/booking/model/booking_list_response.dart';
import 'package:frezka/utils/api_end_points.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../main.dart';
import '../../network/network_utils.dart';
import '../../utils/constants.dart';
import '../order/model/order_status_response.dart';
import 'model/booking_status_response.dart';

Future<List<BookingStatusData>> getBookingStatus() async {
  try {
    var res = BookingStatusResponse.fromJson(await handleResponse(await buildHttpResponse(APIEndPoints.bookingStatus, method: HttpMethodType.GET)));
    appStore.setLoading(false);

    bookingStatusListCached = res.data;

    return res.data.validate();
  } catch (e) {
    appStore.setLoading(false);
    throw e;
  }
}

Future<BookingDetailResponse> getBookingDetail({required int bookingId}) async {
  try {
    var res = BookingDetailResponse.fromJson(await handleResponse(await buildHttpResponse('${APIEndPoints.bookingDetail}?id=$bookingId', method: HttpMethodType.GET)));
    appStore.setLoading(false);

    if (bookingDetailCached.any((element) => element.id == res.data!.id)) {
      bookingDetailCached.removeWhere((element) => element.id == res.data!.id);
    }
    bookingDetailCached.add(res.data!);

    return res;
  } catch (e) {
    appStore.setLoading(false);
    throw e;
  }
}

Future saveBookingAPI(Map request) async {
  return await handleResponse(await buildHttpResponse(APIEndPoints.saveBooking, request: request, method: HttpMethodType.POST));
}

Future bookingUpdate(Map request) async {
  return await handleResponse(await buildHttpResponse(APIEndPoints.bookingUpdate, request: request, method: HttpMethodType.POST));
}

Future<BookingStatusResponse> getInvoiceLink({required String bookingId}) async {
  return BookingStatusResponse.fromJson(await handleResponse(await buildHttpResponse("${APIEndPoints.bookingInvoiceDownload}?id=$bookingId", method: HttpMethodType.GET)));
}

Future<OrderStatusResponse> getOrderInvoiceLink({required String orderId}) async {
  print("Fetching PDF for order ID: $orderId");

  return OrderStatusResponse.fromJson(await handleResponse(await buildHttpResponse(
      "${APIEndPoints.orderInvoiceDownload}="
      "$orderId",
      method: HttpMethodType.GET)));
}

Future verifySlot(int employeeId, String startDateTime) async {
  Map request = {
    "employee_id": employeeId,
    "start_date_time": startDateTime,
  };
  return await handleResponse(await buildHttpResponse(APIEndPoints.verifySlot, request: request, method: HttpMethodType.POST));
}

Future<List<BookingListData>> getBookingList({
  int? branchId,
  int? userId,
  String status = '',
  String paymentStatus = '',
  String search = '',
  int page = 1,
  var perPage = PER_PAGE_ITEM,
  required List<BookingListData> bookings,
  Function(bool)? lastPageCallBack,
}) async {
  try {
    String statusData = status.isNotEmpty ? '&${APIParamKeysConst.status}=$status' : '';
    String paymentStatusData = paymentStatus.isNotEmpty ? '&${APIParamKeysConst.paymentStatus}=$paymentStatus' : '';
    String searchBooking = search.isNotEmpty ? '&${APIParamKeysConst.search}=$search' : '';
    String userIdParam = userId != null ? '&${APIParamKeysConst.userId}=$userId' : '';

    BookingListResponse res = BookingListResponse.fromJson(await handleResponse(await buildHttpResponse(
      '${APIEndPoints.bookingList}?${APIParamKeysConst.branchId}=$branchId$userIdParam$statusData$paymentStatusData$searchBooking&${APIParamKeysConst.perPage}=$perPage&${APIParamKeysConst.page}=$page',
      method: HttpMethodType.GET,
    )));

    if (page == 1) bookings.clear();
    List<BookingListData> filteredBookings = res.data.validate();
    if (paymentStatus.isNotEmpty && !status.isNotEmpty) {
      filteredBookings = _filterByPaymentStatus(filteredBookings, paymentStatus);
    }

    bookings.addAll(filteredBookings);

    lastPageCallBack?.call(filteredBookings.length != perPage);

    appStore.setLoading(false);
    return bookings;
  } catch (e) {
    appStore.setLoading(false);
    throw e;
  }
}

List<BookingListData> _filterByPaymentStatus(List<BookingListData> bookings, String paymentStatus) {
  List<String> statusList = paymentStatus.split(',');

  return bookings.where((booking) {
    if (booking.payment == null) return false;

    int? paymentStatusValue = booking.payment!.paymentStatus;
    if (paymentStatusValue == null) return false;

    for (String status in statusList) {
      if (status == BookingStatusConst.PAID && paymentStatusValue == 1) return true;
      if (status == BookingStatusConst.UNPAID && paymentStatusValue == 0) return true;
    }

    return false;
  }).toList();
}
