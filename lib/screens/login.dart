import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lab_mis/screens/landing.dart';

import 'register.dart';

class SignInScreen extends StatefulWidget {
  static const String idScreen = "signinScreen";

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoginFailed = false;
  bool isPasswordIncorect = false;
  bool isEmailIncorrect = false;
  String errorMessage = "";

  Future _signIn() async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: emailController.text, password: passwordController.text)
          .then((value) {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => HomeScreen()));
      });
    } on FirebaseAuthException catch (e) {
      isLoginFailed = true;
      errorMessage = e.message!;

      if (errorMessage ==
          "There is no user record corresponding to this identifier. The user may have been deleted.") {
        isEmailIncorrect = true;
        errorMessage = "User does not exist, please create an account";
      } else {
        isPasswordIncorect = true;
        errorMessage = "Incorrect password";
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
            alignment: Alignment.center,
            child: Padding(
                padding: EdgeInsets.fromLTRB(
                    20, MediaQuery.of(context).size.height * 0.1, 20, 0),
                child: Column(children: <Widget>[
                  const SizedBox(height: 40),
                  const Text(
                    "Login",
                    style: TextStyle(
                        color: Color.fromARGB(255, 132, 58, 163),
                        fontWeight: FontWeight.bold,
                        fontSize: 30),
                  ),
                  const SizedBox(height: 40),
                  TextField(
                    style: TextStyle(color: Color.fromARGB(255, 132, 58, 163)),
                    controller: emailController,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                        labelText: "Email",
                        hoverColor: Color.fromARGB(255, 132, 58, 163),
                        focusColor: Color.fromARGB(255, 132, 58, 163),
                        fillColor: Color.fromARGB(255, 132, 58, 163),
                        errorText: isEmailIncorrect ? errorMessage : null),
                  ),
                  const SizedBox(height: 40),
                  TextField(
                    controller: passwordController,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                        labelText: "Password",
                        errorText: isPasswordIncorect ? errorMessage : null),
                    obscureText: true,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 132, 58, 163),
                        minimumSize: const Size.fromHeight(50)),
                    icon: const Icon(
                      Icons.lock_open,
                      size: 32,
                    ),
                    label: const Text(
                      "Sign In",
                      style: TextStyle(fontSize: 24),
                    ),
                    onPressed: _signIn,
                  ),
                  const SizedBox(height: 20),
                  signUpOption()
                ]))));
  }

  Row signUpOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Don't have account?"),
        GestureDetector(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => RegisterScreen()));
            },
            child: const Text(
              " Sign Up",
              style: TextStyle(fontWeight: FontWeight.bold),
            )),
      ],
    );
  }
}
