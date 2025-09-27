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

class AssignedChecklist extends StatefulWidget {
  const AssignedChecklist({Key? key});

  @override
  State<AssignedChecklist> createState() => _AssignedChecklistState();
}

class _AssignedChecklistState extends State<AssignedChecklist> {
  List<dynamic> checklist = [];
  UserResponse? user;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    final state = context.read<GlobalState>();

    WidgetsBinding.instance!.addPostFrameCallback((_) async {
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
          'https://goltens.in/api/v1/notifications/checklist-history/${user!.data.id}'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);

      if (responseData.containsKey('notificationChecklist')) {
        setState(() {
          checklist = List.from(responseData['notificationChecklist']);
        });
      } else {
        print('Invalid API response structure');
      }
    } else {
      print('Failed to load data: ${response.reasonPhrase}');
    }
  }

  void _copyChecklistId(String checklistId) {
    Clipboard.setData(ClipboardData(text: checklistId));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Checklist ID copied to clipboard'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Assigned Checklist',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: primaryColor,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : checklist.isEmpty
                ? Center(child: Text("No data available"))
                : ListView.builder(
                    itemCount: checklist.length,
                    itemBuilder: (context, index) {
                      final item = checklist[index];
                      // Format assigned date
                      DateTime assignedDateTime =
                          DateTime.parse(item['assignDate']);
                      String formattedDate =
                          DateFormat('dd/MM/yyyy').format(assignedDateTime);
                      String formattedTime =
                          DateFormat('hh:mm a').format(assignedDateTime);

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
                                  '${item['checlistTitle']}',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 8),
                                    Text('Assigner: ${item['assigner']}'),
                                    SizedBox(height: 8),
                                    // Display formatted assigned date and time
                                    Text(
                                        'Assigned Date: $formattedDate at $formattedTime'),
                                  ],
                                ),
                                onTap: () =>
                                    _copyChecklistId(item['checlistId']),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
