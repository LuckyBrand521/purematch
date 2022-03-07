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
import 'package:pure_match/pages/own_profile/edit_profile_pictures.dart';
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

class NewEditProfilePictures extends StatefulWidget {
  String profilePicturePath;
  bool isOnboarding;
  Function() onUpdateProfile;
  List<ImageObj> imagePaths;

  // This sets the Values of the instance vairables to what were passed into the object on creation/instantiation
  //
  NewEditProfilePictures(
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
  _NewEditProfilePicturesState createState() => _NewEditProfilePicturesState();
}

class _NewEditProfilePicturesState extends State<NewEditProfilePictures> {
  // Analytics code
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';

  String error = "";
  double bigHeight = 0.3;
  double bigWidth = 0.3;
  bool isRemoved = false;
  double smallHeight = 0.15;
  double smallWidth = 0.2;
  List<File> imageFiles = [null, null, null, null, null, null, null, null];
  bool loading = false;
  bool isOnboarding = false;
  String profilePicturePath;
  List<ImageObj> userImages;

  @override
  initState() {
    profilePicturePath = widget.profilePicturePath;
    userImages = widget.imagePaths;
    print("##################################################################");
    print(widget.profilePicturePath);
    print(widget.imagePaths);
    print(userImages);
    if (widget.isOnboarding != null && widget.isOnboarding) {
      isOnboarding = true;
    }
    _getStatus();
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

  // This function keeps track on whether or not a photo has been changed
  bool isChangedPhoto() {
    var isChanged = false;
    if (imageFiles[0] != null ||
        imageFiles[1] != null ||
        imageFiles[2] != null ||
        imageFiles[3] != null ||
        imageFiles[4] != null ||
        imageFiles[5] != null ||
        imageFiles[6] != null ||
        imageFiles[7] != null) {
      isChanged = true;
    }
    return isChanged;
  }

  //This function gets whether or not a user is premium or not
  Future<String> _getStatus() async {
    bool status;
    setState(() {
      loading = true;
    });
    var sp = await SharedPreferences.getInstance();
    int id = sp.getInt("id");
    try {
      // var res = await MyHttp.get("users/user/$id");

      var res2 = await MyHttp.get("/settings/member-status");
      // var json = jsonDecode(res.body);
      var json2 = jsonDecode(res2.body);
      status = json2["success"];
      if (status == true) Global.isPremium = true;
      setState(() {});
    } catch (e) {
      print(e);
    }
    setState(() {
      loading = false;
    });
  }

  // This function posts images to the server
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
    if (res != null && (res.statusCode == 200 || res.statusCode == 201)) {
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
    } else {
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

  ///This function will be used to delete an image from the database
  void _deleteImage(int imageNum) async {
    try {
      if (userImages[imageNum].id != null) {
        var response =
            await MyHttp.delete("uploads/${userImages[imageNum].id}");
        if (response.statusCode == 200 || response.statusCode == 201) {
          print("This was a sucessful delete attempt");
        } else {
          print("This was not a great attempt");
        }
      }
    } catch (e) {}
  }

  // This function takes sends the photo to the back end
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

  // This function does the pop up whenever someone taps the image to ask whether they want to take or choose a photo.
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

  // This fucntion is used to crop a photo that was taken
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

// this function is used to crop an image that was taken from the gallery
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

  // This function will be used to alert the user when the hit the x button to delete a photo
  void _alertUser(int imageNum) {
    Global.alertUser(
        context,
        Text("Delete Picture",
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
        Text("Are you sure you want to delete this picture?",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              height: 1.5,
            )),
        Text("Cancel",
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w400,
                color: AppColors.blueColor)),
        () {
          Navigator.of(context).pop();
        },
        Text("Delete",
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.blueColor)),
        () {
          // add to this delete function
          setState(() {
            isRemoved = true;
            _deleteImage(imageNum);
            imageFiles[imageNum] = null;
            userImages[imageNum] = null;
          });
          Navigator.of(context).pop();
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
            child: Stack(
              alignment: AlignmentDirectional.bottomCenter,
              children: [
                ListView(
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    Visibility(
                      visible: isChangedPhoto(),
                      child: Center(
                        child: Container(
                          width:
                              MediaQuery.of(context).size.width * (220 / 414),
                          child: Text(
                            "Press and hold on a picture to drag it to your desired order.",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: 10,
                        ),
                        ClipRect(
                          child: Column(
                            children: [
                              Stack(
                                children: <Widget>[
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Container(
                                    height: 171,
                                    width: 192,
                                    child: (imageFiles[0] == null)
                                        ? profilePicturePath != null &&
                                                profilePicturePath.isNotEmpty &&
                                                profilePicturePath != "na"
                                            ? InkWell(
                                                onTap: () =>
                                                    showActionsheetForPhoto(0),
                                                child: ClipRRect(
                                                  child: Stack(
                                                    children: <Widget>[
                                                      Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          color: AppColors
                                                              .blackColor,
                                                          border: Border.all(
                                                            color: AppColors
                                                                .blackColor,
                                                          ),
                                                        ),
                                                      ),
                                                      Center(
                                                        child:
                                                            CachedNetworkImage(
                                                          imageUrl:
                                                              profilePicturePath,
                                                          width: 240,
                                                          fit: BoxFit.cover,
                                                          errorWidget: (context,
                                                                  url, error) =>
                                                              Icon(Icons.error),
                                                        ),
                                                      ),
                                                      /* Positioned(
                                                          top: -15,
                                                          right: -15,
                                                          child: InkWell(
                                                            onTap: () {
                                                              setState(() {
                                                                _alertUser(0);
                                                              });
                                                            },
                                                            child: Image.asset(
                                                                'assets/images/x_icon.png'),
                                                          ))*/
                                                    ],
                                                  ),
                                                ))
                                            : FlatButton(
                                                onPressed: () =>
                                                    showActionsheetForPhoto(0),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: Container(
                                                  width: 30,
                                                  height: 30,
                                                  child: Image.asset(
                                                      "assets/images/plus-circle2.png"),
                                                ),
                                              )
                                        : InkWell(
                                            onTap: () =>
                                                showActionsheetForPhoto(0),
                                            child: ClipRRect(
                                              child: Stack(
                                                children: <Widget>[
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      color:
                                                          AppColors.blackColor,
                                                    ),
                                                  ),
                                                  Center(
                                                    child: Image.file(
                                                        imageFiles[0],
                                                        fit: BoxFit.cover),
                                                  ),
                                                  /*  Positioned(
                                                    top: -15,
                                                    right: -15,
                                                    child: InkWell(
                                                        onTap: () {
                                                          setState(() {
                                                            _alertUser(0);
                                                          });
                                                        },
                                                        child: Image.asset(
                                                            "assets/images/x_icon.png")),
                                                  )*/
                                                ],
                                              ),
                                            )),
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                          width: 2,
                                          color: AppColors.blueColor,
                                        ),
                                        borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(2))),
                                  ),
                                ],
                              ),
                              Container(
                                width: 192,
                                height: 21,
                                child: Text(
                                  "Profile Picture",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.blueColor,
                                  borderRadius: BorderRadius.vertical(
                                      bottom: Radius.circular(2)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        ClipRect(
                          child: Column(
                            children: [
                              Stack(
                                children: <Widget>[
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Container(
                                    height: 171,
                                    width: 192,
                                    child: (imageFiles[1] == null)
                                        ? userImages[1] != null
                                            ? InkWell(
                                                onTap: () =>
                                                    showActionsheetForPhoto(1),
                                                child: ClipRRect(
                                                  child: Stack(
                                                    children: <Widget>[
                                                      Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          color: AppColors
                                                              .blackColor,
                                                        ),
                                                      ),
                                                      Center(
                                                          child:
                                                              CachedNetworkImage(
                                                        imageUrl:
                                                            userImages[1].path,
                                                        width: 120,
                                                        fit: BoxFit.cover,
                                                        errorWidget: (context,
                                                                url, error) =>
                                                            Icon(Icons.error),
                                                      )),
                                                      Positioned(
                                                        top: -15,
                                                        right: -15,
                                                        child: InkWell(
                                                          child: Image.asset(
                                                              "assets/images/x_icon.png"),
                                                          onTap: () {
                                                            setState(() {
                                                              _alertUser(1);
                                                            });
                                                          },
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ))
                                            : FlatButton(
                                                onPressed: () =>
                                                    showActionsheetForPhoto(1),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: Container(
                                                  width: 30,
                                                  height: 30,
                                                  child: Image.asset(
                                                      "assets/images/plus-circle2.png"),
                                                ))
                                        : Stack(
                                            children: [
                                              InkWell(
                                                  onTap: () =>
                                                      showActionsheetForPhoto(
                                                          1),
                                                  child: ClipRRect(
                                                    child: Image.file(
                                                        imageFiles[1],
                                                        fit: BoxFit.cover),
                                                  )),
                                              Positioned(
                                                top: -15,
                                                right: -15,
                                                child: InkWell(
                                                  child: Image.asset(
                                                      "assets/images/x_icon.png"),
                                                  onTap: () {
                                                    setState(() {
                                                      _alertUser(1);
                                                    });
                                                  },
                                                ),
                                              )
                                            ],
                                          ),
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                          width: 2,
                                          color: AppColors.redColor,
                                        ),
                                        borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(2))),
                                  ),
                                ],
                              ),
                              Container(
                                width: 192,
                                height: 21,
                                child: Text(
                                  "Match Tile Picture",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.redColor,
                                  borderRadius: BorderRadius.vertical(
                                      bottom: Radius.circular(2)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: 10,
                        ),
                        ClipRect(
                          child: Stack(
                            children: <Widget>[
                              Container(
                                height: 192,
                                width: 192,
                                //might have to go back and make changes
                                child: (imageFiles[2] == null)
                                    ? userImages[2] != null
                                        ? InkWell(
                                            onTap: () =>
                                                showActionsheetForPhoto(2),
                                            child: ClipRRect(
                                              child: Stack(
                                                children: <Widget>[
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      color:
                                                          AppColors.blackColor,
                                                    ),
                                                  ),
                                                  Center(
                                                      child: CachedNetworkImage(
                                                    imageUrl:
                                                        userImages[2].path,
                                                    width: 120,
                                                    fit: BoxFit.cover,
                                                    errorWidget:
                                                        (context, url, error) =>
                                                            Icon(Icons.error),
                                                  )),
                                                  Positioned(
                                                    top: -15,
                                                    right: -15,
                                                    child: InkWell(
                                                        child: Image.asset(
                                                            'assets/images/x_icon.png'),
                                                        onTap: () {
                                                          setState(() {
                                                            _alertUser(2);
                                                          });
                                                        }),
                                                  )
                                                ],
                                              ),
                                            ))
                                        : FlatButton(
                                            onPressed: () =>
                                                showActionsheetForPhoto(2),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Container(
                                              width: 30,
                                              height: 30,
                                              child: Image.asset(
                                                  "assets/images/plus-circle2.png"),
                                            ))
                                    : Stack(
                                        children: [
                                          InkWell(
                                              onTap: () =>
                                                  showActionsheetForPhoto(2),
                                              child: ClipRRect(
                                                child: Image.file(imageFiles[2],
                                                    fit: BoxFit.cover),
                                              )),
                                          Positioned(
                                            top: -15,
                                            right: -15,
                                            child: InkWell(
                                              onTap: () {
                                                setState(() {
                                                  _alertUser(2);
                                                });
                                              },
                                              child: Image.asset(
                                                  'assets/images/x_icon.png'),
                                            ),
                                          ),
                                        ],
                                      ),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                      width: 2,
                                      color: AppColors.blueColor,
                                    ),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(2))),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        ClipRect(
                          child: Stack(
                            children: <Widget>[
                              Container(
                                height: 192,
                                width: 192,
                                child: (imageFiles[3] == null)
                                    ? userImages[3] != null
                                        ? InkWell(
                                            onTap: () =>
                                                showActionsheetForPhoto(3),
                                            child: ClipRRect(
                                              child: Stack(
                                                children: <Widget>[
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      color:
                                                          AppColors.blackColor,
                                                    ),
                                                  ),
                                                  Center(
                                                      child: CachedNetworkImage(
                                                    imageUrl:
                                                        userImages[3].path,
                                                    width: 120,
                                                    fit: BoxFit.cover,
                                                    errorWidget:
                                                        (context, url, error) =>
                                                            Icon(Icons.error),
                                                  )),
                                                  Positioned(
                                                    top: -15,
                                                    right: -15,
                                                    child: InkWell(
                                                        child: Image.asset(
                                                            'assets/images/x_icon.png'),
                                                        onTap: () {
                                                          setState(() {
                                                            _alertUser(3);
                                                          });
                                                        }),
                                                  )
                                                ],
                                              ),
                                            ))
                                        : FlatButton(
                                            onPressed: () =>
                                                showActionsheetForPhoto(3),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Container(
                                              width: 30,
                                              height: 30,
                                              child: Image.asset(
                                                  "assets/images/plus-circle2.png"),
                                            ))
                                    : Stack(children: [
                                        InkWell(
                                            onTap: () =>
                                                showActionsheetForPhoto(3),
                                            child: ClipRRect(
                                              child: Stack(
                                                children: <Widget>[
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      color:
                                                          AppColors.blackColor,
                                                    ),
                                                  ),
                                                  Center(
                                                      child: Image.file(
                                                          imageFiles[3],
                                                          fit: BoxFit.cover)),
                                                ],
                                              ),
                                            )),
                                        Positioned(
                                            top: -15,
                                            right: -15,
                                            child: (InkWell(
                                              onTap: () {
                                                setState(() {
                                                  _alertUser(3);
                                                });
                                              },
                                              child: Image.asset(
                                                  'assets/images/x_icon.png'),
                                            )))
                                      ]),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                      width: 2,
                                      color: AppColors.blueColor,
                                    ),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(2))),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: 10,
                        ),
                        ClipRect(
                          child: Stack(
                            children: <Widget>[
                              Container(
                                height: 192,
                                width: 192,
                                child: (imageFiles[4] == null)
                                    ? userImages[4] != null
                                        ? InkWell(
                                            onTap: () =>
                                                showActionsheetForPhoto(4),
                                            child: ClipRRect(
                                              child: Stack(
                                                children: <Widget>[
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      color:
                                                          AppColors.blackColor,
                                                    ),
                                                  ),
                                                  Center(
                                                      child: CachedNetworkImage(
                                                    imageUrl:
                                                        userImages[4].path,
                                                    width: 120,
                                                    fit: BoxFit.cover,
                                                    errorWidget:
                                                        (context, url, error) =>
                                                            Icon(Icons.error),
                                                  )),
                                                  Positioned(
                                                      top: -15,
                                                      right: -15,
                                                      child: InkWell(
                                                          onTap: () {
                                                            setState(() {
                                                              _alertUser(4);
                                                            });
                                                          },
                                                          child: Image.asset(
                                                              'assets/images/x_icon.png')))
                                                ],
                                              ),
                                            ))
                                        : FlatButton(
                                            onPressed: () =>
                                                showActionsheetForPhoto(4),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Container(
                                              width: 30,
                                              height: 30,
                                              child: Image.asset(
                                                  "assets/images/plus-circle2.png"),
                                            ))
                                    : Stack(children: [
                                        InkWell(
                                            onTap: () =>
                                                showActionsheetForPhoto(4),
                                            child: ClipRRect(
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
                                                    ),
                                                  ),
                                                  Center(
                                                      child: Image.file(
                                                          imageFiles[4],
                                                          fit: BoxFit.cover))
                                                ],
                                              ),
                                            )),
                                        Positioned(
                                            top: -15,
                                            right: -15,
                                            child: (InkWell(
                                              onTap: () {
                                                setState(() {
                                                  _alertUser(4);
                                                });
                                              },
                                              child: Image.asset(
                                                  'assets/images/x_icon.png'),
                                            )))
                                      ]),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                      width: 2,
                                      color: AppColors.blueColor,
                                    ),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(2))),
                              ),
                              Visibility(
                                // TODO: Check user premium or not for all black container widget in user_dating_preferences.dart
                                visible: !Global.isPremium,
                                child: Container(
                                  width: 192,
                                  height: 192,
                                  color: AppColors.greyUpgradeColor,
                                ),
                              ),
                              Visibility(
                                // TODO: Check user premium or not for all  "Upgrade to Pure Match Premium to Unlock this filter" text widget in user_dating_preferences.dart"
                                visible: !Global.isPremium,
                                child: Container(
                                  width: 192,
                                  height: 192,
                                  child: Center(
                                    child: Container(
                                      width: 140,
                                      child: Text(
                                        "Upgrade to Pure Match Premium for extra profile pictures",
                                        style: TextStyle(
                                            shadows: [
                                              Shadow(
                                                  blurRadius: 3.0,
                                                  color: Colors.black,
                                                  offset: Offset(1.0, 2.0))
                                            ],
                                            fontSize: 16,
                                            fontFamily: 'Avenir Next',
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        ClipRect(
                          child: Stack(
                            children: <Widget>[
                              Container(
                                height: 192,
                                width: 192,
                                child: (imageFiles[5] == null)
                                    ? userImages[5] != null
                                        ? InkWell(
                                            onTap: () =>
                                                showActionsheetForPhoto(5),
                                            child: ClipRRect(
                                              child: Stack(
                                                children: <Widget>[
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      color:
                                                          AppColors.blackColor,
                                                    ),
                                                  ),
                                                  Center(
                                                      child: CachedNetworkImage(
                                                    imageUrl:
                                                        userImages[5].path,
                                                    width: 120,
                                                    fit: BoxFit.cover,
                                                    errorWidget:
                                                        (context, url, error) =>
                                                            Icon(Icons.error),
                                                  )),
                                                  Positioned(
                                                      top: -15,
                                                      right: -15,
                                                      child: (InkWell(
                                                        onTap: () {
                                                          setState(() {
                                                            _alertUser(5);
                                                          });
                                                        },
                                                        child: Image.asset(
                                                            'assets/images/x_icon.png'),
                                                      ))),
                                                ],
                                              ),
                                            ))
                                        : FlatButton(
                                            onPressed: () =>
                                                showActionsheetForPhoto(5),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Container(
                                              width: 30,
                                              height: 30,
                                              child: Image.asset(
                                                  "assets/images/plus-circle2.png"),
                                            ))
                                    : Stack(children: [
                                        InkWell(
                                            onTap: () =>
                                                showActionsheetForPhoto(5),
                                            child: ClipRRect(
                                              child: Stack(
                                                children: <Widget>[
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      color:
                                                          AppColors.blackColor,
                                                    ),
                                                  ),
                                                  Center(
                                                      child: Image.file(
                                                          imageFiles[5],
                                                          fit: BoxFit.cover))
                                                ],
                                              ),
                                            )),
                                        Positioned(
                                            top: -15,
                                            right: -15,
                                            child: (InkWell(
                                              onTap: () {
                                                setState(() {
                                                  _alertUser(5);
                                                });
                                              },
                                              child: Image.asset(
                                                  'assets/images/x_icon.png'),
                                            )))
                                      ]),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                      width: 2,
                                      color: AppColors.blueColor,
                                    ),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(2))),
                              ),
                              Visibility(
                                // TODO: Check user premium or not for all black container widget in user_dating_preferences.dart
                                visible: !Global.isPremium,
                                child: Container(
                                  width: 192,
                                  height: 192,
                                  color: AppColors.greyUpgradeColor,
                                ),
                              ),
                              Visibility(
                                // TODO: Check user premium or not for all  "Upgrade to Pure Match Premium to Unlock this filter" text widget in user_dating_preferences.dart"
                                visible: !Global.isPremium,
                                child: Container(
                                  width: 192,
                                  height: 192,
                                  child: Center(
                                    child: SizedBox(
                                      width: 140,
                                      child: Text(
                                        "Upgrade to Pure Match Premium for extra profile pictures",
                                        style: TextStyle(
                                            shadows: [
                                              Shadow(
                                                  blurRadius: 3.0,
                                                  color: Colors.black,
                                                  offset: Offset(1.0, 2.0))
                                            ],
                                            fontSize: 16,
                                            fontFamily: 'Avenir Next',
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: 10,
                        ),
                        ClipRect(
                          child: Stack(
                            children: <Widget>[
                              Container(
                                height: 192,
                                width: 192,
                                child: (imageFiles[6] == null)
                                    ? userImages[6] != null
                                        ? InkWell(
                                            onTap: () =>
                                                showActionsheetForPhoto(6),
                                            child: ClipRRect(
                                              child: Stack(
                                                children: <Widget>[
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      color:
                                                          AppColors.blackColor,
                                                    ),
                                                  ),
                                                  Center(
                                                      child: CachedNetworkImage(
                                                    imageUrl:
                                                        userImages[6].path,
                                                    width: 120,
                                                    fit: BoxFit.cover,
                                                    errorWidget:
                                                        (context, url, error) =>
                                                            Icon(Icons.error),
                                                  )),
                                                  Positioned(
                                                      top: -15,
                                                      right: -15,
                                                      child: (InkWell(
                                                        onTap: () {
                                                          setState(() {
                                                            _alertUser(6);
                                                          });
                                                        },
                                                        child: Image.asset(
                                                            'assets/images/x_icon.png'),
                                                      ))),
                                                ],
                                              ),
                                            ))
                                        : FlatButton(
                                            onPressed: () =>
                                                showActionsheetForPhoto(6),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Container(
                                              width: 30,
                                              height: 30,
                                              child: Image.asset(
                                                  "assets/images/plus-circle2.png"),
                                            ))
                                    : Stack(children: [
                                        InkWell(
                                            onTap: () =>
                                                showActionsheetForPhoto(6),
                                            child: ClipRRect(
                                              child: Stack(
                                                children: <Widget>[
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      color:
                                                          AppColors.blackColor,
                                                    ),
                                                  ),
                                                  Center(
                                                      child: Image.file(
                                                          imageFiles[6],
                                                          fit: BoxFit.cover))
                                                ],
                                              ),
                                            )),
                                        Positioned(
                                            top: -15,
                                            right: -15,
                                            child: (InkWell(
                                              onTap: () {
                                                setState(() {
                                                  _alertUser(6);
                                                });
                                              },
                                              child: Image.asset(
                                                  'assets/images/x_icon.png'),
                                            ))),
                                      ]),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                      width: 2,
                                      color: AppColors.blueColor,
                                    ),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(2))),
                              ),
                              Visibility(
                                // TODO: Check user premium or not for all black container widget in user_dating_preferences.dart
                                visible: !Global.isPremium,
                                child: Container(
                                  width: 192,
                                  height: 192,
                                  color: AppColors.greyUpgradeColor,
                                ),
                              ),
                              Visibility(
                                // TODO: Check user premium or not for all  "Upgrade to Pure Match Premium to Unlock this filter" text widget in user_dating_preferences.dart"
                                visible: !Global.isPremium,
                                child: Container(
                                  width: 192,
                                  height: 192,
                                  child: Center(
                                    child: SizedBox(
                                      width: 140,
                                      child: Text(
                                        "Upgrade to Pure Match Premium for extra profile pictures",
                                        style: TextStyle(
                                            shadows: [
                                              Shadow(
                                                  blurRadius: 3.0,
                                                  color: Colors.black,
                                                  offset: Offset(1.0, 2.0))
                                            ],
                                            fontSize: 16,
                                            fontFamily: 'Avenir Next',
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        ClipRect(
                          child: Stack(
                            children: <Widget>[
                              Container(
                                height: 192,
                                width: 192,
                                child: (imageFiles[7] == null)
                                    ? userImages[7] != null
                                        ? InkWell(
                                            onTap: () =>
                                                showActionsheetForPhoto(7),
                                            child: ClipRRect(
                                              child: Stack(
                                                children: <Widget>[
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      color:
                                                          AppColors.blackColor,
                                                    ),
                                                  ),
                                                  Center(
                                                      child: CachedNetworkImage(
                                                    imageUrl:
                                                        userImages[7].path,
                                                    width: 120,
                                                    fit: BoxFit.cover,
                                                    errorWidget:
                                                        (context, url, error) =>
                                                            Icon(Icons.error),
                                                  )),
                                                  Positioned(
                                                      top: -15,
                                                      right: -15,
                                                      child: (InkWell(
                                                        onTap: () {
                                                          setState(() {
                                                            _alertUser(7);
                                                          });
                                                        },
                                                        child: Image.asset(
                                                            'assets/images/x_icon.png'),
                                                      ))),
                                                ],
                                              ),
                                            ))
                                        : FlatButton(
                                            onPressed: () =>
                                                showActionsheetForPhoto(7),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Container(
                                              width: 30,
                                              height: 30,
                                              child: Image.asset(
                                                  "assets/images/plus-circle2.png"),
                                            ))
                                    : Stack(children: [
                                        InkWell(
                                            onTap: () =>
                                                showActionsheetForPhoto(7),
                                            child: ClipRRect(
                                              child: Stack(
                                                children: <Widget>[
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      color:
                                                          AppColors.blackColor,
                                                    ),
                                                  ),
                                                  Center(
                                                      child: Image.file(
                                                          imageFiles[7],
                                                          fit: BoxFit.cover))
                                                ],
                                              ),
                                            )),
                                        Positioned(
                                            top: -15,
                                            right: -15,
                                            child: (InkWell(
                                              onTap: () {
                                                setState(() {
                                                  _alertUser(7);
                                                });
                                              },
                                              child: Image.asset(
                                                  'assets/images/x_icon.png'),
                                            ))),
                                      ]),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                      width: 2,
                                      color: AppColors.blueColor,
                                    ),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(2))),
                              ),
                              Visibility(
                                // TODO: Check user premium or not for all black container widget in user_dating_preferences.dart
                                visible: !Global.isPremium,
                                child: Container(
                                  width: 192,
                                  height: 192,
                                  color: AppColors.greyUpgradeColor,
                                ),
                              ),
                              Visibility(
                                // TODO: Check user premium or not for all  "Upgrade to Pure Match Premium to Unlock this filter" text widget in user_dating_preferences.dart"
                                visible: !Global.isPremium,
                                child: Container(
                                  width: 192,
                                  height: 192,
                                  child: Center(
                                    child: SizedBox(
                                      width: 140,
                                      child: Text(
                                        "Upgrade to Pure Match Premium for extra profile pictures",
                                        style: TextStyle(
                                            shadows: [
                                              Shadow(
                                                  blurRadius: 3.0,
                                                  color: Colors.black,
                                                  offset: Offset(1.0, 2.0))
                                            ],
                                            fontSize: 16,
                                            fontFamily: 'Avenir Next',
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                    Container(
                      height:
                          (MediaQuery.of(context).size.height) * (155 / 896),
                    ),
                    SizedBox(
                      height: 5,
                    )
                  ],
                ),
                Container(
                  width: (MediaQuery.of(context).size.width),
                  color: Colors.white,
                  height: (MediaQuery.of(context).size.height) * (155 / 896),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 20,
                      ),
                      Visibility(
                        visible: profilePicturePath == null,
                        child: Text(
                          "Upload at least a profile picture to continue.",
                          style: TextStyle(
                            color: AppColors.redColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        width: 360,
                        height: 60,
                        padding: EdgeInsets.symmetric(vertical: 5),
                        child: PlatformButton(
                            onPressed: (isChangedPhoto() || isRemoved)
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
                                              Navigator.pop(context);
                                            }, "", null, "", null);
                                          }
                                : null,
                            color: isChangedPhoto() || isRemoved
                                ? AppColors.blueColor
                                : AppColors.greyColor,
                            disabledColor: AppColors.greyColor,
                            materialFlat: (_, __) => MaterialFlatButtonData(
                                  color: isChangedPhoto() || isRemoved
                                      ? AppColors.blueColor
                                      : AppColors.greyColor,
                                  disabledColor: AppColors.greyColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                            cupertinoFilled: (_, __) =>
                                CupertinoFilledButtonData(
                                  borderRadius: BorderRadius.circular(10),
                                  disabledColor: isChangedPhoto() || isRemoved
                                      ? AppColors.blueColor
                                      : AppColors.greyColor,
                                ),
                            child: Text(
                              "Save Changes",
                              style: isChangedPhoto() || isRemoved
                                  ? TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize:
                                          (AppConfig.fullHeight(context) >= 667
                                              ? 20
                                              : 16))
                                  : TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w400,
                                      fontSize:
                                          (AppConfig.fullHeight(context) >= 667
                                              ? 20
                                              : 16)),
                            )),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
