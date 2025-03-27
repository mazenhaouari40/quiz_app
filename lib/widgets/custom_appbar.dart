import 'package:flutter/material.dart';
import '/services/auth.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onSignOut;

  const CustomAppBar({
    super.key,
    required this.title,
    this.onSignOut,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor:  Colors.white, // Set background color to white
      elevation: 2, // Optional: Adds a slight shadow
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.black, // Set text color to black for contrast
          fontWeight: FontWeight.w500, // Optional: Make it slightly bold
        ),
      ),
      iconTheme: const IconThemeData(color: Colors.black), // Set icon color to black
      actions: [
        IconButton(
          icon: const Icon(Icons.logout),
          tooltip: 'Sign Out',
          onPressed: onSignOut ?? () => Auth().signOut(),
        ),
      ],
    );
  }
}
