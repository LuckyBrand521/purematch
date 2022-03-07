class ImageObj {
  String id;
  int userId;
  String path;
  int tag;
  String createdAt;
  String updatedAt;

  ImageObj(this.id, this.userId, this.path, this.tag, this.createdAt,
      this.updatedAt);

  ImageObj.fromJson(Map<String, dynamic> json) {
    ImageObj(
        this.id = json["id"] ?? "na",
        this.userId = json["UserId"] ?? -1,
        this.path = json["path"] ?? "na",
        this.tag = json["tag"] ?? -1,
        this.createdAt = json["createdAt"] ?? "na",
        this.updatedAt = json["updatedAt"] ?? "na");
  }
}
