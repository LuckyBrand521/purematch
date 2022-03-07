import 'package:flutter/material.dart';
import 'package:pure_match/common/RoundIndicators.dart';

/// This is the class to show the ico and the indicator on the login page.

class IconIndicator extends StatelessWidget {
  const IconIndicator(
      {Key key, this.imageAsset, this.currentIndicatorIndex = 0})
      : super(key: key);

  final String imageAsset;
  final int currentIndicatorIndex;
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Image.asset(this.imageAsset),
          SizedBox(
            height: 10,
          ),
          RoundIndicators(
            currentIndicatorIndex: this.currentIndicatorIndex,
            numberOfInidcators: 3,
          ),
        ],
      ),
    );
  }
}
