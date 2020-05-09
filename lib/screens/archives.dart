import 'dart:async';
import 'dart:convert';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taskify/model/task_model.dart';
import 'package:taskify/screens/modify_task.dart';
import 'package:taskify/services/network_services.dart';

class Archives extends StatefulWidget {
  @override
  _ArchivesState createState() => _ArchivesState();
}

class _ArchivesState extends State<Archives> {
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

  var userData;
  var token;
  bool _isLoading = false;

  NetworkServices services = NetworkServices();

  List<Task> tasks = [];

  List tasksList = [];

  List todayTaskList = [];

  @override
  void initState() {
    super.initState();
    checkConnectivity();
    _getUserInfo();
    _fetchAllTasks();
    setState(() {
      _isLoading = true;
    });
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
    return Scaffold(
      body: Container(
        margin: EdgeInsets.only(top: 20.0),
        padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 50.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Tasks Archives',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),
            ),
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
                      const Text('No Internet Connection!'),
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
                } else if (tasksList.length == 0) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Center(
                        child: Image(
                          image: AssetImage('assets/images/emoji.png'),
                          width: 150.0,
                          height: 150.0,
                        ),
                      ),
                      const Text('No Task Archives Found!'),
                    ],
                  );
                }
                return GroupedListView<dynamic, String>(
                  groupBy: (task) {
                    return task['date'];
                  },
                  elements: tasksList,
                  order: GroupedListOrder.ASC,
                  useStickyGroupSeparators: false,
                  groupSeparatorBuilder: (String value) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Center(
                        child: Text(
                      value,
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    )),
                  ),
                  itemBuilder: (context, task) => new Container(
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
                      key: Key(task["id"].toString()),
                      direction: DismissDirection.startToEnd,
                      onDismissed: (direction) async {
                        _deleteTask(task["id"].toString());
                      },
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ModifyTask(
                                        taskID: task["id"].toString(),
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        '${task["title"] ?? "Empty"}',
                                        overflow: TextOverflow.ellipsis,
                                        softWrap: false,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontSize: 15.0,
                                        ),
                                      ),
                                      const SizedBox(height: 3.0),
                                      Text(
                                        '${task["start_time"]} - ${task["end_time"]}' ??
                                            'Empty',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 11.0,
                                        ),
                                      ),
                                      const SizedBox(height: 3.0),
                                      Text(
                                        '${task["venue"] ?? "Empty"}',
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
                                const Icon(Icons.person,
                                    color: Colors.white, size: 20.0),
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
    );
  }
}
