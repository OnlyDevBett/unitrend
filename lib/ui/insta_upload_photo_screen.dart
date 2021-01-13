import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:unitrend/resources/repository.dart';
import 'package:unitrend/ui/insta_home_screen.dart';
import 'package:location/location.dart';
import 'package:flutter/services.dart';
import 'package:geocoder/geocoder.dart';
import 'package:image/image.dart' as Im;
import 'package:path_provider/path_provider.dart';
import 'dart:math';
import 'package:unitrend/utils/colors.dart';

class InstaUploadPhotoScreen extends StatefulWidget {
  File imageFile;

  String text;
  InstaUploadPhotoScreen({this.imageFile, this.text});

  @override
  _InstaUploadPhotoScreenState createState() => _InstaUploadPhotoScreenState();
}

class _InstaUploadPhotoScreenState extends State<InstaUploadPhotoScreen> {
  var _locationController;
  var _captionController;
  final _repository = Repository();
  int currentIndex;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _locationController = TextEditingController();
    _captionController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _locationController?.dispose();
    _captionController?.dispose();
  }

  


  bool _visibility = true;

  void _changeVisibility(bool visibility) {
    setState(() {
      _visibility = visibility;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          FloatingActionButton.extended(
            elevation: 1.0,
              heroTag: 'Delete',
            onPressed: () => Navigator.of(context).pop(),
            label: Text('Delete'),
            icon: Icon(Icons.delete),
            backgroundColor: Colors.redAccent,
          ),
          FloatingActionButton.extended(
              elevation: 1.0,
              heroTag: 'Approve',
              label: Text('Approve'),
              icon: Icon(Icons.thumb_up),
              backgroundColor: primaryColor,
              onPressed: () {
                _changeVisibility(false);

                _repository.getCurrentUser().then((currentUser) {
                  if (currentUser != null) {
                    compressImage();
                    _repository.retrieveUserDetails(currentUser).then((user) {
                      _repository
                        .uploadImageToStorage(widget.imageFile)
                        .then((url) {
                      _repository
                          .addPostToDb(user, url, '${widget.text}')
                          .then((value) {
                        print("Post added to db");
                        Navigator.pushReplacement(context, MaterialPageRoute(
                          builder: ((context) => InstaHomeScreen())
                        ));
                      }).catchError((e) =>
                              print("Error adding current post to db : $e"));
                    }).catchError((e) {
                      print("Error uploading image to storage : $e");
                    });
                    });
                    
                  } else {
                    print("Current User is null");
                  }
                });
              },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          fit: BoxFit.cover,
                          image: FileImage(widget.imageFile))),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void compressImage() async {
    print('starting compression');
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    int rand = Random().nextInt(10000);

    Im.Image image = Im.decodeImage(widget.imageFile.readAsBytesSync());

    var newim2 = new File('$path/img_$rand.jpg')
      ..writeAsBytesSync(Im.encodeJpg(image, quality: 85));

    setState(() {
      widget.imageFile = newim2;
    });
    print('done');
  }

  Future<List<Address>> locateUser() async {
    LocationData currentLocation;
    Future<List<Address>> addresses;

    var location = new Location();

    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      currentLocation = await location.getLocation();

      print(
          'LATITUDE : ${currentLocation.latitude} && LONGITUDE : ${currentLocation.longitude}');

      // From coordinates
      final coordinates =
          new Coordinates(currentLocation.latitude, currentLocation.longitude);

      addresses = Geocoder.local.findAddressesFromCoordinates(coordinates);
    } on PlatformException catch (e) {
      print('ERROR : $e');
      if (e.code == 'PERMISSION_DENIED') {
        print('Permission denied');
      }
      currentLocation = null;
    }
    return addresses;
  }
}
