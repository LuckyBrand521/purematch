import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:amplitude_flutter/amplitude.dart';

import 'phone_login/phone_login.dart';

/**
 * This is the firt page. Basically asking you to login.
 */

class MainPage extends StatelessWidget {
  // Analytics code
  //Initializing amplitude analytics api key

  FirebaseAnalytics analytics = FirebaseAnalytics();
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';

  @override
  Widget build(BuildContext context) {
    //Initializng api key
    amplitudeAnalytics.init(apiKey);

    return PlatformScaffold(
        body: SafeArea(
      child: Center(
          child: Column(
        children: <Widget>[
          SizedBox(
            height: 100,
          ),
          Container(
            height: 200,
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/images/logo.png'))),
          ),
          SizedBox(
            height: 20,
          ),
          Text("PURE MATCH", style: TextStyle(fontSize: 25)),
          SizedBox(
            height: 30,
          ),
          Padding(
            padding: EdgeInsets.all(40),
            child: Column(
              children: <Widget>[
                FlatButton(
                  padding: EdgeInsets.all(15),
                  color: Color.fromRGBO(0, 137, 255, 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child:
                        Text("Log In", style: TextStyle(color: Colors.white)),
                  ),
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => PhoneLogin()));
                  },
                ),
                SizedBox(
                  height: 10,
                ),
                FlatButton(
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => MainPage()));
                    },
                    padding: EdgeInsets.all(15),
                    color: Color.fromRGBO(36, 62, 92, 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Image.asset(
                            'assets/images/facebook.png',
                            height: 20,
                          ),
                        ),
                        Expanded(
                          child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: Text(
                                "Login with Facebook",
                                style: TextStyle(color: Colors.white),
                              )),
                        ),
                      ],
                    ))
              ],
            ),
          )
        ],
      )),
    ));
  }
}
