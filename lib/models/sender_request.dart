class Sender {
  String firstName;
  String lastName;
  String profilePicture;

  Sender(
    this.firstName,
    this.lastName,
    this.profilePicture,
  );

  Sender.fromJson(Map<String, dynamic> json) {
    Sender(
      this.firstName = json["first_name"] ?? "New",
      this.lastName = json["last_name"] ?? "User",
      this.profilePicture = json["ProfilePictureId"] ?? "na",
    );
  }
}
