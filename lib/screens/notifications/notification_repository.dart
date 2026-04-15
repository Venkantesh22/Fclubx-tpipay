import 'package:frezka/utils/api_end_points.dart';
import 'package:frezka/utils/constants.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../main.dart';
import '../../network/network_utils.dart';
import 'model/notification_model.dart';

//region Notification Api
Future<List<NotificationData>> getNotification({bool notificationType = false, Function(int)? callBack}) async {
  try {
    String type = notificationType ? '&${APIParamKeysConst.type}=${APIParamKeysConst.markAsRead}' : '';

    NotificationListResponse res = NotificationListResponse.fromJson(
      await (handleResponse(await buildHttpResponse('${APIEndPoints.notificationList}?${APIParamKeysConst.customerId}=${userStore.userId}$type', method: HttpMethodType.GET))),
    );

    appStore.setLoading(false);
    callBack?.call(res.allUnreadCount.validate());
    notificationListCached = res.notificationData.validate();
    return res.notificationData.validate();
  } catch (e) {
    appStore.setLoading(false);
    throw e;
  }
}
//endregion
