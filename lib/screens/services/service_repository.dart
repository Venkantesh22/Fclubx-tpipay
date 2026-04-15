import 'package:frezka/screens/services/models/service_response.dart';
import 'package:frezka/utils/api_end_points.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../main.dart';
import '../../network/network_utils.dart';
import '../../utils/constants.dart';

Future<List<ServiceListData>> getServiceList({
  int? branchId,
  String categoryId = '',
  String subCategoryId = '',
  String search = '',
  int page = 1,
  var perPage = PER_PAGE_ITEM,
  required List<ServiceListData> list,
  Function(bool)? lastPageCallBack,
}) async {
  try {
    String req;

    String searchPara = search.isNotEmpty ? '&${APIParamKeysConst.search}=$search' : '';

    if (subCategoryId.isNotEmpty) {
      req = subCategoryId != "-1" ? '&${APIParamKeysConst.subCategoryId}=$subCategoryId' : '';
    } else {
      req = categoryId.isNotEmpty ? '&${APIParamKeysConst.categoryId}=$categoryId' : '';
    }

    ServiceResponse res = ServiceResponse.fromJson(await handleResponse(await buildHttpResponse(
      '${APIEndPoints.serviceList}?${APIParamKeysConst.branchId}=$branchId$req$searchPara&${APIParamKeysConst.perPage}=$perPage&${APIParamKeysConst.page}=$page',
      method: HttpMethodType.GET,
    )));
    if (page == 1) list.clear();
    list.addAll(res.data.validate());

    lastPageCallBack?.call(res.data.validate().length != perPage);

    appStore.setLoading(false);
  } catch (e) {
    appStore.setLoading(false);
    throw e;
  }
  return list;
}

Future<ServiceData?> getServiceDetail(int serviceId, int branchId) async {
  var res = ServiceDetailsResponse.fromJson(
    await handleResponse(
      await buildHttpResponse(
        '${APIEndPoints.getServiceDetails}?${APIParamKeysConst.serviceId}=$serviceId&${APIParamKeysConst.branchId}=$branchId',
        method: HttpMethodType.GET,
      ),
    ),
  );
  return res.data;
}
