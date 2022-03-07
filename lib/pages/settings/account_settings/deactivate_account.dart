import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:amplitude_flutter/amplitude.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:intl/intl.dart';
import 'package:pure_match/pages/AppColors.dart';
import 'package:pure_match/pages/MyHttp.dart';
import 'package:sailor/sailor.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../routes.dart';

class DeactivateAccount extends StatefulWidget {
  @override
  _DeactivateAccountState createState() => _DeactivateAccountState();
}

class _DeactivateAccountState extends State<DeactivateAccount> {
  // Analytics code
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';

  bool _textAdded = false;
  String message = "";

  Future<void> _deactivateAccount() async {
    String date = DateFormat("yyyy-MM-dd hh:mm:ss").format(DateTime.now());
    var output = {
      "reason": message,
      "reactivation_date": date,
    };
    var res = await MyHttp.put("users/account/deactivate", output);
    if (res.statusCode == 200) {
      var sp = await SharedPreferences.getInstance();
      sp.remove("token");
      sp.remove("id");

      Routes.sailor.navigate("/main",
          navigationType: NavigationType.pushAndRemoveUntil,
          removeUntilPredicate: (Route<dynamic> route) => false);
    } else {
      print("User update error: ${res.statusCode}");
      print("User update error: ${res.body}");
    }
    print(res.body);
  }

  @override
  Widget build(BuildContext context) {
    //Initializing amplitude analytics api key
    amplitudeAnalytics.init(apiKey);

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
                Navigator.of(context).pop();

                //Analytic tracking code
                analytics.setCurrentScreen(
                    screenName: "account_settings",
                    screenClassOverride: "account_settings");
                amplitudeAnalytics.logEvent("account_settings_page");
              },
            ),
          ),
          title: Text(
            "Delete Account",
            style: TextStyle(
                fontSize: 22,
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontStyle: FontStyle.normal),
          ),
        ),
        cupertino: (_, __) => CupertinoNavigationBarData(
          brightness: Brightness.dark,
          automaticallyImplyLeading: false,
          automaticallyImplyMiddle: false,
          backgroundColor: AppColors.offWhiteColor,
          leading: MaterialButton(
            onPressed: () {},
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              color: Colors.white,
              onPressed: () {
                Navigator.of(context).pop();
                //Analytics tracking code
                analytics.setCurrentScreen(
                    screenName: "account_settings",
                    screenClassOverride: "account_settings");
                amplitudeAnalytics.logEvent("account_settings_page");
              },
            ),
          ),
          title: Text(
            "Delete Account",
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
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(
                height: 20.0,
              ),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                    text: "WARNING:",
                    style: TextStyle(
                      color: Color.fromRGBO(255, 0, 74, 1),
                      fontWeight: FontWeight.w500,
                      fontSize: 20,
                      fontStyle: FontStyle.normal,
                    ),
                    children: [
                      TextSpan(
                        text:
                            " If your account is deleted, you won't be able to recover your profile or other Pure Match account data.",
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 20,
                          color: Color.fromRGBO(44, 45, 48, 1),
                          fontStyle: FontStyle.normal,
                        ),
                      )
                    ]),
              ),
              SizedBox(
                height: 40.0,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: Text(
                  "Please tell us why you're leaving 😢:",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                    fontStyle: FontStyle.normal,
                  ),
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: PlatformTextField(
                  material: (_, __) => MaterialTextFieldData(
                    decoration: InputDecoration(
                      hintText:
                          "Please give us any feedback as to why you are leaving as it will help us be better servants",
                    ),
                    maxLines: 10,
                    onChanged: (string) {
                      message = string;
                      print(string);
                      setState(
                        () {
                          if (message.length > 0) {
                            _textAdded = true;
                          } else {
                            _textAdded = false;
                          }
                        },
                      );
                    },
                  ),
                  cupertino: (_, __) => CupertinoTextFieldData(
                    placeholder:
                        "Please give us any feedback as to why you are leaving as it will help us be better servants",
                    maxLines: 10,
                    onChanged: (string) {
                      message = string;
                      print(message);
                      setState(
                        () {
                          if (message.length > 0) {
                            _textAdded = true;
                          } else {
                            _textAdded = false;
                          }
                        },
                      );
                    },
                  ),
                ),
              ),
              Expanded(child: Container()),
              Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 20.0, horizontal: 32.0),
                child: PlatformButton(
                  padding: EdgeInsets.symmetric(vertical: 15.0),
                  color: ButtonColor(_textAdded),
                  onPressed: () {
                    (_textAdded) ? _deactivateAccount() : null;
                  },
                  materialFlat: (_, __) => MaterialFlatButtonData(
                    child: Text(
                      "Delete My Account",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: _textAdded == true
                              ? FontWeight.w700
                              : FontWeight.w400,
                          color: _textAdded == true
                              ? Colors.white
                              : AppColors.blackColor,
                          fontStyle: FontStyle.normal),
                    ),
                  ),
                  cupertino: (_, __) => CupertinoButtonData(
                    child: Text(
                      "Delete My Account",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: _textAdded == true
                              ? FontWeight.w700
                              : FontWeight.w400,
                          color: _textAdded == true
                              ? Colors.white
                              : AppColors.blackColor,
                          fontStyle: FontStyle.normal),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color ButtonColor(bool red) {
    if (red == false) {
      return AppColors.greyColor;
    }

    return Color.fromRGBO(255, 0, 74, 1);
  }
}
