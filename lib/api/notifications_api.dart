import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dating_app/constants/constants.dart';
import 'package:dating_app/models/user_model.dart';
import 'package:dating_app/models/app_model.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class NotificationsApi {
  /// FINAL VARIABLES
  ///
  /// Firestore instance
  final _firestore = FirebaseFirestore.instance;

  /// Save notification in database
  Future<void> saveNotification({
    required String nReceiverId,
    required String nType,
    required String nMessage,
  }) async {
    _firestore.collection(C_NOTIFICATIONS).add({
      N_SENDER_ID: UserModel().user.userId,
      N_SENDER_FULLNAME: UserModel().user.userFullname,
      N_SENDER_PHOTO_LINK: UserModel().user.userProfilePhoto,
      N_RECEIVER_ID: nReceiverId,
      N_TYPE: nType,
      N_MESSAGE: nMessage,
      N_READ: false,
      TIMESTAMP: FieldValue.serverTimestamp()
    }).then((_) async {
      debugPrint('saveNotification() -> success');
      // await sendBackgroundMessage(
      //     nReceiverId: nReceiverId,
      //     nBody: nMessage,
      //     onSuccess: () {
      //       debugPrint("Successfully notified user");
      //     },
      //     onError: () {
      //       debugPrint("Error sending notification");
      //     });
    });
  }

  Future<void> sendBackgroundMessage({
    required String nReceiverId,
    required String nBody,
    // VoidCallback functions
    required VoidCallback onSuccess,
    required VoidCallback onError,
  }) async {
    debugPrint(nReceiverId);
    await http
        .post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization':
            'key=AAAApjdBntw:APA91bFQh2pRnjBzqPMIrxZyAqBWZov6CcVb0xRakhCNzI74rdf-wpsXfloB0LYjzBgaYEn_nj0t6afivUvx1dbb63hHrdJFV-jknQinSivO7zlVcW1MHiFaj1ZAXTXPx6xu8Ynsuzdg',
      },
      body: jsonEncode(
        <String, dynamic>{
          'notification': <String, dynamic>{
            'title': APP_NAME,
            'body': nBody,
            'color': '#F50057',
            'sound': "default"
          },
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'n_type': 'alert',
            'n_message': nBody,
            'status': 'done'
          },
          'to': nReceiverId,
        },
      ),
    )
        .then((http.Response response) {
      debugPrint(response.body.toString());
      if (response.statusCode == 200) {
        onSuccess();
        debugPrint('sendPushNotification() -> success');
      } else {
        onError();
      }
    }).catchError((error) {
      onError();
      debugPrint('sendPushNotification() -> error: $error');
    });
  }

  Future<String> getRecipientToken(String userId) async {
    try {
      // Query the Firestore collection to get the FCM token for the specified user
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection(C_USERS)
          .where(USER_ID, isEqualTo: userId)
          .get();

      // Check if any documents were found
      if (snapshot.docs.isNotEmpty) {
        // Get the FCM token from the retrieved document
        String fcmToken = snapshot.docs[0].get(USER_DEVICE_TOKEN);
        return fcmToken;
      } else {
        throw Exception('User not found');
      }
    } catch (e) {
      print('Error fetching user FCM token: $e');
      throw e;
    }
  }

  /// Notify Current User after purchasing VIP subscription
  Future<void> onPurchaseNotification({
    required String nMessage,
  }) async {
    _firestore.collection(C_NOTIFICATIONS).add({
      N_SENDER_FULLNAME: APP_NAME,
      N_RECEIVER_ID: UserModel().user.userId,
      N_TYPE: 'alert',
      N_MESSAGE: nMessage,
      N_READ: false,
      TIMESTAMP: FieldValue.serverTimestamp()
    }).then((_) {
      debugPrint('saveNotification() -> success');
    });
  }

  /// Get stream notifications for current user
  Stream<QuerySnapshot<Map<String, dynamic>>> getNotifications() {
    /// Build query
    return _firestore
        .collection(C_NOTIFICATIONS)
        .where(N_RECEIVER_ID, isEqualTo: UserModel().user.userId)

        /// here
        .orderBy(TIMESTAMP, descending: true)
        .snapshots();
  }

  /// Delete current user notifications
  Future<void> deleteUserNotifications() async {
    await _firestore
        .collection(C_NOTIFICATIONS)
        .where(N_RECEIVER_ID, isEqualTo: UserModel().user.userId)
        .get()
        .then((QuerySnapshot<Map<String, dynamic>> snapshot) async {
      // Check result
      if (snapshot.docs.isEmpty) return;

      /// Loop notifications and delete one by one
      for (DocumentSnapshot<Map<String, dynamic>> doc in snapshot.docs) {
        await doc.reference.delete();
      }

      debugPrint('deleteUserNotifications() -> deleted');
    });
  }

  Future<void> deleteUserSentNotifications() async {
    _firestore
        .collection(C_NOTIFICATIONS)
        .where(N_SENDER_ID, isEqualTo: UserModel().user.userId)
        .get()
        .then((QuerySnapshot<Map<String, dynamic>> snapshot) async {
      // Check result
      if (snapshot.docs.isEmpty) return;

      /// Loop notifications
      for (DocumentSnapshot<Map<String, dynamic>> doc in snapshot.docs) {
        await doc.reference.delete();
      }
      debugPrint('deleteUserSentNotifications() -> deleted');
    });
  }

  /// Send push notification method
  Future<void> sendPushNotification({
    required String nTitle,
    required String nBody,
    required String nType,
    required String nSenderId,
    required String nUserDeviceToken,
    // Call Info Map Data
    Map<String, dynamic>? nCallInfo,
  }) async {
    // Variables
    final Uri url = Uri.parse('https://fcm.googleapis.com/fcm/send');

    await http
        .post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization':
            'key=AAAApjdBntw:APA91bFQh2pRnjBzqPMIrxZyAqBWZov6CcVb0xRakhCNzI74rdf-wpsXfloB0LYjzBgaYEn_nj0t6afivUvx1dbb63hHrdJFV-jknQinSivO7zlVcW1MHiFaj1ZAXTXPx6xu8Ynsuzdg',
      },
      body: jsonEncode(
        <String, dynamic>{
          'notification': <String, dynamic>{
            'title': nTitle,
            'body': nBody,
            'color': '#987dfa',
            'sound': "default"
          },
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            N_TYPE: nType,
            N_SENDER_ID: nSenderId,
            'call_info': nCallInfo, // Call Info Data
            'status': 'done'
          },
          'to': nUserDeviceToken,
        },
      ),
    )
        .then((http.Response response) {
      debugPrint(response.body.toString());

      if (response.statusCode == 200) {
        debugPrint('sendPushNotification() -> success');
      } else {
        debugPrint("Error sending notification");
      }
    }).catchError((error) {
      debugPrint('sendPushNotification() -> error: $error');
    });
  }
}
