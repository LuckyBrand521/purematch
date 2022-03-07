import 'package:pure_match/common/global.dart';

class MatchCard {
  int id;
  String image;
  String firstName;
  int age;
  String location;
  String height;
  String church;
  bool isLiked;
  bool isPassed;
  MatchCard(
    this.id,
    this.image,
    this.firstName,
    this.age,
    this.location,
    this.height,
    this.church,
    this.isLiked,
    this.isPassed,
  );

  get heightInInches {
    if (this.height == null || this.height == 0) return "";
    String height = HeightConfig.heightFoot(this.height);
    return height;
  }

  MatchCard.fromJson(Map<String, dynamic> json) {
    MatchCard(
        this.id = json["id"] ?? 1,
        this.image = json["ProfilePictureId"] ??
            "https://i.pinimg.com/564x/19/b8/d6/19b8d6e9b13eef23ec9c746968bb88b1.jpg",
        this.firstName = json["first_name"] ?? "preet",
        this.age = json["age"] ?? 23,
        this.location = json["location"] ?? "Testland,PM",
        this.height = json["height"] ?? "63",
        this.church = json["church"] ?? "Check",
        this.isLiked = false,
        this.isPassed = false);
  }
}
