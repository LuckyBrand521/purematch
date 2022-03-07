import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:pure_match/common/global.dart';
import 'package:pure_match/models/shop_items.dart';
import 'package:pure_match/pages/rewards/plan.dart';
import 'package:pure_match/pages/shop/awards.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:amplitude_flutter/amplitude.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../AppColors.dart';
import '../MyHttp.dart';

class Shop extends StatefulWidget {
  final RewardsPages rewardspages;

  const Shop({Key key, this.rewardspages}) : super(key: key);
  @override
  _ShopState createState() => _ShopState();
}

class _ShopState extends State<Shop> {
  // Analytics code
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final Amplitude amplitudeAnalytics =
      Amplitude.getInstance(instanceName: "PURE MATCH");
  String apiKey = '838a6955ebda06fc6ba6064298dd8a7a';

  bool _loading = false;
  bool status;
  StreamSubscription _purchaseUpdatedSubscription;
  StreamSubscription _purchaseErrorSubscription;
  StreamSubscription _conectionSubscription;

  final List<String> _productLists = Platform.isAndroid
      ? ["check123"]
      : [
          'com.purematch.gripgem',
          'com.purematch.smallgem',
          'com.purematch.biggem',
          'com.purematch.baggem',
          'com.purematch.bagsgems',
          'com.purematch.chestgems'
        ];

  String _platformVersion = 'Unknown';
  List<IAPItem> _items = [];
  List<PurchasedItem> _purchases = [];
  double mediaWidth;
  double mediaHeight;
  double cardWidth;
  double padding_x;
  ShopItem si;
  IAPItem iapItem;
  List _extras = [];
  List _gemBundles = [];
  var balance = 0;
  bool hasCompletedRisingStar = false;
  bool hasCompletedAmbassador = false;
  bool hasCompletedConnector = false;
  bool hasCompletedEvangelist = false;
  bool hasCompletedMatchmaker = false;
  bool hasCompletedSuperstar = false;

  @override
  Widget build(BuildContext context) {
    mediaWidth = MediaQuery.of(context).size.width;
    mediaHeight = MediaQuery.of(context).size.height;
    padding_x = mediaWidth * 0.053;
    // cardWidth = (AppConfig.fullWidth(context) > 375)
    //     ? (AppConfig.fullWidth(context) - padding_x - padding_x - 16) / 2
    //     : (AppConfig.fullWidth(context) == 375)
    //         ? (AppConfig.fullWidth(context) - mediaWidth * 0.053 - mediaWidth * 0.053) / 2
    //         : (AppConfig.fullWidth(context) - 22) / 2;
    cardWidth = (AppConfig.fullWidth(context) >= 375)
        ? (AppConfig.fullWidth(context) -
                padding_x -
                padding_x -
                mediaWidth * 0.038) /
            2
        : (AppConfig.fullWidth(context) - 22) / 2;

    return Scaffold(
      backgroundColor: AppColors.greyColor,
      body: SafeArea(
        child: (this._loading) ? this._showLoading() : shop(),
      ),
    );
  }

  @override
  void initState() {
    _getGemBalance();
    _getStatus();
    _getData();
    //Initializing amplitude analytics api key
    amplitudeAnalytics.init(apiKey);

    setState(() {});
    super.initState();
    initPlatformState();
  }

  @override
  void dispose() {
    if (_conectionSubscription != null) {
      _conectionSubscription.cancel();
      _conectionSubscription = null;
    }
    super.dispose();
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
      print("purchase uppdate subscription");
      print('purchase-updated: $productItem');
      _getGemBalance();
    });

    _purchaseErrorSubscription =
        FlutterInappPurchase.purchaseError.listen((purchaseError) {
      print('purchase-error: $purchaseError');
    });

    // await _getPurchaseHistory();
    // await _getPurchases();
  }

  Future _getPurchases() async {
    List<PurchasedItem> items =
        await FlutterInappPurchase.instance.getAvailablePurchases();
    for (var item in items) {
      print('${item.toString()}');
      this._purchases.add(item);
    }

    setState(() {
      this._items = [];
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
      this._items = [];
      this._purchases = items;
    });
  }

  void _requestPurchase(ShopItem item) {
    print(item.item_id);
    if (Platform.isAndroid) {
      FlutterInappPurchase.instance.requestPurchase(item.item_id.toString());
    } else {
      if (item.item_id.toString() == "20401") {
        for (var item in this._items) {
          if (item.productId.toString() == 'com.purematch.gripgem') {
            FlutterInappPurchase.instance
                .requestPurchase('com.purematch.gripgem');
            break;
          }
        }
      } else if (item.item_id.toString() == "20402") {
        for (var item in this._items) {
          if (item.productId.toString() == 'com.purematch.smallgem') {
            FlutterInappPurchase.instance
                .requestPurchase('com.purematch.smallgem');
            break;
          }
        }
      } else if (item.item_id.toString() == "20403") {
        for (var item in this._items) {
          if (item.productId.toString() == 'com.purematch.biggem') {
            FlutterInappPurchase.instance
                .requestPurchase('com.purematch.biggem');
            break;
          }
        }
      } else if (item.item_id.toString() == "20404") {
        for (var item in this._items) {
          if (item.productId.toString() == 'com.purematch.baggem') {
            FlutterInappPurchase.instance
                .requestPurchase('com.purematch.baggem');
            break;
          }
        }
      } else if (item.item_id.toString() == "20405") {
        for (var item in this._items) {
          if (item.productId.toString() == 'com.purematch.bagsgems') {
            FlutterInappPurchase.instance
                .requestPurchase('com.purematch.bagsgems');
            break;
          }
        }
      } else if (item.item_id.toString() == "20406") {
        for (var item in this._items) {
          if (item.productId.toString() == 'com.purematch.chestgems') {
            FlutterInappPurchase.instance
                .requestPurchase('com.purematch.chestgems');
            break;
          }
        }
      } else {}
    }

    FlutterInappPurchase.purchaseUpdated.listen((event) {
      _purchaseUsingCash(item);
    });
  }

  Future _getProduct() async {
    List<IAPItem> items =
        await FlutterInappPurchase.instance.getProducts(_productLists);
    for (var item in items) {
      print('${item.toString()}');
      this._items.add(item);
    }
    print("******GETTING PRODUCTS FROM STORE*****");
    print(items);

    setState(() {
      this._items = items;
      this._purchases = [];
    });
  }

  Widget shop() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: padding_x),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  "Balance:",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                SizedBox(
                  width: 10,
                ),
                Container(
                  decoration: new BoxDecoration(
                    borderRadius: new BorderRadius.circular(16.0),
                    color: AppColors.offWhiteColor,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Row(
                      children: <Widget>[
                        Image.asset(
                          "assets/images/gem_medium_icon.png",
                          width: 20,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          balance.toString() ?? 1,
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
            SizedBox(
              height: AppConfig.fontsizeForSmallDevice(context, 24),
            ),
            Visibility(
              visible: !Global.isPremium,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                      context, MaterialPageRoute(builder: (context) => Plan()));
                },
                child: Image.asset(
                  "assets/images/premium_subscriptions_card.png",
                  height: 250,
                  width: mediaWidth,
                ),
              ),
            ),
            SizedBox(
              height: AppConfig.fontsizeForSmallDevice(context, 24),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Extras",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                        color: AppColors.blackColor),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: AppConfig.fontsizeForSmallDevice(context, 24),
            ),
            SizedBox(
              height: cardWidth / 0.76 + 10,
              width: mediaWidth,
              child: GridView.builder(
                  physics: new NeverScrollableScrollPhysics(),
                  itemCount: _extras.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      childAspectRatio: 0.76, crossAxisCount: 2),
                  itemBuilder: (context, index) {
                    ShopItem shopItem = this._extras[index];
                    return _extraCard(shopItem);
                  }),
            ),
            SizedBox(
              height: AppConfig.fontsizeForSmallDevice(context, 24),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Gem Bundles",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                        color: AppColors.blackColor),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: AppConfig.fontsizeForSmallDevice(context, 24),
            ),
            Container(
              height: cardWidth / 0.76 * 3 + 40,
              width: mediaWidth,
              child: GridView.builder(
                  physics: new NeverScrollableScrollPhysics(),
                  itemCount: _gemBundles.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.76,
                      crossAxisCount: 2),
                  itemBuilder: (context, index) {
                    ShopItem shopItem = this._gemBundles[index];
                    return _gemBundleCard(shopItem);
                  }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _extraCard(ShopItem shopItem) {
    return InkWell(
      onTap: () {
        showExtraItem(context, shopItem);
      },
      child: Row(
        children: <Widget>[
          FittedBox(
            child: Container(
              width: cardWidth,
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                semanticContainer: true,
                elevation: 20,
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: Container(
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                color: AppColors
                                    .matchBrowseMatchReactivateMatching,
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(8),
                                    bottom: Radius.circular(0)),
                              ),
                              child: Text(shopItem.name,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700))),
                        ),
                      ],
                    ),
                    Material(
                      elevation: 10,
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(10),
                                    bottom: Radius.circular(0)),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text(shopItem.description,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w300)),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Center(
                                    child: CachedNetworkImage(
                                      imageUrl: shopItem.imagePath,
                                      height: 90,
                                      errorWidget: (context, url, error) =>
                                          Icon(Icons.error),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  )
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: Container(
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                color: AppColors
                                    .matchBrowseMatchReactivateMatching,
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(0),
                                    bottom: Radius.circular(10)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(shopItem.gem_cost.toString(),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700)),
                                  Image.asset(
                                      "assets/images/gem_medium_icon.png")
                                ],
                              )),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _gemBundleCard(ShopItem shopItem) {
    return InkWell(
      onTap: () {
        showBundleItem(context, shopItem);
      },
      child: Row(
        children: <Widget>[
          FittedBox(
            child: Container(
              width: cardWidth,
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                semanticContainer: true,
                elevation: 20,
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: (shopItem.value_note == "Great Deal!")
                              ? Container(
                                  padding: EdgeInsets.all(5.0),
                                  width: cardWidth,
                                  decoration: BoxDecoration(
                                    color: AppColors.yellowColor,
                                    borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(10),
                                        bottom: Radius.circular(0)),
                                  ),
                                  child: Text(shopItem.name,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize:
                                              AppConfig.fontsizeForSmallDevice(
                                                  context, 15),
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700)))
                              : (shopItem.value_note == "Best Value!")
                                  ? Container(
                                      padding: EdgeInsets.all(5.0),
                                      width: cardWidth,
                                      decoration: BoxDecoration(
                                        color: AppColors.redColor,
                                        borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(10),
                                            bottom: Radius.circular(0)),
                                      ),
                                      child: Text(shopItem.name,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 15,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700)))
                                  : Container(
                                      padding: EdgeInsets.all(5.0),
                                      width: cardWidth,
                                      decoration: BoxDecoration(
                                        color: AppColors
                                            .matchBrowseMatchReactivateMatching,
                                        borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(10),
                                            bottom: Radius.circular(0)),
                                      ),
                                      child: Text(shopItem.name,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 15,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700))),
                        ),
                      ],
                    ),
                    Material(
                      elevation: 10,
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(8.0),
                              width: cardWidth,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(10),
                                    bottom: Radius.circular(0)),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text(shopItem.description,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w300)),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      CachedNetworkImage(
                                        imageUrl: shopItem.imagePath,
                                        height: 90,
                                        width: 120,
                                        errorWidget: (context, url, error) =>
                                            Icon(Icons.error),
                                      )
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10,
                                  )
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: (shopItem.value_note == "Best Value!")
                              ? Container(
                                  padding: const EdgeInsets.all(8.0),
                                  width: cardWidth,
                                  decoration: BoxDecoration(
                                    color: AppColors.redColor,
                                    borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(0),
                                        bottom: Radius.circular(10)),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                          "Best Value!   " +
                                              "\$" +
                                              shopItem.dollar_cost.toString(),
                                          textAlign: TextAlign.right,
                                          style: TextStyle(
                                              fontSize: (AppConfig.fullWidth(
                                                          context) ==
                                                      375)
                                                  ? 13
                                                  : AppConfig
                                                      .fontsizeForSmallDevice(
                                                          context, 15),
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700)),
                                    ],
                                  ))
                              : (shopItem.value_note == "Great Deal!")
                                  ? Container(
                                      padding: const EdgeInsets.all(8.0),
                                      width: mediaWidth * 0.50,
                                      decoration: BoxDecoration(
                                        color: AppColors.yellowColor,
                                        borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(0),
                                            bottom: Radius.circular(10)),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Text(
                                              "Great Deal!   " +
                                                  "\$" +
                                                  shopItem.dollar_cost
                                                      .toString(),
                                              textAlign: TextAlign.right,
                                              style: TextStyle(
                                                  fontSize: (AppConfig
                                                              .fullWidth(
                                                                  context) ==
                                                          375)
                                                      ? 13
                                                      : AppConfig
                                                          .fontsizeForSmallDevice(
                                                              context, 15),
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w700)),
                                        ],
                                      ))
                                  : Container(
                                      padding: const EdgeInsets.all(8.0),
                                      width: mediaWidth * 0.50,
                                      decoration: BoxDecoration(
                                        color: AppColors
                                            .matchBrowseMatchReactivateMatching,
                                        borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(0),
                                            bottom: Radius.circular(10)),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Text(
                                              "\$" +
                                                  shopItem.dollar_cost
                                                      .toString(),
                                              textAlign: TextAlign.right,
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w700)),
                                        ],
                                      )),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  void showExtraItem(BuildContext context, ShopItem shopItem) {
    showGeneralDialog(
      barrierLabel: "Barrier",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: Duration(milliseconds: 200),
      context: context,
      pageBuilder: (_, __, ___) {
        return Align(
          alignment: Alignment.center,
          child: FittedBox(
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              child: Container(
                width: mediaWidth * 0.80,
                decoration: BoxDecoration(
                  color: AppColors.matchBrowseMatchReactivateMatching,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          IconButton(
                            icon: Icon(Icons.close),
                            color: Colors.white,
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          Center(
                              child: Text(
                            shopItem.name,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                                fontWeight: FontWeight.bold),
                          ))
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Card(
                        elevation: 10,
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10)),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    CachedNetworkImage(
                                      imageUrl: shopItem.imagePath,
                                      height: mediaHeight * 0.15,
                                      width: 120,
                                      errorWidget: (context, url, error) =>
                                          Icon(Icons.error),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Container(
                                        width: mediaWidth * 0.65,
                                        child: Text(
                                          shopItem.more_description,
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600),
                                          textAlign: TextAlign.center,
                                        )),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        height: 35,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.buyButtonGradient1,
                              AppColors.buyButtonGradient2
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: RaisedButton(
                          elevation: 10,
                          color: Colors.transparent,
                          onPressed: () {
                            Navigator.of(context).pop();

                            _alertUser(
                                context,
                                "Confirm Purchase",
                                "Spend ${shopItem.gem_cost.toString()} Pure Gems to get a ${shopItem.name}?",
                                "Purchase",
                                shopItem);
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Text(
                            "Buy",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (_, anim, __, child) {
        return SlideTransition(
          position: Tween(begin: Offset(0, 1), end: Offset(0, 0)).animate(anim),
          child: child,
        );
      },
    );
  }

  void showBundleItem(BuildContext context, ShopItem shopItem) {
    showGeneralDialog(
      barrierLabel: "Barrier",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: Duration(milliseconds: 200),
      context: context,
      pageBuilder: (_, __, ___) {
        return Align(
          alignment: Alignment.center,
          child: FittedBox(
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              child: Container(
                width: mediaWidth * 0.80,
                decoration: BoxDecoration(
                  color: AppColors.matchBrowseMatchReactivateMatching,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          IconButton(
                            icon: Icon(Icons.close),
                            color: Colors.white,
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          Center(
                              child: Text(
                            shopItem.name,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                                fontWeight: FontWeight.bold),
                          ))
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Card(
                        elevation: 10,
                        child: Container(
                          height: 250,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10)),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Container(
                                      width: mediaWidth * 0.60,
                                      child: Text(
                                        shopItem.description,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    )
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    CachedNetworkImage(
                                      imageUrl: shopItem.imagePath,
                                      height: mediaHeight * 0.15,
                                      width: 120,
                                      errorWidget: (context, url, error) =>
                                          Icon(Icons.error),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Container(
                                        width: mediaWidth * 0.65,
                                        child: Text(
                                          shopItem.more_description,
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600),
                                          textAlign: TextAlign.center,
                                        )),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        height: 35,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.buyButtonGradient1,
                              AppColors.buyButtonGradient2
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: RaisedButton(
                          elevation: 10,
                          color: Colors.transparent,
                          onPressed: () {
                            Navigator.of(context).pop();
                            _requestPurchase(shopItem);
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Text(
                            "Buy",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (_, anim, __, child) {
        return SlideTransition(
          position: Tween(begin: Offset(0, 1), end: Offset(0, 0)).animate(anim),
          child: child,
        );
      },
    );
  }

  void _alertUser(BuildContext context, String title, String content,
      String button, ShopItem shopItem) {
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
            FlatButton(
                child: Text("Cancel",
                    style: TextStyle(
                        color: AppColors.communityProfileOptionsBlueColor,
                        fontWeight: FontWeight.w300)),
                onPressed: () {
                  // Update user model is friend request sent successfully
                  Navigator.of(context).pop();
                }),
            (button == "null")
                ? Container
                : FlatButton(
                    child: Text(button,
                        style: TextStyle(
                            color: AppColors.communityProfileOptionsBlueColor,
                            fontWeight: FontWeight.w600)),
                    onPressed: () {
                      Navigator.of(context).pop();
                      if (button == "Purchase") {
//                        _alertUser(context, "Purchase Successfull",
//                            "You bought a ${shopItem.name}", "Ok", shopItem);

                        _purchaseUsingGems(shopItem);
                      }
                    }),
          ],
        ),
        cupertino: (_, __) => CupertinoAlertDialogData(actions: <Widget>[
          CupertinoButton(
            child: Text("Cancel",
                style: TextStyle(
                    color: AppColors.communityProfileOptionsBlueColor,
                    fontWeight: FontWeight.w300)),
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
              print(button);
              Navigator.of(context).pop();

              if (button == "Purchase") {
                _purchaseUsingGems(shopItem);
              }
            },
          ),
        ]),
      ),
      barrierDismissible: true,
    ).then((value) {});
  }

  void _successUser(BuildContext context, String title, String content,
      String button, ShopItem shopItem) {
    showDialog(
      context: context,
      builder: (_) => PlatformAlertDialog(
        title: Text(title,
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
        content: Text(content,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400)),
        material: (_, __) => MaterialAlertDialogData(
          elevation: 1.0,
          actions: <Widget>[
            FlatButton(
                child: Text(button,
                    style: TextStyle(
                        color: AppColors.communityProfileOptionsBlueColor,
                        fontWeight: FontWeight.w300)),
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
                    fontWeight: FontWeight.w300)),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ]),
      ),
      barrierDismissible: true,
    ).then((value) {});
  }

  void _purchaseUsingGems(ShopItem shopItem) async {
    try {
      print(shopItem.item_id);
      var res = await MyHttp.post("shop/purchase/${shopItem.item_id}/gem", {});
      if (res.statusCode == 201 || res.statusCode == 200) {
        int balance_changed = balance.toInt() - shopItem.gem_cost.toInt();
        _successUser(
            context,
            "Purchase Successfull!",
            "You Bought a ${shopItem.name}. Your new Balance is $balance_changed gems",
            "OK",
            shopItem);
        // //Analytics code
        // analytics.logEvent(name: "pg_purchase", parameters: <String, dynamic>{
        //   "item": shopItem.name,
        //   "value": shopItem.gem_value.toString(),
        //   "amount": shopItem.dollar_cost.toString()
        // });
        // amplitudeAnalytics.logRevenue(
        //     shopItem.name, 1, shopItem.dollar_cost.toDouble());

//
        _getGemBalance();
      } else if (res.statusCode == 403) {
        _successUser(
            context,
            "Purchase Unsuccessfull!",
            "You don't have enough balance! Your Balance is ${balance}",
            "OK",
            shopItem);
      }
    } catch (e) {
      print("Err $e");
    }
  }

  void _purchaseUsingCash(ShopItem shopItem) async {
    try {
      print("item_id=$shopItem.item_id");
      var res = await MyHttp.post("shop/purchase/${shopItem.item_id}/cash", {});
      if (res.statusCode == 201 || res.statusCode == 200) {
        //Analytics code
        analytics.logEvent(name: "ia_purchase", parameters: <String, dynamic>{
          "item": shopItem.name,
          "amount": shopItem.dollar_cost
        });
        amplitudeAnalytics.logRevenue(
            shopItem.name, 1, shopItem.dollar_cost.toDouble());

        _getGemBalance();
      } else if (res.statusCode == 403) {
        _successUser(context, "Purchase Unsuccessfull!", "Some error Occurred!",
            "OK", shopItem);
      }
    } catch (e) {
      print("Err $e");
    }
  }

  Future<String> _getStatus() async {
    var sp = await SharedPreferences.getInstance();
    int id = sp.getInt("id");
    print(id);

    try {
      var res = await MyHttp.get("users/user/$id");

      var res2 = await MyHttp.get("/settings/member-status");
      var json = jsonDecode(res.body);
      var json2 = jsonDecode(res2.body);
      status = json2["success"];
      if (status == true) Global.isPremium = true;
      setState(() {});
    } catch (e) {
      print(e);
    }
  }

  void _getGemBalance() async {
    try {
      var res = await MyHttp.get("shop/gem-balance");
      if (res.statusCode == 200 || res.statusCode == 201) {
        var jsondata = jsonDecode(res.body);

        balance = jsondata["balance"];
        print("balance = $balance");
      }
      setState(() {});
    } catch (e) {}
  }

  Container _showLoading() {
    return Container(
      height: double.infinity,
      child: Center(
        child: PlatformCircularProgressIndicator(),
      ),
    );
  }

  void _getData() async {
    setState(() {
      _loading = true;
    });
    try {
      var res = await MyHttp.get("/shop/items");
      if (res.statusCode == 200) {
        var jsonData = jsonDecode(res.body);

        var extras = jsonData["extras"];
        var gembundles = jsonData["gemBundles"];

        for (var g in gembundles) {
          si = ShopItem.fromJson(g);

          _gemBundles.insert(0, si);
          if (Platform.isAndroid) {
            _productLists.add(si.item_id.toString());
          }
        }

        //  print(_gemBundles);

        for (var p in extras) {
          if (p["name"] == "Match Boost") {
            continue;
          }
          si = ShopItem.fromJson(p);

          _extras.add(si);
        }
        await _getProduct();
        setState(() {
          _loading = false;
        });
      }
    } catch (e) {
      print("Err $e");
    }
  }
}
