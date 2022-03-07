import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pure_match/common/MyButtons.dart';
import 'package:pure_match/models/share_user.dart';
import 'package:pure_match/models/user.dart';

import 'package:pure_match/pages/AppColors.dart';
import 'package:pure_match/pages/MyHttp.dart';
import 'package:pure_match/pages/community_profile/community_profile.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:amplitude_flutter/amplitude.dart';

class SuggestAFriend extends StatefulWidget {
  final User user;

  const SuggestAFriend({Key key, this.user}) : super(key: key);

  @override
  _SuggestAFriendState createState() => _SuggestAFriendState();
}

class _SuggestAFriendState extends State<SuggestAFriend> {
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

  void _suggestFriend() async {
    try {
      var data = {
        "text": message,
        "suggestedId": widget.user.id,
        "recipientIds": _selectedFriends,
      };
      print(data);
      var res = await MyHttp.post("/friends/suggest", data);
      if (res.statusCode == 200 || res.statusCode == 201) {
        // Analytics tracking code
        var jsonData = jsonDecode(res.body);
        analytics.logEvent(
            name: "suggested_as_friend",
            parameters: <String, dynamic>{
              "suggested_id": widget.user.id,
              "number_of_recipient": _selectedFriends.length
            });
        print('I am in suggest a friend');
        amplitudeAnalytics.logEvent("suggested_as_friend", eventProperties: {
          "suggested_id": widget.user.id,
          "number_of_recipient": _selectedFriends.length
        });

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => CommunityProfile(
                    userId: widget.user.id,
                    isFriendSuggestion: true,
                  )),
        );
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
        screenName: "suggest_a_friend",
        screenClassOverride: "suggest_a_friend");
    amplitudeAnalytics.logEvent("suggest_a_friend_page");
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
          backgroundColor: AppColors.yellowColor,
          title: Text(
            "Suggest a Friend",
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
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.cover,
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
                                  print(s);
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
                            if (u.u.fullName
                                    .toLowerCase()
                                    .startsWith(filter.toLowerCase().trim()) ==
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
                                    (u.u.imageUrl != null &&
                                            u.u.imageUrl.isNotEmpty &&
                                            u.u.imageUrl != "na")
                                        ? ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(100.0),
                                            child: CachedNetworkImage(
                                              imageUrl: u.u.imageUrl ??
                                                  "https://i.pinimg.com/564x/19/b8/d6/19b8d6e9b13eef23ec9c746968bb88b1.jpg",
                                              width: 46,
                                              height: 46,
                                              fit: BoxFit.cover,
                                              errorWidget:
                                                  (context, url, error) =>
                                                      Icon(Icons.error),
                                            ))
                                        : Icon(Icons.person, size: 46),
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
                          textInputAction: TextInputAction.done,
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
                          "Send", AppColors.yellowColor, _suggestFriend, true)),
                ]),
          ),
        )));
  }
}
