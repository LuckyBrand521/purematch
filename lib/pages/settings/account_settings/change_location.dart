import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:amplitude_flutter/amplitude.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:pure_match/pages/AppColors.dart';
import 'package:pure_match/pages/MyHttp.dart';
import 'package:flutter/cupertino.dart';
import 'package:location/location.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geocoder/geocoder.dart';

class ChangeLocation extends StatefulWidget {
  final int userId;

  const ChangeLocation({Key key, this.userId}) : super(key: key);

  @override
  _ChangeLocationState createState() => _ChangeLocationState();
}

class _ChangeLocationState extends State<ChangeLocation> {
  // Analytics code
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';

  bool _locationChanged = false;
  String _location = "";
  String error = "";
  String prevLocation = "City";
  bool currentUser = true;
  var _churchTxtCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;
  bool called = false;

  @override
  void initState() {
    // _location = widget._location;
    _churchTxtCtrl.text = _location;
    super.initState();
  }

  void _getCurrentLocation(BuildContext context) async {
    setState(() {
      loading = true;
    });
    Location location = new Location();

    bool _serviceEnabled;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        final snackBar = SnackBar(content: Text('Location service not found!'));
        Scaffold.of(context).showSnackBar(snackBar);
        setState(() {
          loading = false;
        });
      }
    }
    _locationData = await location.getLocation();
    print(_locationData);
    var lat = _locationData.latitude;
    var long = _locationData.longitude;

    final coordinates = new Coordinates(lat, long);
    var addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);

    var first = addresses.first;
    var locationTxt = "${first.locality}, ${first.adminArea}";
    print(locationTxt);
    //ctrl.text = locationTxt;
    setState(() {
      this.prevLocation = locationTxt;
      this._location = locationTxt;
      this.loading = false;
    });
    return;
  }

  Future<dynamic> _getLocation(BuildContext context) async {
    var sp = await SharedPreferences.getInstance();
    int id = sp.getInt("id");
    //int id = 53;
    print(id);
    if (widget.userId != null) {
      if (widget.userId != id) {
        currentUser = false;
        id = widget.userId;
      }
    }
    try {
      if (!called) {
        var res = await MyHttp.get("users/user/$id");
        var res2 = await MyHttp.get("users/uploads");
        var json = jsonDecode(res.body);
        prevLocation = json["user"]["location"];
        print(prevLocation);
        print(res.body);
        print(res2.body);
        called = true;
      }
      return prevLocation;
    } catch (e) {
      print(e);
    }
    print(id);
  }

  // String _previousLocation() {
  //   return prevLocation;
  // }

  Future<void> _setLocation() async {
    var res = await MyHttp.put("users/update", {
      "location": this._location,
    });
    if (res.statusCode == 200) {
      //Analytics tracking code
      analytics.logEvent(
          name: "changed_location",
          parameters: <String, dynamic>{
            'previous_location': prevLocation,
            'new_location': this._location
          });
      amplitudeAnalytics.logEvent("changed_location", eventProperties: {
        'previous_location': prevLocation,
        'new_location': this._location
      });

      print("User updated");
      print(res.body);
    } else {
      print("User update error: ${res.statusCode}");
      print("User update error: ${res.body}");
      setState(() {
        var body = json.decode(res.body);
        error = body["message"] ?? "error";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getLocation(context),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return PlatformScaffold(
            backgroundColor: Colors.white,
            //bottomNavBar: HomePage(),
            appBar: PlatformAppBar(
              material: (_, __) => MaterialAppBarData(
                backgroundColor: AppColors.offWhiteColor,
                elevation: 0.0,
                leading: MaterialButton(
                  onPressed: () {},
                  child: IconButton(
                    icon: Icon(Icons.arrow_back),
                    color: Colors.white,
                    onPressed: () {
                      Navigator.pop(context);
                      // analytics tracking code
                      analytics.setCurrentScreen(
                          screenName: "account_settings",
                          screenClassOverride: "account_settings");
                      amplitudeAnalytics.logEvent("account_settings_page");
                    },
                  ),
                ),
                title: Text(
                  "Change Location",
                  style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontStyle: FontStyle.normal),
                ),
              ),
              cupertino: (_, __) => CupertinoNavigationBarData(
                automaticallyImplyLeading: false,
                automaticallyImplyMiddle: false,
                backgroundColor: AppColors.offWhiteColor,
                leading: MaterialButton(
                  onPressed: () {},
                  child: IconButton(
                    icon: Icon(Icons.arrow_back_ios),
                    color: Colors.white,
                    onPressed: () {
                      Navigator.pop(context);
                      // Analytics tracking code
                      analytics.setCurrentScreen(
                          screenName: "account_settings",
                          screenClassOverride: "account_settings");
                      amplitudeAnalytics.logEvent("account_settings_page");
                    },
                  ),
                ),
                title: Text(
                  "Change Location",
                  style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontStyle: FontStyle.normal),
                ),
                padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 10.0),
              ),
            ),
            body: SafeArea(
                child: Scaffold(
              backgroundColor: Colors.white,
              body: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        height: 40,
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.only(top: 20, left: 25, right: 25),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "Location:",
                              style: TextStyle(
                                fontSize: 28,
                                fontStyle: FontStyle.normal,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Center(
                              child: Text(
                                prevLocation,
                                style: TextStyle(
                                  fontSize: 28,
                                  fontStyle: FontStyle.normal,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            TextFormField(
                              validator: (value) {
                                if (value.trim().isEmpty) {
                                  return 'Please enter location';
                                }
                                return null;
                              },
                              controller: _churchTxtCtrl,
                              textCapitalization: TextCapitalization.words,
                              style:
                                  TextStyle(fontSize: 22, color: Colors.black),
                              onChanged: (String value) {
                                setState(() {
                                  if (!value.trim().isEmpty) {
                                    _locationChanged = true;
                                  }
                                  this._location = value;
                                });
                              },
                              decoration: InputDecoration(
                                  contentPadding: EdgeInsets.all(0),
                                  focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: AppColors.redColor, width: 2)),
                                  border: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: AppColors.redColor, width: 2)),
                                  enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: AppColors.redColor,
                                          width: 2))),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Center(
                        child: FlatButton(
                          padding: EdgeInsets.all(0),
                          onPressed: () {
                            _getCurrentLocation(context);
                            setState(() {
                              _locationChanged = true;
                            });
                          },
                          child: Text(
                            "Use my location",
                            style: TextStyle(
                              fontSize: 24,
                              color: AppColors.blueColor,
                              fontStyle: FontStyle.normal,
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.w700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 20.0, horizontal: 30),
                        child: Center(
                          child: SizedBox(
                            width: 500,
                            child: PlatformButton(
                              padding: EdgeInsets.symmetric(vertical: 15.0),
                              color: _locationChanged == true
                                  ? AppColors.blueColor
                                  : AppColors.greyColor,
                              onPressed: () async {
                                await _setLocation();
                              },
                              materialFlat: (_, __) => MaterialFlatButtonData(
                                child: Text(
                                  "Save Changes",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: _locationChanged == true
                                          ? FontWeight.w700
                                          : FontWeight.w400,
                                      color: _locationChanged == true
                                          ? Colors.white
                                          : AppColors.blackColor,
                                      fontStyle: FontStyle.normal),
                                ),
                              ),
                              cupertinoFilled: (_, __) =>
                                  CupertinoFilledButtonData(
                                child: Text(
                                  "Save Changes",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: _locationChanged == true
                                          ? FontWeight.w700
                                          : FontWeight.w400,
                                      color: _locationChanged == true
                                          ? Colors.white
                                          : AppColors.blackColor,
                                      fontStyle: FontStyle.normal),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )),
          );
        } else {
          return Container();
        }
      },
    );
  }
}
