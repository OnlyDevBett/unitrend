import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_skeleton/flutter_skeleton.dart';
import 'package:page_transition/page_transition.dart';
import 'package:swipedetector/swipedetector.dart';
import 'package:unitrend/models/user.dart';
import 'package:unitrend/resources/repository.dart';
import 'package:unitrend/ui/insta_home_screen.dart';
import 'package:unitrend/ui/post_detail_screen.dart';
import 'package:unitrend/utils/colors.dart';

class InstaSearchScreen extends StatefulWidget {
  @override
  _InstaSearchScreenState createState() => _InstaSearchScreenState();
}

class _InstaSearchScreenState extends State<InstaSearchScreen> {
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
      _repository.retrieveAllPosts(user).then((updatedList) {
        setState(() {
          list = updatedList;
        });
      });
      _repository.fetchAllUsers(user).then((list) {
        setState(() {
          usersList = list;
          isLoading = false;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    print("INSIDE BUILD");
    return Scaffold(
      appBar: _getAppBar(),
      body: SwipeDetector(
        onSwipeRight: () {
          Navigator.push(
              context,
              PageTransition(
                  type: PageTransitionType.leftToRight,
                  child: InstaHomeScreen()));
        },
        child: Stack(
          children: <Widget>[
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
        color: Colors.grey.withOpacity(0.35),
        child: GridView.builder(
            padding: EdgeInsets.fromLTRB(10, 25, 10, 110),
            //shrinkWrap: true,
            itemCount: list.length,
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
                                currentuser: currentUser,
                                documentSnapshot: list[index],
                                documentReference: list[index].reference))));
                  },
                  child: _getPost(
                    image:
                        CachedNetworkImageProvider(list[index].data['imgUrl']),
                    context: context,
                  ));
            })));
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

  _getAppBar() {
    return PreferredSize(
        preferredSize: Size.fromHeight(60),

        child: Stack(children: <Widget>[
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
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      15.0,
                      15.0,
                      30.0,
                      0.0,
                    ),
                    child: Text('All Posts',
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
