import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:pure_match/pages/AppColors.dart';
import 'package:pure_match/pages/MyHttp.dart';
import 'dart:convert';
import 'package:pure_match/pages/settings/settings_navigator.dart';
import 'package:amplitude_flutter/amplitude.dart';
import 'dart:io' show Platform;

enum Role { Admin, Moderator, Coach }
enum Choices { Admin, Moderator, Coach }

class AddAdmin extends StatefulWidget {
  final Role role;

  const AddAdmin({Key key, @required this.role}) : super(key: key);
  @override
  _AddAdminState createState() => _AddAdminState();
}

class _AddAdminState extends State<AddAdmin> {
  // Analytics code
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';

  String filter = "";
  var list = [];
  List<Choices> choice = [
    Choices.Admin,
    Choices.Moderator,
    Choices.Coach,
  ];
  int androidIndex = 0;
  Role androidRole = Role.Admin;

  void addedOrRemovedAlert(
      BuildContext context, Role newRole, bool removed, int index) {
    if (Platform.isIOS) {
      if (!removed) {
        if (newRole == Role.Admin) {
          showCupertinoDialog(
              context: context,
              builder: (context) {
                return CupertinoAlertDialog(
                  title: Text("Admin Added"),
                  content: Text(
                    "This user is now an Admin.",
                    style: TextStyle(height: 1.5),
                  ),
                  actions: <Widget>[
                    FlatButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        "Close",
                        style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                            fontSize: 20),
                      ),
                    )
                  ],
                );
              });
        } else if (newRole == Role.Moderator) {
          showCupertinoDialog(
              context: context,
              builder: (context) {
                return CupertinoAlertDialog(
                  title: Text("Moderator Added"),
                  content: Text(
                    "This user is now a Moderator.",
                    style: TextStyle(height: 1.5),
                  ),
                  actions: <Widget>[
                    FlatButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        "Close",
                        style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                            fontSize: 20),
                      ),
                    )
                  ],
                );
              });
        } else {
          showCupertinoDialog(
              context: context,
              builder: (context) {
                return CupertinoAlertDialog(
                  title: Text("Coach Added"),
                  content: Text(
                    "This user is now a Coach.",
                    style: TextStyle(height: 1.5),
                  ),
                  actions: <Widget>[
                    FlatButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        "Close",
                        style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                            fontSize: 20),
                      ),
                    )
                  ],
                );
              });
        }
      } else {
        if (newRole == Role.Admin) {
          showCupertinoDialog(
              context: context,
              builder: (context) {
                return CupertinoAlertDialog(
                  title: Text("Admin Removed"),
                  content: Text("This user is no longer an Admin."),
                  actions: <Widget>[
                    FlatButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        "Close",
                        style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                            fontSize: 20),
                      ),
                    )
                  ],
                );
              });
        } else if (newRole == Role.Moderator) {
          showCupertinoDialog(
              context: context,
              builder: (context) {
                return CupertinoAlertDialog(
                  title: Text("Moderator Removed"),
                  content: Text("This user is no longer a Moderator."),
                  actions: <Widget>[
                    FlatButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        "Close",
                        style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                            fontSize: 20),
                      ),
                    )
                  ],
                );
              });
        } else {
          showCupertinoDialog(
              context: context,
              builder: (context) {
                return CupertinoAlertDialog(
                  title: Text("Coach Removed"),
                  content: Text("This user is no longer a Coach."),
                  actions: <Widget>[
                    FlatButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        "Close",
                        style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                            fontSize: 20),
                      ),
                    )
                  ],
                );
              });
        }
      }
    } else {
      if (!removed) {
        if (newRole == Role.Admin) {
          showCupertinoDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text("Admin Added"),
                  content: Text(
                    "This user is now an Admin.",
                    style: TextStyle(height: 1.5),
                  ),
                  actions: <Widget>[
                    FlatButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        "Close",
                        style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                            fontSize: 20),
                      ),
                    )
                  ],
                );
              });
        } else if (newRole == Role.Moderator) {
          showCupertinoDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text("Moderator Added"),
                  content: Text(
                    "This user is now a Moderator.",
                    style: TextStyle(height: 1.5),
                  ),
                  actions: <Widget>[
                    FlatButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        "Close",
                        style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                            fontSize: 20),
                      ),
                    )
                  ],
                );
              });
        } else {
          showCupertinoDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text("Coach Added"),
                  content: Text(
                    "This user is now a Coach.",
                    style: TextStyle(height: 1.5),
                  ),
                  actions: <Widget>[
                    FlatButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        "Close",
                        style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                            fontSize: 20),
                      ),
                    )
                  ],
                );
              });
        }
      } else {
        if (newRole == Role.Admin) {
          showCupertinoDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text("Admin Removed"),
                  content: Text("This user is no longer an Admin."),
                  actions: <Widget>[
                    FlatButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        "Close",
                        style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                            fontSize: 20),
                      ),
                    )
                  ],
                );
              });
        } else if (newRole == Role.Moderator) {
          showCupertinoDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text("Moderator Removed"),
                  content: Text("This user is no longer a Moderator."),
                  actions: <Widget>[
                    FlatButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        "Close",
                        style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                            fontSize: 20),
                      ),
                    )
                  ],
                );
              });
        } else {
          showCupertinoDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text("Coach Removed"),
                  content: Text("This user is no longer a Coach."),
                  actions: <Widget>[
                    FlatButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        "Close",
                        style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                            fontSize: 20),
                      ),
                    )
                  ],
                );
              });
        }
      }
    }
  }

  void assignAlert(BuildContext context, Role newRole, Role currentRole,
      bool remove, int index) {
    if (Platform.isIOS) {
      showCupertinoDialog(
          context: context,
          builder: (context) {
            if (!remove) {
              if (newRole == Role.Admin) {
                return CupertinoAlertDialog(
                  title: Text("Assign as Admin?"),
                  content: Text(
                    "Are you sure you want to give this user Admin privileges?",
                    style: TextStyle(height: 1.5),
                  ),
                  actions: <Widget>[
                    CupertinoDialogAction(
                      onPressed: () {
                        assignApiCall(newRole, currentRole, index);
                        Navigator.of(context).pop();
                        addedOrRemovedAlert(context, newRole, remove, index);

                        //Analytics tracking code
                        analytics.logEvent(
                            name: "added_admin",
                            parameters: <String, dynamic>{
                              "previous_role": "user",
                              "new_role": newRole.toString().substring(
                                    5,
                                  ),
                              "id": list[index]["id"]
                            });

                        amplitudeAnalytics
                            .logEvent("added_admin", eventProperties: {
                          "previous_role": "user",
                          'chat_id': newRole.toString().substring(
                                5,
                              ),
                          "id": list[index]["id"]
                        });
                      },
                      child: Text(
                        "Assign as Admin",
                        style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                            fontSize: 20),
                      ),
                    ),
                    CupertinoDialogAction(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w500,
                            fontSize: 20),
                      ),
                    )
                  ],
                );
              } else if (newRole == Role.Moderator) {
                return CupertinoAlertDialog(
                  title: Text("Assign as Moderator?"),
                  content: Text(
                    "Are you sure you want to give this user Moderator privileges?",
                    style: TextStyle(height: 1.5),
                  ),
                  actions: <Widget>[
                    CupertinoDialogAction(
                      onPressed: () {
                        assignApiCall(newRole, currentRole, index);
                        Navigator.of(context).pop();
                        addedOrRemovedAlert(context, newRole, remove, index);

                        //Analytics tracking code
                        analytics.logEvent(
                            name: "added_moderator",
                            parameters: <String, dynamic>{
                              "previous_role": "user",
                              "new_role": newRole.toString().substring(
                                    5,
                                  ),
                              "id": list[index]["id"]
                            });

                        amplitudeAnalytics
                            .logEvent("added_moderator", eventProperties: {
                          "previous_role": "user",
                          "new_role": newRole.toString().substring(
                                5,
                              ),
                          "id": list[index]["id"]
                        });
                      },
                      child: Text(
                        "Assign as Moderator",
                        style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                            fontSize: 20),
                      ),
                    ),
                    CupertinoDialogAction(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w500,
                            fontSize: 20),
                      ),
                    )
                  ],
                );
              } else {
                return CupertinoAlertDialog(
                  title: Text("Assign as Coach?"),
                  content: Text(
                    "Are you sure you want to give this user Coach privileges?",
                    style: TextStyle(height: 1.5),
                  ),
                  actions: <Widget>[
                    CupertinoDialogAction(
                      onPressed: () {
                        assignApiCall(newRole, currentRole, index);
                        Navigator.of(context).pop();
                        addedOrRemovedAlert(context, newRole, remove, index);

                        //Analytics tracking code
                        analytics.logEvent(
                            name: "added_coach",
                            parameters: <String, dynamic>{
                              "previous_role": "user",
                              "new_role": newRole.toString().substring(
                                    5,
                                  ),
                              "id": list[index]["id"]
                            });

                        amplitudeAnalytics
                            .logEvent("added_coach", eventProperties: {
                          "previous_role": "user",
                          "new_role": newRole.toString().substring(
                                5,
                              ),
                          "id": list[index]["id"]
                        });
                      },
                      child: Text(
                        "Assign as Coach",
                        style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                            fontSize: 20),
                      ),
                    ),
                    CupertinoDialogAction(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w500,
                            fontSize: 20),
                      ),
                    )
                  ],
                );
              }
            } else {
              if (currentRole == Role.Admin) {
                return CupertinoAlertDialog(
                  title: Text("Remove from Admins?"),
                  content: Text(
                      "Are you sure you want to remove this user's Admin privileges?"),
                  actions: <Widget>[
                    CupertinoDialogAction(
                      onPressed: () {
                        Navigator.of(context).pop();
                        addedOrRemovedAlert(
                            context, currentRole, remove, index);

                        //Analytics tracking code
                        analytics.logEvent(
                            name: "removed_admin",
                            parameters: <String, dynamic>{
                              "previous_role": "admin",
                              "new_role": "user",
                              "id": list[index]["id"]
                            });

                        amplitudeAnalytics.logEvent("removed_admin",
                            eventProperties: {
                              "previous_role": "admin",
                              "new_role": "user",
                              "id": list[index]["id"]
                            });
                      },
                      child: Text(
                        "Remove Admin",
                        style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                            fontSize: 20),
                      ),
                    ),
                    CupertinoDialogAction(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w500,
                            fontSize: 20),
                      ),
                    )
                  ],
                );
              } else if (currentRole == Role.Moderator) {
                return CupertinoAlertDialog(
                  title: Text("Remove from Moderators?"),
                  content: Text(
                      "Are you sure you want to remove this user's Moderator privileges"),
                  actions: <Widget>[
                    CupertinoDialogAction(
                      onPressed: () {
                        Navigator.of(context).pop();
                        addedOrRemovedAlert(
                            context, currentRole, remove, index);
                        //Analytics tracking code
                        analytics.logEvent(
                            name: "removed_moderator",
                            parameters: <String, dynamic>{
                              "previous_role": currentRole.toString().substring(
                                    5,
                                  ),
                              "new_role": "user",
                              "id": list[index]["id"]
                            });

                        amplitudeAnalytics
                            .logEvent("removed_moderator", eventProperties: {
                          "previous_role": currentRole.toString().substring(
                                5,
                              ),
                          "new_role": "user",
                          "id": list[index]["id"]
                        });
                      },
                      child: Text(
                        "Remove Moderator",
                        style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                            fontSize: 20),
                      ),
                    ),
                    CupertinoDialogAction(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w500,
                            fontSize: 20),
                      ),
                    )
                  ],
                );
              } else {
                return CupertinoAlertDialog(
                  title: Text("Remove from Coaches?"),
                  content: Text(
                      "Are you sure you want to remove this user's Coach privileges"),
                  actions: <Widget>[
                    CupertinoDialogAction(
                      onPressed: () {
                        Navigator.of(context).pop();
                        addedOrRemovedAlert(
                            context, currentRole, remove, index);

                        //Analytics tracking code
                        analytics.logEvent(
                            name: "removed_coach",
                            parameters: <String, dynamic>{
                              "previous_role": currentRole.toString().substring(
                                    5,
                                  ),
                              "new_role": "user",
                              "id": list[index]["id"]
                            });

                        amplitudeAnalytics
                            .logEvent("removed_coach", eventProperties: {
                          "previous_role": currentRole.toString().substring(
                                5,
                              ),
                          "new_role": "user",
                          "id": list[index]["id"]
                        });
                      },
                      child: Text(
                        "Remove Coach",
                        style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                            fontSize: 20),
                      ),
                    ),
                    CupertinoDialogAction(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w500,
                            fontSize: 20),
                      ),
                    )
                  ],
                );
              }
            }
          });
    } else {
      showDialog(
          context: context,
          builder: (context) {
            if (!remove) {
              if (newRole == Role.Admin) {
                return AlertDialog(
                  title: Text("Assign as Admin?"),
                  content: Text(
                    "Are you sure you want to give this user Admin privileges?",
                    style: TextStyle(height: 1.5),
                  ),
                  actions: <Widget>[
                    FlatButton(
                      onPressed: () {
                        assignApiCall(newRole, currentRole, index);
                        Navigator.of(context).pop();
                        addedOrRemovedAlert(context, newRole, remove, index);

                        //Analytics tracking code
                        analytics.logEvent(
                            name: "added_admin",
                            parameters: <String, dynamic>{
                              "previous_role": "user",
                              "new_role": newRole.toString().substring(
                                    5,
                                  ),
                              "id": list[index]["id"]
                            });

                        amplitudeAnalytics
                            .logEvent("added_admin", eventProperties: {
                          "previous_role": "user",
                          "new_role": newRole.toString().substring(
                                5,
                              ),
                          "id": list[index]["id"]
                        });
                      },
                      child: Text(
                        "Assign as Admin",
                        style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                            fontSize: 20),
                      ),
                    ),
                    FlatButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w500,
                            fontSize: 20),
                      ),
                    )
                  ],
                );
              } else if (newRole == Role.Moderator) {
                return AlertDialog(
                  title: Text("Assign as Moderator?"),
                  content: Text(
                    "Are you sure you want to give this user Moderator privileges?",
                    style: TextStyle(height: 1.5),
                  ),
                  actions: <Widget>[
                    FlatButton(
                      onPressed: () {
                        assignApiCall(newRole, currentRole, index);
                        Navigator.of(context).pop();
                        addedOrRemovedAlert(context, newRole, remove, index);

                        //Analytics tracking code
                        analytics.logEvent(
                            name: "added_moderator",
                            parameters: <String, dynamic>{
                              "previous_role": "user",
                              "new_role": newRole.toString().substring(
                                    5,
                                  ),
                              "id": list[index]["id"]
                            });

                        amplitudeAnalytics
                            .logEvent("added_moderator", eventProperties: {
                          "previous_role": "user",
                          "new_role": newRole.toString().substring(
                                5,
                              ),
                          "id": list[index]["id"]
                        });
                      },
                      child: Text(
                        "Assign as Moderator",
                        style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                            fontSize: 20),
                      ),
                    ),
                    FlatButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w500,
                            fontSize: 20),
                      ),
                    )
                  ],
                );
              } else {
                return AlertDialog(
                  title: Text("Assign as Coach?"),
                  content: Text(
                    "Are you sure you want to give this user Coach privileges?",
                    style: TextStyle(height: 1.5),
                  ),
                  actions: <Widget>[
                    FlatButton(
                      onPressed: () {
                        assignApiCall(newRole, currentRole, index);
                        Navigator.of(context).pop();
                        addedOrRemovedAlert(context, newRole, remove, index);
                        //Analytics tracking code
                        analytics.logEvent(
                            name: "added_coach",
                            parameters: <String, dynamic>{
                              "previous_role": "user",
                              "new_role": newRole.toString().substring(
                                    5,
                                  ),
                              "id": list[index]["id"]
                            });

                        amplitudeAnalytics
                            .logEvent("added_coach", eventProperties: {
                          "previous_role": "user",
                          "new_role": newRole.toString().substring(
                                5,
                              ),
                          "id": list[index]["id"]
                        });
                      },
                      child: Text(
                        "Assign as Coach",
                        style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                            fontSize: 20),
                      ),
                    ),
                    FlatButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w500,
                            fontSize: 20),
                      ),
                    )
                  ],
                );
              }
            } else {
              if (currentRole == Role.Admin) {
                return AlertDialog(
                  title: Text("Remove from Admins?"),
                  content: Text(
                      "Are you sure you want to remove this user's Admin privileges?"),
                  actions: <Widget>[
                    FlatButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        addedOrRemovedAlert(
                            context, currentRole, remove, index);
                        //Analytics tracking code
                        analytics.logEvent(
                            name: "removed_admin",
                            parameters: <String, dynamic>{
                              "previous_role": "admin",
                              "new_role": "user",
                              "id": list[index]["id"]
                            });

                        amplitudeAnalytics.logEvent("removed_admin",
                            eventProperties: {
                              "previous_role": "admin",
                              "new_role": "user",
                              "id": list[index]["id"]
                            });
                      },
                      child: Text(
                        "Remove Admin",
                        style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                            fontSize: 20),
                      ),
                    ),
                    FlatButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w500,
                            fontSize: 20),
                      ),
                    )
                  ],
                );
              } else if (currentRole == Role.Moderator) {
                return AlertDialog(
                  title: Text("Remove from Moderators?"),
                  content: Text(
                      "Are you sure you want to remove this user's Moderator privileges"),
                  actions: <Widget>[
                    FlatButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        addedOrRemovedAlert(
                            context, currentRole, remove, index);
                        //Analytics tracking code
                        analytics.logEvent(
                            name: "removed_moderator",
                            parameters: <String, dynamic>{
                              "previous_role": currentRole.toString().substring(
                                    5,
                                  ),
                              "new_role": "user",
                              "id": list[index]["id"]
                            });

                        amplitudeAnalytics
                            .logEvent("removed_moderator", eventProperties: {
                          "previous_role": currentRole.toString().substring(
                                5,
                              ),
                          "new_role": "user",
                          "id": list[index]["id"]
                        });
                      },
                      child: Text(
                        "Remove Moderator",
                        style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                            fontSize: 20),
                      ),
                    ),
                    FlatButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w500,
                            fontSize: 20),
                      ),
                    )
                  ],
                );
              } else {
                return AlertDialog(
                  title: Text("Remove from Coaches?"),
                  content: Text(
                      "Are you sure you want to remove this user's Coach privileges"),
                  actions: <Widget>[
                    FlatButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        addedOrRemovedAlert(
                            context, currentRole, remove, index);
                        //Analytics tracking code
                        analytics.logEvent(
                            name: "removed_coach",
                            parameters: <String, dynamic>{
                              "previous_role": currentRole.toString().substring(
                                    5,
                                  ),
                              "new_role": "user",
                              "id": list[index]["id"]
                            });

                        amplitudeAnalytics
                            .logEvent("removed_coach", eventProperties: {
                          "previous_role": currentRole.toString().substring(
                                5,
                              ),
                          "new_role": "user",
                          "id": list[index]["id"]
                        });
                      },
                      child: Text(
                        "Remove Coach",
                        style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                            fontSize: 20),
                      ),
                    ),
                    FlatButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w500,
                            fontSize: 20),
                      ),
                    )
                  ],
                );
              }
            }
          });
    }
  }

  void assignApiCall(Role newRole, Role currentRole, int index) async {
    if (newRole == Role.Admin) {
      int id = list[index]["id"];
      var res = await MyHttp.put(
          "admin/assign/admin", {"userId": id, "role": "Admin"});
    } else if (newRole == Role.Moderator) {
      int id = list[index]["id"];
      var res = await MyHttp.put(
          "admin/assign/admin", {"userId": id, "role": "Moderator"});
    } else {
      int id = list[index]["id"];
      var res = await MyHttp.put(
          "admin/assign/admin", {"userId": id, "role": "Coach"});
    }
  }

  List<Widget> _actionSheetActionSelector(
      BuildContext context, Role role, int index) {
    if (Platform.isIOS) {
      List<Widget> list = [];
      list.add(CupertinoActionSheetAction(
        onPressed: () {
          Navigator.of(context).pop();
          assignAlert(context, Role.Admin, role, false, index);
        },
        child: Text("Assign as Admin"),
      ));
      list.add(CupertinoActionSheetAction(
        onPressed: () {
          Navigator.of(context).pop();
          assignAlert(context, Role.Moderator, role, false, index);
        },
        child: Text("Assign as Moderator"),
      ));
      list.add(CupertinoActionSheetAction(
        onPressed: () {
          Navigator.of(context).pop();
          assignAlert(context, Role.Coach, role, false, index);
        },
        child: Text("Assign as Coach"),
      ));
      return list;
    } else {
      List<PopupMenuItem<Choices>> list = [];
      list.add(const PopupMenuItem<Choices>(
        value: Choices.Admin,
        child: Text("Assign as Admin"),
      ));
      list.add(const PopupMenuItem<Choices>(
        value: Choices.Moderator,
        child: Text("Assign as Moderator"),
      ));
      list.add(const PopupMenuItem<Choices>(
        value: Choices.Coach,
        child: Text("Assign as Coach"),
      ));
      return list;
    }
  }

  void actionSheet(BuildContext context, String title, Role role, int index) {
    showCupertinoModalPopup(
        context: context,
        builder: (context) {
          return CupertinoActionSheet(
            title: Text(title),
            cancelButton: CupertinoActionSheetAction(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
            actions: _actionSheetActionSelector(context, role, index),
          );
        });
  }

  void _actionSheetAndroid(dynamic choice) {
    if (choice == Choices.Admin) {
      assignAlert(context, Role.Admin, androidRole, false, androidIndex);
    } else if (choice == Choices.Moderator) {
      assignAlert(context, Role.Moderator, androidRole, false, androidIndex);
    } else if (choice == Choices.Coach) {
      assignAlert(context, Role.Coach, androidRole, false, androidIndex);
    } else {
      assignAlert(context, Role.Admin, androidRole, true, androidIndex);
    }
  }

  Future<dynamic> _searchAdmins() async {
    var res = await MyHttp.post("admin/search-users", {"searchQuery": filter});
    var json = jsonDecode(res.body);
    var users;
    users = json["admins"] as List<dynamic>;
    list = users;
    _getList();
    return list;
  }

  String _getName(List list, int index) {
    return list[index]["first_name"] + " " + list[index]["last_name"];
  }

  String _getFirstName(List list, int index) {
    return list[index]["first_name"];
  }

  String _getImage(List list, int index) {
    return list[index]["ProfilePictureId"];
  }

  String _getDate(List list, int index) {
    String date = list[index]["createdAt"].substring(0, 10);
    String year = date.substring(0, 4);
    String month = date.substring(5, 7);
    String day = date.substring(8, 10);
    return " $month/$day/$year";
  }

  @override
  void initState() {
    super.initState();
    _searchAdmins();
    //Analytics code
    amplitudeAnalytics.init(apiKey);
    //Analytics tracking code
    analytics.setCurrentScreen(
        screenName: "add_admin", screenClassOverride: "add_admin");
    amplitudeAnalytics.logEvent("add_admin_page");
  }

  Widget _getList() {
    List<Widget> list = [];
    if (filter.trim().isNotEmpty) {
      for (int i = 0; i < this.list.length; i++) {
        list.add(ListTile(
          contentPadding: EdgeInsets.only(right: 0),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(100.0),
            child: _getImage(this.list, i) == null
                ? Image(
                    image: AssetImage("assets/images/Pure_Match_Draft_5.png"),
                  )
                : Image(
                    image: NetworkImage(
                      _getImage(this.list, i),
                    ),
                  ),
          ),
          trailing: Platform.isIOS == true
              ? IconButton(
                  onPressed: () {
                    actionSheet(
                        context,
                        "Admin - " + _getFirstName(this.list, i),
                        Role.Admin,
                        i);
                    //Analytics code
                    analytics.setCurrentScreen(
                        screenName: "manage_admin",
                        screenClassOverride: "manage_admin");
                    amplitudeAnalytics.logEvent("manage_admin_page");
                  },
                  icon: Icon(
                    Icons.more_horiz,
                    size: 40,
                    color: Colors.white,
                  ),
                )
              : PopupMenuButton(
                  icon: Icon(
                    Icons.more_horiz,
                    color: AppColors.greyColor,
                  ),
                  onSelected: _actionSheetAndroid,
                  itemBuilder: (BuildContext context) {
                    androidIndex = i;
                    androidRole = Role.Admin;
                    return _actionSheetActionSelector(context, Role.Admin, i);
                  },
                ),
          title: Text(
            _getName(this.list, i),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              fontStyle: FontStyle.normal,
              color: AppColors.greyColor,
            ),
          ),
          subtitle: Text(
            "Member since" + _getDate(this.list, i),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              fontStyle: FontStyle.normal,
              color: AppColors.greyColor,
            ),
          ),
        ));
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: list,
      );
    } else {
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _searchAdmins(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return PlatformScaffold(
            backgroundColor: AppColors.adminBlackHeader,
            //bottomNavBar: HomePage(),
            appBar: PlatformAppBar(
              material: (_, __) => MaterialAppBarData(
                backgroundColor: AppColors.adminBlackHeader,
                elevation: 0.0,
                leading: MaterialButton(
                  onPressed: () {},
                  child: IconButton(
                    icon: Icon(Icons.arrow_back),
                    color: Colors.white,
                    onPressed: () {
                      Navigator.pop(context);
                      //Analytic tracking code
                      analytics.setCurrentScreen(
                          screenName: "manage_admin",
                          screenClassOverride: "manage_admin");
                      amplitudeAnalytics.logEvent("manage_admin_page");
                    },
                  ),
                ),
                actions: <Widget>[
                  MaterialButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SettingsNavigator(
                                    tabIndex: 2,
                                  )));
                    },
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 10.0, 0),
                      child: Image(
                        image:
                            AssetImage("assets/images/Pure_Match_Draft_5.png"),
                      ),
                    ),
                  )
                ],
                title: Text(
                  "Add an Admin ",
                  style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontStyle: FontStyle.normal,
                      fontFamily: 'Avenir Next'),
                ),
              ),
              cupertino: (_, __) => CupertinoNavigationBarData(
                automaticallyImplyLeading: false,
                automaticallyImplyMiddle: false,
                backgroundColor: AppColors.adminBlackHeader,
                leading: MaterialButton(
                  onPressed: () {},
                  child: IconButton(
                    icon: Icon(Icons.arrow_back_ios),
                    color: Colors.white,
                    onPressed: () {
                      Navigator.pop(context);
                      //Analytics tracking code
                      analytics.setCurrentScreen(
                          screenName: "manage_admin",
                          screenClassOverride: "manage_admin");
                      amplitudeAnalytics.logEvent("manage_admin_page");
                    },
                  ),
                ),
                trailing: MaterialButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SettingsNavigator(
                                  tabIndex: 2,
                                )));
                  },
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 10.0, 0),
                    child: Image(
                      image: AssetImage("assets/images/Pure_Match_Draft_5.png"),
                    ),
                  ),
                ),
                title: Text(
                  "Add an Admin",
                  style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontStyle: FontStyle.normal,
                      fontFamily: 'Avenir Next'),
                ),
                padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 10.0),
              ),
            ),
            body: SafeArea(
              child: Scaffold(
                backgroundColor: AppColors.adminBlackBackground,
                body: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                        child: TextField(
                          cursorColor: Colors.white,
                          onChanged: (String f) {
                            setState(() {
                              filter = f;
                              _searchAdmins();
                            });
                          },
                          style: TextStyle(color: AppColors.adminSBHintText),
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 0, horizontal: 20),
                              prefixIcon: Icon(
                                Icons.search,
                                size: 20,
                                color: AppColors.adminSBHintText,
                              ),
                              hintText: "Search for a user...",
                              hintStyle: TextStyle(
                                color: AppColors.adminSBHintText,
                              ),
                              fillColor: AppColors.searchBarColor,
                              filled: true,
                              focusedBorder: new OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.transparent, width: 0),
                                  borderRadius: const BorderRadius.all(
                                    const Radius.circular(10.0),
                                  )),
                              enabledBorder: new OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.transparent, width: 0),
                                  borderRadius: const BorderRadius.all(
                                    const Radius.circular(10.0),
                                  )),
                              border: new OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.transparent, width: 0),
                                borderRadius: const BorderRadius.all(
                                  const Radius.circular(10.0),
                                ),
                              )),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      list == null ? Container() : _getList(),
                    ],
                  ),
                ),
              ),
            ),
          );
        } else {
          return Container();
        }
      },
    );
  }
}
