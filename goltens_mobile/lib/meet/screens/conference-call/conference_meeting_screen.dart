import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:goltens_core/models/auth.dart';
import 'package:goltens_mobile/meet/screens/common/All_SelectionPage.dart';
import 'package:goltens_mobile/meet/screens/common/EmployeeSelectionPage.dart';
import 'package:goltens_mobile/provider/global_state.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:videosdk/videosdk.dart';

import '../../common/app_bar/meeting_appbar.dart';
import '../../common/app_bar/web_meeting_appbar.dart';
import '../../common/chat/chat_view.dart';
import '../../common/joining/waiting_to_join.dart';
import '../../common/meeting_controls/meeting_action_bar.dart';
import '../../common/participant/participant_list.dart';
import '../../conference-call/conference_participant_grid.dart';
import '../../conference-call/conference_screenshare_view.dart';
import '../../constants/colors.dart';
import '../../utils/toast.dart';
import '../common/Meet-Type_screen.dart';
import '../common/join_screen.dart';

class ConfereneceMeetingScreen extends StatefulWidget {
  final String meetId;
  final bool iscreated;
  final String meetingId, token, displayName;
  final bool micEnabled, camEnabled, chatEnabled;
  final bool isexit;
  final String DateTime;
  final String CreaterName;


  const ConfereneceMeetingScreen({
    Key? key,
    required this.meetingId,
    required this.token,
    required this.displayName,
    this.micEnabled = true,
    this.camEnabled = true,
    this.chatEnabled = true, required this.iscreated, required this.isexit, required this.DateTime, required this.CreaterName, required this.meetId,
  }) : super(key: key);

  @override
  State<ConfereneceMeetingScreen> createState() =>
      _ConfereneceMeetingScreenState();
}

class _ConfereneceMeetingScreenState extends State<ConfereneceMeetingScreen> {
  bool isRecordingOn = false;
  bool showChatSnackbar = true;
  String recordingState = "RECORDING_STOPPED";
  // Meeting
  late Room meeting;
  bool _joined = false;
  UserResponse? user;
  bool isloading = true;
  // Streams
  Stream? shareStream;
  Stream? videoStream;
  Stream? audioStream;
  Stream? remoteParticipantShareStream;

  bool fullScreen = false;

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
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

    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    // Create instance of Room (Meeting)
    Room room = VideoSDK.createRoom(
      roomId: widget.meetingId,
      token: widget.token,
      displayName: widget.displayName,
      micEnabled: widget.micEnabled,
      camEnabled: widget.camEnabled,
      maxResolution: 'hd',
      multiStream: true,
      defaultCameraIndex: kIsWeb ? 0 : 1,
      notification: const NotificationInfo(
        title: "Goltens Meet",
        message: "Goltens Meet is sharing screen in the meeting",
        icon: "notification_share", // drawable icon name
      ),
    );

    // Register meeting events
    registerMeetingEvents(room);

    // Join meeting
    room.join();
    Timer(Duration(seconds: 1 ), ()
    {
      widget.isexit ? showMeetDialog(context, true) : null;
    });
  }

  Widget _meetcode() {
    if ("${widget.meetingId}".isNotEmpty) {
      return Text("Meet Code : ${widget.meetingId}",style: TextStyle(fontSize: 16),);
    } else {
      return Text("No meeting code available");
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
            borderRadius: BorderRadius.circular(20.0), // Adjust the radius as needed
          ),
          content: Container(
            width: double.infinity,
            height: 350,
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Add your icon here
                Icon(
                  Icons.check_circle,
                  color: blackColor,
                  size: 60,
                ),
                SizedBox(height: 16),
                Text(
                  'Congratulations!',
                  style: TextStyle(
                    color: blackColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Your meeting has been scheduled successfully.',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _meetcode(),
                    IconButton(
                      icon: Icon(Icons.copy),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: widget.meetingId));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Copied to clipboard')),
                        );
                      },
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    user!.data.type==UserType.admin?
                    ElevatedButton.icon(
                      onPressed: () {
                        print('fhndnffjn');
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>EmpSelectionPage(
                          invitelink: widget.meetingId,
                          isSchedule: false,
                          channelname: widget.meetingId,
                          isoffline: false,
                          isscheduled: widget.isexit,
                          Dep: '',
                          location: '',
                          DateTime: widget.DateTime,
                          CreaterName: widget.CreaterName,
                          meetId: widget.meetingId,)));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: blackColor,
                      ),
                      icon: Icon(Icons.share, color: Colors.white),
                      label: Text(
                        'Share',
                        style: TextStyle(color: Colors.white),
                      ),
                    ):ElevatedButton.icon(
                      onPressed: () {
                        print('fhndnffjn');
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>AllSelectionPage(
                          invitelink: widget.meetingId,
                          isSchedule: false,
                          channelname: widget.meetingId,
                          isoffline: false,
                          isscheduled: widget.isexit,
                          Dep: '',
                          location: '',
                          DateTime: widget.DateTime,
                          CreaterName: widget.CreaterName,
                          meetId: widget.meetingId,)));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: blackColor,
                      ),
                      icon: Icon(Icons.share, color: Colors.white),
                      label: Text(
                        'Share',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        meeting.leave();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      icon: Icon(Icons.exit_to_app, color: Colors.white),
                      label: Text(
                        'Exit',
                        style: TextStyle(color: Colors.white),
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


  void _showMeetingInfo(String meetingId) async {
    // Fetch the meeting details (description and topic)
    final meetingDetails = await fetchMeetingDescription(meetingId);

    if (meetingDetails != null) {
      final description =
          meetingDetails['description'] ?? 'No description available';
      final topic = meetingDetails['topic'] ?? 'No topic available';

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(topic), // Show the topic as the title
            content: Text(description), // Show the description as the content
            actions: [
              TextButton(
                child: const Text('Close'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      // Show an error dialog if the meeting details couldn't be fetched
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('Failed to load meeting details.'),
            actions: [
              TextButton(
                child: const Text('Close'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  Future<Map<String, String>?> fetchMeetingDescription(String meetingId) async {
    final String apiUrl = 'https://goltens.in/api/v1/meeting/$meetingId';
    print(apiUrl);

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success'] == true &&
            responseData.containsKey('data')) {
          final String description = responseData['data']['description'];
          final String topic = responseData['data']['meetTitle'];
          return {
            'description': description,
            'topic': topic,
          };
        } else {
          print('Description field not found in response.');
          return null;
        }
      } else {
        print(
            'Failed to load meeting details. Status code: ${response.statusCode}');
        return null;
      }
    } catch (error) {
      print('Error loading meeting details: $error');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusbarHeight = MediaQuery.of(context).padding.top;
    bool isWebMobile = kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.android);
    return WillPopScope(
      onWillPop: _onWillPopScope,
      child: _joined
          ? SafeArea(
              child: Scaffold(
                   backgroundColor: blackColor,
                  body: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      !isWebMobile &&
                              (kIsWeb || Platform.isMacOS || Platform.isWindows)
                          ? WebMeetingAppBar(
                              meeting: meeting,
                              token: widget.token,
                              recordingState: recordingState,
                              isMicEnabled: audioStream != null,
                              isCamEnabled: videoStream != null,
                              isLocalScreenShareEnabled: shareStream != null,
                              isRemoteScreenShareEnabled:
                                  remoteParticipantShareStream != null,
                            )
                          : MeetingAppBar(
                              meeting: meeting,
                              token: widget.token,
                              recordingState: recordingState,
                              isFullScreen: fullScreen,
                            ),
                      const Divider(),
                      Expanded(
                          child: Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 15.0, vertical: 8.0),
                        child: Flex(
                          direction: ResponsiveValue<Axis>(context,
                              conditionalValues: [
                                Condition.equals(
                                    name: MOBILE, value: Axis.vertical),
                                Condition.largerThan(
                                    name: MOBILE, value: Axis.horizontal),
                              ]).value!,
                          children: [
                            ConferenseScreenShareView(meeting: meeting),
                            Expanded(
                              child:
                                  ConferenceParticipantGrid(meeting: meeting),
                            ),
                          ],
                        ),
                      )),
                      !isWebMobile &&
                              (kIsWeb || Platform.isMacOS || Platform.isWindows)
                          ? Container()
                          : Column(
                              children: [
                                const Divider(),
                                AnimatedCrossFade(
                                  duration: const Duration(milliseconds: 300),
                                  crossFadeState: !fullScreen
                                      ? CrossFadeState.showFirst
                                      : CrossFadeState.showSecond,
                                  secondChild: const SizedBox.shrink(),
                                  firstChild: MeetingActionBar(
                                    isMicEnabled: audioStream != null,
                                    isCamEnabled: videoStream != null,
                                    isScreenShareEnabled: shareStream != null,
                                    recordingState: recordingState,
                                    // Called when Call End button is pressed
                                    onCallEndButtonPressed: () {

                                      print("=++++++++++++++++++++++++++++++++++++");
                                      if (videoStream != null) {
                                        meeting.disableCam();
                                      }

                                      meeting.end();
                                    },

                                    onCallLeaveButtonPressed: () {
                                      if (videoStream != null) {
                                        meeting.disableCam();
                                      }
                                      meeting.leave();
                                    },
                                    // Called when mic button is pressed
                                    onMicButtonPressed: () {
                                      if (audioStream != null) {
                                        meeting.muteMic();
                                      } else {
                                        meeting.unmuteMic();
                                      }
                                    },
                                    // Called when camera button is pressed
                                    onCameraButtonPressed: () {
                                      if (videoStream != null) {
                                        meeting.disableCam();
                                      } else {
                                        meeting.enableCam();
                                      }
                                    },

                                    onSwitchMicButtonPressed: (details) async {
                                      List<AudioDeviceInfo> outptuDevice =
                                          meeting.audioDevices??[];
                                      double bottomMargin =
                                          (70.0 * outptuDevice.length);
                                      final screenSize =
                                          MediaQuery.of(context).size;
                                      await showMenu(
                                        context: context,
                                        color: black700,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12)),
                                        position: RelativeRect.fromLTRB(
                                          screenSize.width -
                                              details.globalPosition.dx,
                                          details.globalPosition.dy -
                                              bottomMargin,
                                          details.globalPosition.dx,
                                          (bottomMargin),
                                        ),
                                        items: outptuDevice.map((e) {
                                          return PopupMenuItem(
                                              value: e, child: Text(e.label,style: TextStyle(color: Colors.white),));
                                        }).toList(),
                                        elevation: 8.0,
                                      ).then((value) {
                                        if (value != null) {
                                          meeting.switchAudioDevice(value);
                                        }
                                      });
                                    },

                                    onChatButtonPressed: () {
                                      setState(() {
                                        showChatSnackbar = false;
                                      });
                                      showModalBottomSheet(
                                        context: context,
                                        constraints: BoxConstraints(
                                            maxHeight: MediaQuery.of(context)
                                                    .size
                                                    .height -
                                                statusbarHeight),
                                        isScrollControlled: true,
                                        builder: (context) => ChatView(
                                            key: const Key("ChatScreen"),
                                            meeting: meeting),
                                      ).whenComplete(() => {
                                            setState(() {
                                              showChatSnackbar = true;
                                            })
                                          });
                                    },

                                    // Called when more options button is pressed
                                    onMoreOptionSelected: (option) {
                                      // Showing more options dialog box
                                      if (option == "screenshare") {
                                        if (remoteParticipantShareStream ==
                                            null) {
                                          if (shareStream == null) {
                                            meeting.enableScreenShare();
                                          } else {
                                            meeting.disableScreenShare();
                                          }
                                        } else {
                                          showSnackBarMessage(
                                              message:
                                                  "Someone is already presenting",
                                              context: context);
                                        }
                                      } else if (option == "recording") {
                                        if (recordingState ==
                                            "RECORDING_STOPPING") {
                                          showSnackBarMessage(
                                              message:
                                                  "Recording is in stopping state",
                                              context: context);
                                        } else if (recordingState ==
                                            "RECORDING_STARTED") {
                                          meeting.stopRecording();
                                        } else if (recordingState ==
                                            "RECORDING_STARTING") {
                                          showSnackBarMessage(
                                              message:
                                                  "Recording is in starting state",
                                              context: context);
                                        } else {
                                          meeting.startRecording();
                                        }
                                      }else if (option == "Meeting Info") {
                                      _showMeetingInfo(meeting.id);
                                      } else if (option == "participants") {
                                        showModalBottomSheet(
                                          context: context,
                                          isScrollControlled: false,
                                          builder: (context) =>
                                              ParticipantList(meeting: meeting),
                                        );
                                      }else if (option == "Invite Others")
                                        user!.data.type==UserType.admin ?
                                      {
                              Navigator.push(context, MaterialPageRoute(builder: (context)=>AllSelectionPage(
                                invitelink: widget.meetingId,
                                isSchedule: false,
                                channelname: widget.meetingId,
                                isoffline: false,
                                isscheduled: widget.isexit,
                                Dep: '',location: '',
                                DateTime: widget.DateTime,
                                CreaterName: widget.CreaterName,
                                meetId: widget.meetingId,)))
                                      }:{
                                      Navigator.push(context, MaterialPageRoute(builder: (context)=>EmpSelectionPage(
                                      invitelink: widget.meetingId,
                                      isSchedule: false,
                                      channelname: widget.meetingId,
                                      isoffline: false,
                                      isscheduled: widget.isexit,
                                      Dep: '',location: '',
                                      DateTime: widget.DateTime,
                                      CreaterName: widget.CreaterName,
                                      meetId: widget.meetingId,)))};
                                    }, meetId:widget.meetingId ,
                                  ),
                                ),
                              ],
                            ),
                    ],
                  )),
            )
          : const WaitingToJoin(),
    );
  }

  void registerMeetingEvents(Room _meeting) {
    // Called when joined in meeting
    _meeting.on(
      Events.roomJoined,
      () {
        setState(() {
          meeting = _meeting;
          _joined = true;
        });

        subscribeToChatMessages(_meeting);
      },
    );

    // Called when meeting is ended
    _meeting.on(Events.roomLeft, (String? errorMsg) {
      if (errorMsg != null) {
        showSnackBarMessage(
            message: "Meeting left due to $errorMsg !!", context: context);
      }
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MeetTypeScreen(meetId: '',)),
          (route) => false);
    });

    // Called when recording is started
    _meeting.on(Events.recordingStateChanged, (String status) {
      showSnackBarMessage(
          message:
              "Meeting recording ${status == "RECORDING_STARTING" ? "is starting" : status == "RECORDING_STARTED" ? "started" : status == "RECORDING_STOPPING" ? "is stopping" : "stopped"}",
          context: context);

      setState(() {
        recordingState = status;
      });
    });

    // Called when stream is enabled
    _meeting.localParticipant.on(Events.streamEnabled, (Stream _stream) {
      if (_stream.kind == 'video') {
        setState(() {
          videoStream = _stream;
        });
      } else if (_stream.kind == 'audio') {
        setState(() {
          audioStream = _stream;
        });
      } else if (_stream.kind == 'share') {
        setState(() {
          shareStream = _stream;
        });
      }
    });

    // Called when stream is disabled
    _meeting.localParticipant.on(Events.streamDisabled, (Stream _stream) {
      if (_stream.kind == 'video' && videoStream?.id == _stream.id) {
        setState(() {
          videoStream = null;
        });
      } else if (_stream.kind == 'audio' && audioStream?.id == _stream.id) {
        setState(() {
          audioStream = null;
        });
      } else if (_stream.kind == 'share' && shareStream?.id == _stream.id) {
        setState(() {
          shareStream = null;
        });
      }
    });

    // Called when presenter is changed
    _meeting.on(Events.presenterChanged, (_activePresenterId) {
      Participant? activePresenterParticipant =
          _meeting.participants[_activePresenterId];

      // Get Share Stream
      Stream? _stream = activePresenterParticipant?.streams.values
          .singleWhere((e) => e.kind == "share");

      setState(() => remoteParticipantShareStream = _stream);
    });

    _meeting.on(
        Events.error,
        (error) => {
              showSnackBarMessage(
                  message: error['name'].toString() +
                      " :: " +
                      error['message'].toString(),
                  context: context)
            });
  }

  void subscribeToChatMessages(Room meeting) {
    meeting.pubSub.subscribe("CHAT", (message) {
      if (message.senderId != meeting.localParticipant.id) {
        if (mounted) {
          if (showChatSnackbar) {
            showSnackBarMessage(
                message: message.senderName + ": " + message.message,
                context: context);
          }
        }
      }
    });
  }

  Future<bool> _onWillPopScope() async {
    meeting.leave();
    return true;
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
