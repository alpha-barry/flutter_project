import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modue_flutter_ex2/UserInf.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'NightMode.dart';

class SignInPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SignInPageState();
  }

}

class SignInPageState extends State<SignInPage> {
  static SharedPreferences prefs;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String email;
  String password;
  bool isButtonPressed = false;
  String error = '';

  Future<String> signIn(String email, String password) async {
    final AuthResult result = await _auth.signInWithEmailAndPassword(
        email: email, password: password);
    final FirebaseUser user = result.user;
    return user.uid;
  }

  Future<void> getSaveUser() async {
    prefs = await SharedPreferences.getInstance();
    email = prefs.getString('email');
    password = prefs.getString('pwd');
    if (email != null && password != null) {
      connect();
    }
  }

  @override
  void initState() {
    super.initState();
    getSaveUser();
  }

  void connect(){
    final Future<String> uid = signIn(email, password);
    uid.then((String onValue) {
      isButtonPressed = false;
      prefs.setString('email', email);
      prefs.setString('pwd', password);
      UserInf.uid = onValue;
      Navigator.pushNamed(context, '/profil');
    }).catchError((dynamic onError) {
      isButtonPressed = false;
      if (mounted) {
        setState(() {
          error = 'erreur mail/mdp';
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Provider.of<NightMode>(context, listen: true).color,
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: const Center(child: Text('Connexion')),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
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
                child: TextField(
                  onChanged: (String text) => password = text,
                  obscureText: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Password',
                  ),
                ),
              ),

              Text(
                  error,
                  style: const TextStyle(fontSize: 20)
              ),

              Padding(
                padding: const EdgeInsets.all(26.0),
                child: RaisedButton(
                  onPressed: () {
                    if (!isButtonPressed) {
                      isButtonPressed = true;
                      connect();
                    }
                  },
                  child: const Text(
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
