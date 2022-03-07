import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:pure_match/common/profile.dart';
import 'package:pure_match/models/user.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:amplitude_flutter/amplitude.dart';

import '../AppColors.dart';
import '../MyHttp.dart';
import '../../common/constants.dart';

class MatchUserProfile extends StatefulWidget {
  int userId;
  bool isFriendSuggestion;
  bool isMatchSuggestion;

  MatchUserProfile({userId, bool isFriendSuggestion, bool isMatchSuggestion}) {
    this.userId = userId;
    this.isFriendSuggestion = isFriendSuggestion ?? false;
    this.isMatchSuggestion = isMatchSuggestion ?? false;
  }
  @override
  _MatchUserProfileState createState() => _MatchUserProfileState();
}

class _MatchUserProfileState extends State<MatchUserProfile> {
  // Analytics code
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';

  int userId;
  String error;
  User u;
  bool _loading = false;
  Profile profile;
  bool isfriend = false;
  bool requestSent = false;

  @override
  void initState() {
    userId = widget.userId;

    _getProfile();
    profile = new Profile(
      userId: userId,
      isEditable: false,
      themeColor: AppColors.yellowColor,
      friend: isfriend,
      isFriendRequestSent: requestSent,
    );
    super.initState();
    //Analytics code
    amplitudeAnalytics.init(apiKey);
    analytics.setCurrentScreen(
        screenName: "match_user_profile",
        screenClassOverride: "match_user_profile");
    amplitudeAnalytics.logEvent("match_user_profile_page");
  }

  void _getProfile() async {
    print(userId);
    setState(() {
      _loading = true;
    });

    Map<String, dynamic> result = new Map();

    var res = await MyHttp.get("users/user/${userId}");
    var body = json.decode(res.body);

    if (res.statusCode == 200) {
      var user = body['user'] ?? body["User"] ?? body["Author"];
      this.u = User.fromJson(user);
      var res2 = await MyHttp.get("matches/check-friend/${userId}");
      isfriend = json.decode(res2.body);
      var res3 = await MyHttp.get("friends/request-status/${userId}");
      var status = json.decode(res3.body);
      String request = status["status"];

      if (request == "pending") {
        requestSent = true;
      }

//      this.u = User.smallUser(user["first_name"], user["last_name"],user["status"],user["ProfilePictureId"],user["age"],user["height"],user["kids_have"],user["kids_want"],user["no_of_kids"],user["location"],user["church"],user["school_name"],user["position"],user["employer"],user["self_employed"],user["education"]);

      setState(() {
        _loading = false;
      });
    } else {
      print("User update error: ${res.statusCode}");
      print("User update error: ${res.body}");
      setState(() {
        error = body["message"];
      });
    }
  }

  void _showModalBottomSheet(BuildContext context, User userDisplayed) {
    List<Widget> actions = [];
    if (userDisplayed.friend_match_id != null && !profile.friend) {
      actions.add(ListTile(
        title: Text("Suggest as Friend",
            style:
                TextStyle(color: AppColors.communityProfileOptionsBlueColor)),
        onTap: () {
          Navigator.pop(context, profileOptions.suggestFriend); // to change
        },
      ));
      actions.add(ListTile(
        title: Text("Suggest as Match",
            style:
                TextStyle(color: AppColors.communityProfileOptionsBlueColor)),
        onTap: () {
          Navigator.pop(context, profileOptions.suggestMatch);
        },
      ));
      actions.add(ListTile(
        title: Text("Unfriend",
            style: TextStyle(color: AppColors.communityProfileOptionsRedColor)),
        onTap: () {
          Navigator.pop(context, profileOptions.unfriend);
        },
      ));
      actions.add(ListTile(
        title: Text("Report",
            style: TextStyle(color: AppColors.communityProfileOptionsRedColor)),
        onTap: () {
          Navigator.pop(context, profileOptions.report);
        },
      ));
    } else if (userDisplayed.friend_request_id != null ||
        profile.isFriendRequestSent) {
      actions.add(ListTile(
        title: Text("Friend Request Sent",
            style: TextStyle(color: Color.fromRGBO(153, 153, 153, 1))),
        onTap: () {
          Navigator.pop(context, "Friend Request Sent");
        },
      ));
      actions.add(ListTile(
        title: Text("Suggest as Friend",
            style:
                TextStyle(color: AppColors.communityProfileOptionsBlueColor)),
        onTap: () {
          Navigator.pop(context, profileOptions.unfriend); // to change
        },
      ));
      actions.add(ListTile(
        title: Text("Report",
            style: TextStyle(color: AppColors.communityProfileOptionsRedColor)),
        onTap: () {
          Navigator.pop(context, profileOptions.report);
        },
      ));
    } else {
      actions.add(ListTile(
        title: Text("Send Friend Request",
            style:
                TextStyle(color: AppColors.communityProfileOptionsBlueColor)),
        onTap: () {
          Navigator.pop(context, profileOptions.sendFriendRequest);
        },
      ));
      actions.add(ListTile(
        title: Text("Suggest as Friend",
            style:
                TextStyle(color: AppColors.communityProfileOptionsBlueColor)),
        onTap: () {
          Navigator.pop(context, profileOptions.unfriend); // to change
        },
      ));
      actions.add(ListTile(
        title: Text("Report",
            style: TextStyle(color: AppColors.communityProfileOptionsRedColor)),
        onTap: () {
          Navigator.pop(context, profileOptions.report);
        },
      ));
    }
    showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return Container(child: new Wrap(children: actions));
            })
        .then((value) => profile.performSelectedProfileAction(
            value, context, userDisplayed));
  }

  InkWell _getLikeOption(User u) {
    return InkWell(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            ClipRRect(
                borderRadius: BorderRadius.circular(100.0),
                child: CachedNetworkImage(
                  width: 35,
                  imageUrl: u?.imageUrl ??
                      "https://i.pinimg.com/564x/19/b8/d6/19b8d6e9b13eef23ec9c746968bb88b1.jpg",
                  errorWidget: (context, url, error) => Icon(Icons.error),
                )),
            SizedBox(
              width: 8,
            ),
            Expanded(
                child: Text(
              u?.fullName ?? "Preet",
              style: TextStyle(fontWeight: FontWeight.bold),
            ))
          ],
        ),
      ),
    );
  }

  void _showModalActionSheet(BuildContext context, User userDisPlayed) {
    List<CupertinoActionSheetAction> actionSheetActions = [];
    if (isfriend == true) {
      actionSheetActions.add(CupertinoActionSheetAction(
          child: Text("Suggest as Friend",
              style:
                  TextStyle(color: AppColors.communityProfileOptionsBlueColor)),
          onPressed: () {
            Navigator.pop(context, profileOptions.suggestFriend);
          }));
      actionSheetActions.add(CupertinoActionSheetAction(
        child: Text("Suggest as Match",
            style:
                TextStyle(color: AppColors.communityProfileOptionsBlueColor)),
        onPressed: () {
          Navigator.pop(context, profileOptions.suggestMatch);
        },
      ));
      actionSheetActions.add(CupertinoActionSheetAction(
        child: Text("Unfriend",
            style: TextStyle(color: AppColors.communityProfileOptionsRedColor)),
        onPressed: () {
          Navigator.pop(context, profileOptions.unfriend);
        },
      ));
      actionSheetActions.add(CupertinoActionSheetAction(
        child: Text("Report",
            style: TextStyle(color: AppColors.communityProfileOptionsRedColor)),
        onPressed: () {
          Navigator.pop(context, profileOptions.report);
        },
      ));
    } else if (isfriend == false && profile.isFriendRequestSent == true ||
        requestSent == true) {
      actionSheetActions.add(CupertinoActionSheetAction(
        child: Text("Friend Request Sent",
            style: TextStyle(color: Color.fromRGBO(153, 153, 153, 1))),
        onPressed: () {
          Navigator.pop(context);
        },
      ));
      actionSheetActions.add(CupertinoActionSheetAction(
          child: Text("Suggest as Friend",
              style:
                  TextStyle(color: AppColors.communityProfileOptionsBlueColor)),
          onPressed: () {
            Navigator.pop(context, profileOptions.suggestFriend);
          }));
      actionSheetActions.add(CupertinoActionSheetAction(
        child: Text("Report",
            style: TextStyle(color: AppColors.communityProfileOptionsRedColor)),
        onPressed: () {
          Navigator.pop(context, profileOptions.report);
        },
      ));
    } else {
      actionSheetActions.add(CupertinoActionSheetAction(
        child: Text("Send friend Request",
            style:
                TextStyle(color: AppColors.communityProfileOptionsBlueColor)),
        onPressed: () {
          Navigator.pop(context, profileOptions.sendFriendRequest);
          requestSent == true;
        },
      ));
      actionSheetActions.add(CupertinoActionSheetAction(
          child: Text("Suggest as Friend",
              style:
                  TextStyle(color: AppColors.communityProfileOptionsBlueColor)),
          onPressed: () {
            Navigator.pop(context, profileOptions.suggestFriend);
          }));
      actionSheetActions.add(CupertinoActionSheetAction(
        child: Text("Report",
            style: TextStyle(color: AppColors.communityProfileOptionsRedColor)),
        onPressed: () {
          Navigator.pop(context, profileOptions.report);
        },
      ));
    }

    showCupertinoModalPopup(
            context: context,
            builder: (BuildContext context) {
              String firstName = userDisPlayed.first_name;
              return CupertinoActionSheet(
                  title: Text("$firstName Profile",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Color.fromRGBO(143, 143, 143, 1),
                      )),
                  actions: actionSheetActions,
                  cancelButton: CupertinoActionSheetAction(
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                          color: AppColors.communityProfileOptionsBlueColor),
                    ),
                    isDefaultAction: true,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ));
            })
        .then((value) => profile.performSelectedProfileAction(
            value, context, userDisPlayed));
  }

  PlatformAppBar getAppBar() {
    if (widget.isFriendSuggestion) {
      return PlatformAppBar(
        backgroundColor: AppColors.yellowColor,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            CircleAvatar(
              backgroundImage: NetworkImage(u.imageUrl),
              radius: 20,
            ),
            SizedBox(
              width: 10,
            ),
            Text("Friend Suggestion sent!",
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    fontSize: 16)),
          ],
        ),
      );
    } else if (widget.isMatchSuggestion) {
      return PlatformAppBar(
        backgroundColor: AppColors.redColor,
        title: Row(
          children: <Widget>[
            CircleAvatar(
              backgroundImage: NetworkImage(u.imageUrl),
              radius: 20,
            ),
            SizedBox(
              width: 10,
            ),
            Text("Match Suggestion sent!",
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    fontSize: 16)),
          ],
        ),
      );
    } else {
      return PlatformAppBar(
        cupertino: (_, __) =>
            CupertinoNavigationBarData(brightness: Brightness.dark),
        backgroundColor: AppColors.redColor,
        title: Text(u?.first_name ?? "",
            style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.white,
                fontSize: 24)),
        trailingActions: <Widget>[
          PlatformIconButton(
            icon: Image.asset("assets/images/profile_options.png"),
            onPressed: () {
              //Show the action sheet and bottom navigation dialog for android
              if (Platform.isAndroid) {
                _showModalBottomSheet(context, u);
              } else if (Platform.isIOS) {
                _showModalActionSheet(context, u);
              }
            },
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return PlatformScaffold(
      backgroundColor: Colors.white,
      appBar: getAppBar(),
      body: Scaffold(
        body: SafeArea(
          child: (this._loading)
              ? this._showLoading()
              : SingleChildScrollView(
                  child: (u == null)
                      ? Container()
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            // profile.getProfilePlain(u, context),
                            profile.getFullProfile()
                          ],
                        ),
                ),
        ),
      ),
    );
  }

  Container _showLoading() {
    return Container(
      height: double.infinity,
      child: Center(
        child: PlatformCircularProgressIndicator(),
      ),
    );
  }
}
