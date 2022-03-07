import 'dart:convert';
import 'dart:ui';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:amplitude_flutter/amplitude.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pure_match/common/RoundIndicators.dart';
import 'package:pure_match/common/global.dart';
import 'package:pure_match/pages/AppColors.dart';
import 'package:pure_match/pages/MyHttp.dart';
import 'package:pure_match/pages/onboarding/CheckYourEmail.dart';
import 'package:pure_match/pages/onboarding/basic_info/user_church_email_sent.dart';
import 'package:pure_match/pages/onboarding/basic_info/user_spiritual_birthday.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io' show Platform;
import 'package:pure_match/common/MyButtons.dart';

class UserChurch extends StatefulWidget {
  @override
  _UserChurchState createState() => _UserChurchState();
}

class _UserChurchState extends State<UserChurch> {
  // Analytics code
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';

  String selectedOrganization = "Choose an organization";
  bool restrictChurchToOrg = false;
  bool seekingChurch = false;
  String churchName = "";
  String error = "";
  bool _check = false;
  String leadPastorName = "";
  String churchWebsite = "";
  bool _loading = false;
  List _selectedChurch = List();
  List _selectedChurchName = List();
  Text selectedValue = new Text(
    "Choose an organization",
    textAlign: TextAlign.start,
    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
    overflow: TextOverflow.ellipsis,
  );
  List<dynamic> organizationsList = new List<dynamic>();
  List<dynamic> organizationsListdrop = new List<dynamic>();

  int selectedIndex = 0;
  int selected = 0;
  String tempSelectedOrganization = "Choose an organization";
  int tempSelectedIndex = 0;
  FixedExtentScrollController _scrollController;

  @override
  void initState() {
    //Initializing amplitude analytics api key
    amplitudeAnalytics.init(apiKey);
    Global.setOnboardingId(11);
    super.initState();
    this._fetchOrganizations();
  }

  Future<String> _fetchOrganizations() async {
    setState(() {
      _loading = true;
    });

    var res = await MyHttp.get("/churches");
    if (res.statusCode == 200) {
      print(res.body);
      var body = json.decode(res.body);
      if (body != null && body["churchs"] != null) {
        setState(() {
          this.organizationsListdrop.addAll(body["churchs"]);
          this.organizationsList = body["churchs"];
          _loading = false;

          this
              .organizationsList
              .insert(0, {"id": 0, "name": "Choose an organization"});
        });
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
    setState(() {
      _loading = true;
    });

    if (selectedOrganization == "Other") {
      var res = await MyHttp.put("users/update", {
        "church": this.churchName,
        "church_pastor": this.leadPastorName,
        "network_organizations": this._selectedChurchName,
        "organization_name":
            this.selectedOrganization != "Choose an organization"
                ? this.selectedOrganization
                : "",
        "seeking_church": this.seekingChurch,
        "church_website_url": churchWebsite,
        "status": "pending",
      });
      if (res.statusCode == 200) {
        // Analytics tracking code
        analytics.logEvent(
            name: "saved_user_church",
            parameters: <String, dynamic>{"church": this.churchName});

        amplitudeAnalytics.logEvent("saved_user_church",
            eventProperties: {"church": this.churchName});
        print("User updated");
        print(res.body);

        _loading = false;
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => UserSpiritualBirthDate()));
        // Analytics tracking code
        analytics.setCurrentScreen(
            screenName: "onboarding_spiritual_birthday",
            screenClassOverride: "onboarding_spiritual_birthday");
        amplitudeAnalytics.logEvent("onboarding_spiritual_birthday_page");
      } else {
        print("User update error: ${res.statusCode}");
        print("User update error: ${res.body}");
        setState(() {
          var body = json.decode(res.body);
          error = body["message"] ?? "error";
          _loading = false;
        });
      }
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => CheckYourEmail()));
    } else {
      var res = await MyHttp.put("users/update", {
        "church": this.churchName,
        "church_pastor": this.leadPastorName,
        "network_organizations": this._selectedChurchName,
        "organization_name":
            this.selectedOrganization != "Choose an organization"
                ? this.selectedOrganization
                : "",
        "seeking_church": this.seekingChurch,
        "church_website_url": churchWebsite,
      });
      if (res.statusCode == 200) {
        // Analytics tracking code
        analytics.logEvent(
            name: "saved_user_church",
            parameters: <String, dynamic>{"church": this.churchName});

        amplitudeAnalytics.logEvent("saved_user_church",
            eventProperties: {"church": this.churchName});
        print("User updated");
        print(res.body);

        _loading = false;
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => UserSpiritualBirthDate()));
        // Analytics tracking code
        analytics.setCurrentScreen(
            screenName: "onboarding_spiritual_birthday",
            screenClassOverride: "onboarding_spiritual_birthday");
        amplitudeAnalytics.logEvent("onboarding_spiritual_birthday_page");
      } else {
        print("User update error: ${res.statusCode}");
        print("User update error: ${res.body}");
        setState(() {
          var body = json.decode(res.body);
          error = body["message"] ?? "error";
          _loading = false;
        });
      }
    }
  }

  Future<void> _verifyChurch() async {
    var res =
        await MyHttp.post("/church-verify", {"undecided": this.seekingChurch});
    if (res.statusCode == 200) {
      _loading = false;
      print("User updated");
      print(res.body);
      res = await MyHttp.put("users/update", {"status": "pending"});
      if (res.statusCode == 200) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => UserChurchEmailSent(
                      seekingChurch: seekingChurch,
                    )));
      } else {
        print("User update error: ${res.statusCode}");
        print("User update error: ${res.body}");
        setState(() {
          _loading = false;
          var body = json.decode(res.body);
          error = body["message"] ?? "error";
        });        
      }
      setState(() {
        this.seekingChurch = false;
      });
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

  void _onCategorySelected(
      bool selected, category_id, String selectedChurchName) {
    if (selected == true) {
      setState(() {
        _selectedChurch.add(category_id);
        _selectedChurchName.add(selectedChurchName);
      });
    } else {
      setState(() {
        _selectedChurch.remove(category_id);
        _selectedChurchName.remove(selectedChurchName);
      });
    }
  }

  void _doneButtonClicked() {
    //Remove bottom modal from widget tree
    Navigator.of(context).pop();
    //Set temp to actual values
    this.selectedOrganization = this.tempSelectedOrganization;
    print(this.tempSelectedIndex);
    this.selectedIndex = this.tempSelectedIndex;
    //Show the selected values in the bottom sheet
    setState(() {
      if (this.selectedIndex == 0) {
        this.churchName = "";
        this.selectedValue = new Text(
          "Choose an organization",
          textAlign: TextAlign.start,
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
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
          height: AppConfig.heightWithDForSmallDevice(context, 300, 50),
          child: CupertinoPicker(
            itemExtent: AppConfig.heightWithDForSmallDevice(context, 50, 15),
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
    double height = MediaQuery.of(context).size.height;
    if (Platform.isAndroid) {
      return Scaffold(
          appBar: AppBar(
            elevation: 0.0,
            backgroundColor: Colors.white,
            leading: IconButton(
              padding: EdgeInsetsDirectional.only(start: 20.0),
              icon: Icon(Icons.arrow_back, color: AppColors.offWhiteColor),
              onPressed: () {
                Navigator.pop(context);
                //Analytics tracking codee
                analytics.setCurrentScreen(
                    screenName: 'onboarding_refered_by',
                    screenClassOverride: 'onboarding_refered_by');
                amplitudeAnalytics.logEvent("onboarding_refered_by_page");
              },
            ),
          ),
          body: Scaffold(
            backgroundColor: Colors.white,
            body: SingleChildScrollView(
              child: SizedBox(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(
                              height: 10,
                            ),
                            RoundIndicators(
                              currentIndicatorIndex: 5,
                              numberOfInidcators: 14,
                              circleSize: 12,
                            ),
                            SizedBox(
                              height:
                                  AppConfig.fontsizeForSmallDevice(context, 15),
                            ),
                            FittedBox(
                              child: Row(
                                children: [
                                  Text("My church organization is...",
                                      style: TextStyle(
                                          color: AppColors.blackColor,
                                          fontWeight: FontWeight.w600,
                                          fontSize:
                                              (AppConfig.fullHeight(context) >=
                                                      667)
                                                  ? 30
                                                  : 26)),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: ScreenUtil().setHeight(30),
                            ),
                            Center(
                              child: Container(
                                decoration: new BoxDecoration(
                                    border: Border.all(
                                        color: AppColors.greyColor,
                                        width: 1.0)),
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
                                        this.selectedOrganization =
                                            organization;
                                        if (this.selectedOrganization ==
                                            "Choose an organization") {
                                          this.churchName = "";
                                        }
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: ScreenUtil().setHeight(20),
                            ),
                            Visibility(
                                visible: this.selectedOrganization == "Other",
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    SizedBox(
                                      height: ScreenUtil().setHeight(10),
                                    ),
                                    Text(
                                      "Church Website",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize:
                                              (AppConfig.fullHeight(context) >=
                                                      667)
                                                  ? 30
                                                  : 26),
                                      textAlign: TextAlign.left,
                                    ),
                                    SizedBox(
                                      width: ScreenUtil().setHeight(35),
                                    ),
                                    CupertinoTextField(
                                      keyboardType: TextInputType.text,
                                      placeholder: "Enter a website...",
                                      textCapitalization:
                                          TextCapitalization.words,
                                      onEditingComplete: () =>
                                          FocusScope.of(context).nextFocus(),
                                      style: TextStyle(
                                          fontSize:
                                              (AppConfig.fullHeight(context) >=
                                                      667)
                                                  ? 18
                                                  : 14,
                                          color: AppColors.blueColor,
                                          fontWeight: FontWeight.w700),
                                      onChanged: (String churchWebsite) {
                                        setState(() {
                                          this.churchWebsite = churchWebsite;
                                        });
                                      },
                                      keyboardAppearance: Brightness.light,
                                      decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                              color: AppColors.blueColor,
                                              width: 2),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: ScreenUtil().setHeight(20),
                                    ),
                                    Text(
                                      "Lead Pastor",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize:
                                              (AppConfig.fullHeight(context) >=
                                                      667)
                                                  ? 30
                                                  : 26),
                                      textAlign: TextAlign.left,
                                    ),
                                    SizedBox(
                                      width: ScreenUtil().setHeight(35),
                                    ),
                                    CupertinoTextField(
                                      keyboardType: TextInputType.text,
                                      placeholder: "Enter a name...",
                                      textCapitalization:
                                          TextCapitalization.words,
                                      style: TextStyle(
                                          fontSize:
                                              (AppConfig.fullHeight(context) >=
                                                      667)
                                                  ? 18
                                                  : 14,
                                          color: AppColors.blueColor,
                                          fontWeight: FontWeight.w700),
                                      onChanged: (String leadPastorName) {
                                        setState(() {
                                          this.leadPastorName = leadPastorName;
                                        });
                                      },
                                      keyboardAppearance: Brightness.light,
                                      decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                              color: AppColors.blueColor,
                                              width: 2),
                                        ),
                                      ),
                                    ),
                                  ],
                                )),
                            Visibility(
                              visible: this.selectedOrganization !=
                                      "Choose an organization" &&
                                  this.selectedOrganization != "Other",
                              child: Column(
                                children: <Widget>[
                                  Text(
                                    "Select the Church organization(s) you want to include in your community matches:",
                                    textAlign: TextAlign.center,
                                    maxLines: 4,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color: AppColors.blackColor,
                                        fontWeight: FontWeight.w600,
                                        fontSize:
                                            (AppConfig.fullHeight(context) >=
                                                    667)
                                                ? 15
                                                : 11),
                                  ),
                                  SizedBox(
                                    height: ScreenUtil().setHeight(30),
                                  ),
                                  Column(
                                    children: <Widget>[
                                      SizedBox(
                                        child: (_loading == false)
                                            ? ListView(
                                                shrinkWrap: true,
                                                children: List<Widget>.generate(
                                                    organizationsListdrop
                                                            .length -
                                                        1, (int i) {
                                                  return new CheckboxListTile(
                                                    title: new Text(
                                                      organizationsListdrop[i]
                                                              ["name"] ??
                                                          "No Church Organization",
                                                    ),
                                                    value: _selectedChurch
                                                        .contains(
                                                            organizationsListdrop[
                                                                i]['id']),
                                                    selected: _selectedChurch
                                                        .contains(
                                                            organizationsListdrop[
                                                                    selected]
                                                                ['id']),
                                                    onChanged: (bool value) {
                                                      setState(() {
                                                        _onCategorySelected(
                                                            value,
                                                            organizationsListdrop[
                                                                i]["id"],
                                                            organizationsListdrop[
                                                                i]["name"]);
                                                      });
                                                    },
                                                  );
                                                }).toList(),
                                              )
                                            : null,
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: <Widget>[
                                      Text(
                                        "Church Name",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: (AppConfig.fullHeight(
                                                        context) >=
                                                    667)
                                                ? 30
                                                : 26),
                                        textAlign: TextAlign.left,
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    width: 35,
                                    height: 30,
                                  ),
                                  CupertinoTextField(
                                    keyboardType: TextInputType.text,
                                    placeholder: "Church name...",
                                    textCapitalization:
                                        TextCapitalization.words,
                                    onEditingComplete: () =>
                                        FocusScope.of(context).nextFocus(),
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: AppColors.blueColor,
                                        fontWeight: FontWeight.w700),
                                    onChanged: (String churchName) {
                                      setState(() {
                                        this.churchName = churchName;
                                      });
                                    },
                                    keyboardAppearance: Brightness.light,
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                            color: AppColors.blueColor,
                                            width: 2),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.only(
                            bottom: AppConfig.heightWithDForSmallDevice(
                                context, 20, 4),
                          ),
                          child: Column(
                            children: <Widget>[
                              Visibility(
                                visible: this.selectedOrganization ==
                                        "Choose an organization" ||
                                    this.selectedOrganization == "Other",
                                child: Center(
                                  child: SizedBox(
                                    height: 70,
                                    width: AppConfig.heightWithDForSmallDevice(
                                        context, 350, 40),
                                    child: Scaffold(
                                      backgroundColor: Colors.white,
                                      body: MyButtons.getBorderedButton(
                                          "Currently seeking a church",
                                          AppColors.blueColor, () {
                                        setState(() {
                                          if (this.seekingChurch)
                                            this.seekingChurch = false;
                                          else
                                            this.seekingChurch = true;
                                        });
                                        _verifyChurch();
                                      }, this.seekingChurch == true,
                                          borderRadius: 12.0),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height:
                                    AppConfig.heightForSmallDevice(context, 20),
                              ),
                              Center(
                                child: SizedBox(
                                  height: 60,
                                  width: 220,
                                  child: MaterialButton(
                                      onPressed: (this.seekingChurch ||
                                              (this.selectedIndex != 0 ||
                                                  this.churchName.isNotEmpty ||
                                                  this
                                                      .churchWebsite
                                                      .isNotEmpty))
                                          ? () {
                                              (_loading == false)
                                                  ? this._setChurchDetails()
                                                  : null;
                                            }
                                          : null,
                                      padding: EdgeInsets.symmetric(
                                          vertical:
                                              (AppConfig.fullHeight(context) >=
                                                      667)
                                                  ? 20
                                                  : 16,
                                          horizontal: 55),
                                      color: AppColors.blueColor,
                                      disabledColor:
                                          AppColors.disabledBlueColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        "Continue",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                            fontSize: (AppConfig.fullHeight(
                                                        context) >=
                                                    667)
                                                ? 16
                                                : 12),
                                      )),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ]),
                ),
              ),
            ),
          ));
    } else if (Platform.isIOS) {
      return Scaffold(
        appBar: CupertinoNavigationBar(
          brightness: Brightness.dark,
          automaticallyImplyLeading: false,
          automaticallyImplyMiddle: false,
          backgroundColor: Colors.white,
          border: Border(bottom: BorderSide.none),
          padding: EdgeInsetsDirectional.only(start: 10.0),
          leading: CupertinoNavigationBarBackButton(
              color: AppColors.offWhiteColor,
              previousPageTitle: null,
              onPressed: () {
                Navigator.pop(context);
                //Analytics tracking codee
                analytics.setCurrentScreen(
                    screenName: 'onboarding_refered_by',
                    screenClassOverride: 'onboarding_refered_by');
                amplitudeAnalytics.logEvent("onboarding_refered_by_page");
              }),
        ),
        body: CupertinoPageScaffold(
          backgroundColor: Colors.white,
          child: Container(
            height: height,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                          height: 10,
                        ),
                        RoundIndicators(
                          currentIndicatorIndex: 5,
                          numberOfInidcators: 13,
                          circleSize: 12,
                        ),
                        SizedBox(
                          height: AppConfig.fontsizeForSmallDevice(context, 20),
                        ),
                        Text(
                          "My church organization is...",
                          style: TextStyle(
                            color: AppColors.blackColor,
                            fontWeight: FontWeight.w600,
                            fontSize: AppConfig.heightWithDForSmallDevice(
                                context, 30, 4),
                          ),
                          textAlign: TextAlign.left,
                        ),
                        SizedBox(
                          height: AppConfig.heightForSmallDevice(context, 20),
                        ),
                        Center(
                          child: Container(
                              height: AppConfig.heightWithDForSmallDevice(
                                  context, 50, 10),
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
                        SizedBox(
                          height: AppConfig.heightWithDForSmallDevice(
                              context, 20, 4),
                        ),
                        Visibility(
                            visible: this.selectedOrganization == "Other",
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  "Church Website",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize:
                                        AppConfig.heightWithDForSmallDevice(
                                            context, 30, 4),
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                                SizedBox(
                                  width: AppConfig.heightWithDForSmallDevice(
                                      context, 35, 5),
                                ),
                                CupertinoTextField(
                                  keyboardType: TextInputType.text,
                                  placeholder: "Enter a website...",
                                  textCapitalization: TextCapitalization.words,
                                  onEditingComplete: () =>
                                      FocusScope.of(context).nextFocus(),
                                  style: TextStyle(
                                      fontSize:
                                          AppConfig.heightWithDForSmallDevice(
                                              context, 18, 4),
                                      color: AppColors.blueColor,
                                      fontWeight: FontWeight.w700),
                                  onChanged: (String churchWebsite) {
                                    setState(() {
                                      this.churchWebsite = churchWebsite;
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
                                SizedBox(
                                  height: AppConfig.heightWithDForSmallDevice(
                                      context, 20, 4),
                                ),
                                Text(
                                  "Lead Pastor",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize:
                                        AppConfig.heightWithDForSmallDevice(
                                            context, 30, 4),
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                                SizedBox(
                                  width: AppConfig.heightWithDForSmallDevice(
                                      context, 35, 5),
                                ),
                                CupertinoTextField(
                                  keyboardType: TextInputType.text,
                                  placeholder: "Enter a name...",
                                  textCapitalization: TextCapitalization.words,
                                  style: TextStyle(
                                      fontSize:
                                          AppConfig.heightWithDForSmallDevice(
                                              context, 18, 4),
                                      color: AppColors.blueColor,
                                      fontWeight: FontWeight.w700),
                                  onChanged: (String leadPastorName) {
                                    setState(() {
                                      this.leadPastorName = leadPastorName;
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
                              ],
                            )),
                        Visibility(
                          visible: this.selectedOrganization != "Other" &&
                              this.selectedIndex != 0,
                          child: Column(
                            children: <Widget>[
                              Text(
                                "Select the Church organization(s) you want to include in your community matches:",
                                textAlign: TextAlign.center,
                                maxLines: 4,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: AppColors.blackColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15),
                              ),
                              SizedBox(
                                height: AppConfig.heightWithDForSmallDevice(
                                    context, 30, 4),
                              ),
                              SizedBox(
                                child: (_loading == false)
                                    ? ListView(
                                        shrinkWrap: true,
                                        children: List<Widget>.generate(
                                            organizationsListdrop.length - 1,
                                            (int i) {
                                          return new CheckboxListTile(
                                            title: new Text(
                                              organizationsListdrop[i]
                                                      ["name"] ??
                                                  "No Church Organization",
                                            ),
                                            value: _selectedChurch.contains(
                                                organizationsListdrop[i]['id']),
                                            selected: _selectedChurch.contains(
                                                organizationsListdrop[selected]
                                                    ['id']),
                                            onChanged: (bool value) {
                                              setState(() {
                                                _onCategorySelected(
                                                    value,
                                                    organizationsListdrop[i]
                                                        ["id"],
                                                    organizationsListdrop[i]
                                                        ["name"]);
                                              });
                                            },
                                          );
                                        }).toList(),
                                      )
                                    : null,
                              ),
                              SizedBox(
                                height: AppConfig.heightWithDForSmallDevice(
                                    context, 20, 4),
                              ),
                              Row(
                                children: <Widget>[
                                  Text(
                                    "Church Name",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize:
                                            (AppConfig.fullHeight(context) >=
                                                    667)
                                                ? 30
                                                : 26),
                                    textAlign: TextAlign.left,
                                  ),
                                ],
                              ),
                              SizedBox(
                                width: 35,
                                height: AppConfig.heightWithDForSmallDevice(
                                    context, 30, 4),
                              ),
                              CupertinoTextField(
                                keyboardType: TextInputType.text,
                                placeholder: "Church name...",
                                textCapitalization: TextCapitalization.words,
                                onEditingComplete: () =>
                                    FocusScope.of(context).nextFocus(),
                                style: TextStyle(
                                    fontSize:
                                        AppConfig.heightWithDForSmallDevice(
                                            context, 18, 4),
                                    color: AppColors.blueColor,
                                    fontWeight: FontWeight.w700),
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
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height:
                          AppConfig.heightWithDForSmallDevice(context, 20, 4),
                    ),
                    //        Spacer(),
                    Padding(
                      padding: EdgeInsetsDirectional.only(
                        bottom: AppConfig.heightForSmallDevice(context, 20),
                      ),
                      child: Column(
                        children: <Widget>[
                          Visibility(
                            visible: this.selectedIndex == 6 ||
                                this.selectedIndex == 0,
                            child: Center(
                              child: SizedBox(
                                height: 60,
                                width: 350,
                                child: Scaffold(
                                  backgroundColor: Colors.white,
                                  body: MyButtons.getBorderedButton(
                                      "Currently seeking a church",
                                      AppColors.blueColor, () {
                                    setState(() {
                                      if (this.seekingChurch)
                                        this.seekingChurch = false;
                                      else
                                        this.seekingChurch = true;
                                    });
                                    _verifyChurch();
                                  }, this.seekingChurch == true,
                                      borderRadius: 12.0),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: AppConfig.heightWithDForSmallDevice(
                                context, 20, 4),
                          ),
                          Center(
                            child: SizedBox(
                              height: AppConfig.heightWithDForSmallDevice(
                                  context, 60, 10),
                              width: AppConfig.heightWithDForSmallDevice(
                                  context, 220, 20),
                              child: CupertinoButton(
                                  onPressed: (this.seekingChurch ||
                                          (this.selectedIndex != 0 &&
                                                  this.churchName.isNotEmpty ||
                                              this.churchWebsite.isNotEmpty))
                                      ? () {
                                          (_loading == false)
                                              ? this._setChurchDetails()
                                              : null;
                                        }
                                      : null,
                                  padding: EdgeInsets.symmetric(
                                      vertical:
                                          AppConfig.heightWithDForSmallDevice(
                                              context, 20, 4),
                                      horizontal: 55),
                                  color: AppColors.blueColor,
                                  disabledColor: AppColors.disabledBlueColor,
                                  borderRadius: BorderRadius.circular(10),
                                  child: Text(
                                    "Continue",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16),
                                  )),
                            ),
                          ),
                        ],
                      ),
                    )
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
