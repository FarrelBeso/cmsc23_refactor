import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_refactor/model/response_model.dart';
import 'package:todo_refactor/provider/auth_provider.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();

  final emailcontroller = TextEditingController();
  final passwordcontroller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            child: TextFormField(
              controller: emailcontroller,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'First input your email';
                }
                return null;
              },
              decoration: InputDecoration(
                hintText: 'Email',
                contentPadding: const EdgeInsets.all(20),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(40)),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            child: TextFormField(
              controller: passwordcontroller,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'First input your password';
                }
                return null;
              },
              obscureText: true,
              decoration: InputDecoration(
                  hintText: 'Password',
                  contentPadding: const EdgeInsets.all(20),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(40))),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  ResponseModel response =
                      await Provider.of<AuthProvider>(context, listen: false)
                          .login(emailcontroller.text, passwordcontroller.text);
                  if (context.mounted) {
                    // ScaffoldMessenger.of(context).showSnackBar(
                    //     SnackBar(content: Text(response.message!)));
                    print(response.message);
                  }
                }
              },
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  'LOGIN',
                  style: TextStyle(fontSize: 20),
                ),
              )),
        ],
      ),
    );
  }
}
