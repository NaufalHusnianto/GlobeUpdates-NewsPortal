import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:globeupdates/theme/theme.dart';
import 'package:globeupdates/pages/profile_page.dart'; // Import halaman ProfilePage

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onMenuTap;

  const CustomAppBar({
    super.key,
    required this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppTheme.darkTheme.appBarTheme.backgroundColor,
      automaticallyImplyLeading: false,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: onMenuTap,
          ),
          Expanded(
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.cyanAccent.withOpacity(0.3),
                      blurRadius: 15.0,
                      spreadRadius: 1.0,
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/logo.png',
                  height: 30,
                ),
              ),
            ),
          ),
          InkWell(
            onTap: () {
              // Navigasi ke ProfilePage
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            },
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Colors.cyan[800],
              backgroundImage: FirebaseAuth.instance.currentUser?.photoURL !=
                      null
                  ? NetworkImage(FirebaseAuth.instance.currentUser!.photoURL!)
                  : null,
              child: FirebaseAuth.instance.currentUser?.photoURL == null
                  ? Text(
                      (FirebaseAuth.instance.currentUser?.displayName ?? 'NN')
                          .split(' ')
                          .map((e) => e.isNotEmpty ? e[0] : '')
                          .take(2)
                          .join()
                          .toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
