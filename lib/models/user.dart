import 'dart:core';

import 'ImageObj.dart';
import 'mutual_friends.dart';

class User {
  String updatedAt;
  int id;
  String email;
  String last_name;
  String first_name;
  String birthday;
  int age;
  String my_spiritual_birthday;
  String gender;
  String height;
  String body_stat;
  String church;
  String organization_name;
  bool seeking_church;
  bool restrict_matches_to_organization;
  int church_visibility;
  List<String> ethnicity;
  String education;
  String school_name;
  String position;
  String employer;
  int employment_visibility;
  bool self_employed;
  String kids_have;
  String kids_want;
  int no_of_kids;
  String referral_email;
  String about_me;
  int about_me_visibility;
  String location;
  int location_visibility;
  String favorite_verse;
  int favorite_verse_visibility;
  List<String> interests;
  List<ImageObj> userImages;
  int interests_visibility;
  String personality_type;
  String marital_status;
  String imageUrl;
  String status;
  String role;
  Preferences preferences;
  int friend_match_id;
  int friend_request_id;
  String spiritual_age;
  List<MutualFriends> mutualFriends;

  String get fullName => "$first_name $last_name".trim();

  User.smallUser(
      this.first_name,
      this.last_name,
      this.status,
      this.imageUrl,
      this.age,
      this.height,
      this.kids_have,
      this.kids_want,
      this.no_of_kids,
      this.location,
      this.church,
      this.school_name,
      this.position,
      this.employer,
      this.self_employed,
      this.education);

  User(
      this.updatedAt,
      this.id,
      this.email,
      this.last_name,
      this.first_name,
      this.birthday,
      this.age,
      this.my_spiritual_birthday,
      this.gender,
      this.height,
      this.body_stat,
      this.church,
      this.organization_name,
      this.seeking_church,
      this.restrict_matches_to_organization,
      this.church_visibility,
      this.ethnicity,
      this.education,
      this.school_name,
      this.position,
      this.employer,
      this.employment_visibility,
      this.self_employed,
      this.kids_have,
      this.kids_want,
      this.no_of_kids,
      this.referral_email,
      this.about_me,
      this.about_me_visibility,
      this.location,
      this.location_visibility,
      this.favorite_verse,
      this.favorite_verse_visibility,
      this.interests,
      this.interests_visibility,
      this.personality_type,
      this.marital_status,
      this.imageUrl,
      this.status,
      this.role,
      this.preferences,
      this.friend_match_id,
      this.friend_request_id,
      this.spiritual_age,
      this.mutualFriends,
      this.userImages);

  User.likedUser(Map<String, dynamic> json) {
    User(
        this.updatedAt = (json ?? {})['updatedAt'] ?? "",
        this.id = json["UserId"],
        this.email = (json ?? {})['email'] ?? "na",
        this.last_name = json["User"]["last_name"],
        this.first_name = json["User"]["first_name"],
        this.birthday = (json ?? {})['birthday'] ?? "na",
        this.age = age ?? (json ?? {})['age'],
        this.my_spiritual_birthday =
            (json ?? {})['my_spiritual_birthday'] ?? "na",
        this.gender = (json ?? {})['gender'] ?? "na",
        this.height = (json ?? {})['height'] ?? "na",
        this.body_stat = (json ?? {})['body_stat'] ?? "na",
        this.church = (json ?? {})['church'] ?? "na",
        this.organization_name = (json ?? {})['organization_name'] ?? "na",
        this.seeking_church = (json ?? {})['seeking_church'] ?? false,
        this.restrict_matches_to_organization =
            (json ?? {})['restrict_matches_to_organization'] ?? false,
        this.church_visibility = (json ?? {})['church_visibility'] ?? -1,
        this.ethnicity = (json ?? {})['ethnicity']?.cast<String>(),
        this.education = (json ?? {})['education'] ?? "na",
        this.school_name = (json ?? {})['school_name'] ?? "na",
        this.position = (json ?? {})['position'] ?? "na",
        this.employer = (json ?? {})['employer'] ?? "na",
        this.employment_visibility =
            (json ?? {})['employment_visibility'] ?? -1,
        this.self_employed = (json ?? {})['self_employed'] ?? false,
        this.kids_have = (json ?? {})['kids_have'],
        this.kids_want = (json ?? {})['kids_want'],
        this.no_of_kids = (json ?? {})['no_of_kids'],
        this.referral_email = (json ?? {})['referral_email'] ?? "na",
        this.about_me = (json ?? {})['about_me'] ?? "na",
        this.about_me_visibility = (json ?? {})['about_me_visibility'] ?? -1,
        this.location = (json ?? {})['location'] ?? "na",
        this.location_visibility = (json ?? {})['location_visibility'] ?? -1,
        this.favorite_verse = (json ?? {})['favorite_verse'] ?? "na",
        this.favorite_verse_visibility =
            (json ?? {})['favorite_verse_visibility'] ?? -1,
        this.interests = (json ?? {})['interests']?.cast<String>(),
        this.interests_visibility = (json ?? {})['interests_visibility'] ?? -1,
        this.personality_type = (json ?? {})['personality_type'] ?? "na",
        this.marital_status = (json ?? {})['marital_status'] ?? "na",
        this.imageUrl = (json ?? {})['ProfilePictureId'] ?? "na",
        this.status = (json ?? {})['status'] ?? "na",
        this.role = (json ?? {})['role'] ?? "na",
        this.preferences = (json ?? {})['preferences'] != null
            ? Preferences.fromJson((json ?? {})['preferences'])
            : null,
        this.friend_match_id = friend_match_id,
        this.friend_request_id = friend_request_id,
        this.spiritual_age = json["User"]["spiritualAge"] ?? "",
        this.mutualFriends = [],
        this.userImages = []);
  }

  User.fromJson(Map<String, dynamic> jsonBody) {
    try {
      List<MutualFriends> mf = [];
      if (jsonBody["mutualFriends"] != null) {
        var friends = jsonBody["mutualFriends"] as List<dynamic>;
        for (var mutualfriends in friends) {
          MutualFriends mutuals = MutualFriends.fromJson(mutualfriends);
          mf.add(mutuals);
        }
      }

      Map json = jsonBody['user'] as Map<String, dynamic>;

      if (json == null) json = jsonBody;
      List<ImageObj> imageList = [null, null, null, null, null, null, null, null];
      if (json["Upload"] != null) {
        var images = json["Upload"] as List<dynamic>;
        for (var img in images) {
          ImageObj imgObj = ImageObj.fromJson(img);
          if (imgObj.tag == 0) {
            imageList[0] = imgObj;
          } else if (imgObj.tag == 1) {
            imageList[1] = imgObj;
          } else if (imgObj.tag == 2) {
            imageList[2] = imgObj;
          } else if (imgObj.tag == 3) {
            imageList[3] = imgObj;
          } else if (imgObj.tag == 4) {
            imageList[4] = imgObj;
          } else if (imgObj.tag == 5) {
            imageList[5] = imgObj;
          } else if (imgObj.tag == 6) {
            imageList[6] = imgObj;
          } else if (imgObj.tag == 7) {
            imageList[7] = imgObj;
          }
        }
      }
      int age = jsonBody['age'];

      String spiritualAge = (jsonBody ?? {})['spiritual_age'].toString();
      int friend_match_id = jsonBody['friendMatchId'];
      int friend_request_id = jsonBody['friendReqId'];
      if (json["birthday"] != null && json["birthday"] != "Invalid date")
        age = (DateTime.now()
                    .difference(DateTime.parse(json["birthday"]))
                    .inDays /
                365)
            .floor();
      User(
        this.updatedAt = (json ?? {})['updatedAt'] ?? "",
        this.id = (json ?? {})['id'] ?? (json ?? {})['UserId'] ?? -1,
        this.email = (json ?? {})['email'] ?? "na",
        this.last_name = (json ?? {})['last_name'] ?? "na",
        this.first_name = (json ?? {})['first_name'] ?? "na",
        this.birthday = (json ?? {})['birthday'] ?? "na",
        this.age = age ?? (json ?? {})['age'],
        this.my_spiritual_birthday =
            (json ?? {})['my_spiritual_birthday'] ?? "na",
        this.gender = (json ?? {})['gender'] ?? "na",
        this.height = (json ?? {})['height'] ?? "na",
        this.body_stat = (json ?? {})['body_stat'] ?? "na",
        this.church = (json ?? {})['church'] ?? "na",
        this.organization_name = (json ?? {})['organization_name'] ?? "na",
        this.seeking_church = (json ?? {})['seeking_church'] ?? false,
        this.restrict_matches_to_organization =
            (json ?? {})['restrict_matches_to_organization'] ?? false,
        this.church_visibility = (json ?? {})['church_visibility'] ?? -1,
        this.ethnicity = (json ?? {})['ethnicity']?.cast<String>(),
        this.education = (json ?? {})['education'] ?? "na",
        this.school_name = (json ?? {})['school_name'] ?? "na",
        this.position = (json ?? {})['position'] ?? "na",
        this.employer = (json ?? {})['employer'] ?? "na",
        this.employment_visibility =
            (json ?? {})['employment_visibility'] ?? -1,
        this.self_employed = (json ?? {})['self_employed'] ?? false,
        this.kids_have = (json ?? {})['kids_have'],
        this.kids_want = (json ?? {})['kids_want'],
        this.no_of_kids = (json ?? {})['no_of_kids'],
        this.referral_email = (json ?? {})['referral_email'] ?? "na",
        this.about_me = (json ?? {})['about_me'] ?? "na",
        this.about_me_visibility = (json ?? {})['about_me_visibility'] ?? -1,
        this.location = (json ?? {})['location'] ?? "na",
        this.location_visibility = (json ?? {})['location_visibility'] ?? -1,
        this.favorite_verse = (json ?? {})['favorite_verse'] ?? "na",
        this.favorite_verse_visibility =
            (json ?? {})['favorite_verse_visibility'] ?? -1,
        this.interests = (json ?? {})['interests']?.cast<String>(),
        this.interests_visibility = (json ?? {})['interests_visibility'] ?? -1,
        this.personality_type = (json ?? {})['personality_type'] ?? "na",
        this.marital_status = (json ?? {})['marital_status'] ?? "na",
        this.imageUrl = (json ?? {})['ProfilePictureId'] ?? "na",
        this.status = (json ?? {})['status'] ?? "na",
        this.role = (json ?? {})['role'] ?? "na",
        this.preferences = (json ?? {})['preferences'] != null
            ? Preferences.fromJson((json ?? {})['preferences'])
            : null,
        this.friend_match_id = friend_match_id,
        this.friend_request_id = friend_request_id,
        this.spiritual_age = spiritualAge ?? "",
        this.mutualFriends = mf ?? [],
        this.userImages = imageList ?? [],
      );
    } catch (e, stack) {
      print("stack $stack");
      print("User Deserialize catch error: $e}");
      throw e;
    }
  }
}

class Preferences {
  int UserId;
  String updatedAt;
  List<String> education;
  String from_height;
  String to_height;
  int from_age;
  int to_age;
  List<String> build;
  List<String> ethnicity;
  List<String> personality_type;
  List<String> kids_have;
  List<String> kids_want;
  List<String> location;
  int baptism_from_year;
  int baptism_to_year;
  int maxDistance;
  Preferences(
      this.UserId,
      this.updatedAt,
      this.education,
      this.from_height,
      this.to_height,
      this.from_age,
      this.to_age,
      this.build,
      this.ethnicity,
      this.personality_type,
      this.kids_have,
      this.kids_want,
      this.location,
      this.baptism_from_year,
      this.baptism_to_year,
      this.maxDistance);

  Preferences.fromJson(Map<String, dynamic> json) {
    Preferences(
        this.UserId = json['UserId'],
        this.updatedAt = json['updatedAt'],
        this.education = json['education']?.cast<String>(),
        this.from_height = json['from_height'],
        this.to_height = json['to_height'],
        this.from_age = json['from_age'],
        this.to_age = json['to_age'],
        this.build = json['build']?.cast<String>(),
        this.ethnicity = json['ethnicity']?.cast<String>(),
        this.personality_type = json['personality_type']?.cast<String>(),
        this.kids_have = json['kids_have']?.cast<String>(),
        this.kids_want = json['kids_want']?.cast<String>(),
        this.location = json['location']?.cast<String>(),
        this.baptism_from_year = json['baptism_from_year'],
        this.baptism_to_year = json['baptism_to_year'],
        this.maxDistance = json['max_distance']);
  }
}
