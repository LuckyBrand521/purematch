import 'dart:convert';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:amplitude_flutter/amplitude.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:http/http.dart';
import 'package:pure_match/common/loading.dart';
import 'package:pure_match/pages/AppColors.dart';
import 'package:pure_match/pages/MyHttp.dart';
import 'package:pure_match/pages/MyUrl.dart';
import 'package:pure_match/pages/messaging/chat_base_page.dart';
import 'package:pure_match/pages/messaging/group_chat_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:pure_match/common/global.dart';

enum MessageOf { All, Matches, Friends }

class MessagePage extends StatefulWidget {
  // For message PN
  int userId;
  int chatId;
  String status;
  String otherUserName;
  String messageType;
  // For message PN end

  final MessageOf messageOf;
  final Key key;
  final Function(int) onChangedUnreadChatCount;
  MessagePage({
    @required this.key,
    @required this.messageOf,
    @required this.onChangedUnreadChatCount,
    this.userId,
    this.chatId,
    this.status,
    this.otherUserName,
    this.messageType,
  }) : super(key: key);
  @override
  _MessagePageState createState() => _MessagePageState(key: key);
}

class MessageData {
  int _chatId;
  int _userId;
  String _name;
  String _message;
  String _mediaId;
  String _time;
  String _photoUrl;
  int _unreadMessages;
  String status;
  String _type;
  String _groupName;
  bool isTyping = false;

  MessageData(
      this._chatId,
      this._userId,
      this._name,
      this._message,
      this._mediaId,
      this._time,
      this._groupName,
      this._type,
      this._photoUrl,
      this._unreadMessages,
      this.status,
      {this.isTyping});

  set message(String value) {
    _message = value;
  }

  set mediaId(String value) {
    _mediaId = value;
  }

  set groupName(String name) {
    _groupName = name;
  }

  set unreadMessages(int i) {
    _unreadMessages = i;
  }

  set type(String value) {
    _type = value;
  }

  set time(String time) {
    _time = time;
  }

  int get chatId => _chatId;

  int get unreadMessages => _unreadMessages;

  String get photoUrl => _photoUrl;

  String get type => _type;

  String get time => _time;

  String get groupName => _groupName;

  String get message => _message;

  String get mediaId => _mediaId;

  String get name => _name;

  int get userId => _userId;
}

class _MessagePageState extends State<MessagePage>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  List<MessageData> msgs = List();

  // Analytics code
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';

  Socket socket;
  String filter = "";
  TabController _tabController;
  bool _loading = false;

  final Key key;

  _MessagePageState({this.key});

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
        print("*******************");
        print(gotUserId.toString());
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
            return -a.time?.compareTo(b.time);
          });
        });
      });
    });

    socket.on("error", (E) {
      print("Socket Error: $E");
    });
  }

  void _checkFromPN() {
    if (widget.messageType == null || widget.messageType.length == 0) {
      return;
    }
    if (widget.messageType == "Group") {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => GroupChatPage(
                      newGroup: false,
                      chatId: widget.chatId,
                      title: widget.otherUserName,
                      status: widget.status,
                    )))
          ..then((_) {
            this._getChats();
          });
      });
    } else if (widget.messageType == "DM") {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        // add your code here.
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ChatBasePage(
                      userId: widget.userId,
                      chatId: widget.chatId,
                      otherUserName: widget.otherUserName,
                      status: widget.status,
                    ))).then((_) {
          this._getChats();
        });
      });
    }
  }

  _getUnreadChat() async {
    try {
      var res = await MyHttp.get("/chat/unread/all");
      if (res.statusCode == 200) {
        var jsonData = jsonDecode(res.body);
        print(jsonData);
        if (jsonData["numberOfChats"] != null) {
          int unreadChats = jsonData["numberOfChats"];
          if (unreadChats != Global.unreadChatsCount) {
            Global.unreadChatsCount = unreadChats;
            widget.onChangedUnreadChatCount(1);
          }
        } else {
          if (Global.unreadChatsCount != 0) {
            Global.unreadChatsCount = 0;
            widget.onChangedUnreadChatCount(1);
          }
        }
      } else {
        print(res.statusCode);
      }
    } catch (e) {
      print("Err $e");
    }
  }

  void _removeChat(MessageData msgData, int index) async {
    try {
      var res = await MyHttp.delete("/chat/${msgData.chatId}");

      print(res.statusCode);
      print(res.body);
      if (res.statusCode == 200) {
        this.msgs.removeAt(index);
        setState(() {});
      }
      print(res.statusCode);
      print(res.body);
    } catch (e) {
      print(e);
    }
  }

  void _getChats() async {
    _getUnreadChat();
    setState(() {
      _loading = true;
    });
    List<MessageData> allMessages = List();
    Response res;
    print("Getting chats");
    if (widget.messageOf == MessageOf.All)
      res = await MyHttp.get("/users/chats");
    else if (widget.messageOf == MessageOf.Friends)
      res = await MyHttp.get("/friends/chats");
    else {
      res = await MyHttp.get("/matches/chats");
    }
    if (res.statusCode == 200) {
      var body = json.decode(res.body);
      print(body);
      var chats = body["chats"] as List<dynamic>;
      if (chats != null) {
        allMessages = chats.map((c) {
          // print("8************");
          // print(c);
          String name, time, message, mediaId, photoUrl, groupName, type;
          int chatId, unreadMessage, userId = 0;
          var users = c["Users"];
          if (users == null) {
            print("****@@!@!@");
            print(users);
            users = c["Chat"]["Users"];
          }
          print("******888888");
          print(users);
          var user = users[0];
          chatId = c["id"];
          type = c["type"];
          print("**type and group name**");
          groupName = c["group_name"];
          print(type);
          print(groupName);

          if (chatId == 0 || chatId == null) chatId = c["Chat"]["id"];
          if (c["unreadMessage"] != null)
            unreadMessage = int.tryParse(c["unreadMessage"] ?? 0);
          if (user != null) {
            name = user["first_name"];

            userId = user["id"];
            if (type != "Group") {
              var upload = user["ProfilePicture"];
              if (upload != null) {
                photoUrl = upload["path"];
              }
            } else {
              photoUrl = c["img_path"];
            }
            var messageObj = c["Messages"] as List<dynamic>;
            print(messageObj);
            if (messageObj != null && messageObj.length > 0) {
              message = messageObj[0]["text"];
              mediaId = messageObj[0]["mediaId"];
              var createdAt = DateTime.parse(messageObj[0]["createdAt"]);
              createdAt = createdAt.toLocal();
              time = Global.createdAt(createdAt.toString());
            }
          }
          String status = c["status"];
          print("the name $name");
          return MessageData(chatId, userId, name, message, mediaId, time,
              groupName, type, photoUrl, unreadMessage, status);
        }).toList();
        if (allMessages.length > 0 && allMessages[0] != null)
          // &&
          // allMessages[0].time != null)
//        allMessages.sort((a, b) {
//          return -a.time.compareTo(b.time);
//        });
          allMessages.insert(0, null);
        print("EEEEE: ${allMessages}");
      }
    } else {
      print("Error: ${res.statusCode}");
    }

    setState(() {
      msgs = allMessages;
      _loading = false;
    });
  }

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    this._getChats();
    this._connectSocket();
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    _checkFromPN();
    //Initializing amplitude analytics api key
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
    super.deactivate();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      this._getChats();
    }
    print("RESUMEDDD");

//    super.didChangeAppLifecycleState(state);
  }

  Container _searchTextField() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 6.25, horizontal: 15),
      child: TextField(
        textCapitalization: TextCapitalization.words,
        cursorColor: Colors.black,
        onChanged: (String f) {
          setState(() {
            filter = f;
            // Analytic tracking code
            //TODO confirm this is logging correctly
            MessageData msgData = msgs[0];

            analytics.logEvent(
                name: "searched_messages",
                parameters: <String, dynamic>{
                  "userId": msgData.userId.toString(),
                  "term": msgData
                });

            amplitudeAnalytics.logEvent("searched_messages", eventProperties: {
              'userId': msgData.userId.toString(),
              'term': msgData
            });
          });
        },
        decoration: InputDecoration(
            prefixIcon: Icon(Icons.search),
            contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
            hintText: "Search",
            fillColor: AppColors.greyColor,
            filled: true,
            focusedBorder: new OutlineInputBorder(
                borderSide: BorderSide(color: Colors.transparent, width: 0),
                borderRadius: const BorderRadius.all(
                  const Radius.circular(10.0),
                )),
            enabledBorder: new OutlineInputBorder(
                borderSide: BorderSide(color: Colors.transparent, width: 0),
                borderRadius: const BorderRadius.all(
                  const Radius.circular(10.0),
                )),
            border: new OutlineInputBorder(
              borderSide: BorderSide(color: Colors.transparent, width: 0),
              borderRadius: const BorderRadius.all(
                const Radius.circular(10.0),
              ),
            )),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return (_loading == true)
        ? Loading.showLoading()
        : Container(
            child: (msgs.isEmpty)
                ? Column(
                    children: [
                      this._searchTextField(),
                      SizedBox(
                        height: 30,
                      ),
                      Text(
                        "You have no messages.",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w500),
                      ),
                      SizedBox(
                        height: 50,
                      ),
                      Text(
                        "Quick Tip: Pure Match will never message you \nasking for account information.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w100),
                      )
                    ],
                  )
                : ListView.builder(
                    itemCount: msgs.length,
                    itemBuilder: (context, index) {
                      MessageData msgData = msgs[index];
                      if (index == 0) return this._searchTextField();
                      if (filter.trim().isNotEmpty) {
                        if (!msgData._name
                            .toLowerCase()
                            .startsWith(filter.trim().toLowerCase())) {
                          return Container();
                        }
                      }
                      return Slidable(
                        actionPane: SlidableDrawerActionPane(),
                        actionExtentRatio: 0.25,
                        child: ListTile(
                          onTap: () {
                            (msgData.type == "Group")
                                ? Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => GroupChatPage(
                                              title: msgData.groupName,
                                              chatId: msgData.chatId,
                                              newGroup: false,
                                              status: msgData.status,
                                            ))).then((_) {
                                    this._getChats();
                                  })
                                : Navigator.push(
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
                          },
                          leading: Container(
                            width: 50,
                            height: 50,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(100.0),
                              child: (msgData.photoUrl != null &&
                                      msgData.photoUrl.isNotEmpty &&
                                      msgData.photoUrl != "na")
                                  ? CachedNetworkImage(
                                      fit: BoxFit.cover,
                                      imageUrl: msgData.photoUrl,
                                      errorWidget: (context, url, error) =>
                                          Icon(Icons.error),
                                    )
                                  : Icon(Icons.person, size: 50),
                            ),
                          ),
                          title: (msgData.type == "Group")
                              ? Text(
                                  msgData.groupName,
                                  style: (msgData.unreadMessages == 0 ||
                                          msgData.unreadMessages == null)
                                      ? TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.blackColor)
                                      : TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.blackColor),
                                )
                              : Text(
                                  msgData.name,
                                  style: (msgData.unreadMessages == 0 ||
                                          msgData.unreadMessages == null)
                                      ? TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.blackColor)
                                      : TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.blackColor),
                                ),
                          subtitle: Text(
                            (msgData.message != null)
                                ? msgData.message
                                : (msgData.mediaId != null)
                                    ? "Attachment"
                                    : "Start the Conversation!",
                            style: (msgData.unreadMessages == 0 ||
                                    msgData.unreadMessages == null)
                                ? TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.blackColor)
                                : TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.blackColor),
                          ),
                          trailing: Column(
                            children: <Widget>[
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                msgData.time ?? "",
                                style: TextStyle(
                                    fontSize: 12, color: AppColors.blackColor),
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
                                          borderRadius:
                                              BorderRadius.circular(8.0)),
                                      child: Center(
                                          child: Text(
                                        msgData.unreadMessages.toString(),
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      )),
                                    ),
                            ],
                          ),
                        ),
                        secondaryActions: <Widget>[
                          SizedBox(
                            width: 50,
                            child: new IconSlideAction(
                              caption: 'Delete',
                              color: AppColors.listviewRemoveColor,
                              icon: Icons.delete,
                              onTap: () {
                                _removeChat(msgData, index);
                              },
                            ),
                          ),
                        ],
                      );
                    }),
          );
  }
}
