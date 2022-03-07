import 'package:flutter/material.dart';

class SnackBarUi {
  static SnackBar SuccessSnackBar({String title = 'Success', String message}) {
    return SnackBar(
      content: SizedBox(
        height: 40,
        child: Row(
          children: [
            SizedBox(
              width: 6,
            ),            
            Icon(Icons.check_circle_outline, size: 32, color: Colors.white),
            SizedBox(
              width: 16,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                SizedBox(
                  height: 4,
                ),
                Text(message, style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),)
              ],
            )
          ],
        ),
      ),
      backgroundColor: Colors.blue,
      behavior: SnackBarBehavior.floating,
      elevation: 30,
      duration: Duration(seconds: 4),
      shape: RoundedRectangleBorder(
        side: BorderSide.none, borderRadius: BorderRadius.circular(10.0)), 
      margin: EdgeInsets.all(20),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),             
    );
  }

  static SnackBar ErrorSnackBar({String title = 'Error', String message}) {
    return SnackBar(
      content: SizedBox(
        height: 40,
        child: Row(
          children: [
            SizedBox(
              width: 6,
            ),               
            Icon(Icons.remove_circle_outline, size: 32, color: Colors.white),
            SizedBox(
              width: 16,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                SizedBox(
                  height: 4,
                ),
                Text(message, style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),)
              ],
            )
          ],
        ),
      ),
      backgroundColor: Colors.red,
      behavior: SnackBarBehavior.floating,
      elevation: 30,
      duration: Duration(seconds: 4),
      shape: RoundedRectangleBorder(
        side: BorderSide.none, borderRadius: BorderRadius.circular(10.0)), 
      margin: EdgeInsets.all(20),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),             
    );
  }
}
