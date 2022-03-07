import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:pure_match/pages/AppColors.dart';
import 'package:pure_match/pages/MyHttp.dart';
import 'package:pure_match/pages/profile/edit_content.dart';
import 'package:amplitude_flutter/amplitude.dart';

class EditChurch extends StatefulWidget {
  final String _church;

  EditChurch(this._church);

  @override
  _EditChurchState createState() => _EditChurchState();
}

class _EditChurchState extends State<EditChurch> {
  // Analytics code
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';

  String _church;
  int _visibility = 0;
  String error = "";

  var _churchTxtCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _church = widget._church;
    _churchTxtCtrl.text = _church;
    super.initState();
    // Analytics tracking code
    amplitudeAnalytics.init(apiKey);
    analytics.setCurrentScreen(
        screenName: "edit_church", screenClassOverride: "edit_church");
    amplitudeAnalytics.logEvent("edit_church_page");
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return EditContent(
        text: "Edit Church",
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
                          Text("Church", style: TextStyle(fontSize: 28)),
                          TextFormField(
                            validator: (value) {
                              if (value.trim().isEmpty) {
                                return 'Please enter church';
                              }
                              return null;
                            },
                            controller: _churchTxtCtrl,
                            style: TextStyle(fontSize: 22, color: Colors.black),
                            textCapitalization: TextCapitalization.words,
                            onChanged: (String value) {
                              this._church = value;
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
                          SizedBox(
                            height: height * 0.35,
                          ),
                        ],
                      ),
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
                          )
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
