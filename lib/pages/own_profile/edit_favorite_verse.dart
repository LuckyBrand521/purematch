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

class EditFavoriteVerse extends StatefulWidget {
  final String favoriteVerse;
  final bool isFromOnboarding;
  final Function onUpdateProfile;
  EditFavoriteVerse(
      this.favoriteVerse, this.isFromOnboarding, this.onUpdateProfile);

  @override
  EditFavoriteVerseState createState() => EditFavoriteVerseState();
}

class EditFavoriteVerseState extends State<EditFavoriteVerse> {
  // Analytics code
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';

  String _favoriteVerse;
  String _favoriteVerse1;
  String error = "";
  var _favVerseTxtCtrl = TextEditingController();
  var borderSideProperty;
  int _charCount = 0;
  @override
  void initState() {
    _favoriteVerse = widget.favoriteVerse;
    _favoriteVerse1 = _favoriteVerse;
    _charCount = _favoriteVerse.length;
    _favVerseTxtCtrl.text = _favoriteVerse;
    borderSideProperty = BorderSide(color: Colors.transparent, width: 0);
    super.initState();
    // Analytics tracking code
    amplitudeAnalytics.init(apiKey);
    analytics.setCurrentScreen(
        screenName: "edit_favorite_verse",
        screenClassOverride: "edit_favorite_verse");
    amplitudeAnalytics.logEvent("edit_favorite_verse_page");
  }

  @override
  void dispose() {
    _favVerseTxtCtrl.dispose();
    super.dispose();
  }

  bool isChangedValues() {
    var isChanged = false;
    (_favoriteVerse.length > 0 && _favoriteVerse1 != _favoriteVerse)
        ? isChanged = true
        : isChanged = false;
    return isChanged;
  }

  Future<void> _setFavoriteVerse() async {
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
    var res = await MyHttp.put(
        "users/update", {"favorite_verse": this._favoriteVerse});
    if (res.statusCode == 200) {
      //Analytics tracking code
      analytics.logEvent(
          name: "edited_profile",
          parameters: <String, dynamic>{'favorite_verse': this._favoriteVerse});
      amplitudeAnalytics.logEvent("edited_profile",
          eventProperties: {'favorite_verse': this._favoriteVerse});
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
      appBar: EditProfileDetailsAppBar(
              context: context,
              text: "Edit Favorite Verse",
              titleSize: (AppConfig.fullWidth(context) >= 375) ? 24 : 22)
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
                              controller: _favVerseTxtCtrl,
                              maxLengthEnforcement:
                                  MaxLengthEnforcement.enforced,
                              maxLines: 10,
                              onChanged: (String text) {
                                this._favoriteVerse = text;
                                setState(() {
                                  _charCount = text.length;
                                });
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
                              onPressed: (this._favoriteVerse.isNotEmpty &&
                                      _charCount > 5)
                                  ? () {
                                      this._setFavoriteVerse();
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
                              cupertinoFilled: (_, __) =>
                                  CupertinoFilledButtonData(
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
