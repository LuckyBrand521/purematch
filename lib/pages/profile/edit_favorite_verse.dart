import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:pure_match/pages/AppColors.dart';
import 'package:pure_match/pages/profile/edit_content.dart';
import 'package:amplitude_flutter/amplitude.dart';

class EditFavoriteVerse extends StatefulWidget {
  final String _favVerse;

  EditFavoriteVerse(this._favVerse);
  @override
  _EditFavoriteVerseState createState() => _EditFavoriteVerseState();
}

class _EditFavoriteVerseState extends State<EditFavoriteVerse> {
  // Analytics code
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';

  String _favVerse;
  int _visibility = 0;
  String error = "";

  var _favVerseMeTxtCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _favVerse = widget._favVerse;
    _favVerseMeTxtCtrl.text = _favVerse;
    super.initState();
    // Analytics tracking code
    amplitudeAnalytics.init(apiKey);
    analytics.setCurrentScreen(
        screenName: "edit_favorite_verse",
        screenClassOverride: "edit_favorite_verse");
    amplitudeAnalytics.logEvent("edit_favorite_verse_page");
  }

  var borderSideProperty = BorderSide(color: AppColors.redColor, width: 1.5);

  @override
  Widget build(BuildContext context) {
    return EditContent(
        text: "Edit Favorite Verse",
        body: Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                          validator: (value) {
                            if (value.trim().isEmpty) {
                              return "Please enter about me";
                            }
                            return null;
                          },
                          controller: _favVerseMeTxtCtrl,
                          maxLengthEnforced: true,
                          maxLength: 150,
                          maxLines: 20,
                          onChanged: (String text) {
                            this._favVerse = text;
                          },
                          decoration: InputDecoration(
                            hintText: "Type here...",
                            focusedBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                borderSide: borderSideProperty),
                            enabledBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                borderSide: borderSideProperty),
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                borderSide: borderSideProperty),
                          )),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 25.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "Visibility",
                            style: TextStyle(fontSize: 24),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0, top: 10),
                            child: Row(
                              children: <Widget>[
                                SizedBox(
                                  width: 160,
                                  child: FlatButton(
                                      onPressed: () {
                                        setState(() {
                                          this._visibility = 0;
                                        });
                                      },
                                      color: (this._visibility == 0)
                                          ? AppColors.redColor
                                          : AppColors
                                              .profileEditVisibilityBt2BG,
                                      padding:
                                          EdgeInsets.symmetric(vertical: 10),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(10),
                                            bottomLeft: Radius.circular((10))),
                                      ),
                                      child: Text(
                                        "Everyone",
                                        style: TextStyle(
                                            color: (this._visibility == 0)
                                                ? Colors.white
                                                : AppColors.redColor,
                                            fontSize: 14,
                                            fontWeight: FontWeight.normal),
                                        textAlign: TextAlign.center,
                                      )),
                                ),
                                SizedBox(
                                  width: 160,
                                  child: FlatButton(
                                      onPressed: () {
                                        setState(() {
                                          this._visibility = 1;
                                        });
                                      },
                                      color: (this._visibility == 1)
                                          ? AppColors.redColor
                                          : AppColors
                                              .profileEditVisibilityBt2BG,
                                      padding:
                                          EdgeInsets.symmetric(vertical: 10),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(10),
                                            bottomRight: Radius.circular((10))),
                                      ),
                                      child: Text(
                                        "Only Matches",
                                        style: TextStyle(
                                            color: (this._visibility == 1)
                                                ? Colors.white
                                                : AppColors.redColor,
                                            fontSize: 14,
                                            fontWeight: FontWeight.normal),
                                        textAlign: TextAlign.center,
                                      )),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
