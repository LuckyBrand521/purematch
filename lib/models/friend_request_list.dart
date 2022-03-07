import 'package:pure_match/models/sender_request.dart';

class FriendRequestList {
  int id;
  int senderId;
  String status;
  Sender sender;
  int mutualConnections;
  FriendRequestList(
      this.id, this.senderId, this.status, this.sender, this.mutualConnections);

  FriendRequestList.fromJson(Map<String, dynamic> json) {
    FriendRequestList(
      this.id = json["id"] ?? 1,
      this.senderId = json["senderId"] ?? 1,
      this.status = json["status"] ?? "No Status",
      this.sender = Sender.fromJson(json["Sender"]) ?? "na",
      this.mutualConnections = json["mutualConnections"] ?? 0,
    );
  }
}
