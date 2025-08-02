import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class EmailScreen extends StatefulWidget {
  const EmailScreen({super.key});

  @override
  State<EmailScreen> createState() => _EmailScreenState();
}

class _EmailScreenState extends State<EmailScreen> {
  final firebaseAuth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;
  final formKey = GlobalKey<FormState>();
  final newEmailController = TextEditingController();
  final confirmEmailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isPasswordText = true;

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

      final snackBar = SnackBar(content: Text(toString()));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);

    }catch(e){
      final snackBar = SnackBar(content: Text(e.toString()));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        centerTitle: true,
        title: Text('Profile',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          )
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('Change Email',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
            )
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(width: 2)
              ),
              child: Form(
                key: formKey,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: newEmailController,
                        decoration: InputDecoration(
                          hintText: 'Enter your new email',
                          labelText: 'New Email',
                        ),
                        validator: (value){
                          if(value == null || value.isEmpty){
                            return "Email is missing!";
                          }
                          final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                          if(!emailRegex.hasMatch(value)){
                            return 'Enter a valid email address';
                          }

                        },
                      ),
                      TextFormField(
                        controller: confirmEmailController,
                        decoration: InputDecoration(
                          labelText: 'Confirm New Email',
                          hintText: 'Confirm your new email',
                        ),
                        validator: (value){
                          if(value == null || value.isEmpty){
                            return "Email is missing!";
                          }
                          final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                          if(!emailRegex.hasMatch(value)){
                            return 'Enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: passwordController,
                        decoration: InputDecoration(
                          hintText: 'Enter your password',
                          labelText: 'Password',
                          suffixIcon: passwordController.text.isNotEmpty
                          ? IconButton(
                            icon: Icon(isPasswordText
                              ? Icons.visibility
                              : Icons.visibility_off
                            ),
                            onPressed: (){
                              setState(() {
                                isPasswordText = !isPasswordText;
                              });
                            },
                          )
                            : null,
                        ),
                        obscureText: isPasswordText,
                      ),
                      SizedBox(height: 20,),
                      ElevatedButton(
                        onPressed: (){
                          if(formKey.currentState!.validate()) {
                            changeEmail(
                              newEmail: newEmailController.text,
                              confirmEmail: confirmEmailController.text,
                              password: passwordController.text,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                        ),
                        child: Text('Update',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      )
                    ],
                  ),
                )
              )
            ),
          )
        ],
      )
    );
  }
}
