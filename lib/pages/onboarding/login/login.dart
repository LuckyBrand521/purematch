import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:pure_match/common/global.dart';
import 'package:pure_match/common/loading.dart';
import 'package:pure_match/common/myfirebase.dart';
import 'package:pure_match/pages/AppColors.dart';
import 'package:pure_match/pages/MyHttp.dart';
import 'package:flutter/cupertino.dart';
import 'package:amplitude_flutter/amplitude.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:pure_match/pages/onboarding/login/forgot_password.dart';
import 'package:pure_match/pages/onboarding/login/reactivate_account.dart';
import 'package:pure_match/pages/onboarding/login/welcome_back.dart';
import 'package:pure_match/pages/settings/account_settings/successful_deactivate.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Analytics code
  FirebaseAnalytics analytics = FirebaseAnalytics();
  Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';

  String email = "";
  String error = "";
  bool emailValidationCheck = false;
  String password = "";
  bool passwordVisible;
  bool _loading = false;

  @override
  void initState() {
    passwordVisible = false;
    super.initState();
  }

  void _validateEmail() {
    bool validation = false;
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (regex.hasMatch(this.email)) validation = true;
    setState(() {
      this.emailValidationCheck = validation;
    });
  }

  Future<void> _verifyAccountDetails() async {
    setState(() {
      _loading = true;
    });
    var res = await MyHttp.post(
        "login", {"email": this.email, "password": this.password});
    var body = json.decode(res.body);
    if (res.statusCode == 200) {
      print("User verified");
      print(res.body);

      bool status = body["success"];
      if (status == true) {
        String token = body["token"];
        int id = body["Id"];
        // bool newUser = body["newUser"];
        var sp = await SharedPreferences.getInstance();
        await sp.setInt("id", id);
        await sp.setString("token", token);
        _loading = false;
        if (sp.containsKey("loggedIn")) {
          var tokenReq = await MyFirebase.sendFCMToken("users/fcm-token");
          if (tokenReq != null) {
            print("FCm token send response:::::::::");
            print(tokenReq.statusCode);
            print(tokenReq.body);
          }
        }
        Global.currentUser = null;
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => WelcomeBack(
                      isFromLogin: true,
                    )));
      } else {
        setState(() {
          error = body["message"];
        });
      }
    } else {
      print("User update error: ${res.statusCode}");
      print("User update error: ${res.body}");

      setState(() {
        error = body["message"];
        _loading = false;
      });
      if (error == "Deactivated Account") {
        int id = body["Id"];
        String token = body["token"];
        var sp = await SharedPreferences.getInstance();
        await sp.setInt("id", id);
        await sp.setString("token", token);
        _loading = false;
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    ReactivateAccount(id, this.email, this.password)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return PlatformScaffold(
        appBar: PlatformAppBar(
          material: (_, __) => MaterialAppBarData(
            elevation: 0.0,
            backgroundColor: Colors.white,
            leading: IconButton(
              padding: EdgeInsetsDirectional.only(start: 20.0),
              icon: Icon(Icons.arrow_back, color: AppColors.offWhiteColor),
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
          child: Scaffold(
              backgroundColor: Colors.white,
              body: SingleChildScrollView(
                child: SizedBox(
                  height: height - 100,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          //might have to take out the autofill group from here and put it on the individual platformtextfields
                          AutofillGroup(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                SizedBox(
                                  height: 60,
                                ),
                                Text("Email",
                                    style: TextStyle(
                                        fontSize: 28,
                                        color: AppColors.blackColor,
                                        fontWeight: FontWeight.w600)),
                                SizedBox(
                                  height: 12,
                                ),
                                PlatformTextField(
                                  keyboardType: TextInputType.emailAddress,
                                  autofillHints: [AutofillHints.email],
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: AppColors.blueColor,
                                      fontWeight: FontWeight.w700),
                                  onChanged: (String email) {
                                    this.email = email;
                                    this._validateEmail();
                                    setState(() {
                                      this.error = "";
                                    });
                                  },
                                  material: (_, __) => MaterialTextFieldData(
                                    decoration: InputDecoration(
                                        contentPadding: EdgeInsets.all(0),
                                        enabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: AppColors.blueColor,
                                                width: 2))),
                                  ),
                                  cupertino: (_, __) => CupertinoTextFieldData(
                                    keyboardAppearance: Brightness.light,
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                            color: AppColors.blueColor,
                                            width: 2),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 30,
                                ),
                                Text("Password",
                                    style: TextStyle(
                                        fontSize: 28,
                                        color: AppColors.blackColor,
                                        fontWeight: FontWeight.w600)),
                                SizedBox(
                                  height: 12,
                                ),
                                PlatformTextField(
                                  keyboardType: TextInputType.visiblePassword,
                                  autofillHints: [AutofillHints.password],
                                  obscureText: !passwordVisible,
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: AppColors.blackColor,
                                      fontWeight: FontWeight.w600),
                                  onChanged: (String pwd) {
                                    setState(() {
                                      this.password = pwd;
                                      this.error = "";
                                    });
                                  },
                                  material: (_, __) => MaterialTextFieldData(
                                    decoration: InputDecoration(
                                        contentPadding: EdgeInsets.all(0),
                                        suffixIcon: IconButton(
                                          iconSize: 20,
                                          icon: Icon(
                                            // Based on passwordVisible state choose the icon
                                            passwordVisible
                                                ? Icons.visibility
                                                : Icons.visibility_off,
                                            color: AppColors.blackColor,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              passwordVisible =
                                                  !passwordVisible;
                                            });
                                          },
                                        ),
                                        enabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: AppColors.blueColor,
                                                width: 2))),
                                  ),
                                  cupertino: (_, __) => CupertinoTextFieldData(
                                    suffix: IconButton(
                                      iconSize: 20,
                                      icon: Icon(
                                        // Based on passwordVisible state choose the icon
                                        passwordVisible
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                        color: AppColors.blackColor,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          passwordVisible = !passwordVisible;
                                        });
                                      },
                                    ),
                                    keyboardAppearance: Brightness.light,
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                            color: AppColors.blueColor,
                                            width: 2),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10),
                                Center(
                                  child: Text(
                                    this.error,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                        color: Colors.redAccent),
                                  ),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Padding(
                                  padding:
                                      EdgeInsetsDirectional.only(bottom: 20),
                                  child: Center(
                                    child: SizedBox(
                                      width: 220,
                                      height: 60,
                                      child: (this._loading)
                                          ? Loading.showLoading()
                                          : PlatformButton(
                                              onPressed:
                                                  (this.emailValidationCheck &&
                                                          this.password !=
                                                              null &&
                                                          this
                                                              .password
                                                              .isNotEmpty)
                                                      ? () {
                                                          (_loading == false)
                                                              ? this
                                                                  ._verifyAccountDetails()
                                                              : null;
                                                        }
                                                      : null,
                                              color: AppColors.blueColor,
                                              disabledColor:
                                                  AppColors.disabledBlueColor,
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 20),
                                              materialFlat: (_, __) =>
                                                  MaterialFlatButtonData(
                                                    color: AppColors.blueColor,
                                                    disabledColor: AppColors
                                                        .disabledBlueColor,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                  ),
                                              cupertinoFilled: (_, __) =>
                                                  CupertinoFilledButtonData(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                              child: Text(
                                                "Continue",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 16),
                                              )),
                                    ),
                                  ),
                                ),
                                Center(
                                  child: InkWell(
                                      child: Text("Forgot Password",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: AppColors.blueColor,
                                              fontWeight: FontWeight.w600,
                                              fontStyle: FontStyle.normal,
                                              decoration:
                                                  TextDecoration.underline)),
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    ForgotPassword()));
                                        //Analytics code
                                        analytics.setCurrentScreen(
                                            screenName: "forgot_password",
                                            screenClassOverride:
                                                "forgot_password");
                                        amplitudeAnalytics
                                            .logEvent("forgot_password_page");
                                      }),
                                ),
                              ],
                            ),
                          ),
                        ]),
                  ),
                ),
              )),
        ));
  }
}
