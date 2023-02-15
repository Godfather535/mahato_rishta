import 'package:flutter/material.dart';
import 'package:tinder_binder/screens/sign_up_screen.dart';

import '../dialogs/common_dialogs.dart';
import '../dialogs/progress_dialog.dart';
import '../helpers/app_helper.dart';
import '../helpers/app_localizations.dart';
import '../models/user_model.dart';
import '../plugins/otp_screen/otp_screen.dart';
import '../widgets/svg_icon.dart';
import 'enable_location_screen.dart';
import 'home_screen.dart';

class VerificationCodeScreen extends StatefulWidget {
  // Variables
  final String verificationId;

  // Constructor
  VerificationCodeScreen({
    required this.verificationId,
  });

  @override
  _VerificationCodeScreenState createState() => _VerificationCodeScreenState();
}

class _VerificationCodeScreenState extends State<VerificationCodeScreen> {
  // Variables
  late AppLocalizations _i18n;
  late ProgressDialog _pr;

  /// Navigate to next page
  void _nextScreen(screen) {
    // Go to next page route
    Future(() {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => screen), (route) => false);
    });
  }

  /// Go to enable location or GPS screen
  void goToEnableLocationOrGpsScreen(String action) {
    // Navigate
    _nextScreen(EnableLocationScreen(action: action));
  }

  /// logic to validate otp return [null] when success else error [String]
  Future<String?> validateOtp(String otp) async {
    /// Handle entered verification code here
    ///
    /// Show progress dialog
    _pr.show(_i18n.translate("processing"));

    await UserModel().signInWithOTP(
        verificationId: widget.verificationId,
        otp: otp,
        checkUserAccount: () {
          /// Auth user account
          UserModel().authUserAccount(homeScreen: () {
            /// Go to home screen
            _nextScreen(HomeScreen());
          }, signUpScreen: () async {
            // AppHelper instance
            final AppHelper appHelper = new AppHelper();

            /// Check location permission
            await appHelper.checkLocationPermission(onGpsDisabled: () {
              /// Go to Enable GPS screen
              goToEnableLocationOrGpsScreen('GPS');
            }, onDenied: () {
              /// Go to enable location screen
              goToEnableLocationOrGpsScreen('location');
            }, onGranted: () {
              /// Go to sign up screen
              _nextScreen(SignUpScreen());
            });
          });
        },
        onError: () async {
          // Hide dialog
          await _pr.hide();
          // Show error message to user
          errorDialog(context,
              message: _i18n.translate("we_were_unable_to_verify_your_number"));
        });

    // Hide progress dialog
    await _pr.hide();

    return null;
  }

  @override
  Widget build(BuildContext context) {
    /// Initialization
    _i18n = AppLocalizations.of(context);
    _pr = ProgressDialog(context, isDismissible: false);

    return OtpScreen.withGradientBackground(
      topColor: Color(0xff010b69),
      bottomColor: Color(0xff010b29),
      otpLength: 6,
      validateOtp: validateOtp,
      routeCallback: (context) {},
      icon: CircleAvatar(
        radius: 50,
        backgroundColor: Colors.white,
        child: SvgIcon("assets/icons/phone_icon.svg",
            width: 40, height: 40, color: Theme.of(context).primaryColor),
      ),
      title: _i18n.translate("verification_code"),
      subTitle: _i18n.translate("please_enter_the_sms_code_sent"),
    );
  }
}