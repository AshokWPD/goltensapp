import 'dart:async';
// import 'dart:html';

import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter/material.dart';
import 'package:videosdk/videosdk.dart';

import '../../constants/colors.dart';
import '../../utils/api.dart';
import '../../utils/spacer.dart';
import '../../utils/toast.dart';
import 'recording_indicator.dart';

class MeetingAppBar extends StatefulWidget {
  final String token;
  final Room meeting;
  final String recordingState;
  final bool isFullScreen;
  const MeetingAppBar(
      {super.key,
      required this.meeting,
      required this.token,
      required this.isFullScreen,
      required this.recordingState});

  @override
  State<MeetingAppBar> createState() => MeetingAppBarState();
}

class MeetingAppBarState extends State<MeetingAppBar> {
  Duration? elapsedTime;
  Timer? sessionTimer;

  List<VideoDeviceInfo> cameras = [];

  @override
  void initState() {
    startTimer();
    // Holds available cameras info
    loadCameras();

    super.initState();
  }

  Future<void> loadCameras() async {
    // This returns Future<List<VideoDeviceInfo>>
    cameras = widget.meeting.videoDevices ?? [];
    setState(() {}); // update UI after loading devices
  }

// When switching camera - get device object, call changeCam with it
  void switchCamera() {
    // Find a camera different from current
    VideoDeviceInfo? newCam = cameras.firstWhere(
      (camera) => camera.deviceId != widget.meeting.selectedCam?.deviceId,
      orElse: () => cameras[0], // fallback to first camera available
    );

    widget.meeting.changeCam(newCam); // Pass the VideoDeviceInfo (not id)
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
        duration: const Duration(milliseconds: 300),
        crossFadeState: !widget.isFullScreen
            ? CrossFadeState.showFirst
            : CrossFadeState.showSecond,
        secondChild: const SizedBox.shrink(),
        firstChild: Padding(
          padding: const EdgeInsets.fromLTRB(12.0, 10.0, 8.0, 0.0),
          child: Row(
            children: [
              if (widget.recordingState == "RECORDING_STARTING" ||
                  widget.recordingState == "RECORDING_STOPPING" ||
                  widget.recordingState == "RECORDING_STARTED")
                RecordingIndicator(recordingState: widget.recordingState),
              if (widget.recordingState == "RECORDING_STARTING" ||
                  widget.recordingState == "RECORDING_STOPPING" ||
                  widget.recordingState == "RECORDING_STARTED")
                const HorizontalSpacer(),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          widget.meeting.id,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white),
                        ),
                        GestureDetector(
                          child: const Padding(
                            padding: EdgeInsets.fromLTRB(8, 0, 0, 0),
                            child: Icon(
                              Icons.copy,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                          onTap: () {
                            Clipboard.setData(
                                ClipboardData(text: widget.meeting.id));
                            showSnackBarMessage(
                                message: "Meeting ID has been copied.",
                                context: context);
                          },
                        ),
                      ],
                    ),
                    // VerticalSpacer(),
                    Text(
                      elapsedTime == null
                          ? "00:00:00"
                          : elapsedTime.toString().split(".").first,
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: black400),
                    )
                  ],
                ),
              ),
              IconButton(
                icon: SvgPicture.asset(
                  "assets/ic_switch_camera.svg",
                  height: 24,
                  width: 24,
                ),
                onPressed: () {
                  VideoDeviceInfo newCam = cameras.firstWhere((camera) =>
                      camera.deviceId != widget.meeting.selectedCamId);
                  widget.meeting.changeCam(newCam);
                },
              ),
            ],
          ),
        ));
  }

  Future<void> startTimer() async {
    dynamic session = await fetchSession(widget.token, widget.meeting.id);
    DateTime sessionStartTime = DateTime.parse(session['start']);
    final difference = DateTime.now().difference(sessionStartTime);

    setState(() {
      elapsedTime = difference;
      sessionTimer = Timer.periodic(
        const Duration(seconds: 1),
        (timer) {
          setState(() {
            elapsedTime = Duration(
                seconds: elapsedTime != null ? elapsedTime!.inSeconds + 1 : 0);
          });
        },
      );
    });
    // log("session start time" + session.data[0].start.toString());
  }

  @override
  void dispose() {
    if (sessionTimer != null) {
      sessionTimer!.cancel();
    }
    super.dispose();
  }
}
