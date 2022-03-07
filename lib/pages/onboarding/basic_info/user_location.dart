import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:amplitude_flutter/amplitude.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:geocoder/geocoder.dart';
import 'package:location/location.dart';
import 'package:pure_match/common/RoundIndicators.dart';
import 'package:pure_match/common/global.dart';
import 'package:pure_match/pages/AppColors.dart';
import 'package:pure_match/pages/MyHttp.dart';
import 'package:pure_match/pages/onboarding/basic_info/user_church.dart';
import 'package:pure_match/pages/onboarding/basic_info/user_location_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:pure_match/pages/onboarding/profile_info/enableNotification.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserLocation extends StatefulWidget {
  final bool isFromWelcome;
  const UserLocation({Key key, this.isFromWelcome}) : super(key: key);
  @override
  _UserLocationState createState() => _UserLocationState();
}

class _UserLocationState extends State<UserLocation> {
  // Analytics code
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';

  String location = "";
  String error = "";
  bool loading = false;
  bool _loading = false;

  TextEditingController ctrl = TextEditingController();

  void _goTxtLocation() {
    if (widget.isFromWelcome != null && widget.isFromWelcome) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => UserLocationTxt(
                    isFromWelcome: true,
                  )));
    } else {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => UserLocationTxt()));
    }
  }

  void _getLocation(BuildContext context) async {
    setState(() {
      loading = true;
    });
    Location location = new Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        // final snackBar = SnackBar(content: Text('Location service not found!'));
        // Scaffold.of(context).showSnackBar(snackBar);
        setState(() {
          _goTxtLocation();
          loading = false;
        });
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        // final snackBar =
        //     SnackBar(content: Text('Location permission not granted.'));
        _goTxtLocation();
        // Scaffold.of(context).showSnackBar(snackBar);
        setState(() {
          loading = false;
        });
        return;
      }
    }

    _locationData = await location.getLocation();
    print(_locationData);
    var lat = _locationData.latitude;
    var long = _locationData.longitude;
    // double lat1 = 34.182424132244975;
    // double long1 = -118.54756423282491;
    // lat = lat1;
    // long = long1;
    final coordinates = new Coordinates(lat, long);
    var addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);

    var first = addresses.first;
    var locationTxt = "${first.locality}, ${first.adminArea}";
    print(locationTxt);
    ctrl.text = locationTxt;
    setState(() {
      this.location = locationTxt;
      this.loading = false;
    });
    // var locationTxt = "San Francisco, CA";
    // ctrl.text = locationTxt;
    // setState(() {
    //   this.location = locationTxt;
    //   this.loading = false;
    // });
  }

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

  void _hasGone() async {
    var sp = await SharedPreferences.getInstance();
    sp.setBool("loggedIn", true);
  }

  bool isGetLocation = false;
  void _requestLocation() {
    if (isGetLocation) {
      return;
    }
    isGetLocation = true;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      Future.delayed(Duration(seconds: 1), () {
        _getLocation(context);
      });
    });
  }

  @override
  void initState() {
    super.initState();
    if (widget.isFromWelcome != null && widget.isFromWelcome) {
      _hasGone();
    } else {
      Global.setOnboardingId(9);
    }
  }

  @override
  Widget build(BuildContext context) {
    //Initializing amplitude analytics api key
    amplitudeAnalytics.init(apiKey);
    _requestLocation();

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
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              RoundIndicators(
                currentIndicatorIndex: 3,
                numberOfInidcators: 14,
                circleSize: 12,
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "Where are you\nlocated?",
                style: TextStyle(
                    color: AppColors.blackColor,
                    fontSize:
                        AppConfig.heightWithDForSmallDevice(context, 36, 4),
                    fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 10,
              ),
              Stack(
                children: <Widget>[
                  Visibility(
                    visible: (location == ""),
                    child: Image.asset("assets/images/map_tutorial.png",
                        width: AppConfig.fullWidth(context),
                        height: AppConfig.fullWidth(context),
                        fit: BoxFit.cover),
                  ),
                  // Visibility(
                  //   visible: (location == ""),
                  //   child: Positioned.fill(
                  //     bottom: 0,
                  //     child: Container(
                  //       child: Center(
                  //         child: InkWell(
                  //           onTap: () {
                  //             this._getLocation(context);
                  //           },
                  //           child: Container(
                  //             width: AppConfig.heightWithDForSmallDevice(
                  //                 context, 350, 70),
                  //             height: 60,
                  //             child: Center(
                  //               child: Text(
                  //                 "Use my location (Recommended)",
                  //                 style: TextStyle(
                  //                   fontSize: AppConfig.fontsizeForSmallDevice(
                  //                       context, 20),
                  //                   fontWeight: FontWeight.bold,
                  //                   color: AppColors.blueColor,
                  //                 ),
                  //               ),
                  //             ),
                  //             decoration: BoxDecoration(
                  //               color: Colors.white,
                  //               borderRadius:
                  //                   BorderRadius.all(Radius.circular(10)),
                  //               boxShadow: [
                  //                 BoxShadow(
                  //                   color: Colors.grey.withOpacity(0.5),
                  //                   spreadRadius: 5,
                  //                   blurRadius: 7,
                  //                   offset: Offset(
                  //                       0, 3), // changes position of shadow
                  //                 ),
                  //               ],
                  //             ),
                  //           ),
                  //         ),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  Visibility(
                    visible: (location != ""),
                    child: Image.asset("assets/images/map_pinned.png",
                        width: AppConfig.fullWidth(context),
                        height: AppConfig.fullWidth(context),
                        fit: BoxFit.cover),
                  ),
                ],
              ),
              SizedBox(
                height: AppConfig.heightWithDForSmallDevice(context, 20, 4),
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
                  textAlign: TextAlign.center,
                  onChanged: (String location) {
                    setState(() {
                      this.location = location;
                    });
                  },
                  material: (_, __) => MaterialTextFieldData(
                    decoration: InputDecoration(
                        hintText: "Los Angeles, CA",
                        hintStyle:
                            TextStyle(color: AppColors.disabledBlueColor),
                        contentPadding: EdgeInsets.all(0),
                        enabledBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.white, width: 0))),
                  ),
                  cupertino: (_, __) => CupertinoTextFieldData(
                    placeholder: "Los Angeles, CA",
                    placeholderStyle:
                        TextStyle(color: AppColors.disabledBlueColor),
                    textAlign: TextAlign.center,
                    keyboardAppearance: Brightness.light,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.white, width: 0),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: AppConfig.heightWithDForSmallDevice(context, 20, 4),
              ),
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
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
                                      disabledColor:
                                          AppColors.disabledBlueColor,
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
        ),
      )),
    );
  }
}
