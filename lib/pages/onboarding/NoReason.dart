// this is the page to get the answer from the user why is he saying no..

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pure_match/pages/AppColors.dart';
import 'package:flutter/cupertino.dart';

class NoReason extends StatefulWidget {
  @override
  _NoReasonState createState() => _NoReasonState();
}

class _NoReasonState extends State<NoReason> {
  bool buttonDisabled = true;
  String noReason;
  int _charCount = 0;
  int wordCount;
  final whitespaces = RegExp(r'\s+', multiLine: true);

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    var borderSideProperty =
        BorderSide(color: AppColors.noExplaintationBorderColor, width: 1.5);
    return PlatformScaffold(
      backgroundColor: Colors.white,
      appBar: PlatformAppBar(
        material: (_, __) => MaterialAppBarData(
          backgroundColor: Colors.white,
          elevation: 0.0,
          leading: IconButton(
            padding: EdgeInsetsDirectional.only(start: 10.0),
            icon: Icon(
              Icons.arrow_back,
              color: AppColors.offWhiteColor,
              size: 25,
            ),
            iconSize: 30,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        cupertino: (_, __) => CupertinoNavigationBarData(
            automaticallyImplyLeading: false,
            automaticallyImplyMiddle: false,
            backgroundColor: Colors.white,
            border: Border(bottom: BorderSide.none),
            padding: EdgeInsetsDirectional.only(start: 10.0),
            leading: CupertinoNavigationBarBackButton(
                color: AppColors.offWhiteColor,
                previousPageTitle: null,
                onPressed: () => Navigator.pop(context))),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 0, horizontal: 30),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  height: 10,
                ),
                Text(
                  "Please, in a few words, explain why your answer is No.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 28,
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.w600,
                      color: AppColors.blackColor),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  height: ScreenUtil().setHeight(height),
                  child: Scaffold(
                      body: Column(
                    children: <Widget>[
                      PlatformTextField(
                        maxLengthEnforcement: MaxLengthEnforcement.enforced,
                        maxLength: 100,
                        maxLines: 10,
                        style: TextStyle(
                            fontSize: 18,
                            fontStyle: FontStyle.normal,
                            fontWeight: FontWeight.w400,
                            color: AppColors.blackColor),
                        onChanged: (String text) {
                          noReason = text;

                          setState(() {
                            // _charCount = text.split(whitespaces).length;
                            _charCount = text.length;
                            buttonDisabled = _charCount > 100 ? false : true;
                            buttonDisabled = _charCount > 0 ? false : true;
                          });
                        },
                        material: (_, __) => MaterialTextFieldData(
                          decoration: InputDecoration(
                            hintText: "Type here...",
                            hintStyle: TextStyle(
                                fontSize: 15,
                                fontStyle: FontStyle.normal,
                                fontWeight: FontWeight.w400,
                                color: AppColors.blackColor),
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
                            placeholder: "Type here...",
                            placeholderStyle: TextStyle(
                                fontSize: 15,
                                fontStyle: FontStyle.normal,
                                fontWeight: FontWeight.w400,
                                color: AppColors.blackColor),
                            keyboardAppearance: Brightness.light,
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: AppColors.blueColor, width: 2.0),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)))),
                      ),
                      Text(_charCount.toString() + "/500 characters",
                          style: TextStyle(
                              fontSize: 18.0, color: AppColors.blueColor)),
                    ],
                  )),
                ),
                SizedBox(
                  height: 20,
                ),
                Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                        padding: EdgeInsetsDirectional.only(bottom: 35),
                        child: SizedBox(
                            height: 60,
                            width: 200,
                            child: PlatformButton(
                                onPressed: this.buttonDisabled
                                    ? null
                                    : () {
                                        Navigator.pop(context,
                                            {"noReason": this.noReason});
                                      },
                                padding: EdgeInsets.symmetric(vertical: 20),
                                color: AppColors.blueColor,
                                disabledColor: AppColors.disabledBlueColor,
                                materialFlat: (_, __) => MaterialFlatButtonData(
                                      color: AppColors.blueColor,
                                      disabledColor:
                                          AppColors.disabledBlueColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                cupertinoFilled: (_, __) =>
                                    CupertinoFilledButtonData(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                child: Text(
                                  "Continue",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontStyle: FontStyle.normal,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16.0),
                                )))))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
