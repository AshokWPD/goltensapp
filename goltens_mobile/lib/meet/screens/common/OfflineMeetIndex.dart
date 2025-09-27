import 'dart:convert';
import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/services.dart';
import 'package:goltens_core/constants/constants.dart';
import 'package:goltens_core/models/feedback.dart';
import 'package:goltens_core/models/meeting.dart';
import 'package:goltens_core/services/meeting.dart';
import 'package:goltens_mobile/meet/screens/common/All_SelectionPage.dart';
import 'package:goltens_mobile/meet/screens/common/OfflineExit.dart';
import 'package:goltens_mobile/meet/utils/toast.dart';
import 'package:goltens_mobile/meet_main.dart';
import 'package:goltens_mobile/utils/allowed_ids.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:goltens_core/models/auth.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../history/history.dart';
import '../../../provider/global_state.dart';
import 'EmployeeSelectionPage.dart';

class SAOfflineMeetIndex extends StatefulWidget {
  final String meetId;
  // final bool isscheduled;
  // final String location;
  // final String Dep;
  // final String DateTime;
  // final String meetingSubTitle;
  // final String description;

  const SAOfflineMeetIndex({
    super.key,
    required this.meetId,
    // required this.isscheduled,
    // required this.location,
    // required this.Dep,
    // required this.DateTime,
    // required this.meetingSubTitle,
    // required this.description
  });

  @override
  State<SAOfflineMeetIndex> createState() => _SAOfflineMeetIndexState();
}

class _SAOfflineMeetIndexState extends State<SAOfflineMeetIndex> {
  final departmentController = SingleValueDropDownController();
  bool isloading = true;
  FeedbackData? feedback;
  String? selectedLocation;
  TimeOfDay _selectedTime = TimeOfDay.now();
  DateTime _selectedDate = DateTime.now();
  TextEditingController subjectController = TextEditingController();
  TextEditingController summaryController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  int wordCount = 0;
  final int wordLimit = 190;

  Future<TimeOfDay> _selectTime(BuildContext context) async {
    final TimeOfDay? newTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
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
            colorScheme: ColorScheme.light(
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

  bool isscheduled = false;

  final ApiService apiService = ApiService();
// int? meetid;
  void _createMeeting() async {
    try {
      String meetingTitle = subjectController.text;
      int meetingId = _meetingCode;
      // setState(() {
      //   meetid=_meetingCode;
      // }); // Parse the text to int
      print('Meeting ID: $meetingId');

      Meeting newMeeting = Meeting(
        meetTitle: meetingTitle,
        meetDateTime: isscheduled
            ? formattedDateTime
            : DateTime.now().toLocal().toIso8601String(),
        meetCreater: user!.data.name,
        meetingTime: 1,
        meetingId: "$meetingId",
        department: user!.data.department,
        createrId: user!.data.id,
        membersCount: 5,
        isOnline: false,
        attId: 1,
        meetEndTime: isscheduled
            ? formattedDateTime.toString()
            : DateTime.now().add(const Duration(hours: 3)).toString(),
        membersList: [],
        membersAttended: [],
        location: locationController.text ?? '',
        description: summaryController.text ?? '',
        meetingSubTitle: subjectController.text ?? '',
        assignedUser: '',
        assignerId: user!.data.id,
      );

      await apiService.createMeeting(newMeeting);
      if (!isscheduled) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => OfflineExit(
              meetingId: "$meetingId",
              isscheduled: isscheduled,
              CreaterName: user!.data.name,
              DateTime: isscheduled
                  ? formattedDateTime.toString()
                  : DateTime.now().toIso8601String(),
            ),
          ),
        );
      } else {
        showMeetDialog(context, true);
      }
    } catch (error) {
      print('Error creating meeting: $error');
    }
  }

  Widget _meetcode() {
    if ("$_meetingCode".isNotEmpty) {
      return Text(
        "Meet Code : $_meetingCode",
        style: const TextStyle(fontSize: 16),
      );
    } else {
      // Handle case where meetingId is empty
      return const Text("No meeting code available");
    }
  }

  void showMeetDialog(BuildContext context, bool isOnline) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          content: Container(
            width: double.infinity,
            height: 350,
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle,
                  color: primaryColor,
                  size: 60,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Congratulations!',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Your meeting has been scheduled successfully.',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _meetcode(),
                    IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: () {
                        Clipboard.setData(
                            ClipboardData(text: _meetingCode.toString()));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Copied to clipboard')),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    user!.data.type == UserType.admin
                        ? ElevatedButton.icon(
                            onPressed: () {
                              print('fhndnffjn');
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => AllSelectionPage(
                                            invitelink: "$_meetingCode",
                                            isSchedule: false,
                                            channelname: "$_meetingCode",
                                            isoffline: true,
                                            isscheduled: isscheduled,
                                            Dep: '',
                                            location: '',
                                            DateTime: isscheduled
                                                ? formattedDateTime.toString()
                                                : DateTime.now()
                                                    .toIso8601String(),
                                            CreaterName: user!.data.name,
                                            meetId: "$_meetingCode",
                                          )));
                            },
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  primaryColor),
                              shape: MaterialStateProperty.all<OutlinedBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      20.0), // Adjust the value as needed
                                ),
                              ),
                            ),
                            icon: const Icon(Icons.share, color: Colors.black),
                            label: const Text(
                              'Share',
                              style: TextStyle(color: Colors.black),
                            ),
                          )
                        : ElevatedButton.icon(
                            onPressed: () {
                              print('fhndnffjn');
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => EmpSelectionPage(
                                            invitelink: "$_meetingCode",
                                            isSchedule: false,
                                            channelname: "$_meetingCode",
                                            isoffline: true,
                                            isscheduled: isscheduled,
                                            Dep: '',
                                            location: '',
                                            DateTime: isscheduled
                                                ? formattedDateTime.toString()
                                                : DateTime.now()
                                                    .toIso8601String(),
                                            CreaterName: user!.data.name,
                                            meetId: "$_meetingCode",
                                          )));
                            },
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  primaryColor),
                              shape: MaterialStateProperty.all<OutlinedBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      20.0), // Adjust the value as needed
                                ),
                              ),
                            ),
                            icon: const Icon(Icons.share, color: Colors.black),
                            label: const Text(
                              'Share',
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MeetMain(
                              meetId: '',
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
                      icon: const Icon(Icons.exit_to_app, color: Colors.black),
                      label: const Text(
                        'Exit',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color primaryColor = const Color(0xff80d6ff);
  TextEditingController conferenceID = TextEditingController();
  // final ApiService apiService = ApiService();
  UserResponse? user;
  bool isLoading = false;
  bool isload = true;

  int _meetingCode = 0;
  @override
  void initState() {
    // subjectController.text = DateTime.now().toLocal().toString();
    // print(DateTime.now().toLocal().toString());
    // conferenceID.text=widget.meetid;
    var uuid = const Uuid();
    setState(() {
      _meetingCode = int.parse(uuid.v1().substring(0, 5), radix: 16);
    });
    final state = context.read<GlobalState>();

    // TODO: implement initState
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        setState(() {
          user = state.user;
          isload = false;
        });
      }
    });
    summaryController.addListener(() {
      setState(() {
        wordCount = _countWords(summaryController.text);
      });
    });
    super.initState();
  }

  int _countWords(String text) {
    return text.isEmpty ? 0 : text.length;
    // return text.isEmpty ? 0 : text.trim().split(RegExp(r'\s+')).length;
  }

  @override
  void dispose() {
    summaryController.dispose();
    super.dispose();
    conferenceID.dispose();
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
                DateTime: isscheduled
                    ? formattedDateTime.toString()
                    : DateTime.now().toString(),
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
              CreaterName: '',
              DateTime: isscheduled
                  ? formattedDateTime.toString()
                  : DateTime.now().toIso8601String(),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Offline Meeting',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: primaryColor,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
              icon: const Icon(Icons.history),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => memHistory(
                              userData: user!.data,
                            )));
                // Get.to(SAHistory(userData: user!.data));
              },
            ),
          ),
        ],
      ),
      body: isload
          ? const Center(child: Text('no data available'))
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Lottie.asset(
                      'assets/json/calender.json', // Replace with your animation file path
                      fit: BoxFit.contain,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          if (user!.data.type != UserType.user ||
                              allowedIds.contains(user!.data.id))
                            Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: locationController,
                                        decoration: InputDecoration(
                                          labelText: 'Location',
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(20.0),
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
                                //         borderRadius:
                                //             BorderRadius.circular(20.0),
                                //       ),
                                //     ),
                                //   ),
                                // ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: DropDownTextField(
                                    listTextStyle:
                                        const TextStyle(fontSize: 14),
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
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                      ),
                                    ),
                                    dropDownItemCount: departmentList.length,
                                    dropDownList:
                                        departmentList.map((department) {
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
                                    if (wordCount > wordLimit) {
                                      summaryController.text = summaryController
                                          .text
                                          .trim()
                                          .split(RegExp(r'\s+'))
                                          .take(wordLimit)
                                          .join(' ');
                                      summaryController.selection =
                                          TextSelection.fromPosition(
                                              TextPosition(
                                                  offset: summaryController
                                                      .text.length));
                                    }
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
                                    Checkbox(
                                      value: isscheduled,
                                      onChanged: (value) {
                                        setState(() {
                                          isscheduled = !isscheduled;
                                        });
                                      },

                                      // isChecked: isscheduled,
                                      // onTap: (bool) {
                                      //   isscheduled = !isscheduled;
                                      // },
                                      // size: 30,
                                      // uncheckedColor: Colors.white,
                                      // checkedColor: primaryColor,
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
                                if (isscheduled)
                                  ElevatedButton(
                                    onPressed: () async {
                                      _selectedTime =
                                          await _selectTime(context);
                                      _selectedDate = DateTime.now();
                                      _selectDate(context);
                                    },
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              primaryColor),
                                      shape: MaterialStateProperty.all<
                                          OutlinedBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20.0),
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
                                // Row(
                                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                //   children: [
                                //     // ElevatedButton(
                                //     //   onPressed:
                                //     //       () {
                                //     //           Navigator.pop(context);
                                //     //           Navigator.push(
                                //     //             context,
                                //     //             MaterialPageRoute(
                                //     //                 builder: (context) => SAOfflineMeetIndex(
                                //     //                       meetId: widget.meetId,
                                //     //                       isscheduled: false,
                                //     //                       location: '',
                                //     //                       Dep: '',
                                //     //                       DateTime: '',
                                //     //                       meetingSubTitle: '',
                                //     //                       description: '',
                                //     //                     )),
                                //     //           );
                                //     //         },

                                //     //   style: ButtonStyle(
                                //     //     backgroundColor:
                                //     //         MaterialStateProperty.all<Color>(primaryColor),
                                //     //     shape: MaterialStateProperty.all<OutlinedBorder>(
                                //     //       RoundedRectangleBorder(
                                //     //         borderRadius: BorderRadius.circular(20.0),
                                //     //       ),
                                //     //     ),
                                //     //   ),
                                //     //   child: const Text(
                                //     //     'Join',
                                //     //     style: TextStyle(
                                //     //       color: Colors.black,
                                //     //     ),
                                //     //   ),
                                //     // ),
                                //     ElevatedButton(
                                //       onPressed: () {
                                //               if (pickedDate != null) {
                                //                 formattedDateTime =
                                //                     "${_formatDate(pickedDate!)} ${_formatTime(_selectedTime)} ";
                                //               }
                                //               Navigator.pop(context);
                                //               Navigator.push(
                                //                 context,
                                //                 MaterialPageRoute(
                                //                     builder: (context) => SAOfflineMeetIndex(
                                //                           meetId: widget.meetId,
                                //                           isscheduled: isscheduled,
                                //                           location: selectedLocation ?? '',
                                //                           Dep: departmentController
                                //                                   .dropDownValue?.value ??
                                //                               '',
                                //                           DateTime: formattedDateTime,
                                //                           meetingSubTitle:
                                //                               subjectController.text ?? '',
                                //                           description:
                                //                               summaryController.text ?? '',
                                //                         )),
                                //               );
                                //             }
                                //          ,
                                //       style: ButtonStyle(
                                //         backgroundColor:
                                //             MaterialStateProperty.all<Color>(primaryColor),
                                //         shape: MaterialStateProperty.all<OutlinedBorder>(
                                //           RoundedRectangleBorder(
                                //             borderRadius: BorderRadius.circular(20.0),
                                //           ),
                                //         ),
                                //       ),
                                //       child: const Text(
                                //         'Create',
                                //         style: TextStyle(
                                //           color: Colors.black,
                                //         ),
                                //       ),
                                //     ),
                                //   ],
                                // ),
                                ElevatedButton(
                                  onPressed: () {
                                    // if (pickedDate != null) {
                                    //   formattedDateTime =
                                    //       "${_formatDate(pickedDate!)} ${_formatTime(_selectedTime)}";

                                    //   print(
                                    //       "${_formatDate(pickedDate!)} ${_formatTime(_selectedTime)}");
                                    // }
                                    _createMeeting();
                                    //  showMeetDialog(context, false);
                                    // Navigator.pushReplacement(
                                    //   context,
                                    //   MaterialPageRoute(
                                    //     builder: (context) =>
                                    //         OfflineCreateMeetLink(
                                    //       isSchedule: false,
                                    //       isscheduled: widget.isscheduled,
                                    //       Dep: widget.Dep,
                                    //       location: widget.location,
                                    //       DateTime: widget.DateTime,
                                    //       meetingSubTitle:
                                    //           widget.meetingSubTitle,
                                    //       description: widget.description,
                                    //     ),
                                    //   ),
                                    // );
                                  },
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            primaryColor),
                                    shape: MaterialStateProperty.all<
                                        OutlinedBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            20.0), // Adjust the value as needed
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.add,
                                          color: Colors.black),
                                      const SizedBox(width: 8),
                                      Text(
                                          isscheduled
                                              ? "Schedule Meeting"
                                              : 'Create Meeting',
                                          style: const TextStyle(
                                              color: Colors.black)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          // if(user!.data.type != UserType.user ||
                          //     allowedIds.contains(user!.data.id))
                          const SizedBox(
                            height: 30,
                          ),
                          TextFormField(
                            controller: conferenceID,
                            decoration: InputDecoration(
                              labelText: 'Enter Code',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          ElevatedButton(
                            onPressed: () {
                              print('hi');
                              conferenceID.text.isNotEmpty
                                  ? _addMemberToAttendedList(conferenceID.text)
                                  : ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Center(
                                            child: Text('Enter Valid Code')),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                            },
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  primaryColor),
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
                                Icon(Icons.code, color: Colors.black),
                                SizedBox(width: 8),
                                Text('Join Using Code',
                                    style: TextStyle(color: Colors.black)),
                              ],
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

  // bool isNextButtonEnabled = false;
  // void showMeetDialog(BuildContext context, bool isonline) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         backgroundColor: Colors.white,
  //         shape: RoundedRectangleBorder(
  //           borderRadius:
  //               BorderRadius.circular(20.0), // Adjust the radius as needed
  //         ),
  //         content: Container(
  //           width: double.infinity,
  //           height: 500,
  //           padding: const EdgeInsets.all(10),
  //           child: SingleChildScrollView(
  //             child: Column(
  //               children: [
  //                 IgnorePointer(
  //                   ignoring: feedback != null,
  //                   child: DropdownButtonFormField<String>(
  //                     value: selectedLocation,
  //                     onChanged: (value) {
  //                       setState(() {
  //                         selectedLocation = value;
  //                       });
  //                     },
  //                     isExpanded: true,
  //                     itemHeight: 48.0,
  //                     items: locations.map((location) {
  //                       return DropdownMenuItem<String>(
  //                         value: location,
  //                         child: SizedBox(
  //                           width: double.infinity,
  //                           child: Text(
  //                             location,
  //                             overflow: TextOverflow.ellipsis,
  //                           ),
  //                         ),
  //                       );
  //                     }).toList(),
  //                     decoration: InputDecoration(
  //                       labelText: 'Location',
  //                       border: OutlineInputBorder(
  //                         borderRadius: BorderRadius.circular(20.0),
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //                 const SizedBox(
  //                   height: 10,
  //                 ),
  //                 Padding(
  //                   padding: const EdgeInsets.only(bottom: 8.0),
  //                   child: DropDownTextField(
  //                     clearOption: false,
  //                     controller: departmentController,
  //                     validator: (value) {
  //                       if (value != null && value.isEmpty) {
  //                         return 'Please select your department';
  //                       }
  //                       return null;
  //                     },
  //                     textFieldDecoration: InputDecoration(
  //                       labelText: 'Department',
  //                       border: OutlineInputBorder(
  //                         borderRadius: BorderRadius.circular(20.0),
  //                       ),
  //                     ),
  //                     dropDownItemCount: departmentList.length,
  //                     dropDownList: departmentList.map((department) {
  //                       return DropDownValueModel(
  //                           name: department, value: department);
  //                     }).toList(),
  //                   ),
  //                 ),
  //                 const SizedBox(
  //                   height: 10,
  //                 ),
  //                 TextField(
  //                   controller: subjectController,
  //                   decoration: InputDecoration(
  //                     labelText: 'Title',
  //                     border: OutlineInputBorder(
  //                       borderRadius: BorderRadius.circular(20.0),
  //                     ),
  //                   ),
  //                 ),
  //                 const SizedBox(
  //                   height: 10,
  //                 ),
  //                 TextField(
  //                   controller: summaryController,
  //                   maxLines: 5,
  //                   decoration: InputDecoration(
  //                     labelText: 'Summary',
  //                     border: OutlineInputBorder(
  //                       borderRadius: BorderRadius.circular(20.0),
  //                     ),
  //                   ),
  //                 ),
  //                 const SizedBox(
  //                   height: 10,
  //                 ),
  //                 Row(
  //                   children: [
  //                     RoundCheckBox(
  //                       isChecked: isscheduled,
  //                       onTap: (bool) {
  //                         isscheduled = !isscheduled;
  //                       },
  //                       size: 30,
  //                       uncheckedColor: Colors.white,
  //                       checkedColor: primaryColor,
  //                     ),
  //                     const SizedBox(
  //                       width: 10,
  //                     ),
  //                     const Text('Create Meeting for later'),
  //                   ],
  //                 ),
  //                 const SizedBox(
  //                   height: 10,
  //                 ),
  //                 ElevatedButton(
  //                   onPressed: () async {
  //                     _selectedTime = await _selectTime(context);
  //                     _selectedDate = DateTime.now();
  //                     _selectDate(context);
  //                   },
  //                   style: ButtonStyle(
  //                     backgroundColor:
  //                         MaterialStateProperty.all<Color>(primaryColor),
  //                     shape: MaterialStateProperty.all<OutlinedBorder>(
  //                       RoundedRectangleBorder(
  //                         borderRadius: BorderRadius.circular(20.0),
  //                       ),
  //                     ),
  //                   ),
  //                   child: const Text(
  //                     'Select Date & Time',
  //                     style: TextStyle(color: Colors.black),
  //                   ),
  //                 ),
  //                 const SizedBox(
  //                   height: 10,
  //                 ),
  //                 Row(
  //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                   children: [
  //                     ElevatedButton(
  //                       onPressed: () {
  //                         Navigator.pop(context);
  //                         Navigator.push(
  //                           context,
  //                           MaterialPageRoute(
  //                               builder: (context) => SAOfflineMeetIndex(
  //                                     meetId: widget.meetId,
  //                                     // isscheduled: false,
  //                                     // location: '',
  //                                     // Dep: '',
  //                                     // DateTime: '',
  //                                     // meetingSubTitle: '',
  //                                     // description: '',
  //                                   )),
  //                         );
  //                       },
  //                       style: ButtonStyle(
  //                         backgroundColor:
  //                             MaterialStateProperty.all<Color>(primaryColor),
  //                         shape: MaterialStateProperty.all<OutlinedBorder>(
  //                           RoundedRectangleBorder(
  //                             borderRadius: BorderRadius.circular(20.0),
  //                           ),
  //                         ),
  //                       ),
  //                       child: const Text(
  //                         'Join',
  //                         style: TextStyle(
  //                           color: Colors.black,
  //                         ),
  //                       ),
  //                     ),
  //                     ElevatedButton(
  //                       onPressed: () {
  // if (pickedDate != null) {
  //   formattedDateTime =
  //     "${_formatDate(pickedDate!)} ${_formatTime(_selectedTime)} ";
  // }
  //                         Navigator.pop(context);
  //                         Navigator.push(
  //                           context,
  //                           MaterialPageRoute(
  //                               builder: (context) => SAOfflineMeetIndex(
  //                                     meetId: widget.meetId,
  //                                     // isscheduled: isscheduled,
  //                                     // location: selectedLocation ?? '',
  //                                     // Dep: departmentController
  //                                     //         .dropDownValue?.value ??
  //                                     //     '',
  //                                     // DateTime: formattedDateTime,
  //                                     // meetingSubTitle:
  //                                     //     subjectController.text ?? '',
  //                                     // description: summaryController.text ?? '',
  //                                   )),
  //                         );
  //                       },
  //                       style: ButtonStyle(
  //                         backgroundColor:
  //                             MaterialStateProperty.all<Color>(primaryColor),
  //                         shape: MaterialStateProperty.all<OutlinedBorder>(
  //                           RoundedRectangleBorder(
  //                             borderRadius: BorderRadius.circular(20.0),
  //                           ),
  //                         ),
  //                       ),
  //                       child: const Text(
  //                         'Create',
  //                         style: TextStyle(
  //                           color: Colors.black,
  //                         ),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }
}
