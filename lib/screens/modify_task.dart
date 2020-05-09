import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:taskify/components/basic_date_field.dart';
import 'package:taskify/components/basic_time_field.dart';
import 'package:taskify/components/textfield.dart';
import 'package:taskify/components/toast_message.dart';
import 'package:taskify/model/task_model.dart';
import 'package:taskify/screens/home_screen.dart';
import 'package:taskify/services/network_services.dart';

class ModifyTask extends StatefulWidget {
  final String taskID;

  ModifyTask({this.taskID});

  @override
  _ModifyTaskState createState() => _ModifyTaskState();
}

class _ModifyTaskState extends State<ModifyTask> {
  bool get isEditing => widget.taskID != null;

  Task task;

  final _formKey = GlobalKey<FormState>();

  NetworkServices services = NetworkServices();

  TextEditingController _titleController = TextEditingController();
  TextEditingController _dateController = TextEditingController();
  TextEditingController _startTimeController = TextEditingController();
  TextEditingController _endTimeController = TextEditingController();
  TextEditingController _venueController = TextEditingController();

  bool _isLoading = false;

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

  void _addTask() async {
    var data = {
      'title': _titleController.text,
      'date': _dateController.text,
      'start_time': _startTimeController.text,
      'end_time': _endTimeController.text,
      'venue': _venueController.text
    };

    setState(() {
      _isLoading = true;
    });

    await services.addTasks('tasks', data);

    setState(() {
      _isLoading = false;
    });

    Navigator.push(
        context, MaterialPageRoute(builder: (context) => HomeScreen()));
  }

  @override
  void initState() {
    super.initState();
    checkConnectivity();
    _showTask();
  }

  void _showTask() async {
    if (isEditing) {
      setState(() {
        _isLoading = true;
      });

      var response = await services.showTask('tasks', widget.taskID);

      task = response;

      setState(() {
        _isLoading = false;
      });

      _titleController.text = task.title;
      _dateController.text = task.date;
      _startTimeController.text = task.startTime;
      _endTimeController.text = task.endTime;
      _venueController.text = task.venue;
    }
  }

  void _updateTask(String taskID) async {
    setState(() {
      _isLoading = true;
    });

    var data = {
      'title': _titleController.text,
      'date': _dateController.text,
      'start_time': _startTimeController.text,
      'end_time': _endTimeController.text,
      'venue': _venueController.text
    };

    await services.updateTask(data, taskID);

    setState(() {
      _isLoading = false;
    });

    Navigator.push(
        context, MaterialPageRoute(builder: (context) => HomeScreen()));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _dateController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    _venueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Task' : 'Add Task',
          style: TextStyle(fontSize: 20.0, color: Colors.black),
        ),
//        leading: Icon(Icons.arrow_back_ios),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
//        actions: <Widget>[Icon(Icons.more_vert)],
        elevation: 2.0,
      ),
      body: ModalProgressHUD(
        inAsyncCall: _isLoading,
        child: Form(
          key: _formKey,
          child: _isLoading
              ? Center(child: CircularProgressIndicator())
              : ListView(
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
                  children: <Widget>[
                    TextFieldWidget(
                      hint: 'Title',
                      controller: _titleController,
                      validator: (input) {
                        if (input.isEmpty) {
                          return 'Title is required!';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 15.0),
                    BasicDateField(
                      hint: 'Date',
                      controller: _dateController,
                      validator: (dateTime) {
                        if (isEditing) {
                          if (dateTime == '') {
                            return 'Date is required!';
                          }
                        } else {
                          if (dateTime == null) {
                            return 'Date is required!';
                          }
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 15.0),
                    Row(
                      children: <Widget>[
                        BasicTimeField(
                          hint: 'StartTime',
                          controller: _startTimeController,
                          validator: (dateTime) {
                            if (isEditing) {
                              if (dateTime == '') {
                                return 'Start Time is required!';
                              }
                            } else {
                              if (dateTime == null) {
                                return 'Start Time is required!';
                              }
                            }
                            return null;
                          },
                        ),
                        SizedBox(width: 10.0),
                        BasicTimeField(
                          hint: 'Stop Time',
                          controller: _endTimeController,
                          validator: (dateTime) {
                            if (isEditing) {
                              if (dateTime == '') {
                                return 'Stop Time is required!';
                              }
                            } else {
                              if (dateTime == null) {
                                return 'Stop Time is required!';
                              }
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 15.0),
                    TextFieldWidget(
                      hint: 'Location',
                      controller: _venueController,
                      validator: (input) {
                        if (input.isEmpty) {
                          return 'Location is required!';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 30.0),
                    ButtonTheme(
                      minWidth: double.infinity,
                      height: 40.0,
                      child: new FlatButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(18.0),
                        ),
                        onPressed: () async {
                          FocusScope.of(context).requestFocus(new FocusNode());

                          if (isEditing) {
                            // Update Task
                            if (_formKey.currentState.validate()) {
                              // If the form is valid, display a Toast.
                              if (networkState == 'none') {
                                _isLoading = false;
                                ToastMessage.toast('No Internet Connection!');
                                return;
                              }
                              ToastMessage.toast('Updating Task...');
                              _updateTask(widget.taskID);
                            }
                          } else {
                            // Add Task
                            if (_formKey.currentState.validate()) {
                              // If the form is valid, display a Toast.
                              if (networkState == 'none') {
                                _isLoading = false;
                                ToastMessage.toast('No Internet Connection!');
                                return;
                              }
                              ToastMessage.toast('Adding Task...');
                              _addTask();
                            }
                          }

                          // Validate returns true if the form is valid, or false
                          // otherwise.
                        },
                        color: Colors.green,
                        child: Text(
                          isEditing ? 'Update Task' : 'Add Task',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.0,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.0),
                  ],
                ),
        ),
      ),
    );
  }
}
