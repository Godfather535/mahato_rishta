import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dating_app/api/notifications_api.dart';
import 'package:dating_app/constants/constants.dart';
import 'package:dating_app/screens/notifications_screen.dart';
import 'package:dating_app/widgets/notification_counter.dart';
import 'package:dating_app/widgets/svg_icon.dart';
import 'package:flutter/material.dart';

class CustomCurvedAppBar extends StatelessWidget {
  CustomCurvedAppBar({super.key, required this.header});

  final String header;
  final _notificationsApi = NotificationsApi();

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: CustomAppBarClipper(), // CustomClipper to create curved shape
      child: Container(
        height: MediaQuery.of(context).size.height / 6,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.5),
              Colors.purple
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.pink.withOpacity(0.5), // Shadow color
              blurRadius: 2, // Spread radius
              spreadRadius: 2, // Offset in x and y directions
            ),
          ],
        ),
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height / 40,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.all(
                      MediaQuery.of(context).size.aspectRatio * 30),
                  child: Row(
                    children: [
                      // Image.asset("assets/images/app_logo.png",
                      //     width: 50, height: 50),
                      const SizedBox(width: 35),
                      Text(
                        header,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 24),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                        icon: _getNotificationCounter(),
                        onPressed: () async {
                          // Go to Notifications Screen
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => NotificationsScreen()));
                        }),
                    const SizedBox(
                      width: 25,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _getNotificationCounter() {
    // Set icon
    const icon = SvgIcon(
      "assets/icons/bell_icon.svg",
      width: 33,
      height: 33,
      color: Colors.white,
    );

    /// Handle stream
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _notificationsApi.getNotifications(),
        builder: (context, snapshot) {
          // Check result
          if (!snapshot.hasData) {
            return icon;
          } else {
            /// Get total counter to alert user
            final total = snapshot.data!.docs
                .where((doc) => doc.data()[N_READ] == false)
                .toList()
                .length;
            if (total == 0) return icon;
            return NotificationCounter(icon: icon, counter: total);
          }
        });
  }
}

class CustomAppBarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final Path path = Path();
    path.lineTo(0, size.height - 50); // Start from the bottom-left corner
    path.quadraticBezierTo(
        size.width / 2, size.height, size.width, size.height - 50); // Curve
    path.lineTo(size.width, 0); // End at the top-right corner
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true; // Always re-clip when changes are made
  }
}
