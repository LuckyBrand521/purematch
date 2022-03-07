import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:amplitude_flutter/amplitude.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:pure_match/common/RoundIndicators.dart';
import 'package:pure_match/common/global.dart';
import 'package:pure_match/models/city.dart';
import 'package:pure_match/pages/AppColors.dart';
import 'package:pure_match/pages/MyHttp.dart';
import 'package:pure_match/pages/onboarding/basic_info/user_church.dart';
import 'package:flutter/cupertino.dart';
import 'package:pure_match/pages/onboarding/profile_info/enableNotification.dart';

class UserLocationTxt extends StatefulWidget {
  final bool isFromWelcome;
  const UserLocationTxt({Key key, this.isFromWelcome}) : super(key: key);
  @override
  _UserLocationTxtState createState() => _UserLocationTxtState();
}

class _UserLocationTxtState extends State<UserLocationTxt> {
  // Analytics code
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';

  String location = "";
  String error = "";
  bool loading = false;
  bool _loading = false;
  List<City> cities = [];
  TextEditingController ctrl = TextEditingController();

  Future<void> _setLocation() async {
    setState(() {
      _loading = true;
    });
    var res = await MyHttp.put("users/update", {"location": this.location});
    if (res.statusCode == 200) {
      //Analytics tracking code
      analytics.logEvent(
          name: "saved_location",
          parameters: <String, dynamic>{'location': this.location});
      amplitudeAnalytics.logEvent("saved_location",
          eventProperties: {'location': this.location});

      _loading = false;
      if (widget.isFromWelcome != null && widget.isFromWelcome) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => EnableNotification(
                      isFromWelcome: true,
                    )));
      } else {
        // Navigator.push(
        //     context, MaterialPageRoute(builder: (context) => UserReferredBy()));
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => UserChurch()));
        //Analytics tracking code
        analytics.setCurrentScreen(
            screenName: 'onboarding_refered_by',
            screenClassOverride: 'onboarding_refered_by');
        amplitudeAnalytics.logEvent("onboarding_refered_by_page");
      }
    } else {
      print("User update error: ${res.statusCode}");
      print("User update error: ${res.body}");
      setState(() {
        _loading = false;
        var body = json.decode(res.body);
        error = body["message"] ?? "error";
      });
    }
  }

  Future<void> _getCities(String location) async {
    var res = await MyHttp.post("cityLocator", {"city": location});
    if (res.statusCode == 200) {
      var body = json.decode(res.body);
      var cityList = body["city"] as List<dynamic>;
      if (cityList != null) {
        cities = [];
        for (var cityObj in cityList) {
          City city = City.fromJson(cityObj);
          cities.add(city);
        }
        setState(() {});
      }
    } else {
      print("User update error: ${res.statusCode}");
      print("User update error: ${res.body}");
      setState(() {
        var body = json.decode(res.body);
        error = body["message"] ?? "error";
      });
    }
  }

  bool isNumeric(String s) {
    if (s == null) {
      return false;
    }
    // ignore: deprecated_member_use
    return double.parse(s, (e) => null) != null;
  }

  @override
  void initState() {
    super.initState();
    //Initializing amplitude analytics api key
    amplitudeAnalytics.init(apiKey);
    if (widget.isFromWelcome != null && widget.isFromWelcome) {
    } else {
      Global.setOnboardingId(33);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      appBar: PlatformAppBar(
        material: (_, __) => MaterialAppBarData(
          elevation: 0.0,
          backgroundColor: Colors.white,
          leading: (widget.isFromWelcome != null && widget.isFromWelcome)
              ? null
              : IconButton(
                  padding: EdgeInsetsDirectional.only(start: 20.0),
                  icon: Icon(Icons.arrow_back, color: AppColors.offWhiteColor),
                  onPressed: () {
                    Navigator.pop(context);
                    // Analytics tracking code
                    analytics.setCurrentScreen(
                        screenName: 'onboarding_user_birth_date',
                        screenClassOverride: 'onboarding_user_birth_date');
                    amplitudeAnalytics
                        .logEvent("onboarding_user_birth_date_page");
                  },
                ),
        ),
        cupertino: (_, __) => CupertinoNavigationBarData(
            brightness: Brightness.dark,
            automaticallyImplyLeading: false,
            automaticallyImplyMiddle: false,
            backgroundColor: Colors.white,
            border: Border(bottom: BorderSide.none),
            padding: EdgeInsetsDirectional.only(start: 10.0),
            leading: (widget.isFromWelcome != null && widget.isFromWelcome)
                ? null
                : CupertinoNavigationBarBackButton(
                    color: AppColors.offWhiteColor,
                    previousPageTitle: null,
                    onPressed: () {
                      Navigator.pop(context);
                      // Analytics tracking code
                      analytics.setCurrentScreen(
                          screenName: 'onboarding_user_birth_date',
                          screenClassOverride: 'onboarding_user_birth_date');
                      amplitudeAnalytics
                          .logEvent("onboarding_user_birth_date_page");
                    })),
      ),
      body: SafeArea(
          child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            RoundIndicators(
              currentIndicatorIndex: 3,
              numberOfInidcators: 14,
              circleSize: 12,
            ),
            SizedBox(
              height: 30,
            ),
            Text(
              "Where are you\nlocated?",
              style: TextStyle(
                  color: AppColors.blackColor,
                  fontSize: AppConfig.heightWithDForSmallDevice(context, 36, 4),
                  fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 30,
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 30.0),
              child: PlatformTextField(
                controller: ctrl,
                style: TextStyle(
                    fontSize:
                        AppConfig.heightWithDForSmallDevice(context, 22, 4),
                    color: AppColors.blueColor,
                    fontWeight: FontWeight.w700),
                onChanged: (String location) {
                  setState(() {
                    _getCities(location);
                  });
                },
                material: (_, __) => MaterialTextFieldData(
                  decoration: InputDecoration(
                      hintText: "Culver City, CA",
                      hintStyle: TextStyle(color: AppColors.disabledBlueColor),
                      contentPadding: EdgeInsets.all(0),
                      enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: AppColors.blueColor, width: 1))),
                ),
                cupertino: (_, __) => CupertinoTextFieldData(
                  placeholder: "Culver City, CA",
                  placeholderStyle:
                      TextStyle(color: AppColors.disabledBlueColor),
                  textAlign: TextAlign.center,
                  keyboardAppearance: Brightness.light,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: AppColors.blueColor, width: 1),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: AppConfig.heightWithDForSmallDevice(context, 20, 4),
            ),
            Expanded(
              child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: cities.length,
                  itemBuilder: (context, i) {
                    City city = cities[i];
                    String title = city.cityName;
                    if (isNumeric(city.adminCode) == false) {
                      title = city.cityName + ", " + city.adminCode;
                    } else {
                      title = city.cityName + ", " + city.country;
                    }
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 23),
                      child: InkWell(
                        onTap: () {
                          this.location = title;
                          ctrl.text = title;
                          setState(() {});
                        },
                        child: Container(
                          padding: EdgeInsets.only(top: 10, bottom: 10),
                          child: Row(
                            children: [
                              Image.asset(
                                "assets/images/location_icon.png",
                                width: 20,
                                height: 20,
                                fit: BoxFit.contain,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                title,
                                style: TextStyle(
                                    fontSize: 17,
                                    color: AppColors.blackTxtColor),
                              )
                            ],
                          ),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                  width: 0.5,
                                  color: AppColors.blackBorderColor),
                            ),
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  }),
            ),
            // Expanded(child: Container()),
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                child: (loading)
                    ? PlatformCircularProgressIndicator()
                    : Align(
                        alignment: Alignment.bottomCenter,
                        child: SizedBox(
                          height: AppConfig.heightWithDForSmallDevice(
                              context, 60, 10),
                          width: 220,
                          child: PlatformButton(
                              onPressed: (this.location.trim().length > 0)
                                  ? () {
                                      (_loading == false)
                                          ? this._setLocation()
                                          : null;
                                    }
                                  : null,
                              color: AppColors.blueColor,
                              disabledColor: AppColors.disabledBlueColor,
                              materialFlat: (_, __) => MaterialFlatButtonData(
                                    color: AppColors.blueColor,
                                    disabledColor: AppColors.disabledBlueColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                              cupertinoFilled: (_, __) =>
                                  CupertinoFilledButtonData(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                              child: Text(
                                "Continue",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16),
                              )),
                        )))
          ],
        ),
      )),
    );
  }
}
