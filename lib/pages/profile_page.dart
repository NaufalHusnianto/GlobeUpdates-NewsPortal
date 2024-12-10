import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:globeupdates/auth.dart';
import 'package:globeupdates/layouts/global_layout.dart';
import 'package:globeupdates/pages/login_register_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _fullnameController = TextEditingController();
  final _usernameController = TextEditingController();
  bool _isEditing = false;

  final user = FirebaseAuth.instance.currentUser;

  String getInitials(String? displayName) {
    if (displayName == null || displayName.isEmpty) {
      return "NN";
    }
    final parts = displayName.split(' ');
    return parts
        .map((e) => e.isNotEmpty ? e[0] : '')
        .take(2)
        .join()
        .toUpperCase();
  }

  Future<void> _updateProfile() async {
    try {
      // Ambil input dari controller
      final fullname = _fullnameController.text.trim();
      final username = _usernameController.text.trim();

      if (fullname.isNotEmpty || username.isNotEmpty) {
        await user?.updateDisplayName(fullname);
        await user?.reload(); // Reload user data dari Firebase
        setState(() {
          _isEditing = false; // Kembali ke mode non-edit
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _fullnameController.text = user?.displayName ?? '';
    // Username dapat disimpan di custom claims atau Firestore jika perlu.
    _usernameController.text = ''; // Tambahkan jika menggunakan field username.
  }

  @override
  Widget build(BuildContext context) {
    return GlobalLayout(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar pengguna
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.cyan,
              backgroundImage:
                  user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
              child: user?.photoURL == null
                  ? Text(
                      getInitials(user?.displayName),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: 20),

            // Mode tampilan atau edit
            if (_isEditing)
              Column(
                children: [
                  TextField(
                    controller: _fullnameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: _updateProfile,
                        child: const Text('Save'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _isEditing = false;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                        ),
                        child: const Text('Cancel'),
                      ),
                    ],
                  ),
                ],
              )
            else
              Column(
                children: [
                  // Nama pengguna
                  Text(
                    user?.displayName ?? 'No Name',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Email pengguna
                  Text(
                    user?.email ?? 'No Email',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Tombol Edit Profile
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isEditing = true;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyan[800],
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Edit Profile'),
                  ),
                ],
              ),

            const SizedBox(height: 16),

            // Tombol Logout
            ElevatedButton(
              onPressed: () async {
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
              // onPressed: () {
              //   print(FirebaseAuth.instance.currentUser);
              // },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
