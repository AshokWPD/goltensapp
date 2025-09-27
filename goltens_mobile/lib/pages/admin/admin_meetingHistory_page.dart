import 'dart:io';
import 'dart:typed_data';
import 'package:date_time_format/date_time_format.dart';
import 'package:file_picker/file_picker.dart';

import 'package:floating_action_bubble/floating_action_bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:goltens_core/theme/theme.dart';
import 'package:goltens_core/utils/csv_generator.dart';
import 'package:goltens_core/utils/pdf_generator.dart';
import 'package:goltens_mobile/pages/admin/MoreDetail.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:searchbar_animation/searchbar_animation.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

import '../../meet/constants/file.dart';
import '../../utils/functions.dart';

class AdminMeetingPage extends StatefulWidget {
  const AdminMeetingPage({super.key});

  @override
  _AdminMeetingPageState createState() => _AdminMeetingPageState();
}

class _AdminMeetingPageState extends State<AdminMeetingPage>
    with SingleTickerProviderStateMixin {
  late List<Map<String, dynamic>> meetingData;
  String selectedFilter = 'All Meetings';
  // List<dynamic> filteredData = [];
  List<dynamic> searchData = [];
  final TextEditingController _Searchcon = TextEditingController();
  bool isfilterd = false;
  int rowsPerPage = 50;
  int sortColumnIndex = 0;
  bool sortAscending = true;
  int currentPage = 1;
  bool isload = true;
  int totalPages = 0;
  bool isFiltered = false;
  DateTime? selectedDate;
  late Animation<double> _animation;
  late AnimationController _animationController;

  List<Map<String, dynamic>> get visibleMeetings {
    final startIndex = (currentPage - 1) * rowsPerPage;
    final endIndex =
        (startIndex + rowsPerPage).clamp(0, filteredMeetings.length);
    return filteredMeetings.sublist(startIndex, endIndex);
  }

  List<Map<String, dynamic>> get filteredMeetings {
    List<Map<String, dynamic>> result = [];

    // Filter based on the selected meeting type (Online/Offline)
    if (selectedFilter == 'Online Meetings') {
      result =
          meetingData.where((meeting) => meeting['isOnline'] == true).toList();
    } else if (selectedFilter == 'Offline Meetings') {
      result =
          meetingData.where((meeting) => meeting['isOnline'] == false).toList();
    } else {
      result = List.from(meetingData);
    }

    // Filter based on search text
    if (_Searchcon.text.isNotEmpty) {
      result = result
          .where((meeting) =>
              meeting["department"]
                  .toString()
                  .toLowerCase()
                  .contains(_Searchcon.text.toLowerCase()) ||
              meeting["meetTitle"]
                  .toString()
                  .toLowerCase()
                  .contains(_Searchcon.text.toLowerCase()) ||
              meeting["location"]
                  .toString()
                  .toLowerCase()
                  .contains(_Searchcon.text.toLowerCase()) ||
              meeting["meetCreater"]
                  .toString()
                  .toLowerCase()
                  .contains(_Searchcon.text.toLowerCase()))
          .toList();
    }

    // Filter based on selected date
    if (selectedDate != null) {
      result = result.where((meeting) {
        final String dateStr = meeting['meetDateTime'] ?? '';

        if (dateStr.isNotEmpty) {
          try {
            // Try to parse the date string
            DateTime? meetDateTime;
            if (dateStr.contains('T')) {
              meetDateTime = DateTime.parse(dateStr);
            } else {
              meetDateTime = DateTime.parse(dateStr.replaceFirst(' ', 'T'));
            }

            return meetDateTime.isAfter(selectedDate!) &&
                meetDateTime
                    .isBefore(selectedDate!.add(const Duration(days: 1)));
          } catch (e) {
            print('Error parsing date: $e');
            return false;
          }
        } else {
          return false;
        }
      }).toList();
    }

    // Sort the results by date
    result.sort((a, b) {
      DateTime? aDateTime;
      DateTime? bDateTime;

      try {
        aDateTime = a['meetDateTime'] != null && a['meetDateTime'].isNotEmpty
            ? (a['meetDateTime'].contains('T')
                ? DateTime.parse(a['meetDateTime'])
                : DateTime.parse(a['meetDateTime'].replaceFirst(' ', 'T')))
            : null;
      } catch (e) {
        print('Error parsing date for a: $e');
      }

      try {
        bDateTime = b['meetDateTime'] != null && b['meetDateTime'].isNotEmpty
            ? (b['meetDateTime'].contains('T')
                ? DateTime.parse(b['meetDateTime'])
                : DateTime.parse(b['meetDateTime'].replaceFirst(' ', 'T')))
            : null;
      } catch (e) {
        print('Error parsing date for b: $e');
      }

      if (aDateTime == null && bDateTime == null) return 0;
      if (aDateTime == null) return 1;
      if (bDateTime == null) return -1;
      return bDateTime.compareTo(aDateTime);
    });

    return result;
  }

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );

    final curvedAnimation =
        CurvedAnimation(curve: Curves.easeInOut, parent: _animationController);
    _animation = Tween<double>(begin: 0, end: 1).animate(curvedAnimation);

    super.initState();
    meetingData = [];

    fetchMeetingData();
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

  Future<void> fetchMeetingData() async {
    try {
      // final response = await http
      //     .get(Uri.parse('https://goltens.in/api/v1/meeting/meetings'));

      // if (response.statusCode == 200) {
      //   final Map<String, dynamic> dataMap = json.decode(response.body);
      final List<dynamic> meetings = await fetchAllMeetings();

      setState(() {
        meetingData = List<Map<String, dynamic>>.from(meetings);
        //  filteredData.addAll(meetings);
        searchData.addAll(meetings);
        currentPage = 1;
        totalPages = (meetingData.length / rowsPerPage).ceil();
        isload = false;
      });
      // } else {
      //   throw Exception('Failed to load meeting data');
      // }
    } catch (error) {
      print('Error fetching meeting data: $error');
    }
  }

  Future<void> exportMeetingPdfFile() async {
    final directory = await getDownloadsDirectoryPath();
    Uint8List pdfInBytes = await PDFGenerator.generateMeetingData(meetingData);
    File file = File('$directory/meeting-data.pdf');
    file.writeAsBytes(pdfInBytes);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Successfully saved meeting data as PDF in "Download" folder',
          ),
        ),
      );
    }
  }

  Future<void> exportMeetingCsvFile() async {
    String? selectedDirectory = await pickDirectory();

    if (selectedDirectory != null) {
      String csvData = CSVGenerator.generateMeetingData(meetingData);

      // Convert the CSV string into bytes
      List<int> csvBytes = utf8.encode(csvData);

      // Construct the file path with the user-picked directory
      final csvPath =
          '$selectedDirectory/${DateTime.now().millisecondsSinceEpoch}_meeting_data.csv';

      // Create and write to the file
      File file = File(csvPath);
      await file.writeAsBytes(csvBytes);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('CSV successfully saved to selected folder!'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No folder selected'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

// Function to allow the user to pick a folder
  Future<String?> pickDirectory() async {
    String? directoryPath;

    try {
      directoryPath = await FilePicker.platform.getDirectoryPath();

      if (directoryPath != null) {
        print("Selected directory: $directoryPath");
      } else {
        print("No directory selected");
      }
    } catch (e) {
      print("Error selecting directory: $e");
    }

    return directoryPath;
  }

  void searchfilter(String query) {
    query.isEmpty
        ? setState(() {
            isfilterd = false;
            totalPages = (meetingData.length / rowsPerPage).ceil();
          })
        : setState(() {
            searchData = filteredMeetings
                .where((meeting) =>
                    meeting["department"]
                        .toString()
                        .toLowerCase()
                        .contains(query.toLowerCase()) ||
                    meeting["meetTitle"]
                        .toString()
                        .toLowerCase()
                        .contains(query.toLowerCase()) ||
                    meeting["location"]
                        .toString()
                        .toLowerCase()
                        .contains(query.toLowerCase()) ||
                    meeting["meetCreater"]
                        .toString()
                        .toLowerCase()
                        .contains(query.toLowerCase()))
                .toList();
            isfilterd = true;
            currentPage = 1;
            totalPages = (searchData.length / rowsPerPage).ceil();
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

  void searchFilterByDate(DateTime selectedDate) {
    final DateTime startDate =
        DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    final DateTime endDate = startDate.add(const Duration(days: 1));

    setState(() {
      try {
        searchData = filteredMeetings.where((meeting) {
          final String dateStr = meeting['meetDateTime'] ?? '';
          if (dateStr.isNotEmpty) {
            DateTime? meetDateTime;
            try {
              // Parse the date string with appropriate format
              if (dateStr.contains('T')) {
                meetDateTime = DateTime.parse(dateStr);
              } else {
                meetDateTime = DateTime.parse(dateStr.replaceFirst(' ', 'T'));
              }
            } catch (e) {
              print('Error parsing date: $e');
              return false; // Exclude meetings with invalid date strings
            }

            return meetDateTime.isAfter(startDate) &&
                meetDateTime.isBefore(endDate);
          } else {
            return false; // Exclude meetings with empty date strings
          }
        }).toList();
        currentPage = 1;
        totalPages = (searchData.length / rowsPerPage).ceil();

        // Set filtering flags to true upon successful filtering
        isFiltered = true;
        isfilterd = true;
      } catch (e) {
        print('Error in filtering: $e');
        currentPage = 1;

        totalPages = (meetingData.length / rowsPerPage).ceil();
        // Reset filtering flags if an error occurs
        isFiltered = false;
        isfilterd = false;
      }
    });
  }

  String _formatMeetingDateTime(String dateStr) {
    try {
      DateTime dateTime;
      if (dateStr.isNotEmpty) {
        // Parse the date using the correct format
        dateTime = _parseMeetingDateTime(dateStr);
        // Format the parsed date to 'dd-MM-yyyy \nhh:mm a'
        return DateFormat('dd-MM-yyyy \nhh:mm a').format(dateTime);
      } else {
        return 'Invalid Date';
      }
    } catch (e) {
      print('Error formatting date: $e');
      return 'Invalid Date';
    }
  }

  DateTime _parseMeetingDateTime(String dateStr) {
    try {
      if (dateStr.contains('T')) {
        return DateTime.parse(dateStr);
      } else {
        return DateTime.parse(dateStr.replaceFirst(' ', 'T'));
      }
    } catch (e) {
      print('Error parsing date: $e');
      return DateTime(1970, 1, 1); // Return a default date in case of error
    }
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

  void _showDeleteDialog(
    BuildContext context,
    String meetId,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this meeting?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final response = await http.delete(
                  Uri.parse(
                      'https://goltens.in/api/v1/meeting/deleteMeeting/$meetId'),
                );
                print(meetId);
                if (response.statusCode == 200) {
                  print('Meeting deleted successfully');
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Meeting deleted successfully')),
                  );
                  fetchMeetingData();
                } else {
                  Navigator.of(context).pop();
                  print('Failed to delete the meeting');

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Failed to delete the meeting')),
                  );
                }
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Toolbox Meeting',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: primaryColor,
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
      body: (isload)
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
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DropdownButton<String>(
                    value: selectedFilter,
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          selectedFilter = newValue;
                          currentPage = 1;
                          totalPages =
                              (filteredMeetings.length / rowsPerPage).ceil();
                          if (currentPage > totalPages) {
                            currentPage = totalPages;
                          }
                        });
                      }
                    },
                    items: <String>[
                      'All Meetings',
                      'Online Meetings',
                      'Offline Meetings'
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
                if (filteredMeetings.isEmpty)
                  const Center(child: Text('No data available '))
                else
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          // sortColumnIndex: sortColumnIndex,
                          // sortAscending: sortAscending,
                          columns: const [
                            DataColumn(
                              label: Text('Avatar'),
                            ),
                            DataColumn(
                              label: Text('Meeting Host'),
                            ),
                            DataColumn(
                              label: Text('Department'),
                            ),
                            DataColumn(
                              label: Text('Location'),
                            ),
                            DataColumn(
                              label: Text('Title'),
                            ),
                            DataColumn(
                              label: Text('Meeting Time'),
                            ),
                            DataColumn(
                              label: Text('More Info'),
                            ),
                            DataColumn(
                              label: Text('More Doc Info'),
                            ),
                            DataColumn(
                              label: Text('Delete'),
                            ),
                          ],
                          rows: [
                            ...visibleMeetings.map(
                              (meeting) => DataRow(
                                onSelectChanged: (selected) {
                                  if (selected != null && selected) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            MeetingDetailsPage(
                                                meetingId:
                                                    meeting['meetingId']),
                                      ),
                                    );
                                  }
                                },
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
                                        style: const TextStyle(
                                            color: Colors.black),
                                      ),
                                    ),
                                  ),
                                  DataCell(Text('${meeting['meetCreater']}')),
                                  DataCell(Text('${meeting['department']}')),
                                  DataCell(Text('${meeting['location']}')),
                                  DataCell(Text('${meeting['meetTitle']}')),
                                  DataCell(
                                    Text(
                                      _formatMeetingDateTime(
                                          meeting['meetDateTime'] ?? ''),
                                    ),
                                  ),

                                  // DataCell(Text(DateFormat('dd-MM-yyyy \nhh:mm a').format(
                                  //   DateTime.parse(meeting['meetEndTime'] ?? ''),
                                  // ),
                                  // )),
                                  DataCell(
                                    IconButton(
                                      icon: const Icon(Icons.info),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                MeetingDetailsPage(
                                                    meetingId:
                                                        meeting['meetingId']),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  DataCell(
                                    IconButton(
                                      icon: const Icon(Icons.insert_drive_file),
                                      onPressed: () {
                                        _showFileDialog(
                                            context, meeting['meetingId']);
                                      },
                                    ),
                                  ),
                                  DataCell(
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () {
                                        _showDeleteDialog(
                                            context, meeting['meetingId']);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: currentPage == 1 ? null : prevPage,
                      splashRadius: 15.0,
                    ),
                    Text('${totalPages == 0 ? 0 : currentPage} / $totalPages'),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: currentPage == totalPages ? null : nextPage,
                      splashRadius: 15.0,
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  void onSortColumn(int columnIndex, bool ascending) {
    setState(() {
      sortColumnIndex = columnIndex;
      sortAscending = ascending;
      filteredMeetings.sort((a, b) {
        final aValue = a.values.elementAt(columnIndex);
        final bValue = b.values.elementAt(columnIndex);

        if (aValue is String && bValue is String) {
          return ascending
              ? aValue.compareTo(bValue)
              : bValue.compareTo(aValue);
        } else if (aValue is num && bValue is num) {
          return ascending
              ? aValue.compareTo(bValue)
              : bValue.compareTo(aValue);
        }

        return 0;
      });
    });
  }

  void prevPage() {
    if (currentPage > 1) {
      setState(() {
        currentPage--;
      });
    }
  }

  void nextPage() {
    if (currentPage < totalPages) {
      setState(() {
        currentPage++;
      });
    }
  }
}




  // Future<void> exportMeetingCsvFile() async {
  //   // Request storage permission before saving
  //   // if (await Permission.storage.request().isGranted) {
  //   final directory = await getDownloadsDirectoryPath();

  //   // Generate CSV data
  //   String csvData = CSVGenerator.generateMeetingData(meetingData);

  //   // Convert the CSV string into bytes, similar to how you're handling the PDF
  //   List<int> csvBytes = utf8.encode(csvData);

  //   // Construct the file path for CSV
  //   final csvPath =
  //       '$directory/${DateTime.now().millisecondsSinceEpoch}_meeting_data.csv';

  //   // Create and write to the file
  //   File file = File(csvPath);
  //   await file.writeAsBytes(csvBytes);

  //   if (mounted) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text(
  //           'Successfully saved meeting data as CSV in "Download" folder',
  //         ),
  //         duration: Duration(seconds: 2),
  //       ),
  //     );
  //   }
  //   // } else {
  //   //   if (mounted) {
  //   //     ScaffoldMessenger.of(context).showSnackBar(
  //   //       const SnackBar(
  //   //         content: Text('Storage permission is required to save CSV files.'),
  //   //       ),
  //   //     );
  //   //   }
  //   // }
  // }

  // Future<void> exportMeetingCsvFile() async {
  //   final directory = await getDownloadsDirectoryPath();
  //   String csvData = CSVGenerator.generateMeetingData(meetingData);
  //   File file = File('$directory/meeting-data.csv');
  //   file.writeAsString(csvData);

  //   if (mounted) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text(
  //           'Successfully saved meeting data as CSV in "Download" folder',
  //         ),
  //       ),
  //     );
  //   }
  // }


  // floatingActionButton: FloatingActionButton(
      //   backgroundColor: primaryColor,
      //   onPressed: () {
      //     exportMeetingCsvFile();
      //   },
      //   child: const Icon(
      //     Icons.download,
      //     color: Colors.black,
      //   ),
      // ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      // //Init Floating Action Bubble
      // floatingActionButton: FloatingActionBubble(
      //   // Menu items
      //   items: <Bubble>[

      //     // Floating action menu item
      //     Bubble(
      //       title: "PDF",
      //       iconColor: Colors.black,
      //       bubbleColor: primaryColor,
      //       icon: Icons.picture_as_pdf,
      //       titleStyle: TextStyle(fontSize: 14, color: Colors.black),
      //       onPress: () {
      //         exportMeetingPdfFile();
      //         _animationController.reverse();
      //       },
      //     ),
      //     // Floating action menu item
      //     Bubble(
      //       title: "EXCEL",
      //       iconColor: Colors.black,
      //       bubbleColor: primaryColor,
      //       icon: Icons.edit_document,
      //       titleStyle: TextStyle(fontSize: 14, color: Colors.black),
      //       onPress: () {
      //         exportMeetingCsvFile();
      //         _animationController.reverse();
      //       },
      //     ),
      //     //Floating action menu item

      //   ],

      //   // animation controller
      //   animation: _animation,

      //   // On pressed change animation state
      //   onPress: () =>
      //   _animationController.isCompleted
      //       ? _animationController.reverse()
      //       : _animationController.forward(),

      //   // Floating Action button Icon color
      //   iconColor: Colors.black,

      //   // Flaoting Action button Icon
      //   iconData: Icons.file_download_rounded,
      //   backGroundColor: primaryColor,
      // )