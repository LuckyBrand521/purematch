import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:pure_match/common/MyButtons.dart';
import 'package:pure_match/common/global.dart';
import 'package:pure_match/common/snackbar.dart';
import 'package:pure_match/common/triangle2.dart';
import 'package:pure_match/common/triangle3.dart';
import 'package:pure_match/models/match_card.dart';
import 'package:pure_match/pages/AppColors.dart';
import 'package:pure_match/pages/MyHttp.dart';
import 'package:pure_match/pages/match/its_mutual.dart';
import 'package:flutter_tindercard/flutter_tindercard.dart';
import 'package:pure_match/pages/match/match_user_profile.dart';
import 'package:amplitude_flutter/amplitude.dart';
import 'package:pure_match/pages/onboarding/profile_info/user_dating_preference.dart';
import 'package:pure_match/pages/rewards/plan.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';

class MatchProfile extends StatefulWidget {
  final List<MatchCard> matchCards;
  final Function(List<MatchCard>) goBackWithCards;
  MatchProfile({Key key, @required this.matchCards, this.goBackWithCards})
      : super(key: key);
  @override
  _MatchProfileState createState() => _MatchProfileState();
}

class _MatchProfileState extends State<MatchProfile> {
  // Analytics code
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';
  var lat;
  var long;
  MatchCard mc;
  // int i = 0;
  List<MatchCard> removedCards;
  var isFirstTime;
  int next = 0;
  bool _loading = false;
  void _onRightSwipe() async {
    if (widget.matchCards.length == 0) {
      return;
    }
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate();
    }

    print("right click");
    MatchCard m1 = widget.matchCards[0];
    m1.isLiked = true;
    widget.matchCards[0] = m1;
    setState(() {});
    print("&&&&&&&&&&&&&&");
    try {
      var data = {"id": m1.id};
      print(data);

      var res = await MyHttp.post("/matches/like/", data);
      print("********");
      print(res.statusCode);
      print(res.body);
      if (res.statusCode == 201) {
        var body = json.decode(res.body);
        var chat = {};
        chat = body["chat"];
        widget.matchCards.removeAt(0);

        print(chat);
        String message = body["message"];
        print(message);
        if (message == "New Match") {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ItsMutual(matchCard: m1, chat: chat)));
        } else {
//          var card = {
//            "matchcard": widget.matchCards[index].id
//          };
//          Navigator.pop(context, card);

        }
        _setMatchCount(true);
      } else {
//        var card = {
//          "matchcard": widget.matchCard
//        };
//        Navigator.pop(context, card);

      }
    } catch (e) {
      print(e);
    }
  }

//  void _onMutualMatch() async{
//    print("&&&&&&&&&&&&&&");
//    try{
//      var res = await MyHttp.get("/matches/mutual-match/${widget.matchCard.id}");
//      print(res.statusCode);
//      print(res.body);
//      if(res.statusCode == 200){
//        Navigator.push(
//            context,
//            MaterialPageRoute(
//                builder: (context) => ItsMutual(matchCard: )
//            ));
//      }else if(res.statusCode==404){
//        print("no mutual match");
//
//      }
//    }catch(e){
//      print(e);
//    }
//  }

  Future<bool> _setUserMaybe() async {
    if (widget.matchCards.length == 0) {
      return false;
    }
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate();
    }

    MatchCard m1 = widget.matchCards[0];
    m1.isLiked = true;
    widget.matchCards[0] = m1;
    setState(() {});
    var data = {"id": m1.id};
    try {
      var res = await MyHttp.post("/matches/maybe/", data);
      if (res.statusCode == 201) {
        print("User changed to maybe");
        print(res.body);
        widget.matchCards.removeAt(0);
        if (this.mounted) {
          _setMatchCount(true);
        }

        return true;
      }
      return false;
    } catch (e) {
      print("User not removed");
      print(e);
      return false;
    }
  }

  Future<bool> _onLeftSwipe() async {
    if (widget.matchCards.length == 0) {
      return false;
    }
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate();
    }

    MatchCard m1 = widget.matchCards[0];
    m1.isPassed = true;
    widget.matchCards[0] = m1;
    setState(() {});
    try {
      var data = {"id": m1.id};
      var res = await MyHttp.post("/matches/pass", data);
      print(res.statusCode);
      print(res.body);
      if (res.statusCode == 200) {
        widget.matchCards.removeAt(0);
        _setMatchCount(true);

        return true;
      }
      print(res.statusCode);
      print(res.body);
      return false;
    } catch (e) {
      print(e);
      return false;
    }
  }

  String _getTimerCount() {
    int hour = (_start / 3600).toInt();
    int min = ((_start - 3600 * hour) / 60).toInt();
    int sec = (_start - 3600 * hour - 60 * min).toInt();
    String sHour = (hour >= 10) ? hour.toString() : "0" + hour.toString();
    String sMin = (min >= 10) ? min.toString() : "0" + min.toString();
    String sSec = (sec >= 10) ? sec.toString() : "0" + sec.toString();
    return "${sHour}:${sMin}:${sSec}";
  }

  @override
  void dispose() {
    if (_timer != null) {
      _timer.cancel();
    }
    super.dispose();
  }

  Future<void> _setMatchCount(bool isAdded) async {
    var sp = await SharedPreferences.getInstance();
    if (Global.isPremium) {
      Global.match_count1 = 0;
      sp.remove("match_count");
      sp.remove("match_time");
      if (_timer != null) {
        _timer.cancel();
      }
      this._loadingToggle(state: false);
      return;
    }

    int match_count = sp.getInt("match_count");
    if (match_count != null) {
      if (isAdded) {
        match_count++;
      }
    } else {
      if (isAdded) {
        match_count = 1;
      } else {
        match_count = 0;
      }
    }

    if (Global.match_count_daily - match_count <= 0) {
      String strMatch_time = sp.getString("match_time");
      if (strMatch_time == null) {
        String date = DateFormat("yyyy-MM-dd kk:mm:ss").format(DateTime.now());
        sp.setString("match_time", date);
      }
      String date = sp.getString("match_time");
      DateTime match_time = DateTime.parse(date);

      String date1 = DateFormat("yyyy-MM-dd kk:mm:ss").format(DateTime.now());
      DateTime now = DateTime.parse(date1);

      Duration timeDiff = now.difference(match_time);
      int nDiff = 24 * 3600 -
          // int nDiff = 200 -
          (timeDiff.inHours * 3600 +
              timeDiff.inMinutes * 60 +
              timeDiff.inSeconds);
      if (nDiff > 0) {
        _start = nDiff;
        startTimer();
      } else {
        match_count = 0;
        sp.remove("match_count");
        sp.remove("match_time");
      }
    }
    print("match_count=${match_count}");
    sp.setInt("match_count", match_count);
    Global.match_count1 = match_count;
    this._loadingToggle(state: false);
  }

  Timer _timer;
  int _start = 10;

  _cancelTimer() async {
    _timer.cancel();
    var sp = await SharedPreferences.getInstance();

    Global.match_count1 = 0;
    sp.remove("match_count");
    sp.remove("match_time");
    setState(() {});
  }

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_start == 0) {
          _cancelTimer();
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
  }

  getInit() async {
    tutorialPage();
    this._loadingToggle(state: true);
    await _premiumStatus();
    await _setMatchCount(false);
  }

  @override
  void initState() {
    getInit();
    super.initState();

    // Analytics tracking code
    amplitudeAnalytics.init(apiKey);
    analytics.setCurrentScreen(
        screenName: "match_profile", screenClassOverride: "match_profile");
    amplitudeAnalytics.logEvent("match_profile_page");
  }

  void tutorialPage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isFirstTime = prefs.getBool('tutorial_card_first_time');
    if (isFirstTime != null && !isFirstTime) {
      print("not first time");
      prefs.setBool('tutorial_card_first_time', false);
    } else {
      isFirstTime = true;
      print("first time app runn!!!");
      prefs.setBool('tutorial_card_first_time', false);
    }

    setState(() {});
  }

  void onSaveMatchPreferences() {
    Timer(Duration(milliseconds: 300), () {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBarUi.SuccessSnackBar(message: "Match preferences are saved!")
      );
    });    
    _getLocation(context);
  }

  void _loadingToggle({bool state}) {
    if (state == null) {
      state = !this._loading;
    }
    setState(() {
      _loading = state;
    });
  }

  void _getLocation(BuildContext context) async {
    this._loadingToggle();
    Location location = new Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        final snackBar = SnackBar(content: Text('Location service not found!'));
        Scaffold.of(context).showSnackBar(snackBar);
        this._loadingToggle(state: false);
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        final snackBar =
            SnackBar(content: Text('Location permission not granted.'));
        Scaffold.of(context).showSnackBar(snackBar);
        this._loadingToggle(state: false);
        return;
      }
    }

    _locationData = await location.getLocation();
    print(_locationData);
    lat = _locationData.latitude;
    long = _locationData.longitude;

    // final coordinates = new Coordinates(lat, long);
    // var addresses =
    //     await Geocoder.local.findAddressesFromCoordinates(coordinates);

    // var first = addresses.first;
    // var locationTxt = "${first.locality}, ${first.adminArea}";
    // print(locationTxt);

    // double lat1 = 37.785834;
    // double long1 = -122.406417;
    // lat = lat1;
    // long = long1;

    this._getMatchCard();
  }

  void _premiumStatus() async {
    try {
      var res = await MyHttp.get("/settings/member-status");
      if (res.statusCode == 200) {
        Global.isPremium = true;
      } else {
        //  print(res.statusCode);
        Global.isPremium = false;
      }
    } catch (e) {
      print(e);
    }
  }

  void _getMatchCard() async {
    widget.matchCards.clear();
    try {
      print("*************");
      var data = {"latitude": lat, "longitude": long};
      print(data);
      var res = await MyHttp.put("/matches/potential-matches", data);
      if (res.statusCode == 200) {
        var jsonData = jsonDecode(res.body);

        var pMatches = jsonData["pMatches"];
        print("********potential matches********");
        print(pMatches);

        for (var u in pMatches) {
          mc = MatchCard.fromJson(u);
          //  this._getCard(mc);
          widget.matchCards.add(mc);
        }
        print("****printing match cards list*****");
        print(widget.matchCards);
      } else {
        print(res.statusCode);
        print("error");
        print(res.body);
      }
    } catch (e) {
      // print("Err $e");
      throw new Exception("error");
    }
    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double _sigmaX = 9.0; // from 0-10
    double _sigmaY = 9.0; // from 0-10
    double _opacity = 0.7;
    var width = MediaQuery.of(context).size.width;
    CardController controller;
    return Scaffold(
      backgroundColor: AppColors.greyColor,
      appBar: AppBar(
        leading: PlatformIconButton(
          icon: Image.asset(
            "assets/images/window.png",
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
            widget.goBackWithCards(widget.matchCards);
          },
        ),
        backgroundColor: AppColors.redColor,
        title: Text(
          "Pure Match",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.w600, fontSize: 24),
        ),
      ),
      body: SafeArea(
        child: (this._loading)
            ? this._showLoading()
            : !widget.matchCards.isEmpty
                ? Stack(                  
                  children: [
                    Column(
                      children: <Widget>[
                        Expanded(
                          child: Stack(
                            alignment: AlignmentDirectional.center,
                            children: widget.matchCards.sublist(0, 2).reversed.map((matchCard) => 
                              Positioned(
                                top: 0.3 * matchCard.age,
                                bottom: 0.3 * matchCard.age,
                                left: 0.3 * matchCard.age,
                                right: 0.3 * matchCard.age,
                                child: Card(
                                  shadowColor: Colors.black.withOpacity(0.5),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  MatchUserProfile(
                                                    userId: matchCard.id,
                                                  )));
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(8),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          CachedNetworkImage(
                                            height: (AppConfig.fullHeight(
                                                        context) >=
                                                    667)
                                                ? (AppConfig.fullHeight(
                                                            context) /
                                                        2.6)
                                                    .toDouble()
                                                : 165,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                40,
                                            imageUrl: matchCard.image ??
                                                "https://www.google.com/imgres?imgurl=https%3A%2F%2Fath2.unileverservices.com%2Fwp-content%2Fuploads%2Fsites%2F8%2F2019%2F02%2Fman-ponytail-low-tail-shutterstock-500x500.jpg&imgrefurl=https%3A%2F%2Fwww.allthingshair.com%2Fen-ph%2Fmens-hairstyles-haircuts%2Fmens-hairstyle-trends%2Fman-ponytail%2F&tbnid=GPvC4KEIBdV_xM&vet=12ahUKEwjHhZGSmoXpAhVT_awKHd4TASIQMygEegUIARD_AQ..i&docid=QAubuUzCBZeT5M&w=500&h=500&q=man%20image%20500x500&client=safari&ved=2ahUKEwjHhZGSmoXpAhVT_awKHd4TASIQMygEegUIARD_AQ",
                                            errorWidget:
                                                (context, url, error) =>
                                                    Icon(Icons.error),
                                          ),
                                          Text(
                                            "${matchCard.firstName}, ${matchCard.age} ",
                                            style: TextStyle(
                                                fontSize: AppConfig
                                                    .fontsizeForSmallDevice(
                                                        context, 30),
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                              "${matchCard.location} | ${matchCard.heightInInches}",
                                              style: TextStyle(
                                                  fontSize: AppConfig
                                                      .fontsizeForSmallDevice(
                                                          context, 20))),
                                          Text(
                                              "${matchCard.church}",
                                              style: TextStyle(
                                                  fontSize: AppConfig
                                                      .fontsizeForSmallDevice(
                                                          context, 20))),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                            ).toList(),
                          ),

                          // AbsorbPointer(
                          //   absorbing: false,
                          //   child: TinderSwapCard(
                          //     orientation: AmassOrientation.LEFT,
                          //     maxWidth: MediaQuery.of(context).size.width - 20,
                          //     maxHeight: (AppConfig.fullWidth(context) >= 375)
                          //         ? MediaQuery.of(context).size.height * 0.7
                          //         : MediaQuery.of(context).size.height * 0.9,
                          //     minWidth: MediaQuery.of(context).size.width - 30,
                          //     minHeight:
                          //         MediaQuery.of(context).size.height * 0.5,
                          //     swipeEdge: 4.0,
                          //     totalNum: widget.matchCards.length,
                          //     cardBuilder: (context, index) {
                          //       return Card(
                          //         shape: RoundedRectangleBorder(
                          //             borderRadius: BorderRadius.circular(10)),
                          //         child: InkWell(
                          //           onTap: () {
                          //             Navigator.push(
                          //                 context,
                          //                 MaterialPageRoute(
                          //                     builder: (context) =>
                          //                         MatchUserProfile(
                          //                           userId: widget
                          //                               .matchCards[index].id,
                          //                         )));
                          //           },
                          //           child: Container(
                          //             padding: EdgeInsets.all(8),
                          //             child: Column(
                          //               crossAxisAlignment:
                          //                   CrossAxisAlignment.start,
                          //               children: <Widget>[
                          //                 CachedNetworkImage(
                          //                   height: (AppConfig.fullHeight(
                          //                               context) >=
                          //                           667)
                          //                       ? (AppConfig.fullHeight(
                          //                                   context) /
                          //                               2.6)
                          //                           .toDouble()
                          //                       : 165,
                          //                   width: MediaQuery.of(context)
                          //                           .size
                          //                           .width -
                          //                       40,
                          //                   imageUrl: widget
                          //                           .matchCards[index].image ??
                          //                       "https://www.google.com/imgres?imgurl=https%3A%2F%2Fath2.unileverservices.com%2Fwp-content%2Fuploads%2Fsites%2F8%2F2019%2F02%2Fman-ponytail-low-tail-shutterstock-500x500.jpg&imgrefurl=https%3A%2F%2Fwww.allthingshair.com%2Fen-ph%2Fmens-hairstyles-haircuts%2Fmens-hairstyle-trends%2Fman-ponytail%2F&tbnid=GPvC4KEIBdV_xM&vet=12ahUKEwjHhZGSmoXpAhVT_awKHd4TASIQMygEegUIARD_AQ..i&docid=QAubuUzCBZeT5M&w=500&h=500&q=man%20image%20500x500&client=safari&ved=2ahUKEwjHhZGSmoXpAhVT_awKHd4TASIQMygEegUIARD_AQ",
                          //                   errorWidget:
                          //                       (context, url, error) =>
                          //                           Icon(Icons.error),
                          //                 ),
                          //                 Text(
                          //                   "${widget.matchCards[index].firstName}, ${widget.matchCards[index].age} ",
                          //                   style: TextStyle(
                          //                       fontSize: AppConfig
                          //                           .fontsizeForSmallDevice(
                          //                               context, 30),
                          //                       fontWeight: FontWeight.bold),
                          //                 ),
                          //                 Text(
                          //                     "${widget.matchCards[index].location} | ${widget.matchCards[index].heightInInches}",
                          //                     style: TextStyle(
                          //                         fontSize: AppConfig
                          //                             .fontsizeForSmallDevice(
                          //                                 context, 20))),
                          //                 Text(
                          //                     "${widget.matchCards[index].church}",
                          //                     style: TextStyle(
                          //                         fontSize: AppConfig
                          //                             .fontsizeForSmallDevice(
                          //                                 context, 20))),
                          //               ],
                          //             ),
                          //           ),
                          //         ),
                          //       );
                          //     },
                          //     //   animDuration: 10,
                          //     cardController: controller = CardController(),
                          //     swipeUpdateCallback:
                          //         (DragUpdateDetails details, Alignment align) {
                          //       /// Get swiping card's alignment
                          //       if (align.x < 0) {
                          //         //Card is LEFT swiping
                          //         print("card is left swiping");
                          //         Image.asset("assets/images/church_icon.png");
                          //       } else if (align.x > 0) {
                          //         //Card is RIGHT swiping
                          //         print("card is right swiping");
                          //         Image.asset("assets/images/cross_icon.png");
                          //       }
                          //     },
                          //     swipeCompleteCallback:
                          //         (CardSwipeOrientation orientation,
                          //             int index) {
                          //       print(orientation.toString());
                          //       if (orientation == CardSwipeOrientation.LEFT) {
                          //         print(widget.matchCards.length);
                          //         print("Card is LEFT swiping");
                          //         _onLeftSwipe();
                          //         print(widget.matchCards.length);
                          //       } else if (orientation ==
                          //           CardSwipeOrientation.RIGHT) {
                          //         print("Card is RIGHT swiping");
                          //         _onRightSwipe();
                          //       }
                          //       if (orientation ==
                          //           CardSwipeOrientation.RECOVER) {
                          //         print("Card is RECOVER");
                          //       }
                          //     }),
                          // )
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            InkWell(
                              onTap: () {
                                _onLeftSwipe();
                                //Analytics tracking code
                                analytics.logEvent(
                                    name: "deleted_match",
                                    parameters: <String, dynamic>{
                                      'user': widget.matchCards[0].id
                                    });

                                amplitudeAnalytics.logEvent("deleted_match",
                                    eventProperties: {
                                      'user': widget.matchCards[0].id
                                    });

                                print(widget.matchCards.length);
                              },
                              child: Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(100),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.5),
                                      spreadRadius: 0,
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.clear,
                                  color: AppColors.offWhiteColor,
                                  size: 50,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                _setUserMaybe();
                                //Analytics tracking code
                                analytics.logEvent(
                                    name: "maybe_match",
                                    parameters: <String, dynamic>{
                                      'user': widget.matchCards[0].id
                                    });
                                amplitudeAnalytics.logEvent("maybe_match",
                                    eventProperties: {
                                      'user': widget.matchCards[0].id
                                    });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(100),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.5),
                                      spreadRadius: 0,
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                padding: EdgeInsets.all(17),
                                child: SizedBox(
                                  width: 40,
                                  height: 40,
                                  child: Image.asset(
                                      "assets/images/maybe_icon.png"),
                                ),
                                // Icon(
                                //   Image.asset("assets/images/church_icon.png"),
                                //   color: AppColors.matchMaybeColor,
                                //   size: 50,
                                // ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                _onRightSwipe();
                                //Analytics tracking code
                                analytics.logEvent(
                                    name: "liked_match",
                                    parameters: <String, dynamic>{
                                      'user': widget.matchCards[0].id
                                    });
                                amplitudeAnalytics.logEvent("liked_match",
                                    eventProperties: {
                                      'user': widget.matchCards[0].id
                                    });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(100),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.5),
                                      spreadRadius: 0,
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                padding: EdgeInsets.all(12),
                                child: Icon(
                                  Icons.favorite,
                                  color: AppColors.redColor,
                                  size: 50,
                                ),
                              ),
                            )
                          ],
                        ),
                        SizedBox(height: 90),
                      ],
                    ),
                    (isFirstTime == true && next == 0)
                        ? Padding(
                            padding: EdgeInsets.only(top: 10),
                            child: Stack(children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  width:
                                      MediaQuery.of(context).size.width / 2.2,
                                  height: 200,
                                  padding: EdgeInsets.symmetric(
                                      vertical: 2.0, horizontal: 5),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: FittedBox(
                                    child: Column(
                                      children: [
                                        Text(
                                          "This will switch you to\n'Tile View'\nto quickly scroll through\npotential match!",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 20),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        ButtonTheme(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 8.0,
                                              horizontal:
                                                  18.0), //adds padding inside the button
                                          materialTapTargetSize:
                                              MaterialTapTargetSize
                                                  .shrinkWrap, //limits the touch area to the button area
                                          minWidth: 0, //wraps child's width
                                          height: 0,
                                          child: FlatButton(
                                            onPressed: () {
                                              next++;
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
                                                  color: Colors.white,
                                                  fontSize: 20),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                  right: MediaQuery.of(context).size.width /
                                      (1 * 2.3),
                                  top: 10,
                                  child: this._triangle()),
                            ]),
                          )
                        : Container(),
                    (isFirstTime == true && next == 1)
                        ? Positioned(
                            right: 50,
                            bottom: 170,
                            child: Stack(children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  width:
                                      MediaQuery.of(context).size.width / 2.2,
                                  height: 200,
                                  padding: EdgeInsets.symmetric(
                                      vertical: 2.0, horizontal: 5),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: FittedBox(
                                    child: Column(
                                      children: [
                                        Text(
                                          "Press the ♥ button\n or swipe right if\n you like the person",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 20),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        ButtonTheme(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 8.0,
                                              horizontal:
                                                  18.0), //adds padding inside the button
                                          materialTapTargetSize:
                                              MaterialTapTargetSize
                                                  .shrinkWrap, //limits the touch area to the button area
                                          minWidth: 0, //wraps child's width
                                          height: 0,
                                          child: FlatButton(
                                            onPressed: () {
                                              next++;
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
                                                  color: Colors.white,
                                                  fontSize: 15),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                  right: MediaQuery.of(context).size.width /
                                      (11 * 1),
                                  bottom: -1,
                                  child: this._triangle2()),
                            ]),
                          )
                        : Container(),
                    (isFirstTime == true && next == 2)
                        ? Positioned(
                            right: 30,
                            bottom: 170,
                            child: Stack(children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  width:
                                      MediaQuery.of(context).size.width / 2.0,
                                  height: 150,
                                  padding: EdgeInsets.symmetric(
                                      vertical: 2.0, horizontal: 5),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: FittedBox(
                                    child: Column(
                                      children: [
                                        Text(
                                          "Press the ? button\n or swipe up if you're\n unsure about the person",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 20),
                                        ),

                                        //

                                        SizedBox(
                                          height: 10,
                                        ),
                                        ButtonTheme(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 8.0,
                                              horizontal:
                                                  18.0), //adds padding inside the button
                                          materialTapTargetSize:
                                              MaterialTapTargetSize
                                                  .shrinkWrap, //limits the touch area to the button area
                                          minWidth: 0, //wraps child's width
                                          height: 0,
                                          child: FlatButton(
                                            onPressed: () {
                                              next++;
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
                                                  color: Colors.white,
                                                  fontSize: 15),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                  right: MediaQuery.of(context).size.width /
                                      (3 * 1),
                                  bottom: -1,
                                  child: this._triangle2()),
                            ]),
                          )
                        : Container(),
                    (isFirstTime == true && next == 3)
                        ? Positioned(
                            right: width / 2.3,
                            bottom: 170,
                            child: Stack(children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  width:
                                      MediaQuery.of(context).size.width / 2.0,
                                  height: 150,
                                  padding: EdgeInsets.symmetric(
                                      vertical: 2.0, horizontal: 5),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: FittedBox(
                                    child: Column(
                                      children: [
                                        Text(
                                          "Press the X button\n or swipe left if you\ndont like the person",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 15),
                                        ),

                                        //

                                        SizedBox(
                                          height: 10,
                                        ),
                                        ButtonTheme(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 8.0,
                                              horizontal:
                                                  18.0), //adds padding inside the button
                                          materialTapTargetSize:
                                              MaterialTapTargetSize
                                                  .shrinkWrap, //limits the touch area to the button area
                                          minWidth: 0, //wraps child's width
                                          height: 0,
                                          child: FlatButton(
                                            onPressed: () {
                                              next++;
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
                                                  color: Colors.white,
                                                  fontSize: 10),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                  right: MediaQuery.of(context).size.width /
                                      (3 * 1),
                                  bottom: -1,
                                  child: this._triangle2()),
                            ]),
                          )
                        : Container(),
                    (!Global.isPremium &&
                            Global.match_count1 >= Global.match_count_daily)
                        ? ClipRect(
                            child: BackdropFilter(
                            filter: ImageFilter.blur(
                                sigmaX: _sigmaX, sigmaY: _sigmaY),
                            child: Container(
                              height: double.infinity,
                              width: double.infinity,
                              padding: EdgeInsets.all(10),
                              color: Colors.black.withOpacity(_opacity),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    "You’ve reached your daily limit\nfor browsing Matches!",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize:
                                            AppConfig.fontsizeForSmallDevice(
                                                context, 20)),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(
                                    height: AppConfig.fontsizeForSmallDevice(
                                        context, 14),
                                  ),
                                  Container(
                                    padding: EdgeInsets.all(20),
                                    child: MyButtons.getBorderedButton(
                                        "Upgrade to Premium",
                                        AppColors
                                            .matchBrowseMatchReactivateMatching,
                                        () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => Plan()));
                                    }, true, borderRadius: 10),
                                  ),
                                  SizedBox(
                                    height: AppConfig.fontsizeForSmallDevice(
                                        context, 14),
                                  ),
                                  Text(
                                    "Upgrade to Premium to see more\nthan 10 Matches a day,\nor check back in",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize:
                                            AppConfig.fontsizeForSmallDevice(
                                                context, 20)),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(
                                    height: AppConfig.fontsizeForSmallDevice(
                                        context, 14),
                                  ),
                                  Text(
                                    _getTimerCount(),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize:
                                          AppConfig.fontsizeForSmallDevice(
                                              context, 20),
                                    ),
                                  ),
                                  // _getTimerCount
                                ],
                              ),
                            ),
                          ))
                        : Container(),
                  ])
                : Center(
                    child: Stack(
                      children: [
                        FittedBox(
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Text(
                                  "No potential matches found with current filters.\nTry changing your match preferences\nto include more options.",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      height: 1.5),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              FlatButton(
                                  onPressed: () {
                                    // Navigator.push(
                                    //     context,
                                    //     MaterialPageRoute(
                                    //         builder: (context) =>
                                    //             EditMatchSettings()));
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => UserDatingPreference(
                                                userDatingPreferencesPageType:
                                                    UserDatingPreferencesPageType
                                                        .SETTINGS,
                                                onSaveContinue:
                                                    onSaveMatchPreferences)));
                                  },
                                  child: Text(
                                    "Change Match Settings",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: AppColors.redColor,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ))
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _triangle() {
    return CustomPaint(
      painter: Triangle2(Colors.black),
    );
  }

  Widget _triangle2() {
    return CustomPaint(
      painter: Triangle3(Colors.black),
    );
  }

  Container _showLoading() {
    return Container(
      height: double.infinity,
      child: Center(
        child: PlatformCircularProgressIndicator(),
      ),
    );
  }
}
