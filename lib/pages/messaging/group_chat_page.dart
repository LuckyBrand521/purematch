import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pure_match/common/triangle.dart';
import 'package:pure_match/models/chat_bubble_data.dart';
import 'package:pure_match/models/chat_image_data.dart';
import 'package:pure_match/models/group_user.dart';
import 'package:pure_match/models/user.dart';
import 'package:pure_match/pages/AppColors.dart';
import 'package:pure_match/pages/MyHttp.dart';
import 'package:pure_match/pages/MyUrl.dart';
import 'package:pure_match/pages/messaging/add_member_group.dart';
import 'package:pure_match/pages/messaging/group_members.dart';
import 'package:pure_match/pages/messaging/message_base_page.dart';
import 'package:pure_match/pages/messaging/time_divider_algo.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:amplitude_flutter/amplitude.dart';
import 'package:http/http.dart' as http;
import 'dart:io' show Platform;
import 'package:http_parser/http_parser.dart';

class GroupChatPage extends StatefulWidget {
  final List<String> names;
  final String
      status; // this is the chat status if the user is allowed to chat or not.
  String title;

  final int chatId;
  bool newGroup;

  String newUser;
  bool memberAdded;

  bool groupPhotoChanged;
  GroupChatPage(
      {Key key,
      this.names,
      this.chatId,
      this.newGroup,
      this.groupPhotoChanged,
      this.status,
      this.title,
      this.newUser,
      this.memberAdded}) {
    this.newGroup = newGroup ?? false;
    this.groupPhotoChanged = groupPhotoChanged ?? false;
    this.newUser = newUser;
    this.memberAdded = memberAdded ?? false;

    this.title = title;
  }

  @override
  _GroupChatPageState createState() => _GroupChatPageState();
}

class _GroupChatPageState extends State<GroupChatPage> {
  // Analytics code
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';

  String title;
  String newGroupName;
  static final validCharacters = RegExp(r'^[a-zA-Z0-9&%=]+$');
  int userId;
  List<GroupUser> _groupUsers;
  List<int> _groupUserIds;
  List<ChatBubbleData> _messages;
  TextEditingController textEditingController = TextEditingController();
  ScrollController scrollController;

  // this is to check if the user is typing or not
  bool _isCurrentUserTyping = false;
  String userProfilePic;
  String otherUserProfilePic;

  bool enableButton = false;
  String dayHeader;
  Socket socket;

  bool loading = false;
  int topMessageId = -1;
  int _dataPage = 1;
  double width;
  var currentedDate;
  DateTime lastMessageDateTime;

  bool deleteMode = false;
  List<int> selectedDeleteMessages = [];

  Future<String> _getUserProfileById(int id) async {
    print("Statusssssss7890: ${widget.status}");
    if (id == 0 || id == null) {
      print("_getUserProfileById: id is null or 0.: $id}");
      return null;
    }
    try {
      var res = await MyHttp.get("/users/user/$id");
      if (res.statusCode == 200) {
        if (res.body != null) {
          var body = json.decode(res.body);
          if (body != null) {
            var pp = body["user"]["ProfilePictureId"];

            return pp;
          }
        }
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  void _getUserImages() async {
    if (userId == 0 || userId == null) {
      var sp = await SharedPreferences.getInstance();
      int id = sp.getInt("id");

      userId = id;
      print(userId);
    }
    userProfilePic = await this._getUserProfileById(userId);
    //TODO:add profile picture of the user
    //  await this._getUserProfileById(_groupUserIds[0])??
    otherUserProfilePic =
        "https://i.pinimg.com/564x/19/b8/d6/19b8d6e9b13eef23ec9c746968bb88b1.jpg";

    setState(() {});
  }

//  createdAt: 2020-08-20T22:28:15.102Z
  void _getMessages() async {
    topMessageId = -1;
    var res = await MyHttp.get("/chat/${widget.chatId}/messages/$_dataPage");
    if (res.statusCode == 200) {
      var body = json.decode(res.body);

      if (body != null) {
        var messages = body["latestMessages"] as List<dynamic>;
        if (messages != null && messages.length > 0) {
          for (var i = 0; i < messages.length; i++) {
            if (topMessageId == -1) {
              topMessageId = messages[i]["id"];
            }
            String text = messages[i]["text"];
            String path = MyUrl.chatImageUrl(messages[i]["mediaId"]);
            int suggestedId = messages[i]["suggestedId"];
            String suggested_name = messages[i]["suggested_name"];
            String suggested_photo_id = messages[i]["suggested_photo_id"];
            String date = messages[i]["createdAt"];
            String type = messages[i]["type"];
            DateTime msgdate = DateTime.parse(date);

            var cid = ChatImageData(path, null, false);
            int otherUserId = messages[i]["UserId"];
            if (userId == 0 || userId == null) {
              var sp = await SharedPreferences.getInstance();
              userId = sp.getInt("id");
            }
            bool reverse = false;
            if (userId == otherUserId) reverse = true;
            int messageId = messages[i]["id"];
            if (_dataPage == 1) {
              setState(() {
                _messages.add(ChatBubbleData(
                    messageId,
                    text,
                    cid,
                    reverse,
                    msgdate,
                    suggestedId,
                    suggested_name,
                    suggested_photo_id,
                    type));
              });
              scrollController.animateTo(
                  scrollController.position.maxScrollExtent,
                  curve: Curves.ease,
                  duration: Duration(milliseconds: 500));
            } else {
              setState(() {
                _messages.insert(
                    i,
                    ChatBubbleData(messageId, text, cid, reverse, msgdate,
                        suggestedId, suggested_name, suggested_photo_id, type));
              });
            }
          }
          if (_dataPage == 1)
            Future.delayed(Duration(milliseconds: 100), () {
              scrollController.animateTo(
                  scrollController.position.maxScrollExtent,
                  curve: Curves.ease,
                  duration: Duration(milliseconds: 500));
            });

          if (messages.length == 25)
            _dataPage++;
          else
            _dataPage = -1;
        }
      }
    } else {
      print("ERWRGEFSDA");
    }
    setState(() {
      loading = false;
    });
  }

  void handleSendMessage() async {
    if (userId == 0 || userId == null) {
      var sp = await SharedPreferences.getInstance();
      userId = sp.getInt("id");
    }
    var text = textEditingController.value.text;

    if (socket.connected) {
      var data = {
        "ChatId": widget.chatId,
        "UserId": userId,
        "text": text,
        "recipientId": _groupUserIds
      };

      var jsonData = json.encode(data);

      socket.emit("send-group-message", jsonData);
      //Analytics code
      analytics.logEvent(name: 'messaged_group', parameters: <String, dynamic>{
        "chat_id": widget.chatId.toString(),
        'user_id': userId
      });
      amplitudeAnalytics.logEvent("messaged_group", eventProperties: {
        "chat_id": widget.chatId.toString(),
        'user_id': userId
      });
    }
    textEditingController.clear();

    setState(() {
//      _messages.add(
//          ChatBubbleData(-1, text, ChatImageData(null, null, false), true));
      enableButton = false;
    });

    await Future.delayed(Duration(milliseconds: 100), () {
      scrollController.animateTo(scrollController.position.maxScrollExtent,
          curve: Curves.ease, duration: Duration(milliseconds: 500));
    });
  }

  void _sendTyping(bool typing) async {
    if (userId == 0 || userId == null) {
      var sp = await SharedPreferences.getInstance();
      userId = sp.getInt("id");
    }
    if (socket.connected) {
      var data = {
        "ChatId": widget.chatId,
        "UserId": userId,
        "typing": typing,
        "recipientId": _groupUserIds
      };
      var jsonData = json.encode(data);

      socket.emit("is-typing", jsonData);
    }
  }

  void _deleteMessages() async {
    if (userId == 0 || userId == null) {
      var sp = await SharedPreferences.getInstance();
      userId = sp.getInt("id");
    }
    if (socket.connected) {
      var data = {
        "UserId": userId,
        "ids": selectedDeleteMessages,
        "recipientId": _groupUserIds,
        "ChatId": widget.chatId,
      };
      var jsonData = json.encode(data);
      socket.emit("delete", jsonData);
      setState(() {
        this.selectedDeleteMessages.clear();
        deleteMode = false;
      });
    }
  }

  void _connectSocket() async {
    var sp = await SharedPreferences.getInstance();
    var token = sp.getString("token");

    socket = io(MyUrl.url("/"), <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'extraHeaders': {'token': token} // optional
    });

    socket.connect();
    socket.on("connect", (_) {
      print("Socket connected");
      var data = {"chatId": widget.chatId};
      var jsonData = json.encode(data);
      socket.emit("subscribe", jsonData);
      socket.on("deleted-message", (data) {
        var gotData = data;
        List<dynamic> messageIds = gotData["ids"];
        if (messageIds != null && messageIds.length > 0) {
          setState(() {
            for (var m in _messages) {
              if (messageIds.contains(m.id)) {
                m.text = "**This message has been deleted by the user.**";
              }
            }
          });
        }
      });
      socket.on("new-message", (data) {
        var gotData = data;
        int gotUserId = gotData["UserId"];
        int id = gotData["id"];
        bool reverse = false;
        String text = data["text"];
        if (gotUserId == userId) {
          reverse = true;
          if (text == null) return;
        }
        String date = data["createdAt"] ?? DateTime.now().toString();
        int suggestedId = data["suggestedId"];
        String suggested_name = data["suggested_name"];
        String suggested_photo_id = data["suggested_photo_id"];
        String type = data["type"];
        DateTime msgDate = DateTime.parse(date);
        setState(() {
          _messages.add(ChatBubbleData(
              id,
              text,
              ChatImageData(data["path"] as String, null, false),
              reverse,
              msgDate,
              suggestedId,
              suggested_name,
              suggested_photo_id,
              type));
        });
        Future.delayed(Duration(milliseconds: 100), () {
          scrollController.animateTo(scrollController.position.maxScrollExtent,
              curve: Curves.ease, duration: Duration(milliseconds: 500));
        });
      });
    });
    socket.on("connecting", (data) {
      print('connecting');
    });
    socket.on("connect_error", (E) {
      print("**********");
      print("Error: $E");
    });
  }

  List<File> imageFiles = [null];

  @override
  void initState() {
    _messages = List();
    this._getUserImages();
    this._connectSocket();
    this._getMessages();

    scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.minScrollExtent) {
        print("MINIMUM");
        if (!loading && _dataPage != -1) {
          setState(() {
            loading = true;
          });
          this._getMessages();
        }
      }
    });
    var keyboardVisibilityController = KeyboardVisibilityController();
    keyboardVisibilityController.onChange.listen((bool visible) {
      Future.delayed(Duration(milliseconds: 120), () {
        scrollController.animateTo(scrollController.position.maxScrollExtent,
            curve: Curves.ease, duration: Duration(milliseconds: 500));
      });
    });
    // Analytics tracking code
    analytics.setCurrentScreen(
        screenName: "group_chat", screenClassOverride: "group_chat");
    title = widget.title;
    amplitudeAnalytics.logEvent("group_chat_page");

    /* KeyboardVisibilityNotification().addNewListener(
      onChange: (bool visible) {
        Future.delayed(Duration(milliseconds: 120), () {
          scrollController.animateTo(scrollController.position.maxScrollExtent,
              curve: Curves.ease, duration: Duration(milliseconds: 500));
        });
      },
    ); */
    super.initState();

    //Initializing amplitude analytics api key
    amplitudeAnalytics.init(apiKey);
  }

  @override
  void dispose() {
    socket.disconnect();
    socket.destroy();
    _heightFocus.dispose();
    scrollController.dispose();
    super.dispose();
  }

  void _getMembers() async {
    try {
      var res = await MyHttp.get("chat/${widget.chatId}/members");
      // print(res.statusCode);
      // print(res.body);
      var body = json.decode(res.body);
      var friends = body["friends"] as List<dynamic>;
      if (friends != null && friends.length > 0) {
        for (int i = 0; i < friends.length; i++) {
          var friend = friends[i];
          var u = GroupUser(User.fromJson(friend));
          this._groupUsers.add(u);
          this._groupUserIds.add(u.u.id);
        }
        setState(() {});
      }
    } catch (e) {
      print("Get friends error $e");
    }
  }

  void _leaveGroup() async {
    try {
      print("leaaving the group");
      var data = {};

      var res = await MyHttp.put("/chat/${widget.chatId}/leave", data);
      if (res.statusCode == 200) {
        var body = jsonDecode(res.body);
        // print(body);
        _warningUser(context, "You have left the group",
            "You will no longer be able to participate or receive notifications");
        // print(body);
        // Analytics code
        analytics.logEvent(name: "left_group", parameters: <String, dynamic>{
          'group_name': title,
          'chat_id': widget.chatId.toString(),
          'user_id': userId
        });
        amplitudeAnalytics.logEvent("left_group", eventProperties: {
          'group_name': widget.title,
          'chat_id': widget.chatId.toString(),
          'user_id': userId
        });
      } else {
        print("Unable to leave the group ${res.statusCode}");
      }
    } catch (e) {
      print(e);
    }
  }

  void _changeGroupName(String name) async {
    try {
      var data = {"name": name};
      var res = await MyHttp.put("/chat/${widget.chatId}/name", data);
      if (res.statusCode == 200) {
        var body = jsonDecode(res.body);
        // print(body);
        //Analytics code
        String oldName = title;
        title = name;
        print("******");

        setState(() {});
        // analytics code
        analytics.logEvent(
            name: "changed_group_name",
            parameters: <String, dynamic>{
              'group_name': title,
              'chat_id': widget.chatId.toString(),
              "old_name": oldName
            });

        amplitudeAnalytics.logEvent("changed_group_name", eventProperties: {
          'group_name': title,
          'chat_id': widget.chatId.toString(),
          'old_name': oldName
        });
      } else {
        print("Unable to change the group name ${res.statusCode}");
      }
    } catch (e) {
      print(e);
    }
  }

  void _changeGrouppicture(File file) async {
    var sp = await SharedPreferences.getInstance();
    String token = sp.getString("token");
    var request = new http.MultipartRequest(
        "PUT", Uri.parse(MyUrl.url("/chat/${widget.chatId}/image")));
    request.headers["authorization"] = "Bearer $token";

    // analytics code
    analytics.logEvent(
        name: "changed_group_picture",
        parameters: <String, dynamic>{
          'group_name': title,
          'chat_id': widget.chatId.toString()
        });

    amplitudeAnalytics.logEvent("changed_group_picture", eventProperties: {
      'group_name': title,
      'chat_id': widget.chatId.toString()
    });

    //only if images are changed, create multipart requests
    var imageStream = file.readAsBytes().asStream();
    var f = http.MultipartFile('file', imageStream, file.lengthSync(),
        filename: file.path, contentType: MediaType('image', 'jpg'));

    request.fields['tag'] = file.toString();
    request.files.add(f);

    try {
      var res = await request.send();
      if (res.statusCode == 200 || res.statusCode == 201) {
        print("Uploaded");

        var response = await http.Response.fromStream(res);
        if (response != null) {
          var body = json.decode(response.body);
          print(body);
        }
      } else {
        print("Error ${res.statusCode}");
        setState(() {
          print("An Error has occured with statuscode " +
              res.statusCode.toString());
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  void _postImageToServer() async {
    setState(() {
      loading = true;
    });

    var imageStream, f, res, body, newUpload;
    var sp = await SharedPreferences.getInstance();
    String token = sp.getString("token");

    var img = imageFiles[0];
    if (img != null) {
      var request =
          new http.MultipartRequest("POST", Uri.parse(MyUrl.url("/uploads")));
      request.headers["authorization"] = "Bearer $token";

      //only if images are changed, create multipart requests
      imageStream = img.readAsBytes().asStream();
      f = http.MultipartFile('file', imageStream, img.lengthSync(),
          filename: img.path, contentType: MediaType('image', 'jpg'));

      request.fields['tag'] = img.toString();
      request.files.add(f);

      try {
        res = await request.send();
        if (res.statusCode == 200 || res.statusCode == 201) {
          print("Uploaded");

          var response = await http.Response.fromStream(res);
          if (response != null) {
            body = json.decode(response.body);
            newUpload = body["newUpload"];
            // print(newUpload);

            //_changeGrouppicture(newUpload['path'] as String);

          }
        } else {
          print("Error ${res.statusCode}");
          setState(() {
            print("An Error has occured with statuscode " +
                res.statusCode.toString());
          });
        }
      } catch (e) {
        print(e.toString());
      }
    }

    if (res.statusCode == 200 || res.statusCode == 201) {
//      Routes.sailor.navigate("/homes",
//          params: {'tabIndex': 4, 'ownProfileSaved': true},
//          navigationType: NavigationType.pushAndRemoveUntil,
//          removeUntilPredicate: (Route<dynamic> route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    print("*****************");
    print("this is the group chat page");
    width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.blueColor,
        title: Text(title, style: TextStyle(color: Colors.white)),
        actions: <Widget>[
          IconButton(
              icon: Icon(
                Icons.more_horiz,
                color: Colors.white,
              ),
              onPressed: () {
                if (Platform.isAndroid) {
                  _showModalBottomSheet(context);
                } else {
                  _showModalActionSheet(context);
                }
              })
        ],
      ),
      body: SafeArea(
          child: Column(
        children: <Widget>[
          Visibility(
            visible: widget.newGroup == true,
            child: Text(
              "Be the first to start the conversation!",
              style: TextStyle(fontSize: 20, color: Colors.black54),
            ),
          ),
          (imageFiles[0] != null)
              ? Column(
                  children: <Widget>[
                    SizedBox(
                      height: 30,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                            height: 100,
                            width: 100,
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(500.0),
                                child: Image.file(imageFiles[0],
                                    fit: BoxFit.fill)))
                      ],
                    ),
                    Text(
                      "User has the changed the Group Profile Picture",
                      style: TextStyle(fontSize: 15, color: Colors.black54),
                    ),
                  ],
                )
              : Container(),
          SizedBox(
            height: 30,
          ),
          (loading) ? PlatformCircularProgressIndicator() : Container(),
          Visibility(
            visible: widget.memberAdded == true,
            child: Text(
              "${widget.newUser} has been added to the group",
              style: TextStyle(fontSize: 15, color: Colors.black54),
            ),
          ),
          Expanded(
            child: ListView.builder(
                controller: scrollController,
                itemCount: _messages.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  bool reverse = _messages[index].reverse;
                  String networkPath =
                      _messages[index].chatImageData.networkPath;
                  String localPath = _messages[index].chatImageData.localPath;
                  String path = networkPath ?? localPath;
                  bool imageLoading = _messages[index].chatImageData.loading;

                  var avatar = Padding(
                    padding: const EdgeInsets.only(
                        left: 8.0, bottom: 8.0, right: 8.0),
                    child: CircleAvatar(
                      child: (reverse)
                          ? (userProfilePic != null)
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(100.0),
                                  child: CachedNetworkImage(
                                    imageUrl: userProfilePic ??
                                        "https://www.xovi.com/wp-content/plugins/all-in-one-seo-pack/images/default-user-image.png",
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.cover,
                                    errorWidget: (context, url, error) =>
                                        Icon(Icons.error),
                                  ))
                              : Icon(Icons.person, size: 30)
                          : Icon(Icons.person, size: 30),
                    ),
                  );

                  var triangle = CustomPaint(
                    painter: Triangle(
                        (reverse) ? AppColors.blueColor : AppColors.greyColor),
                  );

                  var messagebody = DecoratedBox(
                    decoration: BoxDecoration(
                      color:
                          (reverse) ? AppColors.blueColor : AppColors.greyColor,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: (_messages[index].text == null)
                            ? Container(
                                width: 180,
                                child: Stack(
                                  children: <Widget>[
                                    (networkPath != null)
                                        ? CachedNetworkImage(
                                            imageUrl: networkPath,
                                            width: 168,
                                            height: 168,
                                            errorWidget:
                                                (context, url, error) =>
                                                    Icon(Icons.error),
                                          )
                                        : Image.file(File(localPath)),
                                    (imageLoading)
                                        ? Container(
                                            height: 180,
                                            child: Center(
                                              child:
                                                  PlatformCircularProgressIndicator(),
                                            ),
                                          )
                                        : Container(),
                                  ],
                                ),
                              )
                            : Text(
                                _messages[index].text ?? "",
                                style: TextStyle(
                                    color: (reverse)
                                        ? Colors.white
                                        : Colors.black),
                              ),
                      ),
                    ),
                  );

                  // time logic
                  DateTime msgDateTime = _messages[index].createdAt;
                  String timeDivider;
                  if (lastMessageDateTime != null) {
                    timeDivider = TimeDividerAlgo.getTimeDivider(
                        lastMessageDateTime, msgDateTime);
                  }
                  // print(timeDivider);
                  lastMessageDateTime = msgDateTime;

                  Widget message;

                  if (reverse) {
                    message = Stack(
                      children: <Widget>[
                        messagebody,
                        Positioned(right: 0, bottom: 0, child: triangle),
                      ],
                    );
                  } else {
                    message = Stack(
                      children: <Widget>[
                        Positioned(left: 0, bottom: 0, child: triangle),
                        messagebody,
                      ],
                    );
                  }

                  if (reverse) {
                    return Column(
                      children: <Widget>[
                        (timeDivider != null) ? Text(timeDivider) : Container(),
                        Container(
                          width: double.infinity,
                          child: InkWell(
                            onLongPress: () {
                              setState(() {
                                this.selectedDeleteMessages.clear();
                                if (this.deleteMode == false) {
                                  this.deleteMode = true;
                                }
                              });
                            },
                            onTap: () {
                              setState(() {
                                if (this.deleteMode) {
                                  this.deleteMode = false;
                                }
                              });
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Container(
                                  padding: const EdgeInsets.all(8.0),
                                  constraints: BoxConstraints(
                                      minWidth: 0, maxWidth: width / 2),
                                  child: message,
                                ),
                                avatar,
                                (deleteMode)
                                    ? InkWell(
                                        onTap: () {
                                          setState(() {
                                            if (this
                                                .selectedDeleteMessages
                                                .contains(
                                                    _messages[index].id)) {
                                              this
                                                  .selectedDeleteMessages
                                                  .remove(_messages[index].id);
                                            } else {
                                              this
                                                  .selectedDeleteMessages
                                                  .add(_messages[index].id);
                                            }
                                          });
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Container(
                                            height: 25,
                                            width: 25,
                                            decoration: BoxDecoration(
                                                color: (this
                                                        .selectedDeleteMessages
                                                        .contains(
                                                            _messages[index]
                                                                .id))
                                                    ? AppColors.blueColor
                                                    : Colors.white,
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                    color:
                                                        AppColors.blueColor)),
                                          ),
                                        ),
                                      )
                                    : Container()
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  } else {
                    return Column(
                      children: <Widget>[
                        (timeDivider != null) ? Text(timeDivider) : Container(),
                        Container(
                          width: double.infinity,
                          child: InkWell(
                            onLongPress: () {
                              setState(() {
                                this.selectedDeleteMessages.clear();
                                if (this.deleteMode == false) {
                                  this.deleteMode = true;
                                }
                              });
                            },
                            onTap: () {
                              setState(() {
                                if (this.deleteMode) {
                                  this.deleteMode = false;
                                }
                              });
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                avatar,
                                Container(
                                  padding: const EdgeInsets.all(8.0),
                                  constraints: BoxConstraints(
                                      minWidth: 0, maxWidth: width / 2),
                                  child: message,
                                ),
                                (false) // this is set to false because we do not want the user to delete other's messages
                                    ? Expanded(
                                        child: Align(
                                          alignment: Alignment.centerRight,
                                          child: InkWell(
                                            onTap: () {
                                              setState(() {
                                                if (this
                                                    .selectedDeleteMessages
                                                    .contains(
                                                        _messages[index].id)) {
                                                  this
                                                      .selectedDeleteMessages
                                                      .remove(
                                                          _messages[index].id);
                                                } else {
                                                  this
                                                      .selectedDeleteMessages
                                                      .add(_messages[index].id);
                                                }
                                              });
                                            },
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Container(
                                                height: 25,
                                                width: 25,
                                                decoration: BoxDecoration(
                                                    color: (this
                                                            .selectedDeleteMessages
                                                            .contains(
                                                                _messages[index]
                                                                    .id))
                                                        ? AppColors.blueColor
                                                        : Colors.white,
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                        color: AppColors
                                                            .blueColor)),
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    : Container()
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                }),
          ),
          (widget.status == null)
              ? Container(
                  padding: EdgeInsets.all(8), child: Text("Chat is disabled."))
              : (deleteMode)
                  ? Container(
                      padding: EdgeInsets.all(10),
                      child: SizedBox(
                        width: double.infinity,
                        height: 45,
                        child: FlatButton(
                          onPressed: (this.selectedDeleteMessages.length == 0)
                              ? null
                              : this._deleteMessages,
                          disabledColor: AppColors.greyColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          color: AppColors.redColor,
                          child: Text(
                            "Delete Message",
                            style: TextStyle(
                                color: (this.selectedDeleteMessages.length == 0)
                                    ? Colors.black
                                    : Colors.white,
                                fontSize: 18),
                          ),
                        ),
                      ),
                    )
                  : Row(
                      children: <Widget>[
                        PlatformIconButton(
                          onPressed: () {
                            this._uploadImage();
                          },
                          padding: EdgeInsets.all(0),
                          icon: Icon(
                            PlatformIcons(context).photoCameraSolid,
                            color: Colors.grey,
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.only(left: 8.0, bottom: 2.0),
                            child: PlatformTextField(
                              focusNode: _heightFocus,
                              onChanged: (text) {
                                if (text.trim().length > 0 &&
                                    this._isCurrentUserTyping == false) {
                                  this._sendTyping(true);
                                  this._isCurrentUserTyping = true;
                                } else {
                                  this._sendTyping(false);
                                  this._isCurrentUserTyping = false;
                                }
                                setState(() {
                                  enableButton = text.trim().isNotEmpty;
                                });
                              },
                              cupertino: (_, __) => CupertinoTextFieldData(
                                  placeholder: "Type a message",
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                        width: 1,
                                        color: Colors.grey,
                                      ),
                                      borderRadius: BorderRadius.circular(20)),
                                  suffix: IconButton(
                                      onPressed: (enableButton)
                                          ? handleSendMessage
                                          : null,
                                      icon: Icon(
                                        CupertinoIcons.up_arrow,
                                      ))),
                              material: (_, __) => MaterialTextFieldData(
                                decoration: InputDecoration.collapsed(
                                  hintText: "Type a message",
                                ),
                              ),
                              controller: textEditingController,
                            ),
                          ),
                        ),
                        (Platform.isIOS)
                            ? Container()
                            : PlatformButton(
                                child: Text("Send"),
                                cupertino: (_, __) => CupertinoButtonData(
                                    color: AppColors.greyColor,
                                    padding: EdgeInsets.all(8),
                                    child: Text(
                                      "Send",
                                      style: TextStyle(),
                                    )),
                                color: Colors.white,
                                disabledColor: Colors.transparent,
                                materialFlat: (_, __) =>
                                    MaterialFlatButtonData(),
                                onPressed:
                                    (enableButton) ? handleSendMessage : null,
                              )
                      ],
                    )
        ],
      )),
    );
  }

  void _alertInputUser(
      BuildContext context, String title, String content, String button) {
    showDialog(
      context: context,
      builder: (_) => Container(
        height: 100,
        child: PlatformAlertDialog(
          title: Text(title,
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          content: Column(
            children: <Widget>[
              SizedBox(
                height: 3,
              ),
              FittedBox(
                child: Text(content,
                    style:
                        TextStyle(fontSize: 13, fontWeight: FontWeight.w400)),
              ),
              PlatformTextField(
                autofocus: true,
                cupertino: (_, __) =>
                    CupertinoTextFieldData(placeholder: "Name"),
                onChanged: (value) {
                  title = value;
                  setState(() {});
                },
              ),
            ],
          ),
          material: (_, __) => MaterialAlertDialogData(
            elevation: 1.0,
            actions: <Widget>[
              FlatButton(
                  child: Text("Cancel",
                      style: TextStyle(
                          color: AppColors.communityProfileOptionsBlueColor,
                          fontWeight: FontWeight.w600)),
                  onPressed: () {
                    // Update user model is friend request sent successfully
                    Navigator.of(context).pop();
                  }),
              FlatButton(
                  child: Text(button,
                      style: TextStyle(
                          color: AppColors.communityProfileOptionsBlueColor,
                          fontWeight: FontWeight.w600)),
                  onPressed: () {
                    Navigator.of(context).pop();
                    // Update user model is friend request sent successfully
                    if (validCharacters.hasMatch(title) == false) {
                      _errorUser(context, "Error",
                          "Please Enter a valid group name", "Retry");
                    } else {
                      _changeGroupName(title);
                      setState(() {});
                    }
                  }),
            ],
          ),
          cupertino: (_, __) => CupertinoAlertDialogData(actions: <Widget>[
            CupertinoButton(
              child: Text("Cancel",
                  style: TextStyle(
                      color: AppColors.communityProfileOptionsBlueColor,
                      fontWeight: FontWeight.w600)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            CupertinoButton(
              child: Text(button,
                  style: TextStyle(
                      color: AppColors.communityProfileOptionsBlueColor,
                      fontWeight: FontWeight.w600)),
              onPressed: () {
                Navigator.of(context).pop();
                // Update user model is friend request sent successfully
                if (validCharacters.hasMatch(title) == false) {
                  _errorUser(context, "Error",
                      "Please Enter a valid group name", "Retry");
                } else {
                  _changeGroupName(title);
                  setState(() {});
                }
              },
            ),
          ]),
        ),
      ),
      barrierDismissible: true,
    ).then((value) {});
  }

  void _errorUser(
      BuildContext context, String title, String content, String button) {
    showDialog(
      context: context,
      builder: (_) => PlatformAlertDialog(
        title: Text(title,
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
        content: Text(content,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400)),
        material: (_, __) => MaterialAlertDialogData(
          elevation: 1.0,
          actions: <Widget>[
            Column(
              children: <Widget>[
                FlatButton(
                    child: Text(button,
                        style: TextStyle(
                            color: AppColors.communityProfileOptionsRedColor,
                            fontWeight: FontWeight.w600)),
                    onPressed: () {
                      // Update user model is friend request sent successfully
                      Navigator.of(context).pop();
                      _alertInputUser(context, "Change Group Name",
                          "Enter a new name for this group chat", "Change");
                    }),
              ],
            ),
          ],
        ),
        cupertino: (_, __) => CupertinoAlertDialogData(actions: <Widget>[
          CupertinoButton(
            child: Text(button,
                style: TextStyle(
                    color: AppColors.communityProfileOptionsRedColor,
                    fontWeight: FontWeight.w600)),
            onPressed: () {
              Navigator.of(context).pop();
              _alertInputUser(context, "Change Group Name",
                  "Enter a new name for this group chat", "Change");
            },
          ),
        ]),
      ),
      barrierDismissible: true,
    ).then((value) {
      print(value);
    });
  }

  void _alertUser(BuildContext context, String title, String button) {
    showDialog(
      context: context,
      builder: (_) => PlatformAlertDialog(
        title: Text(title,
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
        material: (_, __) => MaterialAlertDialogData(
          elevation: 1.0,
          actions: <Widget>[
            Column(
              children: <Widget>[
                FlatButton(
                    child: Text(button,
                        style: TextStyle(
                            color: AppColors.communityProfileOptionsRedColor,
                            fontWeight: FontWeight.w600)),
                    onPressed: () {
                      // Update user model is friend request sent successfully
                      Navigator.of(context).pop();
                      _leaveGroup();
                    }),
                FlatButton(
                    child: Text("Cancel",
                        style: TextStyle(
                            color: AppColors.communityProfileOptionsBlueColor,
                            fontWeight: FontWeight.w600)),
                    onPressed: () {
                      // Update user model is friend request sent successfully
                      Navigator.of(context).pop();
                    }),
              ],
            ),
          ],
        ),
        cupertino: (_, __) => CupertinoAlertDialogData(actions: <Widget>[
          Column(
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    border: Border(
                  top: BorderSide(color: Colors.black26, width: 1
                      // width: 3.0 --> you can set a custom width too!
                      ),
                )),
                child: CupertinoButton(
                  child: Text(button,
                      style: TextStyle(
                          color: AppColors.communityProfileOptionsRedColor,
                          fontWeight: FontWeight.w600)),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _leaveGroup();
                  },
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    border: Border(
                  top: BorderSide(color: Colors.black26, width: 1
                      // width: 3.0 --> you can set a custom width too!
                      ),
                )),
                child: CupertinoButton(
                  child: Text("Cancel",
                      style: TextStyle(
                          color: AppColors.communityProfileOptionsBlueColor,
                          fontWeight: FontWeight.w600)),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        ]),
      ),
      barrierDismissible: true,
    ).then((value) {
      print(value);
    });
  }

  void _warningUser(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (_) => PlatformAlertDialog(
        title: Text(title,
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
        content: Text(content,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400)),
        material: (_, __) => MaterialAlertDialogData(
          elevation: 1.0,
          actions: <Widget>[
            FlatButton(
                child: Text("Close",
                    style: TextStyle(
                        color: AppColors.communityProfileOptionsBlueColor,
                        fontWeight: FontWeight.w600)),
                onPressed: () {
                  // Update user model is friend request sent successfully
                  Navigator.of(context).pop();
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MessageBasePage()));
                }),
          ],
        ),
        cupertino: (_, __) => CupertinoAlertDialogData(actions: <Widget>[
          CupertinoButton(
            child: Text("Close",
                style: TextStyle(
                    color: AppColors.communityProfileOptionsBlueColor,
                    fontWeight: FontWeight.w600)),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => MessageBasePage()));
            },
          ),
        ]),
      ),
      barrierDismissible: true,
    ).then((value) {
      print(value);
    });
  }

  void _getImage(int imageNum) async {
    var image = await ImagePicker().getImage(
        source: ImageSource.gallery,
        imageQuality: 90,
        maxWidth: 500,
        maxHeight: 500);
    File croppedFile = await ImageCropper.cropImage(
        sourcePath: image.path,
        // aspectRatio: CropAspectRatio(ratioX: 1.0, ratioY: 1.0),
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.original,
        ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: AppColors.blueColor,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          aspectRatioLockDimensionSwapEnabled: false,
          aspectRatioLockEnabled: false,
        ));

    if (croppedFile == null) return;
    setState(() {
      imageFiles[imageNum] = croppedFile;
      _changeGrouppicture(imageFiles[0]);
    });
  }

  void _showModalBottomSheet(BuildContext context) {
    List<Widget> actions = new List<Widget>();

    actions.add(ListTile(
      title: Text("View Group Members",
          style: TextStyle(color: AppColors.communityProfileOptionsBlueColor)),
      onTap: () {
        Navigator.of(context).pop();
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => GroupMembers(
                      chatId: widget.chatId,
                    )));
      },
    ));
    actions.add(ListTile(
      title: Text("Add Group Members",
          style: TextStyle(color: AppColors.communityProfileOptionsBlueColor)),
      onTap: () {
        Navigator.of(context).pop();
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AddGroupMember(
                      title: title,
                      chatId: widget.chatId,
                    )));
      },
    ));
    actions.add(ListTile(
      title: Text("Change Group Name",
          style: TextStyle(color: AppColors.communityProfileOptionsBlueColor)),
      onTap: () {
        Navigator.of(context).pop();
        _alertInputUser(context, "Change Group Name",
            "Enter a new name for this group chat", "Change");
      },
    ));
    actions.add(ListTile(
      title: Text("Change Group Photo",
          style: TextStyle(color: AppColors.communityProfileOptionsBlueColor)),
      onTap: () {
        Navigator.of(context).pop();
        _getImage(0);
      },
    ));
    actions.add(ListTile(
      title: Text("Leave Group",
          style: TextStyle(color: AppColors.communityProfileOptionsRedColor)),
      onTap: () {
        Navigator.of(context).pop();
        _alertUser(context, "Leave this group?", "Leave");
      },
    ));

    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(child: new Wrap(children: actions));
        });
  }

  void _showModalActionSheet(BuildContext context) {
    List<CupertinoActionSheetAction> actionSheetActions =
        new List<CupertinoActionSheetAction>();

    actionSheetActions.add(CupertinoActionSheetAction(
        child: Text("View Group Members",
            style:
                TextStyle(color: AppColors.communityProfileOptionsBlueColor)),
        onPressed: () {
          Navigator.of(context).pop();
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => GroupMembers(
                        chatId: widget.chatId,
                      )));
        }));
    actionSheetActions.add(CupertinoActionSheetAction(
      child: Text("Add Group Member",
          style: TextStyle(color: AppColors.communityProfileOptionsBlueColor)),
      onPressed: () {
        Navigator.of(context).pop();
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AddGroupMember(
                      title: title,
                      chatId: widget.chatId,
                    )));
      },
    ));
    actionSheetActions.add(CupertinoActionSheetAction(
      child: Text("Change Group Name",
          style: TextStyle(color: AppColors.communityProfileOptionsBlueColor)),
      onPressed: () {
        Navigator.of(context).pop();
        _alertInputUser(context, "Change Group Name",
            "Enter a new name for this group chat", "Change");
      },
    ));
    actionSheetActions.add(CupertinoActionSheetAction(
      child: Text("Change Group Photo",
          style: TextStyle(color: AppColors.communityProfileOptionsBlueColor)),
      onPressed: () {
        Navigator.of(context).pop();
        _getImage(0);
      },
    ));
    actionSheetActions.add(CupertinoActionSheetAction(
      child: Text("Leave Group",
          style: TextStyle(color: AppColors.communityProfileOptionsRedColor)),
      onPressed: () {
        Navigator.of(context).pop();
        _alertUser(context, "Leave this group?", "Leave");
      },
    ));

    showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) {
          return CupertinoActionSheet(
              title: Text(title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Color.fromRGBO(143, 143, 143, 1),
                  )),
              actions: actionSheetActions,
              cancelButton: CupertinoActionSheetAction(
                child: Text(
                  'Cancel',
                  style: TextStyle(
                      color: AppColors.communityProfileOptionsBlueColor),
                ),
                isDefaultAction: true,
                onPressed: () {
                  Navigator.pop(context);
                },
              ));
        });
  }

  void _uploadImage() async {
    var image1 = await ImagePicker().getImage(
        source: ImageSource.gallery,
        imageQuality: 90,
        maxHeight: 500,
        maxWidth: 500);
    File croppedFile = await ImageCropper.cropImage(
        sourcePath: image1.path,
        // aspectRatio: CropAspectRatio(ratioX: 1.0, ratioY: 1.0),
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.original,
        ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: AppColors.blueColor,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          aspectRatioLockDimensionSwapEnabled: false,
          aspectRatioLockEnabled: false,
        ));

    if (croppedFile == null) return;
    int mindex = _messages.length;
    var cid = ChatImageData(null, croppedFile.path, true);
    setState(() {
      _messages.add(ChatBubbleData(
          -1, null, cid, true, DateTime.now(), null, null, null, "message"));
    });
    Future.delayed(Duration(milliseconds: 300), () {
      scrollController.animateTo(
          scrollController.position.maxScrollExtent + 100,
          curve: Curves.ease,
          duration: Duration(milliseconds: 500));
    });
    var sp = await SharedPreferences.getInstance();
    String token = sp.getString("token");
    var request = new http.MultipartRequest(
        "POST", Uri.parse(MyUrl.url("/chat/${widget.chatId}/chatUpload")));
    request.headers["authorization"] = "Bearer $token";
    request.fields['tag'] = "upload";
    var f = http.MultipartFile('file', croppedFile.readAsBytes().asStream(),
        File(croppedFile.path).lengthSync(),
        filename: croppedFile.path, contentType: MediaType('image', 'jpg'));

    request.files.add(f);
    try {
      var res = await request.send();
      if (res.statusCode == 200 || res.statusCode == 201) {
        var resBody = await utf8.decodeStream(res.stream);
        var body = json.decode(resBody);
        var message = body["message"];
        int messageId = message["id"];
        var m = _messages[mindex];
        m.id = messageId;
        m.chatImageData.loading = false;
        setState(() {
          _messages[mindex] = m;
        });
      } else {
        print("Error ${res.statusCode}");
      }
    } catch (e) {
      print(e.toString());
    }
  }

  final FocusNode _heightFocus = FocusNode();
  final IMAGE_LOADING = "LOADING";
}
