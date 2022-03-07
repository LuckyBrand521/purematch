import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pure_match/models/user.dart';

import 'package:pure_match/pages/AppColors.dart';
import 'package:pure_match/pages/MyHttp.dart';
import 'package:pure_match/pages/messaging/unmatch_profile_done.dart';
import 'package:amplitude_flutter/amplitude.dart';

class UnmatchedProfile extends StatefulWidget {
  final int otherUserId;

  const UnmatchedProfile({Key key, this.otherUserId}) : super(key: key);
  @override
  _UnmatchedProfileState createState() => _UnmatchedProfileState();
}

class _UnmatchedProfileState extends State<UnmatchedProfile> {
  // Analytics code
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';

  User _user;

  void _getUser() async {
    try {
      _user = await MyHttp.getUserDetails(userId: widget.otherUserId);
      setState(() {});
    } catch (e) {
      print(e);
    }
  }

  void _unmatchProfile() async {
    try {
      var res = await MyHttp.post("/matches/unmatch/${widget.otherUserId}", {});
      if (res.statusCode == 200) {
        //Analytics code
        analytics.logEvent(
            name: "unmactched_profile",
            parameters: <String, dynamic>{'other_user_id': widget.otherUserId});

        amplitudeAnalytics.logEvent("unmactched_profile",
            eventProperties: {'other_user_id': widget.otherUserId});

        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => UnmatchProfileDone(
                      otherUserId: widget.otherUserId,
                    )));
      } else {
        print("NAAA");
        print(res.statusCode);
      }
    } catch (e) {
      print("NAAA222");
      print(e);
    }
  }

  @override
  void initState() {
    this._getUser();
    super.initState();
    // Analytics tracking code
    amplitudeAnalytics.init(apiKey);
    analytics.setCurrentScreen(
        screenName: 'unmatch_profile', screenClassOverride: 'unmatch_profile');

    amplitudeAnalytics.logEvent("unmatch_profile_page");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 30),
                  child: Column(
                    children: <Widget>[
                      ClipRRect(
                          borderRadius: BorderRadius.circular(20.0),
                          child: CachedNetworkImage(
                            height: 200,
                            imageUrl: this._user?.imageUrl ??
                                "https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&w=1000&q=80",
                            errorWidget: (context, url, error) =>
                                Icon(Icons.error),
                          )),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        this._user?.fullName ?? "User name",
                        style: TextStyle(fontSize: 28),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        "Are you sure you\nwant to unmatch?!",
                        style: TextStyle(
                            color: Colors.red,
                            fontSize: 28,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        "You will no longer be able to message this user. Your message history will be archived until you mutually match again.",
                        style: TextStyle(fontSize: 24),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: 60,
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: FlatButton(
                          color: AppColors.redColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          onPressed: () {
                            this._unmatchProfile();
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(14.0),
                            child: Text(
                              "Unmatch",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: FlatButton(
                          color: AppColors.greyColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            // Analytics tracking code
                            analytics.setCurrentScreen(
                                screenName: "chat_user",
                                screenClassOverride: "chat_user");
                            amplitudeAnalytics.logEvent("chat_user_page");
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(14.0),
                            child: Text(
                              "Cancel",
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
