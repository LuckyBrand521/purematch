import 'dart:html';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MatchOverlay extends StatefulWidget {
  @override
  _MatchOverlayState createState() => _MatchOverlayState();
}

class _MatchOverlayState extends State<MatchOverlay> {
  Future<void> _handleClickMe() async {
    return showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          message: Text("John's Profile"),
          actions: <Widget>[
            CupertinoActionSheetAction(
              child: Text('Send Friend Request'),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) => new CupertinoAlertDialog(
                      title: new Text("Friend Request Sent"),
                      content: new Text(
                          "John will be notified you want to be friends"),
                      actions: [
                        CupertinoDialogAction(
                            isDefaultAction: true,
                            child: new Text(
                              "Close",
                            ),
                            onPressed: () {
                              Navigator.pop(context, 'Discard');
                            })
                      ]),
                );
              },
            ),
            CupertinoActionSheetAction(
              child: Text('Suggest as Friend'),
              onPressed: () {/** */},
            ),
            CupertinoActionSheetAction(
              child: Text('Suggest as Match'),
              onPressed: () {/** */},
            ),
            CupertinoActionSheetAction(
              child: Text(
                'Unmatch',
                style: TextStyle(color: Colors.red),
              ),
              isDestructiveAction: true,
              onPressed: () {/** */},
            ),
            CupertinoActionSheetAction(
              child: Text(
                'Report',
                style: TextStyle(color: Colors.red),
              ),
              isDestructiveAction: true,
              onPressed: () {/** */},
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            isDefaultAction: true,
            child: Text('Cancel'),
            onPressed: () {/** */},
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
