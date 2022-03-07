import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:ui';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:pure_match/common/MyButtons.dart';
import 'package:pure_match/common/global.dart';
import 'package:pure_match/common/snackbar.dart';
import 'package:pure_match/common/triangle.dart';
import 'package:pure_match/models/match_card.dart';
import 'package:pure_match/pages/AppColors.dart';
import 'package:pure_match/pages/MyHttp.dart';
import 'package:pure_match/pages/feed/limited_card.dart';
import 'package:pure_match/pages/match/its_mutual.dart';
import 'package:pure_match/pages/match/match_profile.dart';
import 'package:pure_match/pages/match/match_user_profile.dart';
import 'package:pure_match/pages/match/my_history_base.dart';
import 'package:amplitude_flutter/amplitude.dart';
import 'package:pure_match/pages/onboarding/profile_info/user_dating_preference.dart';
import 'package:pure_match/pages/settings/privacy_settings.dart';
import 'package:pure_match/pages/settings/settings_main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

class BrowseMatch extends StatefulWidget {
  int userId;
  // For post PN
  String matchType;
  BrowseMatch({userId, matchType}) {
    this.userId = userId;
    this.matchType = matchType;
  }
  @override
  _BrowseMatchState createState() => _BrowseMatchState();
}

class _BrowseMatchState extends State<BrowseMatch> {
  // Analytics code
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';

  List<MatchCard> _matchCards = [];
  List<Widget> cardListAfterMakingWidget = [];
  bool _loading = false;
  MatchCard mc;
  var lat;
  var long;
  int next = 0;
  int pageCount = 0;
  var isFirstTime;

  Map<String, dynamic> privacySettings;

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

  void onSaveMatchPreferences() {
    Timer(Duration(milliseconds: 300), () {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBarUi.SuccessSnackBar(message: "Match preferences are saved!")
      );
    });
    _getLocation(context);
  }

  Future<void> _getPriSettings() async {
    var res = await MyHttp.get("settings/privacy_settings");
    var json = jsonDecode(res.body);

    privacySettings = json["user"]["PrivacySetting"] as Map<String, dynamic>;
    // match_premium_visible = privacySettings["match_premium_visible"];
    print("Privacy setting $privacySettings");
    Global.matching_active = privacySettings["matching_active"];
  }

  void _getLocation(BuildContext context) async {
    _getPriSettings();
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
        if (this.mounted) {
          setState(() {});
        }

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
        if (this.mounted) {
          setState(() {});
        }

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
    //
    // var first = addresses.first;
    // var locationTxt = "${first.locality}, ${first.adminArea}";
    // print(locationTxt);

    // double lat1 = 34.182424132244975;
    // double long1 = -118.54756423282491;
    // lat = lat1;
    // long = long1;

    if (this.mounted) {
      setState(() {});
    }

    await this._getMatchCard();
  }

  void tutorialPage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isFirstTime = prefs.getBool('tutorial_first_time');
    if (isFirstTime != null && !isFirstTime) {
      print("not first time");
      prefs.setBool('tutorial_first_time', false);
    } else {
      isFirstTime = true;
      print("first time app runn!!!");
      prefs.setBool('tutorial_first_time', false);
    }
  }

  void _premiumStatus() async {
    try {
      var res = await MyHttp.get("/settings/member-status");
      if (res.statusCode == 200) {
        if (this.mounted) {
          setState(() {
            Global.isPremium = true;
          });
        }
      } else {
        if (this.mounted) {
          setState(() {
            Global.isPremium = false;
          });
        }
      }
    } catch (e) {
      print(e);
    }
  }

  void _getMatchCount() async {
    var sp = await SharedPreferences.getInstance();
    if (Global.isPremium) {
      Global.match_count1 = 0;
      sp.remove("match_count");
      sp.remove("match_time");
      return;
    }
    int match_count = sp.getInt("match_count");
    if (match_count == null) {
      Global.match_count1 = 0;
    } else {
      Global.match_count1 = match_count ?? 0;
    }

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
    } else {
      match_count = 0;
      sp.remove("match_count");
      sp.remove("match_time");
      _getMatchCount();
    }
  }

  Future<void> _setMatchCount() async {
    var sp = await SharedPreferences.getInstance();
    if (Global.isPremium) {
      Global.match_count1 = 0;
      sp.remove("match_count");
      sp.remove("match_time");
      return;
    }

    int match_count = sp.getInt("match_count");
    if (match_count != null) {
      match_count++;
    } else {
      match_count = 1;
    }

    print("match_count=${match_count}");
    sp.setInt("match_count", match_count);
    Global.match_count1 = match_count;
  }

  int _start = 10;


  void _getMatchCard() async {
    _matchCards.clear();
    cardListAfterMakingWidget.clear();
    try {
      var data = {"latitude": lat, "longitude": long};
      var res = await MyHttp.put("/matches/potential-matches", data);
      if (res.statusCode == 200) {
        var jsonData = jsonDecode(res.body);        
        _matchCards = jsonData["pMatches"].map<MatchCard>((obj) => MatchCard.fromJson(obj)).toList();   
        // jsonData['pMatches'].forEach((obj) => print(obj['proximity'])); 
        // jsonData['pMatches'].forEach((obj) => print(obj['age'])); 
        // jsonData['pMatches'].forEach((obj) => print(obj['ageDelta'])); 
        _seperatingList(_matchCards);
      } else {
        print(res.body);
      }
    } catch (e) {
      print("Err $e");
      throw new Exception("error");
    }
    if (this.mounted) {
      setState(() {
        _loading = false;
      });
    }
  }

  void _seperatingList(List<MatchCard> matchCard) {
    print("seperating");
    if (this.mounted) {
      setState(() {
        _loading = true;
      });
    }
    
    for (int i = 0; i < matchCard.length; i++) {
      bool isFade = false;
      print(
          "daily=${Global.match_count_daily}, count1=${Global.match_count1}, i=${i}");
      if (!Global.isPremium &&
          i >= Global.match_count_daily - Global.match_count1) {
        isFade = true;
        print(
            "daily=${Global.match_count_daily}, count1=${Global.match_count1}, i=${i}");
      }
      bool isCounter = false;
      if (!Global.isPremium &&
          Global.match_count_daily - Global.match_count1 == i) {
        isCounter = true;
      }

      if (isFade && isCounter) {
        cardListAfterMakingWidget.add(_getCard(matchCard[i], isFade, isCounter));
        cardListAfterMakingWidget.add(_getCard(matchCard[i], isFade, false));
      } else {
        cardListAfterMakingWidget.add(_getCard(matchCard[i], isFade, isCounter));
      }
    }
    if (cardListAfterMakingWidget.length < 1) {
      cardListAfterMakingWidget.add(_getMyHistoryWidget());
    } else {
      cardListAfterMakingWidget.insert(1, _getMyHistoryWidget());
    }
    
    this._loadingToggle(state: false);
  }

  _getMyHistoryWidget() {
    return InkWell(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => MyHistoryBase()));
        //Analytics tracking code
        analytics.setCurrentScreen(
            screenName: "my_history_mutual",
            screenClassOverride: "my_history_mutual");
        amplitudeAnalytics.logEvent("my_history_mutual_page");
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        elevation: 5,
        child: Container(
          padding: EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 5,
              ),
              Text(
                "My History",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              SizedBox(
                height: 5,
              ),
              Container(
                width: 100,
                child: Row(
                  children: <Widget>[
                    IconButton(
                      icon: Icon(
                        Icons.favorite,
                        color: Colors.red,
                      ),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MyHistoryBase(
                                      selectedPage: 0,
                                    )));
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.help, color: Colors.orange),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MyHistoryBase(
                                      selectedPage: 0,
                                    )));
                      },
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  _getCard(MatchCard m1, bool isFaded, bool isCounter) {
    double _sigmaX = 9.0; // from 0-10
    double _sigmaY = 9.0; // from 0-10
    double _opacity = 0.7;
    double imgHeight = (AppConfig.fullWidth(context) / 2 - 8 - 16);
    if (isFaded && isCounter) {
      return LimitReachedCard(
        startTime: _start,
        endTime: _endTime,
      );
    }

    return AnimatedOpacity(
      opacity: (!m1.isLiked && !m1.isPassed) ? 1.0 : 0.0,
      duration: Duration(milliseconds: 500),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50.0),
        ),
        elevation: 5,
        child: Container(
          padding: EdgeInsets.all(8),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              InkWell(
                onTap: () {
                  isFaded
                      ? null
                      : _registerView(m1).then((value) => {
                            value == true
                                ? Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => MatchUserProfile(
                                              userId: m1.id,
                                            )))
                                : null
                          });
                },
                child: Stack(
                  children: <Widget>[
                    CachedNetworkImage(
                      width: double.infinity,
                      height: imgHeight,
                      imageUrl: m1.image,
                      placeholder: (context, url) => Container(
                        child: CircularProgressIndicator(),
                        height: 20.0,
                        width: 20.0,
                        margin: EdgeInsets.only(top: 30, right: 30, bottom: 30, left: 30),
                      ),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                      fit: BoxFit.cover,
                    ),
                    // Image.network(m1.image,
                    //     width: double.infinity,
                    //     height: imgHeight,
                    //     fit: BoxFit.cover),
                    Container(
                      height: 25,
                      child: Row(
                        children: <Widget>[
                          MyButtons.getContainerForMatchCard(25, () {
                            if (!m1.isPassed && !m1.isLiked) {
                              _onLeftSwipe(m1);
                            }
                          },
                              Icons.clear,
                              (!m1.isPassed)
                                  ? Color.fromRGBO(236, 236, 236, 1)
                                  : Color.fromRGBO(255, 0, 74, 1),
                              Color.fromRGBO(0, 0, 0, 0.5)),
                          Spacer(),
                          MyButtons.getContainerForMatchCard(25, () {
                            if (!m1.isPassed && !m1.isLiked) {
                              _onRightSwipe(m1);
                            }
                          },
                              (!m1.isLiked)
                                  ? Icons.favorite_border
                                  : Icons.favorite,
                              (!m1.isLiked)
                                  ? Color.fromRGBO(236, 236, 236, 1)
                                  : Color.fromRGBO(255, 0, 74, 1),
                              Color.fromRGBO(0, 0, 0, 0.5)),
                        ],
                      ),
                    ),
                    Visibility(
                      visible: isFaded,
                      child: ClipRect(
                          child: BackdropFilter(
                        filter:
                            ImageFilter.blur(sigmaX: _sigmaX, sigmaY: _sigmaY),
                        child: Container(
                          height: imgHeight,
                          width: double.infinity,
                          color: Colors.white.withOpacity(_opacity),
                        ),
                      )),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 5,
              ),
              InkWell(
                onTap: () {
                  _registerView(m1).then((value) => {
                        value == true
                            ? Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MatchUserProfile(
                                          userId: m1.id,
                                        )))
                            : null
                      });
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      isFaded
                          ? "${m1.firstName}****, ${m1.age}"
                          : "${m1.firstName}, ${m1.age}",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.blackColor),
                    ),
                    Text(
                      isFaded
                          ? "Location Hidden"
                          : "${m1.location} | ${m1.heightInInches}",
                      style: TextStyle(
                          color: Color.fromRGBO(44, 45, 48, 0.5),
                          fontSize: 12,
                          fontWeight: FontWeight.w400),
                    ),
                    Text(isFaded ? "Church Hidden" : m1.church,
                        style: TextStyle(
                            color: Color.fromRGBO(44, 45, 48, 0.5),
                            fontSize: 12,
                            fontWeight: FontWeight.w400)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _endTime() {
    _seperatingList(this._matchCards);
  }

  Future<bool> _registerView(MatchCard m1) async {
    try {
      var data = {"id": m1.id};
      print("registering view for " + m1.id.toString());
      var res = await MyHttp.post("/matches/view", data);
      if (res.statusCode == 201) {
        return true;
      } else {
        print(res.statusCode);
        return false;
      }
    } catch (e) {
      print(e);
      return false;
    }
  }

  void didGoBackWithMatchCards(List<MatchCard> matchCards) {
    this._matchCards = matchCards;
    _seperatingList(this._matchCards);
    if (this.mounted) {
      _getMatchCount();
      setState(() {});
    }
  }

  void refreshWidget() {
    if (this.mounted) {
      setState(() {});
    }
  }

  void _checkFromPN() {
    if (widget.matchType == null || widget.matchType == "") {
      return;
    }
    if (widget.userId == null || widget.userId == 0) {
      return;
    }

    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (widget.matchType == "matches") {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => MyHistoryBase(
                      selectedPage: 0,
                      userId: widget.userId,
                      matchType: widget.matchType,
                    )));
      } else if (widget.matchType == "likes") {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => MyHistoryBase(
                      selectedPage: 3,
                      userId: widget.userId,
                      matchType: widget.matchType,
                    )));
      }
    });
  }

  @override
  void initState() {
    getInit();
    super.initState();
    // Analytics tracking code
    amplitudeAnalytics.init(apiKey);
    analytics.setCurrentScreen(
        screenName: "pure_match", screenClassOverride: "pure_match");
    amplitudeAnalytics.logEvent("pure_match_page");
  }

  getInit() async {
    await this.tutorialPage();
    await _premiumStatus();
    await _getMatchCount();
    await _getLocation(context);
    await _checkFromPN();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final double itemHeight = size.height;
    double _sigmaX = 9.0; // from 0-10
    double _sigmaY = 9.0; // from 0-10
    double _opacity = 0.7;

    return Scaffold(
      backgroundColor: AppColors.greyColor,
      appBar: AppBar(
        leading: IconButton(
          padding: EdgeInsets.all(0),
          onPressed: () {
            (Global.matching_active == false)
                ? null
                : (_matchCards.length != 0)
                    ? Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MatchProfile(
                                  matchCards: _matchCards,
                                  goBackWithCards: didGoBackWithMatchCards,
                                )))
                    : Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MatchProfile(
                                  matchCards: [],
                                  goBackWithCards: didGoBackWithMatchCards,
                                )));
          },
          icon: Image(
            image: AssetImage("assets/images/Swipe.png"),
            width: 40,
            height: 40,
          ),
          color: Colors.white,
          //
        ),
        backgroundColor: AppColors.redColor,
        title: Text(
          "Matching",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.w600, fontSize: 24),
        ),
        centerTitle: (Platform.isIOS) ? true : false,
        actions: <Widget>[
          InkWell(
              onTap: () {
                Navigator.push(context,
                        MaterialPageRoute(builder: (context) => MainSettings()))
                    .then((value) =>
                        {value == true ? _getLocation(context) : null});
              },
              child: Padding(
                padding: EdgeInsets.only(right: 10),
                child: SizedBox(
                    width: 35,
                    height: 31,
                    child: Image.asset(
                      "assets/images/setting_logo.png",
                      width: 30,
                      height: 30,
                    )),
              )),
        ],
      ),
      body: SafeArea(
        child: (this._loading)
            ? this._showLoading()
            : Container(
                color: AppColors.greyColor,              
                child: Stack(children: <Widget>[
                  WaterfallFlow.builder(
                    itemCount: cardListAfterMakingWidget.length,
                    padding: EdgeInsets.all(1.0),
                    gridDelegate: SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 0.0,
                        mainAxisSpacing: 0.0,
                        lastChildLayoutTypeBuilder: (index) => index == cardListAfterMakingWidget.length
                            ? LastChildLayoutType.foot
                            : LastChildLayoutType.none,
                        ),
                    itemBuilder: (BuildContext context, int index) => cardListAfterMakingWidget[index] ?? null,
                  ),
                  (Global.matching_active == false)
                      ? BackdropFilter(
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
                                  "Matching currently deactivated.\nChange your settings to reactivate it.",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Container(
                                  padding: EdgeInsets.all(10),
                                  child: MyButtons.getBorderedButton(
                                      "Reactivate Matching",
                                      AppColors
                                          .matchBrowseMatchReactivateMatching,
                                      () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => PrivacySettings(
                                          refreshMatch: refreshWidget,
                                        ),
                                      ),
                                    );
                                  }, true, borderRadius: 10, buttonWidth: 220),
                                )
                              ],
                            ),
                          ),
                        )
                      : Container(),
                  (cardListAfterMakingWidget.isEmpty && _matchCards.isEmpty)
                      ? Center(
                          child: Stack(
                            children: [
                              FittedBox(
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        "No potential matches found with current filters.\nTry changing your match preferences\nto include more options.",
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            height: 1.5),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    TextButton(
                                        onPressed: () {
                                          // Navigator.push(
                                          //     context,
                                          //     MaterialPageRoute(
                                          //         builder: (context) =>
                                          //             EditMatchSettings()));
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      // UserDatingPreference(
                                                      //   userDatingPreferencesPageType:
                                                      //       UserDatingPreferencesPageType
                                                      //           .SETTINGS,
                                                      // )));
                                                      UserDatingPreference(
                                                        userDatingPreferencesPageType:
                                                            UserDatingPreferencesPageType
                                                                .SETTINGS,
                                                        onSaveContinue:
                                                            onSaveMatchPreferences,
                                                      )));
                                        },
                                        child: Text(
                                          "Change Match Settings",
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: AppColors.redColor,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                        ))
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                      : Container(),
                  (isFirstTime == true && next == 0)
                      ? Stack(children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              width: MediaQuery.of(context).size.width / 2.5,
                              height: 200,
                              padding: EdgeInsets.symmetric(
                                  vertical: 23.0, horizontal: 10),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: FittedBox(
                                child: Column(
                                  children: [
                                    Text(
                                      "This will switch you to\n'Swipe View'\nto quickly swipe to the\nnext potential matches!",
                                      // "Carousel swiping is \ncoming soon.\nFor now, swipe left if\n‘Not interested’\nand swipe right to ‘Like’\nor use the buttons below.",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    ButtonTheme(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 8.0,
                                          horizontal:
                                              18.0), //adds padding inside the button
                                      materialTapTargetSize: MaterialTapTargetSize
                                          .shrinkWrap, //limits the touch area to the button area
                                      minWidth: 0, //wraps child's width
                                      height: 0,
                                      child: FlatButton(
                                        onPressed: () {
                                          next++;
                                          if (this.mounted) {
                                            setState(() {});
                                          }
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
                                              fontSize: 12),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                              right:
                                  MediaQuery.of(context).size.width / (1 * 2.8),
                              top: 10,
                              child: this._triangle()),
                        ])
                      : Container(),
                  (isFirstTime == true && next == 2)
                      ? Positioned(
                          top: 50,
                          right: 60,
                          child: Stack(children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                width: MediaQuery.of(context).size.width / 2,
                                height: 120,
                                padding: EdgeInsets.symmetric(
                                    vertical: 2, horizontal: 10),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: FittedBox(
                                  child: Column(
                                    children: [
                                      Text(
                                        "This ♡ will move this \nperson to your \"likes\" list in",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 20),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      ButtonTheme(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 8.0,
                                            horizontal:
                                                18.0), //adds padding inside the button
                                        materialTapTargetSize: MaterialTapTargetSize
                                            .shrinkWrap, //limits the touch area to the button area
                                        minWidth: 0, //wraps child's width
                                        height: 0,
                                        child: FlatButton(
                                          onPressed: () {
                                            next++;
                                            if (this.mounted) {
                                              setState(() {});
                                            }
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
                                                fontSize: 12),
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
                                    (0.9 * 2.8),
                                top: 10,
                                child: this._triangle()),
                          ]),
                        )
                      : Container(),
                  (isFirstTime == true && next == 1)
                      ? Positioned(
                          top: 50,
                          child: Stack(children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                width: MediaQuery.of(context).size.width / 2,
                                height: 120,
                                padding: EdgeInsets.symmetric(
                                    vertical: 2, horizontal: 2),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: FittedBox(
                                  child: Column(
                                    children: [
                                      Text(
                                        "This X will remove this\n person from your tile view",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 20),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      ButtonTheme(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 8.0,
                                            horizontal:
                                                18.0), //adds padding inside the button
                                        materialTapTargetSize: MaterialTapTargetSize
                                            .shrinkWrap, //limits the touch area to the button area
                                        minWidth: 0, //wraps child's width
                                        height: 0,
                                        child: FlatButton(
                                          onPressed: () {
                                            next++;
                                            if (this.mounted) {
                                              setState(() {});
                                            }
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
                                                fontSize: 12),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                                left: 30,
                                // right:
                                //     MediaQuery.of(context).size.width / (1 * 4),
                                top: 10,
                                child: this._triangle()),
                          ]),
                        )
                      : Container(),
                ]),
              ),
      ),
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

  Future<bool> _onLeftSwipe(MatchCard m1) async {
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate();
    }
    _setMatchCount();
    m1.isPassed = true;
    for (int i = 0; i < _matchCards.length; i++) {
      MatchCard m2 = _matchCards[i];
      if (m1.id == m2.id) {
        _matchCards[i] = m1;
        break;
      }
    }
    _seperatingList(_matchCards);
    await Future.delayed(const Duration(milliseconds: 500));
    _matchCards.remove(m1);
    _seperatingList(_matchCards);
    try {
      var data = {"id": m1.id};
      var res = await MyHttp.post("/matches/pass", data);
      print(res.statusCode);
      print(res.body);
      if (res.statusCode == 200) {
        _seperatingList(_matchCards);
        if (this.mounted) {
          setState(() {});
        }

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

  void _onRightSwipe(MatchCard m1) async {
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate();
    }
    _setMatchCount();
    m1.isLiked = true;
    for (int i = 0; i < _matchCards.length; i++) {
      MatchCard m2 = _matchCards[i];
      if (m1.id == m2.id) {
        _matchCards[i] = m1;
        break;
      }
    }
    _seperatingList(_matchCards);
    await Future.delayed(const Duration(milliseconds: 500));
    _matchCards.remove(m1);
    _seperatingList(_matchCards);
    print("&&&&&&&&&&&&&&");
    try {
      var data = {"id": m1.id};
      // var data = {"id": 56};
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
      }
    } catch (e) {
      print(e);
    }
  }

  Widget _triangle() {
    return CustomPaint(
      painter: Triangle(Color.fromRGBO(0, 0, 0, 0.7)),
    );
  }
}