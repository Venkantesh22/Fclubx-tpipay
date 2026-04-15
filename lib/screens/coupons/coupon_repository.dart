import 'package:frezka/network/network_utils.dart';
import 'package:frezka/screens/coupons/model/coupon_details_model.dart';
import 'package:frezka/screens/coupons/model/coupon_list_model.dart';
import 'package:frezka/utils/api_end_points.dart';
import 'package:frezka/utils/constants.dart';
import 'package:nb_utils/nb_utils.dart';

Future<CouponListModel> getCouponListData() async {
  return CouponListModel.fromJson(await handleResponse(await buildHttpResponse(APIEndPoints.getPromotionList, method: HttpMethodType.GET)));
}
Future<CouponDetailsModel> getCouponData({required String couponCode}) async {
  return CouponDetailsModel.fromJson(await handleResponse(await buildHttpResponse("${APIEndPoints.getPromotionDetails}?${APIParamKeysConst.couponCode}=$couponCode", method: HttpMethodType.GET)));
}
