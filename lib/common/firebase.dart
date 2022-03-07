//
//
//
//import 'package:firebase_messaging/firebase_messaging.dart';
//import 'package:flutter/material.dart';
//import 'dart:io' show Platform;
//
//import 'package:pure_match/models/message.dart';
//
//import '../main.dart';
//import '../routes.dart';
//
//class FirebaseNotification extends StatefulWidget {
//  @override
//  _FirebaseNotificationState createState() => _FirebaseNotificationState();
//}
//
//class _FirebaseNotificationState extends State<FirebaseNotification> {
//  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
//  final List<Message> messages = [];
//  String _homeScreenText = "Waiting for token...";
//
//  @override
//  void initState() {
//    if (Platform.isAndroid) {
//      // Android-specific code
//
//      _firebaseMessaging.configure(
//        onMessage: (Map<String, dynamic> message) async {
//          print("onMessage: $message");
//          final notification = message['notification'];
//          final data = message['data'];
//
//          setState(() {
//            messages.add(Message(
//                title: notification['title'], body: notification['body'],id: data["id"]));
//          });
//        },
//        onLaunch: (Map<String, dynamic> message) async {
//          print("onLaunch: $message");
//          _navigateToItemDetail(message);
//
//          final notification = message['data'];
//          setState(() {
//            messages.add(Message(
//              title: '${notification['title']}',
//              body: '${notification['body']}',
//
//            ));
//
//
//          });
//        },
//        onResume: (Map<String, dynamic> message) async {
//          print("onResume: $message");
//          _navigateToItemDetail(message);
//        },
//      );
//      _firebaseMessaging.requestNotificationPermissions(
//        const IosNotificationSettings(sound: true,badge: true,alert: true)
//      );
//      _firebaseMessaging.getToken().then((String token) {
//        assert(token != null);
//        setState(() {
//          _homeScreenText = "Push Messaging token: \n\n $token";
//        });
//        print(_homeScreenText);
//      });
//
//
//
//    }
//      super.initState();
//
//  }
//  void _navigateToItemDetail(Map<String, dynamic> message) {
//    final String pagechooser= message['route'];
//   // Navigator.pushNamed(context, pagechooser);
//    print(pagechooser);
//    Routes.sailor.navigate(pagechooser);
//  }
//  @override
//  Widget build(BuildContext context) => Scaffold(
//    body: ListView(
//      children: messages.map(buildMessage).toList(),
//
//    ),
//  );
//
//  Widget buildMessage(Message message) => ListTile(
//    title: Text(message.title),
//    subtitle: Text(message.id.toString()),
//
//
//  );
//
//
//}
//
