import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:globeupdates/auth.dart';
import 'home_screen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? errorMessage = '';
  bool isLogin = true;

  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();

  final TextEditingController _controllerFullName = TextEditingController();
  final TextEditingController _controllerUsername = TextEditingController();

  Future<void> signInWithEmailAndPassword() async {
    try {
      await Auth().signInWithEmailAndPassword(
          email: _controllerEmail.text, password: _controllerPassword.text);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  Future<void> createUserWithEmailAndPassword() async {
    try {
      await Auth().createUserWithEmailAndPassword(
        email: _controllerEmail.text,
        password: _controllerPassword.text,
      );

      await FirebaseAuth.instance.currentUser?.updateDisplayName(
        _controllerFullName.text,
      );

      final user = FirebaseAuth.instance.currentUser;
      await FirebaseFirestore.instance.collection('users').doc(user?.uid).set({
        'uid': user?.uid,
        'fullname': _controllerFullName.text,
        'username': _controllerUsername.text,
        'email': _controllerEmail.text,
        'createdAt': DateTime.now(),
      });

      // Periksa apakah widget masih mounted sebelum navigasi
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = e.message;
        });
      }
    }
  }

  Widget _title() {
    return Row(
      children: [
        Image.asset(
          'assets/logo.png',
          height: 30,
        ),
        const SizedBox(width: 10),
        const Text(
          'GlobeUpdates',
          style: TextStyle(
            color: Colors.cyan,
            shadows: [
              Shadow(
                blurRadius: 10.0,
                color: Colors.cyan,
                offset: Offset(0, 0),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _entryField(
      String title, TextEditingController controller, bool password) {
    return TextField(
      obscureText: password,
      controller: controller,
      decoration: InputDecoration(
        labelText: title,
        border: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.cyan),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.cyan, width: 2.0),
        ),
        labelStyle: const TextStyle(color: Colors.white),
      ),
      cursorColor: Colors.cyan,
    );
  }

  Widget _errorMessage() {
    if (errorMessage == null || errorMessage!.isEmpty) {
      return const SizedBox.shrink();
    } else if (_controllerEmail.text.isEmpty ||
        _controllerPassword.text.isEmpty) {
      return const Text(
        "All fields must be filled",
        style: TextStyle(color: Colors.red),
      );
    } else {
      return const Text(
        "Invalid email or password",
        style: TextStyle(color: Colors.red),
      );
    }
  }

  Widget _registerFields() {
    return Column(
      children: [
        _entryField('Fullname', _controllerFullName, false),
        const SizedBox(height: 10),
        _entryField('Username', _controllerUsername, false),
      ],
    );
  }

  Widget _submitButton() {
    return ElevatedButton(
      onPressed:
          isLogin ? signInWithEmailAndPassword : createUserWithEmailAndPassword,
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
          side: const BorderSide(color: Colors.cyan),
        ),
        backgroundColor: Colors.cyan.shade800,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(40),
      ),
      child: Text(
        isLogin ? 'Login' : 'Register',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _appLogos() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 50),
      child: SizedBox(
        width: 250,
        height: 250,
        child: Image.asset(
          isLogin ? 'assets/login.png' : 'assets/register.png',
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _loginOrRegisterButton() {
    return TextButton(
      onPressed: () {
        setState(() {
          isLogin = !isLogin;
        });
      },
      child: Text(
        isLogin ? 'Register' : 'Login',
        style: const TextStyle(
          color: Colors.cyan,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _title(),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height - 100,
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _appLogos(),
              if (!isLogin) _registerFields(),
              const SizedBox(height: 10),
              _entryField('Email', _controllerEmail, false),
              const SizedBox(height: 10),
              _entryField('Password', _controllerPassword, true),
              const SizedBox(height: 10),
              _errorMessage(),
              const SizedBox(height: 15),
              _submitButton(),
              _loginOrRegisterButton(),
            ],
          ),
        ),
      ),
    );
  }
}
