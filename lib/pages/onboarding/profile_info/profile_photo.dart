import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:amplitude_flutter/amplitude.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pure_match/common/RoundIndicators.dart';
import 'package:pure_match/common/global.dart';
import 'package:pure_match/pages/AppColors.dart';
import 'package:pure_match/pages/MyUrl.dart';
import 'package:pure_match/pages/onboarding/profile_info/about_yourself.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';
import '../../MyHttp.dart';

class ProfilePhoto extends StatefulWidget {
  @override
  _ProfilePhotoState createState() => _ProfilePhotoState();
}

class _ProfilePhotoState extends State<ProfilePhoto> {
  // Analytics code
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';

  double bigHeight = 0.3;
  double bigWidth = 0.3;

  double smallHeight = 0.15;
  double smallWidth = 0.2;
  List<File> imageFiles = [null, null, null, null, null];
  bool loading = false;
  void _postImageToServer() async {
    setState(() {
      loading = true;
    });
    var sp = await SharedPreferences.getInstance();
    String token = sp.getString("token");

    for (int i = 0; i < imageFiles.length; i++) {
      var request =
          new http.MultipartRequest("POST", Uri.parse(MyUrl.url("/uploads")));
      request.headers["authorization"] = "Bearer $token";
      var img = imageFiles[i];
      if (img == null) continue;
      request.fields['tag'] = i.toString();
      var f = http.MultipartFile(
          'file', img.readAsBytes().asStream(), img.lengthSync(),
          filename: img.path, contentType: MediaType('image', 'jpg'));

      request.files.add(f);
      try {
        var res = await request.send();
        if (res.statusCode == 200) {
          //Analytics code
          analytics.logEvent(
              name: "saved_profile_picture",
              parameters: <String, dynamic>{
                'profile_picture': "profile_picture"
              });
          amplitudeAnalytics.logEvent("saved_profile_picture",
              eventProperties: {'profile_picture': "profile_picture"});

          print("Uploaded");
          if (i == 0) {
            var response = await http.Response.fromStream(res);
            if (response != null) {
              var body = json.decode(response.body);
              var newUpload = body["newUpload"];
              setUserProfilePicture(newUpload['path'] as String);
            }
          }
        } else {
          print("Error ${res.statusCode}");
        }
      } catch (e) {
        print(e.toString());
      }
    }

//    request.send().then((response) {
//      if (response.statusCode == 200) print("Uploaded!");
//      else{
//        print(response.statusCode);
//      }
//    }).catchError((e){
//      print(e);
//    });

    setState(() {
      loading = false;
    });

    Navigator.push(
        context, MaterialPageRoute(builder: (context) => AboutYourself()));

    // Analytics tracking code
    analytics.setCurrentScreen(
        screenName: "onboarding_about_yourself",
        screenClassOverride: "onboarding_about_yourself");
    amplitudeAnalytics.logEvent("onboarding_about_yourself_page");
  }

  Future<void> setUserProfilePicture(String path) async {
    var res = await MyHttp.put("users/update", {"ProfilePictureId": path});
    if (res.statusCode == 200) {
      print("User updated");
      print(res.body);
    } else {
      print("User update error: ${res.statusCode}");
      print("User update error: ${res.body}");
    }
  }

  void _getImage(int imageNum) async {
    var image = await ImagePicker().getImage(
        source: ImageSource.gallery,
        imageQuality: 90,
        maxHeight: 500,
        maxWidth: 500);
    File croppedFile;
    if (imageNum == 0) {
      croppedFile = await ImageCropper.cropImage(
          sourcePath: image.path,
          aspectRatio: CropAspectRatio(ratioX: 1.0, ratioY: 1.0),
          androidUiSettings: AndroidUiSettings(
              toolbarTitle: 'Cropper',
              toolbarColor: AppColors.blueColor,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.square,
              lockAspectRatio: true),
          iosUiSettings: IOSUiSettings(
            minimumAspectRatio: 1.0,
          ));
    } else {
      croppedFile = await ImageCropper.cropImage(
          sourcePath: image.path,
          // aspectRatio: CropAspectRatio(ratioX: 1.0, ratioY: 1.0),
          aspectRatioPresets: [
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.original,
          ],
          androidUiSettings: AndroidUiSettings(
              toolbarTitle: 'Cropper',
              toolbarColor: AppColors.blueColor,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false),
          iosUiSettings: IOSUiSettings(
            aspectRatioLockDimensionSwapEnabled: false,
            aspectRatioLockEnabled: false,
          ));
    }

    if (croppedFile == null) return;
    setState(() {
      imageFiles[imageNum] = croppedFile;
    });
  }

  @override
  void initState() {
    //Initializing amplitude analytics api key
    amplitudeAnalytics.init(apiKey);
    Global.setOnboardingId(21);
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      appBar: PlatformAppBar(
        material: (_, __) => MaterialAppBarData(
          backgroundColor: Colors.white,
          elevation: 0.0,
          leading: IconButton(
            padding: EdgeInsetsDirectional.only(start: 10.0),
            icon: Icon(
              Icons.arrow_back,
              color: AppColors.offWhiteColor,
              size: 25,
            ),
            iconSize: 30,
            onPressed: () {
              Navigator.pop(context);
              // Analytics tracking code
              analytics.setCurrentScreen(
                  screenName: 'basic_info_done',
                  screenClassOverride: 'basic_info_done');
              amplitudeAnalytics.logEvent("basic_info_done_page");
            },
          ),
        ),
        cupertino: (_, __) => CupertinoNavigationBarData(
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
                  // Analytics tracking code
                  analytics.setCurrentScreen(
                      screenName: 'basic_info_done',
                      screenClassOverride: 'basic_info_done');
                  amplitudeAnalytics.logEvent("basic_info_done_page");
                })),
      ),
      body: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    height: ScreenUtil().setHeight(10),
                  ),
                  RoundIndicators(
                    currentIndicatorIndex: 0,
                    numberOfInidcators: 5,
                    circleSize: 12,
                  ),
                  SizedBox(
                    height: ScreenUtil().setHeight(
                        AppConfig.heightWithDForSmallDevice(context, 50, 15)),
                  ),
                  Text(
                    "Add Profile Pictures",
                    style: TextStyle(
                        fontSize: AppConfig.fontsizeForSmallDevice(context, 36),
                        fontWeight: FontWeight.w600,
                        color: AppColors.blackColor),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: ScreenUtil().setHeight(10),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    child: Text(
                      "Upgrade to Premium for 5 more photos",
                      style: TextStyle(
                          fontSize:
                              AppConfig.fontsizeForSmallDevice(context, 15),
                          color: AppColors.offWhiteColor,
                          fontWeight: FontWeight.w500,
                          fontStyle: FontStyle.italic),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                    ),
                  ),
                  /* Row(
                    children: <Widget>[
                      SizedBox(
                        width: 5,
                      ),
                      Expanded(
                        child: Image.asset("assets/images/upgrade_coin.png")
                      )
                    ],
                  ), */
                  SizedBox(
                    height: ScreenUtil().setHeight(
                        AppConfig.heightWithDForSmallDevice(context, 20, 5)),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        height: AppConfig.heightWithDForSmallDevice(
                            context, 240, 80),
                        width: AppConfig.heightWithDForSmallDevice(
                            context, 240, 80),
                        child: (imageFiles[0] == null)
                            ? FlatButton(
                                onPressed: () => _getImage(0),
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(color: AppColors.blueColor),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Image.asset(
                                    "assets/images/plus_circle.png"))
                            : InkWell(
                                onTap: () => _getImage(0),
                                child: Stack(
                                  children: <Widget>[
                                    Container(
                                      decoration: BoxDecoration(
                                          color: AppColors.blackColor,
                                          border: Border.all(
                                            color: AppColors.blackColor,
                                          ),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10))),
                                    ),
                                    Center(
                                        child: Image.file(imageFiles[0],
                                            fit: BoxFit.contain))
                                  ],
                                ),
                              ),
                      ),
                      SizedBox(
                        height: ScreenUtil().setHeight(10),
                      ),
                      Container(
                        height: AppConfig.heightWithDForSmallDevice(
                            context, 130, 40),
                        child: Scrollbar(
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: <Widget>[
                              Container(
                                height: AppConfig.heightWithDForSmallDevice(
                                    context, 120, 40),
                                width: AppConfig.heightWithDForSmallDevice(
                                    context, 120, 40),
                                child: (imageFiles[1] == null)
                                    ? FlatButton(
                                        onPressed: () => _getImage(1),
                                        shape: RoundedRectangleBorder(
                                          side: BorderSide(
                                              color: AppColors.blueColor),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Image.asset(
                                            "assets/images/plus_circle.png"))
                                    : InkWell(
                                        onTap: () => _getImage(1),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          child: Stack(
                                            children: <Widget>[
                                              Container(
                                                decoration: BoxDecoration(
                                                    color: AppColors.blackColor,
                                                    border: Border.all(
                                                      color:
                                                          AppColors.blackColor,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                10))),
                                              ),
                                              Center(
                                                  child: Image.file(
                                                      imageFiles[1],
                                                      fit: BoxFit.contain))
                                            ],
                                          ),
                                        )),
                              ),
                              SizedBox(
                                width: ScreenUtil().setHeight(5),
                              ),
                              Container(
                                height: AppConfig.heightWithDForSmallDevice(
                                    context, 120, 40),
                                width: AppConfig.heightWithDForSmallDevice(
                                    context, 120, 40),
                                child: (imageFiles[2] == null)
                                    ? FlatButton(
                                        onPressed: () => _getImage(2),
                                        shape: RoundedRectangleBorder(
                                          side: BorderSide(
                                              color: AppColors.blueColor),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Image.asset(
                                            "assets/images/plus_circle.png"))
                                    : InkWell(
                                        onTap: () => _getImage(2),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          child: Stack(
                                            children: <Widget>[
                                              Container(
                                                decoration: BoxDecoration(
                                                    color: AppColors.blackColor,
                                                    border: Border.all(
                                                      color:
                                                          AppColors.blackColor,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                10))),
                                              ),
                                              Center(
                                                  child: Image.file(
                                                      imageFiles[2],
                                                      fit: BoxFit.contain))
                                            ],
                                          ),
                                        )),
                              ),
                              SizedBox(
                                width: ScreenUtil().setHeight(5),
                              ),
                              Container(
                                height: AppConfig.heightWithDForSmallDevice(
                                    context, 120, 40),
                                width: AppConfig.heightWithDForSmallDevice(
                                    context, 120, 40),
                                child: (imageFiles[3] == null)
                                    ? FlatButton(
                                        onPressed: () => _getImage(3),
                                        shape: RoundedRectangleBorder(
                                          side: BorderSide(
                                              color: AppColors.blueColor),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Image.asset(
                                            "assets/images/plus_circle.png"))
                                    : InkWell(
                                        onTap: () => _getImage(3),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          child: Stack(
                                            children: <Widget>[
                                              Container(
                                                decoration: BoxDecoration(
                                                    color: AppColors.blackColor,
                                                    border: Border.all(
                                                      color:
                                                          AppColors.blackColor,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                10))),
                                              ),
                                              Center(
                                                  child: Image.file(
                                                      imageFiles[3],
                                                      fit: BoxFit.contain))
                                            ],
                                          ),
                                        )),
                              ),
                              SizedBox(
                                width: ScreenUtil().setHeight(5),
                              ),
                              Container(
                                height: AppConfig.heightWithDForSmallDevice(
                                    context, 120, 40),
                                width: AppConfig.heightWithDForSmallDevice(
                                    context, 120, 40),
                                child: (imageFiles[4] == null)
                                    ? FlatButton(
                                        onPressed: () => _getImage(4),
                                        shape: RoundedRectangleBorder(
                                          side: BorderSide(
                                              color: AppColors.blueColor),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Image.asset(
                                            "assets/images/plus_circle.png"))
                                    : InkWell(
                                        onTap: () => _getImage(4),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          child: Stack(
                                            children: <Widget>[
                                              Container(
                                                decoration: BoxDecoration(
                                                    color: AppColors.blackColor,
                                                    border: Border.all(
                                                      color:
                                                          AppColors.blackColor,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                10))),
                                              ),
                                              Center(
                                                  child: Image.file(
                                                      imageFiles[4],
                                                      fit: BoxFit.contain))
                                            ],
                                          ),
                                        )),
                              ),
                            ],
                          ),
                        ),
                      ),
                      /*Row(children: <Widget>[
                        Container(
                          height: height * smallHeight,
                          width: width * smallWidth,
                          child:(imageFiles[3] == null)? FlatButton(onPressed: () => _getImage(3),
                              shape: RoundedRectangleBorder(
                                side: BorderSide(color: AppColors.blueColor),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Image.asset("assets/images/plus_circle.png")
                          ): InkWell( onTap: () => _getImage(3),  child: ClipRRect(borderRadius: BorderRadius.circular(10.0), child:  Image.file(imageFiles[3], fit: BoxFit.fill,) , )),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Container(
                          height: height * smallHeight,
                          width: width * smallWidth,
                          child:(imageFiles[4] == null)? FlatButton(onPressed: () => _getImage(4),
                              shape: RoundedRectangleBorder(
                                side: BorderSide(color: AppColors.blueColor),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Image.asset("assets/images/plus_circle.png")
                          ): InkWell( onTap: () => _getImage(4),  child: ClipRRect(borderRadius: BorderRadius.circular(10.0), child:  Image.file(imageFiles[4], fit: BoxFit.fill,) , )),
                        ),
                      ],),*/
                    ],
                  ),
                  SizedBox(
                    height: ScreenUtil().setHeight(30),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    child: Text(
                      "To get more Matches, upload at least 5 pictures with good lighting. Avoid group photos and bathroom selfies!",
                      style: TextStyle(
                          fontSize:
                              AppConfig.fontsizeForSmallDevice(context, 15),
                          color: AppColors.offWhiteColor,
                          fontWeight: FontWeight.w500,
                          fontStyle: FontStyle.italic),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(
                    height: ScreenUtil().setHeight(10),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Align(
                      alignment: Alignment.center,
                      child: (loading)
                          ? PlatformCircularProgressIndicator()
                          : SizedBox(
                              height: 60,
                              width: 220,
                              child: PlatformButton(
                                onPressed: (imageFiles[0] != null)
                                    ? () {
                                        this._postImageToServer();
                                      }
                                    : null,
                                padding: EdgeInsets.symmetric(
                                    vertical: 20, horizontal: 55),
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
                                  "Continue",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16),
                                ),
                              ),
                            ),
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
