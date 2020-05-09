import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taskify/screens/home_screen.dart';
import 'package:taskify/screens/welcome.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences locationStorage = await SharedPreferences.getInstance();
  var token = locationStorage.getString('token');

  runApp(
    MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          unselectedWidgetColor: Colors.white,
          primarySwatch: Colors.blue,
        ),
        debugShowCheckedModeBanner: false,
        home: token == null ? WelcomeScreen() : HomeScreen()),
  );
}
