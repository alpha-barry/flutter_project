import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modue_flutter_ex2/ProfilePage.dart';
import 'package:modue_flutter_ex2/UserInf.dart';
// ignore: must_be_immutable

class SignUpPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return SignUpPageState();
  }

}
class SignUpPageState extends State<SignUpPage> {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  String firstName;
  String lastName;
  String email;
  String password;
  String confirmPassword;
  bool isButtonPressed = false;

  String error = "";

  Future<String> signUp(String email, String password) async {
    AuthResult result = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    FirebaseUser user = result.user;
    UserInf.uid = user.uid;
    return user.uid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text("Inscription"),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[

              Padding(
                padding: EdgeInsets.all(26.0),
                child: TextField(
                  onChanged: (String text) => firstName = text,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'prenom',
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.all(26.0),
                child: TextField(
                  onChanged: (String text) => lastName = text,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'nom',
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.all(26.0),
                child: TextField(
                  onChanged: (String text) => email = text,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'email',
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.all(26.0),
                child:  TextField(
                  onChanged: (String text) => password = text,
                  obscureText: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Mdp',
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.all(26.0),
                child:  TextField(
                  onChanged: (String text) => confirmPassword = text,
                  obscureText: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Entrer le mdp à nouveau',
                  ),
                ),
              ),

              Text(
                  error,
                  style: TextStyle(fontSize: 20)
              ),
              Padding(
                padding: EdgeInsets.all(26.0),
                child:  RaisedButton(
                  onPressed: () {
                    if (!isButtonPressed) {
                      isButtonPressed = true;
                      if (firstName != null && lastName != null && firstName.trim().length > 0 && lastName.trim().length > 0) {
                        if (password == confirmPassword) {
                          if (password != null && password.length < 6) {
                            isButtonPressed = false;
                            setState(() {
                              error = "Le mdp doit avoir au plus de 5 caractères";
                            });
                          }
                          else {
                            Future<String> uid = signUp(email, password);
                            uid.then((onValue) {
                              Firestore.instance.collection('profiles').document(
                                  onValue)
                                  .setData({
                                'firstName': firstName.trim(),
                                'lastName': lastName.trim(),
                                'uid': UserInf.uid
                              });

                             // final StorageReference storageReference = FirebaseStorage().ref().child("profiles/" + UserInf.uid + "/photo_de_profile");
                              //storageReference.putFile(image);

                              isButtonPressed = false;
                              Navigator.push(context, MaterialPageRoute(
                                  builder: (context) => ProfilePage()));
                            }).catchError((onError) {
                              isButtonPressed = false;
                              setState(() {
                                error = "erreur mail/mpd";
                              });
                            });
                          }
                        }
                        else {
                          isButtonPressed = false;
                          setState(() {
                            error = "Les mdp ne sont pas pareils";
                          });
                        }
                      }
                      else {
                        isButtonPressed = false;
                        setState(() {
                          error = "Mettez votre prénom et nom";
                        });
                      }
                    }
                  },
                  child: Text(
                      "S'inscrire",
                      style: TextStyle(fontSize: 20)
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
