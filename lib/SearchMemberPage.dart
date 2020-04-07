import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:modue_flutter_ex2/UserInf.dart';
import 'package:modue_flutter_ex2/widgets/headerWidget.dart';
import 'package:provider/provider.dart';

import 'NightMode.dart';

class SearchMemberPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Provider.of<NightMode>(context, listen: true).color,
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Center(child: Text('Recherche')),
      ),
      endDrawer: headerWidget(context),
      body: SearchMemberPageStateful(),
    );
  }
}


class SearchMemberPageStateful extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SearchMemberPageState();
}

class SearchMemberPageState extends State<SearchMemberPageStateful> {

  Widget _membersList(QuerySnapshot contacts){
    return Scrollbar (
        child: ListView.builder(
            itemCount: contacts.documents.length,
            itemBuilder: (BuildContext context, int index){
              return CustomCardState(contacts.documents.elementAt(index));
            }
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return  StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance.collection('profiles').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(child: CircularProgressIndicator(backgroundColor: Colors.deepPurple));
              break;
            case ConnectionState.active:
              return _membersList(snapshot.data);
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

class CustomCardState extends StatefulWidget {
  final DocumentSnapshot document;
  // ignore: sort_constructors_first, prefer_const_constructors_in_immutables
  CustomCardState(this.document);

  @override
  State<StatefulWidget> createState() {
    // ignore: flutter_style_todos
    // TODO: implement createState
    return CustomCard(document);
  }
}

class CustomCard extends State<CustomCardState> {
  final DocumentSnapshot contact;

  // ignore: sort_constructors_first
  CustomCard(this.contact);

  String status = '4';
  Icon icons = Icon(Icons.refresh);

  @override
  void initState() {
    super.initState();

    Firestore.instance.collection('profiles').document(UserInf.uid).snapshots().listen((DocumentSnapshot onValue){
      // ignore: always_specify_types
      final List contactsList = onValue.data['contacts'];
      // ignore: always_specify_types
      final List recContactsList = onValue.data['rec_contacts'];
      // ignore: always_specify_types
      final List sendContactsList = onValue.data['send_contacts'];
      if (mounted) {
        setState(() {
          if (contactsList != null && contactsList.contains(contact.documentID)) {
            status = '0';
          }
          else if (recContactsList != null &&
              recContactsList.contains(contact.documentID)) {
            status = '1';
          }
          else if (sendContactsList != null &&
              sendContactsList.contains(contact.documentID)) {
            status = '2';
          }
          else {
            status = '3';
          }
        });
      }

    });
  }

  void  removeContact(String userUid){
    /*Firestore.instance.collection("profiles").document(UserInf.uid).snapshots().map((convert){
      List list = convert.data[];
    });*/
    Firestore.instance.collection('profiles').document(UserInf.uid).updateData({'contacts': FieldValue.arrayRemove([userUid])});
    Firestore.instance.collection('profiles').document(userUid).updateData({'contacts': FieldValue.arrayRemove([UserInf.uid])});

    Firestore.instance.collection('chat/' +  UserInf.uid + '/conversations').document(userUid).delete();
    Firestore.instance.collection('chat/' + userUid + '/conversations').document(UserInf.uid).delete();
  }

  Future<void> removeContactAlertDialog(String userUid) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Suppression de contact'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Voulez vous supprimer ' + contact['firstName'] + ' ' + contact['lastName'] + ' de vos contacts ?'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: const Text('Oui'),
              onPressed: () {
                removeContact(contact.documentID);
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: const Text('Non'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> cancelContactAlertDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ajout de contact'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text("Voulez vous annuler l'invitation avec " + contact['firstName'] + ' ' + contact['lastName'] + ' ?'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: const Text('Oui'),
              onPressed: () {
                Firestore.instance.collection('profiles').document(UserInf.uid).updateData({'send_contacts': FieldValue.arrayRemove([contact.documentID])});
                Firestore.instance.collection('profiles').document(contact.documentID).updateData({'rec_contacts': FieldValue.arrayRemove([UserInf.uid])});
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: const Text('Non'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void  acceptContact(){
    // ignore: always_specify_types
    Firestore.instance.collection('profiles').document(UserInf.uid).updateData({'rec_contacts': FieldValue.arrayRemove([contact.documentID])}).then((onValue){
      Firestore.instance.collection('profiles').document(UserInf.uid).updateData({'contacts': FieldValue.arrayUnion([contact.documentID])});
    });
    // ignore: always_specify_types
    Firestore.instance.collection('profiles').document(contact.documentID).updateData({'send_contacts': FieldValue.arrayRemove([UserInf.uid])}).then((onValue){
      Firestore.instance.collection('profiles').document(contact.documentID).updateData({'contacts': FieldValue.arrayUnion([UserInf.uid])});
    });
  }

  Future<void> acceptContactAlertDialog() async {
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
                acceptContact();
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: const Text('Refuser'),
              onPressed: () {
                Firestore.instance.collection('profiles').document(UserInf.uid).updateData({'rec_contacts': FieldValue.arrayRemove([contact.documentID])});
                Firestore.instance.collection('profiles').document(contact.documentID).updateData({'send_contacts': FieldValue.arrayRemove([UserInf.uid])});
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    if (status == '0') {
      icons = Icon(Icons.contacts);
    }
    else if (status == '1') {
      icons = Icon(Icons.undo);
    }
    else if (status == '2') {
      icons = Icon(Icons.send);
    }
    else if (status == '3'){
      icons = Icon(Icons.add);
    }

    // ignore: flutter_style_todos
    // TODO: implement build
    return Card(
      borderOnForeground: false,
      child: ListTile(
        leading: Icon(Icons.album, size: 50),
        title: Text(contact['firstName']),
        subtitle: Text(contact['lastName']),
        trailing: IconButton(
            icon: Icon(icons.icon, color: Colors.indigoAccent),
            onPressed: () {
              if (status == '0') {
                removeContactAlertDialog(contact.documentID);
              }
              else if (status == '1') {
                acceptContactAlertDialog();
              }
              else if (status == '2') {
                cancelContactAlertDialog();
              }
              else if (status == '3'){
                Firestore.instance.collection('profiles')
                    .document(UserInf.uid)
                    .updateData(
                    {'send_contacts': FieldValue.arrayUnion([contact.documentID])});
                Firestore.instance.collection('profiles')
                    .document(contact.documentID)
                    .updateData(
                    {'rec_contacts': FieldValue.arrayUnion([UserInf.uid])});
              }
            }
        ),

      ),
    );
  }
}
