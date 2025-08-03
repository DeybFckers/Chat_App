import 'package:chat_app/Screen/AppScreen/Home.dart';
import 'package:chat_app/widgets/AuthField.dart';
import 'package:chat_app/services/GoogleAuth.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/Screen/Form/SignIn.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../utils/PasswordLogic.dart';

class SignUp extends StatefulWidget {
  static route () => MaterialPageRoute(
      builder: (context) => SignUp()
  );
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final firebaseAuth = FirebaseAuth.instance;
  final firebaseStore = FirebaseFirestore.instance;
  final formKey = GlobalKey<FormState>();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmpassController = TextEditingController();
  bool _secureText = true;
  bool _confirmsecureText = true;
  PasswordStrength? _passwordStrength;
  bool _showPasswordInstructions = false;
  bool circular = false;
  AuthClass authClass = AuthClass();

  void dispose(){
    firstNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void initState(){
    super.initState();
    passwordController.addListener((){
      final text = passwordController.text;
      final strength = PasswordStrength.calculate(text: passwordController.text);
      setState(() {
        _passwordStrength = strength;
        _showPasswordInstructions = text.isNotEmpty;
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:  SingleChildScrollView(
        child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
          child: IntrinsicHeight(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Form(
                  key:formKey,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      children: [
                        Text('Sign Up',
                          style: TextStyle(
                            fontSize: 50,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 20,),
                        Row(
                          children: [
                            Expanded(
                              child: AuthField(
                                  labelText: "First Name",
                                  controller: firstNameController,
                                  icon: Icons.person
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: AuthField(
                                labelText: "Last Name",
                                controller: lastNameController,
                                icon: Icons.person
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10,),
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
                        SizedBox(height: 10,),
                        AuthField(
                          labelText: 'Confirm Password',
                          controller: confirmpassController,
                          isPasswordText: _confirmsecureText,
                          icon: Icons.key,
                          suffixIcon: confirmpassController.text.isNotEmpty
                          ? IconButton(
                            icon: Icon(_confirmsecureText
                                ? Icons.visibility
                                : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _confirmsecureText = !_confirmsecureText;
                              });
                            },
                          )
                            : null,
                        ),
                        if (_showPasswordInstructions) ...[
                          const SizedBox(height: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: PasswordStrength.buildInstructionChecklist(passwordController.text),
                          ),
                        ],
                        if (_passwordStrength != null) ... [
                          const SizedBox(height:10),
                          Row(
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds:300),
                                height: 8,
                                width: 300 * _passwordStrength!.widthPerc,
                                decoration: BoxDecoration(
                                  color: _passwordStrength!.statusColor,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                              const SizedBox(width:2),
                              _passwordStrength!.statusWidget ?? const SizedBox(),
                            ],
                          )
                        ],
                        SizedBox(height: 10,),
                        ElevatedButton(
                          onPressed: () async{
                            setState(() {
                              circular = true;
                            });
                            if(passwordController.text == confirmpassController.text){
                              if(formKey.currentState!.validate()){
                                try{
                                  UserCredential userCredential = await firebaseAuth.createUserWithEmailAndPassword(
                                      email: emailController.text, password: passwordController.text);

                                  String fullName = '${firstNameController.text} ${lastNameController.text}';

                                  await userCredential.user?.updateDisplayName(fullName);


                                  await firebaseStore
                                      .collection('users')
                                      .doc(userCredential.user!.uid)
                                      .set({
                                    'Name': fullName,
                                    'Email': emailController.text,
                                    'Photo': userCredential.user?.photoURL ?? '',
                                    'created_at': DateTime.now(),
                                  });

                                  String defaultPhotoUrl = userCredential.user?.photoURL ??
                                      'https://ui-avatars.com/api/?name=${Uri.encodeComponent(fullName)}';

                                  Get.offAll(() => Home(
                                    uid: userCredential.user!.uid,
                                    name: fullName,
                                    email: emailController.text,
                                    photoUrl: defaultPhotoUrl,
                                  ));
                                  circular = false;
                                }catch (e){
                                  final snackBar = SnackBar(content: Text(e.toString()));
                                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                  setState(() {
                                    circular = false;
                                  });
                                }
                              }
                            } else{
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Passwords do not match')),
                              );
                              setState(() {
                                circular = false;
                              });
                              return;
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            fixedSize: Size(410, 55),
                          ),
                          child: circular ? CircularProgressIndicator() :
                          Text('Sign Up',
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

                              final userRef = firebaseStore.collection('users').doc(user.uid);
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
                                Text('Sign Up with Google'),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
          padding: EdgeInsets.fromLTRB(80, 25, 25, 25),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context, SignIn.route()
              );
            },
            child: RichText(
                text: TextSpan(
                    text: ("Already have an account? "),
                    style: Theme.of(context).textTheme.titleMedium,
                    children: [
                      TextSpan(
                          text: 'Sign In',
                          style:Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          )
                      )
                    ]
                )
            ),
          )
      ),
    );
  }
}
