import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../api/conversations_api.dart';
import '../constants/constants.dart';
import '../datas/user.dart';
import '../dialogs/progress_dialog.dart';
import '../helpers/app_localizations.dart';
import '../models/user_model.dart';
import '../screens/chat_screen.dart';
import '../widgets/badge.dart';
import '../widgets/build_title.dart';
import '../widgets/no_data.dart';
import '../widgets/processing.dart';

class ConversationsTab extends StatelessWidget {
  // Variables
  final _conversationsApi = ConversationsApi();

  @override
  Widget build(BuildContext context) {
    /// Initialization
    final i18n = AppLocalizations.of(context);
    final pr = ProgressDialog(context);

    return Column(
      children: [
        /// Header
        BuildTitle(
          svgIconName: 'message_icon',
          title: i18n.translate("conversations"),
        ),

        /// Conversations stream
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _conversationsApi.getConversations(),
            builder: (context, snapshot) {
              /// Check data
              if (!snapshot.hasData) {
                return Processing(text: i18n.translate("loading"));
              } else if (snapshot.data!.docs.isEmpty) {
                /// No conversation
                return NoData(
                    svgName: 'message_icon',
                    text: i18n.translate("no_conversation"));
              } else {
                return ListView.separated(
                  shrinkWrap: true,
                  separatorBuilder: (context, index) => Divider(height: 10),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: ((context, index) {
                    /// Get conversation DocumentSnapshot
                    final DocumentSnapshot conversation =
                          snapshot.data!.docs[index];

                    /// Show conversation
                    return Container(
                      color: !conversation[MESSAGE_READ]
                          ? Theme.of(context).primaryColor.withAlpha(40)
                          : null,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).primaryColor,
                          backgroundImage:
                              NetworkImage(conversation[USER_PROFILE_PHOTO]),
                        ),
                        title: Text(conversation[USER_FULLNAME].split(" ")[0],
                            style: TextStyle(fontSize: 18)),
                        subtitle: conversation[MESSAGE_TYPE] == 'text'
                          ? Text(
                              "${conversation[LAST_MESSAGE]}\n"
                              "${timeago.format(conversation[TIMESTAMP].toDate())}")
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Icon(Icons.photo_camera, 
                                   color: Theme.of(context).primaryColor),
                                SizedBox(width: 5),
                                Text(i18n.translate("photo")),
                              ],
                           ),
                        trailing: !conversation[MESSAGE_READ]
                            ? Badge(text: i18n.translate("new"))
                            : null,
                        onTap: () async {
                          /// Show progress dialog
                          pr.show(i18n.translate("processing"));

                          /// 1.) Set conversation read = true
                          await conversation.reference
                              .update({MESSAGE_READ: true});

                          /// 2.) Get updated user info
                          final DocumentSnapshot userDoc = await UserModel()
                              .getUser(conversation[USER_ID]);

                          /// 3.) Get user object
                          final User user = User.fromDocument(userDoc.data()! as Map<String, dynamic>);

                          /// Hide progrees
                          pr.hide();

                          /// Go to chat screen
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => ChatScreen(user: user)));
                        },
                      ),
                    );
                  }),
                );
              }
            }),
        ),
      ],
    );
  }
}