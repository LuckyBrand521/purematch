class MutualFriends {
  int id;
  String last_name;
  String first_name;
  String imageUrl;

  MutualFriends(this.id, this.first_name, this.last_name, this.imageUrl);

  MutualFriends.fromJson(Map<String, dynamic> json) {
    MutualFriends(
      this.id = json["id"] ?? 1,
      this.first_name = json["first_name"] ?? "New",
      this.last_name = json["last_name"] ?? " User",
      this.imageUrl = json["ProfilePictureId"] ?? "na",
    );
  }
}
