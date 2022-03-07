import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import '../AppColors.dart';

class EditContent extends StatelessWidget {
  final String text;
  final Widget body;

  const EditContent({Key key, @required this.text, @required this.body})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
        appBar: PlatformAppBar(
          material: (_, __) => MaterialAppBarData(
            backgroundColor: AppColors.offWhiteColor,
            leading: IconButton(
              icon: Icon(
                Icons.clear,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            title: Text(this.text,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontStyle: FontStyle.normal,
                    fontFamily: "Roboto",
                    fontSize: 24)),
            actions: [
              FlatButton(
                child: Text("Save",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontStyle: FontStyle.normal,
                        fontFamily: "Roboto",
                        fontSize: 20)),
              )
            ],
          ),
          cupertino: (_, __) => CupertinoNavigationBarData(
            backgroundColor: AppColors.offWhiteColor,
            leading: CupertinoButton(
                child: Icon(Icons.clear, color: Colors.white),
                onPressed: () {
                  Navigator.pop(context);
                }),
            title: Text(this.text,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontStyle: FontStyle.normal,
                    fontFamily: "Roboto",
                    fontSize: 24)),
            trailing: FlatButton(
              child: Text("Save",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontStyle: FontStyle.normal,
                      fontFamily: "Roboto",
                      fontSize: 20)),
            ),
          ),
        ),
        body: body);
  }
}
