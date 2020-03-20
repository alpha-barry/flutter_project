import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:modue_flutter_ex2/MessengerPage.dart';
import 'package:modue_flutter_ex2/UserInf.dart';
import 'package:modue_flutter_ex2/widgets/HeaderWidget.dart';

class ConvListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(

        title: Text('Conversations'),
      ),
      endDrawer: HeaderWidget(context),
      body: ConvListPageStateful(),
    );
  }
}


class ConvListPageStateful extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ConvListPageState();
}

class ConvListPageState extends State<ConvListPageStateful> {


  Widget conversationList(QuerySnapshot contacts){
    return new Scrollbar (
        child: ListView.builder(
            itemCount: contacts.documents.length,
            itemBuilder: (context, index){
              List list = contacts.documents.elementAt(index).data["messages"];
              return Card(
                child: ListTile(
                  title: Text(contacts.documents.elementAt(index).data["contactName"] ?? ''),
                  subtitle: Text(list?.last["message"] ?? ''),
                  leading: CircleAvatar(child: Text(list?.last["name"][0] ?? '')),
                  onTap: () {
                    UserInf.contactUid = contacts.documents.elementAt(index).documentID;
                    Navigator.push(context, MaterialPageRoute(
                        builder: (context) => MessengerPage()));
                  },
                  trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.indigo,),
                      onPressed: () {
                        Firestore.instance.collection("chat/" +  UserInf.uid + "/conversations").document(contacts.documents.elementAt(index).documentID).delete();
                        Firestore.instance.collection("chat/" + contacts.documents.elementAt(index).documentID + "/conversations").document(UserInf.uid).delete();
                      }),
                ),
              );
            }
        )
    );
  }

  @override
  Widget build(BuildContext ctextontext) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection("chat/" + UserInf.uid + "/conversations").snapshots(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return Center(child: CircularProgressIndicator(backgroundColor: Colors.deepPurple));
            break;
          case ConnectionState.active:
            if (snapshot.data.documents.length != 0)
              return conversationList(snapshot.data);
            else
              return Center(child: Text("Aucune conversation"));
            break;
          case ConnectionState.done:
            return Text("DONE");
            break;
          default:
            return Text('Erreur');
        }
      },
    );
  }
}
