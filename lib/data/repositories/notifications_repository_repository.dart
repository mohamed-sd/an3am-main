import 'dart:developer';

import 'package:an3am/data/model/data_output.dart';
import 'package:an3am/data/model/notification_data.dart';
import 'package:an3am/utils/api.dart';

class NotificationsRepository {
  Future<DataOutput<NotificationData>> fetchNotifications(
      {required int page}) async {
    try {
      Map<String, dynamic> parameters = {
        Api.page: page,
      };
      Map<String, dynamic> response = await Api.get(
          url: Api.getNotificationListApi, queryParameters: parameters);

      List<NotificationData> modelList = (response['data']['data'] as List).map(
        (e) {
          return NotificationData.fromJson(e);
        },
      ).toList();

      return DataOutput(total: response['data']['total'], modelList: modelList);
    } catch (e, stack) {
      log(e.toString());
      log('$stack');
      rethrow;
    }
  }
}
