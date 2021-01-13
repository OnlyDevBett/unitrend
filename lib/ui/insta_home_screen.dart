
import 'package:custom_navigator/custom_scaffold.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:unitrend/ui/insta_feed_screen.dart';
import 'package:unitrend/ui/insta_profile_screen.dart';
import 'package:unitrend/ui/insta_search_screen.dart';

import 'chat_screen.dart';

class InstaHomeScreen extends StatefulWidget {
  InstaHomeScreen({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _InstaHomeScreenState createState() => _InstaHomeScreenState();
}

class _InstaHomeScreenState extends State<InstaHomeScreen> {
  // Custom navigator takes a global key if you want to access the
  // navigator from outside it's widget tree subtree
  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    // Here's the custom scaffold widget
    // It takes a normal scaffold with mandatory bottom navigation bar
    // and children who are your pages
    return CustomScaffold(
      scaffold: Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          elevation: 10,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.whatshot, size: 28, color: Colors.black54),
              title: Text(
                'Trends',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
              ),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assessment, size: 28, color: Colors.black54),
              title: Text(
                'All Posts',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
              ),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border, size: 28, color: Colors.black54),
              title: Text(
                'Users',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
              ),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person, size: 28, color: Colors.black54),
              title: Text(
                'Profile',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
              ),
            )
          ],
        ),
      ),

      // Children are the pages that will be shown by every click
      // They should placed in order such as
      // `page 0` will be presented when `item 0` in the [BottomNavigationBar] clicked.
      children: <Widget>[
        FeedPage(),
        InstaSearchScreen(),
        ChatScreen(),
        InstaProfileScreen(),
      ],
      // Called when one of the [items] is tapped.
      onItemTap: (index) {},
    );
  }

}