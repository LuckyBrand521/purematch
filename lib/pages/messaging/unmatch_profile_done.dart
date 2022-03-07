import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pure_match/models/user.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:amplitude_flutter/amplitude.dart';
import 'package:pure_match/pages/AppColors.dart';
import 'package:sailor/sailor.dart';

import '../../routes.dart';
import '../MyHttp.dart';

class UnmatchProfileDone extends StatefulWidget {
  final int otherUserId;

  const UnmatchProfileDone({Key key, this.otherUserId}) : super(key: key);

  @override
  _UnmatchProfileDoneState createState() => _UnmatchProfileDoneState();
}

class _UnmatchProfileDoneState extends State<UnmatchProfileDone> {
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

  @override
  void initState() {
    this._getUser();
    super.initState();
    //Analytics code
    amplitudeAnalytics.init(apiKey);
    analytics.setCurrentScreen(
        screenName: "unmatch_successful",
        screenClassOverride: "unmatch_successful");
    amplitudeAnalytics.logEvent("unmatch_successful_page");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 50, vertical: 30),
            child: Column(children: <Widget>[
              ClipRRect(
                  borderRadius: BorderRadius.circular(20.0),
                  child: CachedNetworkImage(
                    height: 200,
                    imageUrl: this._user?.imageUrl ??
                        "https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&w=1000&q=80",
                    errorWidget: (context, url, error) => Icon(Icons.error),
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
                "Unmatched!",
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
                "You have successfully unmatched with this user.",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 28,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 50,
              ),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FlatButton(
                  color: AppColors.blueColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  onPressed: () {
                    Routes.sailor.navigate("/main",
                        navigationType: NavigationType.pushAndRemoveUntil,
                        removeUntilPredicate: (Route<dynamic> route) => false);
                  },
                  child: Text(
                    "Continue",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              )
            ]),
          ),
        ),
      ),
    );
  }
}
