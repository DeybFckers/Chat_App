import 'package:chat_app/Screen/SettingsScreen/Email.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/widgets/MyDrawer.dart';


class SettingsPage extends StatelessWidget {
  final String photoUrl;
  final String name;
  final String email;
  SettingsPage({super.key, required this.photoUrl, required this.name, required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings',
          style: TextStyle(
            fontSize: 25, fontWeight: FontWeight.bold,
            color: Colors.white,
            ),
          ),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      drawer: myDrawer(Image: photoUrl, name: name, email: email),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 120, 20, 20),
          child: Column(
            children: [
              Center( // Center avatar only
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 52,
                      backgroundImage: NetworkImage(photoUrl),
                    ),
                    SizedBox(height: 10,),
                    Text('$name',
                      style: TextStyle(
                        fontSize: 25,
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(height: 50,),
              Container(
                padding: const EdgeInsets.only(bottom: 10, top: 10),
                width: double.infinity,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(width: 2)
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: (){
                        Navigator.push(
                          context, MaterialPageRoute(
                            builder: (context) => EmailScreen()
                          )
                        );
                      },
                      child:Container(
                        width: double.infinity,
                        child: Text('Email',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                    Divider(
                      thickness: 1.5,
                      color: Colors.grey[400],
                    ),
                    InkWell(
                      onTap: (){
                        print('Name');
                      },
                      child:Container(
                        width: double.infinity,
                        child: Text('Name',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                    Divider(
                      thickness: 1.5,
                      color: Colors.grey[400],
                    ),
                    InkWell(
                      onTap: (){
                        print('Profile Picture');
                      },
                      child:Container(
                        width: double.infinity,
                        child: Text('Profile Picture',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      )
    );
  }
}
