import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:pure_match/common/global.dart';
import 'package:pure_match/pages/AppColors.dart';
import 'package:flutter/cupertino.dart';

import 'basic_info/user_email.dart';

class ModeratorNotes extends StatefulWidget {
  @override
  _ModeratorNotesState createState() => _ModeratorNotesState();
}

class _ModeratorNotesState extends State<ModeratorNotes> {
  @override
  void initState() {
    Global.setOnboardingId(3);
  }

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
                  Text(
                    "Note of Caution from the Moderators ⚠️",
                    maxLines: 2,
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize:
                            (AppConfig.fullWidth(context) >= 375) ? 30 : 26,
                        color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: ScreenUtil().setHeight(20),
                  ),
                  Text(
                    "Thank you for downloading the Pure Match app!🙏",
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize:
                            AppConfig.heightWithDForSmallDevice(context, 24, 4),
                        color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: ScreenUtil().setHeight(25),
                  ),
                  Text(
                    "Our team is so grateful to God for the privilege of working on such a wonderful product.\nWe also know that with great power comes great responsibility 😉.",
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize:
                            AppConfig.heightWithDForSmallDevice(context, 20, 4),
                        color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: ScreenUtil().setHeight(25),
                  ),
                  Text(
                    "As safety and spirit-led community are among our top values, we'd like to remind every member to stay 💯 truthful in your responses to the screening questions, and to be very wise in your interactions in the community.\nAny violations in our standards will result in a total ban from the community, so please be honest and respectful. Let us know if you have any questions about anything, and happy connecting 🙌",
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize:
                            AppConfig.heightWithDForSmallDevice(context, 20, 4),
                        color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: ScreenUtil().setHeight(35),
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
                        width:
                            (AppConfig.fullWidth(context) >= 375) ? 300 : 280,
                        child: PlatformButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => UserEmail()));
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
