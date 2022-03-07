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

class EditKids extends StatefulWidget {
  String haveKids;
  String wantKids;
  int noOfKids;
  bool isFromOnboarding;
  Function() onUpdateProfile;

  EditKids(
      {String haveKids,
      String wantKids,
      int noOfKids,
      bool isFromOnboarding,
      Function onUpdateProfile}) {
    this.haveKids = haveKids;
    this.wantKids = wantKids;
    this.noOfKids = noOfKids;
    this.isFromOnboarding = isFromOnboarding ?? false;
    this.onUpdateProfile = onUpdateProfile;
  }
  @override
  EditKidsState createState() => EditKidsState();
}

class EditKidsState extends State<EditKids> {
  // Analytics code
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';
  int selectedPresentKid = -1;
  int selectedFutureKid = -1;
  int selectedPresentKid1 = -1;
  int selectedFutureKid1 = -1;
  var currentKids = ["No kids", "Kids away\n from home", "Kids at home"];
  var currentKids1 = ["No kids", "Kids away from home", "Kids at home"];
  var futureKids = ["I don’t want kids", "I'm open to kids", "I want kids"];
  var futureKids1 = ["Doesn't want kids", "Open to kids", "Wants kids"];
  String numberOfKids;
  String numberOfKids1;
  List<String> kidsNumberList =
      List.generate(20, (int index) => (index + 1).toString(), growable: true);
  String error = "";

  Text selectedKidiOSValue;
  FixedExtentScrollController _iOSScrollController;
  int tempiOSSelectedIndex;

  @override
  void initState() {
    // this.selectedPresentKid = currentKids.indexWhere((String value) {
    //   return value.replaceAll("\n", "") == widget.haveKids;
    // });
    // this.selectedFutureKid = futureKids.indexWhere((String value) {
    //   return value.replaceAll("\n", "") == widget.wantKids;
    // });
    for (int i = 0; i < currentKids.length; i++) {
      String value1 = currentKids[i].replaceAll("\n", "");
      String value2 = currentKids1[i];
      if (widget.haveKids == value1 || widget.haveKids == value2) {
        this.selectedPresentKid = i;
        break;
      }
    }

    for (int j = 0; j < futureKids.length; j++) {
      String value1 = futureKids[j].replaceAll("\n", "");
      String value2 = futureKids1[j];
      if (widget.wantKids == value1 || widget.wantKids == value2) {
        this.selectedFutureKid = j;
        break;
      }
    }

    this.selectedPresentKid1 = this.selectedPresentKid;
    this.selectedFutureKid1 = this.selectedFutureKid;
    this.numberOfKids = (widget.noOfKids != 0 && widget.noOfKids != null)
        ? widget.noOfKids.toString()
        : "Select Number of Kids";
    this.numberOfKids1 = this.numberOfKids;
    kidsNumberList.insert(0, "Select Number of Kids");
    this.selectedKidiOSValue = new Text(
      (this.numberOfKids != null && this.numberOfKids.isNotEmpty)
          ? this.numberOfKids
          : "Select Number of Kids",
      textAlign: TextAlign.center,
      style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
      overflow: TextOverflow.ellipsis,
    );
    super.initState();
    // Analytics tracking code
    amplitudeAnalytics.init(apiKey);
    analytics.setCurrentScreen(
        screenName: "edit_kids", screenClassOverride: "edit_kids");
    amplitudeAnalytics.logEvent("edit_kids_page");
  }

  @override
  void dispose() {
    if (_iOSScrollController != null) {
      _iOSScrollController.dispose();
    }

    super.dispose();
  }

  bool isChangedValues() {
    var isChanged = false;
    if (this.selectedPresentKid1 != this.selectedPresentKid ||
        this.selectedFutureKid1 != this.selectedFutureKid ||
        this.numberOfKids1 != this.numberOfKids) {
      isChanged = true;
    }
    return isChanged;
  }

  Future<void> _setKids() async {
    int kidsNo = int.tryParse(this.numberOfKids);
    var reqData = {
      "kids_have":
          this.currentKids1[this.selectedPresentKid].replaceAll("\n", ""),
      "kids_want":
          this.futureKids1[this.selectedFutureKid].replaceAll("\n", ""),
      "no_of_kids": kidsNo
    };
    var res = await MyHttp.put("users/update", reqData);
    if (res.statusCode == 200) {
      // Analytics tracking code
      analytics.logEvent(name: "edited_profile", parameters: <String, dynamic>{
        'current_kids': this.currentKids[this.selectedPresentKid],
        "future_kids": futureKids[this.selectedFutureKid],
        "no_of_kids": this.numberOfKids
      });

      amplitudeAnalytics.logEvent("edited_profile", eventProperties: {
        'current_kids': this.currentKids[this.selectedPresentKid],
        "future_kids": futureKids[this.selectedFutureKid],
        "no_of_kids": this.numberOfKids
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

  void _doneButtonClicked() {
    //Remove bottom modal from widget tree
    Navigator.of(context).pop();
    //Set temp to actual values
    this.numberOfKids = kidsNumberList[this.tempiOSSelectedIndex];
    print(this.tempiOSSelectedIndex);
    //Show the selected values in the bottom sheet
    setState(() {
      if (this.numberOfKids == "Select Number of Kids") {
        this.selectedKidiOSValue = new Text(
          this.numberOfKids,
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
          overflow: TextOverflow.ellipsis,
        );
      } else {
        this.selectedKidiOSValue = new Text(
          this.numberOfKids,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.blueColor),
        );
      }
    });
  }

  Column _buildiOSNoOfKidBottomPicker() {
    _iOSScrollController = new FixedExtentScrollController(
        initialItem: int.tryParse(this.numberOfKids) ?? 0);
    tempiOSSelectedIndex = int.tryParse(this.numberOfKids) ?? 0;
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
                      onPressed: () => _iOSScrollController.jumpToItem(
                          tempiOSSelectedIndex != 0
                              ? tempiOSSelectedIndex - 1
                              : kidsNumberList.length - 1)),
                ),
                Center(
                  child: CupertinoButton(
                      child: Icon(CupertinoIcons.right_chevron,
                          color: AppColors.blueColor, size: 30.0),
                      onPressed: () => _iOSScrollController.jumpToItem(
                          tempiOSSelectedIndex != kidsNumberList.length - 1
                              ? tempiOSSelectedIndex + 1
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
            itemExtent: 50,
            backgroundColor: Colors.white,
            useMagnifier: true,
            children: List<Widget>.generate(kidsNumberList.length, (int i) {
              return Center(
                child: Text(kidsNumberList[i] ?? "No Number of Kids",
                    textAlign: TextAlign.start,
                    style: TextStyle(
                        color: AppColors.blackColor,
                        fontStyle: FontStyle.normal,
                        fontWeight: FontWeight.w400,
                        fontSize: 18.0)),
              );
            }),
            scrollController: _iOSScrollController,
            onSelectedItemChanged: (index) {
              setState(() {
                this.tempiOSSelectedIndex = index;
                this.tempiOSSelectedIndex =
                    int.tryParse(kidsNumberList[index]) ?? 0;
              });
            },
          ),
        )
      ],
    );
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
      backgroundColor: Colors.white,
      appBar: EditProfileDetailsAppBar(context: context, text: "Edit Kids Info")
          .getAppBar1(isChangedValues()),
      body: PlatformScaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SizedBox(
            height: scHeight,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      "Number of Kids",
                      style: TextStyle(
                          fontSize: AppConfig.heightWithDForSmallDevice(
                              context, 28, 8),
                          fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height:
                          AppConfig.heightWithDForSmallDevice(context, 20, 10),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 70.0),
                      child: PlatformWidget(
                        material: (_, __) => Center(
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
                                value: numberOfKids,
                                items: kidsNumberList.map((String value) {
                                  return new DropdownMenuItem<String>(
                                    value: value,
                                    child: new Text(
                                      value,
                                      style: TextStyle(
                                        color: AppColors.blueColor,
                                        fontWeight: FontWeight.w500,
                                        fontSize:
                                            (AppConfig.fullHeight(context) >=
                                                    667)
                                                ? 18
                                                : 14,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (String kidsValue) {
                                  setState(() {
                                    this.numberOfKids = kidsValue;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                        cupertino: (_, __) => Center(
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
                                    Expanded(child: selectedKidiOSValue),
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
                                      return _buildiOSNoOfKidBottomPicker();
                                    }),
                              )),
                        ),
                      ),
                    ),
                    SizedBox(
                      height:
                          AppConfig.heightWithDForSmallDevice(context, 30, 15),
                    ),
                    Text(
                      "I currently have:",
                      style: TextStyle(
                          fontSize: AppConfig.heightWithDForSmallDevice(
                              context, 28, 8),
                          fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              children: <Widget>[
                                SizedBox(
                                  height: 10,
                                ),
                                MyButtons.getBorderedButton(
                                    currentKids[0], AppColors.blueColor, () {
                                  setState(() {
                                    this.selectedPresentKid = 0;
                                  });
                                }, this.selectedPresentKid == 0,
                                    verticalPadding: 17.0,
                                    fontSize: 12,
                                    unselectedButtonFontWt: FontWeight.w500),
                                SizedBox(
                                  height: 10,
                                ),
                                MyButtons.getBorderedButton(
                                    currentKids[1], AppColors.blueColor, () {
                                  setState(() {
                                    this.selectedPresentKid = 1;
                                  });
                                }, this.selectedPresentKid == 1,
                                    verticalPadding: 8.0,
                                    fontSize: 12,
                                    unselectedButtonFontWt: FontWeight.w500),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Expanded(
                            child: Column(
                              children: <Widget>[
                                SizedBox(
                                  height: 10,
                                ),
                                MyButtons.getBorderedButton(
                                    currentKids[2], AppColors.blueColor, () {
                                  setState(() {
                                    this.selectedPresentKid = 2;
                                  });
                                }, this.selectedPresentKid == 2,
                                    verticalPadding: 17,
                                    fontSize: 12,
                                    unselectedButtonFontWt: FontWeight.w500),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Text(
                      "In the future",
                      style: TextStyle(
                          fontSize: AppConfig.heightWithDForSmallDevice(
                              context, 28, 8),
                          fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              children: <Widget>[
                                SizedBox(
                                  height: 10,
                                ),
                                MyButtons.getBorderedButton(
                                    futureKids[0], AppColors.blueColor, () {
                                  setState(() {
                                    this.selectedFutureKid = 0;
                                  });
                                }, this.selectedFutureKid == 0,
                                    verticalPadding: 17,
                                    fontSize: 12,
                                    unselectedButtonFontWt: FontWeight.w500),
                                SizedBox(
                                  height: 10,
                                ),
                                MyButtons.getBorderedButton(
                                    futureKids[1], AppColors.blueColor, () {
                                  setState(() {
                                    this.selectedFutureKid = 1;
                                  });
                                }, this.selectedFutureKid == 1,
                                    verticalPadding: 17,
                                    fontSize: 12,
                                    unselectedButtonFontWt: FontWeight.w500),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Expanded(
                            child: Column(
                              children: <Widget>[
                                SizedBox(
                                  height: 10,
                                ),
                                MyButtons.getBorderedButton(
                                    futureKids[2], AppColors.blueColor, () {
                                  setState(() {
                                    this.selectedFutureKid = 2;
                                  });
                                }, this.selectedFutureKid == 2,
                                    verticalPadding: 17,
                                    fontSize: 12,
                                    unselectedButtonFontWt: FontWeight.w500),
                              ],
                            ),
                          ),
                        ],
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
                    Center(
                      child: SizedBox(
                        height: 60,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 30),
                          child: PlatformButton(
                              onPressed: (this.selectedFutureKid != -1 &&
                                      this.selectedPresentKid != -1)
                                  ? () {
                                      this._setKids();
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
                                      context, 20, 4),
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
