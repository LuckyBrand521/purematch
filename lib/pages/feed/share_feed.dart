import 'dart:convert';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:pure_match/common/MyButtons.dart';
import 'package:pure_match/common/RoundIndicators.dart';
import 'package:pure_match/models/post.dart';
import 'package:pure_match/models/share_user.dart';
import 'package:pure_match/models/user.dart';

import 'package:pure_match/pages/AppColors.dart';
import 'package:amplitude_flutter/amplitude.dart';

import 'package:shared_preferences/shared_preferences.dart';
import '../MyHttp.dart';

class ShareFeed extends StatefulWidget {
  final postId;

  const ShareFeed({Key key, @required this.postId}) : super(key: key);

  @override
  _ShareFeedState createState() => _ShareFeedState();
}

class _ShareFeedState extends State<ShareFeed> {
  // Analytics code
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';

  Post p;
  List<ShareUser> _suggestedFriends = [];
  List<int> _selectedSuggestedFriendIds = [];
  String filter = "";
  String message = "";

  void _getFeed(int postId) async {
    try {
      var res = await MyHttp.get("/posts/post/$postId");
      if (res.statusCode == 200) {
        var body = json.decode(res.body);
        var p = body["post"];
        var sp = await SharedPreferences.getInstance();
        int userId = sp.getInt("id");
        setState(() {
          // this.p = Post(id, text, u, images, false, createdAt);
          this.p = Post.fromJson(p, userId);
        });
      }
    } catch (e) {
      print("Err $e");
    }
  }

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

  void _sharePost() async {
    if (this._selectedSuggestedFriendIds.length == 0) return;
    try {
      var data = {
        "userId": this._selectedSuggestedFriendIds,
        "message": this.message,
      };
      var res = await MyHttp.post("/posts/share/${widget.postId}/", data);
      print(res.statusCode);
      print(res.body);
      if (res.statusCode == 200 || res.statusCode == 201) {
        Navigator.pop(context);
        //Analytic code
        var jsonData = jsonDecode(res.body);
        analytics.logEvent(name: "shared_post", parameters: <String, dynamic>{
          "user_id": jsonData["notif"]["UserId"],
          "post_id": widget.postId
        });
        amplitudeAnalytics.logEvent("shared_post", eventProperties: {
          "user_id": jsonData["notif"]["UserId"],
          "post_id": widget.postId
        });
      }
    } catch (e) {
      print("_sharePost error: $e");
    }
  }

  @override
  void initState() {
    // Analytics tracking code
    amplitudeAnalytics.init(apiKey);
    analytics.setCurrentScreen(
        screenName: "share_post", screenClassOverride: "share_post");
    amplitudeAnalytics.logEvent("share_post_page");

    this._getFriends();
    this._getFeed(widget.postId);
    super.initState();
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
            "Share Post",
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
                                child: (p?.user?.imageUrl != null &&
                                        p?.user?.imageUrl.isNotEmpty &&
                                        p?.user?.imageUrl != "na")
                                    ? CachedNetworkImage(
                                        imageUrl: p?.user?.imageUrl ??
                                            "https://i.pinimg.com/564x/19/b8/d6/19b8d6e9b13eef23ec9c746968bb88b1.jpg",
                                        errorWidget: (context, url, error) =>
                                            Icon(Icons.error),
                                      )
                                    : Icon(Icons.person, size: 30),
                              ),
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
                                      p?.user?.fullName ?? "Jane Nany",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(
                                      height: 3,
                                    ),
                                    Text(
                                      p?.createdAt ?? "Today at 3:30pm",
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 10),
                          child: Text(
                            p?.text ??
                                "Getting as group together to play ultimate frisbee.  Anyone wanna join?",
                            style: TextStyle(color: AppColors.blackColor),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        ((p?.images ?? []).length > 0)
                            ? CarouselSlider(
                                options: CarouselOptions(
                                  viewportFraction: 1.0,
                                  onPageChanged: (i, pageChangedReason) {
                                    setState(() {
                                      p.carouselIndex = i;
                                    });
                                  },
                                ),
                                items: (p?.images ?? []).map((i) {
                                  return CachedNetworkImage(
                                    imageUrl: i,
                                    errorWidget: (context, url, error) =>
                                        Icon(Icons.error),
                                  );
                                }).toList(),
                              )
                            : Container(),
                        ((p?.images ?? []).length > 0)
                            ? RoundIndicators(
                                circleSize: 12,
                                currentIndicatorIndex: p.carouselIndex,
                                numberOfInidcators: (p?.images ?? []).length,
                                bubbleColor: AppColors.yellowColor,
                                disableBubbleColor: AppColors.greyColor,
                                borderColor: Colors.white,
                              )
                            : Container(),
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
                                  this
                                      ._selectedSuggestedFriendIds
                                      .remove(u.u.id);
                                } else {
                                  this._selectedSuggestedFriendIds.add(u.u.id);
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
                          "Share", AppColors.yellowColor, () {
                        this._sharePost();
                      }, true)),
                ]),
          ),
        )));
  }
}
