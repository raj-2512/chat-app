import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class ChangeUsernamePage extends StatefulWidget {
  const ChangeUsernamePage({Key? key}) : super(key: key);

  @override
  State<ChangeUsernamePage> createState() => _ChangeUsernamePageState();
}

class _ChangeUsernamePageState extends State<ChangeUsernamePage> {
  final _usernameController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void changeUsername(BuildContext context) async {
    String newUsername = _usernameController.text.trim();

    if (newUsername.isNotEmpty) {
      String uid = FirebaseAuth.instance.currentUser!.uid;

      try {
        await _firestore.collection('users').doc(uid).update({
          'username': newUsername,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Username changed successfully.'),
          ),
        );

        // Navigator.pop(context);
      } catch (error) {
        print('Error changing username: $error');
      }
    }
  }

  Future<bool> _getPFPStatus() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    DocumentSnapshot snapshot =
        await _firestore.collection('users').doc(uid).get();
    if (snapshot.exists) {
      return snapshot.get('pfp') ?? false;
    }
    return false;
  }

  Future<void> _uploadImageAndSetPFP(XFile pickedImage) async {
    final String uid = FirebaseAuth.instance.currentUser!.uid;
    
    // Get user's current profile image URL
    final DocumentSnapshot userSnapshot =
        await _firestore.collection('users').doc(uid).get();
    final String oldImageURL = userSnapshot.get('profileImage') ?? '';
    
    if (oldImageURL.isNotEmpty) {
      try {
        // Delete the old image from Firebase Storage
        final Reference oldImageReference =
            FirebaseStorage.instance.refFromURL(oldImageURL);
        await oldImageReference.delete();
      } catch (error) {
        print('Error deleting old image: $error');
      }
    }

    // Upload the new image
    final Reference storageReference =
        FirebaseStorage.instance.ref().child('profile_images/${DateTime.now().millisecondsSinceEpoch}');
    final UploadTask uploadTask = storageReference.putFile(File(pickedImage.path));

    await uploadTask.whenComplete(() {});

    // Get the download URL of the uploaded image
    final String downloadURL = await storageReference.getDownloadURL();

    // Update user's document in Firestore
    await _firestore.collection('users').doc(uid).update({
      'pfp': true,
      'profileImage': downloadURL,
    });

    setState(() {});
  }

  Future<void> _selectImage() async {
    final ImagePicker _picker = ImagePicker();

    XFile? pickedImage = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      await _uploadImageAndSetPFP(pickedImage);
    }
  }

  void resetToDefault() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    await _firestore.collection('users').doc(uid).update({
      'pfp': false,
    });

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.black,
      ),
      // body: _setUsername(),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                StreamBuilder<DocumentSnapshot>(
                  stream: _firestore
                      .collection('users')
                      .doc(FirebaseAuth.instance.currentUser!.uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    var data = snapshot.data?.data() as Map<String, dynamic>?;
                    String username = data?['username'] ?? '';
                    
                    return Text(
                      username,
                      style: GoogleFonts.bebasNeue(
                        fontSize: 60,
                      ),
                    );
                  },
                ),
                
                FutureBuilder<DocumentSnapshot>(
                  future: _firestore
                      .collection('users')
                      .doc(FirebaseAuth.instance.currentUser!.uid)
                      .get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }

                    if (!snapshot.hasData) {
                      return const Icon(
                        Icons.account_circle,
                        size: 200,
                        color: Colors.black,
                      );
                    }

                    var data = snapshot.data?.data() as Map<String, dynamic>?;
                    bool pfpStatus = data?['pfp'] ?? false;

                    return CircleAvatar(
                      radius: 100,
                      backgroundColor: Colors.white,
                      backgroundImage: pfpStatus
                          ? NetworkImage(data?['profileImage'] ?? '')
                          : null,
                      child: !pfpStatus
                          ? const Icon(
                              Icons.account_circle,
                              size: 200,
                              color: Colors.black,
                            )
                          : null,
                    );
                  },
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: _selectImage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                        ),
                        child: const Text("Change Image",),
                      ),
                      ElevatedButton(
                        onPressed: resetToDefault,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                        ),
                        child: const Text("Reset"),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
          
                //username
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: TextField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'username',
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                
                //Submit button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: GestureDetector(
                    onTap: () => changeUsername(context),
                    child: Container(
                      padding: const EdgeInsets.all(25),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(12)
                      ),
                      child: const Center(
                        child: Text(
                          'Change Username',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      )
    );
  }
}