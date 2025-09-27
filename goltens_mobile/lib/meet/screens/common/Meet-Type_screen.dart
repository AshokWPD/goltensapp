import 'dart:async';
import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:goltens_core/constants/constants.dart';
import 'package:goltens_core/models/auth.dart';
import 'package:goltens_core/models/feedback.dart';
import 'package:goltens_core/services/auth.dart';
import 'package:goltens_core/theme/theme.dart';
import 'package:goltens_mobile/meet/screens/common/OfflineMeetIndex.dart';
import 'package:goltens_mobile/pages/admin/admin_meetingHistory_page.dart';
import 'package:goltens_mobile/pages/admin/scheduledMeet.dart';
import 'package:goltens_mobile/utils/allowed_ids.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:roundcheckbox/roundcheckbox.dart';
import '../../../history/Creatorhistory.dart';
import '../../../provider/global_state.dart';
import '../../../utils/functions.dart';
import 'AssignMeet.dart';
import 'AssignMeetNotification.dart';
import 'MeetNotification.dart';
import 'MeetTrackScreen.dart';
import 'join_screen.dart';

class MeetTypeScreen extends StatefulWidget {
  final String meetId;
  const MeetTypeScreen({super.key, required this.meetId});

  @override
  State<MeetTypeScreen> createState() => _MeetTypeScreenState();
}

class _MeetTypeScreenState extends State<MeetTypeScreen> {
  final departmentController = SingleValueDropDownController();
  UserResponse? user;
  bool isloading = true;
  FeedbackData? feedback;
  String? selectedLocation;
  TimeOfDay _selectedTime = TimeOfDay.now();
  DateTime _selectedDate = DateTime.now();
  TextEditingController subjectController = TextEditingController();
  TextEditingController summaryController = TextEditingController();
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

  void onpressed(bool isjoinonly) {
    // if (pickedDate != null) {
    //   formattedDateTime =
    //       "${_formatDate(pickedDate!)} ${_formatTime(_selectedTime)} ";
    // }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JoinScreen(
          meetId: widget.meetId,
          isscheduled: isscheduled,
          location: locationController.text ?? '',
          Dep: departmentController.dropDownValue?.value ?? '',
          DateTime: formattedDateTime,
          meetingSubTitle: subjectController.text ?? '',
          description: summaryController.text ?? '',
          isonlyjoin: isjoinonly,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back,
                color: Colors.black), // You can customize the icon as needed
            onPressed: () {
              user!.data.type == UserType.admin
                  ? Navigator.pushReplacementNamed(context, '/admin-choose-app')
                  : Navigator.pushReplacementNamed(context, '/choose-app');

              //   Navigator.push(context, MaterialPageRoute(builder: (context)=>AppChoosePage()));
            }),
        title: const Text(
          'Join Meeting',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: primaryColor,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          user!.data.type == UserType.user
              ? IconButton(
                  icon: const Icon(Icons
                      .notifications), // You can change the icon to any other you prefer
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MeetNotification(),
                      ),
                    );
                  },
                )
              : const SizedBox(),
          user!.data.type == UserType.userAndSubAdmin
              ? IconButton(
                  icon: const Icon(Icons
                      .notifications_active), // You can change the icon to any other you prefer
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AssignMeetNotification(),
                      ),
                    );
                  },
                )
              : const SizedBox(),
          user!.data.type == UserType.admin
              ? IconButton(
                  icon: const Icon(Icons
                      .assignment_outlined), // You can change the icon to any other you prefer
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AssignMeet(),
                      ),
                    );
                  },
                )
              : const SizedBox(),
          user!.data.type == UserType.admin
              ? PopupMenuButton<String>(
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
                    } else if (value == 'Feedback') {
                      Navigator.pop(context);
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/admin-feedback',
                        ModalRoute.withName('/admin-choose-app'),
                      );
                    } else if (value == 'Checklist') {
                      Navigator.pop(context);
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/admin-checklist',
                        ModalRoute.withName('/admin-choose-app'),
                      );
                    } else if (value == 'Communication') {
                      Navigator.pop(context);
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/admin-communication',
                        ModalRoute.withName('/admin-choose-app'),
                      );
                    }
                  },
                  itemBuilder: (BuildContext context) => [
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
                      value: 'Feedback',
                      child: Row(
                        children: [
                          Icon(Icons.feedback),
                          SizedBox(width: 8),
                          Text('Go to Feedback'),
                        ],
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'Checklist',
                      child: Row(
                        children: [
                          Icon(Icons.fact_check),
                          SizedBox(width: 8),
                          Text('Go to Checklist'),
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
              : PopupMenuButton<String>(
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
                    } else if (value == 'Feedback') {
                      Navigator.pop(context);
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/feedback',
                        ModalRoute.withName('/choose-app'),
                      );
                    } else if (value == 'Checklist') {
                      Navigator.pop(context);
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/sub-emp checklist',
                        ModalRoute.withName('/choose-app'),
                      );
                    } else if (value == 'Communication') {
                      Navigator.pop(context);
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/home',
                        ModalRoute.withName('/choose-app'),
                      );
                    }
                  },
                  itemBuilder: (BuildContext context) => [
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
                      value: 'Feedback',
                      child: Row(
                        children: [
                          Icon(Icons.feedback),
                          SizedBox(width: 8),
                          Text('Go to Feedback'),
                        ],
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'Checklist',
                      child: Row(
                        children: [
                          Icon(Icons.fact_check),
                          SizedBox(width: 8),
                          Text('Go to Checklist'),
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
                ),
        ],
      ),
      body: Center(
        child: isloading
            ? const CircularProgressIndicator()
            : SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Lottie.asset(
                      'assets/json/meet.json', // Replace with your animation file path
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.only(right: 20.0, left: 20.0),
                      child: ElevatedButton(
                        onPressed: () {
                          // user!.data.type != UserType.user
                          //     ? showMeetDialog(context, false)
                          //     :
                          // Show a dialog to ask whether it's an offline or online meeting
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SAOfflineMeetIndex(
                                      meetId: widget.meetId,
                                      // isscheduled: false,
                                      // Dep: '',
                                      // location: '',
                                      // DateTime: '',
                                      // meetingSubTitle: '',
                                      // description: '',
                                    )),
                          );
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
                            Icon(Icons.mobile_off_outlined,
                                color: Colors
                                    .black), // Replace with the desired icon
                            SizedBox(
                                width:
                                    8), // Adjust the spacing between the icon and text
                            Text('Offline Meeting',
                                style: TextStyle(color: Colors.black)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 20.0, left: 20.0),
                      child: ElevatedButton(
                        onPressed: () {
                          user!.data.type != UserType.user ||
                                  allowedIds.contains(user!.data.id)
                              ? showMeetDialog(context, true)
                              : Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => JoinScreen(
                                      isonlyjoin: false,
                                      meetId: widget.meetId,
                                      isscheduled: false,
                                      location: locationController.text ?? '',
                                      Dep: departmentController
                                              .dropDownValue?.value ??
                                          '',
                                      DateTime: formattedDateTime,
                                      meetingSubTitle:
                                          subjectController.text ?? '',
                                      description: summaryController.text ?? '',
                                    ),
                                  ),
                                );
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
                            Icon(Icons.video_call,
                                color: Colors
                                    .black), // Replace with the desired icon
                            SizedBox(
                                width:
                                    8), // Adjust the spacing between the icon and text
                            Text('Online Meeting',
                                style: TextStyle(color: Colors.black)),
                          ],
                        ),
                      ),
                    ),
                    if (user!.data.type != UserType.user)
                      const SizedBox(height: 20),
                    if (user!.data.type != UserType.user)
                      Padding(
                        padding: const EdgeInsets.only(right: 20.0, left: 20.0),
                        child: ElevatedButton(
                          onPressed: user!.data.type != UserType.user
                              ? () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const ScheduledMeetingPage()));
                                }
                              : () {},
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
                              Icon(Icons.date_range_sharp,
                                  color: Colors
                                      .black), // Replace with the desired icon
                              SizedBox(
                                  width:
                                      8), // Adjust the spacing between the icon and text
                              Text('Scheduled Meeting',
                                  style: TextStyle(color: Colors.black)),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(
                      height: 20,
                    ),
                    user!.data.type != UserType.user
                        ? Padding(
                            padding:
                                const EdgeInsets.only(right: 20.0, left: 20.0),
                            child: ElevatedButton(
                              onPressed: user!.data.type != UserType.user
                                  ? () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => SAHistory(
                                                    userData: user!.data,
                                                  )));
                                    }
                                  : () {},
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        primaryColor),
                                shape:
                                    MaterialStateProperty.all<OutlinedBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        20.0), // Adjust the value as needed
                                  ),
                                ),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.history_sharp,
                                      color: Colors
                                          .black), // Replace with the desired icon
                                  SizedBox(
                                      width:
                                          8), // Adjust the spacing between the icon and text
                                  Text('My Meeting History',
                                      style: TextStyle(color: Colors.black)),
                                ],
                              ),
                            ),
                          )
                        : const SizedBox(),
                    const SizedBox(
                      height: 20,
                    ),
                    user!.data.type != UserType.user
                        ? Padding(
                            padding:
                                const EdgeInsets.only(right: 20.0, left: 20.0),
                            child: ElevatedButton(
                              onPressed: user!.data.type != UserType.user
                                  ? () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  MeetingTrackerScreen(
                                                    userType: user!,
                                                  )));
                                    }
                                  : () {},
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        primaryColor),
                                shape:
                                    MaterialStateProperty.all<OutlinedBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        20.0), // Adjust the value as needed
                                  ),
                                ),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.track_changes,
                                      color: Colors
                                          .black), // Replace with the desired icon
                                  SizedBox(
                                      width:
                                          8), // Adjust the spacing between the icon and text
                                  Text('Track Meetings',
                                      style: TextStyle(color: Colors.black)),
                                ],
                              ),
                            ),
                          )
                        : const SizedBox(),
                    const SizedBox(
                      height: 20,
                    ),
                    user!.data.type == UserType.admin
                        ? Padding(
                            padding:
                                const EdgeInsets.only(right: 20.0, left: 20.0),
                            child: ElevatedButton(
                              onPressed: user!.data.type == UserType.admin
                                  ? () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const AdminMeetingPage()));
                                    }
                                  : () {},
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        primaryColor),
                                shape:
                                    MaterialStateProperty.all<OutlinedBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        20.0), // Adjust the value as needed
                                  ),
                                ),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.history_sharp,
                                      color: Colors
                                          .black), // Replace with the desired icon
                                  SizedBox(
                                      width:
                                          8), // Adjust the spacing between the icon and text
                                  Text('All Meeting History',
                                      style: TextStyle(color: Colors.black)),
                                ],
                              ),
                            ),
                          )
                        : const SizedBox(),
                  ],
                ),
              ),
      ),
    );
  }

  // void showLocationMenu() {
  //   showMenu(
  //     context: context,
  //     position: RelativeRect.fromLTRB(3, 1, 2, 1),
  //     items: locations.map((location) {
  //       return PopupMenuItem<String>(
  //         value: location,
  //         child: Text(location),
  //       );
  //     }).toList(),
  //   ).then((value) {
  //     if (value != null) {
  //       setState(() {
  //         selectedLocation = value;
  //         locationController.text = value;
  //       });
  //     }
  //   });
  // }

  bool isscheduled = false;
  bool isNextButtonEnabled = false;
  void showMeetDialog(BuildContext context, bool isonline) {
    //  final TextEditingController summaryController = TextEditingController();
    int wordCount = 0;
    const int wordLimit = 190;

    int countWords(String text) {
      return text.isEmpty ? 0 : text.length;
      // return text.isEmpty ? 0 : text.trim().split(RegExp(r'\s+')).length;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(20.0), // Adjust the radius as needed
            ),
            content: Container(
              width: double.infinity,
              height: 630,
              padding: const EdgeInsets.all(10),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    IgnorePointer(
                      ignoring: feedback != null,
                      child: DropdownButtonFormField<String>(
                        value: selectedLocation,
                        onChanged: (value) {
                          setState(() {
                            selectedLocation = value;
                            locationController.text = value!;
                          });
                        },
                        isExpanded: true,
                        itemHeight: 48.0,
                        items: locations.map((location) {
                          return DropdownMenuItem<String>(
                            value: location,
                            child: SizedBox(
                              width: double.infinity,
                              child: Text(
                                location,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          );
                        }).toList(),
                        decoration: InputDecoration(
                          labelText: 'Location',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    const Text("----------Or-----------"),
                    const SizedBox(
                      height: 5,
                    ),
                    TextFormField(
                      controller: locationController,
                      decoration: InputDecoration(
                        labelText: 'Location',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
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
                      height: 10,
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
                      height: 10,
                    ),
                    TextField(
                      controller: summaryController,
                      maxLines: 5,
                      onChanged: (text) {
                        setState(() {
                          wordCount = countWords(summaryController.text);
                          if (wordCount > wordLimit) {
                            summaryController.text = summaryController.text
                                .trim()
                                .split(RegExp(r'\s+'))
                                .take(wordLimit)
                                .join(' ');
                            summaryController.selection =
                                TextSelection.fromPosition(TextPosition(
                                    offset: summaryController.text.length));
                          }
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Summary',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        helperText:
                            '${wordCount.toString()}/$wordLimit letters',
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        RoundCheckBox(
                          isChecked: isscheduled,
                          onTap: (bool) {
                            isscheduled = !isscheduled;
                          },
                          size: 30,
                          uncheckedColor: Colors.white,
                          checkedColor: primaryColor,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        const Text('Create Meeting for later'),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
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
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                      ),
                      child: const Text(
                        'Select Date & Time',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: !isonline
                              ? () {
                                  Navigator.pop(context);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            SAOfflineMeetIndex(
                                              meetId: widget.meetId,
                                              // isscheduled: false,
                                              // location: '',
                                              // Dep: '',
                                              // DateTime: '',
                                              // meetingSubTitle: '',
                                              // description: '',
                                            )),
                                  );
                                }
                              : () {
                                  Navigator.pop(context);
                                  onpressed(true);
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
                          child: const Text(
                            'Join',
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: !isonline
                              ? () {
                                  // if (pickedDate != null) {
                                  //   formattedDateTime =
                                  //       "${_formatDate(pickedDate!)} ${_formatTime(_selectedTime)} ";
                                  // }
                                  Navigator.pop(context);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            SAOfflineMeetIndex(
                                              meetId: widget.meetId,
                                              // isscheduled: isscheduled,
                                              // location: selectedLocation ?? '',
                                              // Dep: departmentController
                                              //         .dropDownValue?.value ??
                                              //     '',
                                              // DateTime: formattedDateTime,
                                              // meetingSubTitle:
                                              //     subjectController.text ?? '',
                                              // description:
                                              //     summaryController.text ?? '',
                                            )),
                                  );
                                }
                              : () {
                                  Navigator.pop(context);
                                  onpressed(false);
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
                          child: const Text(
                            'Create',
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        });
      },
    );
  }
}
