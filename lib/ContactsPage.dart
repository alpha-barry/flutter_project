import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:modue_flutter_ex2/UserInf.dart';
import 'package:modue_flutter_ex2/widgets/HeaderWidget.dart';

class ContactsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(

        title: Text('Mes Contacts'),
      ),
      endDrawer: HeaderWidget(context),
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
    /*Firestore.instance.collection("profils").document(UserInf.uid).snapshots().map((convert){
      List list = convert.data[];
    });*/
    Firestore.instance.collection("profils").document(UserInf.uid).updateData({"contacts": FieldValue.arrayRemove([contact["uid"]])});
    Firestore.instance.collection("profils").document(contact["uid"]).updateData({"contacts": FieldValue.arrayRemove([UserInf.uid])});
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
                             /* viewModel.changeView(
                                  route: _routing.chatScreenPage, widgetContext: context);*/
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
        stream: Firestore.instance.collection("profils").where("contacts", arrayContains: UserInf.uid).snapshots(),
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