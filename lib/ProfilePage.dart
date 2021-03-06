import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modue_flutter_ex2/NightMode.dart';
import 'package:modue_flutter_ex2/UserInf.dart';
import 'package:modue_flutter_ex2/widgets/headerWidget.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage>{

  String imgUrl;
  File _image;

  bool isChecked = false;

  Future<void> getImage() async {
    final File image = await ImagePicker.pickImage(source: ImageSource.camera);

    final StorageReference storageReference = FirebaseStorage().ref().child('profiles/' + UserInf.uid + '/photo_de_profile');
    storageReference.putFile(image).onComplete.then((StorageTaskSnapshot onValue) {
      onValue.ref.getDownloadURL().then((dynamic onValue){
        if (mounted) {
          setState(() {
            imgUrl = onValue;
          });
        }
      });
    });
  }

  @override
  void initState() {
    super.initState();


    imgUrl = 'https://firebasestorage.googleapis.com/v0/b/flutterproject-1bb5a.appspot.com/o/photo_profile_fb.jpg?alt=media&token=538ede67-3318-4470-9a7e-192660080f34';

    Firestore.instance.document('profiles/' + UserInf.uid).snapshots().listen((DocumentSnapshot onData){
      if (mounted) {
        setState(() {
          UserInf.fullName = onData.data['firstName'] + ' ' + onData.data['lastName'];
        });
      }
    });

    final StorageReference storageReference = FirebaseStorage.instance
        .ref().child('profiles/' + UserInf.uid + '/photo_de_profile');

    storageReference.getDownloadURL().then((Object onValue) {
      if (onValue != null) {
        if (mounted) {
          setState(() {
            if (onValue != null)
              imgUrl = onValue;
          });
        }
      }
    }).catchError((Object error) {
      imgUrl = 'https://firebasestorage.googleapis.com/v0/b/flutterproject-1bb5a.appspot.com/o/photo_profile_fb.jpg?alt=media&token=538ede67-3318-4470-9a7e-192660080f34';
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Provider.of<NightMode>(context, listen: true).color,
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Center(child: Text('Mon profil')),
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
                            borderRadius: const BorderRadius.all(Radius.circular(45.0)),
                        ),
                      ),
                    ),
                  ),
                  FloatingActionButton(onPressed: getImage, child: Icon(Icons.photo_camera),),

                  Text(UserInf.fullName ?? '', style: TextStyle(
                    fontSize: 20.0,
                    color: Colors.blue,
                  ),),


                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 50, 0, 0),
                    child: Text('Mode nuit', style: TextStyle(
                      color: Colors.blue,
                    ),),
                  ),
                  Checkbox(
                    value: Provider.of<NightMode>(context, listen: true).switcher,
                    onChanged: (bool value) {
                      Provider.of<NightMode>(context, listen: false).switchMode();
                      if (mounted) {
                        setState(() {
                          isChecked = value;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
