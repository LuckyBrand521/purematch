import 'dart:convert';
import 'dart:ui';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:pure_match/models/match_card.dart';
import 'package:pure_match/models/user.dart';
import 'package:pure_match/pages/AppColors.dart';
import 'package:pure_match/pages/MyHttp.dart';
import 'package:pure_match/pages/messaging/chat_base_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:amplitude_flutter/amplitude.dart';

class ItsMutual extends StatefulWidget {
  final MatchCard matchCard;
  final dynamic chat;

  const ItsMutual({Key key, this.matchCard, this.chat}) : super(key: key);
  @override
  _ItsMutualState createState() => _ItsMutualState();
}

class _ItsMutualState extends State<ItsMutual> {
  // Analytics code
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';

  User user;
  bool _loading = false;

  @override
  void initState() {
    _getUserDetails();

    super.initState();
    //Analytics tracking code
    amplitudeAnalytics.init(apiKey);
    analytics.setCurrentScreen(
        screenName: "its_mutual", screenClassOverride: "its_mutual");
    amplitudeAnalytics.logEvent("its_mutual_page");
  }

  Future<User> _getUserDetails() async {
    setState(() {
      _loading = true;
    });
    try {
      var sp = await SharedPreferences.getInstance();
      int userId = sp.getInt("id");
      print(userId);
      var res = await MyHttp.get("users/user/$userId");

      if (res.statusCode == 200) {
        var data = json.decode(res.body);
//        var u = data["user"] ?? data["User"] ?? data["Author"];
        user = User.fromJson(data);

        setState(() {
          _loading = false;
        });
      } else {
        print(res.statusCode.toString() + " " + res.body);
      }
    } catch (e) {
      print("Boom! Found you");
      print(e);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: (this._loading)
          ? this._showLoading()
          : SingleChildScrollView(
              child: Column(
                  //mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      height: height * 0.1,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "It's mutual!",
                          style: TextStyle(
                              fontSize: 40, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: height * 0.1,
                    ),
                    Container(
                      width: width * 0.9,
                      child: FittedBox(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Card(
                              semanticContainer: true,
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              elevation: 5,
                              margin: EdgeInsets.all(10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(60),
                              ),
                              child: CachedNetworkImage(
                                imageUrl: user?.imageUrl ??
                                    "https://ath2.unileverservices.com/wp-content/uploads/sites/8/2019/02/man-ponytail-low-tail-shutterstock-500x500.jpg",
                                fit: BoxFit.contain,
                                height: 350,
                                width: 300,
                                errorWidget: (context, url, error) =>
                                    Icon(Icons.error),
                              ),
                            ),
                            Card(
                              semanticContainer: true,
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              shadowColor: Colors.black,
                              elevation: 5,
                              margin: EdgeInsets.all(10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(60),
                              ),
                              child: CachedNetworkImage(
                                imageUrl: widget.matchCard?.image ??
                                    "https://ath2.unileverservices.com/wp-content/uploads/sites/8/2019/02/man-ponytail-low-tail-shutterstock-500x500.jpg",
                                fit: BoxFit.contain,
                                height: 350,
                                width: 300,
                                errorWidget: (context, url, error) =>
                                    Icon(Icons.error),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      "Introduce yourself to",
                      style: TextStyle(fontSize: 17),
                    ),
                    Text(
                      "get the conversation started!",
                      style: TextStyle(fontSize: 17),
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    ButtonTheme(
                      minWidth: 300.0,
                      height: 50.0,
                      child: RaisedButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ChatBasePage(
                                        chatId: widget.chat["id"],
                                        otherUserName:
                                            widget.matchCard.firstName,
                                        userId: widget.matchCard.id,
                                        status: widget.chat["status"],
                                      )));
                        },
                        elevation: 2.0,
                        color: AppColors.blueColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0)),
                        child: Text(
                          "Message ${widget.matchCard?.firstName ?? "User"}",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    FlatButton(
                      child: Text(
                        "Continue Browsing",
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 20),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      color: Colors.white,
                    )
                  ]),
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
