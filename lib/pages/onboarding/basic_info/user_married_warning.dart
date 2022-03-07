import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import 'package:pure_match/common/global.dart';
import 'package:pure_match/pages/AppColors.dart';
import 'package:flutter/cupertino.dart';
import 'package:pure_match/pages/onboarding/basic_info/user_ethnicity.dart';
import 'package:pure_match/pages/onboarding/basic_info/user_kids.dart';

class UserMarriedWarning extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
        appBar: PlatformAppBar(
          material: (_, __) => MaterialAppBarData(
            backgroundColor: AppColors.blueColor,
            elevation: 0.0,
            leading: IconButton(
              padding: EdgeInsetsDirectional.only(start: 10.0),
              icon: Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 25,
              ),
              iconSize: 30,
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          cupertino: (_, __) => CupertinoNavigationBarData(
              brightness: Brightness.dark,
              automaticallyImplyLeading: false,
              automaticallyImplyMiddle: false,
              backgroundColor: AppColors.blueColor,
              border: Border(bottom: BorderSide.none),
              padding: EdgeInsetsDirectional.only(start: 10.0),
              leading: CupertinoNavigationBarBackButton(
                  color: Colors.white,
                  previousPageTitle: null,
                  onPressed: () => Navigator.pop(context))),
        ),
        body: Scaffold(
          backgroundColor: AppColors.blueColor,
          body: SingleChildScrollView(
            child: Center(
                child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height:
                        AppConfig.heightWithDForSmallDevice(context, 40, 20),
                  ),
                  Text(
                    "You stated that you are:\n\nMarried\n\nYou will have access to\nall Pure Match functions\nexcept the following:\n\n1) Matching\n\nYou will be able to change\nyour relationship status\nin the future.️",
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize:
                            AppConfig.heightWithDForSmallDevice(context, 30, 4),
                        color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height:
                        AppConfig.heightWithDForSmallDevice(context, 30, 10),
                  ),
                  Padding(
                    padding: EdgeInsetsDirectional.only(
                        bottom:
                            (AppConfig.fullWidth(context) >= 375) ? 25 : 21),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: SizedBox(
                        height: AppConfig.heightWithDForSmallDevice(
                            context, 60, 10),
                        width: AppConfig.heightWithDForSmallDevice(
                            context, 300, 20),
                        child: PlatformButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => UserEthnicity()));
                          },
                          color: Colors.white,
                          child: Text(
                            "Continue",
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: AppConfig.heightWithDForSmallDevice(
                                    context, 20, 4),
                                color: AppColors.blueColor),
                          ),
                          materialFlat: (_, __) => MaterialFlatButtonData(
                              color: Colors.white,
                              disabledColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              )),
                          cupertino: (_, __) => CupertinoButtonData(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ),
        ));
  }
}
