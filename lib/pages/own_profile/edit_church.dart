import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:pure_match/common/global.dart';
import 'package:pure_match/pages/AppColors.dart';
import 'package:pure_match/pages/MyHttp.dart';
import 'package:pure_match/pages/onboarding/basic_info/user_church_email_sent.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io' show Platform;
import 'package:pure_match/pages/own_profile/edit_profile_details_app_bar.dart';
import 'package:amplitude_flutter/amplitude.dart';
import 'package:sailor/sailor.dart';

import '../../routes.dart';

class EditChurch extends StatefulWidget {
  final String organization;
  final String church;
  final bool restrictChurchToOrg;
  final bool isFromOnboarding;
  final Function onUpdateProfile;
  EditChurch(this.organization, this.church, this.restrictChurchToOrg,
      this.isFromOnboarding, this.onUpdateProfile);

  @override
  _EditChurchState createState() => _EditChurchState();
}

class _EditChurchState extends State<EditChurch> {
  // Analytics code
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';

  String selectedOrganization;
  String churchName;
  String selectedOrganization1;
  String churchName1;
  bool restrictChurchToOrg;
  Text selectedValue;
  int selectedIndex;
  String tempSelectedOrganization;
  int tempSelectedIndex;
  String oldOrganizationNameValue;
  // ignore: deprecated_member_use
  List<dynamic> organizationsList = new List<dynamic>();
  String error = "";
  FixedExtentScrollController _scrollController;
  TextEditingController ctrl = TextEditingController();

  @override
  void initState() {
    this._fetchOrganizations();
    selectedOrganization =
        widget.organization.isNotEmpty && widget.organization != ""
            ? widget.organization
            : "Choose an organization";
    selectedOrganization1 = selectedOrganization;
    tempSelectedOrganization = selectedOrganization;
    oldOrganizationNameValue = selectedOrganization;
    selectedValue = new Text(
      selectedOrganization,
      textAlign: TextAlign.start,
      style: selectedOrganization != "Choose an organization"
          ? TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: AppColors.blueColor)
          : TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      overflow: TextOverflow.ellipsis,
    );
    selectedIndex = organizationsList.indexOf(selectedOrganization);
    tempSelectedIndex = selectedIndex;
    churchName = widget.church;
    churchName1 = churchName;
    ctrl.text = churchName;
    restrictChurchToOrg = widget.restrictChurchToOrg;
    super.initState();
    // Analytics tracking code
    amplitudeAnalytics.init(apiKey);
    analytics.setCurrentScreen(
        screenName: "edit_church", screenClassOverride: "edit_church");
    amplitudeAnalytics.logEvent("edit_church_page");
  }

  @override
  void dispose() {
    if (_scrollController != null) {
      _scrollController.dispose();
    }

    ctrl.dispose();
    super.dispose();
  }

  bool isChangedValues() {
    var isChanged = false;

    if (this.selectedOrganization1 != this.selectedOrganization ||
        (this.churchName.length > 0 && this.churchName1 != this.churchName)) {
      isChanged = true;
    }
    return isChanged;
  }

  Future<String> _fetchOrganizations() async {
    var res = await MyHttp.get("/churches");
    if (res.statusCode == 200) {
      print(res.body);
      var body = json.decode(res.body);
      if (body != null && body["churchs"] != null) {
        setState(() {
          this.organizationsList = body["churchs"];
          this
              .organizationsList
              .insert(0, {"id": 0, "name": "Choose an organization"});
        });
        print(this.organizationsList);
      }
      return "Success";
    } else {
      print("Church get error status code: ${res.statusCode}");
      print("Church get error: ${res.body}");
      setState(() {
        var body = json.decode(res.body);
        error = body["message"] ?? "error";
      });
      return "Error";
    }
  }

  Future<void> _setChurchDetails() async {
    var res = await MyHttp.put("users/update", {
      "church": this.churchName,
      "organization_name": this.selectedOrganization != "Choose an organization"
          ? this.selectedOrganization
          : "",
      "restrict_matches_to_organization": this.restrictChurchToOrg
    });
    if (res.statusCode == 200) {
      //Analytics tracking code
      analytics.logEvent(
          name: "edited_profile",
          parameters: <String, dynamic>{'church': this.churchName});

      amplitudeAnalytics.logEvent("edited_profile",
          eventProperties: {'church': this.churchName});
      print("User updated");
      print(res.body);
      if (this.selectedOrganization == "Other") {
        _verifyChurch();
      } else {
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
      }
    } else {
      print("User update error: ${res.statusCode}");
      print("User update error: ${res.body}");
      setState(() {
        error = res.statusCode.toString() + " " + res.body;
      });
    }
  }

  Future<void> _verifyChurch() async {
    if (this.oldOrganizationNameValue != "Other") {
      var res = await MyHttp.post("/church-verify", {"undecided": false});
      if (res.statusCode == 200) {
        print("User updated");
        print(res.body);
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => UserChurchEmailSent()));
        // Analytics tracking code
        amplitudeAnalytics.init(apiKey);
        analytics.setCurrentScreen(
            screenName: "user_church_email",
            screenClassOverride: "user_church_email");
        amplitudeAnalytics.logEvent("user_church_email_page");
      } else {
        print("User update error: ${res.statusCode}");
        print("User update error: ${res.body}");
        setState(() {
          error = "$res.statusCode\n$res.body";
        });
      }
    } else {
      Navigator.pop(context, {
        "organization": this.selectedOrganization,
        "church": this.churchName,
        "restrictChurchToOrg": this.restrictChurchToOrg
      });
    }
  }

  void _doneButtonClicked() {
    //Remove bottom modal from widget tree
    Navigator.of(context).pop();
    setState(() {
      //Set temp to actual values
      this.selectedOrganization = this.tempSelectedOrganization;
      print(this.tempSelectedIndex);
      this.selectedIndex = this.tempSelectedIndex;

      if (this.selectedIndex == 0) {
        this.churchName = "";
        this.selectedValue = new Text(
          "Choose an organization",
          textAlign: TextAlign.start,
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
          overflow: TextOverflow.ellipsis,
        );
      } else {
        this.selectedValue = new Text(
          this.selectedOrganization,
          textAlign: TextAlign.start,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.blueColor),
        );
      }
    });
  }

  Column _buildOrganizationBottomPicker() {
    _scrollController =
        new FixedExtentScrollController(initialItem: this.selectedIndex);
    tempSelectedIndex = selectedIndex;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Container(
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.doneBarColor,
              border: Border(
                bottom: BorderSide(
                  color: AppColors.doneBarColor,
                  width: 0.0,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Center(
                  child: CupertinoButton(
                      child: Icon(CupertinoIcons.left_chevron,
                          color: AppColors.blueColor, size: 30.0),
                      onPressed: () => _scrollController.jumpToItem(
                          tempSelectedIndex != 0
                              ? tempSelectedIndex - 1
                              : organizationsList.length - 1)),
                ),
                Center(
                  child: CupertinoButton(
                      child: Icon(CupertinoIcons.right_chevron,
                          color: AppColors.blueColor, size: 30.0),
                      onPressed: () => _scrollController.jumpToItem(
                          tempSelectedIndex != organizationsList.length - 1
                              ? tempSelectedIndex + 1
                              : 0)),
                ),
                new Spacer(),
                Center(
                  child: CupertinoButton(
                    child: Text(
                      "Done",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: AppColors.blueColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 20),
                    ),
                    onPressed: () => _doneButtonClicked(),
                  ),
                ),
              ],
            )),
        SizedBox(
          height: 300,
          child: CupertinoPicker(
            itemExtent: 50,
            backgroundColor: Colors.white,
            useMagnifier: true,
            children: List<Widget>.generate(organizationsList.length, (int i) {
              return Center(
                child: Text(
                    organizationsList[i]["name"] ?? "No Church Organization",
                    textAlign: TextAlign.start,
                    style: TextStyle(
                        color: AppColors.blackColor,
                        fontStyle: FontStyle.normal,
                        fontWeight: FontWeight.w400,
                        fontSize: 18.0)),
              );
            }),
            scrollController: _scrollController,
            onSelectedItemChanged: (index) {
              setState(() {
                this.tempSelectedIndex = index;
                this.tempSelectedOrganization =
                    organizationsList[index]["name"];
              });
            },
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    PlatformAppBar appBar =
        EditProfileDetailsAppBar(context: context, text: "Edit Church")
            .getAppBar1(isChangedValues());
    double pageSize = MediaQuery.of(context).size.height;
    double notifySize = MediaQuery.of(context).padding.top;
    double appBarSize = Platform.isIOS
        ? CupertinoNavigationBar().preferredSize.height
        : AppBar().preferredSize.height;
    if (Platform.isAndroid) {
      return PlatformScaffold(
        backgroundColor: Colors.white,
        appBar: appBar,
        body: Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              child: SizedBox(
                height: pageSize - (appBarSize + notifySize),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        SizedBox(
                          height: AppConfig.heightWithDForSmallDevice(
                              context, 20, 5),
                        ),
                        Text("Church Organization",
                            style: TextStyle(
                              color: AppColors.blackColor,
                              fontWeight: FontWeight.w600,
                              fontSize: AppConfig.heightWithDForSmallDevice(
                                  context, 28, 8),
                            )),
                        SizedBox(
                          height: 30,
                        ),
                        Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 30.0),
                            child: Container(
                              decoration: new BoxDecoration(
                                  border: Border.all(
                                      color: AppColors.greyColor, width: 1.0)),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 1),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  isExpanded: true,
                                  icon: Icon(
                                    Icons.keyboard_arrow_down,
                                    color: AppColors.blueColor,
                                  ),
                                  value: selectedOrganization,
                                  //hint: Text("Choose an organization"),
                                  items: organizationsList.map((var value) {
                                    return new DropdownMenuItem<String>(
                                      value: value["name"],
                                      child: new Text(
                                        value["name"],
                                        style: TextStyle(
                                            color: AppColors.blueColor,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 18),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (String organization) {
                                    setState(() {
                                      this.selectedOrganization = organization;
                                      if (this.selectedOrganization ==
                                          "Choose an organization") {
                                        this.churchName = "";
                                      } else {
                                        this.churchName = ctrl.text;
                                      }
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Visibility(
                            visible: this.selectedOrganization !=
                                "Choose an organization",
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  "Church name",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize:
                                        AppConfig.heightWithDForSmallDevice(
                                            context, 28, 8),
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                                SizedBox(
                                  width: 30,
                                ),
                                Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 30.0),
                                  child: TextField(
                                    textCapitalization:
                                        TextCapitalization.words,
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: AppColors.blueColor,
                                        fontWeight: FontWeight.w700),
                                    controller: ctrl,
                                    onChanged: (String churchName) {
                                      setState(() {
                                        this.churchName = churchName;
                                      });
                                    },
                                    decoration: InputDecoration(
                                        contentPadding: EdgeInsets.all(0),
                                        enabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: AppColors.blueColor,
                                                width: 2))),
                                  ),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                              ],
                            )),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 30),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Checkbox(
                                value: this.restrictChurchToOrg,
                                onChanged: (value) {
                                  setState(() {
                                    this.restrictChurchToOrg = value;
                                  });
                                },
                                activeColor: AppColors.disabledBlueColor,
                                checkColor: AppColors.blueColor,
                                tristate: false,
                              ),
                              Flexible(
                                child: Text(
                                  "Restrict my community and matches to members of my church organization",
                                  textAlign: TextAlign.center,
                                  maxLines: 4,
                                  overflow: TextOverflow.ellipsis,
                                  style: this.restrictChurchToOrg
                                      ? TextStyle(
                                          color: AppColors.blackColor,
                                          fontWeight: FontWeight.w700,
                                          fontSize:
                                              (AppConfig.fullHeight(context) >=
                                                      667)
                                                  ? 18
                                                  : 15)
                                      : TextStyle(
                                          color: AppColors.blackColor,
                                          fontWeight: FontWeight.w400,
                                          fontSize:
                                              (AppConfig.fullHeight(context) >=
                                                      667)
                                                  ? 16
                                                  : 13),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: AppConfig.heightWithDForSmallDevice(
                              context, 15, 5),
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
                          padding: EdgeInsetsDirectional.only(
                              bottom: 20.0, start: 30, end: 30),
                          child: Center(
                            child: SizedBox(
                              height: 60,
                              child: MaterialButton(
                                  onPressed: (this.selectedOrganization !=
                                              "Choose an organization" &&
                                          this.churchName.isNotEmpty &&
                                          this.churchName.length > 0)
                                      ? () {
                                          this._setChurchDetails();
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
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize:
                                            (AppConfig.fullHeight(context) >=
                                                    667)
                                                ? 20
                                                : 15),
                                  )),
                            ),
                          ),
                        ),
                      ]),
                ),
              ),
            ),
          ),
        ),
      );
    } else if (Platform.isIOS) {
      return PlatformScaffold(
        appBar: appBar,
        body: SafeArea(
          child: CupertinoPageScaffold(
            backgroundColor: Colors.white,
            child: SingleChildScrollView(
              child: SizedBox(
                height: pageSize - (appBarSize + notifySize),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        "Church Organization",
                        style: TextStyle(
                          color: AppColors.blackColor,
                          fontWeight: FontWeight.w600,
                          fontSize: AppConfig.heightWithDForSmallDevice(
                              context, 28, 8),
                        ),
                        textAlign: TextAlign.left,
                      ),
                      SizedBox(
                        height: AppConfig.heightWithDForSmallDevice(
                            context, 30, 15),
                      ),
                      Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 30.0),
                          child: Container(
                              height: 50,
                              decoration: new BoxDecoration(
                                  border: Border.all(
                                      color: AppColors.greyColor, width: 1.0)),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 1),
                              child: GestureDetector(
                                child: Row(
                                  children: <Widget>[
                                    Expanded(child: selectedValue),
                                    SizedBox(width: 5),
                                    Icon(Icons.keyboard_arrow_down,
                                        color: AppColors.blueColor)
                                  ],
                                ),
                                onTap: () => showModalBottomSheet(
                                    context: context,
                                    backgroundColor: Colors.white,
                                    elevation: 1.0,
                                    builder: (BuildContext pickerContext) {
                                      return _buildOrganizationBottomPicker();
                                    }),
                              )),
                        ),
                      ),
                      SizedBox(
                        height: AppConfig.heightWithDForSmallDevice(
                            context, 20, 10),
                      ),
                      Visibility(
                          visible: this.selectedIndex != 0,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                "Church name",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: AppConfig.heightWithDForSmallDevice(
                                      context, 28, 8),
                                ),
                                textAlign: TextAlign.left,
                              ),
                              SizedBox(
                                width: AppConfig.heightWithDForSmallDevice(
                                    context, 30, 15),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 30.0),
                                child: CupertinoTextField(
                                  textCapitalization: TextCapitalization.words,
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: AppColors.blueColor,
                                      fontWeight: FontWeight.w700),
                                  controller: ctrl,
                                  onChanged: (String churchName) {
                                    setState(() {
                                      this.churchName = churchName;
                                    });
                                  },
                                  keyboardAppearance: Brightness.light,
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                          color: AppColors.blueColor, width: 2),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: AppConfig.heightWithDForSmallDevice(
                                    context, 20, 5),
                              ),
                            ],
                          )),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 30.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Flexible(
                              child: Text(
                                "Restrict my community and matches to members of my church organization",
                                textAlign: TextAlign.left,
                                maxLines: 5,
                                overflow: TextOverflow.ellipsis,
                                style: this.restrictChurchToOrg
                                    ? TextStyle(
                                        color: AppColors.blackColor,
                                        fontWeight: FontWeight.w700,
                                        fontSize:
                                            (AppConfig.fullHeight(context) >=
                                                    667)
                                                ? 18
                                                : 15)
                                    : TextStyle(
                                        color: AppColors.blackColor,
                                        fontWeight: FontWeight.w400,
                                        fontSize:
                                            (AppConfig.fullHeight(context) >=
                                                    667)
                                                ? 16
                                                : 15),
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            CupertinoSwitch(
                              activeColor: Color.fromRGBO(0, 186, 132, 1),
                              value: this.restrictChurchToOrg,
                              onChanged: (bool newValue) {
                                setState(() {
                                  this.restrictChurchToOrg = newValue;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 10,
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
                      Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                        child: Center(
                          child: SizedBox(
                            height: 60,
                            child: CupertinoButton(
                                onPressed: (this.selectedOrganization !=
                                            "Choose an organization" &&
                                        this.churchName.isNotEmpty &&
                                        this.churchName.length > 0)
                                    ? () {
                                        this._setChurchDetails();
                                      }
                                    : null,
                                color: AppColors.blueColor,
                                disabledColor: AppColors.disabledBlueColor,
                                borderRadius: BorderRadius.circular(10),
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
      );
    } else return Container();
  }
}
