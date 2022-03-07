import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:pure_match/pages/AppColors.dart';
import 'package:pure_match/pages/MyHttp.dart';
import 'package:pure_match/pages/MyUrl.dart';
import 'package:pure_match/common/report_profile_done.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:pure_match/common/constants.dart';
import 'package:amplitude_flutter/amplitude.dart';

import 'global.dart';

class ReportProfile extends StatefulWidget {
  final int otherUserId;
  final int onSuccessShowTab;

  const ReportProfile({Key key, this.otherUserId, this.onSuccessShowTab})
      : super(key: key);
  @override
  _ReportProfileState createState() => _ReportProfileState();
}

class _ReportProfileState extends State<ReportProfile> {
  // Analytics code
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';

  String name;
  String imageUrl;
  bool loading = true;
  String error;

  var messageProfileOptions = [
    "Fake/Inappropriate picture(s)",
    "Explicit content",
    "Not Reponding ",
    "Others"
  ];

  var communityProfileOptions = [
    "Fake/Inappropriate picture(s)",
    "Harassment or threats",
    "Spam",
    "Others"
  ];

  var selectedOptions = [];
  String reasonText = "";

  void _selectOptions(String option) {
    if (this.selectedOptions.contains(option)) {
      this.selectedOptions.remove(option);
    } else {
      this.selectedOptions.add(option);
    }
    setState(() {});
  }

  void _getUserData() async {
    try {
      int id = widget.otherUserId;
      var res = await MyHttp.get("/users/user/${id}");
      if (res.statusCode == 200) {
        var body = json.decode(res.body);
        print(body);
        var user = body["user"];
        if (user != null) {
          name = user["first_name"];
          if (widget.onSuccessShowTab == tabs.messaging.index) {
            imageUrl = MyUrl.chatImageUrl(user["ProfilePictureId"]);
          } else {
            imageUrl = user["ProfilePictureId"];
          }
        }
      } else {
        setState(() {
          error = "Not able to get user details.";
        });
      }
    } catch (e) {
      setState(() {
        error = "$e";
      });
    }

    setState(() {
      loading = false;
    });
  }

  void _reportUser() async {
    final data = {
      "reasons_selected": this.selectedOptions,
      "custom_reason": this.reasonText,
      "reportedUserId": widget.otherUserId
    };

    try {
      var res = await MyHttp.post("/users/report", data);
      if (res.statusCode == 201 || res.statusCode == 200) {
        //Analytics tracking code
        analytics
            .logEvent(name: "reported_profile", parameters: <String, dynamic>{
          'reported_user': widget.otherUserId.toString(),
          "reason": this.selectedOptions.removeAt(0),
          "custom_reason": reasonText
        });
        amplitudeAnalytics.logEvent('reported_profile', eventProperties: {
          'reported_user': widget.otherUserId.toString(),
          "reason": this.selectedOptions.removeAt(0),
          "custom_reason": reasonText
        });

        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ReportProfileDone(
                    name: this.name,
                    imageUrl: this.imageUrl,
                    onSuccessShowTab: widget.onSuccessShowTab)));

        //Analytics tracking code
        analytics.setCurrentScreen(
            screenName: "report_profile_done",
            screenClassOverride: "report_profile_done");
        amplitudeAnalytics.logEvent("report_profile_done");
      } else {
        setState(() {
          error = "Not able to report user.";
        });
      }
    } catch (e) {
      setState(() {
        error = "$e";
      });
    }
  }

  @override
  void initState() {
    this._getUserData();
    super.initState();
    //Analytics code
    amplitudeAnalytics.init(apiKey);
    analytics.setCurrentScreen(
        screenName: "report_profile", screenClassOverride: "report_profile");
    amplitudeAnalytics.logEvent("report_profile_page");
  }

  @override
  Widget build(BuildContext context) {
    var optionBtns;
    if (widget.onSuccessShowTab == tabs.messaging.index) {
      optionBtns = messageProfileOptions
          .asMap()
          .map((i, o) =>
              MapEntry(i, _getOption(o, i, this.selectedOptions.contains(o))))
          .values
          .toList();
    } else if (widget.onSuccessShowTab == tabs.feed.index) {
      optionBtns = communityProfileOptions
          .asMap()
          .map((i, o) =>
              MapEntry(i, _getOption(o, i, this.selectedOptions.contains(o))))
          .values
          .toList();
    }
    var borderSideProperty = BorderSide(color: Colors.grey, width: 1);
    return PlatformScaffold(
      appBar: PlatformAppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        material: (_, __) => MaterialAppBarData(
          leading: IconButton(
            padding: EdgeInsetsDirectional.only(start: 10.0),
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back,
              color: Colors.grey,
            ),
          ),
        ),
        cupertino: (_, __) => CupertinoNavigationBarData(
            automaticallyImplyMiddle: false,
            border: Border(bottom: BorderSide.none),
            padding: EdgeInsetsDirectional.only(start: 10.0),
            leading: CupertinoNavigationBarBackButton(
                color: AppColors.offWhiteColor,
                previousPageTitle: null,
                onPressed: () => Navigator.pop(context))),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: SingleChildScrollView(
          child: Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 60),
            child: (loading)
                ? Center(
                    child: PlatformCircularProgressIndicator(),
                  )
                : (error != null)
                    ? Center(
                        child: Text("$error",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w500)))
                    : Column(
                        children: <Widget>[
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: <Widget>[
                              ClipRRect(
                                  borderRadius: BorderRadius.circular(20.0),
                                  child: CachedNetworkImage(
                                    height: 100,
                                    imageUrl: this.imageUrl ??
                                        "https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&w=1000&q=80",
                                    errorWidget: (context, url, error) =>
                                        Icon(Icons.error),
                                  )),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                this.name ?? "User name",
                                style: TextStyle(
                                    fontSize: 28, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Text(
                            "Select one or more\nreasons to report \nthis user:",
                            style: TextStyle(
                                color: AppColors.redColor,
                                fontSize: 28,
                                fontWeight: FontWeight.w600),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Column(
                            children: optionBtns,
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Container(
                              width: double.infinity,
                              child: Text(
                                "Please describe the issue",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600),
                              )),
                          PlatformTextField(
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
                          SizedBox(
                            height: 20,
                          ),
                          SizedBox(
                            width: double.infinity,
                            height: 60,
                            child: PlatformButton(
                              disabledColor: AppColors.greyColor,
                              color: AppColors.redColor,
                              onPressed: (this.selectedOptions.length > 0)
                                  ? () {
                                      this._reportUser();
                                    }
                                  : null,
                              child: Text(
                                "Report",
                                style: TextStyle(
                                    color: this.selectedOptions.length > 0
                                        ? Colors.white
                                        : Colors.grey,
                                    fontWeight: this.selectedOptions.length > 0
                                        ? FontWeight.w700
                                        : FontWeight.w400,
                                    fontSize: 20),
                              ),
                              materialFlat: (_, __) => MaterialFlatButtonData(
                                disabledColor: AppColors.greyColor,
                                color: AppColors.redColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              cupertinoFilled: (_, __) =>
                                  CupertinoFilledButtonData(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          )
                        ],
                      ),
          ),
        ),
      ),
    );
  }

  Column _getOption(String text, int i, bool selected) {
    return Column(
      children: <Widget>[
        Container(
          height: 60,
          width: double.infinity,
          child: FlatButton(
            color: (selected) ? AppColors.blueColor : AppColors.greyColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            onPressed: () {
              this._selectOptions(text);
            },
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: (selected) ? Colors.white : AppColors.blackColor,
                  fontSize: 20),
            ),
          ),
        ),
        SizedBox(
          height: 5,
        )
      ],
    );
  }
}
