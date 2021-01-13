import 'dart:io';
import 'package:flutter/material.dart';
import 'package:unitrend/ui/login_screen.dart';
import 'package:unitrend/utils/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:unitrend/resources/repository.dart';
import 'package:unitrend/ui/insta_home_screen.dart';
import 'package:unitrend/models/user.dart';
import 'package:image_picker/image_picker.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  User user;
  final Firestore _firestore = Firestore.instance;

  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  String displayName = "";
  String photoUrl = "https://www.google.com/url?sa=i&url=https%3A%2F%2Fwww.sackettwaconia.com%2Fdefault-profile%2F&psig=AOvVaw0j60JtkJf43JiLWcYHRHiW&ust=1586733128442000&source=images&cd=vfe&ved=0CAIQjRxqFwoTCLi6j-K_4egCFQAAAAAdAAAAABAD";
  bool loaded = false;
  File _image;
  
  Future getImage() async {
      // ignore: deprecated_member_use
      var photoUrl = await ImagePicker.pickImage(source: ImageSource.gallery);

      setState(() {
        _image = photoUrl;
        loaded = true;
          print('Image Path $_image');
      });
    }


  @override
  Widget build(BuildContext context) {
    final appBar = Padding(
      padding: EdgeInsets.only(bottom: 40.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          IconButton(
            onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
          return LoginScreen();
        })),
            icon: Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
          )
        ],
      ),
    );

    final pageTitle = Container(
      child: Text(
        "Tell us about you.",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black,
          fontSize: 40.0,
        ),
      ),
    );

    final photoUrlField = Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: 20.0,
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 30.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Align(
                      alignment: Alignment.center,
                      child: CircleAvatar(
                        radius: 70,
                        backgroundColor: Color(0xff476cfb),
                        child: ClipOval(
                          child: new SizedBox(
                            width: 180.0,
                            height: 180.0,
                            child: loaded ? Image.file(
                            _image,
                            fit: BoxFit.fill,
                          ) : Image.network(
                            "data:image/jpeg;base64,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",
                            fit: BoxFit.fill,
                          ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 60.0),
                      child: IconButton(
                        icon: Icon(
                          Icons.edit,
                          size: 30.0,
                        ),
                        onPressed: () {
                          getImage();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ]
          );

    final displayNameField = TextFormField(
      validator: 
        (input) {
            if(input.isEmpty) {
              return 'Please enter a Username';
          }
            return null;
        },
        onChanged: (val) {
                  setState(() => displayName = val);
                },
      onSaved: ((input) => displayName = input),
      decoration: InputDecoration(
        labelText: 'Username',
        labelStyle: TextStyle(color: Colors.black),
        prefixIcon: Icon(
          Icons.person,
          color: Colors.black,
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.black),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.black),
        ),
      ),
      keyboardType: TextInputType.emailAddress,
      style: TextStyle(color: Colors.black),
      cursorColor: Colors.black,
    );


    final emailField = TextFormField(
      validator: 
        (input) {
            if(input.isEmpty) {
              return 'Please enter an email';
          }
            return null;
        },
        onChanged: (val) {
          setState(() => email = val);
        },
        onSaved: (input) => email = input,
        decoration: InputDecoration(
          labelText: 'Email Address',
          labelStyle: TextStyle(color: Colors.black),
          prefixIcon: Icon(
            Icons.mail,
            color: Colors.black,
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
          ),
        ),
      keyboardType: TextInputType.emailAddress,
      style: TextStyle(color: Colors.black),
      cursorColor: Colors.black,
    );

    final passwordField = TextFormField(
      validator: (input) {
                if(input.length < 6) {
                  return 'Your passwords needs to be atleast 6 characters';
                }
                return null;
              },
              onChanged: (val) {
                  setState(() => password = val);
                },
              onSaved: (input) => password = input,
      decoration: InputDecoration(
        labelText: 'Password',
        labelStyle: TextStyle(color: Colors.black),
        prefixIcon: Icon(
          Icons.lock,
          color: Colors.black,
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.black),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.black),
        ),
      ),
      keyboardType: TextInputType.text,
      style: TextStyle(color: Colors.black),
      cursorColor: Colors.black,
      obscureText: true,
    );

    final registerForm = Padding(
      padding: EdgeInsets.only(top: 30.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[photoUrlField, displayNameField, emailField, passwordField],
        ),
      ),
    );

    final submitBtn = Padding(
      padding: EdgeInsets.only(top: 20.0),
      child: Container(
        margin: EdgeInsets.only(top: 10.0, bottom: 20.0),
        height: 60.0,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(7.0),
          border: Border.all(color: Colors.black),
        ),
        child: Material(
          borderRadius: BorderRadius.circular(7.0),
          color: primaryColor,
          elevation: 10.0,
          shadowColor: Colors.white,
          child: MaterialButton(
            onPressed: () {
              if(_formKey.currentState.validate()){
              _formKey.currentState.save();

                  registerWithEmailAndPassword(email, password).then((user) {
                    if (user != null) {
                      print('user');
                    } else {
                      print("Error");
                    }
                  });
                };
              },
            child: Text(
              'CREATE ACCOUNT',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 20.0,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
    );

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(top: 40.0),
          child: Column(
            children: <Widget>[
              appBar,
              Container(
                padding: EdgeInsets.only(left: 30.0, right: 30.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    pageTitle,
                    registerForm,
                    submitBtn
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // Widget _buildFormField(String label, IconData icon) {
  //   return TextFormField(
  //     decoration: InputDecoration(
  //       labelText: label,
  //       labelStyle: TextStyle(color: Colors.black),
  //       prefixIcon: Icon(
  //         icon,
  //         color: Colors.black38,
  //       ),
  //       enabledBorder: UnderlineInputBorder(
  //         borderSide: BorderSide(color: Colors.black38),
  //       ),
  //       focusedBorder: UnderlineInputBorder(
  //         borderSide: BorderSide(color: Colors.orange),
  //       ),
  //     ),
  //     keyboardType: TextInputType.text,
  //     style: TextStyle(color: Colors.black),
  //     cursorColor: Colors.black,
  //   );
  // }

  

  Future<void> addDataToDb(FirebaseUser currentUser) async {
    print("Inside addDataToDb Method");

    _firestore
        .collection("display_names")
        .document(this.displayName)
        .setData({'displayName': this.displayName});

    user = User(
        uid: currentUser.uid,
        email: this.email,
        displayName: this.displayName,
        photoUrl: this.photoUrl,
        // photoUrl: this.photoUrl,
        followers: "0",
        following: "0",
        bio: 'Unitrend User',
        posts: '0',
        phone: '');



    return _firestore
        .collection("users")
        .document(currentUser.uid)
        .setData(user.toMap(user));
  }

  User _userFromFirebaseUser(FirebaseUser user) {
    return user != null ? User(uid: user.uid) : null;
  }

  Future registerWithEmailAndPassword(String email, String password) async {
    try {
      AuthResult result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      FirebaseUser user = result.user;
      print('User Created');
      addDataToDb(user).then((user) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
            return InstaHomeScreen();
          }));
        });
      return _userFromFirebaseUser(user);
      
    } catch (error) {
      print(error.toString());
      return null;
    } 
  }
}