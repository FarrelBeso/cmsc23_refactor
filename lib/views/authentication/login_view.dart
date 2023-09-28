import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

  // on the state of being submitted
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(8),
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
                  contentPadding: EdgeInsets.all(20),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(40)),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(8),
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
                    contentPadding: EdgeInsets.all(20),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(40))),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            ElevatedButton(
                onPressed: () async {
                  if (!_isSubmitting) await _loginButtonAction();
                },
                child: SizedBox(
                  width: 100,
                  height: 50,
                  child: Center(
                    child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: _isSubmitting
                            ? _loadingWidget()
                            : _defaultContent()),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Future<void> _loginButtonAction() async {
    setState(() {
      _isSubmitting = true;
    });

    if (_formKey.currentState!.validate()) {
      await Provider.of<AuthProvider>(context, listen: false)
          .login(emailcontroller.text, passwordcontroller.text);
    } else {
      setState(() {
        _isSubmitting = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Login Failed.')));
    }
  }

  Widget _defaultContent() {
    return const Text(
      'LOGIN',
      style: TextStyle(fontSize: 20),
    );
  }

  Widget _loadingWidget() {
    return const SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(),
    );
  }
}
