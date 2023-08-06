import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dating_app/api/notifications_api.dart';
import 'package:dating_app/constants/constants.dart';
import 'package:dating_app/dialogs/common_dialogs.dart';
import 'package:dating_app/dialogs/progress_dialog.dart';
import 'package:dating_app/helpers/app_localizations.dart';
import 'package:dating_app/helpers/app_notifications.dart';
import 'package:dating_app/widgets/custom_badge.dart';
import 'package:dating_app/widgets/no_data.dart';
import 'package:dating_app/widgets/processing.dart';
import 'package:dating_app/widgets/svg_icon.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationsScreen extends StatelessWidget {
  // Variables
  final _notificationsApi = NotificationsApi();
  final _appNotifications = AppNotifications();

  NotificationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    /// Initialization
    final i18n = AppLocalizations.of(context);
    final pr = ProgressDialog(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(i18n.translate("notifications")),
        actions: [
          IconButton(
              icon: const SvgIcon("assets/icons/trash_icon.svg"),
              onPressed: () async {
                /// Delete all Notifications
                ///
                /// Show confirm dialog
                confirmDialog(context,
                    message:
                        i18n.translate("all_notifications_will_be_deleted"),
                    negativeAction: () => Navigator.of(context).pop(),
                    positiveText: i18n.translate("DELETE"),
                    positiveAction: () async {
                      // Show processing dialog
                      pr.show(i18n.translate("processing"));

                      /// Delete
                      await _notificationsApi.deleteUserNotifications();

                      // Hide progress dialog
                      pr.hide();
                      // Hide confirm dialog
                      Navigator.of(context).pop();
                    });
              })
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _notificationsApi.getNotifications(),
          builder: (context, snapshot) {
            /// Check data
            if (!snapshot.hasData) {
              return Processing(text: i18n.translate("loading"));
            } else if (snapshot.data!.docs.isEmpty) {
              /// No notification
              return NoData(
                  svgName: 'bell_icon',
                  text: i18n.translate("no_notification"));
            } else {
              return Container(
                height: MediaQuery.sizeOf(context).height,
                width: MediaQuery.sizeOf(context).width,
                color: const Color(0xffd7dee5).withOpacity(0.5),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: ((context, index) {
                    /// Get notification DocumentSnapshot<Map<String, dynamic>>
                    final DocumentSnapshot<Map<String, dynamic>> notification =
                        snapshot.data!.docs[index];
                    final String? nType = notification[N_TYPE];
                    // Handle notification icon
                    late ImageProvider bgImage;
                    if (nType == 'alert') {
                      bgImage = const AssetImage('assets/images/app_logo.png');
                    } else {
                      bgImage = NetworkImage(notification[N_SENDER_PHOTO_LINK]);
                    }

                    return GestureDetector(
                      onTap: () async {
                        /// Set notification read = true
                        await notification.reference.update({N_READ: true});

                        /// Handle notification click
                        _appNotifications.onNotificationClick(context,
                            nType: notification.data()?[N_TYPE] ?? '',
                            nSenderId: notification.data()?[N_SENDER_ID] ?? '',
                            nMessage: notification.data()?[N_MESSAGE] ?? '');
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        child: Container(
                          decoration: BoxDecoration(
                            color: !notification[N_READ]
                                ? Theme.of(context).primaryColor.withAlpha(40)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey
                                    .withOpacity(0.5), // Shadow color
                                blurRadius: 2, // Spread radius
                                spreadRadius: 2, // Offset in x and y directions
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                        notification[N_TYPE] == 'alert'
                                            ? notification[N_SENDER_FULLNAME]
                                            : notification[N_SENDER_FULLNAME]
                                                .split(" ")[0],
                                        style: const TextStyle(fontSize: 18)),
                                    Text("${notification[N_MESSAGE]}\n"
                                        "${timeago.format(notification[TIMESTAMP].toDate())}"),
                                  ],
                                ),
                                if (!notification[N_READ])
                                  CustomBadge(text: i18n.translate("new"))
                                else
                                  const SizedBox(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              );
            }
          }),
    );
  }
}
