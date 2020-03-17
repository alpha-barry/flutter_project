import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:modue_flutter_ex2/UserInf.dart';
import 'package:modue_flutter_ex2/widgets/HeaderWidget.dart';

class SearchMemberPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(

        title: Text('Recherche'),
      ),
      endDrawer: HeaderWidget(context),
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
    return new Scrollbar (
        child: ListView.builder(
            itemCount: contacts.documents.length,
            itemBuilder: (context, index){
              return CustomCardState(contacts.documents.elementAt(index));
            }
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return new StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance.collection("profils").snapshots(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(child: CircularProgressIndicator(backgroundColor: Colors.deepPurple));
              break;
            case ConnectionState.active:
              return _membersList(snapshot.data);
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

class CustomCardState extends StatefulWidget {
  final DocumentSnapshot document;
  CustomCardState(this.document);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new CustomCard(this.document);
  }
}

class CustomCard extends State<CustomCardState> {
  final DocumentSnapshot contact;

  CustomCard(this.contact);

  String status = "4";
  Icon icons = new Icon(Icons.refresh);

  @override
  void initState() {
    super.initState();

    Firestore.instance.collection("profils").document(UserInf.uid).snapshots().listen((onValue){
      List contactsList = onValue.data["contacts"];
      List recContactsList = onValue.data["rec_contacts"];
      List sendContactsList = onValue.data["send_contacts"];

      setState(() {
        if (contactsList != null && contactsList.contains(contact.documentID)) {
          status = "0";
        }
        else if (recContactsList != null && recContactsList.contains(contact.documentID)) {
          status = "1";
        }
        else if (sendContactsList != null && sendContactsList.contains(contact.documentID)) {
          status = "2";
        }
        else {
          status = "3";
        }
      });
    });
  }

  void  removeContact(String userUid){
    /*Firestore.instance.collection("profiles").document(myUid).snapshots().map((convert){
      List list = convert.data[];
    });*/
    Firestore.instance.collection("profils").document(UserInf.uid).updateData({"contacts": FieldValue.arrayRemove([userUid])});
    Firestore.instance.collection("profils").document(userUid).updateData({"contacts": FieldValue.arrayRemove([UserInf.uid])});
  }

  Future<void> removeContactAlertDialog(String userUid) async {
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
                removeContact(contact.documentID);
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

  Future<void> cancelContactAlertDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Ajout de contact'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text("Voulez vous annuler l'invitation avec " + contact["firstName"] + " " + contact["lastName"] + " ?"),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Oui'),
              onPressed: () {
                Firestore.instance.collection("profils").document(UserInf.uid).updateData({"send_contacts": FieldValue.arrayRemove([contact.documentID])});
                Firestore.instance.collection("profils").document(contact.documentID).updateData({"rec_contacts": FieldValue.arrayRemove([UserInf.uid])});
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

  @override
  Widget build(BuildContext context) {

    if (status == "0") {
      icons = new Icon(Icons.contacts);
    }
    else if (status == "1") {
      icons = new Icon(Icons.undo);
    }
    else if (status == "2") {
      icons = new Icon(Icons.send);
    }
    else if (status == "3"){
      icons = new Icon(Icons.add);
    }

    // TODO: implement build
    return Card(
      borderOnForeground: false,
      child: ListTile(
          leading: Icon(Icons.album, size: 50),
          title: new Text(contact["firstName"]),
          subtitle: new Text(contact["lastName"]),
          trailing: IconButton(
              icon: Icon(icons.icon, color: Colors.indigoAccent),
              onPressed: () {
                if (status == "0") {
                  removeContactAlertDialog(contact.documentID);
                }
                else if (status == "1") {
                  //acceptContactAlertDialog();
                }
                else if (status == "2") {
                  cancelContactAlertDialog();
                }
                else if (status == "3"){
                  Firestore.instance.collection("profils")
                      .document(UserInf.uid)
                      .updateData(
                      {"send_contacts": FieldValue.arrayUnion([contact.documentID])});
                  Firestore.instance.collection("profils")
                      .document(contact.documentID)
                      .updateData(
                      {"rec_contacts": FieldValue.arrayUnion([UserInf.uid])});
                }
              }
          ),

      ),
    );
  }
}
