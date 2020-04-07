import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:modue_flutter_ex2/widgets/headerWidget.dart';
import 'package:provider/provider.dart';

import 'NightMode.dart';
import 'UserInf.dart';

class RecContactsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Provider.of<NightMode>(context, listen: true).color,
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Center(child: Text('Invitations')),
      ),
      endDrawer: headerWidget(context),
      body: RecContactsPageStateful(),
    );
  }
}


class RecContactsPageStateful extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => RecContactsPageState();
}

class RecContactsPageState extends State<RecContactsPageStateful> {
  void  acceptContact(DocumentSnapshot contact){
    // ignore: always_specify_types
    Firestore.instance.collection('profiles').document(UserInf.uid).updateData({'rec_contacts': FieldValue.arrayRemove([contact['uid']])}).then((onValue){
      Firestore.instance.collection('profiles').document(UserInf.uid).updateData({'contacts': FieldValue.arrayUnion([contact['uid']])});
    });
    // ignore: always_specify_types
    Firestore.instance.collection('profiles').document(contact['uid']).updateData({'send_contacts': FieldValue.arrayRemove([UserInf.uid])}).then((onValue){
      Firestore.instance.collection('profiles').document(contact['uid']).updateData({'contacts': FieldValue.arrayUnion([UserInf.uid])});
    });
  }

  void  removeContact(DocumentSnapshot contact){
    Firestore.instance.collection('profiles').document(UserInf.uid).updateData({'rec_contacts': FieldValue.arrayRemove([contact["uid"]])});
    Firestore.instance.collection('profiles').document(contact['uid']).updateData({'send_contacts': FieldValue.arrayRemove([UserInf.uid])});
  }

  Future<void> removeContactAlertDialog(DocumentSnapshot contact) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ajout de contact'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Voulez vous ajouter ' + contact['firstName'] + ' ' + contact['lastName'] + ' à vos contacts ?'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: const Text('Accepter'),
              onPressed: () {
                acceptContact(contact);
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: const Text('Refuser'),
              onPressed: () {
                removeContact(contact);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _contactsList(QuerySnapshot contacts) {
    return Scrollbar (
        child: ListView.builder(
            itemCount: contacts.documents.length,
            itemBuilder: (BuildContext context, int index){
              return Card(
                borderOnForeground: false,
                child: ListTile(
                  leading: Icon(Icons.album, size: 50),
                  title:  Text(contacts.documents.elementAt(index)['firstName']),
                  subtitle: Text(contacts.documents.elementAt(index)['lastName']),
                  trailing: IconButton(
                      icon: Icon(Icons.more_vert, color: Colors.indigo,),
                      onPressed: () =>
                          removeContactAlertDialog(
                              contacts.documents.elementAt(index))),
                ),
              );
            }
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return  StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance.collection('profiles').where('send_contacts', arrayContains: UserInf.uid).snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(child: CircularProgressIndicator(backgroundColor: Colors.deepPurple));
              break;
            case ConnectionState.active:
              return _contactsList(snapshot.data);
              break;
            case ConnectionState.done:
              return const Text('DONE');
              break;
            default:
              return const Text('Erreur');
          }
        }
    );
  }
}
