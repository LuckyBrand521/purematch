import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pure_match/pages/feed/my_feed.dart';
import 'package:pure_match/pages/onboarding/CheckYourEmail.dart';
import 'package:pure_match/pages/onboarding/NewQuestions.dart';
import 'package:pure_match/pages/onboarding/ThankYouQues.dart';
import 'package:pure_match/pages/onboarding/basic_info/location_tutorial.dart';
import 'package:pure_match/pages/onboarding/basic_info/user_birth_date.dart';
import 'package:pure_match/pages/onboarding/basic_info/user_body_type.dart';
import 'package:pure_match/pages/onboarding/basic_info/user_church.dart';
import 'package:pure_match/pages/onboarding/basic_info/user_education.dart';
import 'package:pure_match/pages/onboarding/basic_info/user_email.dart';
import 'package:pure_match/pages/onboarding/basic_info/user_ethnicity.dart';
import 'package:pure_match/pages/onboarding/basic_info/user_gender.dart';
import 'package:pure_match/pages/onboarding/basic_info/user_kids.dart';
import 'package:pure_match/pages/onboarding/basic_info/user_location.dart';
import 'package:pure_match/pages/onboarding/basic_info/user_location_text.dart';
import 'package:pure_match/pages/onboarding/basic_info/user_married.dart';
import 'package:pure_match/pages/onboarding/basic_info/user_name.dart';
import 'package:pure_match/pages/onboarding/basic_info/user_refered_by.dart';
import 'package:pure_match/pages/onboarding/basic_info/user_spiritual_birthday.dart';
import 'package:pure_match/pages/onboarding/basic_info/user_work.dart';
import 'package:pure_match/pages/onboarding/first_welcome.dart';
import 'package:pure_match/pages/onboarding/login/login.dart';
import 'package:pure_match/pages/onboarding/login/welcome_back.dart';
import 'package:pure_match/pages/onboarding/moderator_notes.dart';
import 'package:pure_match/pages/onboarding/profile_info/DisabledNotification.dart';
import 'package:pure_match/pages/onboarding/profile_info/about_yourself.dart';
import 'package:pure_match/pages/onboarding/profile_info/awsome_done.dart';
import 'package:pure_match/pages/onboarding/profile_info/enableNotification.dart';
import 'package:pure_match/pages/onboarding/profile_info/favorite_verse.dart';
import 'package:pure_match/pages/onboarding/profile_info/love_language.dart';
import 'package:pure_match/pages/onboarding/profile_info/personality_type.dart';
import 'package:pure_match/pages/onboarding/profile_info/profile_photo.dart';
import 'package:pure_match/pages/onboarding/profile_info/user_dating_preference.dart';
import 'package:pure_match/pages/onboarding/profile_info/user_interests.dart';

import 'package:pure_match/pages/onboarding/sign_up.dart';
import 'package:pure_match/pages/onboarding/soFarSoGood.dart';
import 'package:pure_match/pages/onboarding/verified_create_account.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:amplitude_flutter/amplitude.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:pure_match/routes.dart';
import 'package:sailor/sailor.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'common/global.dart';
import 'pages/AppColors.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  print('Handling a background message ${message.messageId}');
}

/// Create a [AndroidNotificationChannel] for heads up notifications
const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  'This channel is used for important notifications.', // description
  importance: Importance.high,
);

/// Initialize the [FlutterLocalNotificationsPlugin] package.
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  Routes.createRoutes();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Set the background messaging handler early on, as a named top-level function
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  /// Create an Android Notification Channel.
  ///
  /// We use this channel in the `AndroidManifest.xml` file to override the
  /// default FCM channel to enable heads up notifications.
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  /// Update the iOS foreground notification presentation options to allow
  /// heads up notifications.
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    Brightness brightness = Brightness.light;
    final materialTheme = new ThemeData(
        fontFamily: 'AvenirNext', primaryColor: AppColors.blackColor);

    final materialDarkTheme = new ThemeData(
      brightness: Brightness.dark,
      primarySwatch: Colors.teal,
    );
    final cupertinoTheme = new CupertinoThemeData(
        textTheme: CupertinoTextThemeData(
            primaryColor: Colors.white,
            textStyle: TextStyle(
                fontFamily: "AvenirNext", color: AppColors.blackColor)));

    config();

    return Theme(
      data: brightness == Brightness.light ? materialTheme : materialDarkTheme,
      child: PlatformProvider(
        //initialPlatform: initialPlatform,
        builder: (context) => PlatformApp(
          localizationsDelegates: <LocalizationsDelegate<dynamic>>[
            DefaultMaterialLocalizations.delegate,
            DefaultWidgetsLocalizations.delegate,
            DefaultCupertinoLocalizations.delegate,
          ],
          title: 'Pure Match',
          material: (_, __) {
            return new MaterialAppData(
              debugShowCheckedModeBanner: false,
              theme: materialTheme,
              darkTheme: materialTheme,
              themeMode: brightness == Brightness.light
                  ? ThemeMode.light
                  : ThemeMode.dark,
            );
          },
          cupertino: (_, __) => new CupertinoAppData(
            theme: cupertinoTheme,
            debugShowCheckedModeBanner: false,
          ),
          onGenerateRoute: Routes.sailor.generator(),
          navigatorKey: Routes.sailor.navigatorKey,
          home: MyHomePage(title: "Pure Match App"),
        ),
      ),
    );
  }
}

void config() {
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Analytics code
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';

  int i = 0;

  Future<void> _isLoggedIn() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification notification = message.notification;
      AndroidNotification android = message.notification?.android;
      print("message received");
      print(message);
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channel.description,
                // TODO add a proper drawable resource to android, for now using
                //      one that already exists in example app.
                icon: 'launch_background',
              ),
            ));
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      _navigateToItemDetail(message.data);
    });

    var sp = await SharedPreferences.getInstance();
    int id = sp.getInt("id");
    if (id != null) {
      Global.onboardingId = await Global.getOnboardingId();
      int onboardingId = Global.onboardingId;
      if (onboardingId != -1) {
        // goContinueOnboarding(onboardingId);
        print("the user was in onboarding screen");
      } else {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => WelcomeBack()));
      }
    } else {
      print("Id is null");
    }
  }

  void goContinueOnboarding(int onboardingId) {
    if (onboardingId == 1) {
      Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => VerifiedCreateAccount()));
    } else if (onboardingId == 2) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => FirstWelcome()));
    } else if (onboardingId == 3) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => ModeratorNotes()));
    } else if (onboardingId == 4) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => NewQuestions()));
    } else if (onboardingId == 5) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => ThankYouQues()));
    } else if (onboardingId == 6) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => UserEmail()));
    } else if (onboardingId == 7) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => UserName()));
    } else if (onboardingId == 8) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => UserBirthDate()));
    } else if (onboardingId == 9) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => UserLocation()));
    } else if (onboardingId == 10) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => UserReferredBy()));
    } else if (onboardingId == 11) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => UserChurch()));
    } else if (onboardingId == 12) {
      Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => UserSpiritualBirthDate()));
    } else if (onboardingId == 13) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => UserGender()));
    } else if (onboardingId == 14) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => UserMarried()));
    } else if (onboardingId == 15) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => UserBodyType()));
    } else if (onboardingId == 16) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => UserEthnicity()));
    } else if (onboardingId == 17) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => UserEducation()));
    } else if (onboardingId == 18) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => UserWork()));
    } else if (onboardingId == 19) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => UserKids()));
    } else if (onboardingId == 20) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => SoFarSoGood()));
    } else if (onboardingId == 21) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => ProfilePhoto()));
    } else if (onboardingId == 22) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => AboutYourself()));
    } else if (onboardingId == 23) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => FavoriteVerse()));
    } else if (onboardingId == 24) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => UserInterests()));
    } else if (onboardingId == 25) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => PersonalityType()));
    } else if (onboardingId == 26) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => LoveLanguage()));
    } else if (onboardingId == 27) {
      Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => UserDatingPreference()));
    } else if (onboardingId == 28) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => AwesomeDone()));
    } else if (onboardingId == 29) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => CheckYourEmail()));
    } else if (onboardingId == 30) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => EnableNotification()));
    } else if (onboardingId == 31) {
      Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => DisabledNotification()));
    } else if (onboardingId == 32) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => LocationTutorial()));
    } else if (onboardingId == 33) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => UserLocationTxt()));
    }
  }

  @override
  void initState() {
    this._isLoggedIn();
    super.initState();
  }

  void _navigateToItemDetail(Map<String, dynamic> message) async {
    var sp = await SharedPreferences.getInstance();
    int userid = sp.getInt("id");
    if (userid == null) {
      return;
    }

    print("checkk");
    print(message);
    final pagechooser = message['data']['route'].toString();
    final id = int.parse(message['data']['id']);
    print("********$id");
    switch (pagechooser) {
      case "/community":
        Routes.sailor.navigate("/community",
            params: {'isFriendRequest': true},
            navigationType: NavigationType.push,
            removeUntilPredicate: (Route<dynamic> route) => false);
        break;
      case "/feed":
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => MyFeed()));
        break;
      case "/messsage":
        final status = message['data']['status'].toString();
        final chat_id = message['data']['chatId'].toString();
        final chatId = double.parse(chat_id).round();
        final otherUserName = message['data']['otherUserName'].toString();
        final type = message['data']['type'].toString();
        (type == "Group")
            ? Routes.sailor.navigate("/messsage_Group",
                params: {
                  'tabIndex': 2,
                  'userId': id,
                  'status': status,
                  'chatId': chatId,
                  'otherUserName': otherUserName,
                  'type': "Group"
                },
                navigationType: NavigationType.push,
                removeUntilPredicate: (Route<dynamic> route) => false)
            : Routes.sailor.navigate("/messsage_DM",
                params: {
                  'tabIndex': 2,
                  'userId': id,
                  'status': status,
                  'chatId': chatId,
                  'otherUserName': otherUserName,
                  'type': "DM"
                },
                navigationType: NavigationType.push,
                removeUntilPredicate: (Route<dynamic> route) => false);
        break;
      case "/likes":
        Routes.sailor.navigate("/likes",
            params: {'tabIndex': 1, 'userid': id},
            navigationType: NavigationType.push,
            removeUntilPredicate: (Route<dynamic> route) => false);
        break;
      case "/matches":
        Routes.sailor.navigate("/matches",
            params: {'tabIndex': 1, 'userid': id},
            navigationType: NavigationType.push,
            removeUntilPredicate: (Route<dynamic> route) => false);
        break;
      case "/post":
        Routes.sailor.navigate("/post",
            params: {'tabIndex': 0, 'postId': id},
            navigationType: NavigationType.push,
            removeUntilPredicate: (Route<dynamic> route) => false);
        break;
      default:
        Routes.sailor.navigate("/homes",
            navigationType: NavigationType.push,
            removeUntilPredicate: (Route<dynamic> route) => false);
    }
  }

  _launchTermsURL() async {
    const url = 'https://purematch.co/terms-of-service/';
    launch(url);
  }

  _launchPrivacyURL() async {
    const url = 'https://purematch.co/privacy-policy/';
    launch(url);
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return ScreenUtilInit(
      designSize: Size(750, 1334),
      builder: () => Scaffold(
          body: SingleChildScrollView(
        child: SizedBox(
          height: height,
          child: Center(
              child: Column(
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: 70,
                  ),
                  Container(
                    height:
                        AppConfig.heightWithDForSmallDevice(context, 160, 40),
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage('assets/images/logo.png'))),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                ],
              ),
              Spacer(),
              SizedBox(
                height: AppConfig.heightWithDForSmallDevice(context, 60, 10),
                width: AppConfig.heightWithDForSmallDevice(context, 350, 70),
                child: PlatformButton(
                  padding: EdgeInsets.all(
                    AppConfig.heightWithDForSmallDevice(context, 15, 5),
                  ),
                  color: AppColors.blueColor,
                  disabledColor: AppColors.blueColor,
                  materialFlat: (_, __) => MaterialFlatButtonData(
                    color: AppColors.blueColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  cupertino: (_, __) => CupertinoButtonData(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text("Log In",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 18)),
                  ),
                  onPressed: () {
                    // if (Global.onboardingId != -1) {
                    //   goContinueOnboarding(Global.onboardingId);
                    // } else {
                    //   Navigator.push(context,
                    //       MaterialPageRoute(builder: (context) => LoginPage()));
                    // }
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => LoginPage()));                    
                  },
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Visibility(
                visible: false,
                child: SizedBox(
                  height: 60,
                  width: AppConfig.heightWithDForSmallDevice(context, 350, 300),
                  child: PlatformButton(
                    onPressed: () {},
                    padding: EdgeInsets.all(15),
                    color: AppColors.facebookButtonColor,
                    disabledColor: AppColors.facebookButtonColor,
                    materialFlat: (_, __) => MaterialFlatButtonData(
                      color: AppColors.facebookButtonColor,
                      disabledColor: AppColors.facebookButtonColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    cupertino: (_, __) => CupertinoButtonData(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          child: Image.asset(
                            'assets/images/facebook.png',
                            height: 25,
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          "Log In with Facebook",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              InkWell(
                  child: Text("Sign Up",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 16,
                          color: AppColors.blackColor,
                          fontWeight: FontWeight.w600,
                          fontStyle: FontStyle.normal,
                          decoration: TextDecoration.underline)),
                  onTap: () {
                    if (Global.onboardingId != -1) {
                      goContinueOnboarding(Global.onboardingId);
                    } else {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SignUpPage()));
                      //Analytics tracking code
                      analytics.setCurrentScreen(
                          screenName: "sign_up",
                          screenClassOverride: "sign_up");
                      amplitudeAnalytics.logEvent("sign_up_page");
                    } //SignUp//SignUp
                  }),
              SizedBox(
                height: 20,
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding:
                      EdgeInsets.only(left: 25.0, right: 25.0, bottom: 40.0),
                  child: Wrap(
                    spacing: 0.0,
                    runSpacing: 2.0,
                    direction: Axis.horizontal,
                    alignment: WrapAlignment.center,
                    children: [
                      Text(
                        "By continuing, you agree to our ",
                        style: TextStyle(
                            color: AppColors.blackColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w400),
                      ),
                      InkWell(
                        child: Text("Terms",
                            //textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 12,
                                color: AppColors.blackColor,
                                fontWeight: FontWeight.w400,
                                fontStyle: FontStyle.normal,
                                decoration: TextDecoration.underline)),
                        onTap: () => _launchTermsURL(),
                      ),
                      Text(
                        " and ",
                        style: TextStyle(
                            color: AppColors.blackColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w400),
                      ),
                      InkWell(
                        child: Text("Privacy Policy",
                            //textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 12,
                                color: AppColors.blackColor,
                                fontWeight: FontWeight.w400,
                                fontStyle: FontStyle.normal,
                                decoration: TextDecoration.underline)),
                        onTap: () => _launchPrivacyURL(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )),
        ),
      )),
    );
  }
}
