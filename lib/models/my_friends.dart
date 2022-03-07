class MyFriends {
  int id;
  String first_name;
  String last_name;
  String ProfilePictureId;
  int mutualConnections;
  MyFriends(this.id, this.first_name, this.last_name, this.ProfilePictureId,
      this.mutualConnections);

  MyFriends.fromJson(Map<String, dynamic> json) {
    MyFriends(
      this.id = json["id"] ?? 1,
      this.first_name = json["first_name"] ?? "New",
      this.last_name = json["last_name"] ?? " User",
      this.ProfilePictureId = json["ProfilePictureId"] ?? "na",
      this.mutualConnections = json["mutualConnections"] ?? 0,
    );
  }
}
