import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NameScreen extends StatefulWidget {
  const NameScreen({super.key});

  @override
  State<NameScreen> createState() => _NameScreenState();
}

class _NameScreenState extends State<NameScreen> {
  final firebaseAuth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;
  final formKey = GlobalKey<FormState>();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isPasswordText = true;

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
        title: Text('Name',
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
          Text('Change Name',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
            )
          ),
          Padding(
            padding: const EdgeInsets.all(10),
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
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: firstNameController,
                              decoration: InputDecoration(
                                labelText: 'First Name',
                              ),
                              validator: (value){
                                if(value == null || value.isEmpty){
                                  return "First name is missing!";
                                }
                              },
                            ),
                          ),
                          SizedBox(width: 15),
                          Expanded(
                            child: TextFormField(
                              controller: lastNameController,
                              decoration: InputDecoration(
                                labelText: 'Last Name',
                              ),
                              validator: (value){
                                if(value == null || value.isEmpty){
                                  return "Last name is missing!";
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      TextFormField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: 'Email address',
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
                            changeName(
                                firstName: firstNameController.text,
                                lastName: lastNameController.text,
                                email: emailController.text,
                                password: passwordController.text
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
                ),
              )
            ),
          )
        ],
      ),
    );
  }
}
