import 'dart:convert';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:amplitude_flutter/amplitude.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:pure_match/common/loading.dart';
import 'package:pure_match/common/profile.dart';
import 'package:pure_match/models/my_friends.dart';
import 'package:pure_match/models/post.dart';
import 'package:pure_match/models/user.dart';
import 'package:pure_match/pages/feed/feed_detail.dart';
import 'package:pure_match/common/constants.dart';
import 'package:pure_match/pages/feed/create_feed.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pure_match/pages/feed/share_feed.dart';
import 'dart:io' show Platform;
import '../AppColors.dart';
import '../MyHttp.dart';

class CommunityProfile extends StatefulWidget {
  int userId;
  bool isFriendSuggestion;
  bool isMatchSuggestion;

  CommunityProfile({userId, bool isFriendSuggestion, bool isMatchSuggestion}) {
    this.userId = userId;
    this.isFriendSuggestion = isFriendSuggestion ?? false;
    this.isMatchSuggestion = isMatchSuggestion ?? false;
  }
  @override
  _CommunityProfileState createState() => _CommunityProfileState();
}

class _CommunityProfileState extends State<CommunityProfile> {
  int userId;
  String error;
  List<Post> posts = [];
  User u;
  Profile profile;
  bool request = false;
  bool isfriend = false;
  MyFriends frd;
  List<MyFriends> _mutualFriends = [];
  bool _loading = false;

  // Analytics code
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';

  void _loadingToggle({bool state}) {
    if (state == null) {
      state = !this._loading;
    }
    if (this.mounted) {
      setState(() {
        _loading = state;
      });
    }
  }

  @override
  void initState() {
    print("reached community");
    userId = widget.userId;
    profile = new Profile(
      userId: 20,
      isEditable: false,
      themeColor: AppColors.yellowColor,
    );
    super.initState();

    //Analytics tracking code
    amplitudeAnalytics.init(apiKey);
    analytics.setCurrentScreen(
        screenName: "community_profile",
        screenClassOverride: "community_profile");
    amplitudeAnalytics.logEvent('community_profile_page');

    _makeApiCalls();
  }

  void _makeApiCalls() async {
    this._loadingToggle();
    await _getCommunityProfile();
    await _checkfriendRequest();
    await _checkfriend();
    this._loadingToggle();
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
        backgroundColor: AppColors.redColor,
        title: Text(u?.first_name ?? "ok",
            style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.white,
                fontSize: 24)),
        automaticallyImplyLeading: false,
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

  void _checkfriendRequest() async {
    var res = await MyHttp.get("/friends/request-status/${userId}");
    if (res.statusCode == 200) {
      request = true;
      if (this.mounted) {
        setState(() {});
      }
    } else {
      print("Friend Request not sent");
    }
  }

  void _checkfriend() async {
    var res = await MyHttp.get("/matches/check-friend/${userId}");
    if (res.statusCode == 200) {
      isfriend = json.decode(res.body);
      print("****");
      print(isfriend);
      if (this.mounted) {
        setState(() {});
      }
    } else {
      print("not a friend");
    }
  }

  void _getCommunityProfile() async {
    print(userId);

    var res = await MyHttp.get("friends/profile/${userId}");
    var body = json.decode(res.body);
    print("BODY*********");
    print(body);
    if (res.statusCode == 200) {
      //Analytics code
      analytics.logEvent(
          name: 'viewed_community_profile',
          parameters: <String, dynamic>{'user_id': userId});
      amplitudeAnalytics.logEvent('viewed_community_profile',
          eventProperties: {'user_id': userId});

      var user = body['user'] ??
          body["User"] ??
          body["Author"] ??
          body["restrictedUser"];
      if (user != null) {
        print(user);
        print(user["Posts"]);
        var friend = body["mutualFriends"];
        for (var p in friend) {
          frd = MyFriends.fromJson(p);
          // _friends.add(friend);
          _mutualFriends.add(frd);
        }
        print("User Community Profile $user");
        this.u = User.fromJson(user);

        var sp = await SharedPreferences.getInstance();
        int userId = sp.getInt("id");
        if (user['Posts'] != null) {
          posts = List<Post>.from(
              user['Posts']?.map((i) => Post.fromJson(i, userId)));
          print("&&&&&&&&&&&&");
          print(posts);
          print(posts.length);
        }
        if (this.mounted) {
          setState(() {});
        }
      } else {
        if (this.mounted) {
          setState(() {
            error = "User not found with id $userId";
          });
        }
      }
    } else {
      print("User update error: ${res.statusCode}");
      print("User update error: ${res.body}");
      if (this.mounted) {
        setState(() {
          error = body["message"];
        });
      }
    }
  }

  void _showModalBottomSheet(BuildContext context, User userDisplayed) {
    List<Widget> actions = [];
    if (isfriend == true) {
      actions.add(ListTile(
        title: Text("Suggest as Friend",
            style:
                TextStyle(color: AppColors.communityProfileOptionsBlueColor)),
        onTap: () {
          Navigator.pop(context, profileOptions.suggestFriend);
          // Analytics tracking code
          analytics.logEvent(
              name: "suggested_as_friend",
              parameters: <String, dynamic>{
                'user': userId,
                "suggested_id": userDisplayed.friend_match_id
              });
          amplitudeAnalytics.logEvent('suggested_as_friend', eventProperties: {
            'user': userId,
            "suggested_id": userDisplayed.friend_match_id
          }); // to change
        },
      ));
      actions.add(ListTile(
        title: Text("Suggest as Match",
            style:
                TextStyle(color: AppColors.communityProfileOptionsBlueColor)),
        onTap: () {
          Navigator.pop(context, profileOptions.suggestMatch);
          // Analytics tracking code
          analytics.logEvent(
              name: "suggested_as_match",
              parameters: <String, dynamic>{
                'user': userId,
                "suggested_id": userDisplayed.friend_match_id
              });
        },
      ));
      actions.add(ListTile(
        title: Text("Unfriend",
            style: TextStyle(color: AppColors.communityProfileOptionsRedColor)),
        onTap: () {
          Navigator.pop(context, profileOptions.unfriend);
          // Analytics tracking code
          analytics.logEvent(name: "unfriend", parameters: <String, dynamic>{
            'user': userId,
            "suggested_id": userDisplayed.friend_match_id
          });
          amplitudeAnalytics.logEvent('unfriend', eventProperties: {
            'user': userId,
            "suggested_id": userDisplayed.friend_match_id
          });
        },
      ));
      actions.add(ListTile(
        title: Text("Report",
            style: TextStyle(color: AppColors.communityProfileOptionsRedColor)),
        onTap: () {
          Navigator.pop(context, profileOptions.report);
        },
      ));
    } else if (request == true && isfriend == false) {
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
          Navigator.pop(context, profileOptions.suggestFriend);
          // // Analytics tracking code
          // analytics.logEvent(
          //     name: "suggested_as_friend",
          //     parameters: <String, dynamic>{
          //       'user': userId,
          //       "suggested_id": userDisplayed.friend_match_id
          //     }); //
          // amplitudeAnalytics.logEvent('suggested_as_friend', eventProperties: {
          //   'user': userId,
          //   "suggested_id": userDisplayed.friend_match_id
          // });

          // to change
        },
      ));
      actions.add(ListTile(
        title: Text("Report",
            style: TextStyle(color: AppColors.communityProfileOptionsRedColor)),
        onTap: () {
          Navigator.pop(context, profileOptions.report);
        },
      ));
    } else if (isfriend == false) {
      actions.add(ListTile(
        title: Text("Send Friend Request",
            style:
                TextStyle(color: AppColors.communityProfileOptionsBlueColor)),
        onTap: () {
          Navigator.pop(context, profileOptions.sendFriendRequest);

          // // Analytics tracking code
          // analytics.logEvent(
          //     name: "sent_friend_request",
          //     parameters: <String, dynamic>{
          //       'user': userId,
          //       "suggested_id": userDisplayed.friend_match_id
          //     });
          // amplitudeAnalytics.logEvent('sent_friend_request', eventProperties: {
          //   'user': userId,
          //   "suggested_id": userDisplayed.friend_match_id
          // });

          request == true;
          setState(() {});
        },
      ));
      actions.add(ListTile(
        title: Text("Suggest as Friend",
            style:
                TextStyle(color: AppColors.communityProfileOptionsBlueColor)),
        onTap: () {
          Navigator.pop(context, profileOptions.unfriend); // to change
          // Analytics tracking code
          analytics.logEvent(
              name: "suggested_as_friend",
              parameters: <String, dynamic>{
                'user': userId,
                "suggested_id": userDisplayed.friend_match_id
              });
          amplitudeAnalytics.logEvent('suggested_as_friend', eventProperties: {
            'user': userId,
            "suggested_id": userDisplayed.friend_match_id
          });
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
    print("community_profil _showModalBottomSheet ${userDisplayed.id}");
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
            //Analytics tracking code
            analytics.logEvent(
                name: "suggested_as_friend",
                parameters: <String, dynamic>{
                  'user': userId,
                  "suggested_id": userDisPlayed.friend_match_id
                });
            amplitudeAnalytics.logEvent('suggested_as_friend',
                eventProperties: {
                  'user': userId,
                  "suggested_id": userDisPlayed.friend_match_id
                });
          }));
      actionSheetActions.add(CupertinoActionSheetAction(
        child: Text("Suggest as Match",
            style:
                TextStyle(color: AppColors.communityProfileOptionsBlueColor)),
        onPressed: () {
          Navigator.pop(context, profileOptions.suggestMatch);
          // Analytics tracking code
          analytics.logEvent(
              name: "suggested_as_match",
              parameters: <String, dynamic>{
                'user': userId,
                "suggested_id": userDisPlayed.friend_match_id
              });
          amplitudeAnalytics.logEvent('suggested_as_match', eventProperties: {
            'user': userId,
            "suggested_id": userDisPlayed.friend_match_id
          });
        },
      ));
      actionSheetActions.add(CupertinoActionSheetAction(
        child: Text("Unfriend",
            style: TextStyle(color: AppColors.communityProfileOptionsRedColor)),
        onPressed: () {
          Navigator.pop(context, profileOptions.unfriend);
          // Analytics tracking code
          analytics.logEvent(name: "unfriend", parameters: <String, dynamic>{
            'user': userId,
            "suggested_id": userDisPlayed.friend_match_id
          });
          amplitudeAnalytics.logEvent('unfriend', eventProperties: {
            'user': userId,
            "suggested_id": userDisPlayed.friend_match_id
          });
        },
      ));
      actionSheetActions.add(CupertinoActionSheetAction(
        child: Text("Report",
            style: TextStyle(color: AppColors.communityProfileOptionsRedColor)),
        onPressed: () {
          Navigator.pop(context, profileOptions.report);
        },
      ));
    } else if (isfriend == false && request == true) {
      actionSheetActions.add(CupertinoActionSheetAction(
        child: Text("Friend Request Sent",
            style: TextStyle(color: Color.fromRGBO(153, 153, 153, 1))),
        onPressed: () {
          Navigator.pop(context);
          // Analytics tracking code
          // analytics.logEvent(
          //     name: "sent_friend_Request",
          //     parameters: <String, dynamic>{
          //       'user': userId,
          //       "suggested_id": userDisPlayed.friend_match_id
          //     });
          // amplitudeAnalytics.logEvent('sent_friend_Request', eventProperties: {
          //   'user': userId,
          //   "suggested_id": userDisPlayed.friend_match_id
          // });
        },
      ));
      actionSheetActions.add(CupertinoActionSheetAction(
          child: Text("Suggest as Friend",
              style:
                  TextStyle(color: AppColors.communityProfileOptionsBlueColor)),
          onPressed: () {
            Navigator.pop(context, profileOptions.suggestFriend);
            // Analytics tracking code
            analytics.logEvent(
                name: "suggested_as_friend",
                parameters: <String, dynamic>{
                  'user': userId,
                  "suggested_id": userDisPlayed.friend_match_id
                });
            amplitudeAnalytics.logEvent('suggested_as_friend',
                eventProperties: {
                  'user': userId,
                  "suggested_id": userDisPlayed.friend_match_id
                });
          }));
      actionSheetActions.add(CupertinoActionSheetAction(
        child: Text("Report",
            style: TextStyle(color: AppColors.communityProfileOptionsRedColor)),
        onPressed: () {
          Navigator.pop(context, profileOptions.report);
        },
      ));
    } else if (isfriend == false) {
      actionSheetActions.add(CupertinoActionSheetAction(
        child: Text("Send friend Request",
            style:
                TextStyle(color: AppColors.communityProfileOptionsBlueColor)),
        onPressed: () {
          Navigator.pop(context, profileOptions.sendFriendRequest);

          request = true;
          setState(() {});
        },
      ));
      actionSheetActions.add(CupertinoActionSheetAction(
          child: Text("Suggest as Friend",
              style:
                  TextStyle(color: AppColors.communityProfileOptionsBlueColor)),
          onPressed: () {
            Navigator.pop(context, profileOptions.suggestFriend);
            // Analytics tracking code
            analytics.logEvent(
                name: "suggested_as_friend",
                parameters: <String, dynamic>{
                  'user': userId,
                  "suggested_id": userDisPlayed.friend_match_id
                });
            amplitudeAnalytics.logEvent('suggested_as_friend',
                eventProperties: {
                  'user': userId,
                  "suggested_id": userDisPlayed.friend_match_id
                });
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

  void _likePost(int id) async {
    print("Id is $id");
    try {
      var data = {};
      var res = await MyHttp.post("/posts/like/post/$id", data);
      // Analytics tracking code
      var jsonData = jsonDecode(res.body);
      analytics.logEvent(name: 'liked_post', parameters: <String, dynamic>{
        "user_id": this.userId,
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
    print("unlike kra");
    try {
      var res = await MyHttp.delete("/posts/like/post/$id");

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

      print("Post unliked done");
      // print(res.statusCode);

      // print(res.body);
    } catch (e) {
      print("UnLike error");
      print(e);
    }
  }

  List<Widget> postWidget = [];
  double scroll_p = 0;
  bool isImgSelected = false;
  String selectedImageUrl = "";
  ScrollController _sc = new ScrollController();
  void savePosition() {
    scroll_p = _sc.offset;
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

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance
        .addPostFrameCallback((_) => goToSavedPosition(context));
    postWidget.removeRange(0, postWidget.length);
    postWidget
        .addAll(this.posts.map((p) => this._getPost(context, p)).toList());
    return PlatformScaffold(
      backgroundColor: Colors.white,
      appBar: PlatformAppBar(
        backgroundColor: AppColors.yellowColor,
        title: Text(u?.first_name ?? "Profile",
            style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.white,
                fontSize: 24)),
        trailingActions: <Widget>[
          PlatformIconButton(
            icon: Image.asset("assets/images/profile_options.png"),
            onPressed: () {
              //Show the action sheet and bottom navigation dialog for android
              if (u != null) {
                if (Platform.isAndroid) {
                  _showModalBottomSheet(context, u);
                } else if (Platform.isIOS) {
                  _showModalActionSheet(context, u);
                }
              } else {
                setState(() {
                  error =
                      "You cannot open options before the profile is loaded";
                });
              }
            },
          ),
        ],
        cupertino: (_, __) =>
            CupertinoNavigationBarData(brightness: Brightness.dark),
      ),
      body: Scaffold(
        body: SafeArea(
          child: (isImgSelected)
              ? InkWell(
                  onTap: () {
                    isImgSelected = false;
                    selectedImageUrl = "";
                    setState(() {});
                  },
                  child: Center(
                    child: CachedNetworkImage(
                      imageUrl: selectedImageUrl,
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                  ),
                )
              : (this._loading)
                  ? Loading.showLoading()
                  : (u == null)
                      ? Center(
                          child: Text(error ?? "Something went wrong.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w500)))
                      : SingleChildScrollView(
                          controller: _sc,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              profile.getProfilePlain(u, context),
                              SizedBox(
                                height: 10,
                              ),
                              (posts != null && posts.length > 0)
                                  ? Text("Feed Activity",
                                      style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w600))
                                  : Container(),
                              (posts != null && posts.length > 0)
                                  ? Column(
                                      children: this.postWidget,
                                    )
                                  : Center(
                                      child: Text(
                                        "No recent activity",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            fontSize: 24),
                                      ),
                                    ),
                            ],
                          ),
                        ),
        ),
      ),
    );
  }

  Container _getPost(BuildContext context, Post p) {
    return CreateFeed.createPost(context, p, () {
      showCupertinoModalPopup(
          context: context,
          builder: (BuildContext context) {
            return CupertinoActionSheet(
              actions: <Widget>[
//                                             CupertinoActionSheetAction(
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
    }, () {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => FeedDetail(
                    postId: p.id,
                  ))).then((v) {
        this._getCommunityProfile();
      });
    }, (i) {
      setState(() {
        p.carouselIndex = i;
      });
    }, () async {
      List<Widget> likeDialogContent = [];
      print(p.likedByUsers);
      for (var u in p.likedByUsers) {
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
    }, () {
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
      savePosition();
      setState(() {});
    }, false);
  }
}
