import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:modue_flutter_ex2/ContactsPage.dart';
import 'package:modue_flutter_ex2/ConversationsListPage.dart';
import 'package:modue_flutter_ex2/MessengerPage.dart';
import 'package:modue_flutter_ex2/NightMode.dart';
import 'package:modue_flutter_ex2/ProfilePage.dart';
import 'package:modue_flutter_ex2/RecContactsPage.dart';
import 'package:modue_flutter_ex2/SearchMemberPage.dart';
import 'package:provider/provider.dart';
import 'SignInPage.dart';
import 'SignUpPage.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    SystemChrome.setPreferredOrientations(<DeviceOrientation>[
      DeviceOrientation.portraitUp,
    ]);

    return ChangeNotifierProvider<NightMode>(
      create: (BuildContext context) => NightMode(),
      child: MaterialApp(
        initialRoute: '/',
        // ignore: always_specify_types
        routes: {
          '/signup': (BuildContext context) => SignUpPage(),
          '/signin': (BuildContext context) => SignInPage(),
          '/profil': (BuildContext context) => ProfilePage(),
          '/search': (BuildContext context) => SearchMemberPage(),
          '/invits': (BuildContext context) => RecContactsPage(),
          '/contacts': (BuildContext context) => ContactsPage(),
          '/conversations': (BuildContext context) => ConversationsListPage(),
          '/messenger': (BuildContext context) => MessengerPage(),
        },
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const MyHomePage(title: 'Flutter Demo Home Page'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(

        title: Center(child: Text(widget.title)),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(26.0),
                child: RaisedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/signin');
                  },
                  child: const Text(
                      'Connexion',
                      style: TextStyle(fontSize: 20)
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(26.0),
                child: RaisedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/signup');
                  },
                  child: const Text(
                      'Inscription',
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

class SecondRoute extends StatelessWidget {
  @override

  const SecondRoute({Key key, this.email, this.password}) : super(key: key);

  final String email;
  final String password;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Second Route'),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Text('Bonjour ' + email),
            RaisedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Go back!'),
            ),
          ],
        ),
      ),
    );
  }
}
