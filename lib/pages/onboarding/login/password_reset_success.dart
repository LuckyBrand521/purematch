import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:pure_match/pages/AppColors.dart';
import 'package:flutter/cupertino.dart';
import 'package:pure_match/pages/onboarding/login/login.dart';

class PasswordResetSuccess extends StatefulWidget {
  final String resetEmail;
  PasswordResetSuccess(this.resetEmail, {Key key}) : super(key: key);
  @override
  _PasswordResetSuccessState createState() => _PasswordResetSuccessState();
}

class _PasswordResetSuccessState extends State<PasswordResetSuccess> {
  String email;
  bool emailValidationCheck = false;
  String message =
      "Reset link sent!\nBe sure to check your spam folder if you don’t see it.";
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.value = TextEditingValue(text: widget.resetEmail);
    // other code here
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return PlatformScaffold(
      appBar: PlatformAppBar(
          material: (_, __) => MaterialAppBarData(
              elevation: 0.0, backgroundColor: Colors.white, leading: null),
          cupertino: (_, __) => CupertinoNavigationBarData(
              automaticallyImplyLeading: false,
              automaticallyImplyMiddle: false,
              backgroundColor: Colors.white,
              border: Border(bottom: BorderSide.none),
              padding: EdgeInsetsDirectional.only(start: 10.0),
              leading: null)),
      body: SafeArea(
          child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: SizedBox(
            height: height - 100,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        height: 60,
                      ),
                      Text("Email",
                          style: TextStyle(
                              fontSize: 28,
                              color: AppColors.blackColor,
                              fontWeight: FontWeight.w600)),
                      SizedBox(
                        height: 12,
                      ),
                      PlatformTextField(
                        keyboardType: TextInputType.emailAddress,
                        controller: _controller,
                        style: TextStyle(
                            fontSize: 18,
                            color: AppColors.blueColor,
                            fontWeight: FontWeight.w700),
                        material: (_, __) => MaterialTextFieldData(
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(0),
                              enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: AppColors.blueColor, width: 2))),
                        ),
                        cupertino: (_, __) => CupertinoTextFieldData(
                          keyboardAppearance: Brightness.light,
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                  color: AppColors.blueColor, width: 2),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Text(
                    this.message,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Padding(
                    padding: EdgeInsetsDirectional.only(bottom: 20),
                    child: Center(
                      child: SizedBox(
                        width: 220,
                        height: 60,
                        child: PlatformButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => LoginPage()));
                            },
                            color: AppColors.blueColor,
                            disabledColor: AppColors.disabledBlueColor,
                            padding: EdgeInsets.symmetric(vertical: 20),
                            materialFlat: (_, __) => MaterialFlatButtonData(
                                  color: AppColors.blueColor,
                                  disabledColor: AppColors.disabledBlueColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                            cupertinoFilled: (_, __) =>
                                CupertinoFilledButtonData(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                            child: Text(
                              "Back to Login",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16),
                            )),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      )),
    );
  }
}
