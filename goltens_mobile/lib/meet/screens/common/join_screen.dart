// ignore_for_file: non_constant_identifier_names, dead_code

import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:goltens_core/models/meeting.dart';
import 'package:goltens_core/services/meeting.dart';
import 'package:goltens_mobile/history/history.dart';
import 'package:goltens_mobile/meet/screens/common/Meet-Type_screen.dart';
import 'package:goltens_mobile/utils/allowed_ids.dart';
import 'package:http/http.dart' as http;
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:goltens_core/models/auth.dart';
import 'package:goltens_mobile/meet/utils/api.dart';
import 'package:goltens_mobile/provider/global_state.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../../history/HistoryMoreDetail.dart';
import 'All_SelectionPage.dart';
import '../../constants/colors.dart';
import '../../utils/spacer.dart';
import '../../utils/toast.dart';
import '../../widgets/common/joining_details/joining_details.dart';
import '../conference-call/conference_meeting_screen.dart';
import '../one-to-one/one_to_one_meeting_screen.dart';

// Join Screen
class JoinScreen extends StatefulWidget {
  final String meetId;
  final bool isscheduled;
  final String location;
  final String Dep;
  final String DateTime;
  final String meetingSubTitle;
  final String description;
 final bool isonlyjoin;

   JoinScreen({
    Key? key,
    required this.meetId,
    required this.isscheduled,
    required this.location,
    required this.Dep,
    required this.DateTime,
    required this.meetingSubTitle,
    required this.description,
    required this.isonlyjoin
  }) : super(key: key);

  @override
  State<JoinScreen> createState() => _JoinScreenState();
}

class _JoinScreenState extends State<JoinScreen> {
  String _token = "";
  bool isShare = false;
  bool isMicOn = true;
  bool isCameraOn = true;
  UserResponse? user;
  bool isLoading = false;

  bool? isJoinMeetingSelected;
  bool? isCreateMeetingSelected;
  CameraController? cameraController;

  @override
  void initState() {
    print("${widget.location}========${widget.DateTime}==========");
    initCameraPreview();
    final state = context.read<GlobalState>();

    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    // TODO: implement initState
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        setState(() => user = state.user);
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final token = await fetchToken(context);
      setState(() => _token = token);
    });
  }

  @override
  setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  ApiService apiService = ApiService();

  void _createMeeting(String meettitle, String meetId) async {
    try {
      // String meetingTitle = meettitle;
      // String meetingId =meetId;
      // Parse the text to int
      // print('Meeting ID: $meetingId');

      Meeting newMeeting = Meeting(
        meetTitle: widget.meetingSubTitle,
        meetDateTime: DateTime.now().toString(),
        meetCreater: user!.data.name,
        meetingTime: 1,
        meetingId: meetId,
        department: widget.Dep,
        createrId: user!.data.id,
        membersCount: 0,
        isOnline: true,
        attId: 1,
        meetEndTime: DateTime.now().add(Duration(hours: 3)).toString(),
        membersList: [],
        membersAttended: [],
        location: widget.location,
        description: widget.description,
        meetingSubTitle: widget.meetingSubTitle,
        assignedUser: '',
        assignerId: user!.data.id,
      );

      print('$newMeeting');

      // Call the createMeeting method in ApiService
      await apiService.createMeeting(newMeeting);
      print("Success.....................");
      // Optionally, you can update the UI or navigate to another screen
    } catch (error) {
      print('Error creating meeting: $error');
    }
  }

  DateTime? upcomingDateTime;

  Map<String, dynamic>? meetingDetails;
  Future<void> fetchMeetingDetails(String meetId, callType) async {
    setState(() {
      isLoading = true;
    });
    final String apiUrl = 'https://goltens.in/api/v1/meeting/$meetId';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        setState(() {
          meetingDetails = data;
          upcomingDateTime =
              DateTime.parse(meetingDetails?['data']['meetEndTime']);
          print("${meetingDetails?['data']['meetEndTime']}");
          // Get the current date time
          // DateTime currentDateTime = ;
          // isLoading = false;
        });
        if (DateTime.now().isBefore(upcomingDateTime!)) {
          setState(() {
            isLoading = false;
          });

          _addMemberToAttendedList(meetId, callType);
        } else {
          setState(() {
            isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Meeting has been ended'),
              duration: Duration(seconds: 2),
            ),
          );
        }

        print("$data");
      } else {
        print(
            'Failed to load meeting details. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error loading meeting details: $error');
    }
  }

  Future<void> _addMemberToAttendedList(String meetingId, callType) async {
    //  await fetchMeetingDetails(meetingId);

    // Parse the upcoming date time string into a DateTime object

    final url = 'https://goltens.in/api/v1/meeting/addmember/$meetingId';

    if (user != UserType.admin) {
      final Map<String, dynamic> data = {
        "membersName": user!.data.name,
        "memberInTime": DateTime.now().toLocal().toIso8601String(),
        "memberOutTime": DateTime.now().toLocal().toIso8601String(),
        "memberId": user!.data.id,
        "dateTime": DateTime.now().toLocal().toIso8601String(),
        "location": "location",
        "remark": "remarks",
        "memberdep": user!.data.department,
        "memberphone": user!.data.phone,
        "memberemail": user!.data.email,
        "latitude": 40.7128,
        "longitude": -74.006,
        "digitalSignature": ""
      };

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );
      print(jsonEncode(data));

      if (response.statusCode == 200) {
        if (callType == "GROUP") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ConfereneceMeetingScreen(
                isexit: widget.isscheduled,
                token: _token,
                meetingId: meetingId,
                displayName: user!.data.name,
                micEnabled: isMicOn,
                camEnabled: isCameraOn,
                iscreated: false,
                DateTime: widget.DateTime,
                CreaterName: user!.data.name,
                meetId: widget.meetId,
              ),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OneToOneMeetingScreen(
                token: _token,
                meetingId: meetingId,
                displayName: user!.data.name,
                micEnabled: isMicOn,
                camEnabled: isCameraOn,
              ),
            ),
          );
        }

        // Request successful, handle the response if needed
        print('Member added to attended list successfully');
      } else {
        // Request failed, handle the error
        print(
            'Failed to add member to attended list. Status code: ${response.statusCode}');
      }
    } else {
      if (callType == "GROUP") {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ConfereneceMeetingScreen(
              isexit: widget.isscheduled,
              token: _token,
              meetingId: meetingId,
              displayName: user!.data.name,
              micEnabled: isMicOn,
              camEnabled: isCameraOn,
              iscreated: false,
              DateTime: widget.DateTime,
              CreaterName: user!.data.name,
              meetId: widget.meetId,
            ),
          ),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OneToOneMeetingScreen(
              token: _token,
              meetingId: meetingId,
              displayName: user!.data.name,
              micEnabled: isMicOn,
              camEnabled: isCameraOn,
            ),
          ),
        );
      }
      //  widget.onClickMeetingJoin(
      //           _meetingId.trim(), meetingMode, _displayName.trim());
      // Handle the case where user authentication data is not available
      print('User authentication data is not available');
    }
  }

  // Future<void> _addMemberToAttendedList(String meetingId) async {
  //   final url = 'https://goltens.in/api/v1/meeting/addmember/$meetingId';
  //
  //   if (user != null&& user!.data.type==UserType.user) {
  //     final Map<String, dynamic> data = {
  //       "membersName": user!.data.name,
  //       "memberInTime": DateTime.now().toLocal().toIso8601String(),
  //       "memberOutTime": DateTime.now().toLocal().toIso8601String(),
  //       "memberId": user!.data.id,
  //       "dateTime": DateTime.now().toLocal().toIso8601String(),
  //       "location":"0",
  //       "remark": "remark",
  //       "memberdep":user!.data.department,
  //       "memberphone":user!.data.phone,
  //       "memberemail":user!.data.email,
  //       "latitude": 40.7128,
  //       "longitude": -74.006,
  //         "digitalSignature":""
  //     };
  //
  //     final response = await http.post(
  //       Uri.parse(url),
  //       headers: {'Content-Type': 'application/json'},
  //       body: jsonEncode(data),
  //     );
  //     print(jsonEncode(data));
  //
  //     if (response.statusCode == 200) {
  //       // Request successful, handle the response if needed
  //       print('Member added to attended list successfully');
  //     } else {
  //       // Request failed, handle the error
  //       print('Failed to add member to attended list. Status code: ${response.statusCode}');
  //     }
  //   } else {
  //     // Handle the case where user authentication data is not available
  //     print('User authentication data is not available');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width;
    return WillPopScope(
        onWillPop: _onWillPopScope,
        child: Scaffold(
          appBar: AppBar(
            title: const Text(
              'Online Meeting',
              style: TextStyle(color: Colors.black),
            ),
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
            backgroundColor: appbar,
            centerTitle: true,
            iconTheme: const IconThemeData(color: Colors.black),
          ),
          backgroundColor: Colors.white,
          body: SafeArea(
            child: LayoutBuilder(
              builder:
                  (BuildContext context, BoxConstraints viewportConstraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                        minHeight: viewportConstraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Column(
                        mainAxisAlignment:
                            !kIsWeb && (Platform.isAndroid || Platform.isIOS)
                                ? MainAxisAlignment.center
                                : MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Camera Preview
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 100, horizontal: 36),
                            child: SizedBox(
                              height: 300,
                              width: 200,
                              child: Stack(
                                alignment: Alignment.topCenter,
                                children: [
                                  (cameraController == null) && isCameraOn
                                      ? !(cameraController
                                                  ?.value.isInitialized ??
                                              false)
                                          ? Container(
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12)),
                                              child: const Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              ),
                                            )
                                          : Container(
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12)),
                                              child: const Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              ),
                                            )
                                      : AspectRatio(
                                          aspectRatio: ResponsiveValue<double>(
                                              context,
                                              conditionalValues: [
                                                Condition.equals(
                                                    name: MOBILE,
                                                    value: 1 / 1.55),
                                                Condition.equals(
                                                    name: TABLET,
                                                    value: 16 / 10),
                                                Condition.largerThan(
                                                    name: TABLET,
                                                    value: 16 / 9),
                                              ]).value!,
                                          child: isCameraOn
                                              ? ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  child: CameraPreview(
                                                    cameraController!,
                                                  ))
                                              : Container(
                                                  decoration: BoxDecoration(
                                                      color: Colors.black,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12)),
                                                  child: const Center(
                                                    child: Text(
                                                      "Camera is turned off",
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                  ),
                                                ),
                                        ),
                                  Positioned(
                                    bottom: 16,
                                    // Meeting ActionBar
                                    child: Center(
                                      child: Row(
                                        children: [
                                          // Mic Action Button
                                          ElevatedButton(
                                            onPressed: () => setState(
                                              () => isMicOn = !isMicOn,
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              shape: const CircleBorder(),
                                              padding: EdgeInsets.all(
                                                ResponsiveValue<double>(context,
                                                    conditionalValues: [
                                                      Condition.equals(
                                                          name: MOBILE,
                                                          value: 12),
                                                      Condition.equals(
                                                          name: TABLET,
                                                          value: 15),
                                                      Condition.equals(
                                                          name: DESKTOP,
                                                          value: 18),
                                                    ]).value!,
                                              ),
                                              backgroundColor:
                                                  isMicOn ? Colors.white : red,
                                              foregroundColor: Colors.black,
                                            ),
                                            child: Icon(
                                                isMicOn
                                                    ? Icons.mic
                                                    : Icons.mic_off,
                                                color: isMicOn
                                                    ? grey
                                                    : Colors.white),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              if (isCameraOn) {
                                                cameraController?.dispose();
                                                cameraController = null;
                                              } else {
                                                initCameraPreview();
                                                // cameraController?.resumePreview();
                                              }
                                              setState(() =>
                                                  isCameraOn = !isCameraOn);
                                            },
                                            style: ElevatedButton.styleFrom(
                                              shape: const CircleBorder(),
                                              padding: EdgeInsets.all(
                                                ResponsiveValue<double>(context,
                                                    conditionalValues: [
                                                      Condition.equals(
                                                          name: MOBILE,
                                                          value: 12),
                                                      Condition.equals(
                                                          name: TABLET,
                                                          value: 15),
                                                      Condition.equals(
                                                          name: DESKTOP,
                                                          value: 18),
                                                    ]).value!,
                                              ),
                                              backgroundColor: isCameraOn
                                                  ? Colors.white
                                                  : red,
                                            ),
                                            child: Icon(
                                              isCameraOn
                                                  ? Icons.videocam
                                                  : Icons.videocam_off,
                                              color: isCameraOn
                                                  ? grey
                                                  : Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 30),
                            child: Column(
                              children: [
                                if (isJoinMeetingSelected == null && !widget.isonlyjoin&&
                                    isCreateMeetingSelected == null &&
                                    (user!.data.type != UserType.user ||
                                        allowedIds.contains(user!.data.id)))
                                  MaterialButton(
                                      minWidth: ResponsiveValue<double>(context,
                                          conditionalValues: [
                                            Condition.equals(
                                                name: MOBILE,
                                                value: maxWidth / 1.3),
                                            Condition.equals(
                                                name: TABLET,
                                                value: maxWidth / 1.3),
                                            Condition.equals(
                                                name: DESKTOP, value: 600),
                                          ]).value!,
                                      height: 50,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                      color: appbar,
                                      child: const Text("Create Meeting",
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.black)),
                                      onPressed: () => {
                                            // _createMeeting();
                                            setState(() => {
                                                  isCreateMeetingSelected =
                                                      true,
                                                  isJoinMeetingSelected = true
                                                })
                                          }),
                                const VerticalSpacer(16),
                                if (isJoinMeetingSelected == null &&
                                    isCreateMeetingSelected == null)
                                  MaterialButton(
                                      minWidth: ResponsiveValue<double>(context,
                                          conditionalValues: [
                                            Condition.equals(
                                                name: MOBILE,
                                                value: maxWidth / 1.3),
                                            Condition.equals(
                                                name: TABLET,
                                                value: maxWidth / 1.3),
                                            Condition.equals(
                                                name: DESKTOP, value: 600),
                                          ]).value!,
                                      height: 50,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                      color: appbar,
                                      child: const Text("Join Meeting",
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.black)),
                                      onPressed: () => {
                                            // _addMemberToAttendedList(int.parse(conferenceID.text.trim()));
                                            setState(() => {
                                                  isCreateMeetingSelected =
                                                      false,
                                                  isJoinMeetingSelected = true
                                                })
                                          }),
                                if (isJoinMeetingSelected != null &&
                                    isCreateMeetingSelected != null)
                                  JoiningDetails(
                                    isCreateMeeting: isCreateMeetingSelected!,
                                    onClickMeetingJoin: (meetingId, callType,
                                            displayName) =>
                                        _onClickMeetingJoin(
                                            meetingId, callType, displayName),
                                    meetId: "",
                                  ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ));
  }

  Future<bool> _onWillPopScope() async {
    if (isJoinMeetingSelected != null && isCreateMeetingSelected != null) {
      setState(() {
        isJoinMeetingSelected = null;
        isCreateMeetingSelected = null;
      });
      return false;
    } else {
      return true;
    }
  }

  void initCameraPreview() {
    // Get available cameras
    availableCameras().then((availableCameras) {
      // stores selected camera id
      int selectedCameraId = availableCameras.length > 1 ? 1 : 0;

      cameraController = CameraController(
        availableCameras[selectedCameraId],
        ResolutionPreset.medium,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );
      log("Starting Camera");
      cameraController!.initialize().then((_) {
        if (!mounted) return;
        setState(() {});
      });
    }).catchError((err) {
      log("Error: $err");
    });
  }

  void _onClickMeetingJoin(meetingId, callType, displayName) async {
    if (widget.meetId != "") {
      setState(() {
        meetingId = widget.meetId;
      });
    }
    //  _addMemberToAttendedList(meetingId);
    cameraController?.dispose();
    cameraController = null;
    if (displayName.toString().isEmpty) {
      displayName = "Guest";
    }
    if (isCreateMeetingSelected!) {
      createAndJoinMeeting(callType, displayName);
    } else {
      joinMeeting(callType, displayName, meetingId);
    }
  }

  Future<void> createAndJoinMeeting(callType, displayName) async {
    try {
      var meetingID = await createMeeting(_token);
      if (mounted) {
        _createMeeting(displayName, meetingID);
        if (callType == "GROUP") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ConfereneceMeetingScreen(
                isexit: widget.isscheduled,
                token: _token,
                meetingId: meetingID,
                displayName: displayName,
                micEnabled: isMicOn,
                camEnabled: isCameraOn,
                iscreated: true,
                DateTime: widget.DateTime,
                CreaterName: user!.data.name,
                meetId: widget.meetId,
              ),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OneToOneMeetingScreen(
                token: _token,
                meetingId: meetingID,
                displayName: displayName,
                micEnabled: isMicOn,
                camEnabled: isCameraOn,
              ),
            ),
          );
        }
      }
    } catch (error) {
      showSnackBarMessage(message: error.toString(), context: context);
    }
  }

  Future<void> joinMeeting(callType, displayName, meetingId) async {
    if (meetingId.isEmpty) {
      showSnackBarMessage(
          message: "Please enter Valid Meeting ID", context: context);
      return;
    }
    var validMeeting = await validateMeeting(_token, meetingId);
    if (validMeeting) {
      if (mounted) {
        fetchMeetingDetails(meetingId, callType);
      }
    } else {
      if (mounted) {
        showSnackBarMessage(message: "Invalid Meeting ID", context: context);
      }
    }
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }
}
