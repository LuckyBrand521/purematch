import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pure_match/pages/AppColors.dart';

class ReportedSucess extends StatefulWidget {
  final String name;
  final String imageUrl;
  final int onSuccessShowTab;

  const ReportedSucess(
      {Key key,
      @required this.name,
      @required this.imageUrl,
      this.onSuccessShowTab})
      : super(key: key);
  @override
  _ReportedSucessState createState() => _ReportedSucessState();
}

class _ReportedSucessState extends State<ReportedSucess> {
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
            SafeArea(
              child: Text(
                widget.name ?? "MIKE",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600),
              ),
            ),
            Row(
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
                  child: (widget.imageUrl != null &&
                          widget.imageUrl.isNotEmpty &&
                          widget.imageUrl != "na")
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(20.0),
                          child: CachedNetworkImage(
                            height: 200,
                            width: 200,
                            imageUrl: widget.imageUrl ??
                                "https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&w=1000&q=80",
                            errorWidget: (context, url, error) =>
                                Icon(Icons.error),
                          ))
                      : Icon(Icons.person, size: 200),
                ),
                SizedBox(
                  width: 10,
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              "Reported!",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 35, color: Colors.red, fontWeight: FontWeight.w600),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              "Our support team will look \ninto it",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 25,
                  color: Colors.black,
                  fontWeight: FontWeight.w300),
            ),
            SizedBox(
              height: 30,
            ),
            Text(
              "Thank you for helping us\nkeep Pure Match Safe for\neveryone",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 25,
                  color: Colors.black,
                  fontWeight: FontWeight.w300),
            ),
            SizedBox(
              height: 160,
            ),
            SizedBox(
              width: width * 0.85,
              height: 60,
              child: FlatButton(
                padding: EdgeInsets.all(10),
                color: AppColors.blueColor,
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)),
                child: Text("Continue",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
              ),
            ),
          ])),
    );
  }
}
