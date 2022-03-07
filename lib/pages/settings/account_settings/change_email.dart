import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:pure_match/pages/AppColors.dart';
import 'package:pure_match/pages/MyHttp.dart';
import 'package:flutter/cupertino.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:amplitude_flutter/amplitude.dart';
import 'package:url_launcher/url_launcher.dart';

class ChangeEmail extends StatefulWidget {
  final int userId;

  const ChangeEmail({Key key, this.userId}) : super(key: key);

  @override
  _ChangeEmailState createState() => _ChangeEmailState();
}

class _ChangeEmailState extends State<ChangeEmail> {
  // Analytics code
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';

  String error = "";
  String passwordError = "";
  String confirmPasswordError = "";
  bool emailValidationCheck = false;
  bool passwordValidationCheck = false;
  bool confirmPasswordValidationCheck = false;
  bool currentUser = true;
  String password = "";
  String confirmPassword = "";
  bool showPassword = false;
  String showHidePasswordText = "Show Password";
  var prevEmail = "";
  String _newEmail = "";
  bool initialLoading = false;
  bool updateLoading = false;

  // void _validateEmail() {
  //   bool validation = false;
  //   Pattern pattern =
  //       r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
  //   RegExp regex = new RegExp(pattern);
  //   if (regex.hasMatch(this._newEmail)) validation = true;
  //   setState(() {
  //     this.emailValidationCheck = validation;
  //   });
  // }

  // void _validatePassword() {
  //   bool validation = false;
  //   String pattern = r'^(?=.*?[A-Z])((?=.*?[0-9])|(?=.*?[!@#\$&*~])).{8,}$';
  //   RegExp regex = new RegExp(pattern);
  //
  //   if (this.password.isNotEmpty &&
  //       this.password.length >= 8 &&
  //       regex.firstMatch(this.password) != null) {
  //     validation = true;
  //     setState(() {
  //       this.passwordError = "";
  //     });
  //   } else {
  //     setState(() {
  //       this.passwordError =
  //           "Minimum of 8 characters with one upper case letter, and one number or special character.";
  //     });
  //   }
  //
  //   if (this.confirmPassword.isNotEmpty) {
  //     if (this.password != this.confirmPassword) {
  //       setState(() {
  //         this.confirmPasswordValidationCheck = false;
  //         this.confirmPasswordError =
  //             "Passwords must match. Please re-enter your password.";
  //       });
  //     } else {
  //       setState(() {
  //         this.confirmPasswordValidationCheck = true;
  //         this.confirmPasswordError = "";
  //       });
  //     }
  //   }
  //
  //   setState(() {
  //     this.passwordValidationCheck = validation;
  //   });
  // }

  // void _validateConfirmPassword() {
  //   bool validation = false;
  //   String error = "";
  //
  //   if (this.password.isNotEmpty && this.confirmPassword != this.password) {
  //     validation = false;
  //     error = "Passwords must match. Please re-enter your password.";
  //   } else if (this.confirmPassword == this.password) {
  //     validation = true;
  //     error = "";
  //   } else {
  //     validation = false;
  //     error = "";
  //   }
  //
  //   setState(() {
  //     this.confirmPasswordValidationCheck = validation;
  //     this.passwordValidationCheck =
  //         this.passwordError == "" ? validation : false;
  //     this.confirmPasswordError = validation ? "" : error;
  //   });
  // }

  // Future<void> _getEmail() async {
  //   setState(() {
  //     initialLoading = true;
  //   });
  //   var sp = await SharedPreferences.getInstance();
  //   int id = sp.getInt("id");
  //   //int id = 53;
  //   print(id);
  //   if (widget.userId != null) {
  //     if (widget.userId != id) {
  //       currentUser = false;
  //       id = widget.userId;
  //     }
  //   }
  //   try {
  //     var res = await MyHttp.get("users/user/$id");
  //     var res2 = await MyHttp.get("users/uploads");
  //     var json = jsonDecode(res.body);
  //     prevEmail = json["user"]["email"];
  //
  //     print(prevEmail);
  //     print(res.body);
  //     print(res2.body);
  //     setState(() {
  //       prevEmail = json["user"]["email"];
  //     });
  //   } catch (e) {
  //     print(e);
  //   }
  //   print(id);
  //   setState(() {
  //     initialLoading = false;
  //   });
  // }

  // Future<void> _setEmail() async {
  //   // Android and iOS
  //   const uri = 'mailto:test@example.org?subject=Greetings&body=Hello%20World';
  //   if (await canLaunch(uri)) {
  //     await launch(uri);
  //     // Analytics tracking code
  //     analytics.logEvent(name: "changed_email", parameters: <String, dynamic>{
  //       "old_emal": prevEmail,
  //       'new_email': _newEmail
  //     });
  //
  //     amplitudeAnalytics.logEvent("changed_email",
  //         eventProperties: {"old_email": prevEmail, 'new_email': _newEmail});
  //   } else {
  //     throw 'Could not launch $uri';
  //   }
  // }

  @override
  void initState() {
    super.initState();
    //Initializing amplitude analytics api key
    amplitudeAnalytics.init(apiKey);
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    print(height);

    return PlatformScaffold(
        backgroundColor: Colors.white,
        //bottomNavBar: HomePage(),
        appBar: PlatformAppBar(
          material: (_, __) => MaterialAppBarData(
            backgroundColor: AppColors.offWhiteColor,
            elevation: 0.0,
            leading: MaterialButton(
              onPressed: () {},
              child: IconButton(
                icon: Icon(Icons.arrow_back),
                color: Colors.white,
                onPressed: () {
                  Navigator.pop(context);
                  //Analytics tracking code
                  analytics.setCurrentScreen(
                      screenName: "account_settings",
                      screenClassOverride: "account_settings");
                  amplitudeAnalytics.logEvent("account_settings_page");
                },
              ),
            ),
            title: Text(
              "Change Email Address",
              style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontStyle: FontStyle.normal),
            ),
          ),
          cupertino: (_, __) => CupertinoNavigationBarData(
            automaticallyImplyLeading: false,
            automaticallyImplyMiddle: false,
            backgroundColor: AppColors.offWhiteColor,
            leading: MaterialButton(
              onPressed: () {},
              child: IconButton(
                icon: Icon(Icons.arrow_back_ios),
                color: Colors.white,
                onPressed: () {
                  Navigator.pop(context);
                  //Analytics tracking code
                  analytics.setCurrentScreen(
                      screenName: "account_settings",
                      screenClassOverride: "account_settings");
                  amplitudeAnalytics.logEvent("account_settings_page");
                },
              ),
            ),
            title: Text(
              "Change Email Address",
              style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontStyle: FontStyle.normal),
            ),
            padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 10.0),
          ),
        ),
        body: SafeArea(
          child: Scaffold(
            backgroundColor: Colors.white,
            body: new Builder(builder: (BuildContext context) {
              return Center(
                child: InkWell(
                    child: Text("Email us if you like to change your email.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 16,
                            color: AppColors.blueColor,
                            fontWeight: FontWeight.w600,
                            fontStyle: FontStyle.normal,
                            decoration: TextDecoration.underline)),
                    onTap: () async {
                      const uri =
                          'mailto:PureMatchDating@gmail.com?subject=Change%20Email&body=Hello,\nChange%20my%20email%20to%20';
                      if (await canLaunch(uri)) {
                        await launch(uri);
                      } else {
                        final snackBar = new SnackBar(
                            content: new Text(
                                "Not able to open email app. Please email us on PureMatchDating@gmail.com"),
                            backgroundColor: Colors.red);

                        // Find the Scaffold in the Widget tree and use it to show a SnackBar!
                        Scaffold.of(context).showSnackBar(snackBar);
                      }
                    }),
              );
            }),
          ),
        ));
  }
}
