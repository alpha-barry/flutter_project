import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:modue_flutter_ex2/UserInf.dart';
import 'package:modue_flutter_ex2/widgets/headerWidget.dart';
import 'package:provider/provider.dart';

import 'NightMode.dart';

class Test extends ChangeNotifier {
  int i = 2;

  void changeValue() {
    i++;
    notifyListeners();
  }
}

class MessengerPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MessengerPageStateful();
  }
}


class MessengerPageStateful extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MessengerPageState();
}

class MessengerPageState extends State<MessengerPageStateful> {

  final TextEditingController _textController = new TextEditingController();
  String imgUrl = "https://firebasestorage.googleapis.com/v0/b/flutterproject-1bb5a.appspot.com/o/photo_profile_fb.jpg?alt=media&token=538ede67-3318-4470-9a7e-192660080f34";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    Firestore.instance.document('profiles/' + UserInf.contactUid).snapshots().listen((onData){
      setState(() {
        UserInf.contactFullName = onData.data['firstName'] + " " + onData.data["lastName"];
      });
    });

    final StorageReference storageReference = FirebaseStorage.instance
        .ref().child("profiles/" + UserInf.contactUid + "/photo_de_profile");
    storageReference.getDownloadURL().then((onValue) {
      setState(() {
        if (onValue != null)
          imgUrl = onValue;
        //this.imagePickerFile = File(onValue);
      });
    });
  }

  void  removeContact(DocumentSnapshot contact){
    /*Firestore.instance.collection("profiles").document(UserInf.uid).snapshots().map((convert){
      List list = convert.data[];
    });*/
    Firestore.instance.collection("profiles").document(UserInf.uid).updateData({"contacts": FieldValue.arrayRemove([contact["uid"]])});
    Firestore.instance.collection("profiles").document(contact["uid"]).updateData({"contacts": FieldValue.arrayRemove([UserInf.uid])});
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

  Widget _messageList(Map contactsMap){

    final dateFormat = new DateFormat("dd/MM/yyyy 'à' HH:mm:ss");

    String name;
    Color color1;
    Color colorName;

    if (contactsMap == null)
      return Center(
        child: Text("Pas de messages"),
      );

    List contacts = contactsMap["messages"];
    contacts = contacts.reversed.toList();

    return ListView.builder(
        padding: new EdgeInsets.all(8.0),
        reverse: true,
        itemCount: contacts.length,
        itemBuilder: (context, index){

          if (contacts[index]["uid"] == UserInf.uid) {
            name = "Moi";
            colorName = Colors.indigo;
            color1 = Colors.blueGrey;
          }
          else {
            name = contacts[index]["name"];
            colorName = Colors.black;
            color1 = Colors.white;
          }

          DateTime dateTime = contacts[index]["timestamp"].toDate();
          dateTime = dateTime.toUtc().add(new Duration(hours: 2));
          String _date = dateFormat.format(dateTime);

          return Card(
            color: color1,
            child: new Wrap(
              // crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  ListTile(
                    title: new Text(name, style: TextStyle(color: colorName),),
                    trailing: new Text(_date, style: TextStyle(color: Colors.indigo, fontSize: 14,),),
                  ),
                  Container(
                    padding: EdgeInsets.all(15),
                    child: Text(contacts[index]["message"], style: TextStyle(color: Colors.black)),
                  ),
                ]),
          );
        }
    );
  }

  void sendMessage(String pathConversation, String message, String myId) {

    if (message.trim().length > 0) {
      Firestore.instance.document(pathConversation).setData({
        'messages': FieldValue.arrayUnion([
          {
            'name': UserInf.fullName,
            'message': message,
            'timestamp': DateTime.now(),
            'uid': myId,
            'hasSeen': false
          }
        ])
      }, merge: true);

      Firestore.instance.document('profiles/' + UserInf.contactUid).get().then((
          onData) {
        Firestore.instance.document(
            "chat/" + myId + "/conversations/" + UserInf.contactUid).setData({
          'contactName': UserInf.contactFullName,
        }, merge: true);
        Firestore.instance.document(
            "chat/" + UserInf.contactUid + "/conversations/" + myId).setData({
          'contactName': UserInf.fullName,
        }, merge: true);
      });
    }
  }

  Widget _textComposerWidget() {
    return new IconTheme(
      data: new IconThemeData(color: Colors.green),
      child: new Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: new Row(
          children: <Widget>[
            new Flexible(
              child: new TextField(
                decoration:
                new InputDecoration.collapsed(hintText: "Envoyer un message",
                    fillColor: Colors.transparent
                ),
                controller: _textController,
                onSubmitted: null,
              ),
            ),
            new Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              child: new IconButton(
                icon: new Icon(
                    Icons.send ,
                    color: Colors.deepPurple),
                onPressed: () {
                  sendMessage("chat/" + UserInf.uid + "/conversations/" + UserInf.contactUid, _textController.text, UserInf.uid);
                  if (UserInf.uid != UserInf.contactUid)
                    sendMessage("chat/" + UserInf.contactUid + "/conversations/" + UserInf.uid, _textController.text, UserInf.uid);
                  _textController.clear();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Provider.of<NightMode>(context, listen: true).color,
      appBar: new AppBar(
        title: Center(
          child: new Row(
            children: <Widget>[
              Padding(
                  padding: EdgeInsets.all(5.0),
                child: new CircleAvatar(
                  backgroundImage: NetworkImage(imgUrl),
                ),
              ),
              Center(
                child: new Text(
                  UserInf.contactFullName != null
                      ?  UserInf.contactFullName
                      : '',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
      endDrawer: headerWidget(context),
      body: new StreamBuilder<DocumentSnapshot>(
          stream: Firestore.instance.document("chat/" + UserInf.uid + "/conversations/" + UserInf.contactUid).snapshots(),
          builder: (context, snapshot) {
            print("CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC");
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return Center(child: CircularProgressIndicator(backgroundColor: Colors.deepPurple));
                break;
              case ConnectionState.active:
                return new Column(
                  children: <Widget>[
                    new Flexible(
                      child: _messageList(snapshot.data.data),
                    ),
                    new Divider(
                      height: 1.0,
                    ),
                    new Container(
                      decoration: new BoxDecoration(
                        color: Theme.of(context).cardColor,
                      ),
                      child: _textComposerWidget(),
                    ),
                  ],
                );
              case ConnectionState.done:
                return Text("DONE");
                break;
              default:
                return Text('Erreur');
            }
          }
      ),
    );
  }
}
