import 'dart:io';
import 'dart:typed_data';
import 'package:floating_action_bubble/floating_action_bubble.dart';
import 'package:flutter/material.dart';
import 'package:goltens_core/models/auth.dart';
import 'package:goltens_core/theme/theme.dart';
import 'package:goltens_core/utils/csv_generator.dart';
import 'package:goltens_core/utils/pdf_generator.dart';
import 'package:goltens_mobile/meet/screens/common/OfflineExit.dart';
import 'package:goltens_mobile/meet/utils/toast.dart';
import 'package:goltens_mobile/pages/admin/MoreDetail.dart';
import 'package:goltens_mobile/provider/global_state.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:searchbar_animation/searchbar_animation.dart';
import 'dart:convert';
import '../../utils/functions.dart';

class ScheduledMeetingPage extends StatefulWidget {
  const ScheduledMeetingPage({super.key});

  @override
  _ScheduledMeetingPageState createState() => _ScheduledMeetingPageState();
}

class _ScheduledMeetingPageState extends State<ScheduledMeetingPage>
    with SingleTickerProviderStateMixin {
  late List<Map<String, dynamic>> meetingData;
  String selectedFilter = 'All Meetings';
  List<dynamic> filteredData = [];
  List<dynamic> searchData = [];
  final TextEditingController _Searchcon = TextEditingController();
  bool isfilterd = false;
  int rowsPerPage = 50;
  int sortColumnIndex = 0;
  bool sortAscending = true;
  int currentPage = 1;
  int totalPages = 0;
  bool isFiltered = false;
  DateTime? selectedDate;
  late Animation<double> _animation;
  late AnimationController _animationController;
  bool isload = true;
  List<Map<String, dynamic>> get visibleMeetings {
    final startIndex = (currentPage - 1) * rowsPerPage;
    final endIndex =
        (startIndex + rowsPerPage).clamp(0, filteredMeetings.length);
    return filteredMeetings.sublist(startIndex, endIndex);
  }

  // List<Map<String, dynamic>> get filteredMeetings {
  //   List<Map<String, dynamic>> result = [];

  //   if (selectedFilter == 'Online Meetings') {
  //     result =
  //         meetingData.where((meeting) => meeting['isOnline'] == true).toList();
  //   } else if (selectedFilter == 'Offline Meetings') {
  //     result =
  //         meetingData.where((meeting) => meeting['isOnline'] == false).toList();
  //   } else {
  //     result = List.from(meetingData);
  //   }

  //   if (_Searchcon.text.isNotEmpty) {
  //     result = result
  //         .where((meeting) =>
  //             meeting["department"]
  //                 .toString()
  //                 .toLowerCase()
  //                 .contains(_Searchcon.text.toLowerCase()) ||
  //             meeting["meetTitle"]
  //                 .toString()
  //                 .toLowerCase()
  //                 .contains(_Searchcon.text.toLowerCase()) ||
  //             meeting["location"]
  //                 .toString()
  //                 .toLowerCase()
  //                 .contains(_Searchcon.text.toLowerCase()) ||
  //             meeting["meetCreater"]
  //                 .toString()
  //                 .toLowerCase()
  //                 .contains(_Searchcon.text.toLowerCase()))
  //         .toList();
  //   }

  //   if (selectedDate != null) {
  //     result = result.where((meeting) {
  //       final String dateStr = meeting['meetDateTime'] ?? '';

  //       if (dateStr.isNotEmpty) {
  //         try {
  //           final DateTime meetDateTime =
  //               DateTime.parse(dateStr).add(const Duration(hours: 1));
  //           return meetDateTime.isAfter(
  //               DateTime.now()); // Check if meeting time is after current time
  //         } catch (e) {
  //           print('Error parsing date: $e');
  //           return false;
  //         }
  //       } else {
  //         return false;
  //       }
  //     }).toList();
  //   } else {
  //     // If no specific date is selected, filter out past meetings
  //     result = result.where((meeting) {
  //       final String dateStr = meeting['meetDateTime'] ?? '';

  //       if (dateStr.isNotEmpty) {
  //         try {
  //           final DateTime meetDateTime =
  //               DateTime.parse(dateStr).add(const Duration(hours: 1));
  //           return meetDateTime.isAfter(
  //               DateTime.now()); // Check if meeting time is after current time
  //         } catch (e) {
  //           print('Error parsing date: $e');
  //           return false;
  //         }
  //       } else {
  //         return false;
  //       }
  //     }).toList();
  //   }

  //   result.sort((a, b) {
  //     final DateTime aDateTime = DateTime.parse(a['meetDateTime'] ?? '');
  //     final DateTime bDateTime = DateTime.parse(b['meetDateTime'] ?? '');
  //     return bDateTime.compareTo(aDateTime);
  //   });

  //   return result;
  // }

  List<Map<String, dynamic>> get filteredMeetings {
    List<Map<String, dynamic>> result = [];

    // Filter by meeting type (Online/Offline)
    if (selectedFilter == 'Online Meetings') {
      result =
          meetingData.where((meeting) => meeting['isOnline'] == true).toList();
    } else if (selectedFilter == 'Offline Meetings') {
      result =
          meetingData.where((meeting) => meeting['isOnline'] == false).toList();
    } else {
      result = List.from(meetingData);
    }

    // Search filter
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

    // Filter by selected date
    if (selectedDate != null) {
      result = result.where((meeting) {
        final String dateStr = meeting['meetDateTime'] ?? '';

        if (dateStr.isNotEmpty) {
          try {
            final DateTime meetDateTime = _parseMeetingDateTime(dateStr)
                .add(const Duration(hours: 1)); // Adjust the meeting time
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
    } else {
      // If no specific date is selected, filter out past meetings
      result = result.where((meeting) {
        final String dateStr = meeting['meetDateTime'] ?? '';

        if (dateStr.isNotEmpty) {
          try {
            final DateTime meetDateTime = _parseMeetingDateTime(dateStr)
                .add(const Duration(hours: 1)); // Adjust the meeting time
            return meetDateTime.isAfter(DateTime.now());
          } catch (e) {
            print('Error parsing date: $e');
            return false;
          }
        } else {
          return false;
        }
      }).toList();
    }

    // Sort by meeting date
    result.sort((a, b) {
      final DateTime aDateTime = _parseMeetingDateTime(a['meetDateTime'] ?? '');
      final DateTime bDateTime = _parseMeetingDateTime(b['meetDateTime'] ?? '');
      return bDateTime.compareTo(aDateTime);
    });

    setState(() {
      // currentPage = 1;
      totalPages = (result.length / rowsPerPage).ceil();
    });

    return result;
  }

// DateTime _parseMeetingDateTime(String dateStr) {
//   try {
//     if (dateStr.contains('T')) {
//       return DateTime.parse(dateStr);
//     } else {
//       return DateTime.parse(dateStr.replaceFirst(' ', 'T'));
//     }
//   } catch (e) {
//     print('Error parsing date: $e');
//     return DateTime(1970, 1, 1); // Default date in case of error
//   }
// }

  // List<Map<String, dynamic>> get filteredMeetings {
  //   List<Map<String, dynamic>> result = [];

  //   if (selectedFilter == 'Online Meetings') {
  //     result = meetingData.where((meeting) => meeting['isOnline'] == true).toList();
  //   } else if (selectedFilter == 'Offline Meetings') {
  //     result = meetingData.where((meeting) => meeting['isOnline'] == false).toList();
  //   } else {
  //     result = List.from(meetingData);
  //   }

  //   if (_Searchcon.text.isNotEmpty) {
  //     result = result.where((meeting) =>
  //     meeting["department"].toString().toLowerCase().contains(_Searchcon.text.toLowerCase()) ||
  //         meeting["meetTitle"].toString().toLowerCase().contains(_Searchcon.text.toLowerCase())||
  //         meeting["location"].toString().toLowerCase().contains(_Searchcon.text.toLowerCase())||
  //         meeting["meetCreater"].toString().toLowerCase().contains(_Searchcon.text.toLowerCase())
  //     ).toList();
  //   }

  //   if (selectedDate != null) {
  //     result = result.where((meeting) {
  //       final String dateStr = meeting['meetDateTime'] ?? '';

  //       if (dateStr.isNotEmpty) {
  //         try {
  //           final DateTime meetDateTime = DateTime.parse(dateStr);
  //           return meetDateTime.isAfter(selectedDate!) &&
  //               meetDateTime.isBefore(selectedDate!.add(Duration(days: 1)));
  //         } catch (e) {
  //           print('Error parsing date: $e');
  //           return false;
  //         }
  //       } else {
  //         return false;
  //       }
  //     }).toList();
  //   }

  //   return result;
  // }
  UserResponse? user;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );

    final curvedAnimation =
        CurvedAnimation(curve: Curves.easeInOut, parent: _animationController);
    _animation = Tween<double>(begin: 0, end: 1).animate(curvedAnimation);
    final state = context.read<GlobalState>();

    // TODO: implement initState
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        setState(() {
          user = state.user;
          // isload = false;
        });
      }
    });

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

      final List<dynamic> meetings = await fetchAllMeetings();

      // final Map<String, dynamic> dataMap = json.decode(response.body);
      // final List<dynamic> meetings = dataMap['data'] ?? [];

      setState(() {
        meetingData = List<Map<String, dynamic>>.from(meetings);
        filteredData.addAll(meetings);
        searchData.addAll(meetings);
        currentPage = 1;
        totalPages = (filteredData.length / rowsPerPage).ceil();
        isload = false;
      });
      // } else {
      //   setState(() {
      //     isload = false;

      //   });
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
    final directory = await getDownloadsDirectoryPath();
    String csvData = CSVGenerator.generateMeetingData(meetingData);
    File file = File('$directory/meeting-data.csv');
    file.writeAsString(csvData);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Successfully saved meeting data as CSV in "Download" folder',
          ),
        ),
      );
    }
  }

  void searchfilter(String query) {
    query.isEmpty
        ? setState(() {
            isfilterd = false;
            currentPage = 1;
            totalPages = (filteredMeetings.length / rowsPerPage).ceil();
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

  // void searchFilterByDate(DateTime selectedDate) {
  //   final DateTime startDate =
  //       DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
  //   final DateTime endDate = startDate.add(const Duration(days: 1));

  //   setState(() {
  //     try {
  //       final DateFormat formatter = DateFormat('dd-MM-yyyy HH:mm:ss');
  //       searchData = filteredMeetings.where((meeting) {
  //         final String dateStr = meeting['meetDateTime'] ?? '';
  //         if (dateStr.isNotEmpty) {
  //           final DateTime meetDateTime = formatter.parse(dateStr);
  //           return meetDateTime.isAfter(startDate) &&
  //               meetDateTime.isBefore(endDate);
  //         } else {
  //           return false; // Handle empty date string
  //         }
  //       }).toList();
  //       isFiltered = true;
  //       isfilterd = true;
  //     } catch (e) {
  //       print('Error parsing date: $e');
  //       // Handle the FormatException, provide a default behavior or error message
  //       // You can set isFiltered and isfilterd to false here if needed
  //     }
  //   });
  // }

  void searchFilterByDate(DateTime selectedDate) {
    final DateTime startDate =
        DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    final DateTime endDate = startDate.add(const Duration(days: 1));

    setState(() {
      try {
        searchData = filteredMeetings.where((meeting) {
          final String dateStr = meeting['meetDateTime'] ?? '';
          if (dateStr.isNotEmpty) {
            try {
              final DateTime meetDateTime = _parseMeetingDateTime(dateStr);
              return meetDateTime.isAfter(startDate) &&
                  meetDateTime.isBefore(endDate);
            } catch (e) {
              print('Error parsing date: $e');
              return false; // Handle the parsing error
            }
          } else {
            return false; // Handle empty date string
          }
        }).toList();
        currentPage = 1;
        totalPages = (searchData.length / rowsPerPage).ceil();
        isFiltered = true;
        isfilterd = true;
      } catch (e) {
        currentPage = 1;
        totalPages = (filteredMeetings.length / rowsPerPage).ceil();
        print('Error in filtering: $e');
        // Optionally reset filtering flags if an error occurs
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

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Scheduled Meeting',
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
              // IconButton(
              //   icon: const Icon(Icons.calendar_today),
              //   onPressed: () => _selectDate(context),
              // ),
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
      body: isload
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
                          sortColumnIndex: sortColumnIndex,
                          sortAscending: sortAscending,
                          columns: [
                            DataColumn(
                              label: const Text('Avatar'),
                              onSort: (columnIndex, ascending) {
                                onSortColumn(columnIndex, ascending);
                              },
                            ),
                            DataColumn(
                              label: const Text('Meeting Host'),
                              onSort: (columnIndex, ascending) {
                                onSortColumn(columnIndex, ascending);
                              },
                            ),
                            DataColumn(
                              label: const Text('Department'),
                              onSort: (columnIndex, ascending) {
                                onSortColumn(columnIndex, ascending);
                              },
                            ),
                            DataColumn(
                              label: const Text('Location'),
                              onSort: (columnIndex, ascending) {
                                onSortColumn(columnIndex, ascending);
                              },
                            ),
                            DataColumn(
                              label: const Text('Title'),
                              onSort: (columnIndex, ascending) {
                                onSortColumn(columnIndex, ascending);
                              },
                            ),
                            DataColumn(
                              label: const Text('Start Time'),
                              onSort: (columnIndex, ascending) {
                                onSortColumn(columnIndex, ascending);
                              },
                            ),
                            DataColumn(
                              label: const Text('End Time'),
                              onSort: (columnIndex, ascending) {
                                // onSortColumn(columnIndex, ascending);
                              },
                            ),
                            const DataColumn(
                              label: Text('More Info'),
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
                                  DataCell(
                                    Text(
                                      _formatMeetingDateTime(
                                          meeting['meetEndTime'] ?? ''),
                                    ),
                                  ),
                                  DataCell(
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        minimumSize: const Size.fromHeight(40),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                        ),
                                      ),
                                      onPressed: () {
                                        _addMemberToAttendedList(
                                            meeting['meetingId']);
                                        // Navigator.push(
                                        //   context,
                                        //   MaterialPageRoute(
                                        //     builder: (context) =>
                                        //         MeetingDetailsPage(
                                        //             meetingId: meeting['meetingId']),
                                        //   ),
                                        // );
                                      },
                                      child: const Text("Join"),
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
      //       titleStyle: const TextStyle(fontSize: 14, color: Colors.black),
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
      //       titleStyle: const TextStyle(fontSize: 14, color: Colors.black),
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
      //   onPress: () => _animationController.isCompleted
      //       ? _animationController.reverse()
      //       : _animationController.forward(),

      //   // Floating Action button Icon color
      //   iconColor: Colors.black,

      //   // Flaoting Action button Icon
      //   iconData: Icons.file_download_rounded,
      //   backGroundColor: primaryColor,
      // ));
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

  Map<String, dynamic>? meetingDetails;
  Future<void> fetchMeetingDetails(String meetId) async {
    final String apiUrl = 'https://goltens.in/api/v1/meeting/$meetId';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        setState(() {
          meetingDetails = data;
          // isLoading = false;
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

  Future<void> _addMemberToAttendedList(String meetingId) async {
    print("====================================");
    setState(() {
      isLoading = true;
    });

    await fetchMeetingDetails(meetingId);
    // Parse the upcoming date time string into a DateTime object
    DateTime upcomingDateTime =
        DateTime.parse(meetingDetails?['data']['meetEndTime']);

    // Get the current date time
    DateTime currentDateTime = DateTime.now();

    if (currentDateTime.isBefore(upcomingDateTime)) {
      setState(() {
        isLoading = false;
      });
      final url = 'https://goltens.in/api/v1/meeting/addmember/$meetingId';

      if (user != null && user!.data.type == UserType.user) {
        final Map<String, dynamic> data = {
          "membersName": user!.data.name,
          "memberInTime": DateTime.now().toLocal().toIso8601String(),
          "memberOutTime": DateTime.now().toLocal().toIso8601String(),
          "memberId": user!.data.id,
          "dateTime": DateTime.now().toLocal().toIso8601String(),
          "location": "0",
          "remark": "remark",
          "memberdep": user!.data.department,
          "memberphone": user!.data.phone,
          "memberemail": user!.data.email,
          "latitude": 40.7128,
          "longitude": -74.006,
          "digitalSignature": ""
        };

        print(jsonEncode(data));

        final response = await http.post(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(data),
        );
        print(jsonEncode(data));

        if (response.statusCode == 200) {
          Navigator.pop(context);

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => OfflineExit(
                meetingId: meetingId,
                isscheduled: false,
                CreaterName: '',
                DateTime: DateTime.now().toLocal().toIso8601String(),
              ),
            ),
          );

          // Request successful, handle the response if needed
          print('Member added to attended list successfully');
        } else {
          // Request failed, handle the error
          print(
              'Failed to add member to attended list. Status code: ${response.statusCode}');
        }
      } else {
        Navigator.pop(context);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => OfflineExit(
              meetingId: meetingId,
              isscheduled: false,
              CreaterName: user!.data.name,
              DateTime: DateTime.now().toLocal().toIso8601String(),
            ),
          ),
        );
        // Handle the case where user authentication data is not available
        print('User authentication data is not available');
      }
    } else {
      setState(() {
        isLoading = false;
      });
      showSnackBarMessage(message: "Meeting was Ended", context: context);
    }
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
