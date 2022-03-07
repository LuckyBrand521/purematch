import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:pure_match/common/global.dart';
import 'package:pure_match/pages/AppColors.dart';

class DiscountedOffer extends StatefulWidget {
  @override
  _DiscountedOfferState createState() => _DiscountedOfferState();
}

class _DiscountedOfferState extends State<DiscountedOffer> {
  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      backgroundColor: AppColors.blueColor,
      appBar: PlatformAppBar(
        material: (_, __) => MaterialAppBarData(
          backgroundColor: AppColors.blueColor,
          elevation: 0.0,
          leading: MaterialButton(
            onPressed: () {},
            child: IconButton(
              icon: Icon(Icons.arrow_back),
              color: Colors.white,
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ),
        cupertino: (_, __) => CupertinoNavigationBarData(
          automaticallyImplyLeading: false,
          automaticallyImplyMiddle: false,
          backgroundColor: AppColors.blueColor,
          leading: MaterialButton(
            onPressed: () {},
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              color: Colors.white,
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 10.0),
        ),
      ),
      body: SafeArea(
        child: Scaffold(
          backgroundColor: AppColors.blueColor,
          body: Container(
            padding: EdgeInsets.only(left: 10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SizedBox(
                  height: 20.0, //consider using 10
                ),
                Text(
                  "Selected Plan",
                  style: TextStyle(
                      fontSize: 28,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontStyle: FontStyle.normal),
                ),
                SizedBox(
                  height: 15.0,
                ),
                Container(
                  margin: EdgeInsets.only(bottom: 50.0),
                  child: Text(
                    "Pure Match Premium \n6 months @ \$6.49/month (50% OFF) \nRenews automatically on 3/3/2021",
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.normal),
                    textAlign: TextAlign.left,
                  ),
                ), // have a function that will return the right thing depending on users subscription
                SizedBox(
                  height: 10,
                ),
                Text(
                  "Benefits",
                  style: TextStyle(
                      fontSize: 28,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontStyle: FontStyle.normal),
                ),
                SizedBox(
                  height: 10.0,
                ),
                Global.premiumTexts(
                  context,
                  Colors.white,
                  AppConfig.fontsizeForSmallDevice(context, 18),
                ),

                SizedBox(height: 10.0),
                Text(
                  "Payment",
                  style: TextStyle(
                      fontSize: 28,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontStyle: FontStyle.normal),
                ),
                SizedBox(height: 20.0),
                Column(
                  children: <Widget>[
                    PlatformButton(
                      padding: EdgeInsets.symmetric(
                          vertical: 15.0, horizontal: 47.0),
                      color: Color.fromRGBO(0, 186, 132, 1),
                      onPressed: () {},
                      materialFlat: (_, __) => MaterialFlatButtonData(
                        child: Text(
                          "Suscribe with Pure Gems",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              fontStyle: FontStyle.normal),
                        ),
                      ),
                      cupertino: (_, __) => CupertinoButtonData(
                        child: Text(
                          "Suscribe with Pure Gems",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              fontStyle: FontStyle.normal),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    PlatformButton(
                      padding: EdgeInsets.symmetric(
                          vertical: 15.0, horizontal: 75.0),
                      color: Colors.white,
                      onPressed: () {},
                      materialFlat: (_, __) => MaterialFlatButtonData(
                        child: Text(
                          "Suscribe with Pay",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppColors.blackColor,
                              fontStyle: FontStyle.normal),
                        ),
                      ),
                      cupertino: (_, __) => CupertinoButtonData(
                        child: Text(
                          "Suscribe with Pay",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppColors.blackColor,
                              fontStyle: FontStyle.normal),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
