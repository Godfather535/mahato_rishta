import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tinder_binder/screens/phone_number_screen.dart';

import '../helpers/app_localizations.dart';
import '../widgets/default_button.dart';
import '../widgets/terms_of_service_row.dart';


class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  // Variables
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  late AppLocalizations _i18n;
 
  @override
  Widget build(BuildContext context) {
    /// Initialization
    _i18n = AppLocalizations.of(context);
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          // image: DecorationImage(
          //     image: AssetImage("assets/images/background_image.jpg"),
          //     fit: BoxFit.fill,
          //     repeat: ImageRepeat.repeatY),
        ),
        child: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).primaryColor, 
                    Colors.black.withOpacity(.4)])),
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(image: AssetImage('assets/images/bgImage.jpg'),fit: BoxFit.fill),
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      Color(0xffff9c9c),
                      Color(0xffff698c),
                    ],
                  )
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(size.width/4)),
                  color: Color(0xff010b29),
                ),
                height: size.height*0.6,
                width: size.width*0.8,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[

                  /// App logo
                  // AppLogo(),
                  // SizedBox(height: 10),

                  /// App name
                  // Text(APP_NAME,
                  //     style: TextStyle(
                  //         fontSize: 22,
                  //         fontWeight: FontWeight.bold,
                  //         color: Colors.black)),
                  // SizedBox(height: 20),

                  // Text(_i18n.translate("welcome_back"),
                  //   textAlign: TextAlign.center,
                  //   style: TextStyle(fontSize: 18, color: Colors.black)),
                  // SizedBox(height: 5),
                  // Text(_i18n.translate("app_short_description"),
                  //     textAlign: TextAlign.center,
                  //     style: TextStyle(fontSize: 18, color: Colors.black)),
                  // SizedBox(height: 22),


                    Hero(
                      tag: 2,
                      child: SvgPicture.asset('assets/icons/heart_sign_up.svg',
                      height: size.height*0.2,),
                    ),
                    SizedBox(height: 20,),
                    /// Sign in with Phone Number
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                      child: SizedBox(
                        width: double.maxFinite,
                        child: DefaultButton(
                          textColor: Colors.black,
                          // bgColor: Color(0xffff9c9c),
                          bgColor: Colors.pinkAccent,
                          child: Hero(
                            tag: 1,
                            child: Text("Sign up".toUpperCase(),
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400)),
                          ),
                          onPressed: () {
                            /// Go to phone number screen
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => PhoneNumberScreen()));
                          },
                        ),
                      ),
                    ),
                    // SizedBox(height: 15),

                    // Terms of Service section
                    // Text(
                    //   _i18n.translate("by_tapping_log_in_you_agree_with_our"),
                    //   style: TextStyle(
                    //       color: Colors.black, fontWeight: FontWeight.bold),
                    //   textAlign: TextAlign.center,
                    // ),
                    // SizedBox(
                    //   height: 7,
                    // ),
                    TermsOfServiceRow(),

                    SizedBox(height: 15),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
