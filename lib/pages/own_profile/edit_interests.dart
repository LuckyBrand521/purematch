import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:pure_match/common/global.dart';
import 'package:pure_match/pages/own_profile/edit_profile_details_app_bar.dart';
import 'package:amplitude_flutter/amplitude.dart';
import 'package:sailor/sailor.dart';
import '../../routes.dart';
import '../AppColors.dart';
import '../MyHttp.dart';
import 'dart:io' show Platform;

class EditInterests extends StatefulWidget {
  final List<String> userInterests;
  final bool isFromOnboarding;
  final Function onUpdateProfile;
  EditInterests(
      this.userInterests, this.isFromOnboarding, this.onUpdateProfile);

  @override
  EditInterestsState createState() => EditInterestsState();
}

class EditInterestsState extends State<EditInterests> {
  // Analytics code
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';

  List<String> selectedInterests;
  List<String> selectedInterests1;
  String error = "";
  List<String> interests;
  double mediaHeight;
  bool isChangedValues() {
    var isChanged =
        Global.isChangedListValues(selectedInterests, selectedInterests1);
    return isChanged;
  }

  @override
  void initState() {
    selectedInterests = widget.userInterests;
    selectedInterests1 = List.from(selectedInterests);
    interests = [
      "Hiking",
      "Dancing",
      "Salsa Dancing",
      "Football",
      "Running",
      "Reading",
      "Nature",
      "Dogs",
      "Cats",
      "Art",
      "Movies",
      "Video Games",
      "Basketball",
      "Ping Pong",
      "Weight Lifting",
      "Politics",
      "Teaching",
      "Technology",
      "AR/VR",
      "Eating Out",
      "Nutrition",
      "TV Shows",
      "Singing",
      "Knitting",
      "Fashion",
      "Traveling",
      "Eightball Pool",
      "Volleyball",
      "Olympics",
      "Soccer",
      "Baking",
      "Crypto\ncurrency",
      "Feeding the Poor",
      "Music",
      "Learning",
      "Photography",
      "Family",
      "Work/Career",
      "Tabletop Games",
      "Crafts",
      "Cooking",
      "Swing Dancing",
      "Karaoke",
      "Archery",
      "Sushi",
      "Fantasy",
      "Sci-Fi",
      "Comics"
    ];
    super.initState();
    // Analytics tracking code
    amplitudeAnalytics.init(apiKey);
    analytics.setCurrentScreen(
        screenName: "edit_interest", screenClassOverride: "edit_interest");
    amplitudeAnalytics.logEvent("edit_interest_page");
  }

  void _setInterests() async {
    var res =
        await MyHttp.put("users/update", {"interests": this.selectedInterests});
    if (res.statusCode == 200) {
      //Analytics tracking code
      analytics.logEvent(name: "edited_profile", parameters: <String, dynamic>{
        'first_interest': selectedInterests[0],
        'second_interest': selectedInterests[1],
        'third_interest': selectedInterests[2]
      });

      amplitudeAnalytics.logEvent("edited_profile", eventProperties: {
        'first_interest': selectedInterests[0],
        'second_interest': selectedInterests[1],
        'third_interest': selectedInterests[2]
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

  SizedBox _getButton(String text, Function f, bool fill) {
    return SizedBox(
      height: 52,
      width: 85,
      child: FlatButton(
          onPressed: f,
          color: fill ? AppColors.blueColor : Colors.white,
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: AppColors.blueColor, width: 2)),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: fill ? Colors.white : AppColors.blueColor,
                fontWeight: FontWeight.w600,
                fontSize: 12),
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    double pageSize = MediaQuery.of(context).size.height;
    double notifySize = MediaQuery.of(context).padding.top;
    double appBarSize = Platform.isIOS
        ? CupertinoNavigationBar().preferredSize.height
        : AppBar().preferredSize.height;
    double heightOfSC = AppConfig.fullHeight(context) * 350 / 667;
    double scHeight = pageSize -
        (appBarSize + notifySize) -
        20 -
        MediaQuery.of(context).padding.bottom;
    List<Widget> renderInterests = [];
    int mainEnd = interests.length ~/ 3;
    print(mainEnd);

    for (int i = 0; i < mainEnd + 1; i++) {
      renderInterests.add(SizedBox(
        height: 10,
      ));
      int start = i * 3;
      int end = start + 3;
      List<Widget> l = [];
      for (int j = start; j < end && j < interests.length; j++) {
        l.add(SizedBox(
          width: 15,
        ));
        l.add(Expanded(
            child: this._getButton(interests[j], () {
          bool isSelected = this.selectedInterests.contains(interests[j]);
          if (isSelected == false) {
            this.selectedInterests.add(interests[j]);
          } else {
            this.selectedInterests.remove(interests[j]);
          }
          setState(() {});
        }, this.selectedInterests.contains(interests[j]))));
      }
      renderInterests.add(Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: l,
      ));
    }

    return PlatformScaffold(
      backgroundColor: Colors.white,
      appBar: EditProfileDetailsAppBar(context: context, text: "Edit Interests")
          .getAppBar1(isChangedValues()),
      body: PlatformScaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            child: SizedBox(
              height: scHeight,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      "Choose Interests",
                      style:
                          TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: AppColors.blueColor, width: 2.1),
                      ),
                      height: heightOfSC,
                      child: Padding(
                        padding: const EdgeInsetsDirectional.only(end: 12.0),
                        child: SingleChildScrollView(
                          child: Column(
                            children: renderInterests,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15,
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
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 30),
                          child: PlatformButton(
                              onPressed: (this.selectedInterests.isNotEmpty &&
                                      this.selectedInterests.length >= 3)
                                  ? () {
                                      this._setInterests();
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
