import 'dart:ui';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:amplitude_flutter/amplitude.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UnfriendOverlay extends StatefulWidget {
  @override
  _UnfriendOverlayState createState() => _UnfriendOverlayState();
}

class _UnfriendOverlayState extends State<UnfriendOverlay> {
  // Analytics code
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';
  displayIOSDialogUnfriendMe() {
    showDialog(
      context: context,
      builder: (BuildContext context) => new CupertinoAlertDialog(
        title: new Text("Unfriend"),
        content: new Text("Are you sure you want to unfriend Jon "),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: new Text(
              "Unfriend",
              style: TextStyle(color: Colors.red),
            ),
            onPressed: () {
              Navigator.pop(context, 'Discard');
              //Analytics tracking code
              analytics.logEvent(
                  name: "unfriend",
                  parameters: <String, dynamic>{'unfriend': 'unfriend'});

              amplitudeAnalytics.logEvent("unfriend",
                  eventProperties: {'unfriend': 'unfriend'});
              showDialog(
                context: context,
                builder: (BuildContext context) => new CupertinoAlertDialog(
                  title: Text("Unfriend Sucessful"),
                  content: new Text(
                    "You are no longer friends with john.",
                    textAlign: TextAlign.center,
                  ),
                  actions: <Widget>[
                    CupertinoDialogAction(
                        isDefaultAction: true, child: new Text("Close")),
                  ],
                ),
              );
            },
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: new Text(
              "Report User",
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
            ),
            onPressed: () {
              Navigator.pop(context, 'Discard');
            },
          ),
          CupertinoDialogAction(
              isDefaultAction: true, child: new Text("Cancel")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
