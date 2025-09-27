import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:goltens_core/models/auth.dart';
import 'package:http/http.dart' as http;
import 'package:goltens_core/theme/theme.dart';
import 'package:intl/intl.dart';

class memHistory extends StatefulWidget {
  final UserResponseData userData;

  const memHistory({Key? key, required this.userData}) : super(key: key);

  @override
  _memHistoryState createState() => _memHistoryState();
}

class _memHistoryState extends State<memHistory> {
  List<dynamic> meetingsData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final String apiUrl =
        'https://goltens.in/api/v1/meeting/memberMeetings/member';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'memberId': widget.userData.id}),
        // body: jsonEncode({'memberId': "1"}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        setState(() {
          meetingsData = data['data'] ?? [];
          isLoading = false;
        });
      } else {
        // Handle errors
        print('Failed to load data. Status code: ${response.statusCode}');
        // Show error message to the user
        // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        //   content: Text('Failed to load data. Status code: ${response.statusCode}'),
        // ));
      }
    } catch (error) {
      // Handle exceptions
      print('Error loading data: $error');
      // Show error message to the user
      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      //   content: Text('Error loading data: $error'),
      // ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'History',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: primaryColor,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : meetingsData.isEmpty
              ? Center(child: const Text('No data available'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DataTable(
                            columns: const <DataColumn>[
                              DataColumn(label: Text('Avatar')),
                              DataColumn(label: Text('Meet Host')),
                              DataColumn(label: Text('Department')),
                              DataColumn(label: Text('Title')),
                              DataColumn(label: Text('Meeting ID')),
                              DataColumn(label: Text('Date')),
                              DataColumn(label: Text('Time')),
                              // DataColumn(label: Text('Summary')),
                            ],
                            rows: meetingsData.map((meeting) {
                              // Format date and time
                              final formattedDateTime =
                                  DateFormat.yMd().add_jm().format(
                                        DateTime.parse(meeting['meetDateTime']),
                                      );

                              // Split formattedDateTime into date and time
                              final dateAndTime = formattedDateTime.split(' ');

                              return DataRow(
                                cells: [
                                  DataCell(
                                    CircleAvatar(
                                      backgroundColor: primaryColor,
                                      child: Text(
                                        meeting['meetCreater']?.isNotEmpty ==
                                                true
                                            ? meeting['meetCreater'][0]
                                                .toUpperCase()
                                            : 'N',
                                        style: TextStyle(color: Colors.black),
                                      ),
                                    ),
                                  ),
                                  DataCell(Text('${meeting['meetCreater']}')),
                                  DataCell(Text('${meeting['department']}')),
                                  DataCell(Text('${meeting['meetTitle']}')),
                                  DataCell(Text('${meeting['meetingId']}')),
                                  DataCell(Text(dateAndTime[0])), // Date
                                  DataCell(Text(dateAndTime[1])), // Time
                                  //DataCell(Text('${meeting['description']}')),
                                ],
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }
}
