import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modue_flutter_ex2/UserInf.dart';
import 'package:modue_flutter_ex2/widgets/headerWidget.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProfilePage extends StatefulWidget {
  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage>{

  String imgUrl;
  File _image;

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);

    final StorageReference storageReference = FirebaseStorage().ref().child("profiles/" + UserInf.uid + "/photo_de_profile");
    storageReference.putFile(image).onComplete.then((onValue) {
      onValue.ref.getDownloadURL().then((onValue){
        setState(() {
          imgUrl = onValue;
        });
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();


    imgUrl = "https://firebasestorage.googleapis.com/v0/b/flutterproject-1bb5a.appspot.com/o/photo_profile_fb.jpg?alt=media&token=538ede67-3318-4470-9a7e-192660080f34";

    Firestore.instance.document('profiles/' + UserInf.uid).snapshots().listen((onData){
      UserInf.fullName = onData.data['firstName'] + " " + onData.data["lastName"];
    });

    final StorageReference storageReference = FirebaseStorage.instance
        .ref().child("profiles/" + UserInf.uid + "/photo_de_profile");
    storageReference.getDownloadURL().then((onValue) {
      setState(() {
        if (onValue != null)
          imgUrl = onValue;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(

        title: Text('Mon profil'),
      ),
      endDrawer: headerWidget(context),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Center(
              child: Column(
                children: <Widget>[
                  Card(
                    child: Container(
                      width: 150,
                      height: 150,
                      child: Container(
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                image: imgUrl == null
                                    ? Image.file(_image).image
                                    : NetworkImage(imgUrl),
                                fit: BoxFit.cover),
                            borderRadius: BorderRadius.all(Radius.circular(45.0)),
                        ),
                      ),
                    ),
                  ),
                  FloatingActionButton(onPressed: getImage, child: Icon(Icons.photo_camera),),

                  Text(UserInf.fullName ?? '', style: new TextStyle(
                    fontSize: 20.0,
                    color: Colors.blue,
                  ),),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
