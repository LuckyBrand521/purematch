import 'package:flutter/material.dart';
import 'package:pure_match/pages/AppColors.dart';

class RoundIndicators extends StatelessWidget {
  RoundIndicators(
      {Key key,
      this.currentIndicatorIndex = 0,
      this.numberOfInidcators = 3,
      this.bubbleColor = AppColors.blueColor,
      this.disableBubbleColor = Colors.white,
      this.borderColor,
      this.circleSize = 10})
      : super(key: key);

  int currentIndicatorIndex;
  int numberOfInidcators;
  double circleSize;
  Color bubbleColor;
  Color disableBubbleColor;
  Color borderColor;

  @override
  Widget build(BuildContext context) {
    List<Widget> circles = [];
    for (var i = 0; i < this.numberOfInidcators; i++) {
      circles.add(_getCircle(i));
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: circles,
    );
  }

  Padding _getCircle(int i) {
    return Padding(
      padding: const EdgeInsets.only(right: 4.0),
      child: Container(
        height: this.circleSize,
        width: this.circleSize,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: this.borderColor ?? this.bubbleColor),
            color: this.currentIndicatorIndex == i
                ? this.bubbleColor
                : this.disableBubbleColor),
      ),
    );
  }
}
