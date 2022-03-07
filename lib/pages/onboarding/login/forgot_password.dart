import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:pure_match/pages/AppColors.dart';
import 'package:pure_match/pages/MyHttp.dart';
import 'package:flutter/cupertino.dart';
import 'package:pure_match/pages/onboarding/login/password_reset_success.dart';
import 'package:pure_match/pages/onboarding/login/welcome_back.dart';

class ForgotPassword extends StatefulWidget {
  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  String email = "";
  String error = "";
  bool emailValidationCheck = false;
  String message = "A password reset link will be sent to this email.";

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

  // TODO: To call the api for forgot password
  Future<void> _sendPasswordResetLink() async {
    var res =
        await MyHttp.post("/password/send-reset-email", {"email": this.email});
    if (res.statusCode == 200) {
      print("Verificatiion link sent");
      print(res.body);
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => WelcomeBack(
                    isFromLogin: true,
                  )));
    } else {
      print("User update error: ${res.statusCode}");
      print("User update error: ${res.body}");
      setState(() {
        var body = json.decode(res.body);
        error = body["message"] ?? "error";
      });
    }
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PasswordResetSuccess(this.email)));
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
                  Column(
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
                        style: TextStyle(
                            fontSize: 18,
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
                                      color: AppColors.blueColor, width: 2))),
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
                      SizedBox(height: 10),
                      Text(
                        this.error,
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w400),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    this.message,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Padding(
                    padding: EdgeInsetsDirectional.only(bottom: 20),
                    child: Center(
                      child: SizedBox(
                        width: 220,
                        height: 60,
                        child: PlatformButton(
                            onPressed: (this.emailValidationCheck)
                                ? () {
                                    this._sendPasswordResetLink();
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
                              "Send Link",
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
      )),
    );
  }
}
