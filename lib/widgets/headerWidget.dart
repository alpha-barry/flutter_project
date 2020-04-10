import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modue_flutter_ex2/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget headerWidget(BuildContext context){
  return Drawer(

    child: ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        DrawerHeader(
          child: Center(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    'MENU',
                    style: TextStyle(
                      fontSize: 20.0,
                      color: Colors.white,
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    'Menu',
                    style: TextStyle(
                      fontSize: 20.0,
                      color: Colors.white,
                    ),
                  ),
                ),
                Icon(Icons.account_circle),
              ],
            ),
          ),
          decoration: BoxDecoration(
            color: Colors.blue,
          ),
        ),
        ListTile(
          trailing: Icon(Icons.search, color: Colors.blue,),
          title: Text('Mon profil', style: TextStyle(color: Colors.blue),),
          onTap: () {
            Navigator.pushNamed(context, '/profil');
          },
        ),
        ListTile(
          trailing: Icon(Icons.search, color: Colors.blue,),
          title: Text('Rechercher', style: TextStyle(color: Colors.blue),),
          onTap: () {
            Navigator.pushNamed(context, '/search');
          },
        ),
        ListTile(
          trailing: Icon(Icons.contacts, color: Colors.blue,),
          title: Text('Contacts', style: TextStyle(color: Colors.blue),),
          onTap: () {
            Navigator.pushNamed(context, '/contacts');
          },
        ),
        ListTile(
          trailing: Icon(Icons.send, color: Colors.blue),
          title: Text('Invitations', style: TextStyle(color: Colors.blue),),
          onTap: () {
            Navigator.pushNamed(context, '/invits');
          },
        ),
        ListTile(
          trailing: Icon(Icons.message, color: Colors.blue,),
          title: Text('Mes messages', style: TextStyle(color: Colors.blue),),
          onTap: () {
            Navigator.pushNamed(context, '/conversations');
          },
        ),
        ListTile(
          trailing: Icon(Icons.power_settings_new, color: Colors.blue,),
          title: Text('Déconnexion', style: TextStyle(color: Colors.blue),),
          onTap: () {
            FirebaseAuth.instance.signOut();
            SharedPreferences.getInstance().then((SharedPreferences onValue){
              onValue.clear();
            });
            Navigator.pushAndRemoveUntil<void>(
              context,
              MaterialPageRoute<void>(builder: (BuildContext context) => MyApp()),
                  (Route<dynamic> route) => false,
            );
            },
        ),
      ],
    ),
  );
}
