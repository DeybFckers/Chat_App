import 'package:chat_app/services/ChatSettings.dart';
import 'package:flutter/material.dart';


class EmailScreen extends StatefulWidget {
  const EmailScreen({super.key});

  @override
  State<EmailScreen> createState() => _EmailScreenState();
}

class _EmailScreenState extends State<EmailScreen> {
  final formKey = GlobalKey<FormState>();
  final newEmailController = TextEditingController();
  final confirmEmailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isPasswordText = true;
  final chatSettings = ChatSettings();

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
                            chatSettings.changeEmail(
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
