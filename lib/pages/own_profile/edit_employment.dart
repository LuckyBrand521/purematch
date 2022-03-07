import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:pure_match/common/MyButtons.dart';
import 'package:pure_match/common/global.dart';
import 'package:pure_match/pages/own_profile/edit_profile_details_app_bar.dart';
import 'package:amplitude_flutter/amplitude.dart';
import 'package:sailor/sailor.dart';
import '../../routes.dart';
import '../AppColors.dart';
import '../MyHttp.dart';
import 'dart:io' show Platform;

class EditEmployment extends StatefulWidget {
  String company;
  String position;
  bool isSelfEmployed;
  bool isFromOnboarding;
  Function onUpdateProfile;
  EditEmployment(
      {String position,
      String company,
      bool isSelfEmployed,
      bool isFromOnboarding,
      Function onUpdateProfile}) {
    this.position = position;
    this.company = company;
    this.isSelfEmployed = isSelfEmployed;
    this.isFromOnboarding = isFromOnboarding ?? false;
    this.onUpdateProfile = onUpdateProfile;
  }

  @override
  EditEmploymentState createState() => EditEmploymentState();
}

class EditEmploymentState extends State<EditEmployment> {
  // Analytics code
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';

  String position, employer;
  bool selfEmployed;
  String position1, employer1;
  bool selfEmployed1;
  String error = "";
  TextEditingController positionCtrl = TextEditingController();
  TextEditingController employerCtrl = TextEditingController();

  @override
  void initState() {
    position = widget.position;
    positionCtrl.text = position;
    employer = widget.company;
    employerCtrl.text = employer;
    selfEmployed = widget.isSelfEmployed;
    position1 = position;
    employer1 = employer;
    selfEmployed1 = selfEmployed;
    super.initState();
    // Analytics tracking code
    amplitudeAnalytics.init(apiKey);
    analytics.setCurrentScreen(
        screenName: "edit_employment", screenClassOverride: "edit_employment");
    amplitudeAnalytics.logEvent("edit_employment_page");
  }

  @override
  void dispose() {
    positionCtrl.dispose();
    employerCtrl.dispose();
    super.dispose();
  }

  Future<void> _setEmployment() async {
    var res = await MyHttp.put("users/update", {
      "position": this.position,
      "employer": this.employer,
      "self_employed": this.selfEmployed
    });
    if (res.statusCode == 200) {
      // analytics tracking code
      analytics.logEvent(name: "edited_profile", parameters: <String, dynamic>{
        'employer': this.employer,
        "position": this.position,
        "self_employed": this.selfEmployed.toString()
      });

      amplitudeAnalytics.logEvent("edited_profile", eventProperties: {
        'employer': this.employer,
        "position": this.position,
        "self_employed": this.selfEmployed.toString()
      });

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

  bool isChangedValues() {
    var isChanged = false;

    if ((this.position.length > 0 && this.position1 != this.position) ||
        (this.employer.length > 0 && this.employer1 != this.employer) ||
        this.selfEmployed1 != this.selfEmployed) {
      isChanged = true;
    }
    return isChanged;
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
      appBar:
          EditProfileDetailsAppBar(context: context, text: "Edit Employment")
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
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      SizedBox(
                        height: AppConfig.heightWithDForSmallDevice(
                            context, 20, 10),
                      ),
                      Text(
                        "Position",
                        style: TextStyle(
                            fontSize: 28, fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: AppConfig.heightWithDForSmallDevice(
                            context, 20, 10),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 30.0),
                        child: PlatformTextField(
                          textCapitalization: TextCapitalization.words,
                          controller: positionCtrl,
                          style: TextStyle(
                              fontSize: 24,
                              color: AppColors.blueColor,
                              fontWeight: FontWeight.w700),
                          onChanged: (String position) {
                            setState(() {
                              this.position = position;
                            });
                          },
                          material: (_, __) => MaterialTextFieldData(
                            decoration: InputDecoration(
                                hintText: "Enter Position",
                                hintStyle: TextStyle(
                                    color: AppColors.disabledBlueColor),
                                contentPadding: EdgeInsets.all(0),
                                enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: AppColors.blueColor, width: 2))),
                          ),
                          cupertino: (_, __) => CupertinoTextFieldData(
                            placeholder: "Enter Position",
                            placeholderStyle:
                                TextStyle(color: AppColors.disabledBlueColor),
                            keyboardAppearance: Brightness.light,
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                    color: AppColors.blueColor, width: 2),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: AppConfig.heightWithDForSmallDevice(
                            context, 30, 15),
                      ),
                      Text(
                        "Company",
                        style: TextStyle(
                            fontSize: 28, fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: AppConfig.heightWithDForSmallDevice(
                            context, 20, 10),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 30.0),
                        child: PlatformTextField(
                          textCapitalization: TextCapitalization.words,
                          controller: employerCtrl,
                          style: TextStyle(
                              fontSize: 24,
                              color: AppColors.blueColor,
                              fontWeight: FontWeight.w700),
                          onChanged: (String employer) {
                            setState(() {
                              this.employer = employer;
                            });
                          },
                          material: (_, __) => MaterialTextFieldData(
                            decoration: InputDecoration(
                                hintText: "Enter Company",
                                hintStyle: TextStyle(
                                    color: AppColors.disabledBlueColor),
                                contentPadding: EdgeInsets.all(0),
                                enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: AppColors.blueColor, width: 2))),
                          ),
                          cupertino: (_, __) => CupertinoTextFieldData(
                            placeholder: "Enter Company",
                            placeholderStyle:
                                TextStyle(color: AppColors.disabledBlueColor),
                            keyboardAppearance: Brightness.light,
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                    color: AppColors.blueColor, width: 2),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: AppConfig.heightWithDForSmallDevice(
                            context, 30, 15),
                      ),
                      Center(
                        child: MyButtons.getBorderedButton(
                            "Self-Employed", AppColors.blueColor, () {
                          if (this.selfEmployed) {
                            setState(() {
                              this.selfEmployed = false;
                            });
                          } else {
                            setState(() {
                              this.selfEmployed = true;
                            });
                          }
                        }, this.selfEmployed == true, buttonWidth: 180.0),
                      ),
                      SizedBox(
                        height: AppConfig.heightWithDForSmallDevice(
                            context, 20, 10),
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
                      Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 20.0,
                          horizontal: 30,
                        ),
                        child: Center(
                          child: SizedBox(
                            height: 60,
                            child: PlatformButton(
                                onPressed: (this.employer.isNotEmpty &&
                                        this.position.isNotEmpty)
                                    ? () {
                                        this._setEmployment();
                                      }
                                    : null,
                                color: AppColors.blueColor,
                                disabledColor: AppColors.disabledBlueColor,
                                materialFlat: (_, __) => MaterialFlatButtonData(
                                      color: AppColors.blueColor,
                                      disabledColor:
                                          AppColors.disabledBlueColor,
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
                                    fontSize:
                                        AppConfig.heightWithDForSmallDevice(
                                            context, 20, 5),
                                  ),
                                )),
                          ),
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
