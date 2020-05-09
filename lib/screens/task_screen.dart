import 'dart:async';
import 'dart:convert';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taskify/components/header.dart';
import 'package:taskify/components/toast_message.dart';
import 'package:taskify/screens/modify_task.dart';
import 'package:taskify/screens/welcome.dart';
import 'package:taskify/services/network_services.dart';

class TaskScreen extends StatefulWidget {
  @override
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
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

  String todayDate = DateFormat("MMMM d, yyyy").format(new DateTime.now());

  String greeting() {
    var hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning,';
    }
    if (hour < 17) {
      return 'Good afternoon,';
    }
    return 'Good evening,';
  }

  var userData;
  var token;
  bool _isLoading = false;
  bool _logoutLoading = false;

  NetworkServices services = NetworkServices();

  List tasksList = [];

  List todayTaskList = [];

  @override
  void initState() {
    super.initState();
    checkConnectivity();
    _getUserInfo();
    _fetchAllTasks();
  }

  _logout() async {
    if (networkState == 'none') {
      ToastMessage.toast('No Internet Connection!');
      return;
    }
    setState(() {
      _logoutLoading = true;
    });
    // logout from the server ...
    var res = await services.logout('logout');
    var body = json.decode(res.body);
    SharedPreferences localStorage = await SharedPreferences.getInstance();

    if (body['success'] == 'true') {
      localStorage.remove('user');
      localStorage.remove('token');

      setState(() {
        _logoutLoading = false;
      });

      ToastMessage.toast('Successfully Logout');
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => WelcomeScreen()));
    }
  }

  _fetchAllTasks() async {
    setState(() {
      _isLoading = true;
    });
    tasksList = await services.fetchAllTasks('tasks');
    setState(() {
      _isLoading = false;
    });
  }

  _deleteTask(String id) async {
    await services.deleteTask('tasks', id);
    setState(() {
      _fetchAllTasks();
    });
  }

  void _getUserInfo() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var userJson = localStorage.getString('user');
    var t = localStorage.getString('token');
    var user = json.decode(userJson);
    setState(() {
      userData = user;
      token = t;
    });
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      todayTaskList = tasksList
          .where(
              (x) => x['date'].toLowerCase().contains(todayDate.toLowerCase()))
          .toList();
    });
//    print('Today\'s Tasks List = $todayTaskList');
    return Scaffold(
      body: ModalProgressHUD(
        inAsyncCall: _logoutLoading,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 50.0),
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(greeting(),
                          style: TextStyle(
                              fontSize: 30.0, fontWeight: FontWeight.bold)),
                      Text(userData != null ? '${userData['name']}' : 'User',
                          style: TextStyle(
                              fontSize: 30.0, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Column(
                    children: <Widget>[
                      InkWell(
                        onTap: _logout,
                        child: const Icon(
                          Icons.person,
                          color: Colors.blueAccent,
                          size: 30.0,
                        ),
                      ),
                      Text('logout'),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 20.0),
              Header(
                  header: 'You have ${todayTaskList.length} Tasks Today',
                  date: DateFormat("EEEE, MMMM d").format(new DateTime.now())),
              Expanded(
                child: Builder(builder: (_) {
                  if (networkState == 'none') {
                    print('Network State = $networkState');
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Image(
                          image: AssetImage('assets/images/logo.png'),
                          width: 200.0,
                          height: 200.0,
                        ),
                        Text('No Internet Connection!'),
                      ],
                    );
                  } else if (_isLoading) {
                    return Center(
                      child: Image(
                        image: AssetImage('assets/images/load.gif'),
                        width: 100.0,
                        height: 100.0,
                      ),
                    );
                  } else if (todayTaskList.length == 0) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Image(
                          image: AssetImage('assets/images/emoji.png'),
                          width: 150.0,
                          height: 150.0,
                        ),
                        Text('No Task Added!'),
                        Text('You can\'t sleep all day!'),
                      ],
                    );
                  }
                  return ListView.builder(
                    itemCount: todayTaskList.length,
                    itemBuilder: (context, index) => new Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(30.0)),
                      ),
                      child: Dismissible(
                        background: Container(
                          color: Colors.redAccent,
                          padding: EdgeInsets.only(left: 16.0),
                          child: Align(
                            child: Icon(Icons.delete),
                            alignment: Alignment.centerLeft,
                          ),
                        ),
                        key: Key(todayTaskList[index]["id"].toString()),
                        direction: DismissDirection.startToEnd,
                        onDismissed: (direction) async {
                          _deleteTask(todayTaskList[index]["id"].toString());
                        },
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ModifyTask(
                                          taskID: todayTaskList[index]["id"]
                                              .toString(),
                                        ))).then((data) {
                              _fetchAllTasks();
                            });
                          },
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            margin: EdgeInsets.only(bottom: 20.0),
                            elevation: 5.0,
                            color: Colors.blueGrey,
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20.0, vertical: 10.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          '${todayTaskList[index]["title"] ?? "Empty"}',
                                          overflow: TextOverflow.ellipsis,
                                          softWrap: false,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            fontSize: 15.0,
                                          ),
                                        ),
                                        SizedBox(height: 3.0),
                                        Text(
                                          '${todayTaskList[index]["start_time"]} - ${todayTaskList[index]["end_time"]}' ??
                                              'Empty',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 11.0,
                                          ),
                                        ),
                                        SizedBox(height: 3.0),
                                        Text(
                                          '${todayTaskList[index]["venue"] ?? "Empty"}',
                                          overflow: TextOverflow.ellipsis,
                                          softWrap: false,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 11.0,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.person,
                                    color: Colors.white,
                                    size: 20.0,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
