import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:amplitude_flutter/amplitude.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:intl/intl.dart';
import 'package:pure_match/pages/AppColors.dart';
import 'package:pure_match/pages/MyHttp.dart';
import 'package:sailor/sailor.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../routes.dart';

class SuccessfulDeactivatePage extends StatefulWidget {
  @override
  _SuccessfulDeactivatePageState createState() =>
      _SuccessfulDeactivatePageState();
}

class _SuccessfulDeactivatePageState extends State<SuccessfulDeactivatePage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          padding: EdgeInsets.symmetric(horizontal: 15),
          color: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: Container()),
              SizedBox(
                height: 200,
                width: 200,
                child: Image.asset(
                    "assets/images/Pure_Match_Logo_(blue_transparent).png"),
              ),
              Text(
                "Account Deactivated Successfully",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: AppColors.blueColor,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "Log in to reactivate your account",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                  color: AppColors.blackTxtColor,
                ),
                textAlign: TextAlign.center,
              ),
              Expanded(child: Container()),
              Container(
                height: 60,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(32, 0, 32, 10),
                  child: PlatformButton(
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    color: AppColors.blueColor,
                    onPressed: () {
                      Routes.sailor.navigate("/main",
                          navigationType: NavigationType.pushAndRemoveUntil,
                          removeUntilPredicate: (Route<dynamic> route) =>
                              false);
                    },
                    child: Text(
                      "OK",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
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
              SizedBox(
                height: 30,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
