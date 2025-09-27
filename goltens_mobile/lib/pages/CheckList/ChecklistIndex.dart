import 'dart:async';

import 'package:flutter/material.dart';
import 'package:goltens_core/models/auth.dart';
import 'package:goltens_core/services/auth.dart';
import 'package:goltens_core/theme/theme.dart';
import 'package:goltens_mobile/pages/CheckList/All_selectionPage.dart';
import 'package:goltens_mobile/pages/CheckList/subselection.dart';
import 'package:goltens_mobile/pages/auth/auth_page.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../provider/global_state.dart';
import 'AssignedChecklist.dart';
import 'BSO.dart';
import 'FPOC.dart';
import 'GasEquip.dart';
import 'LMA.dart';
import 'LPS.dart';
import 'OverheadCrane.dart';
import 'WeldEquip.dart';
import 'conditions.dart';

class ChecklistIndex extends StatefulWidget {
  const ChecklistIndex({super.key});

  @override
  State<ChecklistIndex> createState() => _ChecklistIndexState();
}

class _ChecklistIndexState extends State<ChecklistIndex> {
  UserResponse? user;
  bool isloading = true;
  List<String> selectedItems = [];
  bool isMultiSelectMode = false;
  String? selectedMeet;
  TimeOfDay _selectedTime = TimeOfDay.now();
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    final state = context.read<GlobalState>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          user = state.user;
          isloading = false;
        });
      }
    });
    super.initState();
  }

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
    DateTime lastDate = DateTime(2080, 12, 31);

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

  String formattedDateTime = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          user!.data.type == UserType.user
              ? IconButton(
                  icon: const Icon(Icons.notifications),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AssignedChecklist()),
                    );
                  },
                )
              : const SizedBox(),
          user!.data.type != UserType.user
              ? IconButton(
                  icon:
                      Icon(isMultiSelectMode ? Icons.close : Icons.select_all),
                  onPressed: () {
                    setState(() {
                      isMultiSelectMode = !isMultiSelectMode;
                      if (!isMultiSelectMode) {
                        selectedItems.clear();
                      }
                    });
                  },
                )
              : const SizedBox(),
          user!.data.type != UserType.admin
              ? PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'logout') {
                      logout();
                    } else if (value == 'Communication') {
                      Navigator.pop(context);
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/home',
                        ModalRoute.withName('/choose-app'),
                      );
                    } else if (value == 'Feedback') {
                      Navigator.pop(context);
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/feedback',
                        ModalRoute.withName('/choose-app'),
                      );
                    } else if (value == 'TBM') {
                      Navigator.pop(context);
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/employee-meeting',
                        ModalRoute.withName('/choose-app'),
                      );
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    const PopupMenuItem<String>(
                      value: 'Feedback',
                      child: Row(
                        children: [
                          Icon(Icons.fact_check),
                          SizedBox(width: 8),
                          Text('Go to Feedback'),
                        ],
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'TBM',
                      child: Row(
                        children: [
                          Icon(Icons.video_call),
                          SizedBox(width: 8),
                          Text('Go to Toolbox Meeting'),
                        ],
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'Communication',
                      child: Row(
                        children: [
                          Icon(Icons.chat),
                          SizedBox(width: 8),
                          Text('Go to Communication'),
                        ],
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'logout',
                      child: Row(
                        children: [
                          Icon(Icons.exit_to_app),
                          SizedBox(width: 8),
                          Text('Logout'),
                        ],
                      ),
                    ),
                  ],
                )
              : const SizedBox(),
        ],
        title: const Text('Check List'),
        backgroundColor: primaryColor,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(
            height: 20,
          ),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 6.0,
              mainAxisSpacing: 6.0,
              children: [
                _buildCard(
                    context, 'Employee Safety Walk', const ConditionsForm()),
                _buildCard(
                    context, 'Behaviour Safety Observation', const BSO()),
                _buildCard(context, 'Safety Checklist Of Gas Equipment',
                    const GasEquip()),
                _buildCard(context, 'Safety Checklist Of Welding Equipment',
                    const WeldEquip()),
                _buildCard(
                    context,
                    'Pre-use Weekly Inspection Checklist for Overhead Crane',
                    const OverheadCrane()),
                _buildCard(context, 'Forklift Pre-Operational', FPOC()),
                _buildCard(context, 'Leadership and Management Accountability',
                    const LMA()),
                _buildCard(
                    context, 'Leadership Perception Survey', const LPS()),
              ],
            ),
          ),
          if (isMultiSelectMode)
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
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
                            color:
                                Colors.black), // Replace with the desired icon
                        SizedBox(width: 8),
                        Text(
                          'Select Date & Time',
                          style: TextStyle(color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  user!.data.type == UserType.admin
                      ? ElevatedButton(
                          onPressed: () {
                            if (selectedItems.isNotEmpty) {
                              // if (pickedDate != null) {
                              //   formattedDateTime =
                              //       "${_formatDate(pickedDate!)} ${_formatTime(_selectedTime)} ";
                              // }
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => All_SelectionPage(
                                          selectedItems,
                                          Assigner: user!.data.name,
                                          Date: formattedDateTime,
                                        )),
                              );
                            }
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.share),
                              SizedBox(width: 8),
                              Text('Assign Others'),
                            ],
                          ),
                        )
                      : ElevatedButton(
                          onPressed: () {
                            if (selectedItems.isNotEmpty) {
                              // if (pickedDate != null) {
                              //   formattedDateTime =
                              //       "${_formatDate(pickedDate!)} ${_formatTime(_selectedTime)} ";
                              // }
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SubSelectionPage(
                                          selectedItems,
                                          Assigner: user!.data.name,
                                          Date: formattedDateTime,
                                        )),
                              );
                            }
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.share),
                              SizedBox(width: 8),
                              Text('Assign Others'),
                            ],
                          ),
                        ),
                  const SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
          const SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, String text, Widget page) {
    bool isSelected = selectedItems.contains(text);
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Card(
        color: isSelected ? Colors.grey : Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: InkWell(
          onTap: () {
            if (!isMultiSelectMode) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => page),
              );
            } else {
              setState(() {
                if (isSelected) {
                  selectedItems.remove(text);
                } else {
                  // Check if the maximum number of selections has been reached
                  if (selectedItems.length < 3) {
                    selectedItems.add(text);
                  } else {
                    // Show a snackbar or any other message to indicate the limit
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Maximum selection limit reached'),
                      ),
                    );
                  }
                }
              });
            }
          },
          child: Stack(
            children: [
              if (isMultiSelectMode)
                Positioned(
                    top: 5,
                    left: 5,
                    child: Checkbox(
                      value: isSelected,
                      onChanged: (value) {
                        setState(() {
                          isSelected = value!;
                          if (isSelected) {
                            selectedItems.add(text);
                          } else {
                            selectedItems.remove(text);
                          }
                        });
                      },
                      checkColor: Colors.black,
                      fillColor: MaterialStateProperty.resolveWith<Color>(
                        (Set<MaterialState> states) {
                          if (states.contains(MaterialState.selected)) {
                            return primaryColor;
                          }
                          return Colors.white;
                        },
                      ),
                    )),
              Container(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Text(
                    text,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width * 0.039,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void logout() {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Are you sure you want to logout ?"),
          actions: [
            TextButton(
              child: const Text("CANCEL"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text("OK"),
              onPressed: () async {
                await AuthService.logout();

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return const AuthPage();
                  }),
                  (route) => false,
                );
              },
            ),
          ],
        );
      },
    );
  }
}
