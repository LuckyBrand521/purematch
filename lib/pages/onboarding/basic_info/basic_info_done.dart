import 'package:flutter/material.dart';
import 'package:pure_match/pages/AppColors.dart';
import 'package:pure_match/pages/onboarding/profile_info/profile_photo.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter/cupertino.dart';

class BasicInfoDone extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return PlatformScaffold(
      appBar: PlatformAppBar(
        material: (_, __) => MaterialAppBarData(
          backgroundColor: Colors.white,
          elevation: 0.0,
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
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 80),
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 40,
                ),
                Text("So far so good!",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.blueColor, fontSize: 48)),
                SizedBox(
                  height: height * 0.1,
                ),
                Text("We’re almost there. Now time for the fun stuff!",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24)),
                SizedBox(
                  height: height * 0.32,
                ),
                SizedBox(
                  height: 50,
                  width: 150,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 0),
                    child: PlatformButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ProfilePhoto()));
                      },
                      child: Text(
                        "Continue",
                        style: TextStyle(color: Colors.white),
                      ),
                      padding:
                          EdgeInsets.symmetric(vertical: 20, horizontal: 55),
                      color: Color.fromRGBO(0, 137, 255, 1),
                      disabledColor: AppColors.disabledBlueColor,
                      materialFlat: (_, __) => MaterialFlatButtonData(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      cupertino: (_, __) => CupertinoButtonData(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
