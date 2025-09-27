import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import the services.dart for Clipboard
import 'package:intl/intl.dart'; // Import intl for date and time formatting
import 'package:get/get.dart';
import 'package:goltens_core/models/auth.dart';
import 'package:goltens_core/theme/theme.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';

import '../../../provider/global_state.dart';

class MeetNotification extends StatefulWidget {
  const MeetNotification({
    super.key,
  });

  @override
  State<MeetNotification> createState() => _MeetNotificationState();
}

class _MeetNotificationState extends State<MeetNotification> {
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

  void _copyMeetingId(String meetingId) {
    Clipboard.setData(ClipboardData(text: meetingId));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Meeting ID copied to clipboard'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Meeting Notifications',
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
                       bool isvaliddate =
                                DateTime.tryParse(meeting['meetingTime']) !=
                                    null;
                            // Format date
                            // DateTime meetingTime =
                            //     DateTime.parse(meeting['meetingTime']);
                            String formattedDate = isvaliddate
                                ? DateFormat('dd/MM/yyyy').format(
                                    DateTime.parse(meeting['meetingTime']))
                                : "${meeting['meetingTime']}";
                            // Format time to AM/PM
                            String formattedTime = isvaliddate
                                ? DateFormat('hh:mm a').format(
                                    DateTime.parse(meeting['meetingTime']))
                                : "";
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
                                      leading: CircleAvatar(
                                        backgroundColor: primaryColor,
                                        child: Text(
                                          meeting['hostname']?.isNotEmpty ==
                                                  true
                                              ? meeting['hostname'][0]
                                                  .toUpperCase()
                                              : 'N',
                                          style: const TextStyle(
                                              color: Colors.black),
                                        ),
                                      ),
                                      title: Text(
                                        '${meeting['meetingId']}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 8),
                                          Text('${meeting['hostname']}'),
                                          Text('${meeting['meetingType']}'),
                                          // Display formatted date and time
                                            isvaliddate
                                              ? Text(
                                                  '$formattedDate at $formattedTime')
                                              : Text('Scheduled Date&Time: $formattedDate '),
                                        ],
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.copy,
                                                color: Colors.black),
                                            onPressed: () {
                                              _copyMeetingId(
                                                  meeting['meetingId']);
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.segment,
                                                color: Colors.black),
                                            onPressed: () {
                                              _showMeetingInfo(
                                                  meeting['meetingId']);
                                            },
                                          ),
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



// Padding(
//                                 padding: const EdgeInsets.all(2.0),
//                                 child: Container(
//                                   decoration: BoxDecoration(
//                                       color: Colors.grey.shade200,
//                                       borderRadius: BorderRadius.circular(18),
//                                       border: Border.all(
//                                           color: primaryColor, width: 2)),
//                                   height: height * 0.13,
//                                   width: width,
//                                   child: Stack(
//                                     children: [
//                                       Align(
//                                         alignment: Alignment.topLeft,
//                                         child: Padding(
//                                           padding: const EdgeInsets.all(8.0),
//                                           child: CircleAvatar(
//                                             radius: width * 0.06,
//                                             //maxRadius: width*0.06,
//                                             // minRadius: width*0.005,
//                                             backgroundColor: primaryColor,
//                                             child: Text(
//                                               meeting['hostname']?.isNotEmpty ==
//                                                       true
//                                                   ? meeting['hostname'][0]
//                                                       .toUpperCase()
//                                                   : 'N',
//                                               style: const TextStyle(
//                                                   color: Colors.black),
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                       Align(
//                                         alignment: Alignment.topCenter,
//                                         child: Column(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.start,
//                                           children: [
//                                             Text(
//                                               '${meeting['meetingId']}',
//                                               style: const TextStyle(
//                                                   fontWeight: FontWeight.bold),
//                                             ),
//                                             const SizedBox(
//                                               height: 8,
//                                             ),
//                                             Text('${meeting['hostname']}'),
//                                             Text('${meeting['meetingType']}'),
//                                           ],
//                                         ),
//                                       ),
//                                       Align(
//                                         alignment: Alignment.bottomLeft,
//                                         child: Padding(
//                                           padding: const EdgeInsets.all(7),
//                                           child: Text(
//                                               '$formattedDate at $formattedTime'),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ));