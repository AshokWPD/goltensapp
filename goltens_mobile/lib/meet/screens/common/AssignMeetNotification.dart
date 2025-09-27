import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import the services.dart for Clipboard
import 'package:intl/intl.dart'; // Import intl for date and time formatting
import 'package:goltens_core/models/auth.dart';
import 'package:goltens_core/theme/theme.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';

import '../../../provider/global_state.dart';

class AssignMeetNotification extends StatefulWidget {
  const AssignMeetNotification({super.key});

  @override
  State<AssignMeetNotification> createState() => _AssignMeetNotificationState();
}

class _AssignMeetNotificationState extends State<AssignMeetNotification> {
  List<dynamic> Newmeetingsfirst = [];

  List<dynamic> meetings = [];
  UserResponse? user;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    final state = context.read<GlobalState>();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        setState(() {
          user = state.user;
          isLoading = false;
          fetchData();
        });
      }
    });
  }

  Future<void> fetchData() async {
    final response = await http.get(
      Uri.parse(
          'https://goltens.in/api/v1/notifications/notification-history/${user!.data.id}'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);

      if (responseData.containsKey('notificationHistory')) {
        setState(() {
          Newmeetingsfirst = List.from(responseData['notificationHistory']);
          meetings = Newmeetingsfirst.reversed.toList();
          isLoading = false;
        });
      } else {
        print('Invalid API response structure');
      }
    } else {
      print('Failed to load data: ${response.reasonPhrase}');
    }
  }

  Future<Map<String, String>?> fetchMeetingDescription(String meetingId) async {
    final String apiUrl = 'https://goltens.in/api/v1/meeting/$meetingId';
    print(apiUrl);

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success'] == true &&
            responseData.containsKey('data')) {
          final String description = responseData['data']['description'];
          final String topic = responseData['data']['meetTitle'];
          return {
            'description': description,
            'topic': topic,
          };
        } else {
          print('Description field not found in response.');
          return null;
        }
      } else {
        print(
            'Failed to load meeting details. Status code: ${response.statusCode}');
        return null;
      }
    } catch (error) {
      print('Error loading meeting details: $error');
      return null;
    }
  }

  void _showMeetingInfo(String meetingId) async {
    setState(() {
      isLoading = true;
    });

    // Fetch the meeting details (description and topic)
    final meetingDetails = await fetchMeetingDescription(meetingId);

    setState(() {
      isLoading = false;
    });

    if (meetingDetails != null) {
      final description =
          meetingDetails['description'] ?? 'No description available';
      final topic = meetingDetails['topic'] ?? 'No topic available';

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(topic), // Show the topic as the title
            content: Text(description), // Show the description as the content
            actions: [
              TextButton(
                child: const Text('Close'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      // Show an error dialog if the meeting details couldn't be fetched
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('Failed to load meeting details.'),
            actions: [
              TextButton(
                child: const Text('Close'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  void _copyMeetingId(String meetingId) {
    Clipboard.setData(ClipboardData(text: meetingId));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Meeting ID copied to clipboard'),
      ),
    );
  }

  void _onIconPressed(String meetingId) {
    // Handle icon press here, e.g., open a detailed view
    _showMeetingInfo(meetingId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Assigned Meet Notifications',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: primaryColor,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : meetings.isEmpty
                    ? const Center(child: Text("No data available"))
                    : Expanded(
                        child: ListView.builder(
                          itemCount: meetings.length,
                          itemBuilder: (context, index) {
                            final meeting = meetings[index];
                            // Format date
                            String formattedDate;
                            String formattedTime;

                            if (meeting['meetingTime']
                                .startsWith('Offline Meeting')) {
                              formattedDate = meeting['meetingTime'];
                              formattedTime = '';
                            } else {
                              final List<String> dateFormats = [
                                'dd-MM-yyyyTHH:mm:ss.sss', // ISO 8601 format
                                'dd-MM-yyyy HH:mm:ss', // Another common format
                                // Add more date formats as needed
                              ];

                              DateTime? meetingTime;
                              bool parsedSuccessfully = false;

                              for (String format in dateFormats) {
                                try {
                                  meetingTime = DateFormat(format)
                                      .parse(meeting['meetingTime']);
                                  parsedSuccessfully = true;
                                  break;
                                } catch (e) {
                                  // Try the next format
                                }
                              }

                              if (parsedSuccessfully && meetingTime != null) {
                                formattedDate = DateFormat('dd/MM/yyyy')
                                    .format(meetingTime.toLocal());
                                formattedTime = DateFormat('hh:mm a')
                                    .format(meetingTime.toLocal());
                              } else {
                                // Unable to parse, set as empty strings or handle differently
                                formattedDate = '';
                                formattedTime = '';
                              }
                            }

                            return Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20.0),
                                child: Card(
                                  color: Colors.grey.shade100,
                                  elevation: 5,
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: ListTile(
                                      title: Text(
                                        '${meeting['meetingTitle']}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 8),
                                          Text(
                                            '${meeting['meetingType']}',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w400),
                                          ),
                                          const SizedBox(height: 8),
                                          // Display formatted date and time
                                          Text(
                                              '$formattedDate at $formattedTime'),
                                          if (meeting['meetingId'] != null &&
                                              meeting['meetingId'] != '')
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  'Meeting ID: ${meeting['meetingId']}',
                                                ),
                                                Row(
                                                  children: [
                                                    IconButton(
                                                      onPressed: () =>
                                                          _copyMeetingId(
                                                              meeting[
                                                                  'meetingId']),
                                                      icon: const Icon(
                                                          Icons.copy),
                                                    ),
                                                    IconButton(
                                                      icon: const Icon(
                                                          Icons.info_outline),
                                                      onPressed: () {
                                                        _onIconPressed(meeting[
                                                            'meetingId']);
                                                      },
                                                    )
                                                  ],
                                                ),
                                              ],
                                            ),
                                          if (meeting['meetingId'] != null &&
                                              meeting['meetingId'] != '')
                                            Text('${meeting['hostname']}'),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ],
        ),
      ),
    );
  }
}
