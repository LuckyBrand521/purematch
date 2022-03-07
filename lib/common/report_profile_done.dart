import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:pure_match/pages/AppColors.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:amplitude_flutter/amplitude.dart';
import 'package:sailor/sailor.dart';

import '../routes.dart';

class ReportProfileDone extends StatefulWidget {
  final String name;
  final String imageUrl;
  final int onSuccessShowTab;

  const ReportProfileDone(
      {Key key, this.name, this.imageUrl, this.onSuccessShowTab})
      : super(key: key);
  @override
  _ReportProfileDoneState createState() => _ReportProfileDoneState();
}

class _ReportProfileDoneState extends State<ReportProfileDone> {
  // Analytics code
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';

  @override
  Widget build(BuildContext context) {
    //Initializing amplitude analytics api key
    amplitudeAnalytics.init(apiKey);

    double h = MediaQuery.of(context).size.height;
    return PlatformScaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 40),
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 10,
                ),
                Text(
                  widget.name ?? "Name",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
                ),
                SizedBox(
                  height: 5,
                ),
                ClipRRect(
                    borderRadius: BorderRadius.circular(20.0),
                    child: CachedNetworkImage(
                      height: 100,
                      imageUrl: widget.imageUrl ??
                          "https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&w=1000&q=80",
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    )),
                SizedBox(
                  height: 20,
                ),
                Text(
                  "Reported!",
                  style: TextStyle(
                      color: AppColors.redColor,
                      fontSize: 36,
                      fontWeight: FontWeight.w600),
                ),
                SizedBox(
                  height: 20,
                ),
                Text("Our support team will look into it.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                    )),
                SizedBox(
                  height: 20,
                ),
                Text(
                    "Thank you for helping us keep Pure Match safe for everyone.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                    )),
                SizedBox(
                  height: h * 0.22,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 0, vertical: 20),
                  child: SizedBox(
                    //width: double.infinity,
                    height: 60,
                    child: PlatformButton(
                      color: AppColors.blueColor,
                      onPressed: () {
                        Routes.sailor.navigate("/homes",
                            params: {'tabIndex': widget.onSuccessShowTab},
                            navigationType: NavigationType.pushAndRemoveUntil,
                            removeUntilPredicate: (Route<dynamic> route) =>
                                false);
                        //Analytics tracking code
                        analytics.setCurrentScreen(
                            screenName: "messages_all",
                            screenClassOverride: "messages_all");
                        amplitudeAnalytics.logEvent('messages_all_page');
                      },
                      child: Text(
                        "Continue",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700),
                      ),
                      materialFlat: (_, __) => MaterialFlatButtonData(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      cupertino: (_, __) => CupertinoButtonData(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
