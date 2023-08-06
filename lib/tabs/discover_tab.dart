import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dating_app/api/dislikes_api.dart';
import 'package:dating_app/api/likes_api.dart';
import 'package:dating_app/api/matches_api.dart';
import 'package:dating_app/api/visits_api.dart';
import 'package:dating_app/constants/constants.dart';
import 'package:dating_app/datas/user.dart';
import 'package:dating_app/dialogs/its_match_dialog.dart';
import 'package:dating_app/helpers/app_localizations.dart';
import 'package:dating_app/models/user_model.dart';
import 'package:dating_app/plugins/swipe_stack/swipe_stack.dart';
import 'package:dating_app/screens/disliked_profile_screen.dart';
import 'package:dating_app/screens/profile_screen.dart';
import 'package:dating_app/widgets/cicle_button.dart';
import 'package:dating_app/widgets/custom_curved_appbar.dart';
import 'package:dating_app/widgets/no_data.dart';
import 'package:dating_app/widgets/processing.dart';
import 'package:dating_app/widgets/profile_card.dart';
import 'package:flutter/material.dart';
import 'package:dating_app/api/users_api.dart';

class DiscoverTab extends StatefulWidget {
  const DiscoverTab({Key? key}) : super(key: key);

  @override
  _DiscoverTabState createState() => _DiscoverTabState();
}

class _DiscoverTabState extends State<DiscoverTab>
    with TickerProviderStateMixin {
  // Variables
  final GlobalKey<SwipeStackState> _swipeKey = GlobalKey<SwipeStackState>();
  final DislikesApi _dislikesApi = DislikesApi();
  final VisitsApi _visitsApi = VisitsApi();
  final UsersApi _usersApi = UsersApi();
  List<DocumentSnapshot<Map<String, dynamic>>>? _users;
  late AppLocalizations _i18n;

  List<DocumentSnapshot> _removedUsers = [];
  late AnimationController _removeAnimationController;
  double? _listPaddingTop;

  /// Get all Users
  Future<void> _loadUsers(
      List<DocumentSnapshot<Map<String, dynamic>>> dislikedUsers) async {
    _usersApi.getUsers(dislikedUsers: dislikedUsers).then((users) {
      // Check result
      if (users.isNotEmpty) {
        if (mounted) {
          setState(() => _users = users);
        }
      } else {
        if (mounted) {
          setState(() => _users = []);
        }
      }
      // Debug
      debugPrint('getUsers() -> ${users.length}');
      debugPrint('getDislikedUsers() -> ${dislikedUsers.length}');
    });
  }

  @override
  void initState() {
    super.initState();

    /// First: Load All Disliked Users to be filtered
    _dislikesApi.getDislikedUsers(withLimit: false).then(
        (List<DocumentSnapshot<Map<String, dynamic>>> dislikedUsers) async {
      /// Validate user max distance
      await UserModel().checkUserMaxDistance();

      /// Load all users
      await _loadUsers(dislikedUsers);
    });
  }

  @override
  Widget build(BuildContext context) {
    /// Initialization
    _i18n = AppLocalizations.of(context);
    return _showUsers();
  }

  // Function to remove the user from the list
  void removeUser(var index) {
    if (index >= 0) {
      setState(() {
        _users!.removeAt(index);
      });
    }
  }

  Widget _showUsers() {
    /// Check result
    if (_users == null) {
      return Stack(
        children: [
          Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SizedBox(
                  width: 100,
                  child: CustomCurvedAppBar(
                    header: "DISCOVER",
                  ))),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Processing(text: _i18n.translate("loading")),
            ],
          ),
        ],
      );
    } else if (_users!.isEmpty) {
      /// No user found
      return Stack(
        children: [
          Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SizedBox(
                  width: 100,
                  child: CustomCurvedAppBar(
                    header: "DISCOVER",
                  ))),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              NoData(
                  svgName: 'search_icon',
                  text: _i18n.translate(
                      "no_user_found_around_you_please_try_again_later")),
            ],
          ),
        ],
      );
    } else {
      return Stack(
        fit: StackFit.expand,
        children: [
          /// User card list
          // SwipeStack(
          //     key: _swipeKey,
          //     children: _users!.map((userDoc) {
          //       // Get User object
          //       final User user = User.fromDocument(userDoc.data()!);
          //       // Return user profile
          //       return SwiperItem(
          //           builder: (SwiperPosition position, double progress) {
          //         /// Return User Card
          //         return ProfileCard(
          //             page: 'discover', position: position, user: user);
          //       });
          //     }).toList(),
          //     padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
          //     translationInterval: 6,
          //     scaleInterval: 0.03,
          //     stackFrom: StackFrom.None,
          //     onEnd: () => debugPrint("onEnd"),
          //     onSwipe: (int index, SwiperPosition position) {
          //       /// Control swipe position
          //       switch (position) {
          //         case SwiperPosition.None:
          //           break;
          //         case SwiperPosition.Left:

          //           /// Swipe Left Dislike profile
          //           _dislikesApi.dislikeUser(
          //               dislikedUserId: _users![index][USER_ID],
          //               onDislikeResult: (r) =>
          //                   debugPrint('onDislikeResult: $r'));

          //           break;

          //         case SwiperPosition.Right:

          //           /// Swipe right and Like profile
          //           _likeUser(context, clickedUserDoc: _users![index]);

          //           break;
          //       }
          //     }),

          Container(
            height: MediaQuery.sizeOf(context).height,
            width: MediaQuery.sizeOf(context).width,
            color: const Color(0xffd7dee5),
          ),
          Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SizedBox(
                  width: 100,
                  child: CustomCurvedAppBar(
                    header: "DISCOVER",
                  ))),
          NotificationListener<ScrollNotification>(
            onNotification: (scrollNotification) {
              if (scrollNotification is ScrollUpdateNotification) {
                double paddingTop = 100 - scrollNotification.metrics.pixels;
                if (paddingTop < 0) {
                  paddingTop = 0;
                }
                // Update padding dynamically
                setState(() {
                  _listPaddingTop = paddingTop;
                });
              }
              return false;
            },
            child: Container(
              padding: EdgeInsets.only(top: _listPaddingTop ?? 120),
              child: AnimatedList(
                initialItemCount: _users!.length,
                itemBuilder: (context, index, animation) {
                  final userDoc = _users![index];
                  final user = User.fromDocument(userDoc.data()!);

                  if (_removedUsers.contains(userDoc)) {
                    // Item is being removed, apply custom animation
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: Offset(1.0, 0.0),
                        end: Offset(0.0, 0.0),
                      ).animate(animation),
                      child: ProfileCard(
                        page: 'discover',
                        position: SwiperPosition.None,
                        user: user,
                        usersList: _users,
                        userDoc: userDoc,
                        onLikeSuccessCallback: () => removeUser(index),
                      ),
                    );
                  } else {
                    // Item is not being removed, show it normally
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ProfileCard(
                          page: 'discover',
                          position: SwiperPosition.None,
                          user: user,
                          usersList: _users,
                          userDoc: userDoc,
                          onLikeSuccessCallback: () => removeUser(index),
                        ),
                      ],
                    );
                  }
                },
              ),
            ),
          ),
        ],
      );
    }
  }

  /// Build swipe buttons
  Widget swipeButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        /// Rewind profiles
        ///
        /// Go to Disliked Profiles
        cicleButton(
            bgColor: Colors.white,
            padding: 8,
            icon: const Icon(Icons.restore, size: 22, color: Colors.grey),
            onTap: () {
              // Go to Disliked Profiles Screen
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const DislikedProfilesScreen()));
            }),

        const SizedBox(width: 20),

        /// Swipe left and reject user
        cicleButton(
            bgColor: Colors.white,
            padding: 8,
            icon: const Icon(Icons.close, size: 35, color: Colors.grey),
            onTap: () {
              /// Get card current index
              final cardIndex = _swipeKey.currentState!.currentIndex;

              /// Check card valid index
              if (cardIndex != -1) {
                /// Swipe left
                _swipeKey.currentState!.swipeLeft();
              }
            }),

        const SizedBox(width: 20),

        /// Swipe right and like user
        cicleButton(
            bgColor: Colors.white,
            padding: 8,
            icon: Icon(Icons.favorite_border,
                size: 35, color: Theme.of(context).primaryColor),
            onTap: () async {
              /// Get card current index
              final cardIndex = _swipeKey.currentState!.currentIndex;

              /// Check card valid index
              if (cardIndex != -1) {
                /// Swipe right
                _swipeKey.currentState!.swipeRight();
              }
            }),

        const SizedBox(width: 20),

        /// Go to user profile
        cicleButton(
            bgColor: Colors.white,
            padding: 8,
            icon:
                const Icon(Icons.remove_red_eye, size: 22, color: Colors.grey),
            onTap: () {
              /// Get card current index
              final cardIndex = _swipeKey.currentState!.currentIndex;

              /// Check card valid index
              if (cardIndex != -1) {
                /// Get User object
                final User user = User.fromDocument(_users![cardIndex].data()!);

                /// Go to profile screen
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) =>
                        ProfileScreen(user: user, showButtons: false)));

                /// Increment user visits an push notification
                _visitsApi.visitUserProfile(
                  visitedUserId: user.userId,
                  userDeviceToken: user.userDeviceToken,
                  nMessage:
                      _i18n.translate("visited_your_profile_click_and_see"),
                );
              }
            }),
      ],
    );
  }
}
