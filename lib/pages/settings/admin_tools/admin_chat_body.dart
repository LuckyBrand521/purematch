import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:pure_match/pages/AppColors.dart';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart';
import 'package:pure_match/pages/MyHttp.dart';
import 'package:pure_match/pages/MyUrl.dart';
import 'package:pure_match/pages/messaging/chat_base_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:amplitude_flutter/amplitude.dart';
import 'package:pure_match/common/global.dart';

enum SubPage { Inquiries, Warnings }

class ChatPage extends StatefulWidget {
  final SubPage page;

  const ChatPage({Key key, @required this.page}) : super(key: key);
  @override
  _ChatPageState createState() => _ChatPageState();
}

class MessageData {
  int _chatId;
  int _userId;
  String _name;
  String _message;
  String _time;
  String _photoUrl;
  int _unreadMessages;
  String status;
  bool isTyping = false;

  MessageData(this._chatId, this._userId, this._name, this._message, this._time,
      this._photoUrl, this._unreadMessages, this.status,
      {this.isTyping});

  set message(String value) {
    _message = value;
  }

  set unreadMessages(int i) {
    _unreadMessages = i;
  }

  set time(String time) {
    _time = time;
  }

  int get chatId => _chatId;

  int get unreadMessages => _unreadMessages;

  String get photoUrl => _photoUrl;

  String get time => _time;

  String get message => _message;

  String get name => _name;

  int get userId => _userId;
}

class _ChatPageState extends State<ChatPage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  // Analytics code
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';

  TabController _tabController;

  List<MessageData> msgs = List();

  Socket socket;
  String filter = "";

  void _connectSocket() async {
    var sp = await SharedPreferences.getInstance();
    var token = sp.getString("token");
    int id = sp.getInt("id");
    print("ID is $id");
    socket = io(MyUrl.url("/"), <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'extraHeaders': {'token': token} // optional
    });
    socket.connect();
    socket.on("connect", (_) {
      print("Socket connected");
      var data = {"userId": id};
      var jsonData = json.encode(data);
      socket.emit("join", jsonData);
      socket.on("new-message", (data) {
        print(data);
        var gotData = data;
        int gotUserId = gotData["UserId"];
        bool typing = gotData["typing"];
        print(gotUserId);
        if (gotUserId == id) return;
        for (int i = 0; i < msgs.length; i++) {
          MessageData md = msgs[i];
          if (md == null) {
            print("Md is nulll ===================");
            continue;
          }
          if (md.userId == gotUserId) {
            setState(() {
              md.isTyping = typing;
            });
            break;
          }
        }
      });
      socket.on("new-message", (data) {
        print(data);
        var gotData = data;
        int gotUserId = gotData["UserId"];
        print(gotUserId);
        if (gotUserId == id) return;
        setState(() {
          for (int i = 0; i < msgs.length; i++) {
            MessageData md = msgs[i];
            if (md == null) {
              print("Md is nulll ===================");
              continue;
            }
            if (md.userId == gotUserId) {
              var now = DateTime.now().toLocal();
              md.time = Global.createdAt(now.toString());
              md.message = gotData["text"] as String;
              md.unreadMessages = md._unreadMessages + 1;
              break;
            }
          }
          msgs.sort((a, b) {
            return -a.time.compareTo(b.time);
          });
        });
      });
    });

    socket.on("error", (E) {
      print("Socket Error: $E");
    });
  }

  void _getChats() async {
    List<MessageData> allMessages = List();
    Response res;
    if (widget.page == SubPage.Inquiries)
      res = await MyHttp.get("/admin/inquiries");
    else {
      res = await MyHttp.get("/admin/warnings");
    }
    if (res.statusCode == 200) {
      var body = json.decode(res.body);
      print(body);
      var chats;
      if (widget.page == SubPage.Warnings) {
        chats = body["warnings"] as List<dynamic>;
      } else {
        chats = body["inquiries"] as List<dynamic>;
      }
      if (chats != null) {
        allMessages = chats.map((c) {
          print("8************");
          print(c);
          String name, time, message, photoUrl;
          int chatId, unreadMessage, userId = 0;
          var users = c["Users"];
          if (users == null) {
            print("****@@!@!@");
            print(users);
            //TODO: Warnings may need to be changed for Inquires
            if (widget.page == SubPage.Warnings) {
              users = c["warnings"]["Users"];
            } else {
              users = c["inquiries"]["Users"];
            }
          }
          var user = users[0];
          chatId = c["id"];
          if (chatId == 0 || chatId == null) chatId = c["Chat"]["id"];
          if (c["unreadMessage"] != null)
            unreadMessage = int.tryParse(c["unreadMessage"] ?? 0);
          if (user != null) {
            name = user["first_name"];
            userId = user["id"];
            var upload = user["ProfilePicture"];
            if (upload != null) {
              photoUrl = upload["path"];
            }
            var messageObj = c["Messages"] as List<dynamic>;
            print(messageObj);
            if (messageObj != null && messageObj.length > 0) {
              message = messageObj[0]["text"];
              var createdAt = DateTime.parse(messageObj[0]["createdAt"]);
              createdAt = createdAt.toLocal();
              time = Global.createdAt(createdAt.toString());
            }
          }
          String status = c["status"];
          return MessageData(chatId, userId, name, message, time, photoUrl,
              unreadMessage, status);
        }).toList();
        if (allMessages.length > 0 &&
            allMessages[0] != null &&
            allMessages[0].time != null)
          allMessages.sort((a, b) {
            return -a.time.compareTo(b.time);
          });
        allMessages.insert(0, null);
        print("EEEEE: ${allMessages.length}");
      }
    } else {
      print("Error: ${res.statusCode}");
    }
    setState(() {
      msgs = allMessages;
    });
  }

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    this._getChats();
    this._connectSocket();
    WidgetsBinding.instance.addObserver(this);
    super.initState();

    //Initializing amplitude api key
    amplitudeAnalytics.init(apiKey);
  }

  @override
  void dispose() {
    _tabController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    socket.disconnect();
    socket.destroy();
    super.dispose();
  }

  @override
  void deactivate() {
    print("DEEEA=====================================");
    super.deactivate();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      print("RESUMEDDD");
      this._getChats();
    }
//    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView.builder(
          itemCount: msgs.length,
          itemBuilder: (context, index) {
            MessageData msgData = msgs[index];
            if (index == 0)
              return Container(
                height: 50,
                padding:
                    const EdgeInsets.symmetric(vertical: 6.25, horizontal: 15),
                child: TextField(
                  cursorColor: Colors.black,
                  onChanged: (String f) {
                    setState(() {
                      filter = f;
                    });
                  },
                  decoration: InputDecoration(
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                      hintText: "Search",
                      hintStyle: TextStyle(
                        color: AppColors.adminSBHintText,
                      ),
                      fillColor: AppColors.searchBarColor,
                      filled: true,
                      focusedBorder: new OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.transparent, width: 0),
                          borderRadius: const BorderRadius.all(
                            const Radius.circular(10.0),
                          )),
                      enabledBorder: new OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.transparent, width: 0),
                          borderRadius: const BorderRadius.all(
                            const Radius.circular(10.0),
                          )),
                      border: new OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.transparent, width: 0),
                        borderRadius: const BorderRadius.all(
                          const Radius.circular(10.0),
                        ),
                      )),
                ),
              );
            if (filter.trim().isNotEmpty) {
              if (!msgData._name
                  .toLowerCase()
                  .startsWith(filter.trim().toLowerCase())) {
                return Container();
              }
            }
            return Container(
              child: ListTile(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ChatBasePage(
                                  userId: msgData.userId,
                                  chatId: msgData.chatId,
                                  otherUserName: msgData.name,
                                  status: msgData.status,
                                ))).then((_) {
                      this._getChats();
                    });
                    //Analytics tracking code
                    analytics.setCurrentScreen(
                        screenName: "chat_user",
                        screenClassOverride: "chat_user");
                    amplitudeAnalytics.logEvent("chat_user_page");
                  },
                  leading: ClipRRect(
                      borderRadius: BorderRadius.circular(100.0),
                      child: CachedNetworkImage(
                        imageUrl: msgData.photoUrl ??
                            "https://i.pinimg.com/564x/19/b8/d6/19b8d6e9b13eef23ec9c746968bb88b1.jpg",
                        errorWidget: (context, url, error) => Icon(Icons.error),
                      )),
                  title: Text(
                    msgData.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.normal,
                      color: AppColors.greyColor,
                    ),
                  ),
                  subtitle: Text(
                    msgData.message ?? "Attachment",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.normal,
                      color: AppColors.greyColor,
                    ),
                  ),
                  trailing: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        msgData.time ?? "",
                        style:
                            TextStyle(fontSize: 12, color: AppColors.greyColor),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      (msgData.unreadMessages == 0 ||
                              msgData.unreadMessages == null)
                          ? Container(
                              width: 20,
                            )
                          : Container(
                              height: 20,
                              width: 20,
                              decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                      begin: Alignment.topRight,
                                      end: Alignment.bottomLeft,
                                      colors: [
                                        Color(0xFFed7260),
                                        Color(0xFFec3f5a)
                                      ]),
                                  borderRadius: BorderRadius.circular(8.0)),
                              child: Center(
                                  child: Text(
                                msgData.unreadMessages.toString(),
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              )),
                            ),
                    ],
                  )),
            );
          }),
    );
  }
}
