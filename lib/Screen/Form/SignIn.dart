import 'package:chat_app/Screen/AppScreen/Home.dart';
import 'package:chat_app/Screen/Form/SignUp.dart';
import 'package:chat_app/widgets/AuthField.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:chat_app/services/GoogleAuth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class SignIn extends StatefulWidget {
  static route () => MaterialPageRoute(
    builder: (context) => SignIn()
  );
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final firebaseAuth = FirebaseAuth.instance;
  final firebaseStore = FirebaseFirestore.instance;
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _secureText = true;
  bool circular = false;
  AuthClass authClass =AuthClass();

  void dispose(){
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
          child: IntrinsicHeight(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Form(
                  key: formKey,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      children: [
                        Text('Sign In',
                          style: TextStyle(
                            fontSize: 50,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 20,),
                        AuthField(
                            labelText: 'Email',
                            controller: emailController,
                          icon: Icons.email,
                        ),
                        SizedBox(height: 10,),
                        AuthField(
                          labelText: 'Password',
                          controller: passwordController,
                          isPasswordText: _secureText,
                          icon: Icons.key,
                          suffixIcon: passwordController.text.isNotEmpty
                          ? IconButton(
                            icon: Icon(_secureText
                              ? Icons.visibility
                              : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _secureText = !_secureText;
                              });
                            },
                          )
                            : null,
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () async{
                            setState(() {
                              circular = true;
                            });
                            if(formKey.currentState!.validate()){
                              try{
                                UserCredential userCredential = await firebaseAuth.signInWithEmailAndPassword(
                                    email: emailController.text, password: passwordController.text);

                                User? user = userCredential.user;

                                final userDoc = await firebaseStore
                                  .collection('users')
                                  .doc(user!.uid)
                                  .get();

                                String name = userDoc.data()?['Name']??'';
                                String email = userDoc.data()?['Email']??'';
                                String photoUrl = userDoc.data()?['Photo'] ?? '';

                                Get.offAll(() => Home(
                                  uid:user.uid,
                                  name: name,
                                  email: email,
                                  photoUrl: photoUrl.isEmpty
                                      ? 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(name)}' // default avatar
                                      : photoUrl,
                                ));
                              }catch(e){
                                final snackBar = SnackBar(content: Text(e.toString()));
                                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                setState(() {
                                  circular = false;
                                });
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            fixedSize: Size(410, 55),
                          ),
                          child: circular ? CircularProgressIndicator() :
                          Text('Sign In',
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.only(left: 25, right: 25),
                          child: Row(
                            children: [
                              Expanded(
                                  child: Divider(
                                    thickness: 1.5,
                                    color: Colors.grey[400],
                                  )
                              ),
                              Text('Or',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                )
                              ),
                              Expanded(
                                  child: Divider(
                                    thickness: 1.5,
                                    color: Colors.grey[400],
                                  )
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),
                        InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () async {
                            final userCredential = await authClass.googleSignIn(context);

                            final user = userCredential?.user;
                            if (user != null) {

                              final userRef = firebaseStore
                                  .collection('users')
                                  .doc(user.uid);
                              final doc = await userRef.get();

                              if (!doc.exists) {
                                await userRef.set({
                                  'Name': user.displayName ?? '',
                                  'Email': user.email ?? '',
                                  'Photo': user.photoURL ?? '',
                                  'createdAt': DateTime.now(),
                                });
                              }
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.blue, width: 2),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  'assets/google.svg',
                                  height: 25,
                                  width: 25,
                                ),
                                SizedBox(width: 10),
                                Text('Sign In with Google'),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
          padding: EdgeInsets.fromLTRB(20, 25, 20, 25),
          child: ElevatedButton(
              onPressed: (){
                Navigator.push(
                    context, SignUp.route()
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                elevation: 0,
                fixedSize: const Size(415, 55),
                side: BorderSide(color: Colors.blue, width: 2),
              ),
              child: Text(
                  'Create new account',
                style: TextStyle(color: Colors.blue),
              )
          ),
      ),
    );
  }
}
