import 'dart:convert';
import 'package:goltens_core/models/forms.dart';
import 'package:http/http.dart' as http;
import '../constants/constants.dart';
import '../models/meeting.dart';

class ApiService {
  Future<void> createMeeting(Meeting meeting) async {
    // Exclude meetingId from the JSON payload
    Map<String, dynamic> meetingJson = meeting.toJson();

    final response = await http.post(
      Uri.parse('$apiUrl/meeting/meet'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(meetingJson),
    );
    print(json.encode(meetingJson));

    if (response.statusCode != 200) {
      throw Exception('Failed to create meeting');
    } else {
      print(json.encode(meetingJson));
    }
  }

  void postData(FormData formData) async {
    final response = await http.post(
      Uri.parse('$apiUrl/forms/createForm'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(formData.toJson()),
    );

    if (response.statusCode == 201) {
      print('POST request successful');
      print('Response: ${response.body}');
    } else {
      print('POST request failed with status: ${response.statusCode}');
      print('Response: ${response.body}');
    }
  }

  Future<void> sendNotification(
      List<int> userlist,
      String title,
      String body,
      String route,
      code,
      String meetingId,
      String meetingTitle,
      String meetingType,
      String hostname,
      String meetingTime) async {
    final response = await http.post(
      Uri.parse('$apiUrl/notifications/sendNotification'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "userIds": userlist,
        "title": title,
        "body": body,
        "route": route,
        "code": "$code",
        "meetingId": meetingId,
        "meetingTitle": meetingTitle,
        "meetingType": meetingType,
        "hostname": hostname,
        "meetingTime": meetingTime
      }),
    );

    if (response.statusCode == 200) {
      print('POST request successful');
      print('Response: ${response.body}');
    } else {
      print('POST request failed with status: ${response.statusCode}');
      print('Response: ${response.body}');
    }
  }

  Future<void> updateMeeting(
      int membersCount, String attId, String meetEndTime, String meetId) async {
    final response = await http.put(
      Uri.parse('$apiUrl/meeting/$meetId'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "membersCount": membersCount,
        "meetEndTime": meetEndTime
      }),
    );

    if (response.statusCode == 200) {
      print('POST request successful');
      print('Response: ${response.body}');
    } else {
      print('POST request failed with status: ${response.statusCode}');
      print('Response: ${response.body}');
    }
  }
}