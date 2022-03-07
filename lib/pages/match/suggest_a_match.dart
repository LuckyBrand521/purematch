import 'dart:convert';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pure_match/common/MyButtons.dart';
import 'package:pure_match/models/share_user.dart';
import 'package:pure_match/models/user.dart';

import 'package:pure_match/pages/AppColors.dart';
import 'package:pure_match/pages/MyHttp.dart';
import 'package:pure_match/pages/match/match_user_profile.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:amplitude_flutter/amplitude.dart';

class SuggestAMatch extends StatefulWidget {
  final User user;

  const SuggestAMatch({Key key, this.user}) : super(key: key);

  @override
  _SuggestAMatchState createState() => _SuggestAMatchState();
}

class _SuggestAMatchState extends State<SuggestAMatch> {
  // Analytics code
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';

  List<ShareUser> _suggestedFriends = [];
  List<int> _selectedFriends = [];
  String filter = "";
  String message = "";

  void _getFriends() async {
    try {
      var res = await MyHttp.get("/friends/my-friends");
      print(res.statusCode);
      print(res.body);
      var body = json.decode(res.body);
      var friends = body["friends"] as List<dynamic>;
      if (friends != null && friends.length > 0) {
        for (int i = 0; i < friends.length; i++) {
          var friend = friends[i];
          var u = ShareUser(User.fromJson(friend));
          this._suggestedFriends.add(u);
        }
        setState(() {});
      }
    } catch (e) {
      print("Get friends error $e");
    }
  }

  void _suggestMatch() async {
    try {
      var data = {
        "text": message,
        "suggestId": widget.user.id,
        "recipientIds": _selectedFriends,
      };
      var res = await MyHttp.post("/matches/suggest", data);
      if (res.statusCode == 200 || res.statusCode == 201) {
        // Analytics tracking code
        var jsonData = jsonDecode(res.body);
        analytics.logEvent(
            name: "suggested_a_match",
            parameters: <String, dynamic>{
              "suggested_id": widget.user.id,
              "number_of_recipient": _selectedFriends.length
            });
        amplitudeAnalytics.logEvent("suggested_a_match", eventProperties: {
          "suggested_id": widget.user.id,
          "number_of_recipient": _selectedFriends.length
        });
        print('I am in suggest a match');

        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => MatchUserProfile(
                      isMatchSuggestion: true,
                      userId: widget.user.id,
                    )));
      } else {
        print("User suggest error ${res.statusCode}");
        print("User suggest error: ${res.body}");
      }
    } catch (e) {
      print("Suggest friends error $e");
    }
  }

  @override
  void initState() {
    this._getFriends();

    super.initState();
    //Analytics code
    amplitudeAnalytics.init(apiKey);
    analytics.setCurrentScreen(
        screenName: "suggest_a_match", screenClassOverride: "suggest_a_friend");
    amplitudeAnalytics.logEvent("suggest_a_match_page");
  }

  @override
  Widget build(BuildContext context) {
    var borderSideProperty = BorderSide(color: Colors.grey, width: 0.5);
    var aa = OutlineInputBorder(
        borderSide:
            BorderSide(color: AppColors.profileSecondHeaderColor, width: 0.0),
        borderRadius: BorderRadius.circular(15.0));

    return Scaffold(
//      resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: AppColors.redColor,
          title: Text(
            "Suggest a Match",
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: SafeArea(
            child: SingleChildScrollView(
          child: Container(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          height: 70,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              ClipRRect(
                                  borderRadius: BorderRadius.circular(100.0),
                                  child: CachedNetworkImage(
                                    imageUrl: widget.user?.imageUrl ??
                                        "https://i.pinimg.com/564x/19/b8/d6/19b8d6e9b13eef23ec9c746968bb88b1.jpg",
                                    errorWidget: (context, url, error) =>
                                        Icon(Icons.error),
                                  )),
                              SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      widget.user.first_name ?? "Jane Nany",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(
                                      height: 3,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          "Share With:",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        SizedBox(
                          height: 40,
                          child: TextField(
                              cursorColor: AppColors.feedShareSearchTextColor,
                              onSubmitted: (s) {
                                if (s.trim().isNotEmpty) {
//                              this._searchText = s.trim();
//                              this._getSearchData();
                                }
                              },
                              onChanged: (s) {
                                setState(() {
                                  filter = s.trim();
                                });
                              },
                              style: TextStyle(
                                fontSize: 14.0,
                                color: AppColors.feedShareSearchTextColor,
                              ),
                              decoration: InputDecoration(
                                  contentPadding: EdgeInsets.all(0.0),
                                  fillColor: AppColors.profileSecondHeaderColor,
                                  filled: true,
                                  focusColor:
                                      AppColors.profileSecondHeaderColor,
                                  prefixIcon: Icon(
                                    Icons.search,
                                    size: 24,
                                    color: AppColors.feedShareSearchTextColor,
                                  ),
                                  hintText: "Search",
                                  hintStyle: TextStyle(
                                      color:
                                          AppColors.feedShareSearchTextColor),
                                  border: aa,
                                  focusedBorder: aa,
                                  enabledBorder: aa,
                                  disabledBorder: aa)),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 200,
                    child: ListView.builder(
                        itemCount: this._suggestedFriends.length,
                        itemBuilder: (c, i) {
                          var u = this._suggestedFriends[i];
                          if (filter.trim().isNotEmpty) {
                            if (u.u.fullName.startsWith(filter.trim()) ==
                                false) {
                              return Container();
                            }
                          }
                          return InkWell(
                              onTap: () {
                                if (u.selected) {
                                  this._selectedFriends.remove(u.u.id);
                                } else {
                                  this._selectedFriends.add(u.u.id);
                                }
                                setState(() {
                                  u.selected = !u.selected;
                                });
                              },
                              child: Container(
                                color: (u.selected)
                                    ? AppColors.noButtonColor
                                    : Colors.white,
                                height: 70,
                                padding: EdgeInsets.all(10),
                                child: Row(
                                  children: <Widget>[
                                    ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(100.0),
                                        child: CachedNetworkImage(
                                          imageUrl: u.u.imageUrl ??
                                              "https://i.pinimg.com/564x/19/b8/d6/19b8d6e9b13eef23ec9c746968bb88b1.jpg",
                                          errorWidget: (context, url, error) =>
                                              Icon(Icons.error),
                                        )),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                        child: Text(
                                      u.u.fullName ?? "",
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ))
                                  ],
                                ),
                              ));
                        }),
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "Add message:",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        TextField(
                          maxLines: 4,
                          onChanged: (s) {
                            this.message = s;
                          },
                          decoration: InputDecoration(
                            hintText: "Say something about this post...",
                            hintStyle: TextStyle(
                                fontSize: 15,
                                fontStyle: FontStyle.normal,
                                fontWeight: FontWeight.w400,
                                color: AppColors.blackColor),
                            enabledBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                borderSide: borderSideProperty),
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                borderSide: borderSideProperty),
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Container(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: MyButtons.getBorderedButton(
                          "Send", AppColors.redColor, _suggestMatch, true)),
                ]),
          ),
        )));
  }
}
