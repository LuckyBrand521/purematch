import 'package:pure_match/models/post.dart';
import 'package:pure_match/models/user.dart';

class SearchFeedData {
  String term;
  User user;
  Post post;

  SearchFeedData({this.term, this.user, this.post});
}
