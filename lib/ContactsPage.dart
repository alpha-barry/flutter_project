import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:modue_flutter_ex2/MessengerPage.dart';
import 'package:modue_flutter_ex2/UserInf.dart';
import 'package:modue_flutter_ex2/widgets/headerWidget.dart';
import 'package:provider/provider.dart';

import 'NightMode.dart';

class ContactsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Provider.of<NightMode>(context, listen: true).color,
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Center(child: Text('Mes Contacts')),
      ),
      endDrawer: headerWidget(context),
      body: ContactsPageStateful(),
    );
  }
}


class ContactsPageStateful extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ContactsPageState();
}

class ContactsPageState extends State<ContactsPageStateful> {

  void  removeContact(DocumentSnapshot contact){
    /*Firestore.instance.collection("profiles").document(UserInf.uid).snapshots().map((convert){
      List list = convert.data[];
    });*/
    Firestore.instance.collection("profiles").document(UserInf.uid).updateData({"contacts": FieldValue.arrayRemove([contact["uid"]])});
    Firestore.instance.collection("profiles").document(contact["uid"]).updateData({"contacts": FieldValue.arrayRemove([UserInf.uid])});

    Firestore.instance.collection("chat/" +  UserInf.uid + "/conversations").document(contact["uid"]).delete();
    Firestore.instance.collection("chat/" + contact["uid"] + "/conversations").document(UserInf.uid).delete();
  }

  Future<void> removeContactAlertDialog(DocumentSnapshot contact) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Suppression de contact'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Voulez vous supprimer ' + contact["firstName"] + " " + contact["lastName"] + " de vos contacts ?"),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Oui'),
              onPressed: () {
                removeContact(contact);
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('Non'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _contactsList(QuerySnapshot contacts){
    return new Scrollbar (
        child: ListView.builder(
            itemCount: contacts.documents.length,
            itemBuilder: (context, index){
              return Card(
                borderOnForeground: false,
                child: ListTile(
                    leading: Icon(Icons.album, size: 50),
                    title: new Text(contacts.documents.elementAt(index)["firstName"]),
                    subtitle: new Text(contacts.documents.elementAt(index)["lastName"]),
                    trailing: new Wrap(
                      children: <Widget>[
                        IconButton(
                            icon: Icon(Icons.message, color: Colors.indigo),
                            onPressed: () {
                              UserInf.contactUid = contacts.documents.elementAt(index).documentID;
                              Navigator.push(context, MaterialPageRoute(
                                  builder: (context) => MessengerPage()));
                            }),
                        IconButton(
                            icon: Icon(Icons.more_vert, color: Colors.indigo,),
                            onPressed: () => removeContactAlertDialog(contacts.documents.elementAt(index)))
                      ],
                    )

                ),
              );
            }
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return new StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance.collection("profiles").where("contacts", arrayContains: UserInf.uid).snapshots(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(child: CircularProgressIndicator(backgroundColor: Colors.deepPurple));
              break;
            case ConnectionState.active:
              return _contactsList(snapshot.data);
              break;
            case ConnectionState.done:
              return Text("DONE");
              break;
            default:
              return Text('Erreur');
          }
        }
    );
  }
}
