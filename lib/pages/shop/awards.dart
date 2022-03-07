import 'dart:convert';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:pure_match/common/global.dart';
import 'package:pure_match/models/shop_items.dart';
import 'package:pure_match/pages/AppColors.dart';

import '../MyHttp.dart';

enum RewardsPages { AWARDS, SHOPS }

class Awards extends StatefulWidget {
  final RewardsPages rewardspages;
  final Function(int) onSelectSpendMyPureGems;

  const Awards({Key key, this.rewardspages, this.onSelectSpendMyPureGems})
      : super(key: key);
  @override
  _AwardsState createState() => _AwardsState();
}

class _AwardsState extends State<Awards> {
  double mediaWidth;
  double mediaHeight;
  ShopItem si;
  // List _extras = [];
  // List _gemBundles = [];
  var balance = 0;
  bool hasCompletedRisingStar = false;
  bool hasCompletedAmbassador = false;
  bool hasCompletedConnector = false;
  bool hasCompletedEvangelist = false;
  bool hasCompletedMatchmaker = false;
  bool hasCompletedSuperstar = false;
  // GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  bool _loading = false;

  @override
  void initState() {
    _getAwards();
    _getGemBalance();

    setState(() {});
    super.initState();
  }

  void _getAwards() async {
    setState(() {
      _loading = true;
    });
    try {
      var res = await MyHttp.get("/settings/rewards");
      if (res.statusCode == 200) {
        var jsonData = jsonDecode(res.body);
        var awards = jsonData["awards"];
        hasCompletedRisingStar = awards["hasCompletedRisingStar"];
        hasCompletedAmbassador = awards["hasCompletedAmbassador"];
        hasCompletedConnector = awards["hasCompletedConnector"];
        hasCompletedEvangelist = awards["hasCompletedEvangelist"];
        hasCompletedMatchmaker = awards["hasCompletedMatchmaker"];
        hasCompletedSuperstar = awards["hasCompletedSuperstar"];
      }
    } catch (e) {
      print("Err $e");
    }
    if (this.mounted) {
      setState(() {
        _loading = false;
      });
    }
  }

  void _getGemBalance() async {
    try {
      var res = await MyHttp.get("shop/gem-balance");
      if (res.statusCode == 200 || res.statusCode == 201) {
        var jsondata = jsonDecode(res.body);

        balance = jsondata["balance"];
        print(balance);
      }
      setState(() {});
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    mediaWidth = MediaQuery.of(context).size.width;
    mediaHeight = MediaQuery.of(context).size.height;
    print("height" + mediaHeight.toString());
    print("width" + mediaWidth.toString());
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(child: (this._loading) ? this._showLoading() : awards()),
    );
  }

  Widget awards() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 300,
                  child: Text(
                    "Reach dating milestones and earn rewards to help you find your pure love!",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 19),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 50,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  height: 175,
                  width: 175,
                  child: InkWell(
                    onTap: () {
                      widget.onSelectSpendMyPureGems(1);
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Material(
                          elevation: 60,
                          color: Colors.transparent,
                          child: RichText(
                            text: TextSpan(
                              style: DefaultTextStyle.of(context).style,
                              children: <TextSpan>[
                                TextSpan(
                                    text: 'Spend My\nPure Gems',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontSize: 24)),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Material(
                          elevation: 0,
                          color: Colors.transparent,
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: DefaultTextStyle.of(context).style,
                              children: <TextSpan>[
                                TextSpan(
                                    text: '${balance}\nGem Balance',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                        fontSize: 17)),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  decoration: BoxDecoration(
                      boxShadow: [
                        new BoxShadow(
                            color: Color.fromRGBO(255, 172, 0, 1),
                            offset: new Offset(0, 3),
                            blurRadius: 20.0,
                            spreadRadius: 10.0)
                      ],
                      shape: BoxShape.circle,
                      image: DecorationImage(
                          image: new AssetImage(
                              "assets/images/gem_transparent.png"),
                          fit: BoxFit.fill)),
                )
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Text(
                  "Awards",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                )
              ],
            ),
            FittedBox(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  awardCard("Rising Star", "100", "Complete\nyour profile",
                      hasCompletedRisingStar),
                  awardCard(
                      "Ambassador",
                      "250",
                      "Share Pure Match\nwith 5 people",
                      hasCompletedAmbassador),
                  awardCard(
                      "Connector",
                      "500",
                      "Share Pure match\nwith 10 people",
                      hasCompletedConnector),
                ],
              ),
            ),
            FittedBox(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  awardCard("Evangelist", "750",
                      "10 friends you\ninvited joined", hasCompletedEvangelist),
                  awardCard(
                      "Matchmaker",
                      "1000",
                      "Two people you\nintroduced date",
                      hasCompletedMatchmaker),
                  awardCard("Super Star", "2000", "Unlock all other badges",
                      hasCompletedSuperstar),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget awardCard(String title, String gems, String details, bool isSelected) {
    double _sigmaX = 1.0; // from 0-10
    double _sigmaY = 1.0; // from 0-10
    double _opacity = 0.5;
    return Card(
      // elevation: isSelected ? 0 : 5,
      elevation: 0,
      color: isSelected
          ? AppColors.matchBrowseMatchReactivateMatching
          : Colors.white,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Color.fromRGBO(142, 142, 142, 1), width: 1),
        borderRadius: BorderRadius.circular(15),
      ),
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 3),
      child: Stack(children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            width: 100,
            child: Column(
              children: <Widget>[
                Text(title,
                    style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w600)),
                SizedBox(
                  height: 7,
                ),
                Image.asset("assets/images/gem_medium_icon.png"),
                SizedBox(
                  height: 7,
                ),
                Text(gems,
                    style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w600)),
                Text(details,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w100,
                        fontSize: 12)),
              ],
            ),
          ),
        ),
        Positioned(
          top: 0,
          bottom: 0,
          left: 0,
          right: 0,
          child: Visibility(
            visible: title != "Rising Star",
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: _sigmaX, sigmaY: _sigmaY),
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(_opacity),
                      ),
                    ],
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ),
        Visibility(
          visible: title != "Rising Star",
          child: Positioned.fill(
            top: 0,
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              child: Center(
                child: Text(
                  "COMING\nSOON",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    shadows: <Shadow>[
                      Shadow(
                        color: Colors.black.withOpacity(1.0),
                        offset: Offset(1.0, 1.0),
                        blurRadius: 2.0,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ]),
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
