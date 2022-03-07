import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:amplitude_flutter/amplitude.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:pure_match/common/global.dart';
import 'package:pure_match/pages/AppColors.dart';

class EditProfileDetailsAppBar {
  final BuildContext context;
  final String text;
  final double titleSize;

  const EditProfileDetailsAppBar(
      {@required this.context, @required this.text, this.titleSize = 24});

  void _alertUser() {
    Global.alertUser(
        context,
        Text("Discard Changes",
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
        Text("All unsaved changes will be discarded",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              height: 1.5,
            )),
        Text("Discard",
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.redColor)),
        () {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        },
        Text("Keep Editing",
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.blueColor)),
        () {
          Navigator.of(context).pop();
        });
  }

  PlatformAppBar getAppBar() {
    return PlatformAppBar(
      automaticallyImplyLeading: false,
      material: (_, __) => MaterialAppBarData(
        backgroundColor: AppColors.offWhiteColor,
        title: Text(this.text,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontStyle: FontStyle.normal,
                fontSize: titleSize != 0.0 ? titleSize : 24)),
        actions: [
          FlatButton(
            onPressed: () {
              _alertUser();
              _sendOwnProfileEvent("profilePicture");
            },
            child: Text("Cancel",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15)),
          )
        ],
      ),
      cupertino: (_, __) => CupertinoNavigationBarData(
        brightness: Brightness.dark,
        backgroundColor: AppColors.offWhiteColor,
        title: Text(this.text,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontStyle: FontStyle.normal,
                fontSize: titleSize != 0.0 ? titleSize : 24)),
        trailing: FlatButton(
          onPressed: () {
            _alertUser();
            _sendOwnProfileEvent("profilePicture");
          },
          child: Text("Cancel",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 15)),
        ),
      ),
    );
  }

  PlatformAppBar getAppBar1(bool isChanged) {
    return PlatformAppBar(
      automaticallyImplyLeading: false,
      material: (_, __) => MaterialAppBarData(
        backgroundColor: AppColors.offWhiteColor,
        title: Text(this.text,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontStyle: FontStyle.normal,
                fontSize: titleSize != 0.0 ? titleSize : 24)),
        actions: [
          FlatButton(
            onPressed: () {
              isChanged ? _alertUser() : Navigator.of(context).pop();
            },
            child: Text("Cancel",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15)),
          )
        ],
      ),
      cupertino: (_, __) => CupertinoNavigationBarData(
        brightness: Brightness.dark,
        backgroundColor: AppColors.offWhiteColor,
        title: Text(this.text,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontStyle: FontStyle.normal,
                fontSize: titleSize != 0.0 ? titleSize : 24)),
        trailing: FlatButton(
          onPressed: () {
            isChanged ? _alertUser() : Navigator.of(context).pop();
          },
          child: Text("Cancel",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 15)),
        ),
      ),
    );
  }

  PlatformAppBar getAppBar2(bool isChanged, bool isHavePhoto) {
    return PlatformAppBar(
      automaticallyImplyLeading: false,
      material: (_, __) => MaterialAppBarData(
        backgroundColor: AppColors.offWhiteColor,
        title: Text(this.text,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontStyle: FontStyle.normal,
                fontSize: titleSize != 0.0 ? titleSize : 24)),
        actions: [
          FlatButton(
            onPressed: () {
              !isHavePhoto
                  ? null
                  : isChanged
                      ? _alertUser()
                      : Navigator.of(context).pop();
            },
            child: Text("Cancel",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15)),
          )
        ],
      ),
      cupertino: (_, __) => CupertinoNavigationBarData(
        brightness: Brightness.dark,
        backgroundColor: AppColors.offWhiteColor,
        title: Text(this.text,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontStyle: FontStyle.normal,
                fontSize: titleSize != 0.0 ? titleSize : 24)),
        trailing: FlatButton(
          onPressed: () {
            !isHavePhoto
                ? null
                : isChanged
                    ? _alertUser()
                    : Navigator.of(context).pop();
          },
          child: Text("Cancel",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 15)),
        ),
      ),
    );
  }

  Future<void> _sendOwnProfileEvent(String profilePicture) async {
    // Analytics code
    FirebaseAnalytics analytics = FirebaseAnalytics();
    final Amplitude amplitudeAnalytics =
        Amplitude.getInstance(instanceName: "PURE MATCH");
    String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';
    amplitudeAnalytics.init(apiKey);

    await analytics.logEvent(
        name: "edited_profile",
        parameters: <String, dynamic>{'profile_picture': profilePicture});
    amplitudeAnalytics.logEvent("edited_profile_page");
  }
}
