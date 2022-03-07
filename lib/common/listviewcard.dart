import 'package:flutter/material.dart';
import 'package:pure_match/common/global.dart';
import 'package:pure_match/pages/AppColors.dart';

class ListViewCard extends StatefulWidget {
  final int index;
  final Key key;
  final List<String> listItems;

  ListViewCard(this.listItems, this.index, this.key);

  @override
  _ListViewCardState createState() => _ListViewCardState();
}

class _ListViewCardState extends State<ListViewCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      margin: EdgeInsets.all(2),
      color: Colors.white,
      child: InkWell(
        splashColor: Colors.blue,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    alignment: Alignment.topLeft,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          '${widget.listItems[widget.index]}',
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize:
                                  AppConfig.fontsizeForSmallDevice(context, 24),
                              color: AppColors.blueColor),
                          textAlign: TextAlign.center,
                          maxLines: 5,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
              child: Icon(
                Icons.reorder,
                color: Colors.black,
                size: 30.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
