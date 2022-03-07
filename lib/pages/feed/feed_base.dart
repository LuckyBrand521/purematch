import 'package:flutter/material.dart';
import 'package:pure_match/pages/feed/feed_base_enum.dart';
import 'package:pure_match/pages/feed/feed_notification.dart';
import 'package:pure_match/pages/feed/friends_base.dart';
import 'package:pure_match/pages/feed/my_activity_base.dart';
import 'package:pure_match/pages/feed/my_feed.dart';

class FeedBase extends StatefulWidget {
  final int postId;
  final BaseFeedEnum baseFeedEnum;
  final bool isFriendRequest;
  final Function(int) onSelectedOptionFriendRequest;
  final Function(int) onSelectedFeedNotification;
  FeedBase(
      {Key key,
      @required this.baseFeedEnum,
      this.isFriendRequest,
      this.onSelectedOptionFriendRequest,
      this.onSelectedFeedNotification,
      this.postId})
      : super(key: key);

  @override
  _FeedBaseState createState() => _FeedBaseState();
}

class _FeedBaseState extends State<FeedBase> {
  Widget pageToRender;

  void selectedOptionFriendRequest(index) {
    widget.onSelectedOptionFriendRequest(index);
  }

  void selectFeedNotification(int index) {
    widget.onSelectedFeedNotification(index);
  }

  @override
  Widget build(BuildContext context) {
    switch (this.widget.baseFeedEnum) {
      case BaseFeedEnum.MY_ACTIVITY:
        pageToRender = MyActivityBase();
        break;
      case BaseFeedEnum.MY_FEED:
        pageToRender = MyFeed(
          postId: widget.postId,
        );
        break;
      case BaseFeedEnum.NOTIFICATION:
        pageToRender = FeedNotification(
          selectFeedNotification: selectFeedNotification,
        );
        break;
      case BaseFeedEnum.FRIENDS:
        pageToRender = FriendsBase(
          isFriendReuest: widget.isFriendRequest,
          selectOptionFriendRequest: selectedOptionFriendRequest,
        );
        break;
      default:
        pageToRender = MyFeed();
    }
    return pageToRender;
  }
}
