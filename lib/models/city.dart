class City {
  int cityId;
  String cityName;
  String adminCode;
  String country;

  City(
    this.cityId,
    this.cityName,
    this.adminCode,
    this.country,
  );

  City.fromJson(Map<String, dynamic> json) {
    try {
      this.cityId = json["cityId"];
      this.cityName = json["name"];
      this.adminCode = json["adminCode"];
      this.country = json["country"];
    } catch (e, postErroStackTrac) {
      print("postErroStackTrac $postErroStackTrac");
      print("post deserialise error:$e");
      throw e;
    }
  }
}
