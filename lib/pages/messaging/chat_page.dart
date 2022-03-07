import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pure_match/common/global.dart';
import 'package:pure_match/common/triangle.dart';
import 'package:pure_match/models/chat_bubble_data.dart';
import 'package:pure_match/models/chat_image_data.dart';
import 'package:pure_match/pages/AppColors.dart';
import 'package:pure_match/pages/MyHttp.dart';
import 'package:pure_match/pages/MyUrl.dart';
import 'package:pure_match/pages/community_profile/community_profile.dart';
import 'package:pure_match/pages/messaging/time_divider_algo.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:amplitude_flutter/amplitude.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:io' show Platform;

class ChatPage extends StatefulWidget {
  final int chatId;
  final int otherUserId;
  final String status;
  const ChatPage({Key key, this.chatId, this.otherUserId, this.status})
      : super(key: key);
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  // Analytics code
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';

  List<ChatBubbleData> _messages;

  TextEditingController textEditingController = TextEditingController();
  ScrollController scrollController;

  // this is to check if the user is typing or not
  bool _isCurrentUserTyping = false;
  String userProfilePic;
  String otherUserProfilePic;
  String otherUserFirstName = "A";
  bool enableButton = false;
  Socket socket;
  int userId;
  bool isSelectedImage = false;
  int indexMsg = -1;
  bool loading = false;
  int topMessageId = -1;
  int _dataPage = 1;
  double width;
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
            otherUserFirstName = body["user"]["first_name"];

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
      print("ID ========");
      print(id);
      print("User ID =======");
      userId = id;
      print(userId);
    }
    userProfilePic = await this._getUserProfileById(userId);

    otherUserProfilePic = await this._getUserProfileById(widget.otherUserId);

    print("****************");
    print("userProfilePic: $userProfilePic");
    print("otherUserProfilePic: $otherUserProfilePic");
    if (this.mounted) {
      setState(() {});
    }
  }

  void _getMessages() async {
    topMessageId = -1;
    if (_dataPage == 1) {
      _messages = List();
    }
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
            var cid = ChatImageData(path, null, false);
            int otherUserId = messages[i]["UserId"];
            if (userId == 0 || userId == null) {
              var sp = await SharedPreferences.getInstance();
              userId = sp.getInt("id");
            }
            int suggestedId = messages[i]["suggestedId"];
            String suggested_name = messages[i]["suggested_name"];
            String suggested_photo_id = messages[i]["suggested_photo_id"];
            String type = messages[i]["type"];
            String date = messages[i]["createdAt"];

            DateTime msgDate = DateTime.parse(date);
            bool reverse = false;
            if (userId == otherUserId) reverse = true;
            int messageId = messages[i]["id"];
            if (_dataPage == 1) {
              if (this.mounted) {
                setState(() {
                  _messages.add(ChatBubbleData(
                      messageId,
                      text,
                      cid,
                      reverse,
                      msgDate,
                      suggestedId,
                      suggested_name,
                      suggested_photo_id,
                      type));
                  scrollController.animateTo(
                      scrollController.position.maxScrollExtent,
                      curve: Curves.ease,
                      duration: Duration(milliseconds: 500));
                });
              }
            } else {
              if (this.mounted) {
                setState(() {
                  _messages.insert(
                      i,
                      ChatBubbleData(
                          messageId,
                          text,
                          cid,
                          reverse,
                          msgDate,
                          suggestedId,
                          suggested_name,
                          suggested_photo_id,
                          type));
                });
              }
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
    if (this.mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  void handleSendMessage() async {
    print("sending message");
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
        "recipientId": widget.otherUserId
      };

      var jsonData = json.encode(data);
      print(jsonData);
      socket.emit("send-message", jsonData);
    }
    textEditingController.clear();
    if (this.mounted) {
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

    //Analytics tracking code
    analytics.logEvent(
        name: "messaged_friend",
        parameters: <String, dynamic>{'user': this.userId.toString()});

    amplitudeAnalytics.logEvent("messaged_friend",
        eventProperties: {'user': this.userId.toString()});
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
        "recipientId": widget.otherUserId
      };
      var jsonData = json.encode(data);
      print(jsonData);
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
        "recipientId": widget.otherUserId,
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
    print("check 123*********");
    socket = io(MyUrl.url("/"), <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'extraHeaders': {'token': token} // optional
    });
    print("1");
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
        print("chat page new message");
        print(data);
        var gotData = data;
        int gotUserId = gotData["UserId"];
        int id = gotData["id"];
        bool reverse = false;
        String text = data["text"];
        String date = data["createdAt"] ?? DateTime.now().toString();
        int suggestedId = data["suggestedId"];
        String suggested_name = data["suggested_name"];
        String suggested_photo_id = data["suggested_photo_id"];
        String type = data["type"];
        DateTime msgDate = DateTime.parse(date);

        if (gotUserId == userId) {
          reverse = true;
          if (text == null) return;
        }
        if (this.mounted) {
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
            scrollController.animateTo(
                scrollController.position.maxScrollExtent,
                curve: Curves.ease,
                duration: Duration(milliseconds: 500));
          });
        }
      });
    });
    socket.on("connecting", (data) {
      print('connecting');
    });
    socket.on("connect_error", (E) {
      print("**********");
      print("chast_page Socket Error: $E");
    });
  }

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

  Container _getFriendSuggestionContainer(ChatBubbleData data, bool reverse) {
    return (data.suggestedId != null)
        ? Container(
            padding: const EdgeInsets.only(top: 8.0),
            child: Column(
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10.0),
                    topRight: Radius.circular(10.0),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: data.suggested_photo_id ??
                        "https://i.pinimg.com/564x/19/b8/d6/19b8d6e9b13eef23ec9c746968bb88b1.jpg",
                    height: 123,
                    width:
                        AppConfig.heightWithDForSmallDevice(context, 269, 40),
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => CommunityProfile(
                              userId: data.suggestedId,
                            )));
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color:
                          (reverse) ? AppColors.greyColor : AppColors.blueColor,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(10.0),
                        bottomRight: Radius.circular(10.0),
                      ),
                    ),
                    padding: EdgeInsets.only(left: 14, top: 8, bottom: 8),
                    width:
                        AppConfig.heightWithDForSmallDevice(context, 269, 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          (data.type == "friend_suggestion")
                              ? "Friend Suggestion: ${data.suggested_name}"
                              : "Match Suggestion: ${data.suggested_name}",
                          style: TextStyle(
                              color: (reverse)
                                  ? AppColors.blackColor
                                  : Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                        Text(
                          "Go to Profile",
                          style: TextStyle(
                              color: (reverse)
                                  ? AppColors.blueColor
                                  : Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            ),
          )
        : Container();
  }

  void _uploadImage(ImageSource source) async {
    var image1 = await ImagePicker().getImage(
        source: source, maxWidth: 500, maxHeight: 500, imageQuality: 90);
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
    if (this.mounted) {
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
    }

    var sp = await SharedPreferences.getInstance();
    String token = sp.getString("token");
    var request = new http.MultipartRequest(
        "POST", Uri.parse(MyUrl.url("/chat/${widget.chatId}/chatUpload")));
    request.headers["authorization"] = "Bearer $token";
    request.fields['tag'] = "upload";
    print("path=${croppedFile.path}");
    print("name=${croppedFile.path.split('/').last}");
    var f = http.MultipartFile('file', croppedFile.readAsBytes().asStream(),
        File(croppedFile.path).lengthSync(),
        filename: croppedFile.path.split('/').last,
        contentType: MediaType('image', 'jpg'));

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
        print("chat_page _uploadImage Error ${res.statusCode}");
      }
    } catch (e) {
      print(e.toString());
    }
  }

  final FocusNode _heightFocus = FocusNode();
  final IMAGE_LOADING = "LOADING";

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: (isSelectedImage == false)
          ? Container(
              child: Column(
                children: <Widget>[
                  (loading) ? PlatformCircularProgressIndicator() : Container(),
                  Expanded(
                    child: ListView.builder(
                        controller: scrollController,
                        itemCount: _messages.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          bool reverse = _messages[index].reverse;
                          String networkPath =
                              _messages[index].chatImageData.networkPath;
                          String localPath =
                              _messages[index].chatImageData.localPath;
                          String path = networkPath ?? localPath;
                          bool imageLoading =
                              _messages[index].chatImageData.loading;

                          var avatar = (reverse)
                              ? Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8.0, bottom: 8.0, right: 8.0),
                                )
                              : Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8.0, bottom: 8.0, right: 8.0),
                                  child: CircleAvatar(
                                      child: (reverse)
                                          ? ((userProfilePic != null)
                                              ? ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          100),
                                                  child: CachedNetworkImage(
                                                    imageUrl: userProfilePic,
                                                    width: 40,
                                                    height: 40,
                                                    fit: BoxFit.cover,
                                                    errorWidget:
                                                        (context, url, error) =>
                                                            Icon(Icons.error),
                                                  ),
                                                )
                                              : Icon(Icons.person, size: 30))
                                          : ((otherUserProfilePic != null)
                                              ? ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          100),
                                                  child: CachedNetworkImage(
                                                    imageUrl:
                                                        otherUserProfilePic,
                                                    width: 40,
                                                    height: 40,
                                                    fit: BoxFit.cover,
                                                    errorWidget:
                                                        (context, url, error) =>
                                                            Icon(Icons.error),
                                                  ),
                                                )
                                              : Text(
                                                  '${otherUserFirstName[0]}'))),
                                );
                          var triangle = CustomPaint(
                            painter: Triangle((reverse)
                                ? AppColors.blueColor
                                : AppColors.greyColor),
                          );

                          var messagebody = DecoratedBox(
                            decoration: BoxDecoration(
                              color: (reverse)
                                  ? AppColors.blueColor
                                  : AppColors.greyColor,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: (_messages[index].text == null)
                                    ? Container(
                                        width: 180,
                                        child: InkWell(
                                          onTap: (this.deleteMode == false)
                                              ? () {
                                                  isSelectedImage = true;
                                                  indexMsg = index;
                                                  print("Image selected");
                                                  setState(() {});
                                                }
                                              : null,
                                          child: Stack(
                                            children: <Widget>[
                                              (networkPath != null)
                                                  ? CachedNetworkImage(
                                                      imageUrl: networkPath,
                                                      width: 168,
                                                      height: 168,
                                                      fit: BoxFit.cover,
                                                      errorWidget: (context,
                                                              url, error) =>
                                                          Icon(Icons.error),
                                                    )
                                                  : Image.file(
                                                      File(localPath),
                                                      width: 168,
                                                      height: 168,
                                                      fit: BoxFit.cover,
                                                    ),
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
                          DateTime currentedDate = _messages[index].createdAt;
                          String timeDivider;
                          if (lastMessageDateTime != null) {
                            timeDivider = TimeDividerAlgo.getTimeDivider(
                                lastMessageDateTime, currentedDate);
                          }
                          print(timeDivider);
                          lastMessageDateTime = currentedDate;

                          Widget message;

                          if (reverse) {
                            message = Stack(
                              children: <Widget>[
                                messagebody,
                                Positioned(
                                    right: 0, bottom: 0, child: triangle),
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
                                (timeDivider != null)
                                    ? Text(timeDivider)
                                    : Container(),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Column(children: <Widget>[
                                          _getFriendSuggestionContainer(
                                              _messages[index], reverse),
                                          Container(
                                            padding:
                                                (_messages[index].suggestedId !=
                                                        null)
                                                    ? const EdgeInsets.only(
                                                        left: 8.0, bottom: 8.0)
                                                    : const EdgeInsets.all(8.0),
                                            constraints: BoxConstraints(
                                                minWidth: 0,
                                                maxWidth: width / 1.4),
                                            child: message,
                                          ),
                                        ]),
                                        avatar,
                                        (deleteMode)
                                            ? InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    if (this
                                                        .selectedDeleteMessages
                                                        .contains(
                                                            _messages[index]
                                                                .id)) {
                                                      this
                                                          .selectedDeleteMessages
                                                          .remove(
                                                              _messages[index]
                                                                  .id);
                                                    } else {
                                                      this
                                                          .selectedDeleteMessages
                                                          .add(_messages[index]
                                                              .id);
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
                                                                    _messages[
                                                                            index]
                                                                        .id))
                                                            ? AppColors
                                                                .blueColor
                                                            : Colors.white,
                                                        shape: BoxShape.circle,
                                                        border: Border.all(
                                                            color: AppColors
                                                                .blueColor)),
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
                                (timeDivider != null)
                                    ? Text(timeDivider)
                                    : Container(),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: <Widget>[
                                        avatar,
                                        Column(children: <Widget>[
                                          _getFriendSuggestionContainer(
                                              _messages[index], reverse),
                                          Container(
                                            padding:
                                                (_messages[index].suggestedId !=
                                                        null)
                                                    ? const EdgeInsets.only(
                                                        bottom: 8.0, right: 8.0)
                                                    : const EdgeInsets.all(8.0),
                                            constraints: BoxConstraints(
                                                minWidth: 0,
                                                maxWidth: width / 1.4),
                                            child: message,
                                          ),
                                        ]),
                                        (false) // this is set to false because we do not want the user to delete other's messages
                                            ? Expanded(
                                                child: Align(
                                                  alignment:
                                                      Alignment.centerRight,
                                                  child: InkWell(
                                                    onTap: () {
                                                      setState(() {
                                                        if (this
                                                            .selectedDeleteMessages
                                                            .contains(
                                                                _messages[index]
                                                                    .id)) {
                                                          this
                                                              .selectedDeleteMessages
                                                              .remove(_messages[
                                                                      index]
                                                                  .id);
                                                        } else {
                                                          this
                                                              .selectedDeleteMessages
                                                              .add(_messages[
                                                                      index]
                                                                  .id);
                                                        }
                                                      });
                                                    },
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Container(
                                                        height: 25,
                                                        width: 25,
                                                        decoration: BoxDecoration(
                                                            color: (this
                                                                    .selectedDeleteMessages
                                                                    .contains(
                                                                        _messages[index]
                                                                            .id))
                                                                ? AppColors
                                                                    .blueColor
                                                                : Colors.white,
                                                            shape:
                                                                BoxShape.circle,
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
                          padding: EdgeInsets.all(8),
                          child: Text("Chat is disabled."))
                      : (deleteMode)
                          ? Container(
                              padding: EdgeInsets.all(10),
                              child: SizedBox(
                                width: double.infinity,
                                height: 45,
                                child: FlatButton(
                                  onPressed:
                                      (this.selectedDeleteMessages.length == 0)
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
                                        color: (this
                                                    .selectedDeleteMessages
                                                    .length ==
                                                0)
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
                                    this._uploadImage(ImageSource.camera);
                                  },
                                  padding: EdgeInsets.all(0),
                                  icon: Icon(
                                    PlatformIcons(context).photoCameraSolid,
                                    color: Colors.grey,
                                  ),
                                ),
                                PlatformIconButton(
                                  onPressed: () {
                                    this._uploadImage(ImageSource.gallery);
                                  },
                                  padding: EdgeInsets.all(0),
                                  icon: Icon(
                                    Icons.image,
                                    color: Colors.grey,
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 8.0, bottom: 2.0),
                                    child: PlatformTextField(
                                      textCapitalization:
                                          TextCapitalization.sentences,
                                      textInputAction: TextInputAction.newline,
                                      focusNode: _heightFocus,
                                      onChanged: (text) {
                                        if (text.trim().length > 0 &&
                                            this._isCurrentUserTyping ==
                                                false) {
                                          this._sendTyping(true);
                                          this._isCurrentUserTyping = true;
                                        } else {
                                          this._sendTyping(false);
                                          this._isCurrentUserTyping = false;
                                        }
                                        if (this.mounted) {
                                          setState(() {
                                            enableButton =
                                                text.trim().isNotEmpty;
                                          });
                                        }
                                      },
                                      cupertino: (_, __) =>
                                          CupertinoTextFieldData(
                                              placeholder: "Type a message",
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                    width: 1,
                                                    color: Colors.grey,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20)),
                                              suffix: IconButton(
                                                  onPressed: (enableButton)
                                                      ? handleSendMessage
                                                      : null,
                                                  icon: Icon(
                                                    CupertinoIcons.up_arrow,
                                                  ))),
                                      material: (_, __) =>
                                          MaterialTextFieldData(
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
                                        cupertino: (_, __) =>
                                            CupertinoButtonData(
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
                                        onPressed: (enableButton)
                                            ? handleSendMessage
                                            : null,
                                      )
                              ],
                            )
                ],
              ),
            )
          : InkWell(
              onTap: () {
                isSelectedImage = false;
                indexMsg = -1;
                setState(() {});
              },
              child: Center(
                child: CachedNetworkImage(
                  imageUrl:
                      (_messages[indexMsg].chatImageData.networkPath != null)
                          ? _messages[indexMsg].chatImageData.networkPath
                          : _messages[indexMsg].chatImageData.localPath,
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              ),
            ),
    );
  }

  Widget shareCard(bool friendSuggest) {
    //TODO: Implement these Share card with in the chat with the message.

    return Column(
      children: <Widget>[
        Container(
          width: width / 1.5,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              color: AppColors.suggestMatchChatCard),
          child: Column(
            children: <Widget>[
              Container(
                height: 100,
                decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.elliptical(10, 10)),
                    image: DecorationImage(
                        image: NetworkImage(
                          "https://pixinvent.com/materialize-material-design-admin-template/app-assets/images/user/12.jpg",
                        ),
                        fit: BoxFit.cover)),
              ),
              Container(
                width: width / 1.5,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.vertical(
                        bottom: Radius.elliptical(10, 10)),
                    color: Colors.grey[300]),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      (friendSuggest == true)
                          ? Text(
                              "Friend Suggestion:Faith",
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w800),
                            )
                          : Text(
                              "Match Suggestion:Faith",
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w800),
                            ),
                      Text(
                        "Go to Profile",
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppColors.blueColor),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
