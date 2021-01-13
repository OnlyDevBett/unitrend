import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:unitrend/common/app_background.dart';
import 'package:unitrend/models/feed.dart';
import 'dart:math';
import 'package:unitrend/ui/feed_detail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unitrend/models/user.dart';
import 'package:unitrend/utils/colors.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:shimmer/shimmer.dart';

class FeedPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: secondCircleColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'UniTre',
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 40.0,
                ),
              ),
              Text(
                'nd',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: secondaryLight,
                  fontSize: 40.0,
                ),
              )
            ],
          ),
          Expanded(
            flex: 2,
            child: PageViewWidget(),
          ),
        ],
      ),
    );
  }
}

class PageViewWidget extends StatefulWidget {
  @override
  _PageViewWidgetState createState() => _PageViewWidgetState();
}

class _PageViewWidgetState extends State<PageViewWidget> {
  List<Challenge> _list = Challenge.generateChallenge();

  PageController pageController;

  double viewportFraction = 0.8;

  double pageOffset = 0;

  User currentUser, user, followingUser;
  IconData icon;
  Color color;
  List<User> usersList = List<User>();
  Future<List<DocumentSnapshot>> _future;
  List<String> followingUIDs = List<String>();

  @override
  void initState() {
    super.initState();
    pageController =
        PageController(initialPage: 0, viewportFraction: viewportFraction)
          ..addListener(() {
            setState(() {
              pageOffset = pageController.page;
            });
          });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: <Widget>[
      AppBackground(),
      PageView.builder(
        controller: pageController,
        itemBuilder: (context, index) {
          double scale = max(viewportFraction,
              (1 - (pageOffset - index).abs()) + viewportFraction);

          double angle = (pageOffset - index).abs();
          if (angle > 0.5) {
            angle = 1 - angle;
          }
          var bean = _list[index];

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                PageTransition(
                  type: PageTransitionType.scale,
                  alignment: Alignment.bottomCenter,
                  child: DetailPage(
                    bean,
                  ),
                ),
              );
            },
            child: Container(
              padding: EdgeInsets.only(
                right: 10,
                left: 20,
                top: 100 - scale * 25,
                bottom: 50,
              ),
              child: Transform(
                transform: Matrix4.identity()
                  ..setEntry(
                    3,
                    2,
                    0.001,
                  )
                  ..rotateY(angle),
                alignment: Alignment.center,
                child: Stack(
                  children: <Widget>[
                    ClipRRect(
                        borderRadius: BorderRadius.circular(15.0),
                        child: Container(
                          decoration: BoxDecoration(gradient: primaryGradient),
                        )),
                    if (_list[index].rarity == 'hard')
                      ClipRRect(
                        borderRadius: BorderRadius.circular(15.0),
                        child: Shimmer.fromColors(
                          baseColor: primaryColor,
                          highlightColor: Colors.white10,
                          child: Container(
                            decoration: BoxDecoration(gradient: primaryGradient),
                          ),
                        ),
                      ),
                    if (_list[index].rarity == 'legendary')
                      ClipRRect(
                          borderRadius: BorderRadius.circular(15.0),
                          child: Container(
                            decoration:
                                BoxDecoration(gradient: primaryGradient),
                          )),
                    Positioned(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0.0, 25.0, 0.0, 0.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              _list[index].name,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 70),
                    Positioned(
                      child: Padding(
                        padding:
                            const EdgeInsets.fromLTRB(15.0, 75.0, 15.0, 0.0),
                        child: AutoSizeText(
                          _list[index].description,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Align(
                        alignment: FractionalOffset.bottomRight,
                        child: Text(
                          '[ ${_list[index].rarity} ]',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        },
        itemCount: _list.length,
      ),
    ]);
  }
}
