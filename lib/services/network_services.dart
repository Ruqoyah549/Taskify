import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taskify/components/toast_message.dart';
import 'package:taskify/model/task_model.dart';

class NetworkServices {
  final String _url = 'http://api.paavion.com.ng/api/';

  _setHeaders() =>
      {'Content-type': 'application/json', 'Accept': 'application/json'};

  _getToken() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token = localStorage.getString('token');
    return '?token=$token';
  }

  _getTokenAuth() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token = localStorage.getString('token');
    return token;
  }

  postData(data, apiUrl) async {
    var fullUrl = _url + apiUrl + await _getToken();
    return await http.post(fullUrl,
        body: jsonEncode(data), headers: _setHeaders());
  }

  getData(apiUrl) async {
    var fullUrl = _url + apiUrl + await _getToken();
    return await http.get(fullUrl, headers: _setHeaders());
  }

  logout(apiUrl) async {
    String token = await _getTokenAuth();

    var fullUrl = _url + apiUrl;
    return await http.get(fullUrl, headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });
  }

  Future<List> fetchAllTasks(apiUrl) async {
    List tasks = [];
    try {
      String token = await _getTokenAuth();

      var fullUrl = _url + apiUrl;
      var response = await http.get(fullUrl, headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        tasks = data['data'] as List;
      }
      return tasks;
    } catch (e) {
      print('Error:: $e');
      return tasks;
    }
  }

  addTasks(apiUrl, var data) async {
    try {
      String token = await _getTokenAuth();

      var fullUrl = _url + apiUrl;
      var response = await http.post(
        fullUrl,
        body: jsonEncode(data),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token'
        },
      );
      if (response.statusCode == 201) {
        ToastMessage.toast('Task Added Successfuly!');
      } else {
        ToastMessage.toast('Cannot Add Task!');
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  deleteTask(apiUrl, String taskID) async {
    try {
      String token = await _getTokenAuth();

      var fullUrl = _url + apiUrl + '/' + taskID;
      var response = await http.delete(
        fullUrl,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token'
        },
      );
      if (response.statusCode == 202) {
        ToastMessage.toast('Task Deleted Successfuly!');
      } else {
        ToastMessage.toast('Cannot delete Task!');
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  showTask(apiUrl, String taskID) async {
    try {
      String token = await _getTokenAuth();
      var fullUrl = _url + apiUrl;
      var response = await http.get(
        fullUrl + '/' + taskID,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token'
        },
      );
      Task task;
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        var rest = data["data"];
        task = Task(
            title: rest[0]['title'],
            date: rest[0]['date'],
            startTime: rest[0]['start_time'],
            endTime: rest[0]['end_time'],
            venue: rest[0]['venue']);
        return task;
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  updateTask(var data, String taskID) async {
    try {
      String token = await _getTokenAuth();

      var fullUrl = _url + 'tasks/' + taskID;
      var response = await http.put(
        fullUrl,
        body: jsonEncode(data),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token'
        },
      );
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data['success'] == 'true') {
          ToastMessage.toast('Task Updated Successfuly!');
        }
      } else {
        ToastMessage.toast('Cannot Update Task!');
      }
    } catch (e) {
      ToastMessage.toast('Cannot Update Task!');
      throw Exception(e);
    }
  }
}
