import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:goltens_core/constants/constants.dart';
import 'package:goltens_core/models/auth.dart';
import 'package:goltens_core/models/feedback.dart';
import 'package:goltens_core/theme/theme.dart';
import 'package:goltens_mobile/provider/global_state.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:roundcheckbox/roundcheckbox.dart';

import 'OfflineMeetIndex.dart';
import 'SubAdminSelectionPage.dart';
import 'join_screen.dart';

class AssignMeet extends StatefulWidget {
  const AssignMeet({super.key});

  @override
  State<AssignMeet> createState() => _AssignMeetState();
}

class _AssignMeetState extends State<AssignMeet> {
  final departmentController = SingleValueDropDownController();
  TextEditingController subjectController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  UserResponse? user;
  bool isloading = true;
  FeedbackData? feedback;
  String? selectedLocation;
  String? selectedMeet;
  TimeOfDay _selectedTime = TimeOfDay.now();
  DateTime _selectedDate = DateTime.now();
  bool isscheduled = false;
  bool isNextButtonEnabled = false;
  TextEditingController locationController = TextEditingController();

  Future<TimeOfDay> _selectTime(BuildContext context) async {
    final TimeOfDay? newTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.black,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    return newTime ?? TimeOfDay.now();
  }

  DateTime? pickedDate;
  Future<void> _selectDate(BuildContext context) async {
    DateTime currentDate = DateTime.now();
    DateTime lastDate = currentDate.add(const Duration(days: 30));

    pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: currentDate,
      lastDate: lastDate,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.black,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      print('Selected date: ${_formatDate(pickedDate!)}');
      print('Selected time: ${_formatTime(_selectedTime)}');
      setState(() {
        formattedDateTime = formatDateTimeAPI(
            _formatDate(pickedDate!), _formatTime(_selectedTime));
      });
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd-MM-yyyy').format(date);
  }

  String _formatTime(TimeOfDay time) {
    final now = DateTime.now();
    final dateTime =
        DateTime(now.year, now.month, now.day, time.hour, time.minute);
    final formattedTime =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00.000';
    return formattedTime;
  }

  String formatDateTimeAPI(String dateString, String timeString) {
    // Parse date and time strings
    List<String> dateParts = dateString.split('-');
    List<String> timeParts = timeString.split(':');

    int year = int.parse(dateParts[0]);
    int month = int.parse(dateParts[1]);
    int day = int.parse(dateParts[2]);

    int hour = int.parse(timeParts[0]);
    int minute = int.parse(timeParts[1]);
    int second = int.parse(timeParts[2].split('.')[0]);

    // Create DateTime object
    DateTime dateTime = DateTime(year, month, day, hour, minute, second);

    // Format the DateTime object to the desired format
    String formattedDateTime = dateTime.toIso8601String();

    return formattedDateTime;
  }

  @override
  void initState() {
    final state = context.read<GlobalState>();

    // TODO: implement initState
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        setState(() {
          user = state.user;
          isloading = false;
        });
      }
    });
    super.initState();
  }

  List<String> meet = [
    'Online Meeting',
    'Offline Meeting',
  ];

  void showLocationMenu() {
    showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(3, 1, 2, 1),
      items: locations.map((location) {
        return PopupMenuItem<String>(
          value: location,
          child: Text(location),
        );
      }).toList(),
    ).then((value) {
      if (value != null) {
        setState(() {
          selectedLocation = value;
          locationController.text = value;
        });
      }
    });
  }

  List<String> locations = [
    '2nd Level Office',
    '2nd Level Non Service Warehouse',
    '2nd Level In-situ Shop',
    'ISD Shop',
    'Chrome Shop',
    'Machine Shop',
    'Welding Shop',
    'SCM Store & Logistic Office',
    'In-situ & Workshop Storage Room',
    'Engine Storage Room',
    'SCM & GT & GWW Office',
    'Reception Area',
    'GT Production Office',
    'Car Park & Open Yard'
  ];
  String formattedDateTime = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Assign Meeting',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: primaryColor,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: locationController,
                      decoration: InputDecoration(
                        labelText: 'Location',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_drop_down),
                    onPressed: () {
                      showLocationMenu();
                    },
                  ),
                ],
              ),
              // IgnorePointer(
              //   ignoring: feedback != null,
              //   child: DropdownButtonFormField<String>(
              //     value: selectedLocation,
              //     onChanged: (value) {
              //       setState(() {
              //         selectedLocation = value;
              //       });
              //     },
              //     isExpanded: true,
              //     itemHeight: 48.0,
              //     items: locations.map((location) {
              //       return DropdownMenuItem<String>(
              //         value: location,
              //         child: SizedBox(
              //           width: double.infinity,
              //           child: Text(
              //             location,
              //             overflow: TextOverflow.ellipsis,
              //           ),
              //         ),
              //       );
              //     }).toList(),
              //     decoration: InputDecoration(
              //       labelText: 'Location',
              //       border: OutlineInputBorder(
              //         borderRadius: BorderRadius.circular(20.0),
              //       ),
              //     ),
              //   ),
              // ),
              const SizedBox(
                height: 15,
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: DropDownTextField(
                  listTextStyle: const TextStyle(fontSize: 14),
                  clearOption: false,
                  controller: departmentController,
                  validator: (value) {
                    if (value != null && value.isEmpty) {
                      return 'Please select your department';
                    }
                    return null;
                  },
                  textFieldDecoration: InputDecoration(
                    labelText: 'Department',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                  dropDownItemCount: departmentList.length,
                  dropDownList: departmentList.map((department) {
                    return DropDownValueModel(
                        name: department, value: department);
                  }).toList(),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              DropdownButtonFormField<String>(
                value: selectedMeet,
                onChanged: (value) {
                  setState(() {
                    selectedMeet = value;
                  });
                },
                isExpanded: true,
                itemHeight: 48.0,
                items: meet.map((meet) {
                  return DropdownMenuItem<String>(
                    value: meet,
                    child: SizedBox(
                      width: double.infinity,
                      child: Text(
                        meet,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  );
                }).toList(),
                decoration: InputDecoration(
                  labelText: 'Meeting Type',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              TextField(
                controller: subjectController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              ElevatedButton(
                onPressed: () async {
                  _selectedTime = await _selectTime(context);
                  _selectedDate = DateTime.now();
                  _selectDate(context);
                },
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(primaryColor),
                  shape: MaterialStateProperty.all<OutlinedBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          20.0), // Adjust the value as needed
                    ),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.date_range,
                        color: Colors.black), // Replace with the desired icon
                    SizedBox(width: 8),
                    Text(
                      'Select Date & Time',
                      style: TextStyle(color: Colors.black),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              ElevatedButton(
                onPressed: () {
                  if (pickedDate != null &&
                      locationController.text.isNotEmpty &&
                      departmentController.dropDownValue!.value != null &&
                      selectedMeet!.isNotEmpty &&
                      subjectController.text.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SubAdminSelectionPage(
                                location: locationController.text ?? '',
                                date: formattedDateTime ?? '',
                                Dep:
                                    departmentController.dropDownValue!.value ??
                                        '',
                                title: subjectController.text,
                                type: selectedMeet! ?? '',
                              )),
                    );
                  } else {
                    const snackBar =
                        SnackBar(content: Text("Please Fill Above Fields"));
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  }
                },
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(primaryColor),
                  shape: MaterialStateProperty.all<OutlinedBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.assignment_outlined, color: Colors.black),
                    SizedBox(width: 8),
                    Text(
                      'Assign Meeting',
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
