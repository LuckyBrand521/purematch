import 'package:flutter/material.dart';
import 'package:pure_match/common/global.dart';
import 'package:pure_match/pages/AppColors.dart';
import 'package:pure_match/pages/MyUrl.dart';
import 'package:pure_match/pages/onboarding/icon_indicator.dart';
import 'package:pure_match/pages/onboarding/verification_code.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:amplitude_flutter/amplitude.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class PhoneLogin extends StatefulWidget {
  @override
  _PhoneLoginState createState() => _PhoneLoginState();
}

class _PhoneLoginState extends State<PhoneLogin> {
  // Analytics code
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController controller = TextEditingController();
  String initialCountry = 'US';
  PhoneNumber number = PhoneNumber(isoCode: 'US');

  String errorMsg = "";
  // var textEditing = MaskedTextController(mask: "(000) 000-0000");
  bool _loading = false;

  Future<void> _sendSms() async {
    bool isValidatedPhoneNumber = formKey.currentState.validate();
    if (!isValidatedPhoneNumber) {
      return;
    }
    setState(() {
      _loading = true;
    });

    String phone = number.phoneNumber;
    print("phone=${phone}");

    var req = await http
        .post(Uri.parse(MyUrl.url("phone-register")), body: {"phone": phone});

    if (req.statusCode == 200) {
      var body = convert.jsonDecode(req.body);
      print("Body:" + req.body);
      bool status = body["success"];
      _loading = false;
      if (status == true) {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => VerificationCode(phone)));

        //Analytics tracking code
        analytics.setCurrentScreen(
            screenName: "verification_code",
            screenClassOverride: "verification_code");
        amplitudeAnalytics.logEvent("verification_code_page");
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
      });
    }
    setState(() {
      _loading = false;
    });
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
              //Analytics tracking code
              analytics.setCurrentScreen(
                  screenName: "sign_up", screenClassOverride: "sign_up");
            },
          ),
        ),
        cupertino: (_, __) => CupertinoNavigationBarData(
            backgroundColor: Colors.white,
            border: Border(bottom: BorderSide.none),
            padding: EdgeInsetsDirectional.only(start: 10.0),
            leading: CupertinoNavigationBarBackButton(
                color: AppColors.offWhiteColor,
                previousPageTitle: null,
                onPressed: () {
                  Navigator.pop(context);
                  //Analytics tracking code
                  analytics.setCurrentScreen(
                      screenName: "sign_up", screenClassOverride: "sign_up");
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
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 20,
                ),
                IconIndicator(
                  imageAsset: "assets/images/phone_icon.png",
                ),
                SizedBox(
                  height: 25,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    children: <Widget>[
                      Text(
                        "Enter your Phone Number to receive a Validation Code",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontStyle: FontStyle.normal,
                          fontSize: AppConfig.heightWithDForSmallDevice(
                              context, 28, 8),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      Form(
                        key: formKey,
                        child: InternationalPhoneNumberInput(
                          onInputChanged: (PhoneNumber number) {
                            print(number.phoneNumber);
                            this.number = number;
                          },
                          onInputValidated: (bool value) {
                            print(value);
                          },
                          selectorConfig: SelectorConfig(
                            selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                          ),
                          ignoreBlank: true,
                          autoValidateMode: AutovalidateMode.always,
                          selectorTextStyle: TextStyle(color: Colors.black),
                          initialValue: number,
                          textFieldController: controller,
                          formatInput: true,
                          keyboardType: TextInputType.number,
                          // inputBorder: BorderSide(color: AppColors.communityProfileOptionsBlueColor, width: 1),

                          onSaved: (PhoneNumber number) {
                            print('On Saved: $number');
                          },
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text(errorMsg),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        width: 200,
                        height: 60,
                        child: (_loading)
                            ? Center(child: PlatformCircularProgressIndicator())
                            : PlatformButton(
                                child: Center(
                                  child: Text("Send SMS",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400)),
                                ),
                                color: AppColors.blueColor,
                                disabledColor: AppColors.disabledBlueColor,
                                padding: EdgeInsets.all(15),
                                onPressed: () {
                                  (_loading == false) ? this._sendSms() : null;
                                },
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
                              ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      )),
    );
  }
}
