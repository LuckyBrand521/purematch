import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:location/location.dart';
import 'package:pure_match/pages/AppColors.dart';
import 'package:pure_match/pages/MyHttp.dart';
import 'package:pure_match/pages/profile/edit_content.dart';
import 'package:amplitude_flutter/amplitude.dart';

class EditLocation extends StatefulWidget {
  final String _location;

  EditLocation(this._location);

  @override
  _EditLocationState createState() => _EditLocationState();
}

class _EditLocationState extends State<EditLocation> {
  // Analytics code
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';

  String _location;
  int _visibility = 0;
  String error = "";
  bool loading = false;

  var _churchTxtCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _location = widget._location;
    _churchTxtCtrl.text = _location;
    super.initState();
    // Analytics tracking code
    amplitudeAnalytics.init(apiKey);
    analytics.setCurrentScreen(
        screenName: "edit_location", screenClassOverride: "edit_location");
    amplitudeAnalytics.logEvent("edited_profile");
  }

  void _getLocation(BuildContext context) async {
    setState(() {
      loading = true;
    });
    Location location = new Location();

    bool _serviceEnabled;

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
  }

  Future<void> _setLocation() async {
    var res = await MyHttp.put("users",
        {"location": this._location, "location_visibility": this._visibility});
    if (res.statusCode == 200) {
      //Analytics tracking code
      analytics.logEvent(
          name: "edited_profile",
          parameters: <String, dynamic>{'location': this._location});
      amplitudeAnalytics.logEvent("edited_profile",
          eventProperties: {'location': this._location});

      print("User updated");
      print(res.body);
      Navigator.pop(context, {"location": this._location});
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
    final height = MediaQuery.of(context).size.height;
    return EditContent(
        text: "Edit Location",
        body: Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
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
                          Text("Location", style: TextStyle(fontSize: 28)),
                          TextFormField(
                            validator: (value) {
                              if (value.trim().isEmpty) {
                                return 'Please enter location';
                              }
                              return null;
                            },
                            controller: _churchTxtCtrl,
                            textCapitalization: TextCapitalization.words,
                            style: TextStyle(fontSize: 22, color: Colors.black),
                            onChanged: (String value) {
                              this._location = value;
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
                                        color: AppColors.redColor, width: 2))),
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
                          this._getLocation(context);
                        },
                        child: Text(
                          "Use My Location",
                          style: TextStyle(
                              color: AppColors.redColor,
                              decoration: TextDecoration.underline),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: height * 0.3,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 25.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "Visibility",
                            style: TextStyle(fontSize: 24),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0, top: 10),
                            child: Row(
                              children: <Widget>[
                                SizedBox(
                                  width: 160,
                                  child: FlatButton(
                                      onPressed: () {
                                        setState(() {
                                          this._visibility = 0;
                                        });
                                      },
                                      color: (this._visibility == 0)
                                          ? AppColors.redColor
                                          : AppColors
                                              .profileEditVisibilityBt2BG,
                                      padding:
                                          EdgeInsets.symmetric(vertical: 10),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(10),
                                            bottomLeft: Radius.circular((10))),
                                      ),
                                      child: Text(
                                        "Everyone",
                                        style: TextStyle(
                                            color: (this._visibility == 0)
                                                ? Colors.white
                                                : AppColors.redColor,
                                            fontSize: 14,
                                            fontWeight: FontWeight.normal),
                                        textAlign: TextAlign.center,
                                      )),
                                ),
                                SizedBox(
                                  width: 160,
                                  child: FlatButton(
                                      onPressed: () {
                                        setState(() {
                                          this._visibility = 1;
                                        });
                                      },
                                      color: (this._visibility == 1)
                                          ? AppColors.redColor
                                          : AppColors
                                              .profileEditVisibilityBt2BG,
                                      padding:
                                          EdgeInsets.symmetric(vertical: 10),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(10),
                                            bottomRight: Radius.circular((10))),
                                      ),
                                      child: Text(
                                        "Only Matches",
                                        style: TextStyle(
                                            color: (this._visibility == 1)
                                                ? Colors.white
                                                : AppColors.redColor,
                                            fontSize: 14,
                                            fontWeight: FontWeight.normal),
                                        textAlign: TextAlign.center,
                                      )),
                                )
                              ],
                            ),
                          ),
                          (loading)
                              ? PlatformCircularProgressIndicator()
                              : Container(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
