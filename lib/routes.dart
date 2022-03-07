import 'package:pure_match/main.dart';
import 'package:pure_match/pages/messaging/home_page.dart';
import 'package:sailor/sailor.dart';

class Routes {
  static final sailor = Sailor();

  static void createRoutes() {
    sailor.addRoutes([
      SailorRoute(
          name: "/main",
          builder: (context, args, params) {
            return MyHomePage();
          }),
      SailorRoute(
          name: "/homes",
          builder: (context, args, params) {
            return HomePage(
              tabIndex: params.param('tabIndex') ?? 0.toString(),
            );
          },
          params: [
            SailorParam(name: 'tabIndex', defaultValue: 0, isRequired: false),
            SailorParam(name: 'ownProfileSaved')
          ]),
      SailorRoute(
          name: "/community",
          builder: (context, args, params) {
            return HomePage(
              tabIndex: params.param('tabIndex') ?? 0.toString(),
              isFriendRequest: params.param('isFriendRequest'),
            );
          },
          params: [
            SailorParam(name: 'tabIndex', defaultValue: 0, isRequired: false),
            SailorParam(name: 'isFriendRequest')
          ]),
      SailorRoute(
          name: "/messsage_DM",
          builder: (context, args, params) {
            return HomePage(
              tabIndex: params.param('tabIndex') ?? 0.toString(),
              status: params.param('status') ?? "",
              userId: params.param('userId') ?? 0.toString(),
              chatId: params.param('chatId') ?? 0.toString(),
              otherUserName: params.param('otherUserName') ?? "",
              messageType: "DM",
            );
            //   ChatBasePage(
            //   status: params.param('status') ?? "",
            //   userId: params.param('userId') ?? 0.toString(),
            //   chatId: params.param('chatId') ?? 0.toString(),
            //   otherUserName: params.param('otherUserName') ?? "",
            // );
          },
          params: [
            SailorParam(name: 'tabIndex'),
            SailorParam(name: 'status'),
            SailorParam(name: 'userId'),
            SailorParam(name: 'chatId'),
            SailorParam(name: 'otherUserName'),
          ]),
      SailorRoute(
          name: "/post",
          builder: (context, args, params) {
            return HomePage(
              tabIndex: params.param('tabIndex') ?? 0,
              postId: params.param('postId') ?? 0,
            );
          },
          params: [
            SailorParam(name: 'tabIndex'),
            SailorParam(name: 'postId'),
          ]),
      SailorRoute(
          name: "/messsage_Group",
          builder: (context, args, params) {
            return HomePage(
              tabIndex: params.param('tabIndex') ?? 0.toString(),
              status: params.param('status') ?? "",
              userId: params.param('userId') ?? 0.toString(),
              chatId: params.param('chatId') ?? 0.toString(),
              otherUserName: params.param('otherUserName') ?? "",
              messageType: "Group",
            );
          },
          params: [
            SailorParam(name: 'tabIndex'),
            SailorParam(name: 'userId'),
            SailorParam(name: 'status'),
            SailorParam(name: 'chatId'),
            SailorParam(name: 'otherUserName'),
          ]),
      SailorRoute(
          name: "/likes",
          builder: (context, args, params) {
            return HomePage(
              tabIndex: params.param('tabIndex') ?? 0.toString(),
              userId: params.param('userid'),
              matchType: "likes",
            );
          },
          params: [
            SailorParam(name: 'tabIndex'),
            SailorParam(name: 'userid', defaultValue: 0, isRequired: false),
          ]),
      SailorRoute(
          name: "/matches",
          builder: (context, args, params) {
            return HomePage(
              tabIndex: params.param('tabIndex') ?? 0.toString(),
              userId: params.param('userid'),
              matchType: "matches",
            );

            //   CommunityProfile(
            //   userId: params.param('userid'),
            // );
          },
          params: [
            SailorParam(name: 'tabIndex'),
            SailorParam(name: 'userid', defaultValue: 0, isRequired: false),
          ]),
      SailorRoute(
          name: "/shop",
          builder: (context, args, params) {
            return HomePage(
              tabIndex: params.param('tabIndex') ?? 0.toString(),
              isShop: params.param('isShop'),
            );
          },
          params: [
            SailorParam(name: 'tabIndex'),
            SailorParam(name: 'isShop', defaultValue: false, isRequired: false),
          ]),
    ]);
  }
}
