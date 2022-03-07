import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:pure_match/common/global.dart';
import 'package:pure_match/pages/AppColors.dart';

class PremiumAd extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
        backgroundColor: AppColors.blueColor,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(10.0),
              child: Column(children: <Widget>[
                SizedBox(
                  height: 30,
                ),
                Center(
                  child: Text(
                    "Pure Match Premium",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Global.premiumTexts(
                  context,
                  Colors.white,
                  AppConfig.fontsizeForSmallDevice(context, 18),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  height: 100,
                  //color: AppColors.redColor,
                  decoration: new BoxDecoration(
                    color: AppColors.redColor,
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.all(Radius.circular(30.0)),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(5.0),
                    child: Row(
                      children: <Widget>[
                        Text(
                          "12 Months",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 20,
                              color: Colors.white),
                        ),
                        SizedBox(
                          width: 2,
                        ),
                        VerticalDivider(thickness: 2, color: Colors.white),
                        SizedBox(
                          width: 2,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              "\$6.99/mo",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 20,
                                  color: Colors.white),
                            ),
                            Container(
                              width: 80,
                              height: 20,
                              decoration: new BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.rectangle,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.0)),
                              ),
                              child: Text(
                                "Save 50%",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: AppColors.redColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14),
                              ),
                            )
                          ],
                        ),
                        SizedBox(
                          width: 2,
                        ),
                        VerticalDivider(thickness: 2, color: Colors.white),
                        SizedBox(
                          width: 2,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  "2500",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 20,
                                      color: Colors.white),
                                ),
                                SizedBox(
                                  width: 2,
                                ),
                                Image.asset(
                                  "assets/images/gem_medium_icon.png",
                                ),
                              ],
                            ),
                            Container(
                              width: 80,
                              height: 20,
                              decoration: new BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.rectangle,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.0)),
                              ),
                              child: Text(
                                "Save 140%",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: AppColors.redColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Container(
                  height: 100,
                  //color: AppColors.redColor,
                  decoration: new BoxDecoration(
                    color: AppColors.noButtonColor,
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.all(Radius.circular(30.0)),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(5.0),
                    child: Row(
                      children: <Widget>[
                        Text(
                          "  6 Months",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 20,
                              color: Colors.white),
                        ),
                        SizedBox(
                          width: 2,
                        ),
                        VerticalDivider(thickness: 2, color: Colors.white),
                        SizedBox(
                          width: 2,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              "\$9.99/mo",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 20,
                                  color: Colors.white),
                            ),
                            Container(
                              width: 80,
                              height: 20,
                              decoration: new BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.rectangle,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.0)),
                              ),
                              child: Text(
                                "Save 35%",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: AppColors.redColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14),
                              ),
                            )
                          ],
                        ),
                        SizedBox(
                          width: 2,
                        ),
                        VerticalDivider(thickness: 2, color: Colors.white),
                        SizedBox(
                          width: 2,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  "2000",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 20,
                                      color: Colors.white),
                                ),
                                SizedBox(
                                  width: 2,
                                ),
                                Image.asset(
                                  "assets/images/gem_medium_icon.png",
                                ),
                              ],
                            ),
                            Container(
                              width: 80,
                              height: 20,
                              decoration: new BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.rectangle,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.0)),
                              ),
                              child: Text(
                                "Save 50%",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: AppColors.redColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Container(
                  height: 100,
                  //color: AppColors.redColor,
                  decoration: new BoxDecoration(
                    color: AppColors.noExplaintationBorderColor,
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.all(Radius.circular(30.0)),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(5.0),
                    child: Row(
                      children: <Widget>[
                        Text(
                          "  3 Months",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 20,
                              color: Colors.white),
                        ),
                        SizedBox(
                          width: 2,
                        ),
                        VerticalDivider(thickness: 2, color: Colors.white),
                        SizedBox(
                          width: 2,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              "\$12.99/mo",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 20,
                                  color: Colors.white),
                            ),
                            Container(
                              width: 80,
                              height: 20,
                              decoration: new BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.rectangle,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.0)),
                              ),
                              child: Text(
                                "Save 15%",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: AppColors.redColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14),
                              ),
                            )
                          ],
                        ),
                        SizedBox(
                          width: 2,
                        ),
                        VerticalDivider(thickness: 2, color: Colors.white),
                        SizedBox(
                          width: 2,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  "1500",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 20,
                                      color: Colors.white),
                                ),
                                SizedBox(
                                  width: 2,
                                ),
                                Image.asset(
                                  "assets/images/gem_medium_icon.png",
                                ),
                              ],
                            ),
                            Container(
                              width: 80,
                              height: 20,
                              decoration: new BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.rectangle,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.0)),
                              ),
                              child: Text(
                                "Save 15%",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: AppColors.redColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Container(
                  height: 100,
                  //color: AppColors.redColor,
                  decoration: new BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.all(Radius.circular(30.0)),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(5.0),
                    child: Row(
                      children: <Widget>[
                        Text(
                          "  Monthly  ",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 20,
                              color: AppColors.offWhiteColor),
                        ),
                        SizedBox(
                          width: 2,
                        ),
                        VerticalDivider(
                            thickness: 2, color: AppColors.greyColor),
                        SizedBox(
                          width: 2,
                        ),
                        Text(
                          "\$14.99/mo",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 20,
                              color: AppColors.offWhiteColor),
                        ),
                        SizedBox(
                          width: 2,
                        ),
                        VerticalDivider(
                            thickness: 2, color: AppColors.greyColor),
                        SizedBox(
                          width: 2,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "500",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 20,
                                  color: AppColors.offWhiteColor),
                            ),
                            SizedBox(
                              width: 2,
                            ),
                            Image.asset(
                              "assets/images/gem_medium_icon.png",
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 40,
                ),
                Center(
                  child: PlatformButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Cancel",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white)),
                    materialFlat: (_, __) => MaterialFlatButtonData(
                      color: AppColors.blueColor,
                    ),
                  ),
                )
              ]),
            ),
          ),
        ));
  }
}
