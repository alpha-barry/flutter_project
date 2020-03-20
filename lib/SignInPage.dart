import 'package:flutter/material.dart';
import 'package:modue_flutter_ex2/ProfilePage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modue_flutter_ex2/UserInf.dart';

// ignore: must_be_immutable

class SignInPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return SignInPageState();
  }

}

class SignInPageState extends State<SignInPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String email;
  String password;
  bool isButtonPressed = false;
  String error = "";

  Future<String> signIn(String email, String password) async {
    AuthResult result = await _auth.signInWithEmailAndPassword(
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
        title: Text("Connexion"),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
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
                child: TextField(
                  onChanged: (String text) => password = text,
                  obscureText: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Password',
                  ),
                ),
              ),

              Text(
                  error,
                  style: TextStyle(fontSize: 20)
              ),

              Padding(
                padding: EdgeInsets.all(26.0),
                child: RaisedButton(
                  onPressed: () {
                    if (!isButtonPressed) {
                      isButtonPressed = true;
                      Future<String> uid = signIn(email, password);
                      uid.then((onValue) {
                        isButtonPressed = false;
                        Navigator.push(context, MaterialPageRoute(
                            builder: (context) => ProfilePage()));
                      }).catchError((onError) {
                        isButtonPressed = false;
                        setState(() {
                          error = "erreur mail/mdp";
                        });
                      });
                    }
                  },
                  child: Text(
                      'Se connecter',
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
