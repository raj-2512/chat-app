import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:Twitter/auth/auth_service.dart';
import 'package:Twitter/pages/friend_request_page.dart';
import 'package:provider/provider.dart';

import 'chat_page.dart';
import 'change_username.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // final user = FirebaseAuth.instance.currentUser!;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  late String _username = ''; // Initialize with an empty string
  final _friendUsernameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  void _loadUsername() async {
    String uid = _auth.currentUser!.uid;

    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      setState(() {
        _username = userSnapshot['username'];
      });
    } catch (error) {
      print('Error loading username: $error');
    }
  }

  void _sendFriendRequest() async {
    String friendUsername = _friendUsernameController.text.trim();

    if (friendUsername.isNotEmpty && friendUsername != _username) {
      try {
        DocumentSnapshot friendSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: friendUsername)
          .get()
          .then((value) => value.docs.first);

        String friendUid = friendSnapshot['uid'];
        String currentUserUid = _auth.currentUser!.uid;

        await _fireStore.collection('friend_requests').add({
          'senderUid': currentUserUid,
          'receiverUid': friendUid,
          'status': 'pending',
          'timestamp': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Friend request sent')),
        );

        _friendUsernameController.clear();
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User not found or error: $error'))
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid username')),
      );
    }
  }

  void signOut() {
    final authService = Provider.of<AuthService>(context, listen: false);

    authService.signOut();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Home Page',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            onPressed: signOut,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 45,
                    child: TextField(
                      controller: _friendUsernameController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Username',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  height: 45,
                  child: ElevatedButton(
                    onPressed: _sendFriendRequest,
                    style: const ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(Colors.black),
                    ),
                    child: const Text('Send Request'),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 370,
            child: OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FriendRequestPage()),
                );
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(
                  color: Colors.black,
                ),
              ),
              child: const Text(
                'View Requests',
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Row(
              children: [
                Expanded(
                  child: Divider(
                    thickness: 0.5,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _buildUserList(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Row(
              children: [
                Expanded(
                  child: Divider(
                    thickness: 0.5,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(_auth.currentUser!.uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }

                    if (snapshot.hasData) {
                      var pfpStatus = snapshot.data!['pfp'];
                      var profileImage = snapshot.data!['profileImage'];
                      return CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.white,
                        backgroundImage: pfpStatus ? NetworkImage(profileImage) : null,
                        child: pfpStatus ? null : const Icon(
                          Icons.account_circle,
                          size: 40,
                          color: Colors.black,
                        ),
                      );
                    }
                    return const SizedBox(); // Return an empty SizedBox if no data
                  },
                ),
                const SizedBox(width: 10),
                StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(_auth.currentUser!.uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }

                    if (snapshot.hasData) {
                      var username = snapshot.data!['username'];
                      _username = username; // Update the local username
                      return Text(
                        username,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      );
                    }
                    return Text(
                      _username,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ); // Display the stored username
                  },
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ChangeUsernamePage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                  ),
                  child: const Text(
                    'Edit Profile',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 25.0),
          //   child: Row(
          //     children: [
          //       Expanded(
          //         child: Divider(
          //           thickness: 0.5,
          //           color: Colors.grey[400],
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          // Container(
          //   padding: const EdgeInsets.all(10),
          //   alignment: Alignment.center,
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.center,
          //     children: [
          //       const Icon(
          //         Icons.account_circle, // Add your preferred icon here
          //         size: 40,
          //         color: Colors.black, // Set the color for the default icon
          //       ),
          //       const SizedBox(width: 10),
          //       StreamBuilder<DocumentSnapshot>(
          //         stream: FirebaseFirestore.instance
          //             .collection('users')
          //             .doc(_auth.currentUser!.uid)
          //             .snapshots(),
          //         builder: (context, snapshot) {
          //           if (snapshot.hasData) {
          //             var username = snapshot.data!['username'];
          //             _username = username; // Update the local username
          //             return Text(
          //               username,
          //               style: const TextStyle(
          //                 fontWeight: FontWeight.bold,
          //                 fontSize: 16,
          //               ),
          //             );
          //           }
          //           return Text(
          //             _username,
          //             style: const TextStyle(
          //               fontWeight: FontWeight.bold,
          //               fontSize: 16,
          //             ),
          //           ); // Display the stored username
          //         },
          //       ),
          //       const SizedBox(width: 10),
          //       ElevatedButton(
          //         onPressed: () {
          //           Navigator.push(
          //             context,
          //             MaterialPageRoute(builder: (context) => ChangeUsernamePage()),
          //           );
          //         },
          //         style: ElevatedButton.styleFrom(
          //           backgroundColor: Colors.black,
          //         ),
          //         child: const Text(
          //           'Edit Profile',
          //           style: TextStyle(
          //             color: Colors.white,
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildUserList() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Error');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('Loading...');
        }

        List<String> friendUids = [];
        if (snapshot.hasData) {
          Map<String, dynamic>? userData = snapshot.data!.data() as Map<String, dynamic>?;
          if (userData != null && userData.containsKey('friends')) {
            friendUids = List<String>.from(userData['friends']);
          }
        }

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('users').snapshots(),
          builder:(context, snapshot) {
            if (snapshot.hasError) {
              return const Text('Error');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text('Loading...');
            }

            List<DocumentSnapshot> friendDocs = snapshot.data!.docs
              .where((doc) => friendUids.contains(doc.id))
              .toList();

            if (friendDocs.isEmpty) {
              return const Text('No Friends Found');
            }

            return ListView(
              children: friendDocs
                .map<Widget>((doc) => _buildUserListItem(doc))
                .toList(),
            );
          },
        );
      },
    );
  }

  // Widget _buildUserListItem(DocumentSnapshot document) {
  //   Map<String, dynamic> data = document.data()! as Map<String, dynamic>;

  //   if (_auth.currentUser!.email != data['email']) {
  //     return ListTile(
  //       leading: const Icon(
  //       Icons.account_circle, // Add your preferred icon here
  //       size: 40,
  //       color: Colors.black, // Set the color for the default icon
  //     ),
  //       title: FutureBuilder<DocumentSnapshot>(
  //         future: FirebaseFirestore.instance.collection('users').doc(data['uid']).get(),
  //         builder: (context, snapshot) {
  //           if (snapshot.connectionState == ConnectionState.done) {
  //             if (snapshot.hasData && snapshot.data != null) {
  //               var username = snapshot.data!['username'];
  //               return Text(username);
  //             }
  //           }
  //           return const Text('Loading...'); // Return loading text while fetching username
  //         },
  //       ),
  //       onTap: () {
  //         Navigator.push(
  //           context,
  //           MaterialPageRoute(
  //             builder: (context) => ChatPage(
  //               receiverUserEmail: data['email'],
  //               receiverUserID: data['uid'],
  //             ),
  //           ),
  //         );
  //       },
  //     );
  //   } else {
  //     return Container();
  //   }
  // }

  Widget _buildUserListItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;

    return ListTile(
      leading: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(data['uid'])
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Icon(
              Icons.account_circle,
              size: 40,
              color: Colors.black,
            );
          }

          if (snapshot.hasData) {
            var pfpStatus = snapshot.data!['pfp'];
            var profileImage = snapshot.data!['profileImage'];
            return CircleAvatar(
              radius: 20,
              backgroundImage: pfpStatus ? NetworkImage(profileImage) : null,
              child: pfpStatus ? null : const Icon(
                Icons.account_circle,
                size: 20,
                color: Colors.black,
              ),
            );
          }
          
          return const Icon(
            Icons.account_circle,
            size: 40,
            color: Colors.black,
          ); // Display default icon if no data
        },
      ),
      title: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(data['uid']).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData && snapshot.data != null) {
              var username = snapshot.data!['username'];
              return Text(username);
            }
          }
          return const Text('Loading...'); // Return loading text while fetching username
        },
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatPage(
              receiverUserEmail: data['email'],
              receiverUserID: data['uid'],
            ),
          ),
        );
      },
    );
  }

}