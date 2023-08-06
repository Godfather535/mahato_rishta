import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dating_app/api/dislikes_api.dart';
import 'package:dating_app/api/likes_api.dart';
import 'package:dating_app/api/matches_api.dart';
import 'package:dating_app/api/visits_api.dart';
import 'package:dating_app/constants/constants.dart';
import 'package:dating_app/datas/user.dart';
import 'package:dating_app/dialogs/its_match_dialog.dart';
import 'package:dating_app/dialogs/report_dialog.dart';
import 'package:dating_app/helpers/app_localizations.dart';
import 'package:dating_app/models/user_model.dart';
import 'package:dating_app/plugins/swipe_stack/swipe_stack.dart';
import 'package:dating_app/screens/disliked_profile_screen.dart';
import 'package:dating_app/screens/profile_screen.dart';
import 'package:dating_app/widgets/cicle_button.dart';
import 'package:dating_app/widgets/custom_badge.dart';
import 'package:dating_app/widgets/default_card_border.dart';
import 'package:dating_app/widgets/show_like_or_dislike.dart';
import 'package:dating_app/widgets/svg_icon.dart';
import 'package:flutter/material.dart';
import 'package:dating_app/helpers/app_helper.dart';

class ProfileCard extends StatefulWidget {
  /// User object
  final User user;

  /// Screen to be checked
  final String? page;

  /// Swiper position
  final SwiperPosition? position;
  final List<DocumentSnapshot<Map<String, dynamic>>>? usersList;
  DocumentSnapshot<Map<String, dynamic>>? userDoc;
  Function? onLikeSuccessCallback;

  ProfileCard(
      {Key? key,
      this.page,
      this.position,
      required this.user,
      this.usersList,
      required this.userDoc,
      this.onLikeSuccessCallback})
      : super(key: key);

  @override
  State<ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends State<ProfileCard>
    with SingleTickerProviderStateMixin {
  final LikesApi _likesApi = LikesApi();

  final DislikesApi _dislikesApi = DislikesApi();

  final MatchesApi _matchesApi = MatchesApi();

  final GlobalKey<SwipeStackState> _swipeKey = GlobalKey<SwipeStackState>();

  // Local variables
  final AppHelper _appHelper = AppHelper();

  late AppLocalizations _i18n;

  final VisitsApi _visitsApi = VisitsApi();

  late AnimationController removalAnimationController;
  late User user;
  bool isFlagEnabled = false;

  @override
  void initState() {
    removalAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    user = User.fromDocument(widget.userDoc!.data()!);

    super.initState();
  }

  @override
  void dispose() {
    removalAnimationController.dispose();
    super.dispose();
  }

  /// Build swipe buttons
  Widget swipeButtons(BuildContext context) {
    _i18n = AppLocalizations.of(context);
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
              _likeUser(context, clickedUserDoc: widget.userDoc!);
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
              // final cardIndex = _swipeKey.currentState!.currentIndex;

              /// Check card valid index
              // if (cardIndex != -1) {
              /// Get User object

              /// Go to profile screen
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) =>
                      ProfileScreen(user: user, showButtons: false)));

              /// Increment user visits an push notification
              _visitsApi.visitUserProfile(
                visitedUserId: user.userId,
                userDeviceToken: user.userDeviceToken,
                nMessage: _i18n.translate("visited_your_profile_click_and_see"),
              );
              // }
            }),
      ],
    );
  }

  /// Like user function
  Future<void> _likeUser(BuildContext context,
      {required DocumentSnapshot<Map<String, dynamic>> clickedUserDoc}) async {
    /// Check match first
    await _matchesApi.checkMatch(
        userId: clickedUserDoc[USER_ID],
        onMatchResult: (result) {
          if (result) {
            /// It`s match - show dialog to ask user to chat or continue playing
            showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) {
                  return ItsMatchDialog(
                    swipeKey: _swipeKey,
                    matchedUser: User.fromDocument(clickedUserDoc.data()!),
                  );
                });
          }
        });

    /// like profile
    await _likesApi.likeUser(
        likedUserId: clickedUserDoc[USER_ID],
        userDeviceToken: clickedUserDoc[USER_DEVICE_TOKEN],
        nMessage: _i18n.translate("liked_your_profile_click_and_see"),
        onLikeResult: (result) {
          debugPrint('likeResult: $result');
          widget.usersList!.remove(widget.userDoc);
          widget.onLikeSuccessCallback!();
        });
  }

  @override
  Widget build(BuildContext context) {
    // Variables
    final bool requireVip =
        widget.page == 'require_vip' && !UserModel().userIsVip;
    late ImageProvider userPhoto;
    // Check user vip status
    if (requireVip) {
      userPhoto = const AssetImage('assets/images/crow_badge.png');
    } else {
      userPhoto = NetworkImage(widget.user.userProfilePhoto);
    }
    _i18n = AppLocalizations.of(context);

    //
    // Get User Birthday
    final DateTime userBirthday =
        DateTime(user.userBirthYear, user.userBirthMonth, user.userBirthDay);
    // Get User Current Age
    final int userAge = UserModel().calculateUserAge(userBirthday);
    final size = MediaQuery.sizeOf(context);
    // Build profile card
    return Padding(
      key: UniqueKey(),
      padding: const EdgeInsets.all(9.0),
      child: Stack(
        children: [
          /// User Card
          InkWell(
            onTap: () {
              /// Go to profile screen
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) =>
                      ProfileScreen(user: user, showButtons: false)));

              /// Increment user visits an push notification
              _visitsApi.visitUserProfile(
                visitedUserId: user.userId,
                userDeviceToken: user.userDeviceToken,
                nMessage: _i18n.translate("visited_your_profile_click_and_see"),
              );
            },
            child: SizedBox(
              height: size.height / 1.4,
              width: size.width / 1.1,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 0),
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  margin: const EdgeInsets.all(0),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(28.0),
                      topRight: Radius.circular(28.0),
                      topLeft: Radius.circular(28.0),
                      bottomRight: Radius.circular(28.0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5), // Shadow color
                        blurRadius: 2, // Spread radius
                        spreadRadius: 2, // Blur radius
                        offset:
                            const Offset(4, 4), // Offset in x and y directions
                      ),
                    ],
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      /// User profile image
                      image: DecorationImage(

                          /// Show VIP icon if user is not vip member
                          image: userPhoto,
                          fit: requireVip ? BoxFit.contain : BoxFit.cover),
                    ),
                    child: Container(
                      /// BoxDecoration to make user info visible
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                            begin: Alignment.bottomRight,
                            colors: [Colors.black, Colors.transparent]),
                      ),

                      /// User info container
                      child: Container(
                        alignment: Alignment.bottomLeft,
                        // padding: const EdgeInsets.all(10.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// User fullname
                            Container(
                              color: Colors.white.withOpacity(0.2),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            '${widget.user.userFullname}, '
                                            '${userAge.toString()}',
                                            style: TextStyle(
                                                fontSize:
                                                    widget.page == 'discover'
                                                        ? 18
                                                        : 16,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 8.0),

                                    // User location
                                    Row(
                                      children: [
                                        // Icon
                                        const SvgIcon(
                                            "assets/icons/location_point_icon.svg",
                                            color: Color(0xffFFFFFF),
                                            width: 16,
                                            height: 16),

                                        const SizedBox(width: 5),

                                        // Locality & Country
                                        Expanded(
                                          child: Text(
                                            "${widget.user.userLocality}, ${widget.user.userCountry}",
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),

                                    widget.page == 'discover'
                                        ? Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Container(
                                                  width: size.width / 1.3,
                                                  decoration: BoxDecoration(
                                                    color: Theme.of(context)
                                                        .primaryColor
                                                        .withOpacity(0.2),
                                                    border: Border.all(
                                                        color: Theme.of(context)
                                                            .primaryColor),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                  child: const Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 24,
                                                            vertical: 12),
                                                    child: Center(
                                                      child: Text(
                                                        "CHECK COMPLETE DETAILS",
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 12),
                                                      ),
                                                    ),
                                                  ),
                                                )
                                                // cicleButton(
                                                //     bgColor: Colors.white,
                                                //     padding: 8,
                                                //     icon: const Icon(Icons.remove_red_eye,
                                                //         size: 22, color: Colors.grey),
                                                //     onTap: () {
                                                //       /// Get card current index
                                                //       // final cardIndex = _swipeKey.currentState!.currentIndex;

                                                //       /// Check card valid index
                                                //       // if (cardIndex != -1) {
                                                //       /// Get User object

                                                //       /// Go to profile screen
                                                //       Navigator.of(context).push(
                                                //           MaterialPageRoute(
                                                //               builder: (context) =>
                                                //                   ProfileScreen(
                                                //                       user: user,
                                                //                       showButtons: false)));

                                                //       /// Increment user visits an push notification
                                                //       _visitsApi.visitUserProfile(
                                                //         visitedUserId: user.userId,
                                                //         userDeviceToken: user.userDeviceToken,
                                                //         nMessage:
                                                //             "${UserModel().user.userFullname.split(' ')[0]}, "
                                                //             "${_i18n.translate("visited_your_profile_click_and_see")}",
                                                //       );
                                                //       // }
                                                //     }),
                                              ],
                                            ),
                                          )
                                        : const SizedBox(),
                                  ],
                                ),
                              ),
                            ),

                            /// User education

                            // Note: Uncoment the code below if you want to show the education

                            // Row(
                            //   children: [
                            //     const SvgIcon("assets/icons/university_icon.svg",
                            //         color: Colors.white, width: 20, height: 20),
                            //     const SizedBox(width: 5),
                            //     Expanded(
                            //       child: Text(
                            //         user.userSchool,
                            //         style: const TextStyle(
                            //           color: Colors.white,
                            //           fontSize: 16,
                            //         ),
                            //         maxLines: 1,
                            //         overflow: TextOverflow.ellipsis,
                            //       ),
                            //     ),
                            //   ],
                            // ),

                            // const SizedBox(height: 3),

                            // User job title
                            // Note: Uncoment the code below if you want to show the job title

                            // Row(
                            //   children: [
                            //     const SvgIcon("assets/icons/job_bag_icon.svg",
                            //         color: Colors.white, width: 17, height: 17),
                            //     const SizedBox(width: 5),
                            //     Expanded(
                            //       child: Text(
                            //         user.userJobTitle,
                            //         style: const TextStyle(
                            //           color: Colors.white,
                            //           fontSize: 16,
                            //         ),
                            //         maxLines: 1,
                            //         overflow: TextOverflow.ellipsis,
                            //       ),
                            //     ),
                            //   ],
                            // ),

                            widget.page == 'discover'
                                ? const SizedBox(height: 10)
                                : const SizedBox(width: 0, height: 0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Positioned(
          //   bottom: 50,
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.center,
          //     children: [
          //       Expanded(
          //         child: Container(
          //           height: 50,
          //           width: size.width / 1.5,
          //           decoration: BoxDecoration(
          //             color: Colors.white,
          //             borderRadius: BorderRadius.circular(12),
          //           ),
          //           child: const Center(
          //             child: Text("Check full details"),
          //           ),
          //         ),
          //       )
          //     ],
          //   ),
          // ),

          /// Show location distance
          Positioned(
            top: 35,
            left: widget.page == 'discover' ? 18 : 5,
            child: CustomBadge(
                icon: widget.page == 'discover'
                    ? const SvgIcon("assets/icons/location_point_icon.svg",
                        color: Colors.white, width: 15, height: 15)
                    : null,
                text:
                    '${_appHelper.getDistanceBetweenUsers(userLat: widget.user.userGeoPoint.latitude, userLong: widget.user.userGeoPoint.longitude)}km'),
          ),

          /// Show Like or Dislike
          widget.page == 'discover'
              ? ShowLikeOrDislike(position: widget.position!)
              : const SizedBox(width: 0, height: 0),

          /// Show message icon
          widget.page == 'matches'
              ? Positioned(
                  bottom: 5,
                  right: 5,
                  child: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: const SvgIcon("assets/icons/message_icon.svg",
                          color: Colors.white, width: 30, height: 30)),
                )
              : const SizedBox(width: 0, height: 0),

          // Show Report/Block profile button
          widget.page == 'discover'
              ? Positioned(
                  top: 0,
                  right: 0,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: isFlagEnabled
                        ? Container(
                            key: const Key('flag'),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(0.5),
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(30),
                                topRight: Radius.circular(28),
                              ),
                            ),
                            child: Column(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      isFlagEnabled = false;
                                    });
                                  },
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.flag,
                                      color: Colors.white,
                                      size: size.aspectRatio * 40),
                                  onPressed: () =>
                                      ReportDialog(userId: widget.user.userId)
                                          .show(),
                                ),
                              ],
                            ),
                          )
                        : IconButton(
                            key: const Key('more'),
                            onPressed: () {
                              setState(() {
                                isFlagEnabled = true;
                              });
                            },
                            icon: const Icon(
                              Icons.more_horiz_outlined,
                            ),
                          ),
                  ),
                )
              // child: CircleAvatar(
              //   radius: size.height / 40,
              //   backgroundColor: Colors.black.withOpacity(0.2),
              //   child: IconButton(
              //       icon: Icon(Icons.flag,
              //           color: Theme.of(context).primaryColor,
              //           size: size.aspectRatio * 40),
              //       onPressed: () =>
              //           ReportDialog(userId: widget.user.userId).show()),
              // ))
              : const SizedBox(width: 0, height: 0),

          // /// Swipe buttons
          // widget.page == 'discover'
          //     ? Positioned(
          //         bottom: 15,
          //         left: 5,
          //         right: 5,
          //         child: Container(
          //             margin: const EdgeInsets.only(bottom: 20),
          //             child: Align(
          //               alignment: Alignment.bottomCenter,
          //               child: swipeButtons(context),
          //             )),
          //       )
          //     : const SizedBox(width: 0, height: 0),
        ],
      ),
    );
  }
}
