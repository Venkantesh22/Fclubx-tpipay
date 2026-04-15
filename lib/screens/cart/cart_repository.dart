import 'package:frezka/models/base_response_model.dart';
import 'package:frezka/screens/cart/model/city_list_response.dart';
import 'package:frezka/screens/cart/model/country_list_response.dart';
import 'package:frezka/screens/cart/model/logistic_zone_response.dart';
import 'package:frezka/screens/cart/model/state_list_response.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../main.dart';
import '../../network/network_utils.dart';
import '../../utils/api_end_points.dart';
import '../../utils/constants.dart';
import 'model/address_list_response.dart';
import 'model/cart_list_response.dart';
import 'model/cart_response.dart';

Future<CartResponse> addToCart(request) async {
  // Check if user is authenticated before making API call
  if (!appStore.isLoggedIn || userStore.token.isEmpty) {
    throw "User not authenticated. Please login first.";
  }
  return CartResponse.fromJson(await handleResponse(await buildHttpResponse(APIEndPoints.addToCart, request: request, method: HttpMethodType.POST)));
}

Future<BaseResponseModel> updateCart(request) async {
  // Check if user is authenticated before making API call
  if (!appStore.isLoggedIn || userStore.token.isEmpty) {
    throw "User not authenticated. Please login first.";
  }
  return BaseResponseModel.fromJson(await handleResponse(await buildHttpResponse(APIEndPoints.updateCart, request: request, method: HttpMethodType.POST)));
}

Future<CartResponse> removeFromCart({required int cartId}) async {
  // Check if user is authenticated before making API call
  if (!appStore.isLoggedIn || userStore.token.isEmpty) {
    throw "User not authenticated. Please login first.";
  }
  return CartResponse.fromJson(await handleResponse(await buildHttpResponse('${APIEndPoints.removeFromCart}?${APIParamKeysConst.cartId}=$cartId', method: HttpMethodType.GET)));
}

Future<(List<CartListData>, CartListResponse)> getCartList({
  int page = 1,
  var perPage = PER_PAGE_ITEM,
  required (List<CartListData>, CartListResponse) cartList,
  Function(bool)? lastPageCallBack,
}) async {
  try {
    // Check if user is authenticated before making API call
    if (!appStore.isLoggedIn || userStore.token.isEmpty) {
      log("User not authenticated, skipping cart list API call");
      appStore.setLoading(false);
      return cartList;
    }

    var res = CartListResponse.fromJson(await handleResponse(await buildHttpResponse(APIEndPoints.getCartList, method: HttpMethodType.GET)));

    if (page == 1) cartList.$1.clear();
    cartList.$1.addAll(res.data.validate());
    cartList.$2.cartPriceData = res.cartPriceData;

    // Set the cart price data in product store to preserve tax data
    if (res.cartPriceData != null) {
      productStore.setCartPriceData(res.cartPriceData!);
    }

    productStore.setCartItemCount(cartList.$1.length);

    lastPageCallBack?.call(res.data.validate().length != perPage);

    appStore.setLoading(false);

    return cartList;
  } catch (e) {
    appStore.setLoading(false);
    // If it's an authentication error, don't throw it, just return empty cart
    if (e.toString().contains('Unauthenticated') || e.toString().contains('401')) {
      log("Authentication error in getCartList, returning empty cart");
      return cartList;
    }
    throw e;
  }
}

Future<List<UserAddress>> getAddressList({
  int page = 1,
  var perPage = PER_PAGE_ITEM,
  required List<UserAddress> addressList,
  Function(bool)? lastPageCallBack,
}) async {
  try {
    var res = AddressListResponse.fromJson(
        await handleResponse(await buildHttpResponse(APIEndPoints.getAddressList + "?${APIParamKeysConst.perPage}=$perPage&${APIParamKeysConst.page}=$page", method: HttpMethodType.GET)));

    if (page == 1) addressList.clear();
    addressList.addAll(res.userAddress.validate());

    lastPageCallBack?.call(res.userAddress.validate().length != perPage);

    appStore.setLoading(false);

    return addressList;
  } catch (e) {
    appStore.setLoading(false);
    throw e;
  }
}

Future<BaseResponseModel> removeAddress({required int addressId}) async {
  return BaseResponseModel.fromJson(await handleResponse(await buildHttpResponse('${APIEndPoints.removeAddress}?id=$addressId', method: HttpMethodType.GET)));
}

Future<BaseResponseModel> addEditAddress({required Map request, bool isEdit = false}) async {
  return BaseResponseModel.fromJson(await handleResponse(await buildHttpResponse(isEdit ? APIEndPoints.editAddress : APIEndPoints.addAddress, request: request, method: HttpMethodType.POST)));
}

Future<List<CountryData>> getCountryList() async {
  var res = CountryListResponse.fromJson(await handleResponse(await buildHttpResponse(APIEndPoints.countryList, method: HttpMethodType.GET)));
  appStore.setLoading(false);

  return res.data.validate();
}

Future<List<StateData>> getStateList({required int countryId}) async {
  var res = StateListResponse.fromJson(await handleResponse(await buildHttpResponse('${APIEndPoints.stateList}?${APIParamKeysConst.countryId}=$countryId', method: HttpMethodType.GET)));
  appStore.setLoading(false);

  return res.data.validate();
}

Future<List<CityData>> getCityList({required int stateId}) async {
  var res = CityListResponse.fromJson(await handleResponse(await buildHttpResponse('${APIEndPoints.cityList}?${APIParamKeysConst.stateId}=$stateId', method: HttpMethodType.GET)));
  appStore.setLoading(false);

  return res.data.validate();
}

List<LogisticZoneData> zoneList = [];

Future<List<LogisticZoneData>> getLogisticZone({required int addressId}) async {
  try {
    var res = LogisticZoneResponse.fromJson(await handleResponse(await buildHttpResponse('${APIEndPoints.getLogisticZoneList}?${APIParamKeysConst.addressId}=$addressId', method: HttpMethodType.GET)));
    appStore.setLoading(false);
    zoneList = res.zoneList.validate();
    return res.data.validate();
  } catch (e) {
    appStore.setLoading(false);
    throw e;
  }
}
