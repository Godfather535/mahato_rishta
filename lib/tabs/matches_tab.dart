import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../api/matches_api.dart';
import '../datas/user.dart';
import '../helpers/app_localizations.dart';
import '../models/user_model.dart';
import '../screens/chat_screen.dart';
import '../widgets/build_title.dart';
import '../widgets/loading_card.dart';
import '../widgets/no_data.dart';
import '../widgets/processing.dart';
import '../widgets/profile_card.dart';
import '../widgets/users_grid.dart';

class MatchesTab extends StatefulWidget {
  @override
  _MatchesTabState createState() => _MatchesTabState();
}

class _MatchesTabState extends State<MatchesTab> {
  /// Variables
  final MatchesApi _matchesApi = MatchesApi();
  List<DocumentSnapshot>? _matches;
  late AppLocalizations _i18n;

  @override
  void initState() {
    super.initState();

    /// Get user matches
    _matchesApi.getMatches().then((matches) {
      if (mounted) setState(() => _matches = matches);
    });
  }

  @override
  Widget build(BuildContext context) {
    /// Initialization
    _i18n = AppLocalizations.of(context);

    return Column(
      children: [
        /// Header
        BuildTitle(
          svgIconName: 'heart_icon',
          title: _i18n.translate("matches"),
        ),

        /// Show matches
        Expanded(child: _showMatches()),
      ],
    );
  }

  /// Handle matches result
  Widget _showMatches() {
    /// Check result
    if (_matches == null) {
      return Processing(text: _i18n.translate("loading"));
    } else if (_matches!.isEmpty) {
      /// No match
      return NoData(
        svgName: 'heart_icon', text: _i18n.translate("no_match"));
    } else {
      /// Load matches
      return UsersGrid(
        itemCount: _matches!.length,
        itemBuilder: (context, index) {
          /// Get match doc
          final DocumentSnapshot match = _matches![index];

          /// Load profile
          return FutureBuilder<DocumentSnapshot>(
              future: UserModel().getUser(match.id),
              builder: (context, snapshot) {
                /// Check result
                if (!snapshot.hasData) return LoadingCard();

                /// Get user object
                final User user = User.fromDocument(snapshot.data!.data()! as Map<String,dynamic>);

                /// Show user card
                return GestureDetector(
                    child: ProfileCard(user: user, page: 'matches'),
                    onTap: () {
                      /// Go to chat screen
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => ChatScreen(user: user)));
                    });
              });
        },
      );
    }
  }
}
