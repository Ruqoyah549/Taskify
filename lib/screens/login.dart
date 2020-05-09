import 'dart:async';
import 'dart:convert';

import 'package:connectivity/connectivity.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taskify/components/rounded_button.dart';
import 'package:taskify/components/toast_message.dart';
import 'package:taskify/constants.dart';
import 'package:taskify/screens/home_screen.dart';
import 'package:taskify/services/network_services.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool _isLoading = false;
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  Connectivity connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> subscription;
  String networkState;

  void checkConnectivity() async {
    // subscribe to connectivity change
    subscription =
        connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      var conn = getConnectionValue(result);
      setState(() {
        networkState = conn;
      });
    });
  }

  // Method to convert connectivity to a string value;
  String getConnectionValue(var connectivityResult) {
    String status = '';
    switch (connectivityResult) {
      case ConnectivityResult.mobile:
        status = 'mobile';
        break;
      case ConnectivityResult.wifi:
        status = 'wifi';
        break;
      case ConnectivityResult.none:
        status = 'none';
        break;
      default:
        status = 'none';
        break;
    }
    return status;
  }

  void _login() async {
    setState(() {
      _isLoading = true;
    });

    var data = {
      'email': _emailController.text,
      'password': _passwordController.text
    };

    var res = await NetworkServices().postData(data, 'login');
    var body = json.decode(res.body);
    if (body['success'] == 'true') {
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      localStorage.setString('token', body['access_token']);
      localStorage.setString('user', json.encode(body['user']));
      print('LoginScreen-->> Registered User: ${body['user']}');
      print('LoginScreen-->> User\'s Token: ${body['access_token']}');

//      Navigator.pushReplacementNamed(context, '/home');
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (BuildContext context) => HomeScreen()));

//      Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen()));
    } else {
      print(body['message']);
      ToastMessage.toast(body['message']);
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    checkConnectivity();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: _isLoading,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Flexible(
                  child: Hero(
                    tag: 'logo',
                    child: Container(
                      height: 50.0,
                      child: Image.asset('assets/images/logo.png'),
                    ),
                  ),
                ),
                SizedBox(
                  height: 48.0,
                ),
                TextFormField(
                  controller: _emailController,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.emailAddress,
                  decoration: kTextFieldDecoration.copyWith(
                    hintText: 'Enter your email.',
                  ),
                  validator: (email) {
                    if (email.isEmpty) {
                      return 'Please enter your email address';
                    }
                    if (!EmailValidator.validate(email)) {
                      return 'Invalid email address';
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: 8.0,
                ),
                TextFormField(
                  controller: _passwordController,
                  textAlign: TextAlign.center,
                  obscureText: true,
                  decoration: kTextFieldDecoration.copyWith(
                    hintText: 'Enter your password.',
                  ),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: 24.0,
                ),
                RoundedButton(
                  title: _isLoading ? 'Logging in...' : 'Login',
                  color: Colors.lightBlueAccent,
                  onPressed: () async {
                    FocusScope.of(context).requestFocus(new FocusNode());
                    // Validate returns true if the form is valid, or false
                    // otherwise.

                    if (_formKey.currentState.validate()) {
                      // If the form is valid, display a Snackbar.

                      if (networkState == 'none') {
                        _isLoading = false;
                        ToastMessage.toast('No Internet Connection!');
                        return;
                      }

                      ToastMessage.toast('Processing data');
                      _login();
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
