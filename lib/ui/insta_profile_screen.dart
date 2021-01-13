import 'dart:async';
import 'package:async/async.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:swipedetector/swipedetector.dart';
import 'package:unitrend/main.dart';
import 'package:unitrend/models/user.dart';
import 'package:unitrend/resources/repository.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:unitrend/ui/edit_profile_screen.dart';
import 'package:unitrend/ui/post_detail_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:unitrend/utils/colors.dart';

class InstaProfileScreen extends StatefulWidget {
  final String name;
  InstaProfileScreen({this.name});
  @override
  _InstaProfileScreenState createState() => _InstaProfileScreenState();
}

class _InstaProfileScreenState extends State<InstaProfileScreen> {
  var _repository = Repository();
  List<DocumentSnapshot> list = List<DocumentSnapshot>();
  User _user;
  IconData icon;
  Color color;
  Future<List<DocumentSnapshot>> _future;

  @override
  void initState() {
    super.initState();
    retrieveUserDetails();
    icon = FontAwesomeIcons.heart;
  }

  retrieveUserDetails() async {
    FirebaseUser currentUser = await _repository.getCurrentUser();
    User user = await _repository.retrieveUserDetails(currentUser);
    setState(() {
      _user = user;
    });
    _future = _repository.retrieveUserPosts(_user.uid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: _user != null
            ? SwipeDetector(
                onSwipeRight: () {
                  Navigator.pop(context,
                      PageTransition(type: PageTransitionType.leftToRight));
                },
                child: Stack(
                  children: <Widget>[
                    _getPostsList(context) == null
                        ? Container()
                        : _getPostsList(context),
                    _getHeader(context),
                  ],
                ),
              )
            : Container());
  }

  _getPostsList(context) {
    return Container(
        color: Colors.grey.withOpacity(0.35),
        child: FutureBuilder(
          future: _future,
          builder: ((context, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
            if (snapshot.hasData) {
              if (snapshot.connectionState == ConnectionState.done) {
                return SizedBox(
                    height: 630.0,
                    child: GridView.builder(
                        padding: EdgeInsets.fromLTRB(10, 325, 10, 110),
                        //shrinkWrap: true,
                        itemCount: snapshot.data.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                        ),
                        itemBuilder: ((context, index) {
                          return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: ((context) => PostDetailScreen(
                                            user: _user,
                                            documentSnapshot:
                                                snapshot.data[index],
                                            documentReference: snapshot
                                                .data[index].reference))));
                              },
                              child: _getPost(
                                image: CachedNetworkImageProvider(
                                    snapshot.data[index].data['imgUrl']),
                                context: context,
                              ));
                        })));
              } else {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          }),
        ));
  }

  _getPost({context, CachedNetworkImageProvider image}) {
    print('help');
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: MediaQuery.of(context).size.width * 0.4,
        width: MediaQuery.of(context).size.width * 0.4,
        decoration: BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.cover,
              image: image,
            ),
            borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  _getHeader(context) {
    return Positioned(
      top: 0,
      child: Container(
        padding: EdgeInsets.fromLTRB(15, 35, 15, 15),
        height: 290,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(35),
            boxShadow: [
              BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  blurRadius: 15,
                  offset: Offset(0, 5))
            ]),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            _getAvatar(),
            SizedBox(height: 10),
            Text(
              '${_user.displayName}',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 10),
            _getUserStats(),
            SizedBox(
              height: 10,
            ),
            _getUserBtns(),
          ],
        ),
      ),
    );
  }

  _getUserBtns() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        GestureDetector(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
            decoration: BoxDecoration(
                gradient: primaryGradient,
                borderRadius: BorderRadius.circular(10)),
            child: Text(
              'Edit Profile',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
            ),
          ),
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: ((context) => EditProfileScreen(
                        photoUrl: _user.photoUrl,
                        email: _user.email,
                        bio: _user.bio,
                        name: _user.displayName,
                        phone: _user.phone))));
          },
        ),
        SizedBox(
          width: 15,
        ),
        GestureDetector(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
            decoration: BoxDecoration(
                gradient: primaryGradient,
                borderRadius: BorderRadius.circular(10)),
            child: Text(
              'Sign Out',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
            ),
          ),
          onTap: () {
            _repository.signOut().then((v) {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) {
                return MyApp();
              }));
            });
          },
        ),
      ],
    );
  }

  _getUserStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
          child: Container(
            decoration: BoxDecoration(
                border:
                    Border(right: BorderSide(color: Colors.grey, width: 0.5))),
            child: Column(
              children: <Widget>[
                StreamBuilder(
                  stream: _repository
                      .fetchStats(uid: _user.uid, label: 'posts')
                      .asStream(),
                  builder: ((context,
                      AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
                    if (snapshot.hasData) {
                      return detailsWidget(
                          snapshot.data.length.toString(), 'posts');
                    } else {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  }),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
                border:
                    Border(right: BorderSide(color: Colors.grey, width: 0.5))),
            child: Column(
              children: <Widget>[
                StreamBuilder(
                  stream: _repository
                      .fetchStats(uid: _user.uid, label: 'followers')
                      .asStream(),
                  builder: ((context,
                      AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
                    if (snapshot.hasData) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 24.0),
                        child: detailsWidget(
                            snapshot.data.length.toString(), 'followers'),
                      );
                    } else {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  }),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Column(
            children: <Widget>[
              StreamBuilder(
                stream: _repository
                    .fetchStats(uid: _user.uid, label: 'following')
                    .asStream(),
                builder:
                    ((context, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
                  if (snapshot.hasData) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: detailsWidget(
                          snapshot.data.length.toString(), 'following'),
                    );
                  } else {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                }),
              ),
            ],
          ),
        ),
      ],
    );
  }

  _getAvatar() {
    return Stack(
      alignment: AlignmentDirectional.center,
      children: <Widget>[
        Container(
          width: 73,
          height: 73,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [Colors.orange.shade400, Colors.pink]),
              borderRadius: BorderRadius.circular(50)),
        ),
        CircleAvatar(
          backgroundColor: Colors.white,
          radius: 35,
        ),
        CircleAvatar(
          backgroundImage: NetworkImage(_user.photoUrl),
          radius: 30,
        ),
      ],
    );
  }

  Widget detailsWidget(String count, String label) {
    return Column(
      children: <Widget>[
        Text(count,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
                color: Colors.black)),
        Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child:
              Text(label, style: TextStyle(fontSize: 16.0, color: Colors.grey)),
        )
      ],
    );
  }
}
