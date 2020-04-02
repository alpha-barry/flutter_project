import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:modue_flutter_ex2/UserInf.dart';
import 'package:modue_flutter_ex2/widgets/headerWidget.dart';
import 'package:provider/provider.dart';

import 'NightMode.dart';

class ConversationsListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Provider.of<NightMode>(context, listen: true).color,
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Center(child: Text('Conversations')),
      ),
      endDrawer: headerWidget(context),
      body: ConversationsListPageStateful(),
    );
  }
}


class ConversationsListPageStateful extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ConversationsListPageState();
}

class ConversationsListPageState extends State<ConversationsListPageStateful> {


  Widget conversationList(QuerySnapshot contacts){
    return Scrollbar (
        child: ListView.builder(
            itemCount: contacts.documents.length,
            itemBuilder: (BuildContext context, int index){
              final List<dynamic> list = contacts.documents.elementAt(index).data['messages'];
              return Card(
                child: ListTile(
                  title: Text(contacts.documents.elementAt(index).data['contactName'] ?? ''),
                  subtitle: Text(list?.last['message'] ?? ''),
                  leading: CircleAvatar(child: Text(list?.last['name'][0] ?? '')),
                  onTap: () {
                    UserInf.contactUid = contacts.documents.elementAt(index).documentID;
                    Navigator.pushNamed(context, '/messenger');

                  },
                  trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.indigo,),
                      onPressed: () {
                        Firestore.instance.collection('chat/' +  UserInf.uid + '/conversations').document(contacts.documents.elementAt(index).documentID).delete();
                        Firestore.instance.collection('chat/' + contacts.documents.elementAt(index).documentID + '/conversations').document(UserInf.uid).delete();
                      }),
                ),
              );
            }
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('chat/' + UserInf.uid + '/conversations').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return Center(child: CircularProgressIndicator(backgroundColor: Colors.deepPurple));
            break;
          case ConnectionState.active:
            if (snapshot.data.documents.isNotEmpty)
              return conversationList(snapshot.data);
            else
              return const Center(child: Text('Aucune conversation'));
            break;
          case ConnectionState.done:
            return const Text('DONE');
            break;
          default:
            return const Text('Erreur');
        }
      },
    );
  }
}
