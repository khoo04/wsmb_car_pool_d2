import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../helper.dart';

class AuthService {
  static Future<bool> registerUser(String email, String password) async {
    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  static Future<void> loginUser(
      String ic, String password, BuildContext context) async {
    try {
      //Find user email
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('riders')
          .where('IC', isEqualTo: ic)
          .get();
      final userData = snapshot.docs.first.data() as Map<String, dynamic>;
      final email = userData["email"];
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      Helper.showSnackBar(context, "Invalid Credentials");
    }
  }
}
