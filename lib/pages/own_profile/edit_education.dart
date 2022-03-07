import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:pure_match/common/MyButtons.dart';
import 'package:amplitude_flutter/amplitude.dart';
import 'package:pure_match/common/global.dart';
import 'package:sailor/sailor.dart';
import '../../routes.dart';
import '../AppColors.dart';
import '../MyHttp.dart';
import 'edit_profile_details_app_bar.dart';

class EditEducation extends StatefulWidget {
  final String school, educationLevel;
  final bool isFromOnboarding;
  final Function onUpdateProfile;
  EditEducation(this.school, this.educationLevel, this.isFromOnboarding,
      this.onUpdateProfile);

  @override
  EditEducationState createState() => EditEducationState();
}

class EditEducationState extends State<EditEducation> {
  // Analytics code
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';

  String schoolName;
  String schooName1;
  int education = -1;
  int education1 = -1;
  String error = "";
  TextEditingController ctrl = TextEditingController();
  List<String> educationLevels = [
    "High School",
    "Associate",
    "Bachelor",
    "Graduate",
    "Doctorate",
    "Professional"
  ];

  @override
  void initState() {
    schoolName = widget.school;
    schooName1 = schoolName;
    ctrl.text = schoolName;
    education = educationLevels.indexOf(widget.educationLevel);
    education1 = education;
    super.initState();
    // Analytics tracking code
    amplitudeAnalytics.init(apiKey);
    analytics.setCurrentScreen(
        screenName: "edit_education", screenClassOverride: "edit_education");
    amplitudeAnalytics.logEvent("edit_education_page");
  }

  @override
  void dispose() {
    ctrl.dispose();
    super.dispose();
  }

  bool isChangedValues() {
    var isChanged = false;
    // (pickedYear1 != pickedYear) ? isChanged = true : isChanged = false;
    if ((schoolName.length > 0 && schooName1 != schoolName) ||
        education1 != education) {
      isChanged = true;
    }
    return isChanged;
  }

  Future<void> _setEducation() async {
    var res = await MyHttp.put("users/update", {
      "education": this.educationLevels[this.education],
      "school_name": schoolName
    });
    if (res.statusCode == 200) {
      //Analytics tracking code
      analytics.logEvent(name: "edited_profile", parameters: <String, dynamic>{
        'education': this.educationLevels[this.education]
      });
      amplitudeAnalytics.logEvent("edited_profile",
          eventProperties: {'education': this.educationLevels[this.education]});
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
        error = "$res.status\n$res.body";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    List<Widget> button = List<Widget>();
    for (var i = 0; i < educationLevels.length; i++) {
      button.add(Column(
        children: <Widget>[
          SizedBox(
            height: 10,
          ),
          MyButtons.getBorderedButton(educationLevels[i], AppColors.blueColor,
              () {
            setState(() {
              this.education = i;
            });
          }, this.education == i),
        ],
      ));
    }

    return PlatformScaffold(
      appBar: EditProfileDetailsAppBar(context: context, text: "Edit Education")
          .getAppBar1(isChangedValues()),
      body: PlatformScaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(new FocusNode());
            },
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      "School",
                      style:
                          TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30.0),
                      child: PlatformTextField(
                        textCapitalization: TextCapitalization.words,
                        controller: ctrl,
                        style: TextStyle(
                            fontSize: 24,
                            color: AppColors.blueColor,
                            fontWeight: FontWeight.w700),
                        onChanged: (String school) {
                          setState(() {
                            this.schoolName = school;
                          });
                        },
                        material: (_, __) => MaterialTextFieldData(
                          decoration: InputDecoration(
                              hintText: "School Name",
                              hintStyle:
                                  TextStyle(color: AppColors.disabledBlueColor),
                              contentPadding: EdgeInsets.all(0),
                              enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: AppColors.blueColor, width: 2))),
                        ),
                        cupertino: (_, __) => CupertinoTextFieldData(
                          placeholder: "School Name",
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
                      height: 30,
                    ),
                    Text(
                      "Education Level",
                      style:
                          TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Column(
                      children: button,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Visibility(
                      visible: this.error.isNotEmpty,
                      child: Center(
                        child: Text(
                          this.error,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: AppColors.redColor),
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 20.0, horizontal: 10),
                      child: Center(
                        child: SizedBox(
                          height: 60,
                          child: PlatformButton(
                              onPressed: (this.education != -1)
                                  ? () {
                                      this._setEducation();
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
                                    fontSize: 20),
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
    );
  }
}
