import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:goltens_core/models/auth.dart';
import 'package:http/http.dart' as http;
import 'package:goltens_core/theme/theme.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:searchbar_animation/searchbar_animation.dart';

import '../meet/constants/file.dart';
import 'HistoryMoreDetail.dart';

class SAHistory extends StatefulWidget {
  final UserResponseData userData;

  const SAHistory({Key? key, required this.userData}) : super(key: key);

  @override
  _SAHistoryState createState() => _SAHistoryState();
}

class _SAHistoryState extends State<SAHistory> {
  List<dynamic> meetingsData = [];
  bool isLoading = true;
  List<dynamic> searchData = [];
  final TextEditingController _Searchcon = TextEditingController();
  DateTime? selectedDate;
  bool isFiltered = false;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void searchfilter(String query) {
    query.isEmpty
        ? setState(() {
            isFiltered = false;
          })
        : setState(() {
            searchData = meetingsData
                .where((meeting) =>
                    meeting["meetTitle"]
                        .toString()
                        .contains(query.toLowerCase()) ||
                    meeting["meetingId"]
                        .toString()
                        .contains(query.toLowerCase()))
                .toList();
            isFiltered = true;
          });
  }

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
        searchFilterByDate(selectedDate!);
      });
    }
  }

  void searchFilterByDate(DateTime? selectedDate) {
    if (selectedDate == null) {
      setState(() {
        isFiltered = false;
      });
      return;
    }

    final DateTime startDate =
        DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    final DateTime endDate = startDate.add(const Duration(days: 1));

    setState(() {
      searchData = meetingsData.where((meeting) {
        final DateTime? meetDateTime =
            DateTime.tryParse(meeting['meetDateTime'] ?? '');
        return meetDateTime != null &&
            meetDateTime.isAfter(startDate) &&
            meetDateTime.isBefore(endDate);
      }).toList();
      isFiltered = true;
    });
  }

  Future<void> fetchData() async {
    const String apiUrl = 'https://goltens.in/api/v1/meeting/creater';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'createrId': widget.userData.id}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        setState(() {
          meetingsData = data['data'] ?? [];
          isLoading = false;
        });
      } else {
        print('Failed to load data. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error loading data: $error');
    }
  }

  void _navigateToMeetingDetails(meetingId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MeetingDetailsPage(meetingId: meetingId),
      ),
    );
  }

  void _showPreviewDialog(BuildContext context, String fileData) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            // title: const Text('Files'),
            content: SizedBox(
                width: double.maxFinite,
                // height: double.maxFinite,
                child: fileData.endsWith(".pdf")
                    ? const PDF(
                        swipeHorizontal: true,
                      ).cachedFromUrl(fileData)
                    : Image.network(fileData)),
            actions: [
              TextButton(
                onPressed: () {
                  downloadFile(fileData);
                },
                child: const Text('Download'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Close'),
              ),
            ],
          );
        });
  }

  Future<void> downloadFile(String url) async {
    // Get the filename from the URL
    String fileName = url.split('/').last;

    // Determine the directory to store the downloaded file
    Directory? directory;
    if (Platform.isAndroid) {
      directory = await getExternalStorageDirectory();
    } else if (Platform.isIOS) {
      directory = await getApplicationDocumentsDirectory();
    }

    // Create the save path
    String savePath = '${directory!.path}/$fileName';

    // Check if the file already exists
    if (await File(savePath).exists()) {
      print('File already exists. Path: $savePath');
      return;
    }

    // Start downloading
    try {
      await FlutterDownloader.enqueue(
        url: url,
        savedDir: directory.path,
        fileName: fileName,
        showNotification: true,
        openFileFromNotification: true,
      );
      print('Download successful. Path: $savePath');
    } catch (e) {
      print('Error downloading file: $e');
    }
  }

  void _showFileDialog(
    BuildContext context,
    String meetId,
  ) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return FutureBuilder<List<String>>(
              future: fetchFiles(meetId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return AlertDialog(
                    title: const Text('Error'),
                    content: const Text('Failed to load files'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Close'),
                      ),
                    ],
                  );
                } else {
                  return AlertDialog(
                    title: const Text('Files'),
                    content: SizedBox(
                      width: double.maxFinite,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: snapshot.data!.length ?? 0,
                        itemBuilder: (context, index) {
                          final file = snapshot.data![index];
                          return ListTile(
                            leading: file.endsWith(".pdf")
                                ? Image.asset("assets/sheet.png")
                                : Image.asset("assets/picture.png"),
                            title: file.endsWith(".pdf")
                                ? const Text(
                                    "PDF",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  )
                                : const Text("Image",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                            trailing: IconButton(
                              icon: const Icon(Icons.open_in_new),
                              onPressed: () {
                                _showPreviewDialog(context, file);
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Close'),
                      ),
                    ],
                  );
                }
              });
        });
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(75.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: () => _selectDate(context),
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: SearchBarAnimation(
                    onEditingComplete: (value) {
                      searchfilter(value);
                    },
                    onCollapseComplete: (value) {
                      searchfilter(value);
                    },
                    onExpansionComplete: (value) {
                      searchfilter(value);
                    },
                    onSaved: (value) {
                      searchfilter(value);
                    },
                    textEditingController: _Searchcon,
                    enableBoxBorder: true,
                    buttonColour: primaryColor,
                    cursorColour: primaryColor,
                    isOriginalAnimation: true,
                    enableKeyboardFocus: true,
                    buttonBorderColour: Colors.black45,
                    trailingWidget: const Icon(
                      Icons.search,
                      size: 20,
                      color: Colors.black,
                    ),
                    secondaryButtonWidget: const Icon(
                      Icons.close,
                      size: 20,
                      color: Colors.black,
                    ),
                    onChanged: (value) {
                      searchfilter(value);
                    },
                    buttonWidget: const Icon(
                      Icons.search,
                      size: 20,
                      color: Colors.black,
                    ),
                    onFieldSubmitted: (String value) {
                      searchfilter(value);
                      debugPrint('onFieldSubmitted value $value');
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : meetingsData.isEmpty
              ? const Center(child: Text('No data available'))
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
                          isFiltered
                              ? DataTable(
                                  columns: const [
                                    DataColumn(label: Text('Avatar')),
                                    DataColumn(label: Text('Meet Host')),
                                    DataColumn(label: Text('Meeting Title')),
                                    DataColumn(
                                        label: Text('Meeting ID'),
                                        numeric: true),
                                    DataColumn(label: Text('Date')),
                                    DataColumn(label: Text('Time')),
                                    DataColumn(label: Text('More Info')),
                                    DataColumn(label: Text('More Doc Info')),
                                  ],
                                  rows: searchData.map((meeting) {
                                    final formattedDateTime =
                                        DateFormat.yMd().add_jm().format(
                                              DateTime.tryParse(
                                                      meeting['meetDateTime'] ??
                                                          '') ??
                                                  DateTime.now(),
                                            );
                                    final dateAndTime =
                                        formattedDateTime.split(' ');

                                    return DataRow(
                                      selected: false,
                                      cells: [
                                        DataCell(
                                          CircleAvatar(
                                            backgroundColor: primaryColor,
                                            child: Text(
                                              meeting['meetCreater']
                                                          ?.isNotEmpty ==
                                                      true
                                                  ? meeting['meetCreater'][0]
                                                      .toUpperCase()
                                                  : 'N',
                                              style: const TextStyle(
                                                  color: Colors.black),
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                            Text('${meeting['meetCreater']}')),
                                        DataCell(
                                            Text('${meeting['meetTitle']}')),
                                        DataCell(
                                            Text('${meeting['meetingId']}')),
                                        DataCell(Text(dateAndTime[0])),
                                        DataCell(Text(dateAndTime[1])),
                                        DataCell(
                                          IconButton(
                                            icon: const Icon(Icons.info),
                                            onPressed: () {
                                              _navigateToMeetingDetails(
                                                  meeting['meetingId']);
                                            },
                                          ),
                                        ),
                                      ],
                                      onSelectChanged: (_) {
                                        _navigateToMeetingDetails(
                                            meeting['meetingId']);
                                      },
                                    );
                                  }).toList(),
                                )
                              : DataTable(
                                  columns: const [
                                    DataColumn(label: Text('Avatar')),
                                    DataColumn(label: Text('Meet Host')),
                                    DataColumn(label: Text('Meeting Title')),
                                    DataColumn(
                                        label: Text('Meeting ID'),
                                        numeric: true),
                                    DataColumn(label: Text('Date')),
                                    DataColumn(label: Text('Time')),
                                    DataColumn(label: Text('More Info')),
                                    DataColumn(label: Text('More Doc Info')),
                                  ],
                                  rows: meetingsData.map((meeting) {
                                    final formattedDateTime =
                                        DateFormat.yMd().add_jm().format(
                                              DateTime.tryParse(
                                                      meeting['meetDateTime'] ??
                                                          '') ??
                                                  DateTime.now(),
                                            );

                                    final dateAndTime =
                                        formattedDateTime.split(' ');

                                    return DataRow(
                                      selected: false,
                                      cells: [
                                        DataCell(
                                          CircleAvatar(
                                            backgroundColor: primaryColor,
                                            child: Text(
                                              meeting['meetCreater']
                                                          ?.isNotEmpty ==
                                                      true
                                                  ? meeting['meetCreater'][0]
                                                      .toUpperCase()
                                                  : 'N',
                                              style: const TextStyle(
                                                  color: Colors.black),
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                            Text('${meeting['meetCreater']}')),
                                        DataCell(
                                            Text('${meeting['meetTitle']}')),
                                        DataCell(
                                            Text('${meeting['meetingId']}')),
                                        DataCell(Text(dateAndTime[0])),
                                        DataCell(Text(dateAndTime[1])),
                                        DataCell(
                                          IconButton(
                                            icon: const Icon(Icons.info),
                                            onPressed: () {
                                              _navigateToMeetingDetails(
                                                  meeting['meetingId']);
                                            },
                                          ),
                                        ),
                                        DataCell(
                                          IconButton(
                                            icon: const Icon(
                                                Icons.insert_drive_file),
                                            onPressed: () {
                                              _showFileDialog(
                                                context,
                                                meeting['meetingId'],
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                      onSelectChanged: (_) {
                                        _navigateToMeetingDetails(
                                            meeting['meetingId']);
                                      },
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
