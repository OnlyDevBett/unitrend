import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:unitrend/common/app_background.dart';
import 'package:unitrend/models/feed.dart';
import 'package:unitrend/ui/insta_home_screen.dart';
import 'package:unitrend/ui/post_detail_screen.dart';
import 'package:unitrend/utils/colors.dart';
import 'package:image_picker/image_picker.dart';
import 'package:unitrend/ui/insta_upload_photo_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unitrend/models/user.dart';
import 'package:unitrend/resources/repository.dart';
import 'package:flutter_skeleton/flutter_skeleton.dart';
import 'package:shimmer/shimmer.dart';
import 'package:swipedetector/swipedetector.dart';

import 'insta_feed_screen.dart';

class DetailPage extends StatefulWidget {
  final Challenge challenge;

  DetailPage(this.challenge);

  @override
  _DetailPageState createState() => _DetailPageState(challenge);
}

class _DetailPageState extends State<DetailPage> {
  final Challenge challenge;

  _DetailPageState(this.challenge);

  int _currentIndex = 0;
  final double expanded_height = 400;
  final double rounded_container_height = 50;

  File imageFile;

  var _repository = Repository();
  List<DocumentSnapshot> list = List<DocumentSnapshot>();
  User _user = User();
  User currentUser;
  List<User> usersList = List<User>();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _repository.getCurrentUser().then((user) {
      _user.uid = user.uid;
      _user.displayName = user.displayName;
      _user.photoUrl = user.photoUrl;
      _repository.fetchUserDetailsById(user.uid).then((user) {
        setState(() {
          currentUser = user;
        });
      });
      print("USER : ${user.displayName}");

      _repository
          .retrievePosts(user, widget.challenge.name)
          .then((updatedList) {
        setState(() {
          list = updatedList;
          isLoading = false;
        });
      });
      _repository.fetchAllUsers(user).then((list) {
        setState(() {
          usersList = list;
        });
      });
    });
  }

  Future<File> _pickImage(String action) async {
    File selectedImage;

    action == 'Gallery'
        ? selectedImage =
            await ImagePicker.pickImage(source: ImageSource.gallery)
        : await ImagePicker.pickImage(source: ImageSource.camera);

    return selectedImage;
  }

  Future _showImageDialog() {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: ((context) {
          return SimpleDialog(
            children: <Widget>[
              SimpleDialogOption(
                child: Text('Choose from Gallery'),
                onPressed: () {
                  _pickImage('Gallery').then((selectedImage) {
                    setState(() {
                      imageFile = selectedImage;
                    });

                    var text = '${challenge.name}';
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: ((context) => InstaUploadPhotoScreen(
                                  imageFile: imageFile,
                                  text: text,
                                ))));
                  });
                },
              ),
              SimpleDialogOption(
                child: Text('Take Photo'),
                onPressed: () {
                  _pickImage('Camera').then((selectedImage) {
                    setState(() {
                      imageFile = selectedImage;
                    });

                    var text = '${challenge.name}';
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: ((context) => InstaUploadPhotoScreen(
                                imageFile: imageFile, text: text))));
                  });
                },
              ),
              SimpleDialogOption(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
          );
        }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _getAppBar(),
      body: SwipeDetector(
        onSwipeRight: () {
          Navigator.pushReplacement(
              context,
              PageTransition(
                  type: PageTransitionType.leftToRight,
                  child: InstaHomeScreen()));
                  Navigator.push(
              context,
              PageTransition(
                  type: PageTransitionType.leftToRight,
                  child: FeedPage()));
        },
        child: Stack(
          children: <Widget>[
          AppBackground(),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(widget.challenge.description,
                  style: TextStyle(
                      color: Colors.black,
                      letterSpacing: 2.0,
                      fontSize: 15.0,
                      fontWeight: FontWeight.w400)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 130.0, 8.0, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('Posts for this Challenge',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600)
                        ),
                ],
              ),
            ),
            if (isLoading == true)
              Padding(
                padding: EdgeInsets.only(top: 165),
                child: CardListSkeleton(
                  style: SkeletonStyle(
                    theme: SkeletonTheme.Light,
                    isShowAvatar: true,
                    isCircleAvatar: true,
                    barCount: 5,
                  ),
                ),
              ),
            _getPostsList(context),
            _getBottomBarShadow(context),
            _getBottomBar(context),
            Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top,
              ),
            )
          ],
        ),
      ),
    );
  }

  _getPostsList(context) {
    return Container(
        color: Colors.grey.withOpacity(0.25),
        child: ListView.builder(
          padding: EdgeInsets.only(top: 165),
          scrollDirection: Axis.vertical,
          itemCount: list.length,
          itemBuilder: ((context, index) {
            print("LIST : ${list.length}");
            return GestureDetector(
              onTap: () {
                print("SNAPSHOT : ${list[index].reference.path}");
                Navigator.pushReplacement(
                    context,
                    PageTransition(
                        type: PageTransitionType.scale,
                        alignment: Alignment.bottomCenter,
                        child: PostDetailScreen(
                            user: _user,
                            currentuser: currentUser,
                            documentSnapshot: list[index],
                            documentReference: list[index].reference)));
              },
              child: _getPost(
                image: CachedNetworkImageProvider(list[index].data['imgUrl']),
                name: list[index].data['postOwnerName'],
                avatar: CachedNetworkImageProvider(list[index].data['imgUrl']),
                context: context,
              ),
            );
          }),
        ));
  }

  _getPost(
      {CachedNetworkImageProvider image,
      String name,
      CachedNetworkImageProvider avatar,
      FieldValue timeStamp,
      context}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      child: Container(
        width: double.infinity,
        height: 530.0,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25.0),
        ),
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0),
              child: Column(
                children: <Widget>[
                  ListTile(
                    leading: Container(
                      width: 50.0,
                      height: 50.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black45,
                            offset: Offset(0, 2),
                            blurRadius: 6.0,
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        child: ClipOval(
                          child: Image(
                            height: 50.0,
                            width: 50.0,
                            image: avatar,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  InkWell(
                    onDoubleTap: () => print('Like post'),
                    child: Container(
                      margin: EdgeInsets.all(10.0),
                      width: double.infinity,
                      height: 400.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black45,
                            offset: Offset(0, 5),
                            blurRadius: 8.0,
                          ),
                        ],
                        image: DecorationImage(
                          image: image,
                          fit: BoxFit.fitWidth,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _getBottomBarShadow(context) {
    return Positioned(
      bottom: 0,
      child: Container(
        height: 150,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
              Colors.grey.withOpacity(0.8),
              Colors.grey.withOpacity(0.01),
            ])),
      ),
    );
  }

  _getBottomBar(context) {
    return Positioned(
      bottom: 0,
      child: ClipPath(
        child: Container(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(25, 0, 25, 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Container(
                  width: 55,
                  height: 55,
                  margin: EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                      gradient: primaryGradient,
                      boxShadow: [
                        BoxShadow(
                          color:
                              Colors.deepOrangeAccent.shade100.withOpacity(.6),
                          offset: Offset(0, 10),
                          blurRadius: 20,
                        )
                      ],
                      borderRadius: BorderRadius.circular(25)),
                  child: IconButton(
                    icon: Icon(Icons.add),
                    color: Colors.grey.shade300,
                    onPressed: () => _showImageDialog(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _getAppBar() {
    return PreferredSize(
        preferredSize: Size.fromHeight(75),
        child: Stack(children: <Widget>[
          ClipRRect(
              child: Container(
            decoration: BoxDecoration(color: primaryColor),
          )),
          if (widget.challenge.rarity == 'hard')
            ClipRRect(
              child: Shimmer.fromColors(
                baseColor: primaryColor,
                highlightColor: Colors.white10,
                child: Container(
                  decoration: BoxDecoration(color: primaryColor),
                ),
              ),
            ),
          if (widget.challenge.rarity == 'legendary')
            ClipRRect(
                child: Container(
              decoration: BoxDecoration(gradient: primaryGradient),
            )),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
              context,
              PageTransition(
                  type: PageTransitionType.leftToRight,
                  child: InstaHomeScreen()));
                  Navigator.push(
              context,
              PageTransition(
                  type: PageTransitionType.leftToRight,
                  child: FeedPage()));
                    },
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        15.0,
                        15.0,
                        30.0,
                        0.0,
                      ),
                      child: Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      15.0,
                      15.0,
                      30.0,
                      0.0,
                    ),
                    child: Text(widget.challenge.name,
                        style: TextStyle(
                            color: Colors.white,
                            letterSpacing: 5.0,
                            fontSize: 25.0,
                            fontWeight: FontWeight.w400)),
                  ),
                ],
              ),
            ],
          ),
        ]));
  }
}

class BottomBarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    var sw = size.width;
    var sh = size.height;

    path.moveTo(0, sh * 0.35);
    path.lineTo(sw * 0.3, sh * 0.35);
    path.cubicTo(sw * 0.4, sh * 0.35, sw * 0.4, 0, sw * 0.5, 0);
    path.cubicTo(sw * 0.6, 0, sw * 0.6, sh * 0.35, sw * 0.7, sh * 0.35);
    path.lineTo(sw, sh * 0.35);
    path.lineTo(sw, sh);
    path.lineTo(0, sh);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
