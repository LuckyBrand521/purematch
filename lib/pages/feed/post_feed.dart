import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:amplitude_flutter/amplitude.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pure_match/common/global.dart';
import 'package:pure_match/models/user.dart';

import 'package:pure_match/pages/MyHttp.dart';
import 'package:pure_match/pages/community_profile/community_profile.dart';
import 'dart:io';

import '../AppColors.dart';

class PostFeed extends StatefulWidget {
  bool isAdmin;

  PostFeed({bool isAdmin}) {
    this.isAdmin = isAdmin;
  }

  @override
  _PostFeedState createState() => _PostFeedState();
}

class _PostFeedState extends State<PostFeed> {
  // Analytics code
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';

  List<File> _images = [];
  String text = "";
  TextEditingController _ctrl;
  bool showOptions = false;
  bool _loading = false;
  bool _adminAnnouncement = false;
  User _user;
  bool isAdmin;
  void _getImage() async {
    var image = await ImagePicker().getImage(
      source: ImageSource.gallery,
      // maxWidth: 500,
      // maxHeight: 500,
      imageQuality: 75,
    );
    if (image == null) return;
    File croppedFile = await ImageCropper.cropImage(
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
    if (croppedFile == null) return;
    _images.add(File(croppedFile.path));
    this._ctrl.text = this.text;
    setState(() {});
  }

  void _getImageFromCamera() async {
    var image = await ImagePicker().getImage(
      source: ImageSource.camera,
      // maxWidth: 500,
      // maxHeight: 500,
      imageQuality: 75,
    );
    if (image == null) return;
    File croppedFile = await ImageCropper.cropImage(
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
    if (croppedFile == null) return;
    _images.add(File(croppedFile.path));
    this._ctrl.text = this.text;
    setState(() {});
  }

  void _getUserDetails() async {
    setState(() {
      _loading = true;
    });
    _user = await MyHttp.getUserDetails();
    setState(() {
      _loading = false;
    });
  }

  void _post() {
    Navigator.pop(context, {
      "text": this.text.trim(),
      "images": this._images,
      "announcement": this._adminAnnouncement
    });
  }

  @override
  void initState() {
    isAdmin = widget.isAdmin;
    _ctrl = TextEditingController();
    this._getUserDetails();
    super.initState();
    //Analytics tracking code
    amplitudeAnalytics.init(apiKey);
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () {
              text.isEmpty
                  ? Navigator.of(context).pop(context)
                  : showDialog(
                      context: context,
                      builder: (_) => PlatformAlertDialog(
                            title: Text("Discard New Post?"),
                            material: (_, __) => MaterialAlertDialogData(
                              elevation: 1.0,
                              actions: <Widget>[
                                TextButton(
                                  child: Text("Ok",
                                      style: TextStyle(
                                          color: AppColors
                                              .communityProfileOptionsBlueColor,
                                          fontWeight: FontWeight.w600)),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    Navigator.of(context).pop();
                                    // Routes.sailor.navigate("/feed",
                                    //     navigationType:
                                    //         NavigationType.pushAndRemoveUntil,
                                    //     removeUntilPredicate:
                                    //         (Route<dynamic> route) => false);
                                  },
                                ),
                                TextButton(
                                  child: Text("Cancel",
                                      style: TextStyle(
                                          color:
                                              Color.fromRGBO(255, 69, 58, 1))),
                                  onPressed: () {
                                    Navigator.of(context).pop(context);
                                    // Analytics tracking code
                                    analytics.setCurrentScreen(
                                        screenName: "my_feed",
                                        screenClassOverride: "my_feed");
                                    amplitudeAnalytics.logEvent("my_feed_page");
                                  },
                                )
                              ],
                            ),
                            cupertino: (_, __) =>
                                CupertinoAlertDialogData(actions: <Widget>[
                              CupertinoDialogAction(
                                child: Text("OK",
                                    style: TextStyle(
                                        color: AppColors
                                            .communityProfileOptionsBlueColor)),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  Navigator.of(context).pop();
                                  // Routes.sailor.navigate("/feed",
                                  //     navigationType:
                                  //         NavigationType.pushAndRemoveUntil,
                                  //     removeUntilPredicate:
                                  //         (Route<dynamic> route) => false);
                                },
                              ),
                              CupertinoDialogAction(
                                child: Text("Cancel",
                                    style: TextStyle(
                                        color: Color.fromRGBO(255, 69, 58, 1))),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  // Analytics tracking code
                                  analytics.setCurrentScreen(
                                      screenName: "my_feed",
                                      screenClassOverride: "my_feed");
                                  amplitudeAnalytics.logEvent("my_feed_page");
                                },
                              )
                            ]),
                          ),
                      barrierDismissible: false);
            }),
        backgroundColor: AppColors.yellowColor,
        title: Text("New Post"),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              "Cancel",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          )
        ],
      ),
      body: (this._loading)
          ? this._showLoading()
          : SafeArea(
              child: GestureDetector(
                onTap: () {
                  FocusScope.of(context).requestFocus(new FocusNode());
                },
                child: SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.all(8),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Container(
                          height: 80,
                          padding: EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: <Widget>[
                              (_user != null &&
                                      _user.imageUrl != null &&
                                      _user.imageUrl.isNotEmpty &&
                                      _user.imageUrl != "na")
                                  ? ClipRRect(
                                      borderRadius:
                                          BorderRadius.circular(100.0),
                                      child: _adminAnnouncement
                                          ? Container(
                                              width: 50,
                                              height: 50,
                                              child: Image.asset(
                                                  "assets/images/dark_logo.png"),
                                            )
                                          : CachedNetworkImage(
                                              width: 50,
                                              height: 50,
                                              fit: BoxFit.cover,
                                              imageUrl: _user?.imageUrl ??
                                                  "https://i.pinimg.com/564x/19/b8/d6/19b8d6e9b13eef23ec9c746968bb88b1.jpg",
                                              errorWidget:
                                                  (context, url, error) =>
                                                      Icon(Icons.error),
                                            ))
                                  : Icon(Icons.person, size: 35),
                              SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                  child: InkWell(
                                child: Text(
                                  _adminAnnouncement
                                      ? "Pure Match"
                                      : _user?.fullName ?? "",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700),
                                ),
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              CommunityProfile(
                                                userId: _user.id,
                                              )));
                                },
                              ))
                            ],
                          ),
                        ),
                        (_images.length > 0)
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(0.0),
                                child: Image.file(
                                  _images[0],
                                  fit: BoxFit.fill,
                                  height: 200,
                                ))
                            : Container(),
                        SizedBox(
                          height: 10,
                        ),
                        (_images.length > 1)
                            ? Container(
                                height: 150,
                                child: Scrollbar(
                                  child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: _images.length,
                                      itemBuilder: (context, i) {
                                        if (i == 0) return Container();
                                        return Container(
                                          padding: EdgeInsets.only(right: 5),
                                          child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(0.0),
                                              child: Image.file(
                                                _images[i],
                                                fit: BoxFit.fill,
                                                height: 200,
                                              )),
                                        );
                                      }),
                                ),
                              )
                            : Container(),
                        SizedBox(
                          height: 10,
                        ),
                        (showOptions)
                            ? Container(
                                height: 60,
                                child: ListView(
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(100.0),
                                            child: CachedNetworkImage(
                                              width: 40,
                                              imageUrl: _user?.imageUrl ??
                                                  "https://i.pinimg.com/564x/19/b8/d6/19b8d6e9b13eef23ec9c746968bb88b1.jpg",
                                              errorWidget:
                                                  (context, url, error) =>
                                                      Icon(Icons.error),
                                            )),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Expanded(
                                            child: InkWell(
                                          child: Text(_user?.fullName ?? ""),
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        CommunityProfile(
                                                          userId: _user.id,
                                                        )));
                                          },
                                        ))
                                      ],
                                    ),
                                    Row(
                                      children: <Widget>[
                                        ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(100.0),
                                            child: CachedNetworkImage(
                                              width: 40,
                                              imageUrl: _user?.imageUrl ??
                                                  "https://i.pinimg.com/564x/19/b8/d6/19b8d6e9b13eef23ec9c746968bb88b1.jpg",
                                              errorWidget:
                                                  (context, url, error) =>
                                                      Icon(Icons.error),
                                            )),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Expanded(
                                            child: InkWell(
                                          child: Text(_user?.fullName ?? ""),
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        CommunityProfile(
                                                          userId: _user.id,
                                                        )));
                                          },
                                        ))
                                      ],
                                    ),
                                    Row(
                                      children: <Widget>[
                                        ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(100.0),
                                            child: CachedNetworkImage(
                                              width: 40,
                                              imageUrl: _user?.imageUrl ??
                                                  "https://i.pinimg.com/564x/19/b8/d6/19b8d6e9b13eef23ec9c746968bb88b1.jpg",
                                              errorWidget:
                                                  (context, url, error) =>
                                                      Icon(Icons.error),
                                            )),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Expanded(
                                            child: InkWell(
                                          child: Text(_user?.fullName ?? ""),
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        CommunityProfile(
                                                          userId: _user.id,
                                                        )));
                                          },
                                        ))
                                      ],
                                    ),
                                  ],
                                ),
                              )
                            : Container(),
                        TextField(
                          textCapitalization: TextCapitalization.sentences,
                          controller: _ctrl,
                          maxLines: 8,
                          cursorColor: Colors.black,
                          onChanged: (val) {
                            this.text = val;
                            String trim = val.trim();

                            if (trim.length > 0) {
                              int start = trim.length - 2;
                              int end = trim.length - 1;
                              if (start < 0) start = 0;
                              if (trim.substring(start, end) == "@") {
                                showOptions = true;
                              }
                            }
                            setState(() {
                              this.text = val;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: "Write your message here",
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey[300]),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey[300]),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey[300]),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Container(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: InkWell(
                                onTap: () {
                                  // this._getImage();
                                  showCupertinoModalPopup(
                                    context: context,
                                    builder: (BuildContext context) =>
                                        CupertinoActionSheet(
                                      title: const Text('Select your option'),
                                      message: null,
                                      actions: <Widget>[
                                        CupertinoActionSheetAction(
                                          child: const Text('Take a photo'),
                                          onPressed: () {
                                            Navigator.pop(context, 'One');
                                            _getImageFromCamera();
                                          },
                                        ),
                                        CupertinoActionSheetAction(
                                          child: const Text('Open camera roll'),
                                          onPressed: () {
                                            Navigator.pop(context, 'Two');
                                            this._getImage();
                                          },
                                        )
                                      ],
                                    ),
                                  );
                                },
                                child: Icon(
                                  Icons.camera_alt,
                                  size: 36,
                                  color: Colors.black,
                                )),
                          ),
                        ),
                        Container(
                          child: Text(""),
                        ),
                        SizedBox(
                          height:
                              height * ((_images.length == 0) ? 0.20 : 0.05),
                        ),
                        Visibility(
                          visible: isAdmin,
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              "Admin Tools",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        Visibility(
                          visible: isAdmin,
                          child: Row(
                            children: [
                              Text(
                                "Announcement Post",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              Expanded(child: Container()),
                              Switch.adaptive(
                                  value: _adminAnnouncement,
                                  onChanged: (bool) {
                                    setState(() {
                                      _adminAnnouncement = bool;
                                    });
                                  }),
                            ],
                          ),
                        ),
                        SizedBox(
                            width: double.infinity,
                            child: Global.FlatButtonX(
                                childx: Text(
                                  _adminAnnouncement
                                      ? "Post as Announcement"
                                      : "Post to Feed",
                                  style: TextStyle(
                                    color: (this.text.trim().isNotEmpty ||
                                            this._images.isNotEmpty)
                                        ? Colors.white
                                        : Colors.black,
                                    fontWeight: (this.text.trim().isNotEmpty ||
                                            this._images.isNotEmpty)
                                        ? FontWeight.w700
                                        : FontWeight.w400,
                                    fontSize: 20,
                                  ),
                                ),
                                onPressedx: (this.text.trim().isNotEmpty ||
                                        this._images.isNotEmpty)
                                    ? this._post
                                    : null,
                                colorx: AppColors.blueColor,
                                textColorx: Colors.white,
                                shapex: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                disabledColorx: AppColors.greyColor,
                                disabledTextColorx: Colors.black,
                                paddingY: 12)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Container _showLoading() {
    analytics.setCurrentScreen(
        screenName: "new_post", screenClassOverride: "new_post");
    amplitudeAnalytics.logEvent("new_post_page");

    return Container(
      height: double.infinity,
      child: Center(
        child: PlatformCircularProgressIndicator(),
      ),
    );
  }
}
