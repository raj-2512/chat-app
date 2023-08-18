import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService extends ChangeNotifier{
  
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  String get currentUserUid {
    return _firebaseAuth.currentUser?.uid ?? '';
  }

  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = 
        await _firebaseAuth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        _fireStore.collection('users').doc(userCredential.user!.uid).set({
          'uid': userCredential.user!.uid,
          'email': email,
          'authMethod': 'email',
        }, SetOptions(merge: true));

      return userCredential;
    } 
    on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }
  
  Future<UserCredential> signUpWithEmailandPassword(
    String email, password, username) async {
    try {
      UserCredential userCredential = 
        await _firebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        _fireStore.collection('users').doc(userCredential.user!.uid).set({
          'uid': userCredential.user!.uid,
          'email': email,
          'authMethod': 'email',
          'username': username,
          'pfp': false,
          'profileImage': '',
        });

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  Future<void> signOut() async {
    return await FirebaseAuth.instance.signOut();
  }
  
  
  Future<void> signInWithGoogle() async {
    final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();

    if (gUser != null) {
      final GoogleSignInAuthentication gAuth = await gUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken,
        idToken: gAuth.idToken,
      );

      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      if (userCredential.user != null) {
        final email = userCredential.user!.email ?? '';
        final uid = userCredential.user!.uid;

        final username = email.split('@').first;

        final userDocRef = _fireStore.collection('users').doc(uid);
        final userDoc = await userDocRef.get();

        if (!userDoc.exists || (userDoc.exists && userDoc['username'] == null)) {
          await userDocRef.set(
            {
              'uid': uid,
              'email': email,
              'authMethod': 'google', // Add the authentication method
              'username': username,
              'pfp': false,
              'profileImage': '',
            },
            SetOptions(merge: true),
          );
        }
      }
    }
  }
}