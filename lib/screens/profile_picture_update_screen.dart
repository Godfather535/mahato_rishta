import 'dart:io';

import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import '../models/user_model.dart';
import '../widgets/image_source_sheet.dart';
import '../widgets/show_scaffold_msg.dart';
import '../widgets/svg_icon.dart';
import '../widgets/user_gallery.dart';
import 'home_screen.dart';

class ProfilePictureUpdateScreen extends StatefulWidget {
  const ProfilePictureUpdateScreen({Key? key}) : super(key: key);

  @override
  _ProfilePictureUpdateScreenState createState() => _ProfilePictureUpdateScreenState();
}

class _ProfilePictureUpdateScreenState extends State<ProfilePictureUpdateScreen> {

  File? _imageFile;

  void _getImage(BuildContext context) async {
    await showModalBottomSheet(
        context: context,
        builder: (context) => ImageSourceSheet(
          onImageSelected: (image) {
            if (image != null) {
              setState(() {
                _imageFile = image;
              });
              // close modal
              Navigator.of(context).pop();
            }
          },
        ));
  }

  void _goToHomeScreen() {
    /// Go to home screen
    Future(() {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => HomeScreen()),
              (route) => false);
    });
  }

  _updateProfile() async {
    /// Update profile image
    await UserModel().updateProfileImage(
      imageFile: _imageFile, oldImageUrl: "https://", path: 'profile',);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Color(0xff010b29),title: Text("Profile",style: TextStyle(color: Color(0xffff9c9c)),),),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xff010b29),
        child: Center(
          child: Icon(Icons.arrow_forward_ios,color: Color(0xffff9c9c),),
        ),
        onPressed: (){
          if(_imageFile != null){
            _updateProfile();
            _goToHomeScreen();
          } else {
            showScaffoldMessage(
                context: context,
                duration: Duration(seconds: 7),
                message: "Profile Picture is mandatory!",
                bgcolor: Colors.red);
          }
        },
      ),
      body: SingleChildScrollView(
        child: ScopedModelDescendant<UserModel>(
            builder: (context, child, userModel) {
            return Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18.0,vertical: 28),
                    child: Container(
                      width: MediaQuery.of(context).size.width/3,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(68),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey[500]!,
                                offset: const Offset(4, 4),
                                blurRadius: 15,
                                spreadRadius: 1),
                            BoxShadow(
                                color: Colors.white,
                                offset: const Offset(-4, -4),
                                blurRadius: 15,
                                spreadRadius: 1)
                          ]),
                      child: Center(
                        child: GestureDetector(
                          child: Center(
                              child: _imageFile == null
                                  ? CircleAvatar(
                                radius: 60,
                                backgroundColor: Theme.of(context).primaryColor,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SvgIcon("assets/icons/camera_icon.svg",
                                        width: 40, height: 40, color: Colors.white),
                                    SizedBox(
                                      height: 8,
                                    ),
                                    Text("Profile Picture",style: TextStyle(color: Colors.white,fontWeight: FontWeight.w300,fontSize: 12),)
                                  ],
                                ),
                              )
                                  : CircleAvatar(
                                radius: 60,
                                backgroundImage: FileImage(_imageFile!),
                              )),
                          onTap: () {
                            /// Get profile image
                            _getImage(context);
                          },
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18.0),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(68),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey[500]!,
                                offset: const Offset(4, 4),
                                blurRadius: 15,
                                spreadRadius: 1),
                            BoxShadow(
                                color: Colors.white,
                                offset: const Offset(-4, -4),
                                blurRadius: 15,
                                spreadRadius: 1)
                          ]),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(28.0),
                          child: UserGallery(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        ),
      ),
    );
  }
}
