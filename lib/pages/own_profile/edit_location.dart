import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:amplitude_flutter/amplitude.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:geocoder/geocoder.dart';
import 'package:location/location.dart';
import 'package:pure_match/common/global.dart';
import 'package:pure_match/pages/AppColors.dart';
import 'package:pure_match/pages/MyHttp.dart';
import 'package:flutter/cupertino.dart';
import 'package:pure_match/pages/own_profile/edit_profile_details_app_bar.dart';
import 'package:sailor/sailor.dart';

import '../../routes.dart';

class EditLocation extends StatefulWidget {
  final String _location;
  final bool isFromOnboarding;
  final Function onUpdateProfile;
  EditLocation(this._location, this.isFromOnboarding, this.onUpdateProfile);

  @override
  _EditLocationState createState() => _EditLocationState();
}

class _EditLocationState extends State<EditLocation> {
  // Analytics code
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';

  String _location = "";
  String _location1 = "";
  String error = "";
  bool loading = false;
  TextEditingController ctrl = TextEditingController();

  @override
  void initState() {
    _location = widget._location;
    _location1 = _location;
    ctrl.text = _location;
    super.initState();
    // Analytics tracking code
    amplitudeAnalytics.init(apiKey);
    analytics.setCurrentScreen(
        screenName: "edit_location", screenClassOverride: "edit_location");
    amplitudeAnalytics.logEvent("edit_location_page");
  }

  @override
  void dispose() {
    ctrl.dispose();
    super.dispose();
  }

  bool isChangedValues() {
    var isChanged = false;
    if (this._location.length > 0 && this._location != this._location1) {
      isChanged = true;
    }
    return isChanged;
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
        final snackBar = SnackBar(content: Text('Location service not found!'));
        Scaffold.of(context).showSnackBar(snackBar);
        setState(() {
          loading = false;
        });
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

    final coordinates = new Coordinates(lat, long);
    var addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);

    var first = addresses.first;
    var locationTxt = "${first.locality}, ${first.adminArea}";
    print(locationTxt);
    ctrl.text = locationTxt;
    setState(() {
      this._location = locationTxt;
      this.loading = false;
    });
  }

  Future<void> _setLocation() async {
    var res = await MyHttp.put("users/update", {"location": this._location});
    if (res.statusCode == 200) {
      //Analytics tracking code
      analytics.logEvent(
          name: "edited_profile",
          parameters: <String, dynamic>{'location': this._location});

      amplitudeAnalytics.logEvent("edited_profile",
          eventProperties: {'location': this._location});
      print("User updated");
      print(res.body);

      if (widget.isFromOnboarding != null && widget.isFromOnboarding) {
        Navigator.pop(context);
        // widget.onSaveheight();
        widget.onUpdateProfile();
      } else {
        Global.ownProfileSaved = true;
        Routes.sailor.navigate("/homes",
            params: {'tabIndex': 4},
            navigationType: NavigationType.pushAndRemoveUntil,
            removeUntilPredicate: (Route<dynamic> route) => false);
      }
    } else {
      print("User update error: ${res.statusCode}");
      print("User update error: ${res.body}");
      setState(() {
        error = "$res.statusCode\n$res.body";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      backgroundColor: Colors.white,
      appBar: EditProfileDetailsAppBar(context: context, text: "Edit Location")
          .getAppBar1(isChangedValues()),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(new FocusNode());
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: 20,
                ),
                Text(
                  "Location:",
                  style: TextStyle(
                      fontSize:
                          AppConfig.heightWithDForSmallDevice(context, 28, 4),
                      fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 30.0),
                  child: PlatformTextField(
                    textCapitalization: TextCapitalization.words,
                    controller: ctrl,
                    style: TextStyle(
                        fontSize: 25,
                        color: Color.fromRGBO(44, 45, 48, 1),
                        fontWeight: FontWeight.w400),
                    onChanged: (String location) {
                      setState(() {
                        this._location = location;
                      });
                    },
                    material: (_, __) => MaterialTextFieldData(
                      decoration: InputDecoration(
                          hintText: "City or Zip Code",
                          hintStyle:
                              TextStyle(color: AppColors.disabledBlueColor),
                          contentPadding: EdgeInsets.all(0),
                          enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: AppColors.blueColor, width: 2))),
                    ),
                    cupertino: (_, __) => CupertinoTextFieldData(
                      placeholder: "City or Zip Code",
                      placeholderStyle:
                          TextStyle(color: AppColors.disabledBlueColor),
                      keyboardAppearance: Brightness.light,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom:
                              BorderSide(color: AppColors.blueColor, width: 2),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 25,
                ),
                Center(
                  child: Text(
                    "OR",
                    style: TextStyle(
                        color: AppColors.blackColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w700),
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                PlatformButton(
                  onPressed: () {
                    this._getLocation(context);
                  },
                  child: Text(
                    "Use my location\n(Recommended)",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: AppColors.blueColor,
                        fontSize:
                            AppConfig.heightWithDForSmallDevice(context, 24, 6),
                        fontWeight: FontWeight.w700),
                  ),
                  color: Colors.white,
                  disabledColor: Colors.white,
                  materialFlat: (_, __) => MaterialFlatButtonData(
                      color: Colors.white, disabledColor: Colors.white),
                ),
                SizedBox(
                  height: 10,
                ),
                SizedBox(
                  height: 15,
                ),
                Center(
                  child: Text(
                    this.error,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.redColor),
                  ),
                ),
                Expanded(
                  child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                      child: (loading)
                          ? Center(child: PlatformCircularProgressIndicator())
                          : Align(
                              alignment: Alignment.bottomCenter,
                              child: SizedBox(
                                height: 60,
                                child: PlatformButton(
                                    onPressed:
                                        (this._location.trim().length > 0)
                                            ? () {
                                                this._setLocation();
                                              }
                                            : null,
                                    color: AppColors.blueColor,
                                    disabledColor: AppColors.disabledBlueColor,
                                    materialFlat: (_, __) =>
                                        MaterialFlatButtonData(
                                          color: AppColors.blueColor,
                                          disabledColor:
                                              AppColors.disabledBlueColor,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                    cupertinoFilled: (_, __) =>
                                        CupertinoFilledButtonData(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                    child: Text(
                                      "Save Changes",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize:
                                            (AppConfig.fullHeight(context) >=
                                                    667)
                                                ? 20
                                                : 15,
                                      ),
                                    )),
                              ))),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
