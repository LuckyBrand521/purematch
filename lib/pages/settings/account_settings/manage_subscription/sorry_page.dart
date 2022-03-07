import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:pure_match/pages/AppColors.dart';
import 'package:pure_match/pages/settings/account_settings/manage_subscription/manage_subscription.dart';

class SorryPage extends StatefulWidget {
  @override
  _SorryPageState createState() => _SorryPageState();
}

class _SorryPageState extends State<SorryPage> {
  bool button1 = false;
  bool button2 = false;
  bool button3 = false;
  bool button4 = false;

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      backgroundColor: AppColors.blueColor,
      body: SafeArea(
        child: Scaffold(
          backgroundColor: AppColors.blueColor,
          body: Container(
            padding: EdgeInsets.only(left: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SizedBox(
                  height: 20.0,
                ),
                Text(
                  "We're sorry to \nsee you go!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.w700,
                      fontSize: 28.0,
                      color: Colors.white),
                ),
                SizedBox(
                  height: 10.0,
                ),
                Text(
                  "Please help us improve our service \nby telling us why you are cancelling \nyour subscription: ",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.w500,
                      fontSize: 20.0,
                      color: Colors.white),
                ),
                SizedBox(
                  height: 30.0,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 30.0),
                  child: Text(
                    "Select all that apply:",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        fontStyle: FontStyle.normal,
                        fontWeight: FontWeight.w600,
                        fontSize: 16.0,
                        color: Colors.white),
                  ),
                ),
                Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: 5.0, horizontal: 30.0),
                  child: FlatButton(
                    onPressed: () {
                      setState(() {
                        button1 = !button1;
                      });
                    },
                    color: button1 == true ? Colors.white : AppColors.blueColor,
                    padding: EdgeInsets.symmetric(vertical: 15.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      side: BorderSide(
                        color: Colors.white,
                      ),
                    ),
                    textColor:
                        button1 == true ? AppColors.blueColor : Colors.white,
                    child: Text(
                      "Too expensive",
                      style: TextStyle(
                        fontStyle: FontStyle.normal,
                        fontWeight:
                            button1 == true ? FontWeight.w700 : FontWeight.w500,
                        fontSize: 20.0,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: 5.0, horizontal: 30.0),
                  child: FlatButton(
                    onPressed: () {
                      setState(() {
                        button2 = !button2;
                      });
                    },
                    color: button2 == true ? Colors.white : AppColors.blueColor,
                    padding: EdgeInsets.symmetric(vertical: 15.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      side: BorderSide(
                        color: Colors.white,
                      ),
                    ),
                    textColor:
                        button2 == true ? AppColors.blueColor : Colors.white,
                    child: Text(
                      "Not enough value",
                      style: TextStyle(
                        fontStyle: FontStyle.normal,
                        fontWeight:
                            button2 == true ? FontWeight.w700 : FontWeight.w500,
                        fontSize: 20.0,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: 5.0, horizontal: 30.0),
                  child: FlatButton(
                    onPressed: () {
                      setState(() {
                        button3 = !button3;
                      });
                    },
                    color: button3 == true ? Colors.white : AppColors.blueColor,
                    padding: EdgeInsets.symmetric(vertical: 15.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      side: BorderSide(
                        color: Colors.white,
                      ),
                    ),
                    textColor:
                        button3 == true ? AppColors.blueColor : Colors.white,
                    child: Text(
                      "I don't need it",
                      style: TextStyle(
                        fontStyle: FontStyle.normal,
                        fontWeight:
                            button3 == true ? FontWeight.w700 : FontWeight.w500,
                        fontSize: 20.0,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: 5.0, horizontal: 30.0),
                  child: FlatButton(
                    onPressed: () {
                      setState(() {
                        button4 = !button4;
                      });
                    },
                    padding: EdgeInsets.symmetric(vertical: 15.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      side: BorderSide(
                        color: Colors.white,
                      ),
                    ),
                    textColor:
                        button4 == true ? AppColors.blueColor : Colors.white,
                    color: button4 == true ? Colors.white : AppColors.blueColor,
                    child: Text(
                      "Other",
                      style: TextStyle(
                        fontStyle: FontStyle.normal,
                        fontWeight:
                            button4 == true ? FontWeight.w700 : FontWeight.w500,
                        fontSize: 20.0,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 25.0,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 30.0),
                  child: Text(
                    "Add any additional comments:",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        fontStyle: FontStyle.normal,
                        fontWeight: FontWeight.w600,
                        fontSize: 16.0,
                        color: Colors.white),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: PlatformTextField(
                    material: (_, __) => MaterialTextFieldData(
                        decoration: InputDecoration(hintText: "Enter text..."),
                        maxLines: 7),
                    cupertino: (_, __) => CupertinoTextFieldData(
                        placeholder: "Enter text...", maxLines: 7),
                  ),
                ),
                SizedBox(
                  height: 30.0,
                ),
                Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: 5.0, horizontal: 30.0),
                  child: PlatformButton(
                    padding: EdgeInsets.symmetric(vertical: 15.0),
                    color: Colors.white,
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ManageSubscription()));
                    },
                    materialFlat: (_, __) => MaterialFlatButtonData(
                      child: Text(
                        "Back to Pure Match",
                        style: TextStyle(
                            fontSize: 20,
                            color: AppColors.blueColor,
                            fontWeight: FontWeight.w700,
                            fontStyle: FontStyle.normal),
                      ),
                    ),
                    cupertino: (_, __) => CupertinoButtonData(
                      child: Text(
                        "Back to Pure Match",
                        style: TextStyle(
                            fontSize: 20,
                            color: AppColors.blueColor,
                            fontWeight: FontWeight.w700,
                            fontStyle: FontStyle.normal),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
