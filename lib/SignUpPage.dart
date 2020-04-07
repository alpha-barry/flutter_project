import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modue_flutter_ex2/UserInf.dart';
import 'package:provider/provider.dart';

import 'NightMode.dart';

class SignUpPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // ignore: flutter_style_todos
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

  String error = '';

  Future<String> signUp(String email, String password) async {
    final AuthResult result = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    final FirebaseUser user = result.user;
    UserInf.uid = user.uid;
    return user.uid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Provider.of<NightMode>(context, listen: true).color,
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: const Center(child: Text('Inscription')),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[

              Padding(
                padding: const EdgeInsets.all(26.0),
                child: TextField(
                  onChanged: (String text) => firstName = text,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'prenom',
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(26.0),
                child: TextField(
                  onChanged: (String text) => lastName = text,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'nom',
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(26.0),
                child: TextField(
                  onChanged: (String text) => email = text,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'email',
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(26.0),
                child:  TextField(
                  onChanged: (String text) => password = text,
                  obscureText: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Mdp',
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(26.0),
                child:  TextField(
                  onChanged: (String text) => confirmPassword = text,
                  obscureText: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Entrer le mdp à nouveau',
                  ),
                ),
              ),

              Text(
                  error,
                  style: const TextStyle(fontSize: 20)
              ),
              Padding(
                padding: const EdgeInsets.all(26.0),
                child:  RaisedButton(
                  onPressed: () {
                    if (!isButtonPressed) {
                      isButtonPressed = true;
                      if (firstName != null && lastName != null && firstName.trim().isNotEmpty && lastName.trim().isNotEmpty) {
                        if (password == confirmPassword) {
                          if (password != null && password.length < 6) {
                            isButtonPressed = false;
                            if (mounted) {
                              setState(() {
                                error = 'Le mdp doit avoir au plus de 5 caractères';
                              });
                            }
                          }
                          else {
                            final Future<String> uid = signUp(email, password);
                            uid.then((String onValue) {
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
                              Navigator.pushNamed(context, '/profil');
                            }).catchError((onError) {
                              isButtonPressed = false;
                              if (mounted) {
                                setState(() {
                                  error = 'erreur mail/mpd';
                                });
                              }
                            });
                          }
                        }
                        else {
                          isButtonPressed = false;
                          setState(() {
                            error = 'Les mdp ne sont pas pareils';
                          });
                        }
                      }
                      else {
                        isButtonPressed = false;
                        setState(() {
                          error = 'Mettez votre prénom et nom';
                        });
                      }
                    }
                  },
                  child: const Text(
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
