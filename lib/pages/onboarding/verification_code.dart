import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:pure_match/common/global.dart';
import 'package:pure_match/pages/MyUrl.dart';
import 'package:pure_match/pages/onboarding/verified_create_account.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:amplitude_flutter/amplitude.dart';
import 'dart:convert' as convert;
import '../AppColors.dart';
import 'icon_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io' show Platform;

class VerificationCode extends StatefulWidget {
  final String phone;

  VerificationCode(this.phone, {Key key}) : super(key: key);

  @override
  _VerificationCodeState createState() => _VerificationCodeState();
}

class _VerificationCodeState extends State<VerificationCode> {
  // Analytics code
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';

  String errorMsg = "Enter your Verification Code";
  bool verificationDisabled = true;
  String code = "";
  bool _loading = false;

  Future<void> _sendSms() async {
    setState(() {
      _loading = true;
    });
    var url = Uri.parse(MyUrl.url("phone-register"));
    var req = await http.post(url, body: {"phone": widget.phone});
    if (req.statusCode == 200) {
      var body = convert.jsonDecode(req.body);
      print("Body:" + req.body);
      bool status = body["success"];
      if (status == true) {
      } else {
        String message = body["message"];
        setState(() {
          errorMsg = message;
          _loading = false;
        });
      }
    } else {
      setState(() {
        errorMsg = "Error: ${req.statusCode}";
        _loading = false;
      });
    }
  }

  Future<void> _authenticate() async {
    setState(() {
      _loading = true;
    });
    var dataToSend =
        convert.jsonEncode({"phone": widget.phone, "code": this.code});
    print("Data to send: $dataToSend");
    var url = Uri.parse(MyUrl.url("phone-verify"));
    var req = await http.post(url,
        body: dataToSend, headers: {"Content-Type": "application/json"});
    print("URL: ${req.request.url}");
    if (req.statusCode == 200) {
      var body = convert.jsonDecode(req.body);

      analytics.logEvent(
          name: "started_onboarding",
          parameters: <String, dynamic>{'user_id': body['Id'].toString()});
      amplitudeAnalytics.logEvent("started_onboarding",
          eventProperties: {'user_id': body['Id'].toString()});

      print("Body:" + req.body);
      bool status = body["success"];
      if (status == true) {
        String token = body["token"];
        int id = body["Id"];
        // bool newUser = body["newUser"];
        var sp = await SharedPreferences.getInstance();
        await sp.setInt("id", id);
        await sp.setString("token", token);
        // var tokenReq = await MyFirebase.sendFCMToken("users/fcm-token");
        // if (tokenReq != null) {
        //   print("FCm token send response:::::::::");
        //   print(tokenReq.statusCode);
        //   print(tokenReq.body);
        // }
        // TODO: To check new user or not after testing of signing up process in onboarding is done
        //if (newUser == true)

        sp.setBool("signup", true);

        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => VerifiedCreateAccount()),
            ModalRoute.withName("/"));
        analytics.setCurrentScreen(
            screenName: "device_verified",
            screenClassOverride: "device_verified");
        amplitudeAnalytics.logEvent("device_verified_page");

        /* else
         print("old user");
         Routes.sailor.navigate("/homes",
             navigationType: NavigationType.pushAndRemoveUntil,
              removeUntilPredicate: (Route<dynamic> route) => false); */
      } else {
        String message = body["message"];
        setState(() {
          errorMsg = message;
          _loading = false;
        });
      }
    } else {
      setState(() {
        errorMsg = "Error: ${req.statusCode}";
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    //Initializing amplitude analytics api key
    amplitudeAnalytics.init(apiKey);

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
                onPressed: () {
                  Navigator.pop(context);
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
              child: Column(children: <Widget>[
                IconIndicator(
                  imageAsset: "assets/images/verification_icon.png",
                  currentIndicatorIndex: 1,
                ),
                SizedBox(
                  height: 25,
                ),
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 70),
                    child: Column(children: <Widget>[
                      Text(
                        errorMsg,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontStyle: FontStyle.normal,
                          fontSize: AppConfig.heightWithDForSmallDevice(
                              context, 28, 8),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height:
                            AppConfig.heightWithDForSmallDevice(context, 25, 5),
                      ),
                      Container(
                          height: Platform.isAndroid ? 40 : 45,
                          child: PlatformTextField(
                            maxLength: 6,
                            keyboardType: TextInputType.phone,
                            textAlign: TextAlign.center,
                            onChanged: (String str) {
                              print(str);
                              code = str;
                              if (str.length == 6) {
                                setState(() {
                                  verificationDisabled = false;
                                });
                              } else {
                                setState(() {
                                  verificationDisabled = true;
                                });
                              }
                            },
                            style: TextStyle(
                                fontSize: AppConfig.heightWithDForSmallDevice(
                                    context, 28, 4),
                                color: AppColors.blueColor,
                                fontStyle: FontStyle.normal,
                                fontWeight: FontWeight.w700),
                            material: (_, __) => MaterialTextFieldData(
                              decoration: InputDecoration(
                                  counterText: "",
                                  enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: AppColors.blueColor,
                                          width: 2)),
                                  focusedBorder: UnderlineInputBorder(
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
                          )),
                      SizedBox(
                        height: 30,
                      ),
                      Container(
                        width: 200,
                        height: 60,
                        child: PlatformButton(
                          padding: EdgeInsets.all(15),
                          color: AppColors.blueColor,
                          materialFlat: (_, __) => MaterialFlatButtonData(
                            color: AppColors.blueColor,
                            disabledColor: AppColors.disabledBlueColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          cupertino: (_, __) => CupertinoButtonData(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          disabledColor: AppColors.disabledBlueColor,
                          child: Center(
                            child: Text("Continue",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400)),
                          ),
                          onPressed: verificationDisabled
                              ? null
                              : () {
                                  (_loading == false)
                                      ? this._authenticate()
                                      : null;
                                },
                        ),
                      ),
                      SizedBox(
                        height:
                            AppConfig.heightWithDForSmallDevice(context, 20, 4),
                      ),
                      InkWell(
                        child: Text("I didn't get a code",
                            style: TextStyle(
                                fontSize: AppConfig.heightWithDForSmallDevice(
                                    context, 16, 3),
                                color: AppColors.blueColor,
                                fontWeight: FontWeight.w500,
                                fontStyle: FontStyle.normal,
                                decoration: TextDecoration.underline)),
                        onTap: () => _sendSms(),
                      ),
                    ]))
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
