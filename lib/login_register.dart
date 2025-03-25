import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quiz_app/widgets/GoogleSignIn.dart';
import 'package:quiz_app/widgets/join_quiz_widget.dart';
import 'services/auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? errorMessage = '';
  bool isLogin = true;

  final TextEditingController _controllerFullname = TextEditingController();

  final TextEditingController _controllerEmail = TextEditingController();

  final TextEditingController _controllerPassword = TextEditingController();

  Future<void> signInWithEmailAndPassword() async {
    try {
      await Auth().signInWithEmailAndPassword(
        email: _controllerEmail.text,
        password: _controllerPassword.text,
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
        fullname: _controllerFullname.text,
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  Widget _title() {
    return Text(
      isLogin ? 'Log in to your account' : 'Create a free account',
      style: TextStyle(
        fontSize: 22, // Bigger text size
        fontWeight: FontWeight.bold, // Bold text
        color: Colors.black, // Optional: Adjust color if needed
      ),
      textAlign: TextAlign.center, // Centers the text
    );
  }

  Widget _entryField(String title, TextEditingController controller) {
    return TextField(
      controller: controller,
      obscureText: title.toLowerCase() == "password" ? true : false,
      decoration: customInputDecoration(title: title),
    );
  }

  Widget _errorMessage() {
    return Text(errorMessage == '' ? '' : '$errorMessage');
  }

  Widget _submitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed:
            isLogin
                ? signInWithEmailAndPassword
                : createUserWithEmailAndPassword,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        child: Text(
          isLogin ? 'Login' : 'Register',
          style: const TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
    );
  }

  Widget _loginOrRegisterButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center, // Center the content
      children: [
        Text(
          isLogin ? "Don't have an account? " : "Already have an account? ",
          style: TextStyle(
            fontSize: 16,
            color: Colors.black,
          ), // Adjust text style
        ),
        TextButton(
          onPressed: () {
            setState(() {
              isLogin = !isLogin;
            });
          },
          child: Text(
            isLogin ? "Register" : "Login",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ), // Make it bold
          ),
        ),
      ],
    );
  }

  InputDecoration customInputDecoration({
    required String title,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: title,
      labelStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.black, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey, width: 1),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.red, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.red, width: 1.5),
      ),
      filled: true,
      fillColor: Colors.white, // Keeps the background clean
      contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      suffixIcon: suffixIcon,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: <Widget>[
            // JoinQuizWidget at the top
            Align(alignment: Alignment.topCenter, child: JoinQuizWidget()),
            // Center the rest of the widgets
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Ensures content is centered
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    _title(),
                    SizedBox(height: 16),
                    GoogleSignInButton(onPressed: () {}),
                    SizedBox(height: 16),
                    Text(
                      ' -or use - ',
                      style: TextStyle(
                        fontSize: 18,
                        color: const Color.fromARGB(255, 68, 87, 103),
                      ),
                    ),
                    SizedBox(height: 16),
                    if (!isLogin) _entryField('Full name', _controllerFullname),
                    SizedBox(height: 16),
                    _entryField('Email', _controllerEmail),
                    SizedBox(height: 16),

                    _entryField('Password', _controllerPassword),
                    SizedBox(height: 16),
                    _errorMessage(),
                    SizedBox(height: 16.0),
                    _submitButton(),
                    SizedBox(height: 20.0),
                    _loginOrRegisterButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
