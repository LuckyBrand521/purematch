import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:amplitude_flutter/amplitude.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:pure_match/common/MyButtons.dart';
import 'package:pure_match/common/RoundIndicators.dart';
import 'package:pure_match/common/global.dart';
import 'package:pure_match/models/post.dart';
import 'package:pure_match/models/user.dart';
import 'package:pure_match/pages/MyHttp.dart';
import 'package:pure_match/pages/community_profile/community_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../AppColors.dart';
import 'announcements.dart';

class FeedDetail extends StatefulWidget {
  final int postId;

  const FeedDetail({Key key, @required this.postId}) : super(key: key);
  @override
  _FeedDetailState createState() => _FeedDetailState();
}

class Comment {
  int id;
  User user;
  int userid;
  String text;
  String _createdAt;
  int likes;
  bool liked;
  bool replyTextOn = false;
  List<Comment> replies;

  Comment(this.id, this.user, this.userid, this.text, this._createdAt,
      this.likes, this.liked, this.replies);

  String get createdAt {
    String time = "NA";
    time = Global.createdAt(this._createdAt);
    return time;
  }
}

class _FeedDetailState extends State<FeedDetail> {
  // Analytics code
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';

  User _user;
  String _newComment = "";
  Post _post;
  List<Comment> comments = [];
  List<Widget> likeDialogContent = [];
  TextEditingController _ctrl = TextEditingController();
  String selectedImageUrl = "";
  bool isImgSelected = false;
  void _getFeed(int postId) async {
    try {
      var res = await MyHttp.get("/posts/post/$postId");
      if (res.statusCode == 200) {
        print("Success2");
        print(res.body);
        this._setComment(res.body);
      }
    } catch (e) {
      print("Err $e");
    }
  }

  Future<void> _setComment(String bodyS, {bool isreply}) async {
    try {
      var body = json.decode(bodyS);
      var p = body["post"];
      int id = p["id"];
      String text = p["text"];
      String createdAt = p["createdAt"];
      bool announcement;
      if (p["announcement"] != null) {
        announcement = p["announcement"];
      } else {
        announcement = false;
      }
      var user = p["User"] ?? p["Author"];
      User user_post = _user;
      print("Userrrr");
      print(user);
      if (user != null && user["first_name"] != null) {
        user_post = User.fromJson(user);
      }
      List<dynamic> imagesData = p["PostUploads"];
      List<String> images = [];
      if (imagesData != null && imagesData.length > 0) {
        for (var img in imagesData) {
          String path = img["path"];
          images.add(path);
        }
      }
      List<dynamic> likes = p["LikeActions"];
      bool liked = false;
      User u;
      int numberOfLikes = 0;
      if (likes != null && likes.length > 0) {
        // liked = true;
        numberOfLikes = likes.length;
        for (var l in likes) {
          var lu = l["User"];
          var lUser = User.fromJson(lu);
          var sp = await SharedPreferences.getInstance();
          int id = sp.getInt("id");
          if (id == lUser.id) {
            liked = true;
          }
          this.likeDialogContent.add(_getLikeOption(lUser));
        }
      }
      int commentsCount = 0;
      List<dynamic> commentsData = p["Comments"];
      this.comments.clear();
      for (var c in commentsData) {
        print("#####");
        print(c);
        commentsCount++;
        int cid = c["id"];
        int cuserid = c["UserId"];
        String text = c["text"];
        var user = c["User"] ?? c["Author"];
        if (user != null && user["first_name"] != null) {
          u = User.fromJson(user);
        }
        String commentCreateAt = c["createdAt"];

        List<dynamic> clikes = c["LikeActions"];
        bool cliked = false;
        int cnumberOfLikes = 0;
        if (clikes != null && clikes.length > 0) {
          cliked = true;
          cnumberOfLikes = clikes.length;
        }

        var reply = c["reply"] as List<dynamic>;
        List<Comment> replies = [];
        if (reply != null && reply.length > 0) {
          for (var r in reply) {
            int rcid = r["id"];
            int ruserid = r["UserId"];
            String rtext = r["text"];
            String rCreatedAt = r["createdAt"];
            var ru = r["User"];
            User rUser = User.fromJson(ru);
            List<dynamic> rlikes = r["Likes"];
            bool rliked = false;
            int rnumberOfLikes = 0;
            if (rlikes != null && rlikes.length > 0) {
              rliked = true;
              rnumberOfLikes = rlikes.length;
            }
            replies.add(Comment(rcid, rUser, ruserid, rtext, rCreatedAt,
                rnumberOfLikes, rliked, null));
          }
        }
        comments.add(Comment(cid, u, cuserid, text, commentCreateAt,
            cnumberOfLikes, cliked, replies));
      }
      setState(() {
        this._post = Post(
            id, text, announcement, user_post, images, liked, createdAt,
            numberOfLikes: numberOfLikes, numberOfComments: commentsCount);
      });
    } catch (e) {
      print("_setComment err: $e");
    }
  }

  void _getUser() async {
    try {
      this._user = await MyHttp.getUserDetails();
    } catch (e) {
      print("Err $e");
    }
  }

  List<Widget> _renderComments() {
    List<Widget> w = comments.map((c) {
      return _getComment(c);
    }).toList();
    return w;
  }

  void _sendComment() async {
    try {
      var data = {"text": this._newComment};
      var res = await MyHttp.post("/posts/comment/${widget.postId}", data);
      print("Comment added");
      print(res.statusCode);
      print(res.body);
      this._getFeed(widget.postId);

      //Analytics tracking code
      var jsonData = jsonDecode(res.body);
      analytics
          .logEvent(name: "commented_on_post", parameters: <String, dynamic>{
        'user_id': this._user.id,
        'post_user_id': jsonData["notif"]["recipientId"],
        'post_id': widget.postId
      });
      amplitudeAnalytics.logEvent("commented_on_post", eventProperties: {
        'user_id': this._user.id,
        'post_id': widget.postId
      });
    } catch (e) {
      print("Comment Error: $e");
    }
  }

  void _likePost(int id) async {
    print("Id is $id");
    try {
      var data = {};
      var res = await MyHttp.post("/posts/like/post/$id", data);
      //Analytics tracking code
      var jsonData = jsonDecode(res.body);
      analytics.logEvent(name: "liked_post", parameters: <String, dynamic>{
        'user_id': this._user.id,
        'post_user_id': jsonData["notif"]["recipientId"],
        'post_id': widget.postId,
      });
      amplitudeAnalytics.logEvent("liked_post", eventProperties: {
        'user_id': this._user.id,
        'post_user_id': jsonData["notif"]["recipientId"],
        'post_id': widget.postId,
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
      //Analytics tracking code
      var jsonData = jsonDecode(res.body);
      analytics.logEvent(name: "unliked_post", parameters: <String, dynamic>{
        'user_id': this._user.id,
        'post_user_id': jsonData["notif"]["recipientId"],
        'post_id': widget.postId
      });
      amplitudeAnalytics.logEvent("unliked_post", eventProperties: {
        'user_id': this._user.id,
        'post_user_id': jsonData["notif"]["recipientId"],
        'post_id': widget.postId
      });

      print("Post unliked");
      print(res.statusCode);
      print(res.body);
    } catch (e) {
      print("Like error");
      print(e);
    }
  }

  void _likeComment(int id) async {
    print("Id is $id");
    try {
      var data = {};
      var res = await MyHttp.post("/posts/like/comment/$id", data);
      //Analytics tracking code
      // var jsonData = jsonDecode(res.body);
      analytics.logEvent(name: "liked_comment", parameters: <String, dynamic>{
        'user_id': this._user.id,
        'post_id': widget.postId,
        "number_of_likes": _post.numberOfLikes,
        "number_of_comments": _post.numberOfComments
      });
      amplitudeAnalytics.logEvent("liked_comment", eventProperties: {
        'user_id': this._user.id,
        'post_id': widget.postId,
        "number_of_likes": _post.numberOfLikes,
        "number_of_comments": _post.numberOfComments
      });

      print("Like Comment");
      print(res.statusCode);
      print(res.body);
    } catch (e) {
      print("Like Comment");
      print(e);
    }
  }

  void _unlikeComment(int id) async {
    print("Id is $id");
    try {
      var res = await MyHttp.delete("/posts/like/comment/$id");
      //Analytics tracking code
      analytics.logEvent(name: "unliked_comment", parameters: <String, dynamic>{
        'user_id': this._user.id,
        'post_id': widget.postId,
        "number_of_likes": _post.numberOfLikes,
        "number_of_comments": _post.numberOfComments
      });
      amplitudeAnalytics.logEvent("unliked_comment", eventProperties: {
        'user_id': this._user.id,
        'post_id': widget.postId,
        "number_of_likes": _post.numberOfLikes,
        "number_of_comments": _post.numberOfComments
      });

      print("Comment Unlike");
      print(res.statusCode);
      print(res.body);
    } catch (e) {
      print("UnLike Comment");
      print(e);
    }
  }

  @override
  void initState() {
    this._getUser();
    this._getFeed(widget.postId);

    super.initState();
    //Analytics tracking code
    amplitudeAnalytics.init(apiKey);
    analytics.setCurrentScreen(
        screenName: "feed_details", screenClassOverride: "feed_details");
    amplitudeAnalytics.logEvent("feed_details_page");
  }

  var aa = OutlineInputBorder(
      borderSide: BorderSide(color: Colors.grey[400], width: 1.0),
      borderRadius: BorderRadius.circular(25.0));

  // Dialog to show likes
  Future<void> openDialog() async {
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

  InkWell _getLikeOption(User u) {
    return InkWell(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CommunityProfile(
                              userId: u.id,
                            )));
              },
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(100.0),
                  child: CachedNetworkImage(
                    width: 35,
                    height: 35,
                    fit: BoxFit.cover,
                    imageUrl: u?.imageUrl ??
                        "https://i.pinimg.com/564x/19/b8/d6/19b8d6e9b13eef23ec9c746968bb88b1.jpg",
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  )),
            ),
            SizedBox(
              width: 8,
            ),
            Expanded(
                child: InkWell(
              child: Text(
                u?.fullName ??
                    "Name", //used to say "Preet"...lol.  Shaela changed to "Name."
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

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    return PlatformScaffold(
        appBar: PlatformAppBar(
          backgroundColor: AppColors.yellowColor,
          title: Text(
            "Post",
            style: TextStyle(color: Colors.white),
          ),
          cupertino: (_, __) =>
              CupertinoNavigationBarData(brightness: Brightness.dark),
        ),
        body: Scaffold(
            resizeToAvoidBottomInset: false,
            body: SafeArea(
              child: (isImgSelected == false)
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Expanded(
                          child: SingleChildScrollView(
                            child: Container(
                              color: Colors.white,
                              child: Column(
                                children: <Widget>[
                                  Container(
                                    padding: EdgeInsets.all(8),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Container(
                                          height: 50,
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              (_post?.user?.imageUrl != null &&
                                                      _post?.user?.imageUrl
                                                          .isNotEmpty &&
                                                      _post?.user?.imageUrl !=
                                                          "na")
                                                  ? InkWell(
                                                      onTap: () {
                                                        if (_post
                                                            ?.announcement) {
                                                          Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        AnnouncementsPage(),
                                                              ));
                                                        } else {
                                                          Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          CommunityProfile(
                                                                            userId:
                                                                                _post.user.id,
                                                                          )));
                                                        }
                                                      },
                                                      child: ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      100.0),
                                                          child: _post
                                                                  ?.announcement
                                                              ? Container(
                                                                  width: 50,
                                                                  height: 50,
                                                                  child: Image
                                                                      .asset(
                                                                          "assets/images/dark_logo.png"),
                                                                )
                                                              : CachedNetworkImage(
                                                                  imageUrl: _post
                                                                          ?.user
                                                                          ?.imageUrl ??
                                                                      "https://i.pinimg.com/564x/19/b8/d6/19b8d6e9b13eef23ec9c746968bb88b1.jpg",
                                                                  errorWidget: (context,
                                                                          url,
                                                                          error) =>
                                                                      Icon(Icons
                                                                          .error),
                                                                )),
                                                    )
                                                  : Icon(Icons.person,
                                                      size: 50),
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
                                                    InkWell(
                                                      child: Text(
                                                        _post?.announcement ??
                                                                true
                                                            ? "Pure Match"
                                                            : _post?.user
                                                                    ?.fullName ??
                                                                "Pure Match",
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      onTap: () {
                                                        if (_post
                                                            ?.announcement) {
                                                          Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        AnnouncementsPage(),
                                                              ));
                                                        } else {
                                                          Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          CommunityProfile(
                                                                            userId:
                                                                                _post.user.id,
                                                                          )));
                                                        }
                                                      },
                                                    ),
                                                    SizedBox(
                                                      height: 3,
                                                    ),
                                                    Text(
                                                      _post?.createdAt ??
                                                          "Oops...",
                                                      style: TextStyle(
                                                          color: Colors.grey,
                                                          fontSize: 12),
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
                                                    //TODO log analytics for saved post and unsave post
                                                    //TODO log analytics for reported post
                                                  }
                                                },
                                                itemBuilder:
                                                    (BuildContext context) {
                                                  return <PopupMenuEntry>[
                                                    PopupMenuItem(
                                                      child: Text("Save"),
                                                      value: 1,
                                                    ),
                                                    PopupMenuItem(
                                                      child: Text(
                                                        "Report",
                                                        style: TextStyle(
                                                            color: Colors.red),
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
                                        Container(
                                          padding: EdgeInsets.only(left: 10),
                                          child: Text(
                                            _post?.text ??
                                                "Sorry!  It's either taking us longer to load the page you clicked on, or we can't find that post anymore.  Please stay tuned as we work to make this screen less confusing, lol.",
                                            style: TextStyle(
                                                color: AppColors.blackColor),
                                            textAlign: TextAlign.left,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        ((_post?.images ?? []).length > 0)
                                            ? CarouselSlider(
                                                options: CarouselOptions(
                                                  aspectRatio: 16 / 9,
                                                  viewportFraction: 1,
                                                  onPageChanged:
                                                      (i, pageChangedReason) {
                                                    setState(() {
                                                      _post.carouselIndex = i;
                                                    });
                                                  },
                                                ),
                                                items: (_post?.images ?? [])
                                                    .map((i) {
                                                  return InkWell(
                                                    onTap: () {
                                                      print(
                                                          "image selected $i");
                                                      isImgSelected = true;
                                                      selectedImageUrl = i;
                                                      setState(() {});
                                                    },
                                                    child: CachedNetworkImage(
                                                      imageUrl: i,
                                                      width: double.infinity,
                                                      fit: BoxFit.cover,
                                                      errorWidget: (context,
                                                              url, error) =>
                                                          Icon(Icons.error),
                                                    ),
                                                  );
                                                }).toList(),
                                              )
                                            : Container(),
                                        ((_post?.images ?? []).length > 0)
                                            ? RoundIndicators(
                                                circleSize: 12,
                                                currentIndicatorIndex:
                                                    _post.carouselIndex,
                                                numberOfInidcators:
                                                    (_post?.images ?? [])
                                                        .length,
                                                bubbleColor:
                                                    AppColors.yellowColor,
                                                disableBubbleColor:
                                                    AppColors.greyColor,
                                                borderColor: Colors.white,
                                              )
                                            : Container(),
                                        Container(
                                            width: double.infinity,
                                            child: InkWell(
                                              onTap: () {
                                                openDialog();
                                              },
                                              child: Text(
                                                "${_post?.numberOfLikes} likes ${_post?.numberOfComments} comments",
                                                style: TextStyle(
                                                    color: AppColors.blackColor,
                                                    fontSize: 12),
                                                textAlign: TextAlign.right,
                                              ),
                                            )),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            MyButtons.getActionButtons(
                                                1, 0, "Like", () {
                                              setState(() {
                                                if (_post.liked)
                                                  _post.numberOfLikes--;
                                                else
                                                  _post.numberOfLikes++;
                                                _post.liked = !_post.liked;
                                              });
                                              if (_post.liked)
                                                this._likePost(_post.id);
                                              else
                                                this._unlikePost(_post.id);
                                            }, _post?.liked ?? false),
                                            MyButtons.getActionButtons(
                                                1, 1, "Comment", () {}, false),
                                            MyButtons.getActionButtons(
                                                1, 2, "Share", () {}, false),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(children: this._renderComments()),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
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
                                        width: 50,
                                        height: 50,
                                        imageUrl: _user?.imageUrl ??
                                            "https://i.pinimg.com/564x/19/b8/d6/19b8d6e9b13eef23ec9c746968bb88b1.jpg",
                                        fit: BoxFit.cover,
                                        errorWidget: (context, url, error) =>
                                            Icon(Icons.error),
                                      ))
                                  : Container(),
                              SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                  child: TextField(
                                      textCapitalization:
                                          TextCapitalization.sentences,
                                      controller: _ctrl,
                                      style: TextStyle(
                                        fontSize: 12.0,
                                        color: Colors.black,
                                      ),
                                      onChanged: (val) {
                                        _newComment = val;
                                        setState(() {});
                                      },
                                      decoration: InputDecoration(
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 0.0, horizontal: 8),
                                          filled: true,
                                          suffixIcon: IconButton(
                                            onPressed: (this
                                                    ._newComment
                                                    .trim()
                                                    .isNotEmpty)
                                                ? () {
                                                    this._sendComment();
                                                    this._ctrl.clear();
                                                  }
                                                : null,
                                            icon: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        100.0),
                                                child: Container(
                                                    padding: EdgeInsets.all(3),
                                                    color:
                                                        AppColors.yellowColor,
                                                    child: Icon(
                                                      Icons.arrow_upward,
                                                      color: Colors.white,
                                                    ))),
                                          ),
                                          hintText: "Add Comment...",
                                          border: aa,
                                          focusedBorder: aa,
                                          enabledBorder: aa,
                                          disabledBorder: aa))),
                            ],
                          ),
                        )
                      ],
                    )
                  : InkWell(
                      onTap: () {
                        isImgSelected = false;
                        selectedImageUrl = "";
                        setState(() {});
                      },
                      child: Center(
                        child: CachedNetworkImage(
                          imageUrl: selectedImageUrl,
                          errorWidget: (context, url, error) =>
                              Icon(Icons.error),
                        ),
                      ),
                    ),
            )));
  }

  Container _getComment(Comment c,
      {bool isReply = false, Comment mainComment}) {
    TextEditingController ctrl = TextEditingController();
    List<Widget> replies = [];
    if (c.replies != null && c.replies.length > 0) {
      for (var r in c.replies) {
        replies.add(this._getComment(r, isReply: true, mainComment: c));
      }
    }
    return (Container(
      padding: EdgeInsets.all(10),
      child: Column(
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              (c.user?.imageUrl != null &&
                      c.user?.imageUrl.isNotEmpty &&
                      c.user?.imageUrl != "na")
                  ? InkWell(
                      onTap: () {
                        int uid = c.userid;
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CommunityProfile(
                                      userId: uid,
                                    )));
                      },
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(100.0),
                          child: CachedNetworkImage(
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            imageUrl: c.user?.imageUrl ??
                                "https://i.pinimg.com/564x/19/b8/d6/19b8d6e9b13eef23ec9c746968bb88b1.jpg",
                            errorWidget: (context, url, error) =>
                                Icon(Icons.error),
                          )),
                    )
                  : Icon(Icons.person, size: 50),
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.greyColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: BoxConstraints(maxWidth: 200),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          InkWell(
                            child: Text(c?.user?.fullName ?? "Michale Morris",
                                style: TextStyle(fontWeight: FontWeight.bold),
                                textAlign: TextAlign.left),
                            onTap: () {
                              int uid = c.userid;
                              print(uid);
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => CommunityProfile(
                                            userId: uid,
                                          )));
                            },
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            c?.text ?? "Nice pictures Jennie!",
                            style: TextStyle(),
                            textAlign: TextAlign.left,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 2,
                    ),
                    Row(
                      children: <Widget>[
                        Text(
                          c?.createdAt ?? "10m",
                          style: TextStyle(
                              color: AppColors.offWhiteColor, fontSize: 12),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        InkWell(
                            onTap: () {
                              setState(() {
                                if (c.liked)
                                  c.likes--;
                                else
                                  c.likes++;
                                c.liked = !c.liked;
                              });
                              if (c.liked)
                                this._likeComment(c.id);
                              else
                                this._unlikeComment(c.id);
                            },
                            child: Text(
                              "${c.likes} Likes",
                              style: TextStyle(
                                  color: (c.liked)
                                      ? AppColors.yellowColor
                                      : AppColors.offWhiteColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12),
                            )),
                        SizedBox(
                          width: 5,
                        ),
                        InkWell(
                          onTap: () {
                            setState(() {
                              c.replyTextOn = !c.replyTextOn;
                            });
                          },
                          child: Text(
                            "Reply",
                            style: TextStyle(
                                color: AppColors.offWhiteColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Column(
                      children: replies,
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    (c.replyTextOn && isReply == false)
                        ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: <Widget>[
                                (_user?.imageUrl != null &&
                                        _user?.imageUrl.isNotEmpty &&
                                        _user?.imageUrl != "na")
                                    ? ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(100.0),
                                        child: CachedNetworkImage(
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.cover,
                                          imageUrl: _user?.imageUrl ??
                                              "https://i.pinimg.com/564x/19/b8/d6/19b8d6e9b13eef23ec9c746968bb88b1.jpg",
                                          errorWidget: (context, url, error) =>
                                              Icon(Icons.error),
                                        ))
                                    : Icon(Icons.person, size: 46),
                                SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                    child: TextField(
                                        textCapitalization:
                                            TextCapitalization.sentences,
                                        controller: ctrl,
                                        style: TextStyle(
                                          fontSize: 12.0,
                                          color: Colors.black,
                                        ),
                                        onChanged: (val) {
                                          _newComment = val;
                                        },
                                        decoration: InputDecoration(
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    vertical: 0.0,
                                                    horizontal: 8),
                                            filled: true,
                                            suffixIcon: IconButton(
                                              onPressed: () {
                                                try {
                                                  if (this
                                                      ._newComment
                                                      .trim()
                                                      .isEmpty) return;
                                                  var data = {
                                                    "text": this._newComment
                                                  };
                                                  MyHttp.post(
                                                          "/posts/reply/${c.id}",
                                                          data)
                                                      .then((res) {
                                                    print(
                                                        "Comment Reply added");
                                                    print(res.statusCode);
                                                    print(res.body);
                                                    var body =
                                                        json.decode(res.body);
                                                    var comment =
                                                        body["comment"];
                                                    var reply = comment["reply"]
                                                        as List<dynamic>;

                                                    //Analytics tracking code
                                                    analytics.logEvent(
                                                        name: "replied_comment",
                                                        parameters: <String,
                                                            dynamic>{
                                                          'post_id':
                                                              comment["PostId"],
                                                          'user_id':
                                                              comment["userId"]
                                                        });
                                                    amplitudeAnalytics.logEvent(
                                                        "replied_comment",
                                                        eventProperties: {
                                                          'post_id':
                                                              comment["PostId"],
                                                          'user_id':
                                                              comment["userId"]
                                                        });

                                                    if (reply != null &&
                                                        reply.length > 0) {
                                                      for (var r in reply) {
                                                        print("****");
                                                        print(r);
                                                      }
                                                    }
                                                    ctrl.clear();
                                                    this._getFeed(
                                                        widget.postId);
                                                  }).catchError((e) {
                                                    print(
                                                        "Comments Reply Error: $e");
                                                  });
                                                } catch (e) {
                                                  print(
                                                      "Comment Reply Error: $e");
                                                }
                                              },
                                              icon: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          100.0),
                                                  child: Container(
                                                      padding:
                                                          EdgeInsets.all(3),
                                                      color:
                                                          AppColors.yellowColor,
                                                      child: Icon(
                                                        Icons.arrow_upward,
                                                        color: Colors.white,
                                                      ))),
                                            ),
                                            hintText: "Reply...",
                                            border: aa,
                                            focusedBorder: aa,
                                            enabledBorder: aa,
                                            disabledBorder: aa))),
                              ],
                            ),
                          )
                        : Container(),
//                    _getComment(ni)
                  ],
                ),
              )
            ],
          ),
          (c.replyTextOn && isReply == true)
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: <Widget>[
                      ClipRRect(
                          borderRadius: BorderRadius.circular(100.0),
                          child: (_user != null &&
                                  _user.imageUrl != null &&
                                  _user.imageUrl.isNotEmpty &&
                                  _user.imageUrl != "na")
                              ? CachedNetworkImage(
                                  width: 50,
                                  imageUrl: _user?.imageUrl,
                                  errorWidget: (context, url, error) =>
                                      Icon(Icons.error),
                                )
                              : Icon(Icons.person, size: 50)),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                          child: TextField(
                              textCapitalization: TextCapitalization.sentences,
                              controller: ctrl,
                              style: TextStyle(
                                fontSize: 12.0,
                                color: Colors.black,
                              ),
                              onChanged: (val) {
                                _newComment = val;
                              },
                              decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 0.0, horizontal: 8),
                                  filled: true,
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      try {
                                        if (this._newComment.trim().isEmpty)
                                          return;
                                        var data = {"text": this._newComment};
                                        MyHttp.post(
                                                "/posts/reply/${mainComment.id}",
                                                data)
                                            .then((res) {
                                          print("Comment Reply added");
                                          print(res.statusCode);
                                          print(res.body);
                                          var body = json.decode(res.body);
                                          var comment = body["comment"];
                                          var reply =
                                              comment["reply"] as List<dynamic>;
                                          //Analytics tracking code
                                          analytics.logEvent(
                                              name: "replied_comment",
                                              parameters: <String, dynamic>{
                                                'post_id': mainComment.id,
                                                'user_id': comment["userId"]
                                              });
                                          amplitudeAnalytics.logEvent(
                                              "replied_comment",
                                              eventProperties: {
                                                'post_id': mainComment.id,
                                                'user_id': comment["userId"]
                                              });

                                          if (reply != null &&
                                              reply.length > 0) {
                                            for (var r in reply) {
                                              print("****");
                                              print(r);
                                            }
                                          }
                                          ctrl.clear();
                                          this._getFeed(widget.postId);
                                        }).catchError((e) {
                                          print("Comments Reply Error: $e");
                                        });
                                      } catch (e) {
                                        print("Comment Reply Error: $e");
                                      }
                                    },
                                    icon: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(100.0),
                                        child: Container(
                                            padding: EdgeInsets.all(3),
                                            color: AppColors.yellowColor,
                                            child: Icon(
                                              Icons.arrow_upward,
                                              color: Colors.white,
                                            ))),
                                  ),
                                  hintText: "Reply...",
                                  border: aa,
                                  focusedBorder: aa,
                                  enabledBorder: aa,
                                  disabledBorder: aa))),
                    ],
                  ),
                )
              : Container(),
        ],
      ),
    ));
  }
}
