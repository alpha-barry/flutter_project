import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:modue_flutter_ex2/UserInf.dart';
import 'package:modue_flutter_ex2/widgets/headerWidget.dart';
import 'package:provider/provider.dart';
import 'NightMode.dart';


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

  final TextEditingController _textController = TextEditingController();
  String imgUrl = 'https://firebasestorage.googleapis.com/v0/b/flutterproject-1bb5a.appspot.com/o/photo_profile_fb.jpg?alt=media&token=538ede67-3318-4470-9a7e-192660080f34';

  @override
  void initState() {
    super.initState();

    Firestore.instance.document('profiles/' + UserInf.contactUid).snapshots().listen((DocumentSnapshot onData){
      if (mounted) {
        setState(() {
          UserInf.contactFullName =
              onData.data['firstName'] + ' ' + onData.data['lastName'];
        });
      }
    });

    final StorageReference storageReference = FirebaseStorage.instance
        .ref().child('profiles/' + UserInf.contactUid + '/photo_de_profile');
    storageReference.getDownloadURL().then((dynamic onValue) {
      if (mounted) {
        setState(() {
          if (onValue != null)
            imgUrl = onValue;
        });
      }
    });
  }

  void  removeContact(DocumentSnapshot contact){
    Firestore.instance.collection('profiles').document(UserInf.uid).updateData(<String, FieldValue>{'contacts': FieldValue.arrayRemove(<String>[contact['uid']])});
    Firestore.instance.collection('profiles').document(contact['uid']).updateData(<String, FieldValue>{'contacts': FieldValue.arrayRemove(<String>[UserInf.uid])});
  }

  Future<void> removeContactAlertDialog(DocumentSnapshot contact) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
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
                removeContact(contact);
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

  Widget _messageList(Map<String, dynamic> contactsMap){

    final DateFormat dateFormat = DateFormat("dd/MM/yyyy 'à' HH:mm:ss");

    String name;
    Color color1;
    Color colorName;

    if (contactsMap == null)
      return const Center(
        child: Text('Pas de messages'),
      );

    List<dynamic> contacts = contactsMap['messages'];

    if (contacts != null) {
      contacts = contacts.reversed.toList();
    }

    return ListView.builder(
        padding: const EdgeInsets.all(8.0),
        reverse: true,
        itemCount: contacts.length,
        itemBuilder: (BuildContext context, int index){

          if (contacts[index]['uid'] == UserInf.uid) {
            name = 'Moi';
            colorName = Colors.indigo;
            color1 = Colors.blueGrey;
          }
          else {
            name = contacts[index]['name'];
            colorName = Colors.black;
            color1 = Colors.white;
          }

          DateTime dateTime = contacts[index]['timestamp'].toDate();
          dateTime = dateTime.toUtc().add(const Duration(hours: 2));
          final String _date = dateFormat.format(dateTime);

          return Card(
            color: color1,
            child: Wrap(
                children: <Widget>[
                  ListTile(
                    title: Text(name, style: TextStyle(color: colorName),),
                    trailing: Text(_date, style: TextStyle(color: Colors.indigo, fontSize: 14,),),
                  ),
                  Container(
                    padding: const EdgeInsets.all(15),
                    child: Text(contacts[index]['message'], style: TextStyle(color: Colors.black)),
                  ),
                ]),
          );
        }
    );
  }

  void sendMessage(String pathConversation, String message, String myId) {

    if (message.trim().isNotEmpty) {

      Firestore.instance.document('profiles/' + UserInf.contactUid).get().then((DocumentSnapshot onData) {

        final List<dynamic> contacts = onData.data['contacts'];

        if (contacts.contains(UserInf.uid)) {
          Firestore.instance.document(pathConversation).setData(<String, FieldValue>{
            'messages': FieldValue.arrayUnion(<Map<String, dynamic>>[
              <String, dynamic>{
                'name': UserInf.fullName,
                'message': message,
                'timestamp': DateTime.now(),
                'uid': myId,
                'hasSeen': false
              }
            ])
          }, merge: true);
          Firestore.instance.document(
              'chat/' + myId + '/conversations/' + UserInf.contactUid).setData(<String, dynamic>{
            'contactName': UserInf.contactFullName,
          }, merge: true);
          Firestore.instance.document(
              'chat/' + UserInf.contactUid + '/conversations/' + myId).setData(<String, dynamic>{
            'contactName': UserInf.fullName,
          }, merge: true);
        }
      });
    }
  }

  Widget _textComposerWidget() {
    return IconTheme(
      data: IconThemeData(color: Colors.green),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: <Widget>[
            Flexible(
              child: TextField(
                decoration:
                InputDecoration.collapsed(hintText: 'Envoyer un message',
                    fillColor: Colors.transparent
                ),
                controller: _textController,
                onSubmitted: null,
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              child: IconButton(
                icon: Icon(
                    Icons.send ,
                    color: Colors.deepPurple),
                onPressed: () {
                  sendMessage('chat/' + UserInf.uid + '/conversations/' + UserInf.contactUid, _textController.text, UserInf.uid);
                  if (UserInf.uid != UserInf.contactUid)
                    sendMessage('chat/' + UserInf.contactUid + '/conversations/' + UserInf.uid, _textController.text, UserInf.uid);
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
      appBar: AppBar(
        title: Center(
          child: Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: CircleAvatar(
                  backgroundImage: NetworkImage(imgUrl),
                ),
              ),
              Center(
                child: Text(
                  UserInf.contactFullName ?? '',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
      endDrawer: headerWidget(context),
      body: StreamBuilder<DocumentSnapshot>(
          stream: Firestore.instance.document('chat/' + UserInf.uid + '/conversations/' + UserInf.contactUid).snapshots(),
          builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return Center(child: CircularProgressIndicator(backgroundColor: Colors.deepPurple));
                break;
              case ConnectionState.active:
                return Column(
                  children: <Widget>[
                    Flexible(
                      child: _messageList(snapshot.data.data),
                    ),
                    const Divider(
                      height: 1.0,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                      ),
                      child: _textComposerWidget(),
                    ),
                  ],
                );
              case ConnectionState.done:
                return const Text('DONE');
                break;
              default:
                return const Text('Erreur');
            }
          }
      ),
    );
  }
}
