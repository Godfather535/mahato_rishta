import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tinder_binder/screens/sign_up_screen.dart';
import 'package:tinder_binder/screens/verification_code_screen.dart';

import '../dialogs/progress_dialog.dart';
import '../helpers/app_localizations.dart';
import '../models/user_model.dart';
import '../widgets/default_button.dart';
import '../widgets/show_scaffold_msg.dart';
import 'home_screen.dart';

class PhoneNumberScreen extends StatefulWidget {
  @override
  _PhoneNumberScreenState createState() => _PhoneNumberScreenState();
}

class _PhoneNumberScreenState extends State<PhoneNumberScreen> {
  // Variables
  final _formKey = GlobalKey<FormState>();
  final _scaffoldkey = GlobalKey<ScaffoldState>();
  final _numberController = TextEditingController();
  String? _phoneCode = '+91'; // Define yor default phone code
  String _initialSelection = 'IN'; // Define yor default country code
  late AppLocalizations _i18n;
  late ProgressDialog _pr;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    /// Initialization
    _i18n = AppLocalizations.of(context);
    _pr = ProgressDialog(context, isDismissible: false);

    return Scaffold(
        key: _scaffoldkey,
        backgroundColor: Color(0xff010b29),
        appBar: AppBar(
          backgroundColor: Color(0xff010b29),
          leading: IconButton(icon: Icon(Icons.arrow_back_ios_outlined, color: Colors.white),onPressed: (){
            Navigator.pop(context);
          },),
          title: Hero(
              tag: 1,
              child: Text('Sign Up'.toUpperCase(), style: TextStyle(color: Colors.white),)),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  color: Color(0xfff3ead3),
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(color: Colors.grey, blurRadius: 2,spreadRadius: 0.2),
                  ]
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    children: [
                      Hero(
                        tag: 2,
                        child: SvgPicture.asset("assets/icons/sign_up_with_mobile.svg",
                            width: 160, height: 160),
                      ),
                      SizedBox(height: 20),
                      Text('sign in'.toUpperCase(),
                          textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xff010b13))),
                      SizedBox(height: 6),
                      Text(
                          'Please Enter Your Phone Number For Mobile Verification',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Color(0xff010b13), fontWeight: FontWeight.w300,)),
                      SizedBox(height: 22),

                      /// Form
                      Form(
                        key: _formKey,
                        child: Column(
                          children: <Widget>[
                            TextFormField(
                              controller: _numberController,
                              decoration: InputDecoration(
                                  labelText: _i18n.translate("phone_number"),
                                  hintText: _i18n.translate("enter_your_number"),
                                  floatingLabelBehavior: FloatingLabelBehavior.always,
                                  prefixIcon: Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: CountryCodePicker(
                                      alignLeft: false,
                                      enabled: false,
                                      initialSelection: _initialSelection,
                                      onChanged: (country) {
                                        /// Get country code
                                        _phoneCode = country.dialCode!;
                                      },
                                    ),
                                  )),
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.allow(new RegExp("[0-9]"))
                              ],
                              validator: (number) {
                                // Basic validation
                                if (number == null) {
                                  return _i18n
                                      .translate("please_enter_your_phone_number");
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 20),
                            SizedBox(
                              width: double.maxFinite,
                              child: DefaultButton(
                                bgColor: Color(0xffeb2188),
                                child: Text(_i18n.translate("CONTINUE"),
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400)),
                                onPressed: () async {
                                  /// Validate form
                                  if (_formKey.currentState!.validate()) {
                                    /// Sign in
                                    _signIn(context);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  /// Sign in with phone number
  void _signIn(BuildContext context) async {
    // Show progress dialog
    _pr.show(_i18n.translate("processing"));

    /// Verify user phone number
    await UserModel().verifyPhoneNumber(
        phoneNumber: _phoneCode! + _numberController.text.trim(),
        checkUserAccount: () {
          /// Auth user account
          UserModel().authUserAccount(homeScreen: () {
            /// Go to home screen
            Future(() {
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => HomeScreen()));
            });
          }, signUpScreen: () {
            /// Go to sign up screen
            Future(() {
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => SignUpScreen()));
            });
          });
        },
        codeSent: (code) async {
          // Hide progreess dialog
          _pr.hide();
          // Go to verification code screen
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => VerificationCodeScreen(
                    verificationId: code,
                  )));
        },
        onError: (errorType) async {
          // Hide progreess dialog
          _pr.hide();

          // Check Erro type
          if (errorType == 'invalid_number') {
              // Check error type
              final String message =
                  _i18n.translate("we_were_unable_to_verify_your_number");
              // Show error message
              // Validate context
              if (mounted) {
                showScaffoldMessage(
                    context: context, message: message, bgcolor: Colors.red);
              }
          }
        });
  }
}
