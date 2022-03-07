import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:amplitude_flutter/amplitude.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:pure_match/common/global.dart';
import 'package:pure_match/pages/AppColors.dart';
import 'package:pure_match/pages/MyHttp.dart';
import 'package:flutter/cupertino.dart';
import 'package:pure_match/pages/own_profile/edit_profile_details_app_bar.dart';
import 'package:sailor/sailor.dart';
import 'dart:io' show Platform;

import '../../../routes.dart';

class EditHeight extends StatefulWidget {
  final String height;
  final Function onSaveheight;
  final bool isFromOnboarding;
  const EditHeight(
      {Key key, this.height, this.onSaveheight, this.isFromOnboarding})
      : super(key: key);
  @override
  _EditHeightState createState() => _EditHeightState();
}

class _EditHeightState extends State<EditHeight> {
  // Analytics code
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';

  String error = "";
  String height = "";
  bool _loading = false;
  bool isChangedValues() {
    var isChanged = false;
    (double.tryParse(this.height) != null)
        ? isChanged = true
        : isChanged = false;
    return isChanged;
  }

  Future<void> _setHeight() async {
    setState(() {
      _loading = true;
    });
    double dHeight = double.tryParse(this.height);
    var res = await MyHttp.put("users/update", {"height": dHeight});
    if (res.statusCode == 200) {
      //analytics tracking code
      analytics.logEvent(
          name: "saved_user_height",
          parameters: <String, dynamic>{"height": this.height});

      amplitudeAnalytics.logEvent("saved_user_height",
          eventProperties: {"height": this.height});

      print("User updated");
      print(res.body);
      _loading = false;

      // Analytics tracking code
      analytics.setCurrentScreen(
          screenName: 'onboarding_marital_status',
          screenClassOverride: 'onboarding_marital_status');
      amplitudeAnalytics.logEvent("onboarding_marital_status_page");

      if (widget.isFromOnboarding != null && widget.isFromOnboarding) {
        Navigator.pop(context);
        widget.onSaveheight();
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
        _loading = false;
        var body = json.decode(res.body);
        error = body["message"] ?? "error";
      });
    }
  }

  final Map<String, String> heightMap = {
    "4'5 (135 cm)": "135",
    "4'6 (137 cm)": "137",
    "4'7 (139 cm)": "140",
    "4'8 (142 cm)": "142",
    "4'9 (145 cm)": "145",
    "4'10 (147 cm)": "147",
    "4'11 (150 cm)": "150",
    "5'0 (152 cm)": "152",
    "5'1 (154 cm)": "155",
    "5'2 (157 cm)": "158",
    "5'3 (160 cm)": "160",
    "5'4 (162 cm)": "163",
    "5'5 (165 cm)": "165",
    "5'6 (168 cm)": "168",
    "5'7 (170 cm)": "170",
    "5'8 (173 cm)": "173",
    "5'9 (175 cm)": "175",
    "5'10 (178 cm)": "178",
    "5'11 (180 cm)": "180",
    "6'0 (183 cm)": "183",
    "6'1 (185 cm)": "185",
    "6'2 (188 cm)": "188",
    "6'3 (191 cm)": "191",
    "6'4 (193 cm)": "193",
    "6'5 (196 cm)": "196",
    "6'6 (198 cm)": "198",
    "6'7 (200 cm)": "201",
    "6'8 (203 cm)": "203",
  };

  // only for android
  String dropDownVal = "4'5 (135 cm)";
  List<String> heightList = ["4'5 (135 cm)"];
  int positionInMapHeight = 0;

  @override
  void initState() {
    heightList = heightMap.keys.toList();
    print(heightList);
    this.dropDownVal = heightList[0];
    super.initState();
    //Initializing amplitude analytics api key
    amplitudeAnalytics.init(apiKey);
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    List<String> heightInCmList = heightMap.values.toList();
    int indexHeight = 0;
    bool keyPosition = false;
    heightMap.entries.forEach((element) {
      if (element.value == widget.height) {
        keyPosition = true;
      }
      if (!keyPosition) indexHeight++;
    });
    print(indexHeight);
    if (Platform.isAndroid) {
      return PlatformScaffold(
        appBar: EditProfileDetailsAppBar(context: context, text: "Edit Height")
            .getAppBar1(isChangedValues()),
        body: SafeArea(
          child: Scaffold(
            backgroundColor: Colors.white,
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      height: 20,
                    ),

                    Text("Select your Height:",
                        style: TextStyle(
                            fontSize: 28, fontWeight: FontWeight.w600)),
                    SizedBox(height: 20),
                    DropdownButton<String>(
                      value: this.dropDownVal,
                      isExpanded: true,
                      items: heightList.map((String value) {
                        return new DropdownMenuItem<String>(
                          value: value,
                          child: new Text(
                            value,
                            style: TextStyle(fontSize: 16),
                          ),
                        );
                      }).toList(),
                      onChanged: (String val) {
                        print(val);
                        setState(() {
                          this.dropDownVal = val;
                          this.height = heightMap[val];
                        });
                      },
                    ),
//                  TextField(
//                    keyboardType: TextInputType.number,
//                    style: TextStyle(fontSize: 22, color: AppColors.blueColor),
//                    onChanged: (String height) {
//                      setState(() {
//                        this.height = height;
//                      });
//                    },
//                    decoration: InputDecoration(
//                        hintText: "In cm",
//                        contentPadding: EdgeInsets.all(0),
//                        enabledBorder: UnderlineInputBorder(
//                            borderSide: BorderSide(
//                                color: AppColors.blueColor, width: 2))),
//                  ),
                    SizedBox(
                      height: 50,
                    ),
                    Text(this.error),
                    /*SizedBox(
                      height: 30,
                    ),*/
                    Container(
                      padding: EdgeInsetsDirectional.only(bottom: 20, top: 20),
                      child: Align(
                        alignment: Alignment.center,
                        child: SizedBox(
                          height: 60,
                          width: 220,
                          child: FlatButton(
                              onPressed: (isChangedValues())
                                  ? () {
                                      if (_loading == false) {
                                        this._setHeight();
                                      } else {
                                        null;
                                      }
                                    }
                                  : null,
                              color: AppColors.blueColor,
                              disabledColor: AppColors.disabledBlueColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                "Save Changes",
                                style: TextStyle(
                                    color: AppColors.blackColor,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16),
                              )),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    } else if (Platform.isIOS) {
      return PlatformScaffold(
        backgroundColor: Colors.white,
        appBar: EditProfileDetailsAppBar(context: context, text: "Edit Heights")
            .getAppBar1(isChangedValues()),
        body: SafeArea(
          child: CupertinoPageScaffold(
            backgroundColor: Colors.white,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      height:
                          AppConfig.heightWithDForSmallDevice(context, 20, 5),
                    ),
                    Text("Select your Height:",
                        style: TextStyle(
                            fontSize:
                                AppConfig.fontsizeForSmallDevice(context, 28),
                            fontWeight: FontWeight.w600)),
                    SizedBox(
                      height:
                          AppConfig.heightWithDForSmallDevice(context, 20, 5),
                    ),
                    Center(
                        child: SizedBox(
                            height: AppConfig.heightWithDForSmallDevice(
                                context, 200, 40),
                            width: 300,
                            child: CupertinoPicker(
                              itemExtent: AppConfig.heightWithDForSmallDevice(
                                  context, 50, 20),
                              backgroundColor: CupertinoColors.white,
                              useMagnifier: true,
                              children: List<Widget>.generate(heightList.length,
                                  (int i) {
                                return Text(heightList[i] ?? "No Height",
                                    style: TextStyle(
                                        color:
                                            AppColors.listviewSelectedCellColor,
                                        fontStyle: FontStyle.normal,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 23.0));
                              }),
                              scrollController: new FixedExtentScrollController(
                                initialItem: indexHeight,
                              ),
                              onSelectedItemChanged: (index) {
                                setState(() {
                                  this.height = heightInCmList[index];
                                });
                              },
                            ))),
                    SizedBox(
                      height: height * 0.1,
                    ),
                    Text(this.error),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: SizedBox(
                        height: 60,
                        width: 220,
                        child: FlatButton(
                            onPressed: (isChangedValues())
                                ? () {
                                    this._setHeight();
                                  }
                                : null,
                            color: AppColors.greyColor,
                            disabledColor: AppColors.doneBarColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              "Save Changes",
                              style: TextStyle(
                                  color: AppColors.blackColor,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 16),
                            )),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
  }
}
