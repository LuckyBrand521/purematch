import 'package:pure_match/common/global.dart';
import 'package:pure_match/models/sender_request.dart';

class FeedNotificationData {
  int notification_id;
  int id;
  int subId;
  Sender sender;
  String message;
  String _createdAt;
  String type;
  bool isRead;

  FeedNotificationData(this.notification_id, this.id, this.subId, this.sender,
      this.message, this._createdAt, this.type, this.isRead);

  String get createdAt {
    String time = "NA";
    time = Global.createdAt(this._createdAt);
    return time;
  }

  FeedNotificationData.fromJson(Map<String, dynamic> json) {
    FeedNotificationData(
      this.notification_id = json["notification_id"] ?? -1,
      this.id = json["data"]["id"] ?? -1,
      this.subId = json["data"]["subId"] ?? -1,
      this.sender = Sender.fromJson(json["sender"]) ?? "na",
      this.message = json["message"] ?? "No Message",
      this._createdAt = json["data"]["createdAt"] ?? "No Time",
      this.type = json["data"]["type"] ?? "Like",
      this.isRead = json["read"] ?? false,
    );
  }
}
