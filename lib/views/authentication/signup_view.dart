import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:string_validator/string_validator.dart';
import 'package:todo_refactor/model/response_model.dart';
import 'package:todo_refactor/model/user_model.dart';
import 'package:todo_refactor/utilities/auth_utils.dart';
import 'package:todo_refactor/views/authentication/login_view.dart';

class SignupView extends StatefulWidget {
  const SignupView({super.key});

  @override
  State<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends State<SignupView> {
  // form keys
  final _basicFormKey = GlobalKey<FormState>();
  final _additionalFormKey = GlobalKey<FormState>();
  final _authenticationFormKey = GlobalKey<FormState>();
  // form fields
  final firstnamefield = TextEditingController();
  final lastnamefield = TextEditingController();
  final usernamefield = TextEditingController();
  final birthdayfield = TextEditingController();
  final locationfield = TextEditingController();
  final emailfield = TextEditingController();
  final passwordfield = TextEditingController();
  final confirmfield = TextEditingController();

  int _sectionIndex = 0;
  final int _sectionlength = 3;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stepper(
            currentStep: _sectionIndex,
            onStepCancel: () {
              if ((_sectionIndex > 0)) {
                setState(() {
                  _sectionIndex -= 1;
                });
              }
            },
            onStepContinue: () async {
              if ((_sectionIndex < _sectionlength) &&
                  verifySection(_sectionIndex)) {
                if (_sectionIndex < _sectionlength - 1) {
                  setState(() {
                    _sectionIndex += 1;
                  });
                } else {
                  ResponseModel response = await AuthUtils()
                      .signIn(setNewUser(), passwordfield.text);

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(response.message!)));
                  }
                }
              }
            },
            steps: <Step>[
              Step(title: Text('Basic Info'), content: basicInfoSection()),
              Step(
                  title: Text('Additional Info'),
                  content: additionalInfoSection()),
              Step(
                  title: Text('Authentication'),
                  content: authenticationSection()),
            ]),
      ],
    );
  }

  // verification functions
  bool verifySection(int index) {
    switch (index) {
      case 0:
        return _basicFormKey.currentState!.validate();
      case 1:
        return _additionalFormKey.currentState!.validate();
      case 2:
        return _authenticationFormKey.currentState!.validate();
      default:
        return true;
    }
  }

  // set the user based on the forms
  UserModel setNewUser() {
    return UserModel(
        firstName: firstnamefield.text,
        lastName: lastnamefield.text,
        username: usernamefield.text,
        birthday: DateTime.parse(birthdayfield.text),
        location: locationfield.text,
        email: emailfield.text);
  }

  // the widgets
  Widget basicInfoSection() {
    return Form(
      key: _basicFormKey,
      child: Container(
          child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            child: TextFormField(
              controller: firstnamefield,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'First enter some text';
                } else if (!isAlpha(value)) {
                  return 'Only letters are permitted';
                } else if (value.length > 50) {
                  return 'Inputs are limited to 50 characters';
                }
                return null;
              },
              decoration: InputDecoration(
                hintText: 'First Name',
                contentPadding: EdgeInsets.all(20),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(40)),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(8),
            child: TextFormField(
              controller: lastnamefield,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'First enter some text';
                } else if (!isAlpha(value)) {
                  return 'Only letters are permitted';
                } else if (value.length > 50) {
                  return 'Inputs are limited to 50 characters';
                }
                return null;
              },
              decoration: InputDecoration(
                  hintText: 'Last Name',
                  contentPadding: EdgeInsets.all(20),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(40))),
            ),
          ),
          Container(
            padding: EdgeInsets.all(8),
            child: TextFormField(
              controller: usernamefield,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'First enter some text';
                } else if (!isAlphanumeric(value)) {
                  return 'Letters and numbers only';
                } else if (value.length > 50) {
                  return 'Should be less than 50 chars';
                }
                return null;
              },
              decoration: InputDecoration(
                  hintText: 'Username',
                  contentPadding: EdgeInsets.all(20),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(40))),
            ),
          ),
        ],
      )),
    );
  }

  Widget additionalInfoSection() {
    return Form(
      key: _additionalFormKey,
      child: Container(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              child: TextFormField(
                controller: birthdayfield,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'First enter some text';
                  } else if (!isDate(value)) {
                    return 'Kindly follow the format';
                  } else if (!validRangeDate(value)) {
                    return 'Improper date range';
                  } else if (value.length > 50) {
                    return 'Should be less than 50 chars';
                  }
                  return null;
                },
                decoration: InputDecoration(
                    icon: Icon(Icons.cake),
                    hintText: 'yyyy-mm-dd',
                    contentPadding: EdgeInsets.all(20),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(40))),
              ),
            ),
            Container(
              padding: EdgeInsets.all(8),
              child: TextFormField(
                controller: locationfield,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'First enter some text';
                  } else if (value.length > 100) {
                    return 'Should be less than 100 chars';
                  }
                  return null;
                },
                decoration: InputDecoration(
                    icon: Icon(Icons.place),
                    hintText: 'Place, Country',
                    contentPadding: EdgeInsets.all(20),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(40))),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget authenticationSection() {
    return Form(
      key: _authenticationFormKey,
      child: Container(
          child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            child: TextFormField(
              controller: emailfield,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'First enter some text';
                } else if (!isEmail(value)) {
                  return 'Provide a proper email';
                } else if (value.length > 50) {
                  return 'Should be less than 50 chars';
                }
                return null;
              },
              decoration: InputDecoration(
                hintText: 'Your Email',
                contentPadding: EdgeInsets.all(20),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(40)),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(8),
            child: TextFormField(
              controller: passwordfield,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'First enter some text';
                } else if (value.length < 8) {
                  return 'Must be at least 8 chars long';
                } else if (!RegExp(r'\d').hasMatch(value)) {
                  return 'Must have at least a number';
                } else if (!RegExp(r'[a-z]').hasMatch(value)) {
                  return 'Must have at least a lowerspace character';
                } else if (!RegExp(r'[A-Z]').hasMatch(value)) {
                  return 'Must have at least an uppercase character';
                } else if (!RegExp(r'\W').hasMatch(value)) {
                  return 'Must have at least a special character';
                } else if (value.length > 50) {
                  return 'Should be less than 50 chars';
                }
                return null;
              },
              obscureText: true,
              decoration: InputDecoration(
                  hintText: 'Enter Password',
                  contentPadding: EdgeInsets.all(20),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(40))),
            ),
          ),
          Container(
            padding: EdgeInsets.all(8),
            child: TextFormField(
              controller: confirmfield,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'First enter some text';
                } else if (value != passwordfield.text) {
                  return 'Password does not match';
                }
                return null;
              },
              obscureText: true,
              decoration: InputDecoration(
                  hintText: 'Retype Password',
                  contentPadding: EdgeInsets.all(20),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(40))),
            ),
          ),
        ],
      )),
    );
  }

  // supplementary func to validate if the date is in the given range
  bool validRangeDate(String dateString) {
    // provided that it's in the format yyyy-mm-dd
    List<String> dateToken = dateString.split('-');
    if (dateToken.length != 3) return false;
    int year = int.parse(dateToken[0]);
    int month = int.parse(dateToken[1]);
    int day = int.parse(dateToken[2]);

    if (year > DateTime.now().year || year < (DateTime.now().year - 130))
      return false;
    if (month <= 0 || month > 13) return false;
    if (day <= 0 || day > 31) return false;
    // switch for day and month
    switch (month) {
      case 2:
        if (day > 29) return false;
      case 4:
      case 6:
      case 9:
      case 11:
        if (day > 30) return false;
    }

    return true;
  }
}
