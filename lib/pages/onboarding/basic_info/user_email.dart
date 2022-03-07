import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:amplitude_flutter/amplitude.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pure_match/common/RoundIndicators.dart';
import 'package:pure_match/common/global.dart';
import 'package:pure_match/pages/AppColors.dart';
import 'package:pure_match/pages/MyHttp.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../NewQuestions.dart';

class UserEmail extends StatefulWidget {
  validatePassword() => createState()._validatePassword();

  @override
  _UserEmailState createState() => _UserEmailState();
}

class _UserEmailState extends State<UserEmail>
    with SingleTickerProviderStateMixin {
  // Analytics code
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';

  String email = "";
  String error = "";
  String passwordError = "";
  String confirmPasswordError = "";
  bool emailValidationCheck = false;
  bool passwordValidationCheck = false;
  bool confirmPasswordValidationCheck = false;
  String password = "";
  String confirmPassword = "";
  bool showPassword = false;
  bool _loading = false;
  String showHidePasswordText = "Show Password";
  FocusNode _focusNode = FocusNode();
  AnimationController _controller;
  Animation _animation;

  @override
  void initState() {
    Global.setOnboardingId(6);
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _animation = Tween(begin: 300.0, end: 50.0).animate(_controller)
      ..addListener(() {
        setState(() {});
        //Initializing amplitude analytics api key
        amplitudeAnalytics.init(apiKey);
      });

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();

    super.dispose();
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

  void _validatePassword() {
    bool validation = false;
    String pattern = r'^(?=.*?[A-Z])((?=.*?[0-9])|(?=.*?[!@#\$&*~])).{8,}$';
    RegExp regex = new RegExp(pattern);

    if (this.password.isNotEmpty &&
        this.password.length >= 8 &&
        regex.firstMatch(this.password) != null) {
      validation = true;
      setState(() {
        this.passwordError = "";
      });
    } else {
      setState(() {
        this.passwordError =
            "* Minimum of 8 characters with one upper case letter, and one number or special character";
      });
    }

    if (this.confirmPassword.isNotEmpty) {
      if (this.password != this.confirmPassword) {
        setState(() {
          this.confirmPasswordValidationCheck = false;
          this.confirmPasswordError =
              "Passwords must match. Please re-enter your password.";
        });
      } else {
        setState(() {
          this.confirmPasswordValidationCheck = true;
          this.confirmPasswordError = "";
        });
      }
    }

    setState(() {
      this.passwordValidationCheck = validation;
    });
  }

  void _validateConfirmPassword() {
    bool validation = false;
    String error = "";

    if (this.password.isNotEmpty && this.confirmPassword != this.password) {
      validation = false;
      error = "Passwords must match. Please re-enter your password.";
    } else if (this.confirmPassword == this.password) {
      validation = true;
      error = "";
    } else {
      validation = false;
      error = "";
    }

    setState(() {
      this.confirmPasswordValidationCheck = validation;
      this.passwordValidationCheck =
          this.passwordError == "" ? validation : false;
      this.confirmPasswordError = validation ? "" : error;
    });
  }

  Future<void> _setAccountDetails() async {
    setState(() {
      _loading = true;
    });
    var sp = await SharedPreferences.getInstance();
    await sp.setString("email", this.email);

    var res1 = await MyHttp.put("users/update", {"email": this.email});
    var res2 =
        await MyHttp.put("users/update-account", {"password": this.password});
    if (res1.statusCode == 200 && res2.statusCode == 200) {
      //Analytics tracking code
      analytics.logEvent(
          name: "saved_email",
          parameters: <String, dynamic>{'user_email': this.email});
      amplitudeAnalytics
          .logEvent("saved_email", eventProperties: {'user_email': this.email});

      print("User updated - email & password");
      print(res1.body);
      print(res2.body);
      _loading = false;
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => NewQuestions()));

      // Analytics tracking code
      analytics.setCurrentScreen(
          screenName: 'onbording_user_name',
          screenClassOverride: 'onbording_user_name');
      amplitudeAnalytics.logEvent("onbording_user_name_page");
    } else {
      print("User update error: ${res1.statusCode}, ${res2.statusCode}");
      print("User update error: ${res1.body}, ${res2.body}");
      setState(() {
        if (res1.statusCode != 200) {
          var body = json.decode(res1.body);
          error = body["message"] ?? "error";
        } else if (res2.statusCode != 200) {
          var body = json.decode(res2.body);
          error = body["message"] ?? "error";
        }
        // error = res1.body + res2.body;
        _loading = false;
      });
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
              //Analytics code
              analytics.setCurrentScreen(
                  screenName: "thank_you_questions",
                  screenClassOverride: "thank_you_questions");
              amplitudeAnalytics.logEvent("thank_you_questions_page");
            },
          ),
        ),
        cupertino: (_, __) => CupertinoNavigationBarData(
            brightness: Brightness.dark,
            automaticallyImplyLeading: false,
            automaticallyImplyMiddle: false,
            backgroundColor: Colors.white,
            border: Border(bottom: BorderSide.none),
            padding: EdgeInsetsDirectional.only(start: 10.0),
            leading: CupertinoNavigationBarBackButton(
                color: AppColors.offWhiteColor,
                previousPageTitle: null,
                onPressed: () {
                  Navigator.pop(context);
                  // Analytics
                  analytics.setCurrentScreen(
                      screenName: "thank_you_questions",
                      screenClassOverride: "thank_you_questions");
                  amplitudeAnalytics.logEvent("thank_you_questions_page");
                })),
      ),
      body: SafeArea(
          child: Scaffold(
        backgroundColor: Colors.white,
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: SingleChildScrollView(
            child: SizedBox(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    AutofillGroup(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(
                            height: ScreenUtil().setHeight(20),
                          ),
                          RoundIndicators(
                            currentIndicatorIndex: 0,
                            numberOfInidcators: 14,
                            circleSize: 12,
                          ),
                          SizedBox(
                            height: height * 0.01,
                          ),
                          Text("Create your free account",
                              style: TextStyle(
                                  fontSize: AppConfig.heightWithDForSmallDevice(
                                      context, 27, 4),
                                  color: AppColors.blackColor,
                                  fontWeight: FontWeight.w600)),
                          SizedBox(
                            height: height * 0.05,
                          ),
                          Text("Email",
                              style: TextStyle(
                                  fontSize: AppConfig.heightWithDForSmallDevice(
                                      context, 28, 4),
                                  color: AppColors.blackColor,
                                  fontWeight: FontWeight.w600)),
                          SizedBox(
                            height: height * 0.02,
                          ),
                          AutofillGroup(
                            child: PlatformTextField(
                              keyboardType: TextInputType.emailAddress,
                              autofillHints: [AutofillHints.email],
                              style: TextStyle(
                                  fontSize: AppConfig.heightWithDForSmallDevice(
                                      context, 18, 4),
                                  color: AppColors.blueColor,
                                  fontWeight: FontWeight.w700),
                              onChanged: (String email) {
                                this.email = email;
                                this._validateEmail();
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
                                        color: AppColors.blueColor, width: 2),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: AppConfig.heightWithDForSmallDevice(
                                context, 30, 10),
                          ),
                          Text("Create a Password",
                              style: TextStyle(
                                  fontSize: AppConfig.heightWithDForSmallDevice(
                                      context, 28, 4),
                                  color: AppColors.blackColor,
                                  fontWeight: FontWeight.w600)),
                          SizedBox(
                            height: ScreenUtil().setHeight(10),
                          ),
                          PlatformTextField(
                            keyboardType: TextInputType.visiblePassword,
                            autofillHints: [AutofillHints.password],
                            onEditingComplete: () =>
                                TextInput.finishAutofillContext(),
                            obscureText: !this.showPassword,
                            style: TextStyle(
                                fontSize: AppConfig.heightWithDForSmallDevice(
                                    context, 18, 4),
                                color: AppColors.blackColor,
                                fontWeight: FontWeight.w600),
                            onChanged: (String pwd) {
                              this.password = pwd;
                              _validatePassword();
                            },
                            material: (_, __) => MaterialTextFieldData(
                              decoration: InputDecoration(
                                  suffixIcon: IconButton(
                                    iconSize: 20,
                                    icon: Icon(
                                      // Based on passwordVisible state choose the icon
                                      showPassword
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: AppColors.offWhiteColor,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        showPassword = !showPassword;
                                      });
                                    },
                                  ),
                                  contentPadding: EdgeInsets.all(0),
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
                                  showPassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: AppColors.offWhiteColor,
                                ),
                                onPressed: () {
                                  setState(() {
                                    showPassword = !showPassword;
                                  });
                                },
                              ),
                              keyboardAppearance: Brightness.light,
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                      color: AppColors.blueColor, width: 2),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: ScreenUtil().setHeight(5)),
                          Visibility(
                            visible: this.passwordError != "",
                            child: Center(
                              child: Text(
                                //this.passwordError != "" ? this.passwordError : "",
                                this.passwordError,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.redColor),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: ScreenUtil().setHeight(25),
                          ),
                          Text("Confirm Password",
                              style: TextStyle(
                                  fontSize: AppConfig.heightWithDForSmallDevice(
                                      context, 28, 4),
                                  color: AppColors.blackColor,
                                  fontWeight: FontWeight.w600)),
                          SizedBox(
                            height: ScreenUtil().setHeight(12),
                          ),
                          PlatformTextField(
                            keyboardType: TextInputType.visiblePassword,
                            obscureText: !this.showPassword,
                            style: TextStyle(
                                fontSize: AppConfig.heightWithDForSmallDevice(
                                    context, 18, 4),
                                color: AppColors.blackColor,
                                fontWeight: FontWeight.w600),
                            onChanged: (String confirmPwd) {
                              this.confirmPassword = confirmPwd;
                              _validateConfirmPassword();
                            },
                            material: (_, __) => MaterialTextFieldData(
                              decoration: InputDecoration(
                                  suffixIcon: IconButton(
                                    iconSize: 20,
                                    icon: Icon(
                                      // Based on passwordVisible state choose the icon
                                      showPassword
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: AppColors.offWhiteColor,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        showPassword = !showPassword;
                                      });
                                    },
                                  ),
                                  contentPadding: EdgeInsets.all(0),
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
                                  showPassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: AppColors.offWhiteColor,
                                ),
                                onPressed: () {
                                  setState(() {
                                    showPassword = !showPassword;
                                  });
                                },
                              ),
                              keyboardAppearance: Brightness.light,
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                      color: AppColors.blueColor, width: 2),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: ScreenUtil().setHeight(10),
                          ),
                          Text(
                            this.confirmPasswordError,
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: AppColors.redColor),
                          ),
                        ],
                      ),
                    ),

                    //      this.showPassword = !this.showPassword;

                    SizedBox(height: ScreenUtil().setHeight(10)),
                    Center(
                      child: Text(
                        this.error,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: AppColors.redColor),
                      ),
                    ),
                    SizedBox(
                      height: ScreenUtil().setHeight(height * 0.1),
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.only(bottom: 20),
                      child: Center(
                        child: SizedBox(
                          width: 220,
                          height: 60,
                          child: PlatformButton(
                              onPressed: (this.emailValidationCheck &&
                                      this.passwordValidationCheck &&
                                      this.confirmPasswordValidationCheck)
                                  ? () {
                                      (_loading == false)
                                          ? this._setAccountDetails()
                                          : null;
                                    }
                                  : null,
                              color: AppColors.blueColor,
                              disabledColor: AppColors.disabledBlueColor,
                              padding: EdgeInsets.symmetric(vertical: 20),
                              materialFlat: (_, __) => MaterialFlatButtonData(
                                    color: AppColors.blueColor,
                                    disabledColor: AppColors.disabledBlueColor,
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
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16),
                              )),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      )),
    );
  }
}
