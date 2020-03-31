import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:modue_flutter_ex2/ContactsPage.dart';
import 'package:modue_flutter_ex2/ConvListPage.dart';
import 'package:modue_flutter_ex2/NightMode.dart';
import 'package:modue_flutter_ex2/ProfilePage.dart';
import 'package:modue_flutter_ex2/RecContactsPage.dart';
import 'package:modue_flutter_ex2/SearchMemberPage.dart';
import 'package:provider/provider.dart';
import 'SignInPage.dart';
import 'SignUpPage.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    return ChangeNotifierProvider<NightMode>(
      create: (context) => NightMode(),
      child: MaterialApp(
        initialRoute: '/',
        routes: {
         // '/': (context) => MyHomePage(),
          '/signup': (context) => SignUpPage(),
          '/signin': (context) => SignInPage(),
          '/profil': (context) => ProfilePage(),
          '/search': (context) => SearchMemberPage(),
          '/invits': (context) => RecContactsPage(),
          '/contacts': (context) => ContactsPage(),
          '/conversations': (context) => ConvListPage(),
        },
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: MyHomePage(title: 'Flutter Demo Home Page'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

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
                padding: EdgeInsets.all(26.0),
                child: RaisedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => SignInPage()));
                  },
                  child: Text(
                      'Connexion',
                      style: TextStyle(fontSize: 20)
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.all(26.0),
                child: RaisedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpPage()));
                  },
                  child: Text(
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

  SecondRoute({Key key, this.email, this.password}) : super(key: key);

  final String email;
  final String password;

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Second Route"),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Text("Bonjour " + this.email),
            RaisedButton(
              onPressed: () {
                Navigator.pop(context);
                // Navigate back to first route when tapped.
              },
              child: Text('Go back!'),
            ),
            /*Scrollbar(
                child: Column(

                ),
            ),*/
          ],
        ),
      ),
    );
  }
}
