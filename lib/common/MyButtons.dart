import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:icon_shadow/icon_shadow.dart';
import 'package:pure_match/pages/AppColors.dart';
import 'package:shadowed_image/shadowed_image.dart';

import 'global.dart';

class MyButtons {
  static Padding getBorderedButton(
      String name, Color buttonColor, Function f, bool fill,
      {double buttonWidth = double.infinity,
      double fontSize = 18,
      FontWeight fontWeight = FontWeight.bold,
      FontWeight unselectedButtonFontWt = FontWeight.w600,
      double borderRadius = 15.0,
      double verticalPadding = 20.0}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0.0),
      child: SizedBox(
        width: buttonWidth,
        child: FlatButton(
            onPressed: f,
            color: fill ? buttonColor : Colors.white,
            padding: EdgeInsets.symmetric(vertical: verticalPadding),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius),
                side: BorderSide(color: buttonColor, width: 2)),
            child: Text(
              name,
              style: TextStyle(
                  color: fill ? Colors.white : buttonColor,
                  fontSize: fontSize,
                  fontWeight: fill ? fontWeight : unselectedButtonFontWt),
              textAlign: TextAlign.center,
            )),
      ),
    );
  }

  static Padding getBorderedButton1(
      String name, Color buttonColor, Color txtColor, Function f, bool fill,
      {double buttonWidth = double.infinity,
      double fontSize = 18,
      FontWeight fontWeight = FontWeight.bold,
      FontWeight unselectedButtonFontWt = FontWeight.w600,
      double borderRadius = 15.0,
      double verticalPadding = 20.0}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: SizedBox(
        width: buttonWidth,
        child: GestureDetector(
          onTap: f,
          child: Container(
              padding: EdgeInsets.symmetric(vertical: verticalPadding),
              decoration: BoxDecoration(
                  color: fill ? buttonColor : Colors.white,
                  borderRadius: BorderRadius.circular(borderRadius),
                  border: Border.all(color: buttonColor, width: 2)),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  name,
                  style: TextStyle(
                      color: fill ? Colors.white : txtColor,
                      fontSize: fontSize,
                      fontWeight: fill ? fontWeight : unselectedButtonFontWt),
                  textAlign: TextAlign.start,
                ),
              )),
        ),
      ),
    );
  }

  static Padding getBorderedButton2(
      String name, Color buttonColor, Color txtColor, Function f, bool fill,
      {double buttonWidth = double.infinity,
      double fontSize = 14,
      FontWeight fontWeight = FontWeight.bold,
      FontWeight unselectedButtonFontWt = FontWeight.w600,
      double borderRadius = 10.0,
      double verticalPadding = 4.0}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: SizedBox(
        width: buttonWidth,
        child: GestureDetector(
          onTap: f,
          child: Container(
              padding: EdgeInsets.symmetric(vertical: verticalPadding),
              decoration: BoxDecoration(
                  color: fill ? buttonColor : Colors.white,
                  borderRadius: BorderRadius.circular(borderRadius),
                  border: Border.all(color: buttonColor, width: 2)),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  name,
                  style: TextStyle(
                      color: fill ? Colors.white : txtColor,
                      fontSize: fontSize,
                      fontWeight: fill ? fontWeight : unselectedButtonFontWt),
                  textAlign: TextAlign.center,
                ),
              )),
        ),
      ),
    );
  }

  static Expanded getActionButtons(
      int postId, int index, String text, Function onTap, bool selected) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
                (index == 0)
                    ? (selected)
                        ? "assets/images/heart_icon_filled.png"
                        : "assets/images/heart_icon.png"
                    : (index == 1)
                        ? "assets/images/comment_icon.png"
                        : "assets/images/share_icon.png",
                width: (index == 0 || index == 1) ? 20 : 18,
                height: (index == 0) ? 18 : 20,
                fit: BoxFit.contain),
            SizedBox(
              width: 10,
            ),
            Text(
              (selected && text == "Like") ? "Liked" : text,
              style: TextStyle(
                  color: (selected)
                      ? AppColors.yellowColor
                      : AppColors.offWhiteColor),
            )
          ],
        ),
      ),
    );
  }

  static Container getContainerForMatchCardWithImageIcon(
    int width,
    Function onTap,
    ImageIcon icon,
    Color iconColor,
    Color shadowColor,
  ) {
    return Container(
      width: width.toDouble(),
      height: width.toDouble(),
      child: IconButton(
        icon: icon,
        padding: EdgeInsets.all(0),
        onPressed: onTap,
      ),
    );
  }

  static Container getContainerForMatchCard(
    int width,
    Function onTap,
    IconData iconData,
    Color iconColor,
    Color shadowColor,
  ) {
    return Container(
      width: width.toDouble(),
      height: width.toDouble(),
      child: IconButton(
        icon: IconShadowWidget(
          Icon(
            iconData,
            color: iconColor,
          ),
          shadowColor: shadowColor,
        ),
        padding: EdgeInsets.all(0),
        onPressed: onTap,
      ),
    );
  }

  static PlatformIconButton getEditButton(
      Image iconData, Color color, Function onTap) {
    return PlatformIconButton(
      icon: ShadowedImage(
        image: iconData,
      ),
      onPressed: onTap,
    );
  }

  static InkWell getSettingsButton(
      String imgIcon, String text, Function onTap) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 10,
          ),
          Container(width: 30, child: Image.asset(imgIcon)),
          SizedBox(
            width: 25,
          ),
          Expanded(
            flex: 2,
            child: Text(
              text,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w400,
                fontStyle: FontStyle.normal,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(Icons.arrow_forward_ios, color: Colors.black, size: 25),
          ),
        ],
      ),
    );
  }

  //
}
