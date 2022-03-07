import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:pure_match/models/user.dart';
import 'package:pure_match/pages/AppColors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:collection/collection.dart';

class Global {
  static String createdAt(String value) {
    var df = DateTime.parse(value ?? "2010-09-11");
    String time = "NA";
    var nowDT = DateTime.now();
    Duration timeDiff = nowDT.difference(df);
    // print("Time diff in hours ${timeDiff.inSeconds}");
    if (timeDiff.inSeconds == 0) {
      time = "Just now";
    } else if (timeDiff.inSeconds >= 0 && timeDiff.inSeconds <= 60) {
      time = "${timeDiff.inSeconds} secs ago";
    } else if (timeDiff.inMinutes >= 1 && timeDiff.inMinutes <= 60) {
      time = "${timeDiff.inMinutes} mins ago";
    } else if (timeDiff.inHours >= 1 && timeDiff.inHours <= 24) {
      time = "${timeDiff.inHours} hours ago";
    } else if (timeDiff.inDays >= 1 && timeDiff.inDays <= 28) {
      time = "${timeDiff.inDays} days ago";
      if (timeDiff.inDays == 1) time = "Yesterday";
    } else {
      time = "${timeDiff.inDays ~/ 28} months ago";
    }
    return time;
  }

  static bool isChangedListValues(List list1, List list2) {
    var isChanged = false;
    Function unOrdDeepEq = const DeepCollectionEquality.unordered().equals;
    if (list1.length > 0) {
      if (unOrdDeepEq(list1, list2)) {
      } else {
        isChanged = true;
      }
    }
    return isChanged;
  }

  static String getFullName(String firstName, String lastName) {
    return (firstName.length > 0 && lastName.length > 0)
        ? firstName + " " + lastName
        : (firstName.length > 0)
            ? firstName
            : (lastName.length > 0)
                ? lastName
                : "User";
  }

  static String getFName(String firstName) {
    return (firstName.length > 0) ? firstName : "User";
  }

  static Future<int> getOnboardingId() async {
    var sp = await SharedPreferences.getInstance();
    int onboardingid = sp.getInt("onboarding") ?? -1;
    return onboardingid;
  }

  static Future<void> setOnboardingId(int onboardingId) async {
    var sp = await SharedPreferences.getInstance();
    bool isSuccess = await sp.setInt("onboarding", onboardingId);
    print("settup = $isSuccess, $onboardingId");
  }

  static Future<void> removeOnboardingId() async {
    var sp = await SharedPreferences.getInstance();
    onboardingId = -1;
    sp.remove("onboarding");
  }

  static double getNumber(double input, {int precision = 2}) => double.parse(
      '$input'.substring(0, '$input'.indexOf('.') + precision + 1));

  static Widget FlatButtonX(
      {Color colorx,
      @required Widget childx,
      RoundedRectangleBorder shapex,
      @required Function onPressedx,
      Key keyx,
      Color disabledColorx,
      Color disabledTextColorx,
      Color textColorx,
      double paddingX,
      double paddingY}) {
    if (disabledTextColorx == null && textColorx == null) {
      disabledTextColorx = colorx;
    }
    if (textColorx == null) {
      textColorx = colorx;
    }
    return TextButton(
        key: keyx,
        style: ButtonStyle(
          foregroundColor: MaterialStateProperty.resolveWith<Color>(
            // text color
            (Set<MaterialState> states) =>
                states.contains(MaterialState.disabled)
                    ? disabledTextColorx
                    : textColorx,
          ),
          backgroundColor: MaterialStateProperty.resolveWith<Color>(
            // background color    this is color:
            (Set<MaterialState> states) =>
                states.contains(MaterialState.disabled)
                    ? disabledColorx
                    : colorx,
          ),
          shape: MaterialStateProperty.all(shapex),
        ),
        onPressed: onPressedx as void Function(),
        child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: (paddingX != null && paddingX > 0) ? paddingX : 8,
                vertical: (paddingY != null && paddingY > 0) ? paddingY : 0),
            child: childx));
  }

  static void alertUser(
      BuildContext context,
      Text alertTitle,
      Text alertContent,
      Text txtBtnCancel,
      Function onBtnCancel,
      Text txtBtnOk,
      Function onBtnOk) {
    showDialog(
      context: context,
      builder: (_) => PlatformAlertDialog(
        title: alertTitle,
        content: alertContent,
        material: (_, __) => MaterialAlertDialogData(
          elevation: 1.0,
          actions: <Widget>[
            TextButton(
              child: txtBtnCancel,
              onPressed: onBtnCancel,
            ),
            TextButton(
              child: txtBtnOk,
              onPressed: onBtnOk,
            )
          ],
        ),
        cupertino: (_, __) => CupertinoAlertDialogData(actions: <Widget>[
          CupertinoButton(
            child: txtBtnCancel,
            onPressed: onBtnCancel,
          ),
          CupertinoButton(
            child: txtBtnOk,
            onPressed: onBtnOk,
          )
        ]),
      ),
      barrierDismissible: false,
    );
  }

  static Center premiumText(
      BuildContext context, String text, Color color, double fontSize) {
    return Center(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
            fontWeight: FontWeight.w600, fontSize: fontSize, color: color),
      ),
    );
  }

  static Column premiumTexts(
      BuildContext context, Color color, double fontSize) {
    return Column(
      children: <Widget>[
        Global.premiumText(
          context,
          "⭐️ Browse unlimited Matches ⭐️",
          color,
          fontSize,
        ),
        Global.premiumText(
          context,
          "⭐️ Unlimited/advanced Match filters ⭐️",
          color,
          fontSize,
        ),
        Global.premiumText(
          context,
          "⭐️ Up to 8 profile pictures ⭐️",
          color,
          fontSize,
        ),
        Global.premiumText(
          context,
          "⭐️ Incognito mode unlocked ⭐️",
          color,
          fontSize,
        ),
        Global.premiumText(
          context,
          "⭐️ See everyone who has liked you ⭐️",
          color,
          fontSize,
        ),
        Global.premiumText(
          context,
          "⭐️ See who has viewed your profile ⭐️",
          color,
          fontSize,
        ),
      ],
    );
  }

  static void alertUserForCardAction(
      BuildContext context,
      String alertTitle,
      String alertContent,
      String txtBtn1,
      Function onTap1,
      String txtBtn2,
      Function onTap2,
      String txtBtn3,
      Function onTap3) {
    showDialog(
        context: context,
        builder: (_) => PlatformAlertDialog(
              title: Text(alertTitle),
              content: Text(alertContent,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w400, height: 1.5)),
              material: (_, __) => MaterialAlertDialogData(
                elevation: 1.0,
                actions: <Widget>[
                  TextButton(
                    child: Text(txtBtn1,
                        style: TextStyle(
                            color: AppColors.redColor,
                            fontWeight: FontWeight.w600)),
                    onPressed: onTap1,
                  ),
                  Visibility(
                    visible: txtBtn2.length > 0,
                    child: TextButton(
                      child:
                          Text(txtBtn2, style: TextStyle(color: Colors.black)),
                      onPressed: onTap2,
                    ),
                  ),
                  Visibility(
                    visible: txtBtn3.length > 0,
                    child: TextButton(
                      child: Text(txtBtn3,
                          style: TextStyle(color: AppColors.blueColor)),
                      onPressed: onTap3,
                    ),
                  )
                ],
              ),
              cupertino: (_, __) => CupertinoAlertDialogData(actions: <Widget>[
                CupertinoDialogAction(
                  child: Text(txtBtn1,
                      style: TextStyle(
                          color: AppColors.redColor,
                          fontWeight: FontWeight.w600)),
                  onPressed: onTap1,
                ),
                Visibility(
                  visible: txtBtn2.length > 0,
                  child: CupertinoDialogAction(
                    child: Text(txtBtn2, style: TextStyle(color: Colors.black)),
                    onPressed: onTap2,
                  ),
                ),
                Visibility(
                  visible: txtBtn3.length > 0,
                  child: CupertinoDialogAction(
                    isDefaultAction: true,
                    child: Text(txtBtn3,
                        style: TextStyle(color: AppColors.blueColor)),
                    onPressed: onTap3,
                  ),
                ),
              ]),
            ),
        barrierDismissible: true);
  }

  static InkWell getHamburgerMenuBar(Function onTap, int unReadCount) {
    return InkWell(
      splashColor: Colors.lightBlue,
      onTap: onTap,
      child: Center(
        child: Container(
          margin: EdgeInsets.only(left: 10),
          width: 40,
          height: 25,
          child: Stack(
            children: [
              Icon(
                Icons.menu,
                color: Colors.white,
              ),
              Visibility(
                visible: (unReadCount > 0),
                child: Positioned(
                  left: 25,
                  top: 0,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red,
                        ),
                        width: 10,
                        height: 10,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  static int calculateAge(DateTime birthDate) {
    DateTime currentDate = DateTime.now();
    int age = currentDate.year - birthDate.year;
    int month1 = currentDate.month;
    int month2 = birthDate.month;
    if (month2 > month1) {
      age--;
    } else if (month1 == month2) {
      int day1 = currentDate.day;
      int day2 = birthDate.day;
      if (day2 > day1) {
        age--;
      }
    }
    return age;
  }

  static bool ownProfileSaved = false;
  static int unreadFriendRequestCount = 0;
  static int unreadFeedNotificationCount = 0;
  static int unreadChatsCount = 0;
  static String gender = "man";
  static bool matching_active = true;
  static bool isPremium = false;
  static int onboardingId = -1;
  static bool hasProfileImg = true;
  static final whitespaces = RegExp(r'\s+', multiLine: true);
  static User currentUser;
  static int match_count1 = 0;
  static int match_count_daily = 10;
}

class HeightConfig {
  static String heightFoot(String heightCM) {
    String heightFoot = "4'5";
    switch (heightCM) {
      case ("135"):
        heightFoot = "4'5";
        break;
      case ("137"):
        heightFoot = "4'6";
        break;
      case ("140"):
        heightFoot = "4'7";
        break;
      case ("142"):
        heightFoot = "4'8";
        break;
      case ("145"):
        heightFoot = "4'9";
        break;
      case ("147"):
        heightFoot = "4'10";
        break;
      case ("150"):
        heightFoot = "4'11";
        break;
      case ("152"):
        heightFoot = "5'0";
        break;
      case ("155"):
        heightFoot = "5'1";
        break;
      case ("158"):
        heightFoot = "5'2";
        break;
      case ("160"):
        heightFoot = "5'3";
        break;
      case ("163"):
        heightFoot = "5'4";
        break;
      case ("165"):
        heightFoot = "5'5";
        break;
      case ("168"):
        heightFoot = "5'6";
        break;
      case ("170"):
        heightFoot = "5'7";
        break;
      case ("173"):
        heightFoot = "5'8";
        break;
      case ("175"):
        heightFoot = "5'9";
        break;
      case ("178"):
        heightFoot = "5'10";
        break;
      case ("180"):
        heightFoot = "5'11";
        break;
      case ("183"):
        heightFoot = "6'0";
        break;
      case ("185"):
        heightFoot = "6'1";
        break;
      case ("188"):
        heightFoot = "6'2";
        break;
      case ("191"):
        heightFoot = "6'3";
        break;
      case ("193"):
        heightFoot = "6'4";
        break;
      case ("196"):
        heightFoot = "6'5";
        break;
      case ("198"):
        heightFoot = "6'6";
        break;
      case ("201"):
        heightFoot = "6'7";
        break;
      case ("203"):
        heightFoot = "6'8";
        break;
      default:
        heightFoot = "4'5";
        break;
    }
    return heightFoot;
  }
}

class AppConfig {
  static double size(BuildContext context, double s) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    if (height / width > 812 / 375) {
      return MediaQuery.of(context).size.width / 812 * s;
    } else {
      return MediaQuery.of(context).size.height / 375 * s;
    }
  }

  static double fullWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double fullHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static double fontsizeForSmallDevice(BuildContext context, int size) {
    double height = MediaQuery.of(context).size.height;
    if (height >= 667) {
    } else {
      size = size - 4;
    }
    return size.toDouble();
  }

  static double heightForSmallDevice(BuildContext context, int size) {
    double height = MediaQuery.of(context).size.height;
    if (height >= 667) {
    } else {
      size = size - 10;
    }
    return size.toDouble();
  }

  static double heightWithDForSmallDevice(
      BuildContext context, int size, int d) {
    double width = MediaQuery.of(context).size.width;
    if (width >= 375) {
    } else {
      size = size - d;
    }
    return size.toDouble();
  }
}
