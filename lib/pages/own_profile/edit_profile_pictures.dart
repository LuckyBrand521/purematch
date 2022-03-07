import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:amplitude_flutter/amplitude.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:pure_match/common/global.dart';
import 'package:pure_match/common/loading.dart';
import 'package:pure_match/models/ImageObj.dart';
import 'package:pure_match/pages/own_profile/edit_profile_details_app_bar.dart';
import 'package:pure_match/pages/rewards/plan.dart';
import 'package:sailor/sailor.dart';
import '../../routes.dart';
import '../AppColors.dart';
import '../MyHttp.dart';
import 'dart:io' show File, Platform;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import '../MyUrl.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:http_parser/http_parser.dart';

class EditProfilePictures extends StatefulWidget {
  String profilePicturePath;
  bool isOnboarding;
  Function() onUpdateProfile;
  List<ImageObj> imagePaths;

  EditProfilePictures(
      {String profilePicturePath,
      bool isOnboarding,
      List<ImageObj> imagePaths,
      Function() onUpdateProfile}) {
    this.profilePicturePath = profilePicturePath;
    this.isOnboarding = isOnboarding ?? false;
    this.imagePaths = imagePaths;
    this.onUpdateProfile = onUpdateProfile;
  }

  @override
  EditProfilePicturesState createState() => EditProfilePicturesState();
}

class EditProfilePicturesState extends State<EditProfilePictures> {
  // Analytics code
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';

  String error = "";
  double bigHeight = 0.3;
  double bigWidth = 0.3;

  double smallHeight = 0.15;
  double smallWidth = 0.2;
  List<File> imageFiles = [null, null, null, null, null];
  bool loading = false;
  bool isOnboarding = false;
  String profilePicturePath;
  List<ImageObj> userImages;

  @override
  initState() {
    profilePicturePath = widget.profilePicturePath;
    userImages = widget.imagePaths;
    if (widget.isOnboarding != null && widget.isOnboarding) {
      isOnboarding = true;
    }
    super.initState();
    // Analytics tracking code
    amplitudeAnalytics.init(apiKey);
    analytics.setCurrentScreen(
        screenName: "profile_picture", screenClassOverride: "profile_pricture");
    amplitudeAnalytics.logEvent("profile_picture_page");
  }

  Future<File> getImageFileFromAssets(String path) async {
    final byteData = await rootBundle.load('assets/$path');

    final file = File('${(await getTemporaryDirectory()).path}/$path');
    await file.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    return file;
  }

  bool isChangedPhoto() {
    var isChanged = false;
    if (imageFiles[0] != null ||
        imageFiles[1] != null ||
        imageFiles[2] != null ||
        imageFiles[3] != null ||
        imageFiles[4] != null) {
      isChanged = true;
    }
    return isChanged;
  }

  void _postImageToServer() async {
    setState(() {
      loading = true;
    });

    var imageStream, f, res, body, newUpload;
    var sp = await SharedPreferences.getInstance();
    String token = sp.getString("token");
    for (int i = 0; i < imageFiles.length; i++) {
      var img = imageFiles[i];
      if (img != null) {
        var request =
            new http.MultipartRequest("POST", Uri.parse(MyUrl.url("/uploads")));
        // var request = new http.MultipartRequest(
        //     "POST", Uri.parse("https://c713e8ae44f7.ngrok.io/uploads"));
        request.headers["authorization"] = "Bearer $token";

        //only if images are changed, create multipart requests
        imageStream = img.readAsBytes().asStream();
        f = http.MultipartFile('file', imageStream, img.lengthSync(),
            filename: img.path, contentType: MediaType('image', 'jpg'));
        print("photo index=${i}");
        request.fields['tag'] = i.toString();
        request.files.add(f);

        try {
          res = await request.send();

          if (res.statusCode == 200 || res.statusCode == 201) {
            print("Uploaded");
            if (i == 0) {
              var response = await http.Response.fromStream(res);
              if (response != null) {
                body = json.decode(response.body);
                newUpload = body["newUpload"];
                setUserProfilePicture(newUpload['path'] as String);
              }
            }
          } else {
            print("error");
            print("Error ${res.statusCode}");

            setState(() {
              this.error = "An Error has occured with statuscode " +
                  res.statusCode.toString();
            });
          }
        } catch (e) {
          print("Catch error");
          print(e.toString());
        }
      }
    }
    setState(() {
      loading = false;
    });

    if (res.statusCode == 200 || res.statusCode == 201) {
      //Analytics tracking code
      analytics.logEvent(
          name: "edited_profile",
          parameters: <String, dynamic>{'profile_picture': "profilePicture"});
      amplitudeAnalytics.logEvent("edited_profile",
          eventProperties: {'profile_picture': "profilePicture"});

      if (isOnboarding) {
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
  }

  Future<void> setUserProfilePicture(String path) async {
    var res = await MyHttp.put("users/update", {"ProfilePictureId": path});
    if (res.statusCode == 200) {
      print("User updated");
      print(res.body);
    } else {
      print("User update error: ${res.statusCode}");
      print("User update error: ${res.body}");
      setState(() {
        error =
            "An Error has occured with statuscode " + res.statusCode.toString();
      });
    }
  }

  void showActionsheetForPhoto(int imageNum) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const Text('Select your option'),
        message: null,
        actions: <Widget>[
          CupertinoActionSheetAction(
            child: const Text('Take a photo'),
            onPressed: () {
              Navigator.pop(context, 'One');
              getImageFromCamera(imageNum);
            },
          ),
          CupertinoActionSheetAction(
            child: const Text('Open camera roll'),
            onPressed: () {
              Navigator.pop(context, 'Two');
              this._getImage(imageNum);
            },
          )
        ],
      ),
    );
  }

  void getImageFromCamera(int imageNum) async {
    var image = await ImagePicker().getImage(
      source: ImageSource.camera,
      // imageQuality: 90,
      // maxHeight: 500,
      // maxWidth: 500,
    );
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

    if (imageNum == 0) {
      if (croppedFile == null) {
        return;
      }
    } else {
      if (image == null) {
        return;
      }
    }
    setState(() {
      if (croppedFile != null) {
        imageFiles[imageNum] = croppedFile;
      } else {
        imageFiles[imageNum] = File(image.path);
      }
    });
  }

  void _getImage(int imageNum) async {
    var image = await ImagePicker().getImage(
      source: ImageSource.gallery,
      // imageQuality: 90,
      // maxHeight: 1000,
      // maxWidth: 1000,
    );
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

    if (imageNum == 0) {
      if (croppedFile == null) {
        return;
      }
    } else {
      if (image == null) {
        return;
      }
    }
    setState(() {
      if (croppedFile != null) {
        imageFiles[imageNum] = croppedFile;
      } else {
        imageFiles[imageNum] = File(image.path);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double pageWidth = MediaQuery.of(context).size.width;
    double notifySize = MediaQuery.of(context).padding.top;
    double appBarSize = Platform.isIOS
        ? CupertinoNavigationBar().preferredSize.height
        : AppBar().preferredSize.height;
    return PlatformScaffold(
      appBar: EditProfileDetailsAppBar(
        context: context,
        text: "Edit Profile Pictures",
        titleSize: AppConfig.fontsizeForSmallDevice(context, 24),
      ).getAppBar2(isChangedPhoto(), Global.hasProfileImg),
      body: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(new FocusNode());
            },
            child: SingleChildScrollView(
              child: SizedBox(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      SizedBox(
                        height:
                            (AppConfig.fullHeight(context) >= 667 ? 30 : 15),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              height: 240,
                              width: 240,
                              child: (imageFiles[0] == null)
                                  ? profilePicturePath != null &&
                                          profilePicturePath.isNotEmpty &&
                                          profilePicturePath != "na"
                                      ? InkWell(
                                          onTap: () =>
                                              showActionsheetForPhoto(0),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            child: Stack(
                                              children: <Widget>[
                                                Container(
                                                  decoration: BoxDecoration(
                                                      color:
                                                          AppColors.blackColor,
                                                      border: Border.all(
                                                        color: AppColors
                                                            .blackColor,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  10))),
                                                ),
                                                Center(
                                                    child: CachedNetworkImage(
                                                  imageUrl: profilePicturePath,
                                                  width: 240,
                                                  fit: BoxFit.cover,
                                                  errorWidget:
                                                      (context, url, error) =>
                                                          Icon(Icons.error),
                                                ))
                                              ],
                                            ),
                                          ))
                                      : FlatButton(
                                          onPressed: () =>
                                              showActionsheetForPhoto(0),
                                          shape: RoundedRectangleBorder(
                                            side: BorderSide(
                                                color: AppColors.blueColor),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Image.asset(
                                              "assets/images/plus_circle.png"))
                                  : InkWell(
                                      onTap: () => showActionsheetForPhoto(0),
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        child: Stack(
                                          children: <Widget>[
                                            Container(
                                              decoration: BoxDecoration(
                                                  color: AppColors.blackColor,
                                                  border: Border.all(
                                                    color: AppColors.blackColor,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(10))),
                                            ),
                                            Center(
                                                child: Image.file(imageFiles[0],
                                                    fit: BoxFit.cover))
                                          ],
                                        ),
                                      )),
                            ),
                            SizedBox(
                              height: (AppConfig.fullHeight(context) >= 667
                                  ? 10
                                  : 5),
                            ),
                            Container(
                              height: 130,
                              child: Scrollbar(
                                child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  children: <Widget>[
                                    Container(
                                      height: 120,
                                      width: 120,
                                      child: (imageFiles[1] == null)
                                          ? userImages[1] != null
                                              ? InkWell(
                                                  onTap: () =>
                                                      showActionsheetForPhoto(
                                                          1),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                    child: Stack(
                                                      children: <Widget>[
                                                        Container(
                                                          decoration:
                                                              BoxDecoration(
                                                                  color: AppColors
                                                                      .blackColor,
                                                                  border: Border
                                                                      .all(
                                                                    color: AppColors
                                                                        .blackColor,
                                                                  ),
                                                                  borderRadius:
                                                                      BorderRadius.all(
                                                                          Radius.circular(
                                                                              10))),
                                                        ),
                                                        Center(
                                                            child:
                                                                CachedNetworkImage(
                                                          imageUrl:
                                                              userImages[1]
                                                                  .path,
                                                          width: 120,
                                                          fit: BoxFit.cover,
                                                          errorWidget: (context,
                                                                  url, error) =>
                                                              Icon(Icons.error),
                                                        ))
                                                      ],
                                                    ),
                                                  ))
                                              : FlatButton(
                                                  onPressed: () =>
                                                      showActionsheetForPhoto(
                                                          1),
                                                  shape: RoundedRectangleBorder(
                                                    side: BorderSide(
                                                        color: AppColors
                                                            .blueColor),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  child: Image.asset(
                                                      "assets/images/plus_circle.png"))
                                          : InkWell(
                                              onTap: () =>
                                                  showActionsheetForPhoto(1),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                                child: Image.file(imageFiles[1],
                                                    fit: BoxFit.cover),
                                              )),
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Container(
                                      height: 120,
                                      width: 120,
                                      child: (imageFiles[2] == null)
                                          ? userImages[2] != null
                                              ? InkWell(
                                                  onTap: () =>
                                                      showActionsheetForPhoto(
                                                          2),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                    child: Stack(
                                                      children: <Widget>[
                                                        Container(
                                                          decoration:
                                                              BoxDecoration(
                                                                  color: AppColors
                                                                      .blackColor,
                                                                  border: Border
                                                                      .all(
                                                                    color: AppColors
                                                                        .blackColor,
                                                                  ),
                                                                  borderRadius:
                                                                      BorderRadius.all(
                                                                          Radius.circular(
                                                                              10))),
                                                        ),
                                                        Center(
                                                            child:
                                                                CachedNetworkImage(
                                                          imageUrl:
                                                              userImages[2]
                                                                  .path,
                                                          width: 120,
                                                          fit: BoxFit.cover,
                                                          errorWidget: (context,
                                                                  url, error) =>
                                                              Icon(Icons.error),
                                                        ))
                                                      ],
                                                    ),
                                                  ))
                                              : FlatButton(
                                                  onPressed: () =>
                                                      showActionsheetForPhoto(
                                                          2),
                                                  shape: RoundedRectangleBorder(
                                                    side: BorderSide(
                                                        color: AppColors
                                                            .blueColor),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  child: Image.asset(
                                                      "assets/images/plus_circle.png"))
                                          : InkWell(
                                              onTap: () =>
                                                  showActionsheetForPhoto(2),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                                child: Image.file(imageFiles[2],
                                                    fit: BoxFit.cover),
                                              )),
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Container(
                                      height: 120,
                                      width: 120,
                                      child: (imageFiles[3] == null)
                                          ? userImages[3] != null
                                              ? InkWell(
                                                  onTap: () =>
                                                      showActionsheetForPhoto(
                                                          3),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                    child: Stack(
                                                      children: <Widget>[
                                                        Container(
                                                          decoration:
                                                              BoxDecoration(
                                                                  color: AppColors
                                                                      .blackColor,
                                                                  border: Border
                                                                      .all(
                                                                    color: AppColors
                                                                        .blackColor,
                                                                  ),
                                                                  borderRadius:
                                                                      BorderRadius.all(
                                                                          Radius.circular(
                                                                              10))),
                                                        ),
                                                        Center(
                                                            child:
                                                                CachedNetworkImage(
                                                          imageUrl:
                                                              userImages[3]
                                                                  .path,
                                                          width: 120,
                                                          fit: BoxFit.cover,
                                                          errorWidget: (context,
                                                                  url, error) =>
                                                              Icon(Icons.error),
                                                        ))
                                                      ],
                                                    ),
                                                  ))
                                              : FlatButton(
                                                  onPressed: () =>
                                                      showActionsheetForPhoto(
                                                          3),
                                                  shape: RoundedRectangleBorder(
                                                    side: BorderSide(
                                                        color: AppColors
                                                            .blueColor),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  child: Image.asset(
                                                      "assets/images/plus_circle.png"))
                                          : InkWell(
                                              onTap: () =>
                                                  showActionsheetForPhoto(3),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                                child: Stack(
                                                  children: <Widget>[
                                                    Container(
                                                      decoration: BoxDecoration(
                                                          color: AppColors
                                                              .blackColor,
                                                          border: Border.all(
                                                            color: AppColors
                                                                .blackColor,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          10))),
                                                    ),
                                                    Center(
                                                        child: Image.file(
                                                            imageFiles[3],
                                                            fit: BoxFit.cover))
                                                  ],
                                                ),
                                              )),
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Container(
                                      height: 120,
                                      width: 120,
                                      child: (imageFiles[4] == null)
                                          ? userImages[4] != null
                                              ? InkWell(
                                                  onTap: () =>
                                                      showActionsheetForPhoto(
                                                          4),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                    child: Stack(
                                                      children: <Widget>[
                                                        Container(
                                                          decoration:
                                                              BoxDecoration(
                                                                  color: AppColors
                                                                      .blackColor,
                                                                  border: Border
                                                                      .all(
                                                                    color: AppColors
                                                                        .blackColor,
                                                                  ),
                                                                  borderRadius:
                                                                      BorderRadius.all(
                                                                          Radius.circular(
                                                                              10))),
                                                        ),
                                                        Center(
                                                            child:
                                                                CachedNetworkImage(
                                                          imageUrl:
                                                              userImages[4]
                                                                  .path,
                                                          width: 120,
                                                          fit: BoxFit.cover,
                                                          errorWidget: (context,
                                                                  url, error) =>
                                                              Icon(Icons.error),
                                                        ))
                                                      ],
                                                    ),
                                                  ))
                                              : FlatButton(
                                                  onPressed: () =>
                                                      showActionsheetForPhoto(
                                                          4),
                                                  shape: RoundedRectangleBorder(
                                                    side: BorderSide(
                                                        color: AppColors
                                                            .blueColor),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  child: Image.asset(
                                                      "assets/images/plus_circle.png"))
                                          : InkWell(
                                              onTap: () =>
                                                  showActionsheetForPhoto(4),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                                child: Stack(
                                                  children: <Widget>[
                                                    Container(
                                                      decoration: BoxDecoration(
                                                          color: AppColors
                                                              .blackColor,
                                                          border: Border.all(
                                                            color: AppColors
                                                                .blackColor,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          10))),
                                                    ),
                                                    Center(
                                                        child: Image.file(
                                                            imageFiles[4],
                                                            fit: BoxFit.cover))
                                                  ],
                                                ),
                                              )),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height:
                            (AppConfig.fullHeight(context) >= 667 ? 30 : 15),
                      ),
                      Center(
                        child: Text(
                          "Press and hold on a picture to adjust its order on your profile.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w400),
                        ),
                      ),
                      Align(
                          alignment: Alignment.bottomCenter,
                          child: Center(
                            child: Wrap(
                              direction: Axis.vertical,
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: <Widget>[
                                Text(
                                  this.error,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.redColor),
                                ),
                                SizedBox(
                                  height: (AppConfig.fullHeight(context) >= 667
                                      ? 10
                                      : 5),
                                ),
                                Visibility(
                                  visible: (!Global.isPremium),
                                  child: InkWell(
                                    onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => Plan())),
                                    child: Text(
                                      "Upgrade to Premium to\nupload more photos!",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                          fontStyle: FontStyle.italic,
                                          color: AppColors.redColor,
                                          decoration: TextDecoration.underline),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: (AppConfig.fullHeight(context) >= 667
                                      ? 20
                                      : 10),
                                ),
                                SizedBox(
                                  height: (AppConfig.fullHeight(context) >= 667
                                      ? 60
                                      : 50),
                                  width: pageWidth * 0.90,
                                  child: (this.loading)
                                      ? Loading.showLoading()
                                      : PlatformButton(
                                          onPressed: (isChangedPhoto())
                                              ? (Global.hasProfileImg)
                                                  ? () {
                                                      this._postImageToServer();
                                                    }
                                                  : (imageFiles[0] != null)
                                                      ? () {
                                                          print("ready");
                                                          this._postImageToServer();
                                                        }
                                                      : () {
                                                          Global.alertUserForCardAction(
                                                              context,
                                                              "Oops",
                                                              "Please select the first picture. It will be your profile picture.",
                                                              "Ok", () {
                                                            Navigator.pop(
                                                                context);
                                                          }, "", null, "",
                                                              null);
                                                        }
                                              : null,
                                          color: (isChangedPhoto())
                                              ? AppColors.blueColor
                                              : AppColors.disabledBlueColor,
                                          disabledColor:
                                              AppColors.disabledBlueColor,
                                          materialFlat: (_, __) =>
                                              MaterialFlatButtonData(
                                                color: AppColors.blueColor,
                                                disabledColor:
                                                    AppColors.disabledBlueColor,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                              ),
                                          cupertinoFilled: (_, __) =>
                                              CupertinoFilledButtonData(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                disabledColor:
                                                    AppColors.disabledBlueColor,
                                              ),
                                          child: Text(
                                            "Save Changes",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w700,
                                                fontSize: (AppConfig.fullHeight(
                                                            context) >=
                                                        667
                                                    ? 20
                                                    : 16)),
                                          )),
                                ),
                              ],
                            ),
                          )),
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
