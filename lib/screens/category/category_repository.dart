import 'package:frezka/network/network_utils.dart';
import 'package:frezka/screens/category/model/category_response.dart';
import 'package:frezka/utils/api_end_points.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../main.dart';
import '../../utils/constants.dart';

Future<List<CategoryData>> getCategoryList({
  int? categoryId,
  String search = '',
  bool isStoreCached = false,
  int page = 1,
  var perPage = PER_PAGE_ITEM,
  required List<CategoryData> list,
  Function(bool)? lastPageCallBack,
}) async {
  try {
    String categoryParam = categoryId != null ? '${APIParamKeysConst.categoryId}=$categoryId&' : '';
    String searchParam = search.isNotEmpty ? '${APIParamKeysConst.search}=$search&' : '';
    String perPageParam = '${APIParamKeysConst.perPage}=$perPage&';
    String pageParam = '${APIParamKeysConst.page}=$page';

    CategoryResponse res = CategoryResponse.fromJson(
      await handleResponse(
        await buildHttpResponse(
          '${APIEndPoints.categoryList}?$categoryParam$searchParam$perPageParam$pageParam',
          method: HttpMethodType.GET,
        ),
      ),
    );

    if (page == 1) list.clear();
    list.addAll(res.category.validate());

    if (isStoreCached) {
      categoryListCached = list;
    }

    lastPageCallBack?.call(res.category.validate().length != perPage);

    appStore.setLoading(false);
  } catch (e) {
    appStore.setLoading(false);
    throw e;
  }
  return list;
}

