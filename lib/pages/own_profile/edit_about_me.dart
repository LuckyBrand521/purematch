import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:pure_match/common/global.dart';
import 'package:pure_match/pages/own_profile/edit_profile_details_app_bar.dart';
import 'package:amplitude_flutter/amplitude.dart';
import 'package:sailor/sailor.dart';
import '../../routes.dart';
import '../AppColors.dart';
import '../MyHttp.dart';
import 'dart:io' show Platform;

class EditAboutMe extends StatefulWidget {
  final String aboutMyself;
  final bool isFromOnboarding;
  final Function onUpdateProfile;
  EditAboutMe(this.aboutMyself, this.isFromOnboarding, this.onUpdateProfile);

  @override
  EditAboutMeState createState() => EditAboutMeState();
}

class EditAboutMeState extends State<EditAboutMe> {
  // Analytics code
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';

  String _aboutMe;
  String _aboutMe1;
  String error = "";
  var _aboutMeTxtCtrl = TextEditingController();
  var borderSideProperty;
  int _charCount = 0;

  @override
  void initState() {
    _aboutMe = widget.aboutMyself;
    _charCount = _aboutMe.length;
    _aboutMe1 = _aboutMe;
    _aboutMeTxtCtrl.text = _aboutMe;
    borderSideProperty = BorderSide(color: Colors.transparent, width: 0);
    super.initState();
    // Analytics tracking code
    amplitudeAnalytics.init(apiKey);
    analytics.setCurrentScreen(
        screenName: "edit_about_me", screenClassOverride: "edit_about_me");
    amplitudeAnalytics.logEvent("edit_about_me_page");
  }

  @override
  void dispose() {
    _aboutMeTxtCtrl.dispose();
    super.dispose();
  }

  bool isChangedValues() {
    var isChanged = false;

    if (_aboutMe.length > 0 && _aboutMe1 != _aboutMe) {
      isChanged = true;
    }
    return isChanged;
  }

  Future<void> _setAboutMe(BuildContext context) async {
    if (_charCount > 500) {
      Global.alertUserForCardAction(
          // context, "Sorry", "A maximum of 100 words are allowed.", "OK", () {
          context,
          "Sorry",
          "A maximum of 500 characters are allowed.",
          "OK", () {
        Navigator.pop(context);
      }, "", null, "", null);
      return;
    }

    var res = await MyHttp.put("users/update", {"about_me": this._aboutMe});
    if (res.statusCode == 200) {
      //Analytics tracking code
      analytics.logEvent(
          name: "edited_profile",
          parameters: <String, dynamic>{'about_me': "about_me"});
      amplitudeAnalytics.logEvent("edited_profile",
          eventProperties: {'about_me': "about_me"});

      print("User updated");
      print(res.body);

      if (widget.isFromOnboarding != null && widget.isFromOnboarding) {
        Navigator.pop(context);
        widget.onUpdateProfile();
      } else {
        Global.ownProfileSaved = true;
        Routes.sailor.navigate("/homes",
            params: {'tabIndex': 4},
            navigationType: NavigationType.pushAndRemoveUntil,
            removeUntilPredicate: (Route<dynamic> route) => false);
      }
    } else {
      print("User update error: ${res.statusCode}");
      print("User update error: ${res.body}");
      setState(() {
        error = res.statusCode.toString() + " " + res.body;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double pageSize = MediaQuery.of(context).size.height;
    double notifySize = MediaQuery.of(context).padding.top;
    double appBarSize = Platform.isIOS
        ? CupertinoNavigationBar().preferredSize.height
        : AppBar().preferredSize.height;
    double scHeight = pageSize -
        (appBarSize + notifySize) -
        20 -
        MediaQuery.of(context).padding.bottom;
    return PlatformScaffold(
      appBar: EditProfileDetailsAppBar(context: context, text: "Edit About Me")
          .getAppBar1(isChangedValues()),
      body: PlatformScaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(new FocusNode());
            },
            child: SingleChildScrollView(
              child: SizedBox(
                height: scHeight,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      SizedBox(
                        height: 20,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.noExplaintationBorderColor,
                          ),
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        child: Column(
                          children: [
                            PlatformTextField(
                              textCapitalization: TextCapitalization.sentences,
                              controller: _aboutMeTxtCtrl,
                              maxLengthEnforcement:
                                  MaxLengthEnforcement.enforced,
                              maxLines: 10,
                              onChanged: (String text) {
                                this._aboutMe = text;
                                setState(() {
                                  _charCount = text.length;
                                });
                                print("First text field: $text");
                              },
                              style: TextStyle(
                                  fontWeight: FontWeight.w400, fontSize: 18),
                              material: (_, __) => MaterialTextFieldData(
                                decoration: InputDecoration(
                                  hintText: "Type here...",
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(10)),
                                      borderSide: borderSideProperty),
                                  enabledBorder: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(10)),
                                      borderSide: borderSideProperty),
                                  border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(10)),
                                      borderSide: borderSideProperty),
                                ),
                              ),
                              cupertino: (_, __) => CupertinoTextFieldData(
                                placeholder: "Type here...",
                                keyboardAppearance: Brightness.light,
                                decoration: BoxDecoration(
                                  shape: BoxShape.rectangle,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                ),
                              ),
                            ),
                            Center(
                              child: Text(
                                  _charCount.toString() + "/500 characters",
                                  style: TextStyle(
                                      fontSize: 17.0,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.blueColor)),
                            ),
                          ],
                        ),
                      ),
                      Center(
                        child: Text(
                          this.error,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: AppColors.redColor),
                        ),
                      ),
                      Expanded(
                        child: Container(),
                      ),
                      Center(
                        child: SizedBox(
                          height: 60,
                          child: PlatformButton(
                              onPressed:
                                  (this._aboutMe.isNotEmpty && _charCount >= 6)
                                      ? () {
                                          this._setAboutMe(context);
                                        }
                                      : null,
                              color: AppColors.blueColor,
                              disabledColor: AppColors.disabledBlueColor,
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
                              child: Text(
                                "Save Changes",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: AppConfig.heightWithDForSmallDevice(
                                      context, 20, 5),
                                ),
                              )),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
