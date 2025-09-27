import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:floating_action_bubble/floating_action_bubble.dart';
import 'package:flutter/material.dart';
import 'package:goltens_core/services/auth.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../../../utils/functions.dart';
import 'MoreInfoPage.dart';
import 'package:goltens_core/theme/theme.dart';
import 'package:goltens_core/utils/csv_generator.dart';
import 'package:searchbar_animation/searchbar_animation.dart';

import 'package:goltens_core/utils/pdf_generator.dart';

class AdminChecklist extends StatefulWidget {
  const AdminChecklist({super.key});

  @override
  _AdminChecklistState createState() => _AdminChecklistState();
}

class _AdminChecklistState extends State<AdminChecklist>
    with SingleTickerProviderStateMixin {
  List<dynamic> responseData = [];
  List<dynamic> filteredData = [];
  List<dynamic> searchData = [];
  TextEditingController _Searchcon = new TextEditingController();
  bool isfilterd = false;
  bool isLoading = true;
  int currentPage = 1;
  int totalPages = 0;
  late Animation<double> _animation;
  late AnimationController _animationController;
  DateTime? selectedDate;
  bool isFiltered = false;
  String selectedFilter = 'All';

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 260),
    );

    final curvedAnimation =
        CurvedAnimation(curve: Curves.easeInOut, parent: _animationController);
    _animation = Tween<double>(begin: 0, end: 1).animate(curvedAnimation);

    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final response = await http.get(Uri.parse(
        'https://goltens.in/api/v1/forms/getAllForm?page=$currentPage'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseDataMap = json.decode(response.body);
      final List<dynamic> data = responseDataMap['data'] ?? [];

      setState(() {
        responseData.addAll(data);
        filteredData.addAll(data);
        searchData.addAll(data); // Initially set filteredData to all data
        isLoading = false;
        totalPages = responseDataMap['totalPages'] ?? 0;
      });
    } else {
      throw Exception('Failed to load data');
    }
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
    if (selectedDate == null) {
      setState(() {
        isFiltered = false;
        isfilterd = false;
      });
      return;
    }

    final DateTime startDate =
        DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    final DateTime endDate = startDate.add(Duration(days: 1));

    setState(() {
      searchData = responseData.where((meeting) {
        final DateTime meetDateTime = DateTime.parse(meeting['dateAndTime']);
        return meetDateTime.isAfter(startDate) &&
            meetDateTime.isBefore(endDate);
      }).toList();
      isFiltered = true;
      isfilterd = true;
    });
  }

  void filterData(String filter) {
    if (filter == 'All') {
      setState(() {
        filteredData = List.from(responseData);
      });
    } else {
      setState(() {
        filteredData = responseData
            .where((item) => item['filterTitle'] == filter)
            .toList();
      });
    }
  }

  Future<void> exportChecklistPdfFile() async {
    final directory = await getDownloadsDirectoryPath();
    Uint8List pdfInBytes =
        await PDFGenerator.generateChecklistData(responseData);
    File file = File('$directory/checklist-data.pdf');
    file.writeAsBytes(pdfInBytes);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Successfully saved checklist data as PDF in "Download" folder'),
        ),
      );
    }
  }

  Future<void> exportChecklistCsvFile() async {
    final directory = await getDownloadsDirectoryPath();
    String csvData = CSVGenerator.generateChecklistData(responseData);
    File file = File('$directory/checklist-data.csv');
    file.writeAsString(csvData);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Successfully saved checklist data as CSV in "Download" folder'),
        ),
      );
    }
  }

  void searchfilter(String query) {
    query.isEmpty
        ? setState(() {
            isfilterd = false;
          })
        : setState(() {
            searchData = filteredData
                .where((meeting) =>
                    meeting["username"]
                        .toString()
                        .toLowerCase()
                        .contains(query.toLowerCase()) ||
                    meeting["filterTitle"]
                        .toString()
                        .toLowerCase()
                        .contains(query.toLowerCase()))
                .toList();
            isfilterd = true;
          });
  }

  List<String> sortItems = [
    'All',
    'Behaviour Safety Observation',
    'Leadership Perception Survey',
    'Leadership and Management Accountability',
    'Forklift Checklist',
    'Employee Safety Walk',
    'Safety Checklist of Gas Equipment',
    'Safety Checklist Of Welding Equipment',
    'Pre-use Weekly Inspection Checklist for Overhead Crane',
  ];

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      backgroundColor: Colors.white,
      color: primaryColor,
      onRefresh: () => fetchData(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Checklist History',
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: primaryColor,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.black),
          actions: [
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'logout') {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text(
                          "Are you sure you want to logout ?",
                        ),
                        actions: [
                          TextButton(
                            child: const Text("CANCEL"),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          TextButton(
                            child: const Text("OK"),
                            onPressed: () async {
                              await AuthService.logout();

                              if (mounted) {
                                await authNavigate(context);
                              }
                            },
                          ),
                        ],
                      );
                    },
                  );
                } else if (value == 'TBM') {
                  Navigator.pop(context);
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/admin-meeting',
                    ModalRoute.withName('/admin-choose-app'),
                  );
                } else if (value == 'Feedback') {
                  Navigator.pop(context);
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/admin-feedback',
                    ModalRoute.withName('/admin-choose-app'),
                  );
                } else if (value == 'Communication') {
                  Navigator.pop(context);
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/admin-communication',
                    ModalRoute.withName('/admin-choose-app'),
                  );
                } else {
                  Navigator.pushNamed(
                    context,
                    '/sub-emp checklist',
                  );
                }
              },
              itemBuilder: (BuildContext context) => [
                PopupMenuItem<String>(
                  value: 'TBM',
                  child: Row(
                    children: [
                      Icon(Icons.video_call),
                      const SizedBox(width: 8),
                      Text('Go to Toolbox Meeting'),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'Feedback',
                  child: Row(
                    children: [
                      Icon(Icons.feedback),
                      const SizedBox(width: 8),
                      Text('Go to Feedback'),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'Go to Communication',
                  child: Row(
                    children: [
                      Icon(Icons.chat),
                      const SizedBox(width: 8),
                      Text('Communication'),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'Checklist',
                  child: Row(
                    children: [
                      Icon(Icons.fact_check_outlined),
                      const SizedBox(width: 8),
                      Text('Checklist'),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.exit_to_app),
                      const SizedBox(width: 8),
                      Text('Logout'),
                    ],
                  ),
                ),
              ],
            ),
          ],
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(75.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(context),
                ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Container(
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
            : responseData.isEmpty
                ? const Text('No data available')
                : Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: DropdownButtonFormField<String>(
                          value: selectedFilter,
                          onChanged: (value) {
                            setState(() {
                              selectedFilter = value!;
                              filterData(
                                  selectedFilter); // Call filterData method
                            });
                          },
                          isExpanded: true,
                          itemHeight: 48.0,
                          items: sortItems
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          decoration: InputDecoration(
                            labelText: 'Sort By',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          child: PaginatedDataTable(
                            rowsPerPage: 50,
                            columns: const [
                              DataColumn(label: Text('Avatar')),
                              DataColumn(label: Text('Inspected By')),
                              DataColumn(label: Text('Form Title')),
                              DataColumn(
                                label:
                                    SizedBox(width: 100, child: Text('Date')),
                              ),
                              DataColumn(
                                label:
                                    SizedBox(width: 100, child: Text('Time')),
                              ),
                            ],
                            source: _FormHistoryDataSource(
                                context, isfilterd ? searchData : filteredData),
                          ),
                        ),
                      ),
                    ],
                  ),
        // floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        // // Init Floating Action Bubble
        // floatingActionButton: FloatingActionBubble(
        //
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
        //         exportChecklistPdfFile();
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
        //         exportChecklistCsvFile();
        //         _animationController.reverse();
        //       },
        //     ),
        //     //Floating action menu item
        //   ],
        //   // animation controller
        //   animation: _animation,
        //   // On pressed change animation state
        //   onPress: () => _animationController.isCompleted ? _animationController.reverse() : _animationController.forward(),
        //   // Floating Action button Icon color
        //   iconColor: Colors.black,
        //   // Flaoting Action button Icon
        //   iconData: Icons.file_download_rounded,
        //   backGroundColor: primaryColor,
        // ),
      ),
    );
  }
}

class _FormHistoryDataSource extends DataTableSource {
  final BuildContext context;
  final List<dynamic> data;

  _FormHistoryDataSource(this.context, this.data);

  @override
  DataRow getRow(int index) {
    final item = data[index];

    return DataRow(
      cells: [
        DataCell(
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MoreInfoPage(formId: item['formId']),
                ),
              );
            },
            child: CircleAvatar(
              backgroundColor: primaryColor,
              child: Text(
                item['username']?.isNotEmpty == true
                    ? item['username'][0].toUpperCase()
                    : 'N',
                style: const TextStyle(color: Colors.black),
              ),
            ),
          ),
        ),
        DataCell(
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MoreInfoPage(formId: item['formId']),
                ),
              );
            },
            child: Text('${item['username']}'),
          ),
        ),
        DataCell(
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MoreInfoPage(
                    formId: item['formId'],
                  ),
                ),
              );
            },
            child: Text('${item['formTitle']}'),
          ),
        ),
        DataCell(
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MoreInfoPage(formId: item['formId']),
                ),
              );
            },
            child: Text(
              item['dateAndTime'] != null && item['dateAndTime'].isNotEmpty
                  ? '${DateFormat.yMd().format(DateTime.parse(item['dateAndTime']))}'
                  : 'N/A',
            ),
          ),
        ),
        DataCell(
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MoreInfoPage(formId: item['formId']),
                ),
              );
            },
            child: Text(
              item['dateAndTime'] != null && item['dateAndTime'].isNotEmpty
                  ? '${DateFormat.jm().format(DateTime.parse(item['dateAndTime']))}'
                  : 'N/A',
            ),
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => data.length;

  @override
  int get selectedRowCount => 0;
}
