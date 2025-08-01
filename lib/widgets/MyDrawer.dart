import 'package:chat_app/Screen/AppScreen/Settings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class myDrawer extends StatelessWidget {
  final String Image;
  final String name;
  final String email;
  const myDrawer({super.key, required this.Image, required this.name, required this.email});

  @override
  Widget build(BuildContext context) {
    return Drawer(

        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              color: Colors.blue.shade700,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top,
              ),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 52,
                      backgroundImage: NetworkImage(Image),
                    ),
                    SizedBox(height: 10,),
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 25, color: Colors.white,
                      )
                    ),
                  ],
                ),
              )
            ),
            Expanded(
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.home),
                    title: Text('H O M E'),
                    onTap: (){
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.settings),
                    title: Text('S E T T I N G S'),
                    onTap: (){
                      Navigator.pop(context);
                      Get.offAll(() => SettingsPage(
                        name: name,
                        email: email,
                        photoUrl: Image,
                      ));
                    },
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('L O G O U T'),
              onTap: () {

              },
            )
          ],
        ),
    );
  }
}
