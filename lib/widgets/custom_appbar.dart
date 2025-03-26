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
      title: Text(
        title,
        style: const TextStyle(color: Color.fromARGB(255, 7, 7, 7)),
      ),
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