import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:pure_match/models/post.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pure_match/models/user.dart';
import 'package:pure_match/pages/AppColors.dart';
import 'package:pure_match/pages/feed/feed_detail.dart';
import 'package:pure_match/pages/feed/share_feed.dart';
import 'package:pure_match/common/MyButtons.dart';
import 'RoundIndicators.dart';

class PostBuilder extends StatefulWidget {
  Post post;

  PostBuilder({post}) {
    this.post = post;
  }

  @override
  _PostBuilderState createState() => _PostBuilderState();
}

class _PostBuilderState extends State<PostBuilder> {
  Post post;
  int postCarouselIndex;

  void initState() {
    post = widget.post;
    postCarouselIndex = 0;
    super.initState();
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

  Future<void> openDialog(List<User> likedByUsers) async {
    List<Widget> likeDialogContent = [];
    for (User user in likedByUsers) {
      likeDialogContent.add(this._getLikeOption(user));
    }

    await showDialog(
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

//   _openIosPostOptions() {
//     return showCupertinoModalPopup(
//         context: context,
//         builder: (BuildContext context) {
//           return CupertinoActionSheet(
//             actions: <Widget>[
// //                                              CupertinoActionSheetAction(
// //                                                child: Text("Unmatch"),
// //                                                onPressed: () {},
// //                                              ),
//               CupertinoActionSheetAction(
//                 child: Text(
//                   "Report",
//                   style: TextStyle(color: Colors.red),
//                 ),
//                 onPressed: () {},
//               ),
//             ],
//           );
//         });
//   }

  @override
  Widget build(BuildContext context) {
    return (Container(
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
                            imageUrl: post.user?.imageUrl ??
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
                              post.user?.fullName ?? "Name",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 3,
                            ),
                            Text(
                              post.createdAt ?? "Today at 3:30pm",
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      // TODO: implement post action options - save, report
                      /* (Platform.isAndroid)
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
                                _openIosPostOptions();
                              },
                              icon: Icon(CupertinoIcons.ellipsis),
                            ) */
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
                                )));
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(left: 10),
                        child: Text(
                          post.text ??
                              "Getting as group together to play ultimate frisbee.  Anyone wanna join?",
                          style: TextStyle(color: AppColors.blackColor),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      ((post.images ?? []).length > 0)
                          ? CarouselSlider(
                              options: CarouselOptions(
                                viewportFraction: 1.0,
                                onPageChanged: (i, pageChangedReason) {
                                  setState(() {
                                    this.postCarouselIndex = i;
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
                      ((post.images ?? []).length > 0)
                          ? RoundIndicators(
                              circleSize: 12,
                              currentIndicatorIndex: this.postCarouselIndex,
                              numberOfInidcators: (post.images ?? []).length,
                              bubbleColor: AppColors.yellowColor,
                              disableBubbleColor: AppColors.greyColor,
                              borderColor: Colors.white,
                            )
                          : Container(),
                    ],
                  ),
                ),
                // TODO: implement like dialog
                /* InkWell(
                  onTap: post.likes != null && post.likes.length > 0
                      ? () {
                          openDialog(List<User>.from(
                              post.likes.map((like) => like.user)));
                        }
                      : null,
                  child: Container(
                      width: double.infinity,
                      child: Text(
                        "${(post.likes ?? []).length} likes ${(post.comments ?? []).length} comments",
                        style: TextStyle(
                            color: AppColors.blackColor, fontSize: 12),
                        textAlign: TextAlign.right,
                      )),
                ), */
                SizedBox(
                  height: 10,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    // TODO: implement like, unlike
                    /* MyButtons.getActionButtons(1, Icons.favorite, "Like", () {
                      setState(() {
                        if (post.liked)
                          p.numberOfLikes--;
                        else
                          p.numberOfLikes++;
                        p.liked = !p.liked;
                      });
                      if (p.liked)
                        _likePost(p.id);
                      else
                        _unlikePost(p.id);
                    }, p.liked), */
                    // TODO: implement comment
                    MyButtons.getActionButtons(1, 1, "Comment", () {}, false),
                    MyButtons.getActionButtons(1, 2, "Share", () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ShareFeed(
                                    postId: post.id,
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
    ));
  }
}
