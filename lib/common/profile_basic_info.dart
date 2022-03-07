import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:intl/intl.dart';
import 'package:pure_match/common/global.dart';
import 'package:pure_match/models/mutual_friends.dart';
import 'package:pure_match/models/user.dart';
import 'package:pure_match/pages/AppColors.dart';
import 'package:pure_match/pages/onboarding/basic_info/editheight.dart';
import 'package:pure_match/pages/own_profile/edit_church.dart';
import 'package:pure_match/pages/own_profile/edit_education.dart';
import 'package:pure_match/pages/own_profile/edit_employment.dart';
import 'package:pure_match/pages/own_profile/edit_kids.dart';
import 'package:pure_match/pages/own_profile/edit_location.dart';
import 'package:pure_match/pages/own_profile/edit_spiritual_birthday.dart';
import 'package:pure_match/pages/profile/edit_birthday.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:amplitude_flutter/amplitude.dart';

class ProfileBasicInfo extends StatefulWidget {
  User user;
  bool isEditable;
  Function onUpdateProfile;
  bool isOnboarding;
  ProfileBasicInfo(
      {User user,
      bool isEditable,
      Function onUpdateProfile,
      bool isOnboarding}) {
    this.user = user;
    this.isEditable = isEditable;
    this.onUpdateProfile = onUpdateProfile;
    this.isOnboarding = isOnboarding;
  }

  @override
  _ProfileBasicInfoState createState() => _ProfileBasicInfoState();
}

class _ProfileBasicInfoState extends State<ProfileBasicInfo> {
  User user;
  bool isEditable;
  String height;
  String spiritualDate;
  String spiritualDateDiff = "";

  // Analytics code
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';

  @override
  void initState() {
    user = widget.user;
    isEditable = widget.isEditable;
    try {
      _dateConversion(user.my_spiritual_birthday ?? "");
      // _conversion(user.height);
      height = HeightConfig.heightFoot(user.height ?? "");
    } catch (e) {
      print("Error in profile basic info $e");
    }

    super.initState();

    //Initializing amplitude analytics api key
    amplitudeAnalytics.init(apiKey);
  }

  // void _conversion(String userheight) {
  //   int centi = int.parse(userheight);
  //   double length = centi / 2.54;
  //   int feet = (length / 12).floor();
  //   double inch = length - 12 * feet;
  //   height = feet.toString() + "'" + inch.floor().toString();
  //
  //   // double inch = 0.3937 * centi;
  //   // double feet = 0.0328 * centi;
  //   // height = feet.toString()+"`"+inch.toString();
  // }

  void _dateConversion(String date) {
    DateTime formateddate = DateTime.parse(date);
    spiritualDate = DateFormat('MM/dd/yy').format(formateddate);
    int daysDiff = DateTime.now().difference(formateddate).inDays;
    int years = (daysDiff / 365).floor();
    if (years > 0) spiritualDateDiff += "$years yrs ";
    daysDiff -= years * 365;
    int months = (daysDiff / 30).floor();
    if (months > 0) spiritualDateDiff += "$months m";
    setState(() {});
  }

  Future<void> openDialog(List<MutualFriends> mutuals) async {
    List<Widget> likeDialogContent = [];
    print(mutuals);
    for (var u in mutuals) {
      print(u.first_name + " " + u.last_name);
      likeDialogContent.add(this._getLikeOption(u));
    }

    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            titlePadding: EdgeInsets.all(0),
            contentPadding: EdgeInsets.all(0),
            title: Container(
                width: double.infinity,
                color: AppColors.yellowColor,
                padding: EdgeInsets.all(4),
                child: Row(
                  children: [
                    Text(
                      "Mutual Friends",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    Spacer(),
                    IconButton(
                      icon: Icon(Icons.close),
                      color: Colors.white,
                      iconSize: 20,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    )
                  ],
                )),
            children: <Widget>[
              Container(
                height: 250,
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: SingleChildScrollView(
                        child: ListBody(
                          children: likeDialogContent,
                        ),
                      ),
                    ),
                    Container(
                      color: AppColors.yellowColor,
                      height: 6,
                      width: double.infinity,
                    )
                  ],
                ),
              )
            ],
          );
        });
  }

  InkWell _getLikeOption(MutualFriends u) {
    return InkWell(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            ClipRRect(
                borderRadius: BorderRadius.circular(100.0),
                child: CachedNetworkImage(
                  width: 35,
                  imageUrl: u?.imageUrl ??
                      "https://i.pinimg.com/564x/19/b8/d6/19b8d6e9b13eef23ec9c746968bb88b1.jpg",
                  errorWidget: (context, url, error) => Icon(Icons.error),
                )),
            SizedBox(
              width: 8,
            ),
            Expanded(
                child: Text(
              u?.first_name ?? "Preet",
              style: TextStyle(fontWeight: FontWeight.bold),
            ))
          ],
        ),
      ),
    );
  }

  Container _getInfoLine(String text, Widget icon, Widget editWidget) {
    return Container(
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.greyColor))),
      padding: const EdgeInsetsDirectional.only(
          start: 10.0, top: 10.0, bottom: 10.0, end: 5.0),
      child: Row(
        children: <Widget>[
          icon,
          SizedBox(
            width: 10,
          ),
          Expanded(
            child: Text(text,
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                overflow: TextOverflow.ellipsis),
          ),
          Visibility(
            visible: isEditable,
            child: PlatformIconButton(
              icon: Image.asset(
                "assets/images/edit_icon.png",
                width: 24,
                color: AppColors.blackColor,
              ),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => editWidget));
                /* .then((value) {
                  refreshEditedValue(value);
                }); */
              },
            ),
          ),
        ],
      ),
    );
  }

  Container _getInfoLineWithInfo(String text, Widget icon, String text2) {
    return Container(
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.greyColor))),
      padding: const EdgeInsetsDirectional.only(
          start: 10.0, top: 10.0, bottom: 10.0, end: 15.0),
      child: Row(
        children: <Widget>[
          icon,
          SizedBox(
            width: 10,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(text,
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                    overflow: TextOverflow.ellipsis),
                InkWell(
                    onTap: () {
                      openDialog(user.mutualFriends);
                    },
                    child: Text(
                      "Show Friends",
                      style:
                          TextStyle(color: AppColors.blueColor, fontSize: 11),
                    ))
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double bWidth = AppConfig.heightWithDForSmallDevice(context, 10, 5);
    if (widget.isEditable == true) {
      bWidth = AppConfig.heightWithDForSmallDevice(context, 6, 1);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsetsDirectional.only(
              start: 10.0, top: 5.0, bottom: 5.0, end: 10.0),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 5),
            decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.greyColor))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    if (isEditable) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => EditBirthDate(
                                  user: widget.user,
                                  isFromOnboarding:
                                      (widget.isOnboarding != null &&
                                              widget.isOnboarding)
                                          ? true
                                          : false,
                                  onUpdateProfile: widget.onUpdateProfile)));
                      //Analytics tracking code
                      analytics.setCurrentScreen(
                          screenName: "edit_birthday",
                          screenClassOverride: "edit_birthday");
                      amplitudeAnalytics.logEvent('edit_birthday_page');
                    }
                  },
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.access_time,
                        color: AppColors.blackColor,
                      ),
                      Text(
                          (user.age != null ? user.age.toString() : '') +
                              " y/o",
                          style: TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 16)),
                    ],
                  ),
                ),

                GestureDetector(
                  onTap: () {
                    if (isEditable) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => EditHeight(
                                    height: widget.user.height ?? '1',
                                    isFromOnboarding:
                                        (widget.isOnboarding != null &&
                                                widget.isOnboarding)
                                            ? true
                                            : false,
                                    onSaveheight: widget.onUpdateProfile,
                                  )));
                    }
                  },
                  child: Row(
                    children: <Widget>[
                      Image.asset(
                        "assets/images/ruler_icon_black.png",
                      ),
                      Text(height ?? '',
                          style: TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 16))
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    if (isEditable) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => EditKids(
                                  haveKids: user.kids_have,
                                  wantKids: user.kids_want,
                                  noOfKids: user.no_of_kids,
                                  isFromOnboarding:
                                      (widget.isOnboarding != null &&
                                              widget.isOnboarding)
                                          ? true
                                          : false,
                                  onUpdateProfile: widget.onUpdateProfile)));
                    }
                  },
                  child: Row(
                    children: <Widget>[
                      Image.asset(
                        "assets/images/kid_icon.png",
                      ),
                      (user.kids_have == null)
                          ? Text("None",
                              style: TextStyle(
                                  fontWeight: FontWeight.w500, fontSize: 16))
                          : (user.kids_have == "No kids"
                              ? Text("None",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16))
                              : Text(user.kids_have,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16))),
                    ],
                  ),
                ),

                // Text(this.kidsHave),
              ],
            ),
          ),
        ),
        Visibility(
          visible:
              user.mutualFriends.length != 0 && user.mutualFriends.isNotEmpty,
          child: _getInfoLineWithInfo(
              user.mutualFriends.length.toString() + " Mutual Friends",
              Icon(Icons.group, color: AppColors.blackColor),
              "Show Friends"),
        ),

        Visibility(
          visible: user.location != null && user.location.isNotEmpty,
          child: _getInfoLine(
              user.location,
              Icon(Icons.place, color: AppColors.blackColor),
              EditLocation(
                  user.location,
                  (widget.isOnboarding != null && widget.isOnboarding)
                      ? true
                      : false,
                  widget.onUpdateProfile)),
        ),
        Visibility(
          visible: user.church != null && user.church.isNotEmpty,
          child: _getInfoLine(
              user.church,
              Image.asset("assets/images/church_icon.png"),
              EditChurch(
                  user.organization_name,
                  user.church,
                  user.restrict_matches_to_organization,
                  (widget.isOnboarding != null && widget.isOnboarding)
                      ? true
                      : false,
                  widget.onUpdateProfile)),
        ),
        Visibility(
          visible: (user.my_spiritual_birthday != null &&
              user.my_spiritual_birthday.isNotEmpty),
          child: _getInfoLine(
              "Baptized: " +
                  "${spiritualDate ?? ""} (${spiritualDateDiff?.trim()})",
              Image.asset("assets/images/cross_icon.png"),
              // EditEducation(user.school_name, user.education)
              EditSpiritualBirthday(
                  user.my_spiritual_birthday,
                  (widget.isOnboarding != null && widget.isOnboarding)
                      ? true
                      : false,
                  widget.onUpdateProfile)),
        ),
        // TODO: implement Spiritual Birthday - in years and months
        Visibility(
          visible: (user.school_name != null && user.school_name.isNotEmpty) ||
              (user.education != null && user.education.isNotEmpty),
          child: _getInfoLine(
              user.school_name != null
                  ? user.school_name
                  : user.education != null
                      ? user.education
                      : "Enter Education",
              Image.asset("assets/images/book_icon.png"),
              EditEducation(
                  user.school_name,
                  user.education,
                  (widget.isOnboarding != null && widget.isOnboarding)
                      ? true
                      : false,
                  widget.onUpdateProfile)),
        ),
        Visibility(
            visible: user.employer != null &&
                user.employer.isNotEmpty &&
                user.position != null &&
                user.position.isNotEmpty,
            child: user.self_employed != null && user.self_employed
                ? _getInfoLine(
                    "Self Employed, " + user.position ??
                        "" + " at " + user.employer ??
                        "",
                    Image.asset("assets/images/bag_icon.png"),
                    EditEmployment(
                        company: user.employer,
                        position: user.position,
                        isSelfEmployed: user.self_employed,
                        isFromOnboarding:
                            (widget.isOnboarding != null && widget.isOnboarding)
                                ? true
                                : false,
                        onUpdateProfile: widget.onUpdateProfile))
                : _getInfoLine(
                    user.position ?? "" + " at " + user.employer ?? "",
                    Image.asset("assets/images/bag_icon.png"),
                    EditEmployment(
                        company: user.employer,
                        position: user.position,
                        isSelfEmployed: user.self_employed,
                        isFromOnboarding:
                            (widget.isOnboarding != null && widget.isOnboarding)
                                ? true
                                : false,
                        onUpdateProfile: widget.onUpdateProfile))),
      ],
    );
  }
}
