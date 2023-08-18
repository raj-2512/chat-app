import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FriendRequestPage extends StatefulWidget {
  const FriendRequestPage({Key? key}) : super(key: key);

  @override
  State<FriendRequestPage> createState() => _FriendRequestPageState();
}

class _FriendRequestPageState extends State<FriendRequestPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Friend Requests',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.black,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _fireStore
          .collection('friend_requests')
          .where('receiverUid', isEqualTo: _auth.currentUser!.uid)
          .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if(!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No Friend Requests'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var requestDoc = snapshot.data!.docs[index];
              String senderUid = requestDoc['senderUid'];
              String requestDocId = requestDoc.id;

              return ListTile(
                title: FutureBuilder<DocumentSnapshot>(
                  future: _fireStore.collection('users').doc(senderUid).get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      if (snapshot.hasData && snapshot.data != null) {
                        var senderUsername = snapshot.data!['username'];
                        return Text(senderUsername);
                      }
                    }
                    return const Text('Loading...');
                  },
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () async {
                        await _acceptFriendRequest(senderUid, requestDocId);
                      },
                      icon: const Icon(Icons.check),
                      color: Colors.green,
                    ),
                    IconButton(
                      onPressed: () async {
                        await _declineFriendRequest(requestDocId);
                      },
                      icon: const Icon(Icons.close),
                      color: Colors.red,
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _acceptFriendRequest(String senderUid, String requestDocId) async {
    try {
      String currentUserUid = _auth.currentUser!.uid;

      await _fireStore.collection('users').doc(currentUserUid).update({
        'friends': FieldValue.arrayUnion([senderUid]),
      });

      await _fireStore.collection('users').doc(senderUid).update({
        'friends': FieldValue.arrayUnion([currentUserUid]),
      });

      await _fireStore.collection('friend_requests').doc(requestDocId).delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Friend request accepted')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error accepting request: $error')),
      );
    }
  }

  Future<void> _declineFriendRequest(String requestDocId) async {
    try {
      await _fireStore.collection('friend_requests').doc(requestDocId).delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Friend request declined')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error declining request: $error')),
      );
    }
  }
}