import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import 'package:pure_match/common/global.dart';
import 'package:pure_match/common/profile_basic_info.dart';
import 'package:pure_match/common/report_profile.dart';
import 'package:pure_match/pages/AppColors.dart';
import 'package:pure_match/pages/MyHttp.dart';
import 'package:pure_match/models/user.dart';
import 'package:pure_match/common/reason_to_report.dart';
import 'package:pure_match/pages/match/suggest_a_friend.dart';
import 'package:pure_match/pages/match/suggest_a_match.dart';
import 'package:pure_match/pages/onboarding/profile_info/enableNotification.dart';
import 'package:pure_match/pages/own_profile/edit_about_me.dart';
import 'package:pure_match/pages/own_profile/edit_favorite_verse.dart';
import 'package:pure_match/pages/own_profile/edit_interests.dart';
import 'package:pure_match/pages/own_profile/edit_profile_pictures.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:amplitude_flutter/amplitude.dart';
import 'package:pure_match/pages/own_profile/new_edit_profile_pictures.dart';

import 'constants.dart';

class Profile {
  // Analytics code
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';

  int userId;
  bool isEditable;
  bool isOnboarding;
  Color themeColor;
  bool isFriendRequestSent;
  bool friend;
  Function() onUpdateProfile;
  Profile(
      {int userId,
      bool isEditable,
      bool isOnboarding,
      Color themeColor,
      bool isFriendRequestSent,
      bool friend,
      Function() onUpdateProfile}) {
    this.userId = userId;
    this.isEditable = isEditable;
    this.themeColor = themeColor;
    this.isOnboarding = isOnboarding ?? false;
    this.onUpdateProfile = onUpdateProfile;
    //Initializing amplitude analytics api key
    amplitudeAnalytics.init(apiKey);

    this.isFriendRequestSent = isFriendRequestSent ?? false;
    this.friend = friend;
  }

  //sending request
  Future<bool> _sendFriendRequest(int toUserId) async {
    var res = await MyHttp.post("friends/request/${toUserId}", {});
    if (res.statusCode == 200 || res.statusCode == 201) {
      // Analytics tracking code
      var jsonData = jsonDecode(res.body);
      analytics.logEvent(
          name: "sent_friend_request",
          parameters: <String, dynamic>{
            'sent_by': jsonData["request"][0]["senderId"],
            'sent_to': toUserId
          });

      amplitudeAnalytics.logEvent("sent_friend_request", eventProperties: {
        'sent_by': jsonData["request"][0]["senderId"],
        'sent_to': toUserId
      });

      var body = json.decode(res.body);
      isFriendRequestSent == true;
      print(body);

      return body['success'] as bool;
    } else {
      print("User update error: ${res.statusCode}");
      print("User update error: ${res.body}");
      return false;
    }
  }

  Future<bool> _unfriend(int toUserId) async {
    var res = await MyHttp.post("friends/unfriend/${toUserId}", {});
    if (res.statusCode == 200) {
      // Analytics code
      analytics.logEvent(name: "unfriend_friend", parameters: <String, dynamic>{
        'sent_by': userId,
        'sent_to': toUserId
      });

      amplitudeAnalytics.logEvent("unfriend_friend",
          eventProperties: {'sent_by': userId, 'sent_to': toUserId});

      var body = json.decode(res.body);
      return body['success'] as bool;
    } else {
      print("User update error: ${res.statusCode}");
      print("User update error: ${res.body}");

      return false;
    }
  }

  void performSelectedProfileAction(
      profileOptions selectedOption, BuildContext context, User userDisplayed) {
    switch (selectedOption) {
      case profileOptions.suggestFriend:
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => SuggestAFriend(
                      user: userDisplayed,
                    )));

        break;
      case profileOptions.suggestMatch:
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => SuggestAMatch(
                      user: userDisplayed,
                    )));

        break;
      case profileOptions.sendMatchRequest:
        break;
      case profileOptions.sendFriendRequest:
        this._sendFriendRequest(userDisplayed.id).then((isSuccess) {
          isSuccess
              ? _alertUser(context, "Friend Request Sent",
                  "${userDisplayed.first_name} will be notified you want to be Friends.",
                  is_friend_request_sent: true)
              : _alertUser(context, "An error occurred", "Please try again!");
        });
        break;
      case profileOptions.unfriend:
        // show alert to unfriend, report or cancel
        showDialog(
            context: context,
            builder: (_) => PlatformAlertDialog(
                  title: Text("Unfriend"),
                  content: Text(
                      "Are you sure you want to Unfriend ${userDisplayed.first_name}?"),
                  material: (_, __) => MaterialAlertDialogData(
                    elevation: 1.0,
                    actions: <Widget>[
                      TextButton(
                        child: Text("Unfriend",
                            style: TextStyle(
                                color: Color.fromRGBO(255, 69, 58, 1),
                                fontWeight: FontWeight.w600)),
                        onPressed: () {
                          Navigator.of(context).pop();
                          this._unfriend(userDisplayed.id).then((isSuccess) =>
                              isSuccess
                                  ? _alertUser(context, "Unfriend Successful",
                                      "You are no longer friends with ${userDisplayed.first_name}.",
                                      is_unfriend: true)
                                  : _alertUser(context, "An error occurred",
                                      "Please try again!"));
                        },
                      ),
                      TextButton(
                        child: Text("Report User",
                            style: TextStyle(color: Colors.black)),
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ReportProfile(
                                      otherUserId: this.userId,
                                      onSuccessShowTab: tabs.feed.index)));
                          //report user
                        },
                      ),
                      TextButton(
                        child: Text("Cancel",
                            style: TextStyle(
                                color: AppColors
                                    .communityProfileOptionsBlueColor)),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      )
                    ],
                  ),
                  cupertino: (_, __) =>
                      CupertinoAlertDialogData(actions: <Widget>[
                    CupertinoDialogAction(
                      child: Text("Unfriend",
                          style:
                              TextStyle(color: Color.fromRGBO(255, 69, 58, 1))),
                      isDefaultAction: true,
                      onPressed: () {
                        Navigator.of(context).pop();
                        this._unfriend(userDisplayed.id).then((isSuccess) =>
                            isSuccess
                                ? _alertUser(context, "Unfriend Successful",
                                    "You are no longer friends with ${userDisplayed.first_name}.",
                                    is_unfriend: true)
                                : _alertUser(context, "An error occurred",
                                    "Please try again!"));
                        //unfriend user
                      },
                    ),
                    CupertinoDialogAction(
                      child: Text("Report User",
                          style: TextStyle(color: Colors.black)),
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ReportProfile(
                                    otherUserId: this.userId,
                                    onSuccessShowTab: tabs.feed.index)));

                        //report user
                      },
                    ),
                    CupertinoDialogAction(
                      child: Text("Cancel",
                          style: TextStyle(
                              color:
                                  AppColors.communityProfileOptionsBlueColor)),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    )
                  ]),
                ),
            barrierDismissible: false);
        break;
      case profileOptions.report:
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ReasonReport(
                      otherUserId: (userDisplayed.id != -1)
                          ? userDisplayed.id
                          : this.userId,
                      onSuccessShowTab: tabs.feed.index,
                    )));

        break;
      default:
        break;
    }
  }

  void _alertUser(BuildContext context, String title, String content,
      {bool is_friend_request_sent = false, bool is_unfriend = false}) {
    showDialog(
      context: context,
      builder: (_) => PlatformAlertDialog(
        title: Text(title,
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w400)),
        content: Text(content,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400)),
        material: (_, __) => MaterialAlertDialogData(
          elevation: 1.0,
          actions: <Widget>[
            FlatButton(
              child: Text("Close",
                  style: TextStyle(
                      color: AppColors.communityProfileOptionsBlueColor,
                      fontWeight: FontWeight.w600)),
              onPressed: () {
                // Update user model is friend request sent successfully
                if (is_friend_request_sent == true) {
                  Navigator.pop(context, "Friend Request Sent");
                } else if (is_unfriend == true) {
                  Navigator.pop(context, "Unfriend");
                } else {
                  Navigator.of(context).pop();
                }
              },
            )
          ],
        ),
        cupertino: (_, __) => CupertinoAlertDialogData(actions: <Widget>[
          CupertinoButton(
            child: Text("Close",
                style: TextStyle(
                    color: AppColors.communityProfileOptionsBlueColor,
                    fontWeight: FontWeight.w600)),
            onPressed: () {
              if (is_friend_request_sent == true) {
                Navigator.pop(context, "Friend Request Sent");
              } else if (is_unfriend == true) {
                Navigator.pop(context, "Unfriend");
              } else {
                Navigator.of(context).pop();
              }
            },
          ),
        ]),
      ),
      barrierDismissible: true,
    ).then((value) {});
  }

  Future<User> _getUserDetails() async {
    try {
      var res = await MyHttp.get("users/user/$userId");

      if (res.statusCode == 200) {
        var data = json.decode(res.body);
//        var u = data["user"] ?? data["User"] ?? data["Author"];
        User user = User.fromJson(data);
        return user;
      } else {
        print(res.statusCode.toString() + " " + res.body);
      }
    } catch (e) {
      print("Boom! Found you");
      print(e);
    }
    return null;
  }

  Future<void> _goNextScreen(BuildContext context) async {
    // var sp = await SharedPreferences.getInstance();
    // bool isAlreadyLogin = sp.containsKey("loggedIn");
    // if (isAlreadyLogin) {
    //   var tokenReq = await MyFirebase.sendFCMToken("users/fcm-token");
    //   print("tokenReq=${tokenReq}");
    // } else {
    //   Navigator.of(context)
    //       .push(MaterialPageRoute(builder: (context) => EnableNotification()));
    // }
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => EnableNotification()));
  }

  SizedBox _getInterestButton(String name) {
    return SizedBox(
      width: 160,
      height: 70,
      child: Padding(
        padding: EdgeInsets.all(4.0),
        child: Container(
          decoration: BoxDecoration(
            color: this.themeColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Center(
            child: Text(
              name,
              style: TextStyle(
                  color: this.themeColor,
                  fontSize: 13,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  Widget getProfilePlain(User user, BuildContext context) {
    double mediaWidth = MediaQuery.of(context).size.width;
    return new Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Stack(
          children: <Widget>[
            (user.imageUrl != null && user.imageUrl.isNotEmpty)
                ? Container(
                    width: mediaWidth,
                    child: Image.network(user.imageUrl, fit: BoxFit.fitWidth))
                : Container(),
            Container(
              padding: EdgeInsetsDirectional.only(top: 8, start: 20),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(Global.getFName(user.first_name ?? ""),
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: AppConfig.fontsizeForSmallDevice(context, 30),
                        fontWeight: FontWeight.w700,
                        shadows: <Shadow>[
                          Shadow(
                              offset: Offset(0, 2),
                              blurRadius: 4,
                              color: Color.fromRGBO(0, 0, 0, 0.5)),
                        ])),
              ),
            ),
          ],
        ),
        ProfileBasicInfo(
            user: user,
            isEditable: isEditable,
            onUpdateProfile: null,
            isOnboarding: false),
      ],
    );
  }

  Widget getProfileBasicInfo(User user, BuildContext context) {
    print("reachedd");
    return SingleChildScrollView(child: getProfilePlain(user, context));
  }

  Widget getFullProfileOnboarding() {
    return new FutureBuilder(
        // future: Future.wait([_getUserDetails(), _getUserPictures()]),
        future: Future.wait([_getUserDetails()]),
        builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.hasData &&
              snapshot.data.length > 0 &&
              snapshot.data[0] != null) {
            print("get user pictures");
            User user = snapshot.data[0];
            snapshot.data.removeLast();
            List<Widget> interestsWidget = (user.interests ?? [])
                .map((i) => this._getInterestButton(i))
                .toList();
            double mediaWidth = MediaQuery.of(context).size.width;
            return SingleChildScrollView(
              child: SizedBox(
                child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Stack(
                      children: <Widget>[
                        (user.imageUrl != null &&
                                user.imageUrl.isNotEmpty &&
                                user.imageUrl != "na")
                            ? Container(
                                width: mediaWidth,
                                child: Image.network(user.imageUrl,
                                    fit: BoxFit.fitWidth))
                            : Icon(Icons.person, size: mediaWidth),
                        Container(
                          padding:
                              EdgeInsetsDirectional.only(top: 8, start: 20),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(Global.getFName(user.first_name ?? ""),
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: AppConfig.fontsizeForSmallDevice(
                                        context, 36),
                                    fontWeight: FontWeight.w700,
                                    shadows: <Shadow>[
                                      Shadow(
                                          offset: Offset(0, 2),
                                          blurRadius: 4,
                                          color: Color.fromRGBO(0, 0, 0, 0.5)),
                                    ])),
                          ),
                        ),
                        Visibility(
                            visible: isEditable,
                            child: Container(
                              padding:
                                  EdgeInsetsDirectional.only(top: 5, end: 0),
                              child: Align(
                                alignment: Alignment.topRight,
                                child: PlatformIconButton(
                                  icon: Image.asset(
                                    "assets/images/edit_icon.png",
                                    width: 30,
                                    color: Colors.white,
                                  ),
                                  onPressed: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              NewEditProfilePictures(
                                                  profilePicturePath:
                                                      user.imageUrl,
                                                  isOnboarding:
                                                      (this.isOnboarding !=
                                                                  null &&
                                                              this.isOnboarding)
                                                          ? true
                                                          : false,
                                                  onUpdateProfile:
                                                      onUpdateProfile,
                                                  imagePaths:
                                                      user.userImages))),
                                ),
                              ),
                            )),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Material(
                        child: ProfileBasicInfo(
                            user: user,
                            isEditable: isEditable,
                            onUpdateProfile: onUpdateProfile,
                            isOnboarding:
                                (this.isOnboarding != null && this.isOnboarding)
                                    ? true
                                    : false)),
                    (user.userImages[1] != null)
                        ? Stack(children: [
                            CachedNetworkImage(
                              imageUrl: user.userImages[1].path,
                              width: mediaWidth,
                              fit: BoxFit.fitWidth,
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error),
                            ),
                            Visibility(
                                visible: isEditable,
                                child: Container(
                                  padding: EdgeInsetsDirectional.only(
                                      top: 5, end: 0),
                                  child: Align(
                                    alignment: Alignment.topRight,
                                    child: PlatformIconButton(
                                      icon: Image.asset(
                                        "assets/images/edit_icon.png",
                                        width: 30,
                                        color: Colors.white,
                                      ),
                                      onPressed: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  NewEditProfilePictures(
                                                      profilePicturePath:
                                                          user.imageUrl,
                                                      isOnboarding: (this
                                                                      .isOnboarding !=
                                                                  null &&
                                                              this.isOnboarding)
                                                          ? true
                                                          : false,
                                                      onUpdateProfile:
                                                          onUpdateProfile,
                                                      imagePaths:
                                                          user.userImages))),
                                    ),
                                  ),
                                )),
                          ])
                        : Container(),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      padding: EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "About Me",
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.w700),
                          ),
                          Visibility(
                            visible: isEditable,
                            // ignore: deprecated_member_use
                            child: FlatButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => EditAboutMe(
                                            user.about_me ?? "na",
                                            (this.isOnboarding != null &&
                                                    this.isOnboarding)
                                                ? true
                                                : false,
                                            onUpdateProfile)));
                              },
                              child: Image.asset(
                                "assets/images/edit_icon.png",
                                width: 24,
                                color: AppColors.blackColor,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        user.about_me ?? "na",
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.w500),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    (user.userImages[2] != null)
                        ? Stack(
                            children: [
                              CachedNetworkImage(
                                imageUrl: user.userImages[2].path,
                                width: mediaWidth,
                                fit: BoxFit.fitWidth,
                                errorWidget: (context, url, error) =>
                                    Icon(Icons.error),
                              ),
                              Visibility(
                                  visible: isEditable,
                                  child: Container(
                                    padding: EdgeInsetsDirectional.only(
                                        top: 5, end: 0),
                                    child: Align(
                                      alignment: Alignment.topRight,
                                      child: PlatformIconButton(
                                        icon: Image.asset(
                                          "assets/images/edit_icon.png",
                                          width: 30,
                                          color: Colors.white,
                                        ),
                                        onPressed: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    NewEditProfilePictures(
                                                        profilePicturePath: user
                                                            .imageUrl,
                                                        isOnboarding:
                                                            (this.isOnboarding !=
                                                                        null &&
                                                                    this
                                                                        .isOnboarding)
                                                                ? true
                                                                : false,
                                                        onUpdateProfile:
                                                            onUpdateProfile,
                                                        imagePaths:
                                                            user.userImages))),
                                      ),
                                    ),
                                  )),
                            ],
                          )
                        : Container(),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      padding: EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "Favorite Verse",
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.w700),
                          ),
                          Visibility(
                            visible: isEditable,
                            child: FlatButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => EditFavoriteVerse(
                                              user.favorite_verse ?? "na",
                                              (this.isOnboarding != null &&
                                                      this.isOnboarding)
                                                  ? true
                                                  : false,
                                              onUpdateProfile)));
                                },
                                child: Image.asset(
                                  "assets/images/edit_icon.png",
                                  width: 24,
                                  color: AppColors.blackColor,
                                )),
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        user.favorite_verse ?? "na",
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.w500),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    (user.userImages[3] != null)
                        ? Stack(children: [
                            CachedNetworkImage(
                              imageUrl: user.userImages[3].path,
                              width: mediaWidth,
                              fit: BoxFit.fitWidth,
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error),
                            ),
                            Visibility(
                                visible: isEditable,
                                child: Container(
                                  padding: EdgeInsetsDirectional.only(
                                      top: 5, end: 0),
                                  child: Align(
                                    alignment: Alignment.topRight,
                                    child: PlatformIconButton(
                                      icon: Image.asset(
                                        "assets/images/edit_icon.png",
                                        width: 30,
                                        color: Colors.white,
                                      ),
                                      onPressed: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  NewEditProfilePictures(
                                                      profilePicturePath:
                                                          user.imageUrl,
                                                      isOnboarding: (this
                                                                      .isOnboarding !=
                                                                  null &&
                                                              this.isOnboarding)
                                                          ? true
                                                          : false,
                                                      onUpdateProfile:
                                                          onUpdateProfile,
                                                      imagePaths:
                                                          user.userImages))),
                                    ),
                                  ),
                                )),
                          ])
                        : Container(),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      padding: EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "Interests",
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.w700),
                          ),
                          Visibility(
                            visible: isEditable,
                            child: FlatButton(
                                onPressed: () {
                                  (user.interests != null &&
                                          user.interests.length > 0)
                                      ? Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) => EditInterests(
                                                  user.interests,
                                                  (this.isOnboarding != null &&
                                                          this.isOnboarding)
                                                      ? true
                                                      : false,
                                                  onUpdateProfile)))
                                      : Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) => EditInterests(
                                                  [],
                                                  (this.isOnboarding != null &&
                                                          this.isOnboarding)
                                                      ? true
                                                      : false,
                                                  onUpdateProfile)));
                                },
                                child: Image.asset(
                                  "assets/images/edit_icon.png",
                                  width: 24,
                                  color: AppColors.blackColor,
                                )),
                          )
                        ],
                      ),
                    ),
                    Center(
                      child: Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Wrap(
                          spacing: 10,
                          children: interestsWidget,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    (user.userImages[4] != null)
                        ? Stack(children: [
                            CachedNetworkImage(
                              imageUrl: user.userImages[4].path,
                              width: mediaWidth,
                              fit: BoxFit.fitWidth,
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error),
                            ),
                            Visibility(
                                visible: isEditable,
                                child: Container(
                                  padding: EdgeInsetsDirectional.only(
                                      top: 5, end: 0),
                                  child: Align(
                                    alignment: Alignment.topRight,
                                    child: PlatformIconButton(
                                      icon: Image.asset(
                                        "assets/images/edit_icon.png",
                                        width: 30,
                                        color: Colors.white,
                                      ),
                                      onPressed: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  NewEditProfilePictures(
                                                      profilePicturePath:
                                                          user.imageUrl,
                                                      isOnboarding: (this
                                                                      .isOnboarding !=
                                                                  null &&
                                                              this.isOnboarding)
                                                          ? true
                                                          : false,
                                                      onUpdateProfile:
                                                          onUpdateProfile,
                                                      imagePaths:
                                                          user.userImages))),
                                    ),
                                  ),
                                )),
                          ])
                        : Container(),
                    SizedBox(
                      height: 10,
                    ),
                    (user.userImages[5] != null)
                        ? Stack(children: [
                            CachedNetworkImage(
                              imageUrl: user.userImages[5].path,
                              width: mediaWidth,
                              fit: BoxFit.fitWidth,
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error),
                            ),
                            Visibility(
                                visible: isEditable,
                                child: Container(
                                  padding: EdgeInsetsDirectional.only(
                                      top: 5, end: 0),
                                  child: Align(
                                    alignment: Alignment.topRight,
                                    child: PlatformIconButton(
                                      icon: Image.asset(
                                        "assets/images/edit_icon.png",
                                        width: 30,
                                        color: Colors.white,
                                      ),
                                      onPressed: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  NewEditProfilePictures(
                                                      profilePicturePath:
                                                          user.imageUrl,
                                                      isOnboarding: (this
                                                                      .isOnboarding !=
                                                                  null &&
                                                              this.isOnboarding)
                                                          ? true
                                                          : false,
                                                      onUpdateProfile:
                                                          onUpdateProfile,
                                                      imagePaths:
                                                          user.userImages))),
                                    ),
                                  ),
                                )),
                          ])
                        : Container(),
                    SizedBox(
                      height: 10,
                    ),
                    (user.userImages[6] != null)
                        ? Stack(children: [
                            CachedNetworkImage(
                              imageUrl: user.userImages[6].path,
                              width: mediaWidth,
                              fit: BoxFit.fitWidth,
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error),
                            ),
                            Visibility(
                                visible: isEditable,
                                child: Container(
                                  padding: EdgeInsetsDirectional.only(
                                      top: 5, end: 0),
                                  child: Align(
                                    alignment: Alignment.topRight,
                                    child: PlatformIconButton(
                                      icon: Image.asset(
                                        "assets/images/edit_icon.png",
                                        width: 30,
                                        color: Colors.white,
                                      ),
                                      onPressed: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  NewEditProfilePictures(
                                                      profilePicturePath:
                                                          user.imageUrl,
                                                      isOnboarding: (this
                                                                      .isOnboarding !=
                                                                  null &&
                                                              this.isOnboarding)
                                                          ? true
                                                          : false,
                                                      onUpdateProfile:
                                                          onUpdateProfile,
                                                      imagePaths:
                                                          user.userImages))),
                                    ),
                                  ),
                                )),
                          ])
                        : Container(),
                    SizedBox(
                      height: 10,
                    ),
                    (user.userImages[7] != null)
                        ? Stack(children: [
                            CachedNetworkImage(
                              imageUrl: user.userImages[7].path,
                              width: mediaWidth,
                              fit: BoxFit.fitWidth,
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error),
                            ),
                            Visibility(
                                visible: isEditable,
                                child: Container(
                                  padding: EdgeInsetsDirectional.only(
                                      top: 5, end: 0),
                                  child: Align(
                                    alignment: Alignment.topRight,
                                    child: PlatformIconButton(
                                      icon: Image.asset(
                                        "assets/images/edit_icon.png",
                                        width: 30,
                                        color: Colors.white,
                                      ),
                                      onPressed: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  NewEditProfilePictures(
                                                      profilePicturePath:
                                                          user.imageUrl,
                                                      isOnboarding: (this
                                                                      .isOnboarding !=
                                                                  null &&
                                                              this.isOnboarding)
                                                          ? true
                                                          : false,
                                                      onUpdateProfile:
                                                          onUpdateProfile,
                                                      imagePaths:
                                                          user.userImages))),
                                    ),
                                  ),
                                )),
                          ])
                        : Container(),
                    Visibility(
                      visible: isOnboarding != null && isOnboarding,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 20.0, horizontal: 10),
                        child: Center(
                          child: SizedBox(
                            height: 60,
                            child: PlatformButton(
                                onPressed: () {
                                  _goNextScreen(context);
                                },
                                color: AppColors.blueColor,
                                disabledColor: AppColors.disabledBlueColor,
                                materialFlat: (_, __) => MaterialFlatButtonData(
                                      color: AppColors.blueColor,
                                      disabledColor:
                                          AppColors.disabledBlueColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                cupertinoFilled: (_, __) =>
                                    CupertinoFilledButtonData(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                child: Text(
                                  "Save & Continue",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 20),
                                )),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return Container(
                height: 200,
                child: Text(
                  "",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.redColor),
                ));
          }
        });
  }

  Widget getFullProfile() {
    return new FutureBuilder(
        // future: Future.wait([_getUserDetails(), _getUserPictures()]),
        future: Future.wait([_getUserDetails()]),
        builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
          // if (snapshot.hasData &&
          //     snapshot.data[0] != null &&
          //     snapshot.data[1] != null) {
          if (snapshot.hasData &&
              snapshot.data.length > 0 &&
              snapshot.data[0] != null) {
            print("get user pictures");
            User user = snapshot.data[0];

            List<Widget> interestsWidget = (user.interests ?? [])
                .map((i) => this._getInterestButton(i))
                .toList();
            double mediaWidth = MediaQuery.of(context).size.width;
            return SingleChildScrollView(
              child: SizedBox(
                child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Stack(
                      children: <Widget>[
                        (user.imageUrl != null &&
                                user.imageUrl.isNotEmpty &&
                                user.imageUrl != "na")
                            ? Container(
                                width: mediaWidth,
                                child: Image.network(user.imageUrl,
                                    fit: BoxFit.fitWidth))
                            : Icon(Icons.person, size: mediaWidth),
                        Container(
                          padding:
                              EdgeInsetsDirectional.only(top: 8, start: 20),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(Global.getFName(user.first_name),
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: AppConfig.fontsizeForSmallDevice(
                                        context, 36),
                                    fontWeight: FontWeight.w700,
                                    shadows: <Shadow>[
                                      Shadow(
                                          offset: Offset(0, 2),
                                          blurRadius: 4,
                                          color: Color.fromRGBO(0, 0, 0, 0.5)),
                                    ])),
                          ),
                        ),
                        Visibility(
                            visible: isEditable,
                            child: Container(
                              padding:
                                  EdgeInsetsDirectional.only(top: 5, end: 0),
                              child: Align(
                                alignment: Alignment.topRight,
                                child: PlatformIconButton(
                                  icon: Image.asset(
                                    "assets/images/edit_icon.png",
                                    width: 30,
                                    color: Colors.white,
                                  ),
                                  onPressed: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              NewEditProfilePictures(
                                                  profilePicturePath:
                                                      user.imageUrl,
                                                  isOnboarding:
                                                      (this.isOnboarding !=
                                                                  null &&
                                                              this.isOnboarding)
                                                          ? true
                                                          : false,
                                                  onUpdateProfile:
                                                      onUpdateProfile,
                                                  imagePaths:
                                                      user.userImages))),
                                ),
                              ),
                            )),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Material(
                        child: ProfileBasicInfo(
                            user: user,
                            isEditable: isEditable,
                            onUpdateProfile: onUpdateProfile,
                            isOnboarding:
                                (this.isOnboarding != null && this.isOnboarding)
                                    ? true
                                    : false)),
                    (user.userImages[1] != null)
                        ? Stack(children: [
                            CachedNetworkImage(
                              imageUrl: user.userImages[1].path,
                              width: mediaWidth,
                              fit: BoxFit.fitWidth,
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error),
                            ),
                            Visibility(
                                visible: isEditable,
                                child: Container(
                                  padding: EdgeInsetsDirectional.only(
                                      top: 5, end: 0),
                                  child: Align(
                                    alignment: Alignment.topRight,
                                    child: PlatformIconButton(
                                      icon: Image.asset(
                                        "assets/images/edit_icon.png",
                                        width: 30,
                                        color: Colors.white,
                                      ),
                                      onPressed: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  NewEditProfilePictures(
                                                      profilePicturePath:
                                                          user.imageUrl,
                                                      isOnboarding: (this
                                                                      .isOnboarding !=
                                                                  null &&
                                                              this.isOnboarding)
                                                          ? true
                                                          : false,
                                                      onUpdateProfile:
                                                          onUpdateProfile,
                                                      imagePaths:
                                                          user.userImages))),
                                    ),
                                  ),
                                )),
                          ])
                        : Container(),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      padding: EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "About Me",
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.w700),
                          ),
                          Visibility(
                            visible: isEditable,
                            child: FlatButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => EditAboutMe(
                                            user.about_me,
                                            (this.isOnboarding != null &&
                                                    this.isOnboarding)
                                                ? true
                                                : false,
                                            onUpdateProfile)));
                              },
                              child: Image.asset(
                                "assets/images/edit_icon.png",
                                width: 24,
                                color: AppColors.blackColor,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        user.about_me ?? "na",
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.w500),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    (user.userImages[2] != null)
                        ? Stack(
                            children: [
                              CachedNetworkImage(
                                imageUrl: user.userImages[2].path,
                                width: mediaWidth,
                                fit: BoxFit.fitWidth,
                                errorWidget: (context, url, error) =>
                                    Icon(Icons.error),
                              ),
                              Visibility(
                                  visible: isEditable,
                                  child: Container(
                                    padding: EdgeInsetsDirectional.only(
                                        top: 5, end: 0),
                                    child: Align(
                                      alignment: Alignment.topRight,
                                      child: PlatformIconButton(
                                        icon: Image.asset(
                                          "assets/images/edit_icon.png",
                                          width: 30,
                                          color: Colors.white,
                                        ),
                                        onPressed: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    NewEditProfilePictures(
                                                        profilePicturePath: user
                                                            .imageUrl,
                                                        isOnboarding:
                                                            (this.isOnboarding !=
                                                                        null &&
                                                                    this
                                                                        .isOnboarding)
                                                                ? true
                                                                : false,
                                                        onUpdateProfile:
                                                            onUpdateProfile,
                                                        imagePaths:
                                                            user.userImages))),
                                      ),
                                    ),
                                  )),
                            ],
                          )
                        : Container(),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      padding: EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "Favorite Verse",
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.w700),
                          ),
                          Visibility(
                            visible: isEditable,
                            child: FlatButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => EditFavoriteVerse(
                                              user.favorite_verse,
                                              (this.isOnboarding != null &&
                                                      this.isOnboarding)
                                                  ? true
                                                  : false,
                                              onUpdateProfile)));
                                },
                                child: Image.asset(
                                  "assets/images/edit_icon.png",
                                  width: 24,
                                  color: AppColors.blackColor,
                                )),
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        user.favorite_verse ?? "na",
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.w500),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    (user.userImages[3] != null)
                        ? Stack(children: [
                            CachedNetworkImage(
                              imageUrl: user.userImages[3].path,
                              width: mediaWidth,
                              fit: BoxFit.fitWidth,
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error),
                            ),
                            Visibility(
                                visible: isEditable,
                                child: Container(
                                  padding: EdgeInsetsDirectional.only(
                                      top: 5, end: 0),
                                  child: Align(
                                    alignment: Alignment.topRight,
                                    child: PlatformIconButton(
                                      icon: Image.asset(
                                        "assets/images/edit_icon.png",
                                        width: 30,
                                        color: Colors.white,
                                      ),
                                      onPressed: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  NewEditProfilePictures(
                                                      profilePicturePath:
                                                          user.imageUrl,
                                                      isOnboarding: (this
                                                                      .isOnboarding !=
                                                                  null &&
                                                              this.isOnboarding)
                                                          ? true
                                                          : false,
                                                      onUpdateProfile:
                                                          onUpdateProfile,
                                                      imagePaths:
                                                          user.userImages))),
                                    ),
                                  ),
                                )),
                          ])
                        : Container(),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      padding: EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "Interests",
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.w700),
                          ),
                          Visibility(
                            visible: isEditable,
                            child: FlatButton(
                                onPressed: () {
                                  (user.interests != null &&
                                          user.interests.length > 0)
                                      ? Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) => EditInterests(
                                                  user.interests,
                                                  (this.isOnboarding != null &&
                                                          this.isOnboarding)
                                                      ? true
                                                      : false,
                                                  onUpdateProfile)))
                                      : Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) => EditInterests(
                                                  [],
                                                  (this.isOnboarding != null &&
                                                          this.isOnboarding)
                                                      ? true
                                                      : false,
                                                  onUpdateProfile)));
                                },
                                child: Image.asset(
                                  "assets/images/edit_icon.png",
                                  width: 24,
                                  color: AppColors.blackColor,
                                )),
                          )
                        ],
                      ),
                    ),
                    Center(
                      child: Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Wrap(
                          spacing: 10,
                          children: interestsWidget,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    (user.userImages[4] != null)
                        ? Stack(children: [
                            CachedNetworkImage(
                              imageUrl: user.userImages[4].path,
                              width: mediaWidth,
                              fit: BoxFit.fitWidth,
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error),
                            ),
                            Visibility(
                                visible: isEditable,
                                child: Container(
                                  padding: EdgeInsetsDirectional.only(
                                      top: 5, end: 0),
                                  child: Align(
                                    alignment: Alignment.topRight,
                                    child: PlatformIconButton(
                                      icon: Image.asset(
                                        "assets/images/edit_icon.png",
                                        width: 30,
                                        color: Colors.white,
                                      ),
                                      onPressed: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  NewEditProfilePictures(
                                                      profilePicturePath:
                                                          user.imageUrl,
                                                      isOnboarding: (this
                                                                      .isOnboarding !=
                                                                  null &&
                                                              this.isOnboarding)
                                                          ? true
                                                          : false,
                                                      onUpdateProfile:
                                                          onUpdateProfile,
                                                      imagePaths:
                                                          user.userImages))),
                                    ),
                                  ),
                                )),
                          ])
                        : Container(),
                    SizedBox(
                      height: 10,
                    ),
                    (user.userImages[5] != null)
                        ? Stack(children: [
                            CachedNetworkImage(
                              imageUrl: user.userImages[5].path,
                              width: mediaWidth,
                              fit: BoxFit.fitWidth,
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error),
                            ),
                            Visibility(
                                visible: isEditable,
                                child: Container(
                                  padding: EdgeInsetsDirectional.only(
                                      top: 5, end: 0),
                                  child: Align(
                                    alignment: Alignment.topRight,
                                    child: PlatformIconButton(
                                      icon: Image.asset(
                                        "assets/images/edit_icon.png",
                                        width: 30,
                                        color: Colors.white,
                                      ),
                                      onPressed: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  NewEditProfilePictures(
                                                      profilePicturePath:
                                                          user.imageUrl,
                                                      isOnboarding: (this
                                                                      .isOnboarding !=
                                                                  null &&
                                                              this.isOnboarding)
                                                          ? true
                                                          : false,
                                                      onUpdateProfile:
                                                          onUpdateProfile,
                                                      imagePaths:
                                                          user.userImages))),
                                    ),
                                  ),
                                )),
                          ])
                        : Container(),
                    SizedBox(
                      height: 10,
                    ),
                    (user.userImages[6] != null)
                        ? Stack(children: [
                            CachedNetworkImage(
                              imageUrl: user.userImages[6].path,
                              width: mediaWidth,
                              fit: BoxFit.fitWidth,
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error),
                            ),
                            Visibility(
                                visible: isEditable,
                                child: Container(
                                  padding: EdgeInsetsDirectional.only(
                                      top: 5, end: 0),
                                  child: Align(
                                    alignment: Alignment.topRight,
                                    child: PlatformIconButton(
                                      icon: Image.asset(
                                        "assets/images/edit_icon.png",
                                        width: 30,
                                        color: Colors.white,
                                      ),
                                      onPressed: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  NewEditProfilePictures(
                                                      profilePicturePath:
                                                          user.imageUrl,
                                                      isOnboarding: (this
                                                                      .isOnboarding !=
                                                                  null &&
                                                              this.isOnboarding)
                                                          ? true
                                                          : false,
                                                      onUpdateProfile:
                                                          onUpdateProfile,
                                                      imagePaths:
                                                          user.userImages))),
                                    ),
                                  ),
                                )),
                          ])
                        : Container(),
                    SizedBox(
                      height: 10,
                    ),
                    (user.userImages[7] != null)
                        ? Stack(children: [
                            CachedNetworkImage(
                              imageUrl: user.userImages[7].path,
                              width: mediaWidth,
                              fit: BoxFit.fitWidth,
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error),
                            ),
                            Visibility(
                                visible: isEditable,
                                child: Container(
                                  padding: EdgeInsetsDirectional.only(
                                      top: 5, end: 0),
                                  child: Align(
                                    alignment: Alignment.topRight,
                                    child: PlatformIconButton(
                                      icon: Image.asset(
                                        "assets/images/edit_icon.png",
                                        width: 30,
                                        color: Colors.white,
                                      ),
                                      onPressed: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  NewEditProfilePictures(
                                                      profilePicturePath:
                                                          user.imageUrl,
                                                      isOnboarding: (this
                                                                      .isOnboarding !=
                                                                  null &&
                                                              this.isOnboarding)
                                                          ? true
                                                          : false,
                                                      onUpdateProfile:
                                                          onUpdateProfile,
                                                      imagePaths:
                                                          user.userImages))),
                                    ),
                                  ),
                                )),
                          ])
                        : Container(),
                    Visibility(
                      visible: isOnboarding != null && isOnboarding,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 20.0, horizontal: 10),
                        child: Center(
                          child: SizedBox(
                            height: 60,
                            child: PlatformButton(
                                onPressed: () {
                                  _goNextScreen(context);
                                },
                                color: AppColors.blueColor,
                                disabledColor: AppColors.disabledBlueColor,
                                materialFlat: (_, __) => MaterialFlatButtonData(
                                      color: AppColors.blueColor,
                                      disabledColor:
                                          AppColors.disabledBlueColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                cupertinoFilled: (_, __) =>
                                    CupertinoFilledButtonData(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                child: Text(
                                  "Save & Continue",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 20),
                                )),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return Container(
                height: 200,
                child: Text(
                  "",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.redColor),
                ));
          }
        });
  }

  Widget getFullProfilePendingUsers() {
    return new FutureBuilder(
        future: Future.wait([_getUserDetails()]),
        builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.hasData && snapshot.data[0] != null) {
            User user = snapshot.data[0];
            // List<Widget> interestsWidget = (user.interests ?? [])
            //     .map((i) => this._getInterestButton(i))
            //     .toList();
            double mediaWidth = MediaQuery.of(context).size.width;
            return SingleChildScrollView(
              child: SizedBox(
                child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Stack(
                      children: <Widget>[
                        (user.imageUrl != null && user.imageUrl.isNotEmpty)
                            ? Container(
                                width: mediaWidth,
                                child: Image.network(user.imageUrl,
                                    fit: BoxFit.fitWidth))
                            : Container(),
                        Container(
                          padding:
                              EdgeInsetsDirectional.only(top: 8, start: 20),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(user.first_name ?? "NA",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 36,
                                    fontWeight: FontWeight.w700)),
                          ),
                        ),
                        Visibility(
                            visible: isEditable,
                            child: Container(
                              padding:
                                  EdgeInsetsDirectional.only(top: 8, end: 20),
                              child: Align(
                                alignment: Alignment.topRight,
                                child: PlatformIconButton(
                                  icon: Icon(Icons.edit,
                                      color: Colors.white, size: 30.0),
                                  onPressed: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              NewEditProfilePictures(
                                                  profilePicturePath:
                                                      user.imageUrl,
                                                  imagePaths:
                                                      user.userImages))),
                                ),
                              ),
                            )),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    ProfileBasicInfo(
                        user: user,
                        isEditable: isEditable,
                        onUpdateProfile: null,
                        isOnboarding: false),
                    (user.userImages[1] != null)
                        ? Stack(children: [
                            CachedNetworkImage(
                              imageUrl: user.userImages[1].path,
                              width: mediaWidth,
                              fit: BoxFit.fitWidth,
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error),
                            ),
                            Visibility(
                                visible: isEditable,
                                child: Container(
                                  padding: EdgeInsetsDirectional.only(
                                      top: 8, end: 20),
                                  child: Align(
                                    alignment: Alignment.topRight,
                                    child: PlatformIconButton(
                                      icon: Icon(Icons.edit,
                                          color: Colors.white, size: 30.0),
                                      onPressed: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  NewEditProfilePictures(
                                                      profilePicturePath:
                                                          user.imageUrl,
                                                      imagePaths:
                                                          user.userImages))),
                                    ),
                                  ),
                                )),
                          ])
                        : Container(),
                    SizedBox(
                      height: 10,
                    ),
                    (user.userImages[2] != null)
                        ? Stack(
                            children: [
                              CachedNetworkImage(
                                imageUrl: user.userImages[2].path,
                                width: mediaWidth,
                                fit: BoxFit.fitWidth,
                                errorWidget: (context, url, error) =>
                                    Icon(Icons.error),
                              ),
                              Visibility(
                                  visible: isEditable,
                                  child: Container(
                                    padding: EdgeInsetsDirectional.only(
                                        top: 8, end: 20),
                                    child: Align(
                                      alignment: Alignment.topRight,
                                      child: PlatformIconButton(
                                        icon: Icon(Icons.edit,
                                            color: Colors.white, size: 30.0),
                                        onPressed: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    NewEditProfilePictures(
                                                        profilePicturePath:
                                                            user.imageUrl,
                                                        imagePaths:
                                                            user.userImages))),
                                      ),
                                    ),
                                  )),
                            ],
                          )
                        : Container(),
                    SizedBox(
                      height: 10,
                    ),
                    (user.userImages[3] != null)
                        ? Stack(
                            children: [
                              CachedNetworkImage(
                                imageUrl: user.userImages[3].path,
                                width: mediaWidth,
                                fit: BoxFit.fitWidth,
                                errorWidget: (context, url, error) =>
                                    Icon(Icons.error),
                              ),
                              Visibility(
                                  visible: isEditable,
                                  child: Container(
                                    padding: EdgeInsetsDirectional.only(
                                        top: 8, end: 20),
                                    child: Align(
                                      alignment: Alignment.topRight,
                                      child: PlatformIconButton(
                                        icon: Icon(Icons.edit,
                                            color: Colors.black, size: 30.0),
                                        onPressed: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    NewEditProfilePictures(
                                                        profilePicturePath:
                                                            user.imageUrl,
                                                        imagePaths:
                                                            user.userImages))),
                                      ),
                                    ),
                                  )),
                            ],
                          )
                        : Container(),
                    SizedBox(
                      height: 10,
                    ),
                    (user.userImages[5] != null)
                        ? Stack(children: [
                            CachedNetworkImage(
                              imageUrl: user.userImages[5].path,
                              width: mediaWidth,
                              fit: BoxFit.fitWidth,
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error),
                            ),
                            Visibility(
                                visible: isEditable,
                                child: Container(
                                  padding: EdgeInsetsDirectional.only(
                                      top: 5, end: 0),
                                  child: Align(
                                    alignment: Alignment.topRight,
                                    child: PlatformIconButton(
                                      icon: Image.asset(
                                        "assets/images/edit_icon.png",
                                        width: 30,
                                        color: Colors.white,
                                      ),
                                      onPressed: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  NewEditProfilePictures(
                                                      profilePicturePath:
                                                          user.imageUrl,
                                                      isOnboarding: (this
                                                                      .isOnboarding !=
                                                                  null &&
                                                              this.isOnboarding)
                                                          ? true
                                                          : false,
                                                      onUpdateProfile:
                                                          onUpdateProfile,
                                                      imagePaths:
                                                          user.userImages))),
                                    ),
                                  ),
                                )),
                          ])
                        : Container(),
                    SizedBox(
                      height: 10,
                    ),
                    (user.userImages[6] != null)
                        ? Stack(children: [
                            CachedNetworkImage(
                              imageUrl: user.userImages[6].path,
                              width: mediaWidth,
                              fit: BoxFit.fitWidth,
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error),
                            ),
                            Visibility(
                                visible: isEditable,
                                child: Container(
                                  padding: EdgeInsetsDirectional.only(
                                      top: 5, end: 0),
                                  child: Align(
                                    alignment: Alignment.topRight,
                                    child: PlatformIconButton(
                                      icon: Image.asset(
                                        "assets/images/edit_icon.png",
                                        width: 30,
                                        color: Colors.white,
                                      ),
                                      onPressed: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  NewEditProfilePictures(
                                                      profilePicturePath:
                                                          user.imageUrl,
                                                      isOnboarding: (this
                                                                      .isOnboarding !=
                                                                  null &&
                                                              this.isOnboarding)
                                                          ? true
                                                          : false,
                                                      onUpdateProfile:
                                                          onUpdateProfile,
                                                      imagePaths:
                                                          user.userImages))),
                                    ),
                                  ),
                                )),
                          ])
                        : Container(),
                    SizedBox(
                      height: 10,
                    ),
                    (user.userImages[7] != null)
                        ? Stack(children: [
                            CachedNetworkImage(
                              imageUrl: user.userImages[7].path,
                              width: mediaWidth,
                              fit: BoxFit.fitWidth,
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error),
                            ),
                            Visibility(
                                visible: isEditable,
                                child: Container(
                                  padding: EdgeInsetsDirectional.only(
                                      top: 5, end: 0),
                                  child: Align(
                                    alignment: Alignment.topRight,
                                    child: PlatformIconButton(
                                      icon: Image.asset(
                                        "assets/images/edit_icon.png",
                                        width: 30,
                                        color: Colors.white,
                                      ),
                                      onPressed: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  NewEditProfilePictures(
                                                      profilePicturePath:
                                                          user.imageUrl,
                                                      isOnboarding: (this
                                                                      .isOnboarding !=
                                                                  null &&
                                                              this.isOnboarding)
                                                          ? true
                                                          : false,
                                                      onUpdateProfile:
                                                          onUpdateProfile,
                                                      imagePaths:
                                                          user.userImages))),
                                    ),
                                  ),
                                )),
                          ])
                        : Container(),
                    SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ),
            );
          } else {
            return Container(
                height: 200,
                child: Text(
                  "",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.redColor),
                ));
          }
        });
  }
}
