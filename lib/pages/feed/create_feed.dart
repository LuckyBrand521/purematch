import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pure_match/common/MyButtons.dart';
import 'package:pure_match/common/RoundIndicators.dart';
import 'package:pure_match/common/global.dart';
import 'package:pure_match/models/post.dart';
import 'package:pure_match/pages/feed/announcements.dart';

import '../AppColors.dart';

class CreateFeed {
  static Container createPost(
      BuildContext context,
      Post p,
      Function _openIosOptions,
      Function _getFeedDetails,
      Function _onCarouselPageChange,
      Function openDialog,
      Function likeUnlikePost,
      Function shareFeed,
      Function community,
      Function(String) onClickImage,
      bool ActivityPage) {
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
                      InkWell(
                        child: (p?.user?.imageUrl != null &&
                                p?.user?.imageUrl?.isNotEmpty &&
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
                                        imageUrl: p?.user?.imageUrl,
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                        errorWidget: (context, url, error) =>
                                            Icon(Icons.error),
                                      ))
                            //this code puts the pure match logo on the post if it is an announcement or a person icon if its not.
                            : (p?.announcement != null &&
                                    p?.announcement == true)
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(100.0),
                                    child: Container(
                                      width: 50,
                                      height: 50,
                                      child: Image.asset(
                                          "assets/images/dark_logo.png"),
                                    ),
                                  )
                                : Icon(Icons.person, size: 50),
                        onTap: p?.announcement
                            ? () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AnnouncementsPage(),
                                    ));
                              }
                            : community,
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
                            InkWell(
                              child: Row(
                                children: [
                                  Text(
                                    p?.announcement
                                        ? "Pure Match "
                                        : p?.user?.fullName ?? "",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  p?.announcement
                                      ? Icon(
                                          Icons.campaign,
                                        )
                                      : Container(),
                                  (p?.announcement && ActivityPage == true)
                                      ? Text(
                                          "  See All Announcements",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12,
                                              color: AppColors.blueColor),
                                        )
                                      : Container(),
                                ],
                              ),
                              onTap: p?.announcement
                                  ? () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                AnnouncementsPage(),
                                          ));
                                    }
                                  : community,
                            ),
                            SizedBox(
                              height: 3,
                            ),
                            Text(
                              p?.createdAt ?? "",
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
                                    break;
                                  case 2:
                                    break;
                                }
                              },
                              itemBuilder: (BuildContext context) {
                                ///TODO: FIGURE OUT HOW TO MAKE SURE THAT SOMEONE WITH A DIFFERENT ID CANT SEE THE DELETE AND EDIT OPTIONS FOR ANDROID
                                return <PopupMenuEntry>[
                                  PopupMenuItem(
                                    child: Text("Save"),
                                    value: 1,
                                  ),
                                  PopupMenuItem(
                                    child: Text("Edit"),
                                    value: 2,
                                  ),
                                  PopupMenuItem(
                                    child: Text("Delete"),
                                    value: 3,
                                  ),
                                  PopupMenuItem(
                                    child: Text(
                                      "Report",
                                      style: TextStyle(color: Colors.red),
                                    ),
                                    value: 4,
                                  ),
                                ];
                              },
                            )
                          : IconButton(
                              onPressed: _openIosOptions,
                              icon: Icon(CupertinoIcons.ellipsis),
                              color: Color.fromRGBO(255, 172, 0, 1),
                              iconSize: 28,
                            )
                    ],
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                InkWell(
                  onTap: _getFeedDetails,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(left: 10),
                        child: Text(
                          p?.text ?? "",
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
                                aspectRatio: 16 / 9,
                                viewportFraction: 1,
                                onPageChanged: (i, pageChangedReason) {
                                  _onCarouselPageChange(i);
                                },
                              ),
                              items: p.images.map((i) {
                                return InkWell(
                                  onTap: () {
                                    onClickImage(i);
                                  },
                                  child: CachedNetworkImage(
                                    imageUrl: i,
                                    width: AppConfig.fullWidth(context),
                                    fit: BoxFit.fitWidth,
                                    errorWidget: (context, url, error) =>
                                        Icon(Icons.error),
                                  ),
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
                    MyButtons.getActionButtons(
                        1, 0, "Like", likeUnlikePost, p.liked),
                    MyButtons.getActionButtons(
                        1, 1, "Comment", _getFeedDetails, false),
                    MyButtons.getActionButtons(1, 2, "Share", shareFeed, false),
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
}

//class CreateFeed{
//
//  void _likePost(int id) async {
//    print("Id is $id");
//    try {
//      var data = {};
//      var res = await MyHttp.post("/posts/like/post/$id", data);
//      print("Post liked");
//      print(res.statusCode);
//      print(res.body);
//    } catch (e) {
//      print("Like error");
//      print(e);
//    }
//  }
//
//
//  void _unlikePost(int id) async {
//    print("Id is $id");
//    print("unlike kra");
//    try {
//      var res = await MyHttp.delete("/posts/like/post/$id");
//      print("Post unliked done");
//      // print(res.statusCode);
//
//      // print(res.body);
//    } catch (e) {
//      print("UnLike error");
//      print(e);
//    }
//  }
//
//  _openIosOptions(BuildContext context) {
//    return showCupertinoModalPopup(
//        context: context, builder: (BuildContext context) {
//      return CupertinoActionSheet(
//        actions: <Widget>[
////                                             CupertinoActionSheetAction(
////                                                child: Text("Unmatch"),
////                                                onPressed: () {},
////                                              ),
//          CupertinoActionSheetAction(
//            child: Text(
//              "Report",
//              style: TextStyle(
//                  color: Colors.red),
//            ),
//            onPressed: () {},
//          ),
//        ],
//      );
//    });
//  }
//
//  Container createPost(Post p) {
//    return Container(
//      color: Colors.white,
//      child: Column(
//        children: <Widget>[
//          Container(
//            padding: EdgeInsets.all(8),
//            child: Column(
//              crossAxisAlignment: CrossAxisAlignment.start,
//              children: <Widget>[
//                Container(
//                  height: 50,
//                  child: Row(
//                    crossAxisAlignment: CrossAxisAlignment.start,
//                    children: <Widget>[
//                      ClipRRect(
//                          borderRadius:
//                          BorderRadius.circular(100.0),
//                          child: CachedNetworkImage(
//                            imageUrl: p?.user?.imageUrl ??
//                                "https://i.pinimg.com/564x/19/b8/d6/19b8d6e9b13eef23ec9c746968bb88b1.jpg",
//                          )),
//                      SizedBox(
//                        width: 10,
//                      ),
//                      Expanded(
//                        child: Column(
//                          crossAxisAlignment:
//                          CrossAxisAlignment.start,
//                          children: <Widget>[
//                            SizedBox(
//                              height: 5,
//                            ),
//                            Text(
//                              p?.user?.name ?? "Jane Nany",
//                              style: TextStyle(
//                                  color: Colors.black,
//                                  fontSize: 14,
//                                  fontWeight: FontWeight.bold),
//                            ),
//                            SizedBox(
//                              height: 3,
//                            ),
//                            Text(
//                              p?.createdAt ?? "Today at 3:30pm",
//                              style: TextStyle(
//                                  color: Colors.grey,
//                                  fontSize: 12),
//                            ),
//                          ],
//                        ),
//                      ),
//                      (Platform.isAndroid)
//                          ? PopupMenuButton(
//                        onSelected: (i) {
//                          switch (i) {
//                            case 1:
//                              break;
//                            case 2:
//                              break;
//                          }
//                        },
//                        itemBuilder:
//                            (BuildContext context) {
//                          return <PopupMenuEntry>[
////                                                PopupMenuItem(
////                                                  child: Text("Save"),
////                                                  value: 1,
////                                                ),
//                            PopupMenuItem(
//                              child: Text(
//                                "Report",
//                                style: TextStyle(
//                                    color: Colors.red),
//                              ),
//                              value: 2,
//                            ),
//                          ];
//                        },
//                      )
//                          : IconButton(
//                        onPressed: () {
//                          this._openIosOptions();
//                        },
//                        icon: Icon(CupertinoIcons.ellipsis),
//                      )
//                    ],
//                  ),
//                ),
//                SizedBox(
//                  height: 5,
//                ),
//                InkWell(
//                  onTap: () {
//                    Navigator.push(
//                        context,
//                        MaterialPageRoute(
//                            builder: (context) =>
//                                FeedDetail(
//                                  postId: p.id,
//                                ))).then((v) {
//                      this._getFeed();
//                    });
//                  },
//                  child: Column(
//                    mainAxisAlignment: MainAxisAlignment.start,
//                    crossAxisAlignment: CrossAxisAlignment.start,
//                    children: <Widget>[
//                      Container(
//                        padding: EdgeInsets.only(left: 10),
//                        child: Text(
//                          p?.text ??
//                              "Getting as group together to play ultimate frisbee.  Anyone wanna join?",
//                          style: TextStyle(
//                              color: AppColors.blackColor),
//                          textAlign: TextAlign.left,
//                        ),
//                      ),
//                      SizedBox(
//                        height: 10,
//                      ),
//                      ((p?.images ?? []).length > 0)
//                          ? CarouselSlider(
//                        options: CarouselOptions(
//                          viewportFraction: 1.0,
//                          onPageChanged: (i, pageChangedReason) {
//                            setState(() {
//                              p.carouselIndex = i;
//                            });
//                          },
//                        ),
//                        items: p.images.map((i) {
//                          return CachedNetworkImage(
//                            imageUrl: i,
//                          );
//                        }).toList(),
//                      )
//                          : Container(),
//                      ((p?.images ?? []).length > 0)
//                          ? RoundIndicators(
//                        circleSize: 12,
//                        currentIndicatorIndex:
//                        p.carouselIndex,
//                        numberOfInidcators:
//                        (p?.images ?? []).length,
//                        bubbleColor: AppColors
//                            .feedImageIndicatorColor,
//                        disableBubbleColor: AppColors
//                            .feedDisableIndicatorBtn,
//                        borderColor: Colors.white,
//                      )
//                          : Container(),
//                    ],
//                  ),
//                ),
//                InkWell(
//                  onTap: () {
//                    openDialog(p?.likedByUsers);
//                  },
//                  child: Container(
//                      width: double.infinity,
//                      child: Text(
//                        "${p?.numberOfLikes} likes ${p
//                            ?.numberOfComments} comments",
//                        style: TextStyle(
//                            color: AppColors.blackColor,
//                            fontSize: 12),
//                        textAlign: TextAlign.right,
//                      )),
//                ),
//                SizedBox(
//                  height: 10,
//                ),
//                Row(
//                  crossAxisAlignment: CrossAxisAlignment.center,
//                  mainAxisAlignment: MainAxisAlignment.center,
//                  children: <Widget>[
//                    MyButtons.getActionButtons(
//                        1, Icons.favorite, "Like", () {
//                      setState(() {
//                        if (p.liked)
//                          p.numberOfLikes--;
//                        else
//                          p.numberOfLikes++;
//                        p.liked = !p.liked;
//                      });
//                      if (p.liked)
//                        this._likePost(p.id);
//                      else
//                        this._unlikePost(p.id);
//                    }, p.liked),
//                    MyButtons.getActionButtons(
//                        1, Icons.chat, "Comment", () {
//                      Navigator.push(context,
//                          MaterialPageRoute(builder: (context) =>
//                              FeedDetail(postId: p.id)));
//                    }, false),
//                    MyButtons.getActionButtons(
//                        1, Icons.share, "Share", () {
//                      Navigator.push(
//                          context,
//                          MaterialPageRoute(
//                              builder: (context) =>
//                                  ShareFeed(
//                                    postId: p?.id,
//                                  )));
//                    }, false),
//                  ],
//                ),
//              ],
//            ),
//          ),
//          SizedBox(
//            height: 10,
//            child: Container(
//              color: AppColors.greyColor,
//            ),
//          )
//        ],
//      ),
//    );
//  }
//
//}
