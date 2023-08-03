import 'package:flutter/material.dart';
import 'package:todo_refactor/views/authentication/login_view.dart';
import 'package:todo_refactor/views/authentication/signup_view.dart';

class AuthView extends StatefulWidget {
  const AuthView({super.key});

  @override
  State<AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends State<AuthView> {
  bool isLogin = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(60),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // login or signup form?
            formWidget(),
            loginSignupButton()
          ],
        ),
      ),
    );
  }

  Widget formWidget() {
    return isLogin ? const LoginView() : const SignupView();
  }

  // components
  Widget loginSignupButton() {
    return TextButton(
        onPressed: () {
          setState(() {
            isLogin = !isLogin;
          });
        },
        child: Text(
          isLogin ? 'Create new account' : 'Back to Login',
          style: TextStyle(decoration: TextDecoration.underline),
        ));
  }
}
