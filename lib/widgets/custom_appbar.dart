import 'package:flutter/material.dart';
import '/services/auth.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onSignOut;

  const CustomAppBar({
    super.key,
    required this.title,
    this.onSignOut,
    required Color backgroundColor,
    required int elevation,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,

      title: Text(
        title,
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w500,
        ),
      ),
      iconTheme: const IconThemeData(
        color: Colors.black,
      ), // Set icon color to black
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
