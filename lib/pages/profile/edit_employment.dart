import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:amplitude_flutter/amplitude.dart';
import 'package:pure_match/pages/AppColors.dart';
import 'package:pure_match/pages/profile/edit_content.dart';

class EditEmployment extends StatefulWidget {
  final String position;
  final String employer;

  EditEmployment(this.position, this.employer);

  @override
  _EditEmploymentState createState() => _EditEmploymentState();
}

class _EditEmploymentState extends State<EditEmployment> {
  // Analytics code
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';

  String position;
  String employer;
  String error;

  int visibility = 0;

  var positionTxtCtrl = TextEditingController();
  var employerTxtCtrl = TextEditingController();

  @override
  void initState() {
    positionTxtCtrl.text = widget.position;
    employerTxtCtrl.text = widget.employer;
    position = widget.position;
    employer = widget.employer;
    super.initState();
    // Analytics tracking code
    amplitudeAnalytics.init(apiKey);
    analytics.setCurrentScreen(
        screenName: "edit_employment", screenClassOverride: "edit_employment");
    amplitudeAnalytics.logEvent("edit_employment_page");
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return EditContent(
        text: "Edit Employment",
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
                          Text("Position", style: TextStyle(fontSize: 28)),
                          TextFormField(
                              validator: (value) {
                                if (value.trim().isEmpty) {
                                  return 'Please enter position';
                                }
                                return null;
                              },
                              controller: positionTxtCtrl,
                              style:
                                  TextStyle(fontSize: 22, color: Colors.black),
                              onChanged: (String position) {
                                this.position = position;
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
                                          width: 2)))),
                          SizedBox(
                            height: 50,
                          ),
                          Text("Employer", style: TextStyle(fontSize: 28)),
                          TextFormField(
                            validator: (value) {
                              if (value.trim().isEmpty) {
                                return 'Please enter employer';
                              }
                              return null;
                            },
                            controller: employerTxtCtrl,
                            style: TextStyle(fontSize: 22, color: Colors.black),
                            onChanged: (String employer) {
                              this.employer = employer;
                            },
                            textCapitalization: TextCapitalization.words,
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.all(0.0),
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
                      height: 50,
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
                                          this.visibility = 0;
                                        });
                                      },
                                      color: (this.visibility == 0)
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
                                            color: (this.visibility == 0)
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
                                          this.visibility = 1;
                                        });
                                      },
                                      color: (this.visibility == 1)
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
                                            color: (this.visibility == 1)
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
