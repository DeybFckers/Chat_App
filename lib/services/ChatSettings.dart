import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatSettings{
  final firebaseAuth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;

  Future<void>changeName({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  })async{
    try{
      User? user = firebaseAuth.currentUser;

      if(user == null) throw Exception("No user signed in.");

      //re-authenticate
      final cred = EmailAuthProvider.credential(
          email: email, password: password
      );
      await user.reauthenticateWithCredential(cred);

      String fullName = '${firstName} ${lastName}';
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'Name': fullName,
      });

      Get.snackbar("Success", "Name updated successfully");

    }catch(e){
      final err = e is FirebaseException ? e.message : e.toString();
      Get.snackbar("Error", err!,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> changeEmail({
    required String newEmail,
    required String confirmEmail,
    required String password,
  }) async{
    try{
      User? user = firebaseAuth.currentUser;

      if(user == null) throw Exception("No user signed in.");
      if(newEmail != confirmEmail) throw Exception("Emails do not match.");

      //re-authenticate
      final cred = EmailAuthProvider.credential(
        email:user.email! , password: password,
      );
      await user.reauthenticateWithCredential(cred);

      //if real apps use this
      // await user.verifyBeforeUpdateEmail(newEmail);

      // practice app / disable Email enumeration protection (recommended) in auth settings
      // ignore: deprecated_member_use
      await user.updateEmail(newEmail);
      await firestore
          .collection('users')
          .doc(user.uid)
          .update({
        "Email": newEmail
      });

      Get.snackbar("Success", "Email updated successfully");

    }catch(e){
      final err = e is FirebaseException ? e.message : e.toString();
      Get.snackbar("Error", err!,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}