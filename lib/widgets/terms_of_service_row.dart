import 'package:flutter/material.dart';

import '../helpers/app_helper.dart';
import '../helpers/app_localizations.dart';

class TermsOfServiceRow extends StatelessWidget {
  // Params
  final Color color;

  TermsOfServiceRow({this.color = Colors.white});

  // Private variables
  final _appHelper = AppHelper();

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        GestureDetector(
          child: Text(
            i18n.translate("terms_of_service"),
            style: TextStyle(
                color: color,
                fontSize: MediaQuery.of(context).size.width/30,
                // decoration: TextDecoration.underline,
                fontWeight: FontWeight.w400),
          ),
          onTap: () {
            // Open terms of service page in browser
            _appHelper.openTermsPage();
          },
        ),
        Text(
          ' | ',
          style: TextStyle(
              color: color, fontWeight: FontWeight.w400,fontSize: MediaQuery.of(context).size.width/30),
        ),
        GestureDetector(
          child: Text(
            i18n.translate("privacy_policy"),
            style: TextStyle(
                color: color,
                fontSize: MediaQuery.of(context).size.width/30,                // decoration: TextDecoration.underline,
                fontWeight: FontWeight.w400),
          ),
          onTap: () {
            // Open privacy policy page in browser
            _appHelper.openPrivacyPage();
          },
        ),
      ],
    );
  }
}
