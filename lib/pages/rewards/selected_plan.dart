import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:pure_match/common/global.dart';
import 'package:pure_match/models/premium_plan.dart';
import 'package:pure_match/pages/AppColors.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:pure_match/pages/rewards/premium_welcome.dart';
import 'package:pure_match/pages/shop/rewards_base.dart';
import 'package:amplitude_flutter/amplitude.dart';
import 'package:intl/intl.dart';

import '../MyHttp.dart';

// ignore: must_be_immutable
class SelectedPlan extends StatefulWidget {
  final PremiumPlan plan;
  final Function(int, int) insufficientBalance;
  final bool isCash;
  // const Awards({Key key, this.rewardspages, this.onSelectSpendMyPureGems})
  //     : super(key: key);

  const SelectedPlan(
      {Key key, this.plan, this.insufficientBalance, this.isCash})
      : super(key: key);

  @override
  _SelectedPlanState createState() => _SelectedPlanState();
}

class _SelectedPlanState extends State<SelectedPlan> {
  // Analytics code
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';

  var balance;
  var now;
  String duration;
  StreamSubscription _purchaseUpdatedSubscription;
  StreamSubscription _purchaseErrorSubscription;
  StreamSubscription _conectionSubscription;
  bool isFeburary = false;
  bool isAprile = true;
  String price1 = "";
  final List<String> _productLists = Platform.isAndroid
      ? ["123"]
      : [
          'com.purematch.yearly',
          'com.purematch.3month',
          'com.purematch.6months',
          'com.purematch.month'
        ];

  String _platformVersion = 'Unknown';
  List<IAPItem> _items = [];
  List<PurchasedItem> _purchases = [];

  @override
  void initState() {
    // DateTime today = DateTime.now();
    // if (today.month == 2) {
    //   isFeburary = true;
    // } else if (today.month == 3) {
    //   isAprile = true;
    // }

    price1 = (widget.plan.duration == "1 Month")
        ? widget.plan.dollar_cost.toString() + "/month"
        : (widget.plan.duration == "3 Months")
            ? Global.getNumber(widget.plan.dollar_cost / 3, precision: 2)
                    .toString() +
                "/month"
            : (widget.plan.duration == "6 Months")
                ? Global.getNumber(widget.plan.dollar_cost / 6, precision: 2)
                        .toString() +
                    "/month"
                : Global.getNumber(widget.plan.dollar_cost / 12, precision: 2)
                        .toString() +
                    "/month";

    _getGemBalance();
    if (Platform.isAndroid) {
      _productLists.add(widget.plan.item_id.toString());
    }

    print(_productLists);
    //Analytics code
    amplitudeAnalytics.init(apiKey);

    now = new DateTime.now();
    print("******");
    var formatter = new DateFormat.yMEd();

    switch (widget.plan.duration) {
      case "12 Months":
        now = now.add(Duration(days: 365));
        break;
      case "6 Months":
        now = now.add(Duration(days: 180));
        break;
      case "3 Months":
        now = now.add(Duration(days: 90));
        break;
      case "1 Month":
        now = now.add(Duration(days: 30));
        break;
    }

    duration = formatter.format(now);
    // 2016-01-25
    setState(() {});
    super.initState();
    //Analytics tracking code
    amplitudeAnalytics.init(apiKey);
    analytics.setCurrentScreen(
        screenName: "premium_plan_payment",
        screenClassOverride: "premium_plan_payment");
    amplitudeAnalytics.logEvent("premium_plan_payment_page");

    initPlatformState();
  }

  @override
  void dispose() {
    if (_conectionSubscription != null) {
      _conectionSubscription.cancel();
      _conectionSubscription = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    double mediaWidth = MediaQuery.of(context).size.width;
    return PlatformScaffold(
        backgroundColor:
            (isFeburary || isAprile) ? Colors.white : AppColors.blueColor,
        appBar: PlatformAppBar(
          material: (_, __) => MaterialAppBarData(
            backgroundColor:
                (isFeburary || isAprile) ? Colors.white : AppColors.blueColor,
            elevation: 0.0,
            leading: IconButton(
              padding: EdgeInsetsDirectional.only(start: 10.0),
              icon: Icon(
                Icons.arrow_back,
                color: (isFeburary || isAprile)
                    ? AppColors.blackColor
                    : Colors.white,
                size: 25,
              ),
              iconSize: 30,
              onPressed: () {
                Navigator.pop(context);

                //Analytics tracking code
                amplitudeAnalytics.init(apiKey);
                analytics.setCurrentScreen(
                    screenName: "account_settings",
                    screenClassOverride: "account_settings");
                amplitudeAnalytics.logEvent("account_settings_page");
              },
            ),
          ),
          cupertino: (_, __) => CupertinoNavigationBarData(
              brightness: Brightness.dark,
              automaticallyImplyLeading: false,
              automaticallyImplyMiddle: false,
              backgroundColor:
                  (isFeburary || isAprile) ? Colors.white : AppColors.blueColor,
              border: Border(bottom: BorderSide.none),
              padding: EdgeInsetsDirectional.only(start: 10.0),
              leading: CupertinoNavigationBarBackButton(
                  color: (isFeburary || isAprile)
                      ? AppColors.blackColor
                      : Colors.white,
                  previousPageTitle: null,
                  onPressed: () {
                    Navigator.pop(context);

                    //Analytics tracking code
                    amplitudeAnalytics.init(apiKey);
                    analytics.setCurrentScreen(
                        screenName: "account_settings",
                        screenClassOverride: "account_settings");
                    amplitudeAnalytics.logEvent("account_settings_page");
                  })),
        ),
        body: SafeArea(
            child: SingleChildScrollView(
                child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "Selected Plan",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: (isFeburary || isAprile)
                                    ? AppColors.blueColor
                                    : Colors.white),
                          ),
                          SizedBox(
                            height: 15.0,
                          ),
                          Text(
                            (!widget.isCash)
                                ? "Pure Match Premium \n${widget.plan.duration} for ${widget.plan.gem_cost} gems \nSet to expire on ${duration}"
                                : "Pure Match Premium \n${widget.plan.duration} for \$${widget.plan.dollar_cost} \nRenews automatically on ${duration}",
                            style: TextStyle(
                                fontSize: 16,
                                color: (isFeburary || isAprile)
                                    ? AppColors.blueColor
                                    : Colors.white,
                                fontWeight: FontWeight.w500,
                                fontStyle: FontStyle.normal),
                            textAlign: TextAlign.left,
                          ),
                          SizedBox(
                            height: 20.0,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Benefits of Premium",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 28,
                                    color: (isFeburary || isAprile)
                                        ? AppColors.blackColor
                                        : Colors.white),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 22,
                          ),
                          Global.premiumTexts(
                            context,
                            (isFeburary || isAprile)
                                ? AppColors.blackColor
                                : Colors.white,
                            AppConfig.fontsizeForSmallDevice(context, 18),
                          ),
                          SizedBox(
                            height: 25,
                          ),
                          SizedBox(
                            height: 12,
                          ),
                          Visibility(
                            visible: !widget.isCash,
                            child: Center(
                              child: Visibility(
                                visible: (!isFeburary || isAprile),
                                child: SizedBox(
                                  width: mediaWidth * 0.84,
                                  height: 60,
                                  child: PlatformButton(
                                    disabledColor: AppColors.greyColor,
                                    color: AppColors.redColor,
                                    onPressed: () {
                                      _alertUser(
                                          context,
                                          "Confirm Purchase",
                                          "Unlock ${widget.plan.duration} of Pure Match Premium for ${widget.plan.gem_cost} Pure Gems?",
                                          "Unlock");
                                    },
                                    child: FittedBox(
                                      child: Text(
                                        "Subscribe with Pure Gems 💎",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 20),
                                      ),
                                    ),
                                    materialFlat: (_, __) =>
                                        MaterialFlatButtonData(
                                      disabledColor: AppColors.greyColor,
                                      color: AppColors
                                          .matchBrowseMatchReactivateMatching,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    cupertino: (_, __) => CupertinoButtonData(
                                      borderRadius: BorderRadius.circular(10),
                                      color: AppColors
                                          .matchBrowseMatchReactivateMatching,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Visibility(
                            visible: !widget.isCash,
                            child: SizedBox(
                              height: 10,
                            ),
                          ),
                          Visibility(
                            visible: widget.isCash,
                            child: Center(
                              child: SizedBox(
                                width: mediaWidth * 0.84,
                                height: 60,
                                child: PlatformButton(
                                  disabledColor: AppColors.greyColor,
                                  color: AppColors.redColor,
                                  onPressed: () {
                                    _requestPurchase(widget.plan);
                                    //  _purchaseUsingCash(widget.plan);
                                  },
                                  child: (Platform.isIOS)
                                      ? Text(
                                          "Subscribe with  Pay",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: (isFeburary || isAprile)
                                                ? Colors.white
                                                : Colors.black,
                                            fontWeight: FontWeight.w700,
                                            fontSize: AppConfig
                                                .heightWithDForSmallDevice(
                                                    context, 20, 5),
                                          ),
                                        )
                                      : Text(
                                          "Subscribe with Google Pay",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: (isFeburary || isAprile)
                                                  ? Colors.white
                                                  : Colors.black,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 20),
                                        ),
                                  materialFlat: (_, __) =>
                                      MaterialFlatButtonData(
                                    disabledColor: AppColors.greyColor,
                                    color: (isFeburary || isAprile)
                                        ? Colors.black
                                        : AppColors.offWhiteColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  cupertino: (_, __) => CupertinoButtonData(
                                    borderRadius: BorderRadius.circular(10),
                                    color: (isFeburary || isAprile)
                                        ? Colors.black
                                        : AppColors.greyColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Padding(
                              padding: EdgeInsets.only(
                                  left: 25.0,
                                  right: 25.0,
                                  top: 10.0,
                                  bottom: 10.0),
                              child: Wrap(
                                spacing: 0.0,
                                runSpacing: 2.0,
                                direction: Axis.horizontal,
                                alignment: WrapAlignment.center,
                                children: [
                                  Text(
                                    "Billed as one payment. Recurring billing, cancel any time. ",
                                    style: TextStyle(
                                        color: AppColors.blackColor,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600),
                                    textAlign: TextAlign.center,
                                  ),
                                  Text(
                                      "I understand that my app store account will be charged after confirmation of purchase, and that my subscription will automatically renew for the same package length at the same price until I cancel in my Account Settings at least 24 hours prior to the end of the current period.  Subscriptions may be managed by the user and auto-renewal may be turned off by going to the user’s Account Settings after purchase."),
                                ],
                              ),
                            ),
                          ),
                        ])))));
  }

  void _alertUser(
      BuildContext context, String title, String content, String button) {
    showDialog(
      context: context,
      builder: (_) => PlatformAlertDialog(
        title: Text(title,
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
        content: Text(content,
            style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w400, height: 1.5)),
        material: (_, __) => MaterialAlertDialogData(
          elevation: 1.0,
          actions: <Widget>[
            TextButton(
                child: Text(button,
                    style: TextStyle(
                        color: AppColors.communityProfileOptionsBlueColor,
                        fontWeight: FontWeight.w600)),
                onPressed: () {
                  print(button);
                  if (button == "Unlock") {
                    print("reached");
                    _purchaseUsingGems(widget.plan);
                  } else if (button == "Add Gems") {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => RewardsBase()));
                    analytics.setCurrentScreen(
                        screenName: "rewards_awards",
                        screenClassOverride: "rewards_awards");
                    amplitudeAnalytics.logEvent("rewards_awards_page");
                  }
                }),
            TextButton(
                child: Text("Cancel",
                    style: TextStyle(
                        color: AppColors.communityProfileOptionsRedColor,
                        fontWeight: FontWeight.w600)),
                onPressed: () {
                  // Update user model is friend request sent successfully
                  Navigator.of(context).pop();
                }),
          ],
        ),
        cupertino: (_, __) => CupertinoAlertDialogData(actions: <Widget>[
          CupertinoButton(
            child: Text(button,
                style: TextStyle(
                    color: AppColors.communityProfileOptionsBlueColor,
                    fontWeight: FontWeight.w600)),
            onPressed: () {
              print(button);
              if (button == "Unlock") {
                Navigator.of(context).pop();
                _purchaseUsingGems(widget.plan);
              } else if (button == "Add Gems") {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => RewardsBase()));
                analytics.setCurrentScreen(
                    screenName: "rewards_awards",
                    screenClassOverride: "rewards_awards");
                amplitudeAnalytics.logEvent("rewards_awards_page");
              }
            },
          ),
          CupertinoButton(
            child: Text("Cancel",
                style: TextStyle(
                    color: AppColors.communityProfileOptionsRedColor,
                    fontWeight: FontWeight.w600)),
            onPressed: () {
              Navigator.of(context).pop();
              //todo add analytics code here
            },
          ),
        ]),
      ),
      barrierDismissible: true,
    ).then((value) {});
  }

  void _purchaseUsingGems(PremiumPlan p) async {
    try {
      var res =
          await MyHttp.post("shop/purchase/${p.item_id}/premium/gems", {});
      if (res.statusCode == 201 || res.statusCode == 200) {
        //Analytics tracking code
        analytics.logEvent(name: "pg_purchase", parameters: <String, dynamic>{
          "item": p.type,
          "value": p.gem_cost.toString(),
          "amount": p.dollar_cost.toString()
        });

        amplitudeAnalytics.logRevenue(p.type, 1, p.dollar_cost);
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => PremiumWelcome()));
      } else if (res.statusCode == 403) {
        Navigator.pop(context);
        widget.insufficientBalance(widget.plan.gem_cost - balance, balance);
      }
    } catch (e) {
      print("Err $e");
    }
  }

  void _getGemBalance() async {
    try {
      var res = await MyHttp.get("shop/gem-balance");
      if (res.statusCode == 200 || res.statusCode == 201) {
        var jsondata = jsonDecode(res.body);
        balance = jsondata["balance"];
        print(balance);
      }
    } catch (e) {}
  }

  void _purchaseUsingCash(PremiumPlan p) async {
    try {
      var res =
          await MyHttp.post("shop/purchase/${p.item_id}/premium/cash", {});
      if (res.statusCode == 201 || res.statusCode == 200) {
        //Analytics code
        analytics.logEvent(name: "ia_purchase", parameters: <String, dynamic>{
          "item": p.type,
          "amount": p.dollar_cost
        });
        amplitudeAnalytics.logRevenue(p.type, 1, p.dollar_cost.toDouble());

        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => PremiumWelcome()));
      } else {
        print(res.statusCode);
      }
    } catch (e) {
      print("Err $e");
    }
  }

  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await FlutterInappPurchase.instance.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // prepare
    var result = await FlutterInappPurchase.instance.initConnection;
    print('result: $result');

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });

    // refresh items for android
    try {
      String msg = await FlutterInappPurchase.instance.consumeAllItems;
      print('consumeAllItems: $msg');
    } catch (err) {
      print('consumeAllItems error: $err');
    }

    _conectionSubscription =
        FlutterInappPurchase.connectionUpdated.listen((connected) {
      print('connected: $connected');
    });

    _purchaseUpdatedSubscription =
        FlutterInappPurchase.purchaseUpdated.listen((productItem) {
      print('purchase-updated: $productItem');
      _purchaseUsingCash(widget.plan);
    });

    _purchaseErrorSubscription =
        FlutterInappPurchase.purchaseError.listen((purchaseError) {
      print('purchase-error: $purchaseError');
    });
    await _getProduct();
    await _getPurchaseHistory();
    await _getPurchases();
  }

  Future _getPurchases() async {
    List<PurchasedItem> items =
        await FlutterInappPurchase.instance.getAvailablePurchases();
    for (var item in items) {
      print('${item.toString()}');
      this._purchases.add(item);
    }

    setState(() {
      if (this._items.length == 0) {
        this._items = [];
      }

      this._purchases = items;
    });
  }

  Future _getPurchaseHistory() async {
    List<PurchasedItem> items =
        await FlutterInappPurchase.instance.getPurchaseHistory();
    for (var item in items) {
      print('${item.toString()}');
      this._purchases.add(item);
    }

    setState(() {
      if (this._items.length == 0) {
        this._items = [];
      }
      this._purchases = items;
    });
  }

  void _requestPurchase(PremiumPlan item) {
    print(item.item_id);
    if (Platform.isAndroid) {
      FlutterInappPurchase.instance.requestPurchase(item.item_id.toString());
    } else {
      if (item.item_id.toString() == "20104") {
        for (var item in this._items) {
          if (item.productId.toString() == 'com.purematch.month') {
            FlutterInappPurchase.instance
                .requestPurchase('com.purematch.month');
            break;
          }
        }
      } else if (item.item_id.toString() == "20101") {
        for (var item in this._items) {
          if (item.productId.toString() == 'com.purematch.yearly') {
            FlutterInappPurchase.instance
                .requestPurchase('com.purematch.yearly');
            break;
          }
        }
      } else if (item.item_id.toString() == "20102") {
        for (var item in this._items) {
          if (item.productId.toString() == 'com.purematch.6months') {
            FlutterInappPurchase.instance
                .requestPurchase('com.purematch.6months');
            break;
          }
        }
      } else if (item.item_id.toString() == "20103") {
        for (var item in this._items) {
          if (item.productId.toString() == 'com.purematch.3month') {
            FlutterInappPurchase.instance
                .requestPurchase('com.purematch.3month');
            break;
          }
        }
      } else {}
    }
  }

  Future _getProduct() async {
    List<IAPItem> items = [];
    if (Platform.isAndroid) {
      items =
          await FlutterInappPurchase.instance.getSubscriptions(_productLists);
    } else {
      items = await FlutterInappPurchase.instance.getProducts(_productLists);
    }
    for (var item in items) {
      print('${item.toString()}');
      this._items.add(item);
    }
    print("******GETTING PRODUCTS FROM STORE*****");
    print(items);

    setState(() {
      this._items = items;
      if (this._purchases.length == 0) {
        this._purchases = [];
      }
    });
  }
}
