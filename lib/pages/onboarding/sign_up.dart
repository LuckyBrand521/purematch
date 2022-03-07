import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:pure_match/common/global.dart';
import 'package:pure_match/pages/AppColors.dart';
import 'package:pure_match/pages/onboarding/phone_login/phone_login.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:amplitude_flutter/amplitude.dart';

class SignUpPage extends StatelessWidget {
  _launchTermsURL() async {
    const url = 'https://purematch.co/terms-of-service/';
    launch(url);
  }

  _launchPrivacyURL() async {
    const url = 'https://purematch.co/privacy-policy/';
    launch(url);
  }

  // Analytics code
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';

  @override
  Widget build(BuildContext context) {
    //Initializing amplitude analytics api key
    amplitudeAnalytics.init(apiKey);

    return Scaffold(
        body: Center(
            child: Column(
      children: <Widget>[
        SizedBox(
          height: AppConfig.heightWithDForSmallDevice(context, 100, 20),
        ),
        Container(
          height: AppConfig.heightWithDForSmallDevice(context, 260, 40),
          decoration: BoxDecoration(
              image:
                  DecorationImage(image: AssetImage('assets/images/logo.png'))),
        ),
        SizedBox(
          height: 50,
        ),
        Expanded(
          child: SizedBox(height: 20),
        ),
        // SizedBox(
        //   width: AppConfig.heightWithDForSmallDevice(context, 330, 70),
        //   height: AppConfig.heightWithDForSmallDevice(context, 50, 10),                    
        //     child: Container(
        //       decoration: BoxDecoration(
        //         boxShadow: [
        //           BoxShadow(
        //             color: Colors.grey,
        //             offset: Offset(0, 0.5),
        //             blurRadius: 0.3,
        //             spreadRadius: 0,                    
        //           )
        //         ],
        //         borderRadius: BorderRadius.only(
        //           topLeft: Radius.circular(10),
        //           topRight: Radius.circular(10),
        //           bottomLeft: Radius.circular(10),
        //           bottomRight: Radius.circular(10)
        //         ),           
        //       ),
        //       child: MaterialButton(
        //         onPressed: () {
        //           Navigator.push(context,
        //               MaterialPageRoute(builder: (context) => PhoneLogin()));
        //         },
        //         padding: EdgeInsets.all(
        //           AppConfig.heightWithDForSmallDevice(context, 10, 10),
        //         ),  
        //         shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(10.0)),
        //         color: Colors.white,   
        //         child: Center(
        //           child: Row(
        //             crossAxisAlignment: CrossAxisAlignment.center,
        //             mainAxisAlignment: MainAxisAlignment.center,
        //             children: <Widget>[
        //               Container(
        //                 padding: EdgeInsets.only(right: 15),
        //                 child: Image.asset(
        //                   'assets/images/gsuite.png',
        //                   height: 18,
        //                 ),
        //               ),
        //               Text(
        //                 "Continue with Google",
        //                 style: TextStyle(
        //                     color: Colors.white,
        //                     fontWeight: FontWeight.w600,
        //                     fontSize: 18),
        //               ),
        //             ],
        //           ),
        //         ),
        //       )
        //     ),
        //   ),
        // SizedBox(
        //   height: 10,
        // ),
        // SizedBox(
        //   width: AppConfig.heightWithDForSmallDevice(context, 330, 70),
        //   height: AppConfig.heightWithDForSmallDevice(context, 50, 10),
        //   child: PlatformButton(
        //     onPressed: () {
        //       Navigator.push(context,
        //           MaterialPageRoute(builder: (context) => PhoneLogin()));
        //     },
        //     padding: EdgeInsets.all(
        //       AppConfig.heightWithDForSmallDevice(context, 10, 10),
        //     ),
        //     color: AppColors.blueColor,
        //     child: Center(
        //       child: Row(
        //         crossAxisAlignment: CrossAxisAlignment.center,
        //         mainAxisAlignment: MainAxisAlignment.center,
        //         children: <Widget>[
        //           Container(
        //             padding: EdgeInsets.only(right: 15),
        //             child: Image.asset(
        //               'assets/images/phone_small.png',
        //               height: 18,
        //             ),
        //           ),
        //           Text(
        //             "Continue with Facebook",
        //             style: TextStyle(
        //                 color: Colors.white,
        //                 fontWeight: FontWeight.w600,
        //                 fontSize: 18),
        //           ),
        //         ],
        //       ),
        //     ),
        //     materialFlat: (_, __) => MaterialFlatButtonData(
        //       color: AppColors.blueColor,
        //       disabledColor: AppColors.disabledBlueColor,
        //       shape: RoundedRectangleBorder(
        //         borderRadius: BorderRadius.circular(10),
        //       ),
        //     ),
        //     cupertino: (_, __) => CupertinoButtonData(
        //       borderRadius: BorderRadius.circular(10),
        //     ),
        //   ),
        // ),
        // SizedBox(
        //   height: 10,
        // ),
        //  SizedBox(
        //   width: AppConfig.heightWithDForSmallDevice(context, 330, 70),
        //   height: AppConfig.heightWithDForSmallDevice(context, 50, 10),
        //   child: PlatformButton(
        //     onPressed: () {
        //       Navigator.push(context,
        //           MaterialPageRoute(builder: (context) => PhoneLogin()));
        //     },
        //     padding: EdgeInsets.all(
        //       AppConfig.heightWithDForSmallDevice(context, 10, 10),
        //     ),
        //     color: AppColors.blueColor,
        //     child: Center(
        //       child: Row(
        //         crossAxisAlignment: CrossAxisAlignment.center,
        //         mainAxisAlignment: MainAxisAlignment.center,
        //         children: <Widget>[
        //           Container(
        //             padding: EdgeInsets.only(right: 15),
        //             child: Image.asset(
        //               'assets/images/phone_small.png',
        //               height: 18,
        //             ),
        //           ),
        //           Text(
        //             "Continue with Apple",
        //             style: TextStyle(
        //                 color: Colors.white,
        //                 fontWeight: FontWeight.w600,
        //                 fontSize: 18),
        //           ),
        //         ],
        //       ),
        //     ),
        //     materialFlat: (_, __) => MaterialFlatButtonData(
        //       color: AppColors.blueColor,
        //       disabledColor: AppColors.disabledBlueColor,
        //       shape: RoundedRectangleBorder(
        //         borderRadius: BorderRadius.circular(10),
        //       ),
        //     ),
        //     cupertino: (_, __) => CupertinoButtonData(
        //       borderRadius: BorderRadius.circular(10),
        //     ),
        //   ),
        // ),
        // SizedBox(
        //   height: 10,
        // ),
        SizedBox(
          width: AppConfig.heightWithDForSmallDevice(context, 330, 70),
          height: AppConfig.heightWithDForSmallDevice(context, 50, 10),
          child: PlatformButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => PhoneLogin()));
            },
            padding: EdgeInsets.all(
              AppConfig.heightWithDForSmallDevice(context, 10, 10),
            ),
            color: AppColors.blueColor,
            child: Center(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(right: 15),
                    child: Image.asset(
                      'assets/images/phone_small.png',
                      height: 18,
                    ),
                  ),
                  Text(
                    "Continue with Phone Number",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 18),
                  ),
                ],
              ),
            ),
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
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.only(left: 25.0, right: 25.0, bottom: 40.0),
            child: Wrap(
              spacing: 0.0,
              runSpacing: 2.0,
              direction: Axis.horizontal,
              alignment: WrapAlignment.center,
              children: [
                Text(
                  "By continuing, you agree to our ",
                  style: TextStyle(
                      color: AppColors.blackColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w400),
                ),
                InkWell(
                  child: Text("Terms",
                      //textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 12,
                          color: AppColors.blackColor,
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.normal,
                          decoration: TextDecoration.underline)),
                  onTap: () => _launchTermsURL(),
                ),
                Text(
                  " and ",
                  style: TextStyle(
                      color: AppColors.blackColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w400),
                ),
                InkWell(
                  child: Text("Privacy Policy",
                      //textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 12,
                          color: AppColors.blackColor,
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.normal,
                          decoration: TextDecoration.underline)),
                  onTap: () => _launchPrivacyURL(),
                ),
              ],
            ),
          ),
        ),
      ],
    )));
  }
}
