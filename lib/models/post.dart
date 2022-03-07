import 'dart:core';
import 'package:pure_match/common/global.dart';
import 'package:pure_match/models/user.dart';

class Post {
  int id;
  String text;
  User user;
  bool announcement;
  List<String> images;
  String _createdAt;
  bool liked;
  int numberOfLikes;
  int numberOfComments;
  int carouselIndex = 0;
  List<User> likedByUsers = [];

  Post(this.id, this.text, this.announcement, this.user, this.images,
      this.liked, this._createdAt,
      {this.numberOfLikes = 0, this.numberOfComments = 0, this.likedByUsers});

  String get createdAt {
    String time = "NA";
    time = Global.createdAt(this._createdAt);
    return time;
  }

  Post.fromJson(Map<String, dynamic> json, int userId) {
    try {
      Map<String, dynamic> author = json['Author'] ?? json["User"];
      print("author $author");
      if (author != null) {
        this.user = User.fromJson(author);
      }

      List<dynamic> likes = json["Likes"] ?? json["LikeActions"];
      bool liked = false;
      int numberOfLikes = 0;
      List<User> likedByUsers = [];
      if (likes != null && likes.length > 0) {
        numberOfLikes = likes.length;
        for (var l in likes) {
          var lUser = User.likedUser(l);
          if (lUser.id == userId) {
            liked = true;
          }
          likedByUsers.add(lUser);
        }
      }

      List<dynamic> comments = json["Comments"];
      int commentsCount = 0;
      if (comments != null && comments.length > 0) {
        commentsCount = comments.length;
      }
      this.images = [];
      var postUploads = json['PostUploads'];
      if (postUploads != null) {
        for (var path in postUploads) {
          var p = path["path"];
          print("P $p");
          this.images.add(p);
        }
      }
      if (json["announcement"] != null && json["announcement"] == true) {
        this.announcement = true;
      } else {
        this.announcement = false;
      }
      this.id = json["id"];
      this.text = json["text"];
      // this.images = json['PostUploads']?.cast<String>();
      this.liked = liked;
      this._createdAt = json["createdAt"];
      this.numberOfLikes = numberOfLikes;
      this.numberOfComments = commentsCount;
      this.likedByUsers = likedByUsers;
    } catch (e, postErroStackTrac) {
      print("postErroStackTrac $postErroStackTrac");
      print("post deserialise error:$e");
      throw e;
    }
  }
}

class Like {
  int id;
  int userId;
  int postId;
  String commentId;
  String createdAt;
  String updatedAt;
  User user;

  Like(this.id, this.userId, this.postId, this.commentId, this.createdAt,
      this.updatedAt, this.user);
  Like.fromJson(Map<String, dynamic> json) {
    var likedUser = json['User'];
    Like(
        this.id = json['id'],
        this.userId = json['UserId'],
        this.postId = json['PostId'],
        this.commentId = json['CommentId'],
        this.createdAt = json['createdAt'],
        this.updatedAt = json['updatedAt'],
        this.user = User.fromJson(likedUser));
  }
}

// TODO: implement comments
class Comment {
  int id;
  Comment(
    this.id,
  );
  Comment.fromJson(Map<String, dynamic> json) {
    Comment(
      this.id = json['id'],
    );
  }
}
