import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:unitrend/models/user.dart';
import 'package:unitrend/resources/repository.dart';
import 'package:unitrend/models/comment.dart';
import 'package:unitrend/ui/insta_profile_screen.dart';
import 'package:unitrend/utils/colors.dart';
import 'package:swipedetector/swipedetector.dart';
import 'package:unitrend/models/like.dart';
import 'insta_friend_profile_screen.dart';

class PostDetailScreen extends StatefulWidget {
  final DocumentSnapshot documentSnapshot;
  final User user, currentuser;
  final DocumentReference documentReference;
  PostDetailScreen(
      {this.documentReference,
      this.user,
      this.currentuser,
      this.documentSnapshot});

  @override
  _PostDetailScreenState createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  var _repository = Repository();
  bool _isLiked = false;
  TextEditingController _commentController = TextEditingController();
  var _formKey = GlobalKey<FormState>();
  User _user;

  @override
  void initState() {
    super.initState();
    retrieveUserDetails();
  }

  retrieveUserDetails() async {
    FirebaseUser currentUser = await _repository.getCurrentUser();
    User user = await _repository.retrieveUserDetails(currentUser);
    setState(() {
      _user = user;
    });
    _repository
        .checkIfUserLikedOrNot(_user.uid, widget.documentSnapshot.reference)
        .then((isLiked) {
      if (!isLiked) {
        setState(() {
          _isLiked = false;
        });
      } else {
        setState(() {
          _isLiked = true;
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _commentController?.dispose();
  }

  _checkIfUser() {
    if (_user.displayName != widget.documentSnapshot.data['postOwnerName'])
      Navigator.pushReplacement(
          context,
          PageTransition(
              type: PageTransitionType.scale,
              alignment: Alignment.bottomCenter,
              child: InstaFriendProfileScreen(
                name: widget.documentSnapshot.data['postOwnerName'],
              )));
    if (_user.displayName == widget.documentSnapshot.data['postOwnerName'])
      Navigator.pushReplacement(
          context,
          PageTransition(
              type: PageTransitionType.scale,
              alignment: Alignment.bottomCenter,
              child: InstaProfileScreen(
                name: widget.documentSnapshot.data['postOwnerName'],
              )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEDF0F6),
      body: SwipeDetector(
        onSwipeRight: () {
          Navigator.pop(
              context, PageTransition(type: PageTransitionType.leftToRight));
        },
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(top: 40.0),
                width: double.infinity,
                height: 600.0,
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              IconButton(
                                icon: Icon(Icons.arrow_back),
                                iconSize: 30.0,
                                color: Colors.black,
                                onPressed: () => Navigator.pop(
                                    context,
                                    PageTransition(
                                        type: PageTransitionType.leftToRight)),
                              ),
                              GestureDetector(
                                onTap: () => _checkIfUser(),
                                child: Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.8,
                                  child: ListTile(
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
                                            image: CachedNetworkImageProvider(
                                                widget.documentSnapshot
                                                    .data['imgUrl']),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      widget.documentSnapshot
                                          .data['postOwnerName'],
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          InkWell(
                            onDoubleTap: () {
                              if (!_isLiked) {
                                setState(() {
                                  _isLiked = true;
                                });
                                postLike(
                                    widget.documentSnapshot.reference, _user);
                              } else {
                                setState(() {
                                  _isLiked = false;
                                });
                                postUnlike(
                                    widget.documentSnapshot.reference, _user);
                              }
                            },
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
                                  image: CachedNetworkImageProvider(
                                      widget.documentSnapshot.data['imgUrl']),
                                  fit: BoxFit.fitWidth,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        GestureDetector(
                                            child: _isLiked
                                                ? Icon(
                                                    Icons.favorite,
                                                    size: 30.0,
                                                    color: Colors.red,
                                                  )
                                                : Icon(
                                                    Icons.favorite_border,
                                                    size: 30.0,
                                                    color: null,
                                                  ),
                                            onTap: () {
                                              if (!_isLiked) {
                                                setState(() {
                                                  _isLiked = true;
                                                });
                                                postLike(
                                                    widget.documentSnapshot
                                                        .reference,
                                                    _user);
                                              } else {
                                                setState(() {
                                                  _isLiked = false;
                                                });
                                                postUnlike(
                                                    widget.documentSnapshot
                                                        .reference,
                                                    _user);
                                              }
                                            }),
                                        SizedBox(width: 5.0),
                                        likesWidget(widget.documentSnapshot
                                                    .reference) ==
                                                null
                                            ? Container()
                                            : likesWidget(widget
                                                .documentSnapshot.reference),
                                      ],
                                    ),
                                    SizedBox(width: 20.0),
                                    Row(
                                      children: <Widget>[
                                        IconButton(
                                          icon: Icon(Icons.chat),
                                          iconSize: 30.0,
                                          onPressed: () {
                                            print('Chat');
                                          },
                                        ),
                                        commentWidget(widget.documentSnapshot
                                                    .reference) ==
                                                null
                                            ? Container()
                                            : commentWidget(widget
                                                .documentSnapshot.reference)
                                      ],
                                    ),
                                  ],
                                ),
                                IconButton(
                                  icon: Icon(Icons.bookmark_border),
                                  iconSize: 30.0,
                                  onPressed: () => print('Save post'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10.0),
              Container(
                width: double.infinity,
                height: 600.0,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    topRight: Radius.circular(30.0),
                  ),
                ),
                child: Column(
                  children: <Widget>[commentsListWidget()],
                ),
              )
            ],
          ),
        ),
      ),
      bottomNavigationBar: Transform.translate(
        offset: Offset(0.0, -1 * MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          height: 100.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30.0),
              topRight: Radius.circular(30.0),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                offset: Offset(0, -2),
                blurRadius: 6.0,
              ),
            ],
            color: Colors.white,
          ),
          child: Padding(
            padding: EdgeInsets.all(12.0),
            child: Form(
              key: _formKey,
              child: TextFormField(
                validator: (String input) {
                  if (input.isEmpty) {
                    return "Please enter comment";
                  }
                },
                controller: _commentController,
                onFieldSubmitted: (value) {
                  _commentController.text = value;
                },
                decoration: InputDecoration(
                  border: InputBorder.none,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  contentPadding: EdgeInsets.all(20.0),
                  hintText: 'Add a comment',
                  prefixIcon: Container(
                    margin: EdgeInsets.all(4.0),
                    width: 48.0,
                    height: 48.0,
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
                          height: 48.0,
                          width: 48.0,
                          image: CachedNetworkImageProvider(
                              widget.documentSnapshot.data['imgUrl']),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  suffixIcon: Container(
                    margin: EdgeInsets.only(right: 4.0),
                    width: 70.0,
                    child: FlatButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      color: primaryColor,
                      onPressed: () {
                        if (_formKey.currentState.validate()) {
                          postComment();
                        }
                      },
                      child: GestureDetector(
                        child: Icon(
                          Icons.send,
                          size: 25.0,
                          color: Colors.white,
                        ),
                        onTap: () {
                          if (_formKey.currentState.validate()) {
                            postComment();
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget likesWidget(DocumentReference reference) {
    return FutureBuilder(
      future: _repository.fetchPostLikes(reference),
      builder: ((context, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
        if (snapshot.hasData) {
          return GestureDetector(
            child: Text(
              '${snapshot.data.length}',
              style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w600),
            ),
          );
        } else {
          return Container();
        }
      }),
    );
  }

  Widget commentWidget(DocumentReference reference) {
    return FutureBuilder(
      future: _repository.fetchPostComments(reference),
      builder: ((context, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
        if (snapshot.hasData) {
          return GestureDetector(
            child: Text(
              '${snapshot.data.length}',
              style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w600),
            ),
          );
        } else {
          return Container();
        }
      }),
    );
  }

  void postLike(DocumentReference reference, User _user) {
    var _like = Like(
        ownerName: _user.displayName,
        ownerPhotoUrl: _user.photoUrl,
        ownerUid: _user.uid,
        timeStamp: FieldValue.serverTimestamp());
    reference
        .collection('likes')
        .document(_user.uid)
        .setData(_like.toMap(_like))
        .then((value) {
      print("Post Liked");
    });
  }

  void postUnlike(DocumentReference reference, User _user) {
    reference.collection("likes").document(_user.uid).delete().then((value) {
      print("Post Unliked");
    });
  }

  postComment() {
    var _comment = Comment(
        comment: _commentController.text,
        timeStamp: FieldValue.serverTimestamp(),
        ownerName: _user.displayName,
        ownerUid: _user.uid);
    widget.documentReference
        .collection("comments")
        .document()
        .setData(_comment.toMap(_comment))
        .whenComplete(() {
      _commentController.text = "";
    });
  }

  Widget commentsListWidget() {
    return Flexible(
      child: StreamBuilder(
        stream: widget.documentReference
            .collection("comments")
            .orderBy('timestamp', descending: false)
            .snapshots(),
        builder: ((context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          } else {
            return ListView.builder(
              itemCount: snapshot.data.documents.length,
              itemBuilder: ((context, index) =>
                  commentItem(snapshot.data.documents[index])),
            );
          }
        }),
      ),
    );
  }

  Widget commentItem(DocumentSnapshot snapshot) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: ListTile(
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
                image: CachedNetworkImageProvider(
                    widget.documentSnapshot.data['imgUrl']),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        title: Text(
          snapshot.data['ownerName'],
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(snapshot.data['comment']),
        trailing: IconButton(
          icon: Icon(
            Icons.favorite_border,
          ),
          color: Colors.grey,
          onPressed: () => print('Like comment'),
        ),
      ),
    );
  }
}
