import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pure_match/common/MyButtons.dart';
import 'package:pure_match/common/global.dart';
import 'package:pure_match/pages/rewards/plan.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../AppColors.dart';

class LimitReachedCard extends StatefulWidget {
  final int startTime;
  final Function endTime;
  LimitReachedCard({this.startTime, this.endTime});
  @override
  _LimitReachedCardState createState() => _LimitReachedCardState();
}

class _LimitReachedCardState extends State<LimitReachedCard> {
  Timer _timer;
  int _start = 10;

  String _getTimerCount() {
    int hour = _start ~/ 3600;
    int min = (_start - 3600 * hour) ~/ 60;
    int sec = (_start - 3600 * hour - 60 * min).toInt();
    String sHour = (hour >= 10) ? hour.toString() : "0" + hour.toString();
    String sMin = (min >= 10) ? min.toString() : "0" + min.toString();
    String sSec = (sec >= 10) ? sec.toString() : "0" + sec.toString();
    return "${sHour}:${sMin}:${sSec}";
  }

  _cancelTimer() async {
    _timer.cancel();
    var sp = await SharedPreferences.getInstance();

    sp.remove("match_count");
    sp.remove("match_time");
    Global.match_count1 = 0;
    if (this.mounted) {
      widget.endTime();
    }
  }

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_start == 0) {
          _cancelTimer();
        } else {
          if (this.mounted) {
            setState(() {
              _start--;
            });
          }
        }
      },
    );
  }

  @override
  void initState() {
    super.initState();

    _start = widget.startTime;
    startTimer();
  }

  @override
  void dispose() {
    if (_timer != null) {
      _timer.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 5,
      child: Container(
        padding: EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              "Limit reached",
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: AppColors.redColor),
            ),
            MyButtons.getBorderedButton2(
              "Upgrade to\nPremium",
              AppColors.matchBrowseMatchReactivateMatching,
              Colors.white,
              () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => Plan()));
              },
              true,
            ),
            Text(
              "or check back in\n${_getTimerCount()}",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.matchTimerColor,
              ),
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
  }
}
