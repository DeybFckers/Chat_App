import 'package:flutter/material.dart';

// A custom widget to represent a user tile with a tap action
class UserTile extends StatelessWidget {
  // The text to display (usually a username or user info)
  final String text;
  final String Image;

  // A function to call when the tile is tapped
  final void Function()? onTap;

  // Constructor with required parameters
  const UserTile({
    super.key,
    required this.text,
    required this.onTap,
    required this.Image,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Triggers the onTap function when the widget is tapped
      onTap: onTap,

      // The visible part of the tile
      child: Container(
        // Styling the container
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12), // Rounded corners
        ),

        // Padding inside the tile
        padding: EdgeInsets.all(25),

        // Horizontal layout (icon + text)
        child: Row(
          children: [
            // Person icon at the start
            CircleAvatar(
              radius: 14,
              backgroundImage: NetworkImage(Image),
            ),

            // Small horizontal space between the icon and the text
            SizedBox(width: 10),

            // The user-provided text
            Text(text),
          ],
        ),
      ),
    );
  }
}
