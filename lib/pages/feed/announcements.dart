import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:io' show Platform;
import 'dart:convert' as convert;
import 'dart:ui';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:pure_match/common/MyButtons.dart';
import 'package:pure_match/common/RoundIndicators.dart';
import 'package:pure_match/common/global.dart';
import 'package:pure_match/common/triangle.dart';
import 'package:pure_match/models/post.dart';
import 'package:pure_match/models/user.dart';

import 'package:pure_match/pages/AppColors.dart';
import 'package:pure_match/pages/MyHttp.dart';
import 'package:pure_match/pages/community_profile/community_profile.dart';
import 'package:pure_match/pages/feed/create_feed.dart';
import 'package:pure_match/pages/feed/feed_detail.dart';
import 'package:pure_match/pages/feed/post_feed.dart';
import 'package:http/http.dart' as http;
import 'package:pure_match/pages/feed/search_feed.dart';
import 'package:pure_match/pages/feed/share_feed.dart';
import 'package:pure_match/pages/messaging/home_page.dart';
import 'package:pure_match/pages/own_profile/edit_profile_pictures.dart';
import 'package:pure_match/pages/settings/settings_main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:amplitude_flutter/amplitude.dart';
import 'package:http_parser/http_parser.dart';
import '../MyUrl.dart';

class AnnouncementsPage extends StatefulWidget {
  @override
  _AnnouncementsPageState createState() => _AnnouncementsPageState();
}

class _AnnouncementsPageState extends State<AnnouncementsPage> {
  List<Post> _announcements = [];
  ScrollController _sc = new ScrollController();
  var isFirstTime;

  // this is for posting the feed only
  List<File> _toPostImages = [];
  String _toPostText = "";
  double _postingProgress = 10;
  bool _postingFeed = false;
  Timer _progressTimer;
  User _user;
  bool _loading = false;
  bool _isAdmin = false;
  bool _isAnnouncement = false;
  int liked = 0;
  int saved = 0;
  int myPost = 0;
  String error = "";
  bool isImgSelected = false;
  String selectedImageUrl = "";

  void _resetToPostVars() {
    if (this.mounted) {
      setState(() {
        this._postingProgress = 0;
        this._postingFeed = false;
        this._toPostImages.clear();
        this._toPostText = "";
      });
    }
  }

  InkWell _getLikeOption(User u) {
    return InkWell(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            (u?.imageUrl != null &&
                    u?.imageUrl.isNotEmpty &&
                    u?.imageUrl != "na")
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(100.0),
                    child: CachedNetworkImage(
                      width: 35,
                      imageUrl: u?.imageUrl,
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ))
                : Icon(Icons.person, size: 35),
            SizedBox(
              width: 8,
            ),
            Expanded(
                child: InkWell(
              child: Text(
                u?.fullName ?? "Preet",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CommunityProfile(
                              userId: _user.id,
                            )));
              },
            ))
          ],
        ),
      ),
    );
  }

  void _likePost(int id) async {
    print("Id is $id");
    try {
      var data = {};
      var res = await MyHttp.post("/posts/like/post/$id", data);
      var jsonData = jsonDecode(res.body);
      print("Post liked");
      print(res.statusCode);
      print(res.body);
    } catch (e) {
      print("Like error");
      print(e);
    }
  }

  void _unlikePost(int id) async {
    print("Id is $id");
    print("unlike kra");
    try {
      var res = await MyHttp.delete("/posts/like/post/$id");

      //Analytics tracking code
      var jsonData = jsonDecode(res.body);
      print("Post unliked done ${res.body}");
    } catch (e) {
      print("UnLike error");
      print(e);
    }
  }

  /// Gets the announcements from the API
  Future<void> _getAnnouncements() async {
    try {
      print("IT GOT IN HERE!!!!!!!!!");
      var res = await MyHttp.get("/users/announcements");
      if (res.statusCode == 200) {
        print("IT GOT IN HERE!222222222!!!!!!!!");
        var body = jsonDecode(res.body);
        print(body);
        //get the announcements and puts them in a list
        var announcements = body["announcements"] as List<dynamic>;
        var sp = await SharedPreferences.getInstance();
        int userId = sp.getInt("id");
        //Goes through the list and turns them into a post and put them in the announcements[] field
        for (var a in announcements) {
          Post post = Post.fromJson(a, userId);
          if (this.mounted) {
            setState(() {
              //print("mater=${post.user.marital_status}");
              //this is where it is put into the list
              this._announcements.add(post);
              _loading = false;
            });
          }
        }
        print(_announcements);
        //print(body["announcements"]);
      }
    } catch (e) {}
  }

  Future<void> openDialog(List<User> likedByUsers) async {
    List<Widget> likeDialogContent = [];
    print(likedByUsers);
    for (var u in likedByUsers) {
      print(u.fullName);
      likeDialogContent.add(this._getLikeOption(u));
    }

    var res = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            titlePadding: EdgeInsets.all(0),
            contentPadding: EdgeInsets.all(0),
            title: Container(
                width: double.infinity,
                color: AppColors.yellowColor,
                padding: EdgeInsets.all(4),
                child: Text(
                  "Likes",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                )),
            children: <Widget>[
              Container(
                height: 250,
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: SingleChildScrollView(
                        child: ListBody(
                          children: likeDialogContent,
                        ),
                      ),
                    ),
                    Container(
                      color: AppColors.yellowColor,
                      height: 6,
                      width: double.infinity,
                    )
                  ],
                ),
              )
            ],
          );
        });
  }

  _openIosOptions() {
    return showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) {
          return CupertinoActionSheet(
            actions: <Widget>[
              CupertinoActionSheetAction(
                child: Text("Save"),
                onPressed: () {},
              ),
              CupertinoActionSheetAction(
                child: Text(
                  "Report",
                  style: TextStyle(color: Colors.red),
                ),
                onPressed: () {},
              ),
            ],
          );
        });
  }

  @override
  void initState() {
    // TODO: implement initState
    _getAnnouncements();
    super.initState();
  }

  Container _showLoading() {
    return Container(
      height: double.infinity,
      child: Center(
        child: PlatformCircularProgressIndicator(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.yellowColor,
        title: Text(
          "Announcements",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.w600, fontSize: 24),
        ),
        bottom: PreferredSize(
            child: Container(), preferredSize: const Size.fromHeight(0.0)),
        actions: <Widget>[
          /*InkWell(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SearchFeed()));
              },
              child: SizedBox(
                  width: 90,
                  height: 30,
                  child: Padding(
                    padding: EdgeInsets.only(right: 25),
                    child: Image.asset(
                      "assets/images/search_bar.png",
                      fit: BoxFit.contain,
                    ),
                  )),
            ),*/
          InkWell(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => MainSettings()));
              },
              child: Padding(
                padding: EdgeInsets.only(right: 10),
                child: SizedBox(
                    width: 35,
                    height: 31,
                    child: Image.asset(
                      "assets/images/setting_logo.png",
                      fit: BoxFit.contain,
                    )),
              )),
        ],
      ),
      body: SafeArea(
        child: Container(
          child: (this._loading)
              ? this._showLoading()
              : RefreshIndicator(
                  onRefresh: _getAnnouncements,
                  child: ListView.builder(
                      itemCount: _announcements.length,
                      controller: _sc,
                      itemBuilder: (context, index) {
                        if (index == _announcements.length) {
                          return _showLoading();
                        }
                        Post p = _announcements[index];
                        return (CreateFeed.createPost(
                            context, p, this._openIosOptions, () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => FeedDetail(
                                        postId: p.id,
                                      ))).then((v) {
                            this._getAnnouncements();
                          });
                        }, (i) {
                          setState(() {
                            p.carouselIndex = i;
                          });
                        }, () {
                          openDialog(p?.likedByUsers);
                        }, () {
                          setState(() {
                            if (p.liked)
                              p.numberOfLikes--;
                            else
                              p.numberOfLikes++;
                            p.liked = !p.liked;
                          });
                          if (p.liked)
                            this._likePost(p.id);
                          else
                            this._unlikePost(p.id);
                        }, () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ShareFeed(
                                        postId: p?.id,
                                      )));
                        }, () async {
                          var sp = await SharedPreferences.getInstance();
                          int currentUserId = sp.getInt("id");
                          if (currentUserId == p?.user?.id) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        CommunityProfile(userId: _user.id)));
                          } else
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => CommunityProfile(
                                          userId: p.user.id,
                                        )));
                        }, (imgUrl) {
                          print("imgUrl=$imgUrl");
                          isImgSelected = true;
                          selectedImageUrl = imgUrl;
                          //savePosition();
                          if (this.mounted) {}
                          setState(() {});
                        }, false));
                      }),
                ),
        ),
      ),
    );
  }
}
