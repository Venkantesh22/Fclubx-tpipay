import 'dart:convert';

import 'package:frezka/screens/order/model/order_list_response.dart';
import 'package:frezka/screens/order/model/order_status_response.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../main.dart';
import '../../models/base_response_model.dart';
import '../../network/network_utils.dart';
import '../../utils/api_end_points.dart';
import '../../utils/constants.dart';
import '../../utils/model_keys.dart';
import 'model/order_detail_response.dart';

Future<List<OrderStatusData>> getOrderStatus() async {
  try {
    var res = OrderStatusResponse.fromJson(await handleResponse(await buildHttpResponse(APIEndPoints.getOrderStatusList, method: HttpMethodType.GET)));
    appStore.setLoading(false);

    orderStatusListCached = res.data;

    return res.data.validate();
  } catch (e) {
    appStore.setLoading(false);
    throw e;
  }
}

Future<dynamic> updateOrderReview({
  List<XFile>? files,
  String reviewId = '',
  String productId = '',
  String productVariationId = '',
  String rating = '',
  String reviewMsg = '',
  Function(dynamic)? onSuccess,
}) async {
  if (appStore.isLoggedIn) {
    MultipartRequest multiPartRequest = await getMultiPartRequest('${reviewId.isNotEmpty ? APIEndPoints.updateReview : APIEndPoints.addReview}');

    if (reviewId.isNotEmpty) multiPartRequest.fields[ProductModelKey.reviewId] = reviewId;
    if (productId.isNotEmpty) multiPartRequest.fields[ProductModelKey.productId] = productId;
    if (productVariationId.isNotEmpty) multiPartRequest.fields[ProductModelKey.productVariationId] = productVariationId;
    if (rating.isNotEmpty) multiPartRequest.fields["rating"] = rating;
    if (reviewMsg.isNotEmpty) multiPartRequest.fields["review_msg"] = reviewMsg;

    if (files.validate().isNotEmpty) {
      multiPartRequest.files.addAll(await getMultipartImages2(files: files.validate(), name: 'gallery'));
    }
    log("Multipart ${jsonEncode(multiPartRequest.fields)}");
    log("Multipart Images ${multiPartRequest.files.map((e) => e.filename)}");

    multiPartRequest.headers.addAll(buildHeaderTokens());

    await sendMultiPartRequest(
      multiPartRequest,
      onSuccess: (data) async {
        onSuccess?.call(data);
      },
      onError: (error) {
        throw error;
      },
    ).catchError((error) {
      throw error;
    });
  }
}

Future<BaseResponseModel> deleteOrderReview({required int id}) async {
  return BaseResponseModel.fromJson(await handleResponse(await buildHttpResponse('${APIEndPoints.removeReview}?${APIParamKeysConst.reviewId}=$id', method: HttpMethodType.GET)));
}

Future placeOrderAPI(Map request) async {
  return await handleResponse(await buildHttpResponse(APIEndPoints.placeOrder, request: request, method: HttpMethodType.POST));
}

Future orderUpdate({required int orderId}) async {
  return await handleResponse(await buildHttpResponse('${APIEndPoints.cancelOrder}?${APIParamKeysConst.id}=$orderId', method: HttpMethodType.GET));
}

Future<OrderDetailResponse> getOrderDetail({required int orderId}) async {
  try {
    var res = OrderDetailResponse.fromJson(await handleResponse(await buildHttpResponse('${APIEndPoints.getOrderDetails}?${APIParamKeysConst.orderId}=$orderId', method: HttpMethodType.GET)));
    appStore.setLoading(false);

    if (orderDetailCached.any((element) => element.id == res.data!.id)) {
      orderDetailCached.removeWhere((element) => element.id == res.data!.id);
    }
    orderDetailCached.add(res.data!);

    return res;
  } catch (e) {
    appStore.setLoading(false);
    throw e;
  }
}

Future<List<OrderListData>> getOrderList({
  String status = '',
  String paymentStatus = '',
  String search = '',
  int page = 1,
  var perPage = PER_PAGE_ITEM,
  required List<OrderListData> orders,
  Function(bool)? lastPageCallBack,
}) async {
  try {
    String statusData = status.isNotEmpty ? '${APIParamKeysConst.deliveryStatus}=$status&' : '';
    String paymentStatusData = paymentStatus.isNotEmpty ? '${APIParamKeysConst.paymentStatus}=$paymentStatus&' : '';

    String searchBooking = search.isNotEmpty ? '&${APIParamKeysConst.search}=$search&' : '';

    String perPages = '${APIParamKeysConst.perPage}=$perPage&';
    String pages = '${APIParamKeysConst.page}=$page';

    String apiUrl = '${APIEndPoints.getOrderList}?$statusData$paymentStatusData$searchBooking$perPages$pages';
    print('Order API URL: $apiUrl');
    print('Payment Status Filter: $paymentStatus');

    OrderListResponse res = OrderListResponse.fromJson(await handleResponse(await buildHttpResponse(
      apiUrl,
      method: HttpMethodType.GET,
    )));

    if (page == 1) orders.clear();
    List<OrderListData> filteredOrders = res.data.validate();

    // Apply client-side payment status filtering if needed
    if (paymentStatus.isNotEmpty && !status.isNotEmpty) {
      filteredOrders = _filterOrdersByPaymentStatus(filteredOrders, paymentStatus);
    }

    orders.addAll(filteredOrders);

    lastPageCallBack?.call(filteredOrders.length != perPage);

    appStore.setLoading(false);

    return orders;
  } catch (e) {
    appStore.setLoading(false);

    throw e;
  }
}

List<OrderListData> _filterOrdersByPaymentStatus(List<OrderListData> orders, String paymentStatus) {
  List<String> statusList = paymentStatus.split(',');

  return orders.where((order) {
    String? orderPaymentStatus = order.paymentStatus;
    if (orderPaymentStatus == null) return false;

    for (String status in statusList) {
      if (status.toLowerCase() == orderPaymentStatus.toLowerCase()) {
        return true;
      }
    }

    return false;
  }).toList();
}
