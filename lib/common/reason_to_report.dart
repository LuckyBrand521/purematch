import 'dart:convert';

import 'dart:ui';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:amplitude_flutter/amplitude.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:pure_match/pages/AppColors.dart';
import 'package:pure_match/pages/MyHttp.dart';
import 'package:pure_match/common/reported_success.dart';
import 'package:pure_match/common/loading.dart';

import 'global.dart';

class ReasonReport extends StatefulWidget {
  final int otherUserId;
  final int onSuccessShowTab;

  const ReasonReport(
      {Key key, @required this.otherUserId, this.onSuccessShowTab})
      : super(key: key);
  @override
  _ReasonReportState createState() => _ReasonReportState();
}

class _ReasonReportState extends State<ReasonReport> {
  String name;
  String imageUrl;
  bool _loading = false;
  bool pressed = true;
  var width;
  var height;

  String reasonText;
  String _selectedOption = "";
  List<String> _options = [
    "Fake/Inappropriate picture(s) ",
    "Harassment or threats",
    "Spam",
    "Other"
  ];

  // Analytics code
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';

  @override
  void initState() {
    this._getUserData();
    super.initState();
    //Initializing amplitude analytics api key
    amplitudeAnalytics.init(apiKey);
    analytics.setCurrentScreen(
        screenName: "report_reason", screenClassOverride: "report_reason");
    amplitudeAnalytics.logEvent('report_reason_page');
  }

  void _getUserData() async {
    try {
      if (this.mounted) {
        setState(() {
          _loading = true;
        });
      }

      int id = widget.otherUserId;
      print(id);
      var res = await MyHttp.get("/users/user/$id");
      if (res.statusCode == 200) {
        var body = json.decode(res.body);
        print(body);
        var user = body["user"];
        if (user != null) {
          name = Global.getFName(user["first_name"]);
          imageUrl = user["ProfilePictureId"];
        }
      } else {
        print("Error: ${res.statusCode}");
      }
    } catch (e) {
      print(e);
    }
    if (this.mounted) {
      setState(() {
        _loading = false;
      });
    }
  }

  void _reportUser() async {
    final data = {
      "reasons_selected": this._options,
      "custom_reason": this.reasonText,
      "reportedUserId": widget.otherUserId
    };

    try {
      var res = await MyHttp.post("/users/report", data);
      if (res.statusCode == 201 || res.statusCode == 200) {
        analytics.logEvent(name: "reported_user", parameters: <String, dynamic>{
          'user': widget.otherUserId,
          "reason": _selectedOption
        });
        amplitudeAnalytics.logEvent('reported_user', eventProperties: {
          'user': widget.otherUserId,
          "reason": _selectedOption
        });
        print(res);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ReportedSucess(
                      name: name,
                      imageUrl: imageUrl,
                    )));
        analytics.setCurrentScreen(
            screenName: "reported_success",
            screenClassOverride: "reported_success");
        amplitudeAnalytics.logEvent('reported_success_page');
      } else {
        print("${res.statusCode}");
      }
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    var borderSideProperty = BorderSide(color: Colors.grey, width: 1);
    return PlatformScaffold(
        backgroundColor: Colors.white,
        appBar: PlatformAppBar(
          leading: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              PlatformIconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: Icon(
                  CupertinoIcons.left_chevron,
                  color: Colors.white,
                ),
                padding: EdgeInsets.only(left: 0, right: 10, top: 5, bottom: 5),
              )
            ],
          ),
          material: (_, __) => MaterialAppBarData(
            backgroundColor: AppColors.offWhiteColor,
            elevation: 0.0,
            title: Text(
              "Report",
              style: TextStyle(
                  fontSize: 22,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontStyle: FontStyle.normal),
            ),
          ),
          cupertino: (_, __) => CupertinoNavigationBarData(
            brightness: Brightness.dark,
            backgroundColor: AppColors.offWhiteColor,
            title: Text(
              "Report",
              style: TextStyle(
                  fontSize: 23,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontStyle: FontStyle.normal),
            ),
            padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 10.0),
          ),
        ),
        body: SafeArea(
          child: (this._loading)
              ? Loading.showLoading()
              : SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Card(
                              semanticContainer: true,
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              shadowColor: Colors.black,
                              elevation: 5,
                              margin: EdgeInsets.all(10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(60),
                              ),
                              child: (imageUrl != null &&
                                      imageUrl.isNotEmpty &&
                                      imageUrl != "na")
                                  ? Image.network(
                                      imageUrl ??
                                          "https://www.computerhope.com/jargon/g/guest-user.jpg",
                                      fit: BoxFit.cover,
                                      height: 160.0,
                                      width: 150.0,
                                    )
                                  : Icon(Icons.person, size: 150),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              name,
                              style: TextStyle(
                                  fontSize: 30, fontWeight: FontWeight.w600),
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 7,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 5),
                        child: Text(
                          "Select one or more reasons to report this user:",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 25,
                              color: Colors.red,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      SizedBox(
                        height: 7,
                      ),
                      Column(
                        children: this
                            ._options
                            .map((e) => this._getOptionButton(e))
                            .toList(),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 0, horizontal: 30),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "Please describe the issue:",
                              style: TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: width * 0.85,
                        child: PlatformTextField(
                          maxLines: 10,
                          onChanged: (a) {
                            this.reasonText = a.trim();
                          },
                          material: (_, __) => MaterialTextFieldData(
                            decoration: InputDecoration(
                              hintText: "Enter Text...",
                              hintStyle: TextStyle(fontSize: 14),
                              contentPadding: const EdgeInsets.all(8.0),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                  borderSide: borderSideProperty),
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                  borderSide: borderSideProperty),
                            ),
                          ),
                          cupertino: (_, __) => CupertinoTextFieldData(
                            placeholder: "Enter Text...",
                            placeholderStyle: TextStyle(fontSize: 14),
                            keyboardAppearance: Brightness.light,
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              border: Border(
                                  left: borderSideProperty,
                                  right: borderSideProperty,
                                  top: borderSideProperty,
                                  bottom: borderSideProperty),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      SizedBox(
                        width: width * 0.85,
                        height: 60,
                        child: FlatButton(
                          padding: EdgeInsets.all(10),
                          onPressed: () {
                            this._reportUser();
                          },
                          color: (this._selectedOption.trim().isNotEmpty)
                              ? Colors.red
                              : Colors.grey[200],
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0)),
                          child: Text("Report",
                              style: TextStyle(
                                  color:
                                      (this._selectedOption.trim().isNotEmpty)
                                          ? Colors.white
                                          : Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w100)),
                        ),
                      ),
                    ],
                  ),
                ),
        ));
  }

  Column _getOptionButton(String text) {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 5,
        ),
        SizedBox(
          width: width * 0.85,
          height: 60,
          child: FlatButton(
            padding: EdgeInsets.all(10),
            onPressed: () {
              setState(() {
                this._selectedOption =
                    (this._selectedOption == text) ? "" : text;
              });
            },
            color:
                (this._selectedOption == text) ? Colors.blue : Colors.grey[200],
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            child: Text(text,
                style: TextStyle(
                    color: (this._selectedOption == text)
                        ? Colors.white
                        : Colors.black,
                    fontSize: 20,
                    fontWeight: (this._selectedOption == text)
                        ? FontWeight.w600
                        : FontWeight.w100)),
          ),
        ),
      ],
    );
  }
}
