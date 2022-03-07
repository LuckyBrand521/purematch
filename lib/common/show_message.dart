import 'package:flutter/material.dart';

showMessage(
    {BuildContext context,
    String title,
    String content,
    VoidCallback onPressedClose}) {
  Widget continuaButton = TextButton(
    child: Text('Close'),
    onPressed: () {
      if (onPressedClose == null) {
        Navigator.pop(context);
      } else {
        onPressedClose();
      }
    },
  );

  AlertDialog alert = AlertDialog(
    title: Text(title),
    content: Text(content),
    actions: [
      continuaButton,
    ],
  );
  //exibe o diálogo
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

showMessageConfim(
    {BuildContext context,
    String title,
    String content,
    String textNoButton = 'No',
    String textYesButton = 'Yes',
    VoidCallback yesButton}) {
  Widget noButtonWidget = TextButton(
    onPressed: () async {
      Navigator.of(context).pop();
    },
    child: Text(
      'Confirm',
      style: TextStyle(color: Colors.blueGrey),
    ),
  );

  Widget yesButtonWidget = TextButton(
    onPressed: yesButton,
    child: Text(
      'Yes',
      style: TextStyle(color: Colors.white),
    ),
  );

  showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0)), //this right here
          child: Container(
            margin: EdgeInsets.all(20),
            height: 215,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text('Content',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor)),
                  ),
                  Divider(),
                  SizedBox(
                    height: 10,
                  ),
                  Text(content),
                  SizedBox(
                    height: 15,
                  ),
                  SizedBox(
                      width: 320.0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [noButtonWidget, yesButtonWidget],
                      ))
                ],
              ),
            ),
          ),
        );
      });
}
