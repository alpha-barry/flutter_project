import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modue_flutter_ex2/SearchMemberPage.dart';

import '../ContactsPage.dart';

Widget HeaderWidget(BuildContext context){
  return Drawer(
    // Add a ListView to the drawer. This ensures the user can scroll
    // through the options in the drawer if there isn't enough vertical
    // space to fit everything.
    child: ListView(
      // Important: Remove any padding from the ListView.
      padding: EdgeInsets.zero,
      children: <Widget>[
        DrawerHeader(
          child: Center(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text(
                    "MENU",
                    style: new TextStyle(
                      fontSize: 20.0,
                      color: Colors.white,
                    ),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text(
                    "Mon Profil",
                    style: new TextStyle(
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
          title: Text('Rechercher', style: TextStyle(color: Colors.blue),),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(
                builder: (context) => SearchMemberPage()));
            // Update the state of the app.
            // ...
          },
        ),
        ListTile(
          trailing: Icon(Icons.contacts, color: Colors.blue,),
          title: Text('Contacts', style: TextStyle(color: Colors.blue),),
          onTap: () {
            // Update the state of the app.
            // ...
            Navigator.push(context, MaterialPageRoute(
                builder: (context) => ContactsPage()));
          },
        ),
        ListTile(
          trailing: Icon(Icons.send, color: Colors.blue),
          title: Text('Invitations', style: TextStyle(color: Colors.blue),),
          onTap: () {
            // Update the state of the app.
            // ...
          },
        ),
        ListTile(
          trailing: Icon(Icons.message, color: Colors.blue,),
          title: Text('Mes messages', style: TextStyle(color: Colors.blue),),
          onTap: () {
            // Update the state of the app.
            // ...
          },
        ),
        ListTile(
          trailing: Icon(Icons.power_settings_new, color: Colors.blue,),
          title: Text('Déconnexion', style: TextStyle(color: Colors.blue),),
          onTap: () {
            // Update the state of the app.
            // ...
          },
        ),
      ],
    ),
  );
}