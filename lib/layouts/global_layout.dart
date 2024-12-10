import 'package:flutter/material.dart';
import 'package:globeupdates/components/custom_app_bar.dart';
import 'package:globeupdates/pages/profile_page.dart';
import 'package:globeupdates/theme/theme.dart';
import 'package:globeupdates/auth.dart';
import 'package:globeupdates/pages/home_screen.dart';
import 'package:globeupdates/pages/bookmark_page.dart';
import 'package:globeupdates/pages/login_register_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GlobalLayout extends StatelessWidget {
  final Widget child;
  final List<String> bookmarkedArticles = [];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  GlobalLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        onMenuTap: () {
          _scaffoldKey.currentState?.openDrawer();
        },
      ),
      drawer: Drawer(
        backgroundColor: AppTheme.darkTheme.scaffoldBackgroundColor,
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.cyan[900],
              ),
              child: Column(
                children: [
                  const Text(
                    'GlobeUpdates',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      shadows: [
                        Shadow(
                          blurRadius: 10.0,
                          color: Colors.white,
                          offset: Offset(0, 0),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.grey[800],
                    backgroundImage:
                        FirebaseAuth.instance.currentUser?.photoURL != null
                            ? NetworkImage(
                                FirebaseAuth.instance.currentUser!.photoURL!)
                            : null,
                    child: FirebaseAuth.instance.currentUser?.photoURL == null
                        ? Text(
                            (FirebaseAuth.instance.currentUser?.displayName ??
                                    'NN')
                                .split(' ')
                                .map((e) => e.isNotEmpty ? e[0] : '')
                                .take(2)
                                .join()
                                .toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 0.0),
                    child: Column(
                      children: [
                        Text(
                          FirebaseAuth.instance.currentUser?.displayName ??
                              'No Name',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          FirebaseAuth.instance.currentUser?.email ??
                              'No Email',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                );
              },
              child: const ListTile(
                leading: Icon(Icons.home),
                title: Text('Home'),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BookmarkPage(),
                  ),
                );
              },
              child: const ListTile(
                leading: Icon(Icons.bookmark_add_rounded),
                title: Text('Bookmark'),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfilePage(),
                  ),
                );
              },
              child: const ListTile(
                leading: Icon(Icons.person),
                title: Text('Profile'),
              ),
            ),
            const Divider(),
            GestureDetector(
              onTap: () async {
                final shouldLogout = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Logout'),
                    content: const Text('Are you sure you want to logout?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.cyan,
                        ),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        child: const Text('Logout'),
                      ),
                    ],
                  ),
                );

                if (shouldLogout ?? false) {
                  await Auth().signOut();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                    (route) => false,
                  );
                }
              },
              child: const ListTile(
                leading: Icon(Icons.logout),
                title: Text('Logout'),
              ),
            ),
          ],
        ),
      ),
      body: child,
    );
  }
}
