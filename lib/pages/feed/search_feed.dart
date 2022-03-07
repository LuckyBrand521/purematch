import 'dart:convert';
import 'dart:io' show Platform;
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pure_match/common/MyButtons.dart';
import 'package:pure_match/common/RoundIndicators.dart';
import 'package:pure_match/common/global.dart';
import 'package:pure_match/models/post.dart';
import 'package:pure_match/models/search_feed_data.dart';
import 'package:pure_match/models/user.dart';
import 'package:amplitude_flutter/amplitude.dart';
import 'package:pure_match/pages/AppColors.dart';
import 'package:pure_match/pages/MyHttp.dart';
import 'package:pure_match/pages/community_profile/community_profile.dart';
import 'package:pure_match/pages/feed/feed_detail.dart';
import 'package:pure_match/pages/feed/share_feed.dart';

class SearchFeed extends StatefulWidget {
  @override
  _SearchFeedState createState() => _SearchFeedState();
}
//
//class SearchData {
//  String term;
//
//  SearchData({this.term});
//}
//
//class SearchUser extends User {
//  int mutualConnections;
//  SearchUser(String name, String imageUrl, int mutualConnections)
//      : super(name, imageUrl) {
//    this.mutualConnections = mutualConnections;
//  }
//}

class _SearchFeedState extends State<SearchFeed> {
  // Analytics code
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';

  int usersCount = 0;
  int postsCount = 0;
  int searchHistory = 0;

  List<Widget> _toShow = [];

  String _searchText = "";

  InkWell _getLikeOption(User u) {
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CommunityProfile(
                      userId: u.id,
                    )));
      },
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
                              userId: u.id,
                            )));
              },
            ))
          ],
        ),
      ),
    );
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

  void _likePost(int id) async {
    print("Id is $id");
    try {
      var data = {};
      var res = await MyHttp.post("/posts/like/post/$id", data);
      //Analytics tracking code
      // Analytics tracking code
      var jsonData = jsonDecode(res.body);
      analytics.logEvent(name: 'liked_post', parameters: <String, dynamic>{
        "user_id": jsonData["notif"]["UserId"],
        'post_user_id': jsonData["notif"]["recipientId"],
        'post_id': id
      });
      amplitudeAnalytics.logEvent('liked_post', eventProperties: {
        "user_id": jsonData["notif"]["UserId"],
        'post_user_id': jsonData["notif"]["recipientId"],
        'post_id': id
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
    try {
      var res = await MyHttp.delete("/posts/like/post/$id");
      //Analytics code
      // Analytics tracking code
      var jsonData = jsonDecode(res.body);
      analytics.logEvent(name: 'liked_post', parameters: <String, dynamic>{
        "user_id": jsonData["notif"]["UserId"],
        'post_user_id': jsonData["notif"]["recipientId"],
        'post_id': id
      });
      amplitudeAnalytics.logEvent('liked_post', eventProperties: {
        "user_id": jsonData["notif"]["UserId"],
        'post_user_id': jsonData["notif"]["recipientId"],
        'post_id': id
      });

      print("Post unliked");
      print(res.statusCode);
      print(res.body);
    } catch (e) {
      print("Like error");
      print(e);
    }
  }

  _openIosOptions() {
    return showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) {
          return CupertinoActionSheet(
            actions: <Widget>[
//                                              CupertinoActionSheetAction(
//                                                child: Text("Unmatch"),
//                                                onPressed: () {},
//                                              ),
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

  void _getSearchData() async {
    try {
      var data = {"term": this._searchText};
      var res = await MyHttp.post("/posts/search", data);
      print(res.statusCode);
      print(res.body);
      if (res.statusCode == 200) {
        if (this._toShow.length != 0) {
          this._toShow.clear();
        }
        var body = json.decode(res.body);
        var users = body["users"] as List<dynamic>;
        // Analytics code
        analytics.logEvent(
            name: "searched_feeds",
            parameters: <String, dynamic>{
              "term": this._searchText.toLowerCase().toString()
            });

        amplitudeAnalytics.logEvent("searched_feeds", eventProperties: {
          "term": this._searchText.toLowerCase().toString()
        });

        if (users != null && users.length > 0) {
          for (int i = 0; i < users.length; i++) {
            if (i == 0 && usersCount == 0) {
              var heading = this._getHeading("People");
              this._toShow.add(heading);
            }
            usersCount++;

            var user = users[i];
            var userContainer = Container(
              color: Colors.white,
              height: 70,
              padding: EdgeInsets.all(10),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CommunityProfile(
                                userId: user["id"],
                              )));
                },
                child: Row(
                  children: <Widget>[
                    (user["ProfilePictureId"] != null &&
                            user["ProfilePictureId"].isNotEmpty &&
                            user["ProfilePictureId"] != "na")
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(100.0),
                            child: CachedNetworkImage(
                              imageUrl: user["ProfilePictureId"] ??
                                  "https://i.pinimg.com/564x/19/b8/d6/19b8d6e9b13eef23ec9c746968bb88b1.jpg",
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error),
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            ))
                        : Icon(Icons.person, size: 50),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                        child: Text(
                      Global.getFullName(user["first_name"], user["last_name"]),
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ))
                  ],
                ),
              ),
            );
            print("90");
            print(this._toShow.length);
            this._toShow.add(userContainer);
            print(this._toShow.length);
            setState(() {});
          }
        }
        var posts = body["posts"] as List<dynamic>;
        if (posts != null && posts.length > 0) {
          for (int i = 0; i < posts.length; i++) {
            print("Posts");
            if (i == 0 && postsCount == 0) {
              var heading = this._getHeading("Posts");
              this._toShow.add(heading);
            }
            postsCount++;
            var p = posts[i];
            int id = p["id"];
            String text = p["text"];
            String createdAt = p["createdAt"];
            var user = p["User"] ?? p["Author"];
            User u = User.fromJson(user);
            List<dynamic> imagesData = p["PostUploads"];
            List<String> images = [];
            if (imagesData != null && imagesData.length > 0) {
              for (var img in imagesData) {
                String path = img["path"];
                images.add(path);
              }
            }
            List<dynamic> likes = p["Likes"];
            bool liked = false;
            int numberOfLikes = 0;
            List<User> likedByUsers = [];
            if (likes != null && likes.length > 0) {
              liked = true;
              numberOfLikes = likes.length;
              for (var l in likes) {
                var lu = l["User"];
                var lUser = User.fromJson(lu);
                likedByUsers.add(lUser);
              }
            }
            List<dynamic> comments = p["Comments"];
            int commentsCount = 0;
            if (comments != null && comments.length > 0) {
              commentsCount = comments.length;
            }
            Post post = Post(id, text, false, u, images, liked, createdAt,
                numberOfLikes: numberOfLikes,
                numberOfComments: commentsCount,
                likedByUsers: likedByUsers);
            var pp = Container(
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
                              ClipRRect(
                                  borderRadius: BorderRadius.circular(100.0),
                                  child: CachedNetworkImage(
                                    imageUrl: post?.user?.imageUrl ??
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
                                      post?.user?.fullName ?? "Jane Nany",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(
                                      height: 3,
                                    ),
                                    Text(
                                      post?.createdAt ?? "Today at 3:30pm",
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              (Platform.isAndroid)
                                  ? PopupMenuButton(
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
//                                                PopupMenuItem(
//                                                  child: Text("Save"),
//                                                  value: 1,
//                                                ),
                                          PopupMenuItem(
                                            child: Text(
                                              "Report",
                                              style:
                                                  TextStyle(color: Colors.red),
                                            ),
                                            value: 2,
                                          ),
                                        ];
                                      },
                                    )
                                  : IconButton(
                                      onPressed: () {
                                        this._openIosOptions();
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
                                          postId: post.id,
                                        ))).then((v) {});
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.only(left: 10),
                                child: Text(
                                  post?.text ??
                                      "Getting as group together to play ultimate frisbee.  Anyone wanna join?",
                                  style: TextStyle(color: AppColors.blackColor),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              ((post?.images ?? []).length > 0)
                                  ? CarouselSlider(
                                      options: CarouselOptions(
                                        viewportFraction: 1.0,
                                        onPageChanged: (i, pageChangedReason) {
                                          setState(() {
                                            post.carouselIndex = i;
                                          });
                                        },
                                      ),
                                      items: post.images.map((i) {
                                        return CachedNetworkImage(
                                          imageUrl: i,
                                          errorWidget: (context, url, error) =>
                                              Icon(Icons.error),
                                        );
                                      }).toList(),
                                    )
                                  : Container(),
                              ((post?.images ?? []).length > 0)
                                  ? RoundIndicators(
                                      circleSize: 12,
                                      currentIndicatorIndex: post.carouselIndex,
                                      numberOfInidcators:
                                          (post?.images ?? []).length,
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
                            openDialog(post?.likedByUsers);
                          },
                          child: Container(
                              width: double.infinity,
                              child: Text(
                                "${post?.numberOfLikes} likes ${post?.numberOfComments} comments",
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
                                if (post.liked)
                                  post.numberOfLikes--;
                                else
                                  post.numberOfLikes++;
                                post.liked = !post.liked;
                              });
                              if (post.liked)
                                this._likePost(post.id);
                              else
                                this._unlikePost(post.id);
                            }, post.liked),
                            MyButtons.getActionButtons(
                                1, 1, "Comment", () {}, false),
                            MyButtons.getActionButtons(1, 2, "Share", () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ShareFeed(
                                            postId: post?.id,
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
            print("ASASAS");
            setState(() {
              this._toShow.add(pp);
            });
          }
        }
        setState(() {});
      }
    } catch (e) {
      print("Search data errro: $e");
    }
  }

  void _getSearchHistory() async {
    try {
      var res = await MyHttp.get("/posts/search-history");
      print(res.statusCode);
      print(res.body);
      if (res.statusCode == 200) {
        var body = json.decode(res.body);
        var terms = body["terms"] as List<dynamic>;
        if (terms != null && terms.length > 0) {
          for (var term in terms) {
            var sd = SearchFeedData(term: term);
            var c = Container(
              color: Colors.white,
              width: double.infinity,
              padding: EdgeInsets.all(16),
              child: Container(
                child: InkWell(
                  onTap: () {
                    _searchText = sd.term;
                    this._getSearchData();
                  },
                  child: Text(
                    sd.term,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            );
            searchHistory++;
            this._toShow.add(c);
          }
        }
        setState(() {});
      }
    } catch (e) {
      print("Err: $e");
    }
  }

  Container _getHeading(String s) {
    return Container(
      padding: EdgeInsets.all(10),
      child: Text(
        s,
        style: TextStyle(
            color: Colors.black, fontSize: 30, fontWeight: FontWeight.w500),
      ),
    );
  }

  @override
  void initState() {
    this._getSearchHistory();
    super.initState();
    // Analytics tracking code
    amplitudeAnalytics.init(apiKey);
    analytics.setCurrentScreen(
        screenName: 'search_feed', screenClassOverride: 'search_feed');
    amplitudeAnalytics.logEvent("search_feed_page");
  }

  @override
  Widget build(BuildContext context) {
    var aa = OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.noButtonColor, width: 32.0),
        borderRadius: BorderRadius.circular(25.0));
    return Scaffold(
      backgroundColor: AppColors.greyColor,
      appBar: AppBar(
        backgroundColor: AppColors.yellowColor,
        automaticallyImplyLeading: false,
        title: Container(
          height: 35,
          child: TextField(
              textCapitalization: TextCapitalization.words,
              cursorColor: Colors.white,
              onSubmitted: (s) {
                if (s.trim().isNotEmpty) {
                  this._searchText = s.trim();
                  this._getSearchData();
                }
              },
              style: TextStyle(
                fontSize: 14.0,
                color: Colors.white,
              ),
              decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(0.0),
                  fillColor: Colors.grey,
                  filled: true,
                  focusColor: Colors.grey,
                  prefixIcon: Icon(
                    Icons.search,
                    size: 20,
                    color: Colors.white,
                  ),
                  hintText: "Search Community...",
                  hintStyle: TextStyle(color: Colors.white),
                  border: aa,
                  focusedBorder: aa,
                  enabledBorder: aa,
                  disabledBorder: aa)),
        ),
        actions: <Widget>[
          FlatButton(
            padding: EdgeInsets.all(0),
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              "Cancel",
              style: TextStyle(color: Colors.white),
            ),
          )
        ],
      ),
      body: Container(
        child: (this._toShow.length == 0)
            ? Container(
                height: 100,
                child: Center(
                    child: Text(
                  "No Recent Searches",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                )),
              )
            : Container(
                child: ListView.builder(
                  itemCount: this._toShow.length,
                  itemBuilder: (c, i) {
                    return this._toShow[i];
                  },
                ),
              ),
      ),
    );
  }
}
