import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:goltens_core/models/auth.dart';
import 'package:goltens_core/theme/theme.dart';
import 'package:goltens_core/utils/pdf_generator.dart';
import 'package:goltens_mobile/utils/functions.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class MeetingTrackerScreen extends StatefulWidget {
  final UserResponse userType;
  const MeetingTrackerScreen({super.key, required this.userType});

  @override
  _MeetingTrackerScreenState createState() => _MeetingTrackerScreenState();
}

// Show meeting count in department grid and apply date filter inside department meeting page
class _MeetingTrackerScreenState extends State<MeetingTrackerScreen> {
  List<Map<String, dynamic>> meetings = [];
  List<Map<String, dynamic>> allmeetings = [];

  List<String> departments = [];
  bool isLoading = true;
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    _fetchMeetingData();
  }

  Future<List<dynamic>> fetchAllMeetings() async {
    List<dynamic> allMeetings = [];
    int page = 1;
    bool hasMoreData = true;

    while (hasMoreData) {
      final response = await http.get(Uri.parse(
          'https://goltens.in/api/v1/meeting/meetings?page=$page&limit=200'));

      if (response.statusCode == 200) {
        print("{pagessss=$page}");
        final jsonData = json.decode(response.body);
        List<dynamic> data = jsonData['data'];

        if (data.isEmpty) {
          // Stop fetching if the data array is empty
          hasMoreData = false;
        } else {
          // Add the fetched meetings to the list
          allMeetings.addAll(data);
          page++;
        }
      } else {
        throw Exception('Failed to load meetings');
      }
    }

    return allMeetings;
  }

  // Fetch meeting data from API
  Future<void> _fetchMeetingData() async {
    // String url = 'https://goltens.in/api/v1/meeting/meetings';

    try {
      //   final response = await http.get(Uri.parse(url));

      //   if (response.statusCode == 200) {
      //     final Map<String, dynamic> jsonResponse = json.decode(response.body);
      //     final List<dynamic> meetingData = jsonResponse['data'];
      final List<dynamic> meetingData = await fetchAllMeetings();
      if (widget.userType.data.type != UserType.admin) {
        List<int> subadminList =
            await fetchUserIds(widget.userType.data.id.toString());

        setState(() {
          meetings = List<Map<String, dynamic>>.from(meetingData
              .where((element) => subadminList.contains(element["createrId"])));

          allmeetings = meetings;
          _groupMeetingsByDepartment();
          isLoading = false;
        });
      } else {
        setState(() {
          meetings = List<Map<String, dynamic>>.from(meetingData);

          allmeetings = meetings;
          _groupMeetingsByDepartment();
          isLoading = false;
        });
      }
      // } else {
      //   throw Exception('Failed to load meeting data');
      // }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<List<int>> fetchUserIds(String userId) async {
    final url = 'https://goltens.in/api/v1/meeting/getmysubadmins/$userId';

    try {
      final response = await http.get(Uri.parse(url));

      // Check if the response is successful (status code 200)
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        // Return the userIds as a List<int>
        return List<int>.from(data['data']['userIds']);
      } else {
        throw Exception('Failed to load user IDs');
      }
    } catch (error) {
      print('Error fetching user IDs: $error');
      return []; // Return an empty list in case of an error
    }
  }

  // Group meetings by department
  void _groupMeetingsByDepartment() {
    Set<String> departmentSet = {};
    for (var meeting in meetings) {
      String department = meeting['department'] ?? 'No Department';
      departmentSet.add(department);
    }
    departments = departmentSet.toList();
  }

  // Filter meetings by the selected date
  List<Map<String, dynamic>> _filterMeetingsByDate(
      List<Map<String, dynamic>> meetings) {
    if (selectedDate == null) return meetings;

    String formattedSelectedDate =
        DateFormat('dd-MM-yyyy').format(selectedDate!);
    return meetings.where((meeting) {
      String meetDateTime = meeting['meetDateTime'] ?? '';
      if (meetDateTime.isEmpty) return false;
      String meetingDate =
          DateFormat('dd-MM-yyyy').format(DateTime.parse(meetDateTime));
      return meetingDate == formattedSelectedDate;
    }).toList();
  }

  // Show date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meeting Tracker'),
        backgroundColor: primaryColor,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          // Text("Date Filter : ",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),),

          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _selectDate(context),
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                Text(
                  "Retrieving all meetings. Please wait...",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black),
                )
              ],
            ))
          : _buildDepartmentGrid(),
    );
  }

  // Build a grid of departments with meeting count
  Widget _buildDepartmentGrid() {
    List<Map<String, dynamic>> filteredMeetings =
        _filterMeetingsByDate(meetings);

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // 2 columns
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0,
        ),
        itemCount: departments.length,
        itemBuilder: (context, index) {
          // Count the number of meetings in each department
          String department = departments[index];
          int meetingCount = filteredMeetings
              .where((meeting) => meeting['department'] == department)
              .length;

          return GestureDetector(
            onTap: () => _showMeetingsForDepartment(department, allmeetings),
            child: Card(
              color: const Color.fromARGB(255, 203, 248, 255),
              elevation: 5,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        department,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Meetings: $meetingCount', // Display meeting count
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Navigate to the department's meeting page
  void _showMeetingsForDepartment(
      String department, List<Map<String, dynamic>> filteredMeetings) {
    List<Map<String, dynamic>> departmentMeetings =
        filteredMeetings.where((meeting) {
      return meeting['department'] == department;
    }).toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DepartmentMeetingsScreen(
          department: department,
          meetings: departmentMeetings,
          selectedDate: selectedDate,
          allmeetings: departmentMeetings, // Pass selected date
        ),
      ),
    );
  }
}

class DepartmentMeetingsScreen extends StatefulWidget {
  final String department;
  final List<Map<String, dynamic>> meetings;
  final List<Map<String, dynamic>> allmeetings;

  final DateTime? selectedDate;

  const DepartmentMeetingsScreen({
    super.key,
    required this.department,
    required this.meetings,
    this.selectedDate,
    required this.allmeetings,
  });

  @override
  _DepartmentMeetingsScreenState createState() =>
      _DepartmentMeetingsScreenState();
}

class _DepartmentMeetingsScreenState extends State<DepartmentMeetingsScreen> {
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    selectedDate = widget
        .selectedDate; // Initialize with the selected date passed from previous page
  }

  // Filter meetings by the selected date
  List<Map<String, dynamic>> _filterMeetingsByDate(
      List<Map<String, dynamic>> meetings) {
    if (selectedDate == null) return meetings;

    String formattedSelectedDate =
        DateFormat('dd-MM-yyyy').format(selectedDate!);
    return meetings.where((meeting) {
      String meetDateTime = meeting['meetDateTime'] ?? '';
      if (meetDateTime.isEmpty) return false;
      String meetingDate =
          DateFormat('dd-MM-yyyy').format(DateTime.parse(meetDateTime));
      return meetingDate == formattedSelectedDate;
    }).toList();
  }

  // Show date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  Map<String, dynamic>? meetingDetails;

  Future<void> fetchMeetingDetails(String meetingId) async {
    final String apiUrl = 'https://goltens.in/api/v1/meeting/$meetingId';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        setState(() {
          meetingDetails = data;
          //  isLoading = false;
        });
        print("$data");
      } else {
        print(
            'Failed to load meeting details. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error loading meeting details: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredMeetings =
        _filterMeetingsByDate(widget.allmeetings);

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.department} Meetings'),
        backgroundColor: primaryColor,
        centerTitle: true,
        actions: [
          // Text("Date Filter : ",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),),
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _selectDate(context),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: filteredMeetings.length,
        itemBuilder: (context, index) {
          return _buildMeetingCard(filteredMeetings[index]);
        },
      ),
    );
  }

  Future<pw.Document> generateMeetingDetailsPdf(
      Map<String, dynamic> meetingDetails, Uint8List logoImage) async {
    String formatDateTime(String? dateTimeString) {
      if (dateTimeString == null || dateTimeString.isEmpty) {
        return 'N/A';
      }
      final dateTime = DateTime.parse(dateTimeString);
      final formattedDate = DateFormat.yMd().add_jm().format(dateTime);
      return formattedDate;
    }

    List<dynamic> membersAttended =
        meetingDetails['data']?['membersAttended'] ?? [];
    final List<pw.TableRow> allRows = [];

    for (var i = 0; i < membersAttended.length; i++) {
      final currentCounter = i + 1;
      final memberName = membersAttended[i]['membersName'] ?? 'N/A';
      final signatureUrl = membersAttended[i]['digitalSignatureFile'];

      // Adding the signature image if available
      final pw.Widget signatureWidget;
      if (signatureUrl != null && signatureUrl.isNotEmpty) {
        // If signature URL exists, load the image from the URL
        final signatureImage = await networkImage(signatureUrl);
        signatureWidget = pw.Image(signatureImage, height: 30, width: 50);
      } else {
        // If no signature is available, display 'N/A'
        signatureWidget =
            pw.Text('N/A', style: const pw.TextStyle(fontSize: 10));
      }

      allRows.add(
        pw.TableRow(
          verticalAlignment: pw.TableCellVerticalAlignment.middle,
          children: [
            pw.Center(
                child: pw.Text('$currentCounter',
                    style: const pw.TextStyle(fontSize: 10))),
            pw.Center(
              child: pw.Flexible(
                  child: pw.Center(
                child: pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 5),
                  child: pw.Text(memberName,
                      softWrap: true, style: const pw.TextStyle(fontSize: 10)),
                ),
              )),
            ),
            pw.Center(
              child: pw.Flexible(
                child: pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 5),
                  child: signatureWidget, // Adding the signature column here
                ),
              ),
            ),
            pw.Center(
              child: pw.Flexible(
                child: pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 5),
                  child: pw.Text('${membersAttended[i]['remark'] ?? 'N/A'}',
                      softWrap: true, style: const pw.TextStyle(fontSize: 10)),
                ),
              ),
            )
          ],
        ),
      );
    }

    final pdf = pw.Document();
    final pw.TableRow header = pw.TableRow(
      verticalAlignment: pw.TableCellVerticalAlignment.middle,
      decoration: const pw.BoxDecoration(
        color: PdfColors.grey300,
      ),
      children: [
        pw.Center(
            child: pw.Text('S.No',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
        pw.Center(
            child: pw.Text('Name',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
        pw.Center(
            child: pw.Text('Signature',
                style: pw.TextStyle(
                    fontWeight:
                        pw.FontWeight.bold))), // New column for Signature
        pw.Center(
            child: pw.Text('Remarks',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
      ],
    );

    if (membersAttended.isEmpty) {
      final pdfContent = pw.Column(
        mainAxisAlignment: pw.MainAxisAlignment.start,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(children: [
            pw.Image(pw.MemoryImage(logoImage), width: 70.0, height: 70.0),
            pw.SizedBox(width: 90),
            pw.Text('Toolbox Meeting',
                style:
                    pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 20)),
          ]),
          pw.SizedBox(height: 15),
          pw.Container(
              // height: "${meetingDetails['data']['description']}".length < 100
              //     ? 200
              //     : 300,
              width: double.infinity,
              decoration: pw.BoxDecoration(
                border: pw.Border.all(),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
              ),
              child: pw.Wrap(children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(15),
                  child: pw.Column(
                    children: [
                      pw.Row(
                        children: [
                          pw.Container(
                            width: 450,
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Row(
                                  children: [
                                    pw.Container(
                                      width: 120,
                                      child: pw.Text('Conducted By ',
                                          style: pw.TextStyle(
                                              fontWeight: pw.FontWeight.bold)),
                                    ),
                                    pw.Text(
                                        '${meetingDetails['data']?['meetCreater'] ?? 'N/A'}'),
                                  ],
                                ),
                                pw.SizedBox(height: 5),
                                pw.Row(
                                  children: [
                                    pw.Container(
                                      width: 120,
                                      child: pw.Text('Department ',
                                          style: pw.TextStyle(
                                              fontWeight: pw.FontWeight.bold)),
                                    ),
                                    pw.Text(
                                        '${meetingDetails['data']?['department'] ?? 'N/A'}'),
                                  ],
                                ),
                                pw.SizedBox(height: 5),
                                pw.Row(
                                  children: [
                                    pw.Container(
                                      width: 120,
                                      child: pw.Text('Meeting Date ',
                                          style: pw.TextStyle(
                                              fontWeight: pw.FontWeight.bold)),
                                    ),
                                    pw.Text(meetingDetails['data']
                                                ?['meetDateTime'] !=
                                            null
                                        ? DateFormat('dd-MM-yyyy').format(
                                            DateTime.parse(
                                                meetingDetails['data']
                                                    ['meetDateTime']))
                                        : 'N/A'),
                                  ],
                                ),
                                pw.SizedBox(height: 5),
                                pw.Row(
                                  children: [
                                    pw.Container(
                                      width: 120,
                                      child: pw.Text('Meeting Time ',
                                          style: pw.TextStyle(
                                              fontWeight: pw.FontWeight.bold)),
                                    ),
                                    pw.Text(meetingDetails['data']
                                                ?['meetDateTime'] !=
                                            null
                                        ? DateFormat('hh:mm a').format(
                                            DateTime.parse(
                                                meetingDetails['data']
                                                    ['meetDateTime']))
                                        : 'N/A'),
                                  ],
                                ),
                                pw.SizedBox(height: 5),
                                pw.Row(
                                  children: [
                                    pw.Container(
                                      width: 120,
                                      child: pw.Text('Topic ',
                                          style: pw.TextStyle(
                                              fontWeight: pw.FontWeight.bold)),
                                    ),
                                    pw.Expanded(
                                      child: pw.Text(
                                          '${meetingDetails['data']?['meetTitle'] ?? 'N/A'}',
                                          softWrap: true),
                                    )
                                  ],
                                ),
                                pw.SizedBox(height: 5),
                                pw.Row(
                                  crossAxisAlignment:
                                      pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Container(
                                      width: 120,
                                      child: pw.Text('Summary ',
                                          style: pw.TextStyle(
                                              fontWeight: pw.FontWeight.bold)),
                                    ),
                                    pw.Expanded(
                                      child: pw.Text(
                                        ('${meetingDetails['data']['description']}' ==
                                                "")
                                            ? "N/A"
                                            : '${meetingDetails['data']['description']}',
                                        softWrap: true,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ])),
          pw.SizedBox(height: 20),
          pw.Container(
              width: double.infinity,
              decoration: pw.BoxDecoration(
                border: pw.Border.all(),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
              ),
              child: pw.Center(
                child: pw.Padding(
                  padding: const pw.EdgeInsets.all(15),
                  child: pw.Text('No members attended the meeting.',
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold, fontSize: 15)),
                ),
              )),
        ],
      );
      pdf.addPage(pw.Page(build: (pw.Context context) => pdfContent));
    } else {
      for (var chunkIndex = 0; chunkIndex < allRows.length;) {
        // Determine the number of rows for the current page
        int rowsPerPage = (chunkIndex == 0) ? 10 : 20;

        // Get the current chunk of rows
        var rowsChunk = allRows.sublist(
          chunkIndex,
          chunkIndex + rowsPerPage < allRows.length
              ? chunkIndex + rowsPerPage
              : allRows.length,
        );

        // Update the chunk index for the next iteration
        chunkIndex += rowsPerPage;

        // Create the PDF content
        final pdfContent = pw.Column(
          mainAxisAlignment: pw.MainAxisAlignment.start,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Logo and title
            pw.Row(children: [
              pw.Image(pw.MemoryImage(logoImage), width: 70.0, height: 70.0),
              pw.SizedBox(width: 90),
              pw.Text('Toolbox Meetings',
                  style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold, fontSize: 20)),
            ]),
            pw.SizedBox(height: 15),

            // Meeting details - Add on the first page only
            if (chunkIndex <= rowsPerPage) ...[
              pw.Container(
                width: double.infinity,
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(),
                  borderRadius:
                      const pw.BorderRadius.all(pw.Radius.circular(5)),
                ),
                child: pw.Padding(
                  padding: const pw.EdgeInsets.all(15),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Row(
                        children: [
                          pw.Container(
                            width: 120,
                            child: pw.Text('Conducted By ',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold)),
                          ),
                          pw.Text(
                              '${meetingDetails['data']?['meetCreater'] ?? 'N/A'}'),
                        ],
                      ),
                      pw.SizedBox(height: 5),
                      pw.Row(
                        children: [
                          pw.Container(
                            width: 120,
                            child: pw.Text('Department ',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold)),
                          ),
                          pw.Text(
                              '${meetingDetails['data']?['department'] ?? 'N/A'}'),
                        ],
                      ),
                      pw.SizedBox(height: 5),
                      pw.Row(
                        children: [
                          pw.Container(
                            width: 120,
                            child: pw.Text('Meeting Date ',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold)),
                          ),
                          pw.Text(meetingDetails['data']?['meetDateTime'] !=
                                  null
                              ? DateFormat('dd-MM-yyyy').format(DateTime.parse(
                                  meetingDetails['data']['meetDateTime']))
                              : 'N/A'),
                        ],
                      ),
                      pw.SizedBox(height: 5),
                      pw.Row(
                        children: [
                          pw.Container(
                            width: 120,
                            child: pw.Text('Meeting Time ',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold)),
                          ),
                          pw.Text(
                              meetingDetails['data']?['meetDateTime'] != null
                                  ? DateFormat('hh:mm a').format(DateTime.parse(
                                      meetingDetails['data']['meetDateTime']))
                                  : 'N/A'),
                        ],
                      ),
                      pw.SizedBox(height: 5),
                      pw.Row(
                        children: [
                          pw.Container(
                            width: 120,
                            child: pw.Text('Topic ',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold)),
                          ),
                          pw.Expanded(
                            child: pw.Text(
                                '${meetingDetails['data']?['meetTitle'] ?? 'N/A'}',
                                softWrap: true),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 5),
                      pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Container(
                            width: 120,
                            child: pw.Text('Summary ',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold)),
                          ),
                          pw.Expanded(
                            child: pw.Text(
                              ('${meetingDetails['data']['description']}' == "")
                                  ? "N/A"
                                  : '${meetingDetails['data']['description']}',
                              softWrap: true,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],

            pw.SizedBox(height: 20),

            // Table for the current chunk
            pw.Table(
              border: pw.TableBorder.all(),
              columnWidths: {
                0: const pw.FixedColumnWidth(35),
                1: const pw.FixedColumnWidth(160),
                2: const pw.FixedColumnWidth(115),
                3: const pw.FlexColumnWidth(),
              },
              children: [
                header, // Add the table header row
                ...rowsChunk, // Add the chunked rows
              ],
            ),
          ],
        );

        pdf.addPage(
          pw.Page(
            build: (pw.Context context) => pdfContent,
          ),
        );
      }
    }

    return pdf;
  }

  // Meeting card UI
  Widget _buildMeetingCard(Map<String, dynamic> meeting) {
    String meetTitle = meeting['meetTitle'] ?? 'No Title';
    String meetCreater = meeting['meetCreater'] ?? 'Unknown';
    String description = meeting['description'] ?? 'No Description';
    String location = meeting['location'] ?? 'No Location';
    String meetDateTime = meeting['meetDateTime'] ?? 'No Start Time';
    String meetEndTime = meeting['meetEndTime'] ?? 'No End Time';
    String department = meeting['department'] ?? 'No Department';
    bool isvalidDate = meetDateTime != '' && meetDateTime != 'No Start Time';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ExpansionTile(
          title: Text(
            meetTitle,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          subtitle: isvalidDate
              ? Text(
                  'Created by: $meetCreater at ${DateFormat("dd-MM-yyyy").format(DateTime.parse(meetDateTime))}')
              : Text('Created by: $meetCreater Invalid Date'),
          children: [
            const SizedBox(height: 10),
            _buildDetailRow('Description:', description),
            _buildDetailRow('Location:', location),
            _buildDetailRow('Department:', department),
            _buildDetailRow('Start Time:', _formatDateTime(meetDateTime)),
            _buildDetailRow('End Time:', _formatDateTime(meetEndTime)),
            const SizedBox(height: 10),
            _buildAttendeesList(meeting['membersAttended']),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                    onPressed: () async {
                      await fetchMeetingDetails(meeting["meetingId"]);
                      if (meetingDetails != null) {
                        final ByteData image =
                            await rootBundle.load('assets/images/logo.png');
                        Uint8List logoImage = (image).buffer.asUint8List();
                        final pdf = await generateMeetingDetailsPdf(
                            meetingDetails!, logoImage);
                        final directory = await getDownloadsDirectoryPath();
                        final pdfPath =
                            '$directory/${DateTime.now().millisecondsSinceEpoch}_report.pdf';
                        final file = File(pdfPath);
                        await file.writeAsBytes(await pdf.save());

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text('PDF successfully generated and saved!'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      } else {}
                    },
                    icon: const Icon(Icons.download),
                    label: const Text(
                      "Download",
                    )),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(value),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(String dateTimeStr) {
    if (dateTimeStr.isEmpty) return 'N/A';
    DateTime dateTime = DateTime.parse(dateTimeStr);
    return DateFormat('dd-MM-yyyy – hh:mm a').format(dateTime);
  }

  Widget _buildAttendeesList(
    List attendees,
  ) {
    if (attendees.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: Text('No attendees for this meeting.'),
      );
    }

    return Column(
      children: attendees.map<Widget>((attendee) {
        String memberInTime = attendee['memberInTime'] ?? '';
        //String memberOutTime = attendee['memberOutTime'] ?? '';

        return ListTile(
          leading: const Icon(Icons.person),
          title: Text(attendee['membersName']),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Date & Time: ${_formatDateTime(memberInTime)}'),
              // Text('Out Time: ${_formatDateTime(memberOutTime)}'),
            ],
          ),
        );
      }).toList(),
    );
  }
}







// import 'package:flutter/material.dart';
// import 'package:goltens_core/theme/theme.dart';
// import 'package:goltens_mobile/meet/constants/colors.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';

// class MeetingTrackerScreen extends StatefulWidget {
//   const MeetingTrackerScreen({super.key});

//   @override
//   _MeetingTrackerScreenState createState() => _MeetingTrackerScreenState();
// }

// class _MeetingTrackerScreenState extends State<MeetingTrackerScreen> {
//   List<Map<String, dynamic>> meetings = [];
//   List<String> departments = [];
//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _fetchMeetingData();
//   }

//   // Fetch meeting data from API
//   Future<void> _fetchMeetingData() async {
//     String url = 'https://goltens.in/api/v1/meeting/meetings';

//     try {
//       final response = await http.get(Uri.parse(url));

//       if (response.statusCode == 200) {
//         final Map<String, dynamic> jsonResponse = json.decode(response.body);
//         final List<dynamic> meetingData = jsonResponse['data'];

//         setState(() {
//           meetings = List<Map<String, dynamic>>.from(meetingData);
//           _groupMeetingsByDepartment();
//           isLoading = false;
//         });
//       } else {
//         throw Exception('Failed to load meeting data');
//       }
//     } catch (e) {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   // Group meetings by department
//   void _groupMeetingsByDepartment() {
//     Set<String> departmentSet = {};
//     for (var meeting in meetings) {
//       String department = meeting['department'] ?? 'No Department';
//       departmentSet.add(department);
//     }
//     departments = departmentSet.toList();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Meeting Tracker'),
//         backgroundColor: primaryColor,
//         centerTitle: true,
//         iconTheme: const IconThemeData(color: Colors.black),
//       ),
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : _buildDepartmentGrid(),
//     );
//   }

//   // Build a grid of departments
//   Widget _buildDepartmentGrid() {
//     return Padding(
//       padding: const EdgeInsets.all(12.0),
//       child: GridView.builder(
//         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: 2, // 2 columns
//           crossAxisSpacing: 10.0,
//           mainAxisSpacing: 10.0,
//         ),
//         itemCount: departments.length,
//         itemBuilder: (context, index) {
//           return GestureDetector(
//             onTap: () => _showMeetingsForDepartment(departments[index]),
//             child: Card(
//               color: const Color.fromARGB(255, 203, 248, 255),
//               elevation: 5,
//               child: Center(
//                 child: Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Text(
//                     departments[index],
//                     style: const TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 16,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   // Navigate to the department's meeting page
//   void _showMeetingsForDepartment(String department) {
//     List<Map<String, dynamic>> filteredMeetings = meetings.where((meeting) {
//       return meeting['department'] == department;
//     }).toList();

//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => DepartmentMeetingsScreen(
//           department: department,
//           meetings: filteredMeetings,
//         ),
//       ),
//     );
//   }
// }

// // Screen to show meetings for a selected department
// class DepartmentMeetingsScreen extends StatelessWidget {
//   final String department;
//   final List<Map<String, dynamic>> meetings;

//   const DepartmentMeetingsScreen(
//       {super.key, required this.department, required this.meetings});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('$department Meetings'),
//         backgroundColor: primaryColor,
//         centerTitle: true,
//       ),
//       body: ListView.builder(
//         itemCount: meetings.length,
//         itemBuilder: (context, index) {
//           return _buildMeetingCard(meetings[index]);
//         },
//       ),
//     );
//   }

//   Widget _buildMeetingCard(Map<String, dynamic> meeting) {
//     String meetTitle = meeting['meetTitle'] ?? 'No Title';
//     String meetCreater = meeting['meetCreater'] ?? 'Unknown';
//     String description = meeting['description'] ?? 'No Description';
//     String location = meeting['location'] ?? 'No Location';
//     String meetDateTime = meeting['meetDateTime'] ?? 'No Start Time';
//     String meetEndTime = meeting['meetEndTime'] ?? 'No End Time';
//     String department = meeting['department'] ?? 'No Department';

//     return Card(
//       margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
//       elevation: 5,
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: ExpansionTile(
//           title: Text(
//             meetTitle,
//             style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
//           ),
//           subtitle: Text('Created by: $meetCreater at ${DateFormat("dd-MM-yyyy").format(DateTime.parse(meetDateTime))} '),
//           children: [
//             const SizedBox(height: 10),
//             _buildDetailRow('Description:', description),
//             _buildDetailRow('Location:', location),
//             _buildDetailRow('Department:', department),
//             _buildDetailRow('Start Time:', _formatDateTime(meetDateTime)),
//             _buildDetailRow('End Time:', _formatDateTime(meetEndTime)),
//             const SizedBox(height: 10),
//             _buildAttendeesList(meeting['membersAttended']),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildDetailRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4.0),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Expanded(
//             flex: 2,
//             child: Text(
//               label,
//               style: const TextStyle(fontWeight: FontWeight.bold),
//             ),
//           ),
//           Expanded(
//             flex: 3,
//             child: Text(value),
//           ),
//         ],
//       ),
//     );
//   }

//   String _formatDateTime(String dateTimeStr) {
//     if (dateTimeStr.isEmpty) return 'N/A';
//     DateTime dateTime = DateTime.parse(dateTimeStr);
//     return DateFormat('dd-MM-yyyy – hh:mm a').format(dateTime);
//   }

//   Widget _buildAttendeesList(List attendees) {
//     if (attendees.isEmpty) {
//       return const Padding(
//         padding: EdgeInsets.symmetric(vertical: 8.0),
//         child: Text('No attendees for this meeting.'),
//       );
//     }

//     return Column(
//       children: attendees.map<Widget>((attendee) {
//         String memberInTime = attendee['memberInTime'] ?? '';
//         String memberOutTime = attendee['memberOutTime'] ?? '';

//         return ListTile(
//           leading: const Icon(Icons.person),
//           title: Text(attendee['membersName']),
//           subtitle: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text('In Time: ${_formatDateTime(memberInTime)}'),
//               Text('Out Time: ${_formatDateTime(memberOutTime)}'),
//             ],
//           ),
//         );
//       }).toList(),
//     );
//   }
// }





