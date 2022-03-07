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
import 'package:pure_match/pages/feed/share_feed.dart';
import 'package:pure_match/pages/messaging/home_page.dart';
import 'package:pure_match/pages/own_profile/edit_profile_pictures.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:amplitude_flutter/amplitude.dart';
import 'package:http_parser/http_parser.dart';
import '../MyUrl.dart';

enum PostAction { LIKE, COMMENT, SHARE }

enum FeedType { My_FEED, LIKED, SAVED, MY_POST }

class MyActivity extends StatefulWidget {
  final FeedType feedType;
  final int postId;
  const MyActivity({Key key, @required this.feedType, this.postId})
      : super(key: key);
  @override
  _MyActivityState createState() => _MyActivityState();
}

class _MyActivityState extends State<MyActivity> {
  // Analytics code
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';

  String dropdownValue = "Community";
  List<String> imagesLink = [
    "https://blog.capterra.com/wp-content/uploads/2016/12/women_in_tech-720x360.jpg",
    "https://strategicpsychology.com.au/wp-content/uploads/two-girls-with-laptop-and-smart-phone-outdoors-720x360.jpg",
  ];
  int carouselIndex = 0;

  List<Post> _posts = [];
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

  double scroll_p = 0;

  void savePosition() {
    scroll_p = _sc.offset;
  }

  void getAdminStatus() async {
    try {
      var res = await MyHttp.get("/admin/check-admin");
      if (res.statusCode == 200) {
        var body = convert.json.decode(res.body);
        print(")))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))");
        print(body);
        _isAdmin = body["isAdmin"];
      }
    } catch (e) {
      print(
          ")))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))didnt");
    }
  }

  void goToSavedPosition(BuildContext context) {
    print("are youc allinmg me?");
    if (scroll_p != 0 && !isImgSelected) {
      // _sc.jumpTo(scroll_p);
      _sc.animateTo(scroll_p,
          duration: Duration(microseconds: 1), curve: Curves.easeOut);
      scroll_p = 0;
    }
  }

  void tutorialPage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isFirstTime = prefs.getBool('first_time');
    print(
        "I AM ABOUT TO PRINT OUT WHAT I WANT TO SEE!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
    print(prefs.getBool('first_time'));
    if (isFirstTime != null && !isFirstTime) {
      print("not first time");
      prefs.setBool('first_time', false);
    } else {
      setState(() {
        isFirstTime = true;
      });
      print("first time app runn!!!");
      prefs.setBool('first_time', false);
    }
    // isFirstTime=true;
  }

  void _emptyList() {
    _posts = [];
    _getFeed();
  }

  void _postFeed() async {
    if (this.mounted) {
      setState(() {
        this._postingFeed = true;
      });
    }

    var w = MediaQuery.of(context).size.width;
    this._progressTimer = Timer.periodic(Duration(milliseconds: 5), (timer) {
      if (this._postingProgress >= w - 1) {
        timer.cancel();
        return;
      }
      if (this.mounted) {
        setState(() {
          this._postingProgress += 2;
        });
      }
    });
    try {
      var sp = await SharedPreferences.getInstance();
      String token = sp.getString("token");
      var request = new http.MultipartRequest(
          "POST", Uri.parse(MyUrl.url("/posts/create")));
      request.headers["authorization"] = "Bearer $token";

      for (var img in this._toPostImages) {
        if (img == null) continue;
        var f = http.MultipartFile(
            'file', img.readAsBytes().asStream(), img.lengthSync(),
            filename: img.path, contentType: MediaType('image', 'jpg'));
        request.files.add(f);
      }
      request.fields['text'] = this._toPostText;
      request.fields['announcement'] = this._isAnnouncement.toString();
      var res = await request.send();
      if (res.statusCode == 200 || res.statusCode == 201) {
        print("Uploaded");
        var body = await utf8.decodeStream(res.stream);

        print(body);

        this._getFeed();
        //Analytics tracking code
        analytics.logEvent(
            name: "posted_feed",
            parameters: <String, dynamic>{'user_id': _user.id.toString()});
        amplitudeAnalytics.logEvent("posted_feed",
            eventProperties: {'user_id': _user.id.toString()});
      } else {
        if (this.mounted) {
          setState(() {
            error = "Error ${res.statusCode}";
          });
        }
      }
    } catch (e) {
      if (this.mounted) {
        setState(() {
          error = e.toString();
        });
      }
    }
    this._resetToPostVars();
  }

  void _getUserDetails() async {
    if (this.mounted) {
      setState(() {
        _loading = true;
      });
    }

    _user = await MyHttp.getUserDetails();
    if (this.mounted) {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _getFeed() async {
    print("empty post list ");
    _posts = [];
    if (this.mounted) {
      setState(() {
        _loading = true;
      });
    }

    try {
      String url;
      switch (widget.feedType) {
        case FeedType.LIKED:
          url = "/posts/liked";
          break;
        case FeedType.My_FEED:
          url = "/users/feed";
          break;
        case FeedType.SAVED:
          url = "/posts/saved";
          break;
        case FeedType.MY_POST:
          url = "/posts";
          break;
      }

      if (this._posts.length > 0) {
        url += "/${this._posts.last.id}";
      }
      print(url);
      var res = await MyHttp.get(url);
      if (res.statusCode == 201) {
        var body = json.decode(res.body);
        var sp = await SharedPreferences.getInstance();
        int userId = sp.getInt("id");
        var announcements = body["announcement"] as List<dynamic>;
        print(announcements);
        print("There should have been announcements in here!!!!!!!!!!");
        if (announcements != null) {
          for (var a in announcements) {
            Post post = Post.fromJson(a, userId);
            if (this.mounted) {
              setState(() {
                //print("mater=${post.user.marital_status}");
                this._posts.add(post);
                _loading = false;
              });
            }
          }
        }
      }
      if (res.statusCode == 200) {
        var body = json.decode(res.body);
        var posts = body["posts"] ??
            body["feed"] ??
            body["LikedPosts"] as List<dynamic>;
        print("&&&&&&&&&&&&&&&&&&&&&&&&&&");
        print(body["announcement"]);
        if (posts != null && posts.length > 0) {
          var sp = await SharedPreferences.getInstance();
          int userId = sp.getInt("id");
          var announcements = body["announcement"] as List<dynamic>;
          if (announcements != null) {
            for (var a in announcements) {
              Post post = Post.fromJson(a, userId);
              if (this.mounted) {
                setState(() {
                  //print("mater=${post.user.marital_status}");
                  this._posts.add(post);
                  _loading = false;
                });
              }
            }
          }
          for (var p in posts) {
            print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@");
            print(p);
            Post post = Post.fromJson(p, userId);
            if (this.mounted) {
              setState(() {
                print("mater=${post.user.marital_status}");
                this._posts.add(post);
                _loading = false;
              });
            }
          }
        }
      } else {
        print("my_activity _getFeed Errr1: ${res.statusCode}");
        print("my_activity _getFeed Errr2: ${res.body}");
      }
    } catch (e, stacktrace) {
      print("my_activity _getData Err: $e");
      print(stacktrace);
      if (this.mounted) {
        setState(() {
          error = "$e";
        });
      }
    }
    if (this.mounted) {
      setState(() {
        _loading = false;
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
      //Analytics tracking code
      var jsonData = jsonDecode(res.body);
      analytics.logEvent(name: 'liked_post', parameters: <String, dynamic>{
        "user_id": jsonData["notif"]["UserId"],
        'post_user_id': jsonData["notif"]["recipientId"],
        'post_id': id
      });
      amplitudeAnalytics.logEvent("liked_post", eventProperties: {
        "user_id": jsonData["notif"]["UserId"],
        'post_user_id': jsonData["notif"]["recipientId"],
        'post_id': id,
      });

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
      analytics.logEvent(name: 'unliked_post', parameters: <String, dynamic>{
        "user_id": jsonData["notif"]["UserId"],
        'post_user_id': jsonData["notif"]["recipientId"],
        'post_id': id
      });
      amplitudeAnalytics.logEvent("unliked_post", eventProperties: {
        "user_id": jsonData["notif"]["UserId"],
        'post_user_id': jsonData["notif"]["recipientId"],
        'post_id': id
      });

      print("Post unliked done ${res.body}");
    } catch (e) {
      print("UnLike error");
      print(e);
    }
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

  ///This will host all the api calls needed for saving, deleting and editing a post
  void _postApiCalls(String call, Post p) async {
    String url;
    int id = p?.id;
    print("THIS IS THE POST ID BELOW");
    print(id);
    var res;
    try {
      if (call == "Save") {
        url = "posts/save/$id";
        res = await MyHttp.post(url, {});
      } else if (call == "Edit") {
        url = "posts/update/$id";
        res = await MyHttp.put(url, {});
      } else if (call == "Delete") {
        url = "posts/delete/$id";
        res = await MyHttp.delete(url);
      } else {}
      if (res.statusCode == 200 || res.statusCode == 201) {
        Navigator.pop(context);
        print("WE DID IT SUCCESS####");
        this._getFeed();
      } else {
        print("WE DIDNT DO IT FAILURE ####");
      }
    } catch (e) {}
  }

  _openIosOptions({Post post}) {
    ///TODO: figure out how to replace p with the actual post
    //Post p = null;
    return showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) {
          if (post.user.id == _user.id) {
            return CupertinoActionSheet(
              actions: <Widget>[
                CupertinoActionSheetAction(
                  child: Text("Save"),
                  onPressed: () {
                    _postApiCalls("Save", post);
                  },
                ),
                /*CupertinoActionSheetAction(
                child: Text("Edit"),
                onPressed: () {
                  _postApiCalls("Edit", post);
                },
              ),*/

                CupertinoActionSheetAction(
                  child: Text("Delete"),
                  onPressed: () {
                    _postApiCalls("Delete", post);
                  },
                ),
                CupertinoActionSheetAction(
                  child: Text(
                    "Report",
                    style: TextStyle(color: Colors.red),
                  ),
                  onPressed: () {
                    //Analytics tracking code
                    analytics.logEvent(
                        name: 'report_post',
                        parameters: <String, dynamic>{'post_id': _user.id});
                    amplitudeAnalytics.logEvent("report_post",
                        eventProperties: {'post_id': _user.id});
                  },
                ),
              ],
            );
          } else {
            return CupertinoActionSheet(
              actions: <Widget>[
                CupertinoActionSheetAction(
                  child: Text("Save"),
                  onPressed: () {
                    _postApiCalls("Save", post);
                  },
                ),
                CupertinoActionSheetAction(
                  child: Text(
                    "Report",
                    style: TextStyle(color: Colors.red),
                  ),
                  onPressed: () {
                    //Analytics tracking code
                    analytics.logEvent(
                        name: 'report_post',
                        parameters: <String, dynamic>{'post_id': _user.id});
                    amplitudeAnalytics.logEvent("report_post",
                        eventProperties: {'post_id': _user.id});
                  },
                ),
              ],
            );
          }
        });
  }

  void showTutorial() async {
    await tutorialPage();
  }

  @override
  void initState() {
    this._getUserDetails();
    //Analytics code
    amplitudeAnalytics.init(apiKey);

    this._getFeed();
    showTutorial();
    _checkFromPN();
    getAdminStatus();
    super.initState();
    _sc.addListener(() {
      if (_sc.position.pixels == _sc.position.maxScrollExtent) {
        _paginatedFeed();
      }
    });
  }

  void _checkFromPN() {
    if (widget.postId == null || widget.postId == 0) {
      return;
    }

    SchedulerBinding.instance.addPostFrameCallback((_) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => FeedDetail(
                    postId: widget.postId,
                  ))).then((v) {
        this._getFeed();
      });
    });
  }

  void _paginatedFeed() async {
    try {
      var id = _posts.last.id - 1;
      var res = await MyHttp.get("/users/feed/$id");
      if (res.statusCode == 200) {
        print("Success");
        print(res.body);
        var body = json.decode(res.body);
        var posts = body["posts"] ??
            body["feed"] ??
            body["LikedPosts"] as List<dynamic>;
        if (posts != null && posts.length > 0) {
          var sp = await SharedPreferences.getInstance();
          int userId = sp.getInt("id");
          for (var p in posts) {
            print("****PPPP");
            print(p);
            // int id = p["id"];
            // String text = p["text"];
            // String createdAt = p["createdAt"];
            // var user = p["User"] ?? p["Author"];
            // User u = User.fromJson(user);
            // List<dynamic> imagesData = p["PostUploads"];
            // List<String> images = [];
            // if (imagesData != null && imagesData.length > 0) {
            //   for (var img in imagesData) {
            //     String path = img["path"];
            //     images.add(path);
            //   }
            // }
            // List<dynamic> likes = p["Likes"];
            // bool liked = false;
            // int numberOfLikes = 0;
            // List<User> likedByUsers = [];
            // if (likes != null && likes.length > 0) {
            //   liked = true;
            //   numberOfLikes = likes.length;
            //   for (var l in likes) {
            //     var lu = l["User"];
            //     var lUser = User.fromJson(lu);
            //     likedByUsers.add(lUser);
            //   }
            // }
            // List<dynamic> comments = p["Comments"];
            // int commentsCount = 0;
            // if (comments != null && comments.length > 0) {
            //   commentsCount = comments.length;
            // }
            // Post post = Post(id, text, u, images, liked, createdAt,
            //     numberOfLikes: numberOfLikes,
            //     numberOfComments: commentsCount,
            //     likedByUsers: likedByUsers);

            Post post = Post.fromJson(p, userId);
            if (this.mounted) {
              setState(() {
                this._posts.add(post);
              });
            }
          }
        }
      } else {
        print("errorrrrr${res.body}");
        print("Errr1: ${res.statusCode}");
      }
    } catch (e) {
      print("Like error");
      print(e);
    }
    if (this.mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    this._progressTimer?.cancel();
    super.dispose();
  }

  Container createPost(Post p) {
    print("WE ARE GOING TO TEST THIS PUT RN ^^^^^^^^^^^^^^^^^^^^^^^^^");
    print(p.announcement);
    return Container(
      color: Colors.white,
      child: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  height: 50,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      (p?.user?.imageUrl != null &&
                              p?.user?.imageUrl.isNotEmpty &&
                              p?.user?.imageUrl != "na")
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(100.0),
                              child: p?.announcement
                                  ? Container(
                                      width: 50,
                                      height: 50,
                                      child: Image.asset(
                                          "assets/images/dark_logo.png"),
                                    )
                                  : CachedNetworkImage(
                                      imageUrl: p?.user?.imageUrl ??
                                          "https://i.pinimg.com/564x/19/b8/d6/19b8d6e9b13eef23ec9c746968bb88b1.jpg",
                                      errorWidget: (context, url, error) =>
                                          Icon(Icons.error),
                                    ))
                          //this code puts the pure match logo on the post if it is an announcement
                          : (p?.announcement != null && p?.announcement == true)
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(100.0),
                                  child: Container(
                                    width: 50,
                                    height: 50,
                                    child: Image.asset(
                                        "assets/images/dark_logo.png"),
                                  ),
                                )
                              : Icon(Icons.person, size: 35),
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
                            InkWell(
                              child: Text(
                                p?.announcement
                                    ? "Pure Match"
                                    : p?.user?.fullName ?? "Pure Match",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold),
                              ),
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          CommunityProfile(userId: _user.id),
                                    ));
                              },
                            ),
                            SizedBox(
                              height: 3,
                            ),
                            Text(
                              p?.createdAt ?? "Today at 3:30pm",
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      (Platform.isAndroid)
                          ? PopupMenuButton(
                              onSelected: (i) {
                                switch (i) {
                                  case 1:
                                    print("i=1");
                                    break;
                                  case 2:
                                    print("i=2");
                                    break;
                                }
                              },
                              itemBuilder: (BuildContext context) {
                                return <PopupMenuEntry>[
                                  PopupMenuItem(
                                    child: Text("Save"),
                                    value: 1,
                                  ),
                                  PopupMenuItem(
                                    child: Text(
                                      "Report",
                                      style: TextStyle(color: Colors.red),
                                    ),
                                    value: 2,
                                  ),
                                ];
                              },
                            )
                          : IconButton(
                              onPressed: () {
                                this._openIosOptions;
                              },
                              icon: Icon(CupertinoIcons.ellipsis),
                            )
                    ],
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => FeedDetail(
                                  postId: p.id,
                                ))).then((v) {
                      this._getFeed();
                    });
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(left: 10),
                        child: Text(
                          p?.text ??
                              "Sorry! It's either taking us longer to load the page you clicked on, or we can't find that post anymore.",
                          style: TextStyle(color: AppColors.blackColor),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      if ((p?.images ?? []).length > 0)
                        CarouselSlider(
                          options: CarouselOptions(
                            viewportFraction: 1.0,
                            onPageChanged: (i, pageChangedReason) {
                              if (this.mounted) {
                                setState(() {
                                  p.carouselIndex = i;
                                });
                              }
                            },
                          ),
                          items: p.images.map((i) {
                            return (i != null && i.isNotEmpty && i != "na")
                                ? CachedNetworkImage(
                                    imageUrl: i,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorWidget: (context, url, error) =>
                                        Icon(Icons.error),
                                  )
                                : Icon(Icons.person, size: 35);
                          }).toList(),
                        ),
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
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    openDialog(p?.likedByUsers);
                  },
                  child: Container(
                      width: double.infinity,
                      child: Text(
                        "${p?.numberOfLikes} likes ${p?.numberOfComments} comments",
                        style: TextStyle(
                            color: AppColors.blackColor, fontSize: 12),
                        textAlign: TextAlign.right,
                      )),
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    MyButtons.getActionButtons(1, 0, "Like", () {
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
                    }, p.liked),
                    MyButtons.getActionButtons(1, 1, "Comment", () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => FeedDetail(postId: p.id)));
                    }, false),
                    MyButtons.getActionButtons(1, 2, "Share", () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ShareFeed(
                                    postId: p?.id,
                                  )));
                    }, false),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            height: 10,
            child: Container(
              color: AppColors.greyColor,
            ),
          )
        ],
      ),
    );
  }

  var showed = false;
  void showNoProfilePopup() {
    if (!Global.hasProfileImg && !showed) {
      showed = true;
      Global.alertUserForCardAction(context, "No profile image.",
          "Would you please add your profile image first?", "Ok", () {
        Navigator.pop(context);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => EditProfilePictures(
                    profilePicturePath: "na",
                    imagePaths: [null, null, null, null, null])));
      }, "", null, "", null);
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    print("build");
    WidgetsBinding.instance
        .addPostFrameCallback((_) => goToSavedPosition(context));
    // TODO: to get the feed everytime the page appears and remove getting feed from navigator.pop when the user opens to view post in detail & performs action.
    final myBorder = OutlineInputBorder(
      borderSide: BorderSide(color: Colors.transparent),
      borderRadius: const BorderRadius.all(
        const Radius.circular(50.0),
      ),
    );
    if (!showed) {
      Future.delayed(const Duration(seconds: 1), () {
        showNoProfilePopup();
      });
    }
    return (!isImgSelected)
        ? Stack(fit: StackFit.loose, children: [
            Container(
              color: AppColors.greyColor,
              child: Column(
                children: (this.error != null && this.error.isNotEmpty)
                    ? <Widget>[
                        Text(
                          "${this.error}",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w500),
                        ),
                      ]
                    : <Widget>[
                        (_postingFeed)
                            ? Column(
                                children: <Widget>[
                                  Container(
                                    color: AppColors.noButtonColor,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Container(
                                          color: AppColors.blueColor,
                                          child: SizedBox(
                                            width: this._postingProgress,
                                            height: 5,
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.all(8),
                                          child: Row(
                                            children: <Widget>[
                                              (_user?.imageUrl != null &&
                                                      _user?.imageUrl
                                                          .isNotEmpty &&
                                                      _user?.imageUrl != "na")
                                                  ? ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              100.0),
                                                      child: CachedNetworkImage(
                                                        width: 55,
                                                        imageUrl:
                                                            _user?.imageUrl,
                                                        errorWidget: (context,
                                                                url, error) =>
                                                            Icon(Icons.error),
                                                      ))
                                                  : Icon(Icons.person,
                                                      size: 100),
                                              Expanded(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(
                                                    "Uploading new post",
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  )
                                ],
                              )
                            : Container(),
                        (widget.feedType == FeedType.My_FEED &&
                                _loading == false)
                            ? InkWell(
                                onTap: () {
                                  if (this._postingFeed) {
                                    return;
                                  }
                                  this._resetToPostVars();
                                  Navigator.of(context)
                                      .push(MaterialPageRoute(
                                          builder: (context) =>
                                              PostFeed(isAdmin: _isAdmin)))
                                      .then((data) {
                                    this._toPostText = data["text"];
                                    this._toPostImages = data["images"];
                                    this._isAnnouncement = data["announcement"];
                                    this._postFeed();
                                  });
                                },
                                child: Container(
                                  height: 70,
                                  color: Colors.white,
                                  padding: EdgeInsets.all(8),
                                  child: Row(
                                    children: <Widget>[
                                      (_user != null &&
                                              _user.imageUrl != null &&
                                              _user.imageUrl.isNotEmpty &&
                                              _user.imageUrl != "na")
                                          ? ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(100.0),
                                              child: CachedNetworkImage(
                                                imageUrl: _user?.imageUrl,
                                                fit: BoxFit.cover,
                                                width: 50,
                                                height: 70,
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Icon(Icons.error),
                                              ))
                                          : Container(),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Expanded(
                                        child: Text(
                                          "Write something...",
                                          textAlign: TextAlign.left,
                                        ),
                                      ),
                                      Icon(
                                        Icons.camera_alt,
                                        size: 30,
                                        color: Colors.black,
                                      )
                                    ],
                                  ),
                                ),
                              )
                            : Container(),
                        SizedBox(
                          height: 10,
                        ),
                        Expanded(
                          child: (this._loading)
                              ? this._showLoading()
                              : RefreshIndicator(
                                  onRefresh: _getFeed,
                                  child: ListView.builder(
                                      itemCount: _posts.length,
                                      controller: _sc,
                                      itemBuilder: (context, index) {
                                        if (index == _posts.length) {
                                          return _showLoading();
                                        }
                                        Post p = _posts[index];
                                        return (CreateFeed.createPost(
                                            context, p, () {
                                          this._openIosOptions(post: p);
                                        }, () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      FeedDetail(
                                                        postId: p.id,
                                                      ))).then((v) {
                                            this._getFeed();
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
                                                  builder: (context) =>
                                                      ShareFeed(
                                                        postId: p?.id,
                                                      )));
                                        }, () async {
                                          var sp = await SharedPreferences
                                              .getInstance();
                                          int currentUserId = sp.getInt("id");
                                          if (currentUserId == p?.user?.id) {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        CommunityProfile(
                                                            userId: _user.id)));
                                          } else
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        CommunityProfile(
                                                          userId: p.user.id,
                                                        )));
                                        }, (imgUrl) {
                                          print("imgUrl=$imgUrl");
                                          isImgSelected = true;
                                          selectedImageUrl = imgUrl;
                                          savePosition();
                                          if (this.mounted) {}
                                          setState(() {});
                                        }, true));
                                      }),
                                ),
                        ),
                      ],
              ),
            ),
            (widget.feedType == FeedType.LIKED &&
                    liked == 0 &&
                    isFirstTime == true)
                ? Stack(children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        width: MediaQuery.of(context).size.width / 2.8,
                        height: 130,
                        padding: EdgeInsets.symmetric(
                            vertical: 23.0, horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Column(
                          children: [
                            Text(
                              "This is to get your liked messages",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            ButtonTheme(
                              padding: EdgeInsets.symmetric(
                                  vertical: 8.0,
                                  horizontal:
                                      18.0), //adds padding inside the button
                              materialTapTargetSize: MaterialTapTargetSize
                                  .shrinkWrap, //limits the touch area to the button area
                              minWidth: 0, //wraps child's width
                              height: 0,
                              child: FlatButton(
                                onPressed: () {
                                  liked = 1;
                                  if (this.mounted) {
                                    setState(() {});
                                  }
                                },
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(2),
                                    side: BorderSide(
                                        color: AppColors.blueColor, width: 2)),
                                color: AppColors.blueColor,
                                child: Text(
                                  "Got it",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 12),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                        right: MediaQuery.of(context).size.width / (2.8 * 2),
                        top: 10,
                        child: this._triangle()),
                  ])
                : Container(),
            (widget.feedType == FeedType.SAVED &&
                    saved == 0 &&
                    isFirstTime == true)
                ? Positioned(
                    right: (MediaQuery.of(context).size.width / 3),
                    child: Stack(children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          width: MediaQuery.of(context).size.width / 2.8,
                          height: 130,
                          padding: EdgeInsets.symmetric(
                              vertical: 23.0, horizontal: 10),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Column(
                            children: [
                              Text(
                                "This is to get your saved messages",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              ButtonTheme(
                                padding: EdgeInsets.symmetric(
                                    vertical: 8.0,
                                    horizontal:
                                        18.0), //adds padding inside the button
                                materialTapTargetSize: MaterialTapTargetSize
                                    .shrinkWrap, //limits the touch area to the button area
                                minWidth: 0, //wraps child's width
                                height: 0,
                                child: FlatButton(
                                  onPressed: () {
                                    saved = 1;
                                    if (this.mounted) {
                                      setState(() {});
                                    }
                                  },
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(2),
                                      side: BorderSide(
                                          color: AppColors.blueColor,
                                          width: 2)),
                                  color: AppColors.blueColor,
                                  child: Text(
                                    "Got it",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 12),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                          right: MediaQuery.of(context).size.width / (2.8 * 2),
                          top: 10,
                          child: this._triangle()),
                    ]),
                  )
                : Container(),
            (widget.feedType == FeedType.MY_POST &&
                    myPost == 0 &&
                    isFirstTime == true)
                ? Positioned(
                    right: (MediaQuery.of(context).size.width / 80),
                    child: Stack(children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          width: MediaQuery.of(context).size.width / 2.8,
                          height: 130,
                          padding: EdgeInsets.symmetric(
                              vertical: 23.0, horizontal: 10),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Column(
                            children: [
                              Text(
                                "See all your post here",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              ButtonTheme(
                                padding: EdgeInsets.symmetric(
                                    vertical: 8.0,
                                    horizontal:
                                        18.0), //adds padding inside the button
                                materialTapTargetSize: MaterialTapTargetSize
                                    .shrinkWrap, //limits the touch area to the button area
                                minWidth: 0, //wraps child's width
                                height: 0,
                                child: FlatButton(
                                  onPressed: () {
                                    myPost = 1;
                                    if (this.mounted) {
                                      setState(() {});
                                    }
                                  },
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(2),
                                      side: BorderSide(
                                          color: AppColors.blueColor,
                                          width: 2)),
                                  color: AppColors.blueColor,
                                  child: Text(
                                    "Got it",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 12),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                          right: MediaQuery.of(context).size.width / (2.8 * 2),
                          top: 10,
                          child: this._triangle()),
                    ]),
                  )
                : Container(),
            (isFirstTime == true)
                ? Positioned(
                    right: 10,
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: 0,
                      ),
                      child: Stack(children: [
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Container(
                            width: MediaQuery.of(context).size.width / 2,
                            height: 200,
                            padding: EdgeInsets.symmetric(
                                vertical: 20.0, horizontal: 5),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: FittedBox(
                              child: Column(
                                children: [
                                  Text(
                                    "This will take you to\nyour app Settings\nwhere you can edit\nyour preferences\nand more!",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  ButtonTheme(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 8.0,
                                        horizontal:
                                            18.0), //adds padding inside the button
                                    materialTapTargetSize: MaterialTapTargetSize
                                        .shrinkWrap, //limits the touch area to the button area
                                    minWidth: 0, //wraps child's width
                                    height: 0,
                                    child: FlatButton(
                                      onPressed: () {
                                        setState(() {});
                                      },
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(2),
                                          side: BorderSide(
                                              color: AppColors.blueColor,
                                              width: 2)),
                                      color: AppColors.blueColor,
                                      child: Text(
                                        "Got it",
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 10),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Positioned(right: 20, top: 10, child: this._triangle()),
                      ]),
                    ),
                  )
                : Container(),
          ])
        : InkWell(
            onTap: () {
              isImgSelected = false;
              selectedImageUrl = "";
              if (this.mounted) {
                setState(() {});
              }
            },
            child: Center(
              child: CachedNetworkImage(
                imageUrl: selectedImageUrl,
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
            ),
          );
  }

  Widget _triangle() {
    return CustomPaint(
      painter: Triangle(Colors.black),
    );
  }

// without
/*
* Container(
                color: Colors.white,
                child: Column(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.all(8),
                      child: Column(
                        children: <Widget>[
                          Container(
                            height: 50,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                ClipRRect(
                                    borderRadius: BorderRadius.circular(100.0),
                                    child: CachedNetworkImage(
                                      imageUrl:
                                          "https://i.pinimg.com/564x/19/b8/d6/19b8d6e9b13eef23ec9c746968bb88b1.jpg",
                                    )),
                                SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        "Jane Nany",
                                        style: TextStyle(
                                            color: Colors.black, fontSize: 14),
                                      ),
                                      SizedBox(
                                        height: 3,
                                      ),
                                      Text(
                                        "Today at 3:30pm",
                                        style: TextStyle(
                                            color: Colors.grey, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                                PopupMenuButton(
                                  onSelected: (i) {
                                    switch (i) {
                                      case 1:
                                        break;
                                      case 2:
                                        break;
                                    }
                                  },
                                  itemBuilder: (BuildContext context) {
                                    return <PopupMenuEntry>[
                                      PopupMenuItem(
                                        child: Text("Unmatch"),
                                        value: 1,
                                      ),
                                      PopupMenuItem(
                                        child: Text(
                                          "Report",
                                          style: TextStyle(color: Colors.red),
                                        ),
                                        value: 2,
                                      ),
                                    ];
                                  },
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            "Getting a group together to play ultimate frisbee.  Anyone wanna join?",
                            style: TextStyle(color: AppColors.blackColor),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                              width: double.infinity,
                              child: Text(
                                "10 likes 12 comments",
                                style: TextStyle(
                                    color: AppColors.blackColor,
                                    fontSize: 12),
                                textAlign: TextAlign.right,
                              )),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              this._getActionButtons(
                                  1, Icons.favorite, "Like", () {}, true),
                              this._getActionButtons(
                                  1, Icons.chat, "Comment", () {}, false),
                              this._getActionButtons(
                                  1, Icons.share, "Share", () {}, false),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

* */

// with images
/*
* Container(
                color: Colors.white,
                child: Column(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.all(8),
                      child: Column(
                        children: <Widget>[
                          Container(
                            height: 50,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                ClipRRect(
                                    borderRadius: BorderRadius.circular(100.0),
                                    child: CachedNetworkImage(
                                      imageUrl:
                                          "https://i.pinimg.com/564x/19/b8/d6/19b8d6e9b13eef23ec9c746968bb88b1.jpg",
                                    )),
                                SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        "Jane Nany",
                                        style: TextStyle(
                                            color: Colors.black, fontSize: 14),
                                      ),
                                      SizedBox(
                                        height: 3,
                                      ),
                                      Text(
                                        "Today at 3:30pm",
                                        style: TextStyle(
                                            color: Colors.grey, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                                PopupMenuButton(
                                  onSelected: (i) {
                                    switch (i) {
                                      case 1:
                                        break;
                                      case 2:
                                        break;
                                    }
                                  },
                                  itemBuilder: (BuildContext context) {
                                    return <PopupMenuEntry>[
                                      PopupMenuItem(
                                        child: Text("Unmatch"),
                                        value: 1,
                                      ),
                                      PopupMenuItem(
                                        child: Text(
                                          "Report",
                                          style: TextStyle(color: Colors.red),
                                        ),
                                        value: 2,
                                      ),
                                    ];
                                  },
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            "Getting as group together to play ultimate frisbee.  Anyone wanna join?",
                            style: TextStyle(color: AppColors.blackColor),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          CarouselSlider(
                            viewportFraction: 1.0,
                            items: imagesLink.map((i) {
                              return CachedNetworkImage(
                                imageUrl: i,
                              );
                            }).toList(),
                            onPageChanged: (i) {
                              setState(() {
                                this.carouselIndex = i;
                              });
                            },
                          ),
                          RoundIndicators(
                            circleSize: 12,
                            currentIndicatorIndex: this.carouselIndex,
                            numberOfInidcators: imagesLink.length,
                            bubbleColor: AppColors.yellowColor,
                            disableBubbleColor:
                                AppColors.greyColor,
                            borderColor: Colors.white,
                          ),
                          Container(
                              width: double.infinity,
                              child: Text(
                                "10 likes 90 comments",
                                style: TextStyle(
                                    color: AppColors.blackColor,
                                    fontSize: 12),
                                textAlign: TextAlign.right,
                              )),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              this._getActionButtons(
                                  1, Icons.favorite, "Like", () {}, true),
                              this._getActionButtons(
                                  1, Icons.chat, "Comment", () {}, false),
                              this._getActionButtons(
                                  1, Icons.share, "Share", () {}, false),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )

* */
  Container _showLoading() {
    return Container(
      height: double.infinity,
      child: Center(
        child: PlatformCircularProgressIndicator(),
      ),
    );
  }
}
