import 'dart:convert';
import 'dart:ui';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:amplitude_flutter/amplitude.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:intl/intl.dart';
import 'package:pure_match/common/MyButtons.dart';
import 'package:pure_match/common/constants.dart';
import 'package:pure_match/common/global.dart';
import 'package:pure_match/common/loading.dart';
import 'package:pure_match/models/match_card.dart';
import 'package:pure_match/pages/AppColors.dart';
import 'package:pure_match/pages/MyHttp.dart';
import 'package:pure_match/common/reason_to_report.dart';
import 'package:pure_match/pages/rewards/plan.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import 'its_mutual.dart';
import 'match_user_profile.dart';

enum MyHistoryPage { MUTUAL, LIKES, MAYBE, LIKED_ME, VIEWED_ME }

class MyHistory extends StatefulWidget {
  final MyHistoryPage myHistoryPage;
  final Key key;
  final int userId;
  const MyHistory(
      {@required this.key, @required this.myHistoryPage, this.userId})
      : super(key: key);
  @override
  _MyHistoryState createState() => _MyHistoryState(key: key);
}

class _MyHistoryState extends State<MyHistory> {
  List<Widget> items = [];
  // Analytics code
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';

  List<Widget> dummy1 = [];
  List<Widget> dummy2 = [];
  List<MatchCard> _matchCard = [];
  final Key key;
  bool _loading = false;
  ScrollController _scrollController = new ScrollController();

  // Pagination
  static const _pageSize = 20;
  final PagingController<int, MatchCard> _pagingController =
    PagingController(firstPageKey: 0);

  _MyHistoryState({this.key});

  void _alertUser(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (_) => PlatformAlertDialog(
        title: Text(title,
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
        content: Text(content,
            style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w400, height: 1.5)),
        material: (_, __) => MaterialAlertDialogData(
          elevation: 1.0,
          actions: <Widget>[
            TextButton(
                child: Text("Close",
                    style: TextStyle(
                        color: AppColors.communityProfileOptionsBlueColor,
                        fontWeight: FontWeight.w600)),
                onPressed: () {
                  // Update user model is friend request sent successfully
                  Navigator.of(context).pop();
                }),
          ],
        ),
        cupertino: (_, __) => CupertinoAlertDialogData(actions: <Widget>[
          CupertinoButton(
            child: Text("Close",
                style: TextStyle(
                    color: AppColors.communityProfileOptionsBlueColor,
                    fontWeight: FontWeight.w600)),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ]),
      ),
      barrierDismissible: true,
    ).then((value) {});
  }

  Future<bool> _unmatchUser(MatchCard mc) async {
    var data = {"id": mc.id};
    try {
      var res = await MyHttp.post("/matches/unmatch/", data);
      if (res.statusCode == 200) {
        //Analytics code
        analytics.logEvent(
            name: "unmatched_user",
            parameters: <String, dynamic>{"user_id": mc.id});
        amplitudeAnalytics
            .logEvent('unmatched_user', eventProperties: {"user_id": mc.id});

        print("Remove User done");
        print(res.statusCode);
        _matchCard.remove(mc);
        _seperatingList(_matchCard);

        print(res.body);
        return true;
      } else {
        print(res.statusCode);
        return false;
      }
    } catch (e) {
      print("User not removed");
      print(e);
      return false;
    }
  }

  Future<bool> _UnlikeUser(MatchCard mc) async {
    print("Unlike user ${mc.id}");
    var data = {"id": mc.id};
    try {
      var res = await MyHttp.post("matches/unlike/", data);
      if (res.statusCode == 200) {
        //Analytics code
        analytics.logEvent(
            name: "unlike_user",
            parameters: <String, dynamic>{"user_id": mc.id});
        amplitudeAnalytics
            .logEvent('unlike_user', eventProperties: {"user_id": mc.id});

        print("Unlike User done");
        print(res.statusCode);
        print(res.body);
        _matchCard.remove(mc);
        _seperatingList(_matchCard);
        return true;
      }
    } catch (e) {
      print("User not removed");
      print(e);
      return false;
    }
  }

  Future<bool> _unsetMaybeUser(MatchCard mc) async {
    print("removing from maybe user ${mc.id}");
    var data = {"id": mc.id};
    try {
      var res = await MyHttp.post("matches/unmaybe/", data);
      if (res.statusCode == 201) {
        //Analytics code
        analytics.logEvent(
            name: "unsetMaybe_user",
            parameters: <String, dynamic>{"user_id": mc.id});
        amplitudeAnalytics
            .logEvent('unsetMaybe_user', eventProperties: {"user_id": mc.id});

        print("UnMaybe User done");
        print(res.statusCode);
        print(res.body);
        _matchCard.remove(mc);
        _seperatingList(_matchCard);
        return true;
      }
    } catch (e) {
      print("User not removed");
      print(e);
      return false;
    }
  }

  Future<bool> _setUserMaybe(MatchCard mc) async {
    print("chaaanging to maybe");
    print(mc.id);
    var data = {"id": mc.id};
    try {
      var res = await MyHttp.post("/matches/change-to-maybe", data);
      print(res.statusCode);
      if (res.statusCode == 201) {
        //Analytics code
        analytics.logEvent(
            name: "setMaybe_user",
            parameters: <String, dynamic>{"user_id": mc.id});
        amplitudeAnalytics
            .logEvent('setMaybe_user', eventProperties: {"user_id": mc.id});

        print("User changed to maybe");
        print(res.body);
        _matchCard.remove(mc);
        _seperatingList(_matchCard);
        return true;
      }
      return false;
    } catch (e) {
      print("User not removed");
      print(e);
      return false;
    }
  }

  void _likeCard(MatchCard m1) async {
    print("&&&&&&&&&&&&&&");
    m1.isLiked = true;
    for (int i = 0; i < _matchCard.length; i++) {
      MatchCard m2 = _matchCard[i];
      if (m1.id == m2.id) {
        _matchCard[i] = m1;
        break;
      }
    }
    _seperatingList(_matchCard);
    try {
      var data = {"id": m1.id};
      print(data);

      var res = await MyHttp.post("/matches/like/", data);

      if (res.statusCode == 201) {
        var body = json.decode(res.body);
        var chat = {};
        chat = body["chat"];

        print(chat);
        String message = body["message"];
        print(message);
        if (message == "New Match") {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ItsMutual(matchCard: m1, chat: chat)));
        } else {}
      } else {
        print("********");
        print(res.statusCode);
        print(res.body);
//        var card = {
//          "matchcard": widget.matchCard
//        };
//        Navigator.pop(context, card);

      }
    } catch (e) {
      print(e);
    }
  }

  Future<bool> _removeUser(MatchCard mc) async {
    print("removing user");
    print(mc.id);
    var data = {"id": mc.id};
    try {
      var res = await MyHttp.post("/matches/pass/", data);
      print(res.statusCode);
      if (res.statusCode == 201 || res.statusCode == 200) {
        //Analytics code
        analytics.logEvent(
            name: "removed_user",
            parameters: <String, dynamic>{"user_id": mc.id});
        amplitudeAnalytics
            .logEvent('removed_user', eventProperties: {"user_id": mc.id});

        print("User changed to maybe");
        print(res.body);
        _matchCard.remove(mc);
        _seperatingList(_matchCard);
        return true;
      }
      return false;
    } catch (e) {
      print("User not removed");
      print(e);
      return false;
    }
  }

  _getCard(MatchCard m1) {
    Widget iconcheck;
    if (widget.myHistoryPage == MyHistoryPage.MUTUAL) {
      iconcheck = MyButtons.getContainerForMatchCard(25, () {
        Global.alertUserForCardAction(
            context,
            "Unmatch",
            "Are you sure you want to Unmatch with ${m1.firstName}? Your message history will them will be archived until you mutually match again",
            "Unmatch",
            () {
              Navigator.of(context).pop(context);
              _unmatchUser(m1).then((isSuccess) {
                isSuccess
                    ? _alertUser(context, "Unmatch Successful",
                        "You no longer Matched with ${m1.firstName}")
                    : _alertUser(
                        context, "An error occurred", "Please try again!");
              });

              Navigator.of(context).pop();
            },
            "Report User",
            () {
              Navigator.of(context).pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ReasonReport(
                            otherUserId: m1.id,
                            onSuccessShowTab: tabs.match.index,
                          )));
            },
            "Cancel",
            () {
              Navigator.of(context).pop(context);
            });
      }, Icons.favorite, Colors.red[600], Color.fromRGBO(0, 0, 0, 0.5));
    } else if (widget.myHistoryPage == MyHistoryPage.LIKES) {
      iconcheck = MyButtons.getContainerForMatchCard(25, () {
        Global.alertUserForCardAction(
            context,
            "Unlike",
            "Are you sure you want to unlike ${m1.firstName}?",
            "Unlike",
            () {
              Navigator.of(context).pop(context);
              _UnlikeUser(m1).then((isSuccess) {
                isSuccess
                    ? _alertUser(context, "Unlike Successfully",
                        "You no longer like  ${m1.firstName}")
                    : _alertUser(
                        context, "An error occurred", "Please try again!");
              });
            },
            "Report User",
            () {
              Navigator.of(context).pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ReasonReport(
                            otherUserId: m1.id,
                            onSuccessShowTab: tabs.match.index,
                          )));
            },
            "Cancel",
            () {
              Navigator.of(context).pop(context);
            });
      }, Icons.favorite, Colors.red[600], Color.fromRGBO(0, 0, 0, 0.5));
    } else {
      // LIKED_ME, MAYBE, VIEWED_ME
      iconcheck = MyButtons.getContainerForMatchCard(25, () {
        if (!m1.isLiked && !m1.isPassed) {
          _likeCard(m1);
        }
      },
          (!m1.isLiked) ? Icons.favorite_border : Icons.favorite,
          (!m1.isLiked)
              ? Color.fromRGBO(236, 236, 236, 1)
              : Color.fromRGBO(255, 0, 74, 1),
          Color.fromRGBO(0, 0, 0, 0.5));
    }

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50.0),
      ),
      elevation: 5,
      child: Container(
        padding: EdgeInsets.all(8),
        color: Colors.white,
        child: InkWell(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => MatchUserProfile(
                          userId: m1.id,
                        )));
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Stack(
                children: <Widget>[
                  CachedNetworkImage(
                    imageUrl: m1.image,
                    placeholder: (context, url) => Container(
                      child: CircularProgressIndicator(),
                      height: 20.0,
                      width: 20.0,
                      margin: EdgeInsets.only(top: 30, right: 30, bottom: 30, left: 30),
                    ), 
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                  Container(
                    height: 25,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        (widget.myHistoryPage == MyHistoryPage.LIKES ||
                                widget.myHistoryPage == MyHistoryPage.MUTUAL)
                            ? Container()
                            : MyButtons.getContainerForMatchCard(25, () {
                                if (widget.myHistoryPage ==
                                    MyHistoryPage.LIKED_ME) {
                                  Global.alertUserForCardAction(
                                      context,
                                      "Remove",
                                      "Are you sure you want to remove ${m1.firstName}? This will remove ${(Global.gender.toLowerCase() == "woman") ? "him" : "her"} from your matches",
                                      "Remove",
                                      () {
                                        Navigator.of(context).pop(context);
                                        _removeUser(m1).then((isSuccess) {
                                          isSuccess
                                              ? _alertUser(context, "Removed",
                                                  " ${m1.firstName} has been removed from this section")
                                              : _alertUser(
                                                  context,
                                                  "An error occurred",
                                                  "Please try again!");
                                        });
                                      },
                                      "Change to Maybe",
                                      () {
                                        Navigator.of(context).pop(context);
                                        _setUserMaybe(m1).then((isSuccess) {
                                          isSuccess
                                              ? _alertUser(
                                                  context,
                                                  "Changed to Maybe",
                                                  "You can find ${m1.firstName} in Maybe section")
                                              : _alertUser(
                                                  context,
                                                  "An error occurred",
                                                  "Please try again!");
                                        });
                                      },
                                      "Cancel",
                                      () {
                                        Navigator.of(context).pop(context);
                                      });
                                }
                                if (widget.myHistoryPage ==
                                    MyHistoryPage.VIEWED_ME) {
                                  Global.alertUserForCardAction(
                                      context,
                                      "Remove",
                                      "Are you sure you want to remove ${m1.firstName}? This will remove ${(Global.gender.toLowerCase() == "woman") ? "him" : "her"} from your matches",
                                      "Remove",
                                      () {
                                        Navigator.of(context).pop(context);
                                        _removeUser(m1).then((isSuccess) {
                                          isSuccess
                                              ? _alertUser(context, "Removed",
                                                  " ${m1.firstName} has been removed from this section")
                                              : _alertUser(
                                                  context,
                                                  "An error occurred",
                                                  "Please try again!");
                                        });
                                      },
                                      "Change to Maybe",
                                      () {
                                        Navigator.of(context).pop(context);
                                        _setUserMaybe(m1).then((isSuccess) {
                                          isSuccess
                                              ? _alertUser(
                                                  context,
                                                  "Changed to Maybe",
                                                  "You can find ${m1.firstName} in Maybe section")
                                              : _alertUser(
                                                  context,
                                                  "An error occurred",
                                                  "Please try again!");
                                        });
                                      },
                                      "Cancel",
                                      () {
                                        Navigator.of(context).pop(context);
                                      });
                                }

                                if (widget.myHistoryPage ==
                                    MyHistoryPage.MAYBE) {
                                  Global.alertUserForCardAction(
                                      context,
                                      "Remove",
                                      "Are you sure you want to remove ${m1.firstName}? This will remove ${(Global.gender.toLowerCase() == "woman") ? "him" : "her"} from your matches",
                                      "Remove",
                                      () {
                                        Navigator.of(context).pop(context);
                                        _unsetMaybeUser(m1).then((isSuccess) {
                                          isSuccess
                                              ? _alertUser(context, "Removed",
                                                  " ${m1.firstName} has been removed from this section")
                                              : _alertUser(
                                                  context,
                                                  "An error occurred",
                                                  "Please try again!");
                                        });
                                      },
                                      "Report User",
                                      () {
                                        Navigator.of(context).pop(context);
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    ReasonReport(
                                                      otherUserId: m1.id,
                                                    )));
//                                              //report user
                                      },
                                      "Cancel",
                                      () {
                                        Navigator.of(context).pop(context);
                                      });
                                }

                                if (widget.myHistoryPage ==
                                    MyHistoryPage.LIKES) {}
                                if (widget.myHistoryPage ==
                                    MyHistoryPage.MUTUAL) {}
                              }, Icons.clear, Color.fromRGBO(236, 236, 236, 1),
                                Color.fromRGBO(0, 0, 0, 0.5)),
                        Spacer(),
                        iconcheck
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 5,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "${m1.firstName}, ${m1.age}",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text("${m1.location} | ${m1.heightInInches}"),
                  Text(m1.church),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _getData() async {
    setState(() {
      _loading = true;
    });
    print("******^^^^"); 

    dummy1 = [];
    dummy2 = [];
    try {
      String url;
      if (widget.myHistoryPage == MyHistoryPage.MUTUAL) {
        url = "/matches/all";
      } else if (widget.myHistoryPage == MyHistoryPage.LIKES) {
        url = "/matches/like";
      } else if (widget.myHistoryPage == MyHistoryPage.MAYBE) {
        url = "/matches/maybe";
      } else if (widget.myHistoryPage == MyHistoryPage.LIKED_ME) {
        url = "/matches/liked-me";
      } else if (widget.myHistoryPage == MyHistoryPage.VIEWED_ME) {
        url = "/matches/view";
      }
      print(url);
      var res = await MyHttp.get(url);
      print(res.statusCode);
      print(res.body);
      if (res.statusCode == 200) {
        var body = json.decode(res.body);
        print(body);
        var data = body["matches"] ??
            body["likes"] ??
            body["maybes"] ??
            body["users"] ??
            body["views"] as List<dynamic>;
        if (data != null && data.length > 0) {
          for (int i = 0; i < data.length; i++) {
            var d = data[i];
            int id = d["id"]; // na user id
            String firstName = d["first_name"];
            String image = d["ProfilePictureId"] ??
                "https://i.pinimg.com/564x/19/b8/d6/19b8d6e9b13eef23ec9c746968bb88b1.jpg";

            int age = d["age"] ?? 0; // na
            if (age == 0) {
              if (d["birthday"] == "Invalid date") {
                age = 24;
              } else {
                var formatter = new DateFormat('yyyy-MM-dd');
                String strBirthday = d["birthday"] ?? "";
                if (strBirthday != "") {
                  DateTime birthday = formatter.parse(strBirthday);
                  if (birthday != null) {
                    age = Global.calculateAge(birthday);
                  }
                }
              }
            }
            String location = d["location"] ?? "Chicago, IL";
            String height = d["height"] ?? "5 11"; // na
            String church = d["church"] ?? "The Church"; // na
            var m1 = MatchCard(id, image, firstName, age, location, height,
                church, false, false);
            var t = this._getCard(m1);

            _matchCard.add(m1);
            print(m1.id);
          }
          _seperatingList(_matchCard);
        }
        setState(() {
          _loading = false;
        });
        // Pagination
        _pagingController.addPageRequestListener((pageKey) {
          _fetchPage(pageKey);      
        });           
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final newItems = getMatchItems(pageKey, _pageSize);
      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + newItems.length;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }   

  List<MatchCard> getMatchItems(int pageKey, int pageSize) {
    if ((pageKey + pageSize) < _matchCard.length) {
      return _matchCard.sublist(pageKey, pageKey + pageSize);
    }
    return _matchCard.sublist(pageKey);
  }

  void _seperatingList(List<MatchCard> matchCard) {
    dummy1 = [];
    dummy2 = [];

    for (int i = 0; i < _matchCard.length; i++) {
      if (i % 2 == 0) {
        dummy1.add(_getCard(_matchCard[i]));
      } else {
        dummy2.add(_getCard(_matchCard[i]));
      }
    }

    setState(() {});
  }

  void _premiumStatus() async {
    try {
      var res = await MyHttp.get("/settings/member-status");
      if (res.statusCode == 200) {
        setState(() {
          Global.isPremium = true;
        });
      } else {
        //  print(res.statusCode);
        setState(() {
          Global.isPremium = false;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  void _checkFromPN() {
    if (widget.userId == null || widget.userId == 0) {
      return;
    }

    SchedulerBinding.instance.addPostFrameCallback((_) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => MatchUserProfile(
                    userId: widget.userId,
                  )));
    });
  }

  @override
  void initState() {
    _getData();
    // _addDummyData();
    _premiumStatus();
    _checkFromPN();

    super.initState();
    print('Im in my history page');
    //Initializing amplitude analytics api key
    amplitudeAnalytics.init(apiKey);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        //if we are in the buttom of the page
        //Here get the data tha you wanna get it and set it in array and call
        setState(() {});
      }
    });
  }

  Widget _buildItems() {
    double _sigmaX = 9.0; // from 0-10
    double _sigmaY = 9.0; // from 0-10
    double _opacity = 0.7;
    return Stack(
      children: <Widget>[
        Container(
          child: SingleChildScrollView(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: ListBody(
                    children: dummy1,
                  ),
                ),
                Expanded(
                  child: ListBody(
                    children: dummy2,
                  ),
                )
              ],
            ),
          ),
        ),
        (Global.isPremium)
            ? Container(
                height: 0,
                width: 0,
              )
            : (widget.myHistoryPage == MyHistoryPage.LIKED_ME ||
                    widget.myHistoryPage == MyHistoryPage.VIEWED_ME)
                ? ClipRect(
                    child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: _sigmaX, sigmaY: _sigmaY),
                    child: Container(
                      height: double.infinity,
                      width: double.infinity,
                      padding: EdgeInsets.all(10),
                      color: Colors.black.withOpacity(_opacity),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            "Upgrade to\nPure Match Premium\nto unlock this feature",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 36),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            padding: EdgeInsets.all(20),
                            child: MyButtons.getBorderedButton(
                                "Upgrade to Premium", AppColors.blueColor, () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Plan()));
                            }, true, borderRadius: 10),
                          )
                        ],
                      ),
                    ),
                  ))
                : Container(
                    height: 0,
                    width: 0,
                  )
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget getUserCard(int index) {
    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(15)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          FadeInImage.memoryNetwork(
            imageErrorBuilder: (_, object, stackTrace) {
              print(object);
              print(stackTrace);
              return Container();
            },
            placeholder: kTransparentImage,
            image: _matchCard[index].image,
            fit: BoxFit.cover,
          ),
          Container(
              child: Column(
            children: [
              Text('${_matchCard[index].firstName}, ${_matchCard[index].age}',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text(
                  '${_matchCard[index].location ?? ''} | ${_matchCard[index].heightInInches ?? ''}'),
              Text('${_matchCard[index].church ?? ''}'),
            ],
          ))
        ],
      ),
    );
  }

  Widget _gridView() {
    double _sigmaX = 9.0; // from 0-10
    double _sigmaY = 9.0; // from 0-10
    double _opacity = 0.7;
    return Stack(
      children: <Widget>[
        _matchCard.length == 0
            ? Container()
            : PagedGridView<int, MatchCard>(
                showNewPageProgressIndicatorAsGridChild: true,
                showNewPageErrorIndicatorAsGridChild: true,
                showNoMoreItemsIndicatorAsGridChild: true,
                pagingController: _pagingController,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  childAspectRatio: 100 / 150,
                  crossAxisSpacing: 3.0,
                  mainAxisSpacing: 3.0,
                  crossAxisCount: 2,
                ),
                builderDelegate: PagedChildBuilderDelegate<MatchCard>(
                  itemBuilder: (context, item, index) => new Container(
                      child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]),
                        color: Colors.transparent,
                        borderRadius: BorderRadius.all(Radius.circular(15))),
                    child: _getCard(_matchCard[index]),
                  )),
                ),
                padding: EdgeInsets.only(left: 3, right: 3),                
              ),
            
              // StaggeredGridView.countBuilder(
              //   controller: _scrollController,
              //   padding: EdgeInsets.only(left: 3, right: 3),
              //   crossAxisCount: 2,
              //   itemCount: _matchCard.length,
              //   itemBuilder: (BuildContext context, int index) => new Container(
              //       child: Container(
              //     decoration: BoxDecoration(
              //         border: Border.all(color: Colors.grey[300]),
              //         color: Colors.transparent,
              //         borderRadius: BorderRadius.all(Radius.circular(15))),
              //     child: _getCard(_matchCard[index]),
              //   )),
              //   staggeredTileBuilder: (index) {
              //     return StaggeredTile.count(1, index.isEven ? 1.4 : 1.4);
              //   },
              //   mainAxisSpacing: 3.0,
              //   crossAxisSpacing: 3.0,
              // ),
        (Global.isPremium)
            ? Container(
                height: 0,
                width: 0,
              )
            : (widget.myHistoryPage == MyHistoryPage.LIKED_ME ||
                    widget.myHistoryPage == MyHistoryPage.VIEWED_ME)
                ? ClipRect(
                    child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: _sigmaX, sigmaY: _sigmaY),
                    child: Container(
                      height: double.infinity,
                      width: double.infinity,
                      padding: EdgeInsets.all(10),
                      color: Colors.black.withOpacity(_opacity),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            "Upgrade to\nPure Match Premium\nto unlock this feature",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 36),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            padding: EdgeInsets.all(20),
                            child: MyButtons.getBorderedButton(
                                "Upgrade to Premium", AppColors.blueColor, () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Plan()));
                            }, true, borderRadius: 10),
                          )
                        ],
                      ),
                    ),
                  ))
                : Container(
                    height: 0,
                    width: 0,
                  )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: (_loading == true) ? Loading.showLoading() : _gridView());
  }
}
