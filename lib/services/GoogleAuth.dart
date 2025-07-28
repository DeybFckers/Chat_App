import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthClass {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/contacts.readonly',
    ],
  );

  FirebaseAuth auth = FirebaseAuth.instance;

  Future<UserCredential?> googleSignIn(BuildContext context) async {
    try {
      // Start the Google Sign-In flow and wait for the user to select an account
      GoogleSignInAccount? googleSignInAccount = await _googleSignIn.signIn();

      // Check if the user actually selected an account or canceled the sign-in
      if (googleSignInAccount != null) {
        // Obtain authentication tokens (idToken and accessToken) from the selected Google account
        GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;

        // Create a new Firebase credential using the tokens obtained from Google
        AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken,
        );

        try {
          // Use the Firebase credential to sign in (or register) the user with Firebase Authentication
          UserCredential userCredential = await auth.signInWithCredential(credential);

          // Return the signed-in user's credentials on success
          return userCredential;
        } catch (e) {
          // If Firebase sign-in fails, show an error message in a SnackBar and return null
          final snackBar = SnackBar(content: Text(e.toString()));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          return null;
        }
      } else {
        // The user canceled the Google sign-in, so return null (no user signed in)
        return null;
      }
    } catch (e) {
      // Catch any unexpected errors during the Google sign-in process,
      // show an error message, and return null
      final snackBar = SnackBar(content: Text(e.toString()));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return null;
    }
  }
}