import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:pure_match/pages/AppColors.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpCenter extends StatefulWidget {
  @override
  _HelpCenterState createState() => _HelpCenterState();
}

class _HelpCenterState extends State<HelpCenter> {
  String error = "";
  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      setState(() {
        error = "Could not open the url";
      });
    }
  }

  Widget _settingsOptions(String title, String url) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            this._launchURL(url);
          },
          child: Row(
            children: <Widget>[
              SizedBox(
                width: 25,
              ),
              Expanded(
                flex: 2,
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.normal,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.arrow_forward_ios,
                    color: Colors.black, size: 25),
              )
            ],
          ),
        ),
        Divider(
          thickness: 2,
          height: 3,
          color: Colors.grey.shade100,
        ),
      ],
    );
  }

  Row buildHelpOptions(String text) {
    return Row(
      children: <Widget>[
        Expanded(
          flex: 2,
          child: Text(
            text,
            style: TextStyle(
              fontSize: 20,
              fontFamily: "Roboto",
              fontWeight: FontWeight.w400,
              fontStyle: FontStyle.normal,
              color: AppColors.blackColor,
            ),
          ),
        ),
        IconButton(
            icon: Icon(Icons.arrow_forward_ios, color: Colors.black, size: 25)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      backgroundColor: Colors.white,
      //bottomNavBar: HomePage(),
      appBar: PlatformAppBar(
        title: Text(
          "Help Center",
          style: TextStyle(
              fontSize: 24,
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontStyle: FontStyle.normal),
        ),
        material: (_, __) => MaterialAppBarData(
          backgroundColor: AppColors.offWhiteColor,
          elevation: 0.0,
        ),
        cupertino: (_, __) => CupertinoNavigationBarData(
          brightness: Brightness.dark,
          automaticallyImplyLeading: true,
          automaticallyImplyMiddle: false,
          backgroundColor: AppColors.offWhiteColor,
          padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 10.0),
        ),
      ),
      body: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Container(
            padding: const EdgeInsetsDirectional.only(
                start: 0.0, end: 5.0, top: 5.0, bottom: 5.0),
            alignment: Alignment.center,
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 15,
                ),
                Divider(
                  thickness: 2,
                  height: 3,
                  color: Colors.grey.shade100,
                ),
                this._settingsOptions("Terms of Service",
                    "http://www.purematch.co/terms-of-service"),
                this._settingsOptions(
                    "Privacy Policy", "http://www.purematch.co/privacy-policy"),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
