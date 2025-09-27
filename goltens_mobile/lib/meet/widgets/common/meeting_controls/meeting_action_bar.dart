import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:goltens_core/models/auth.dart';
import 'package:goltens_mobile/utils/allowed_ids.dart';
import 'package:provider/provider.dart';
import 'package:touch_ripple_effect/touch_ripple_effect.dart';

import '../../../../provider/global_state.dart';
import '../../../constants/colors.dart';
import '../../../utils/spacer.dart';

// Meeting ActionBar
class MeetingActionBar extends StatefulWidget {
  // control states
  final bool isMicEnabled, isCamEnabled, isScreenShareEnabled;
  final String recordingState;

  // callback functions
  final void Function() onCallEndButtonPressed,
      onCallLeaveButtonPressed,
      onMicButtonPressed,
      onCameraButtonPressed,
      onChatButtonPressed;

  final void Function(String) onMoreOptionSelected;

  final void Function(TapDownDetails) onSwitchMicButtonPressed;
  const MeetingActionBar({
    Key? key,
    required this.isMicEnabled,
    required this.isCamEnabled,
    required this.isScreenShareEnabled,
    required this.recordingState,
    required this.onCallEndButtonPressed,
    required this.onCallLeaveButtonPressed,
    required this.onMicButtonPressed,
    required this.onSwitchMicButtonPressed,
    required this.onCameraButtonPressed,
    required this.onMoreOptionSelected,
    required this.onChatButtonPressed,
  }) : super(key: key);

  @override
  State<MeetingActionBar> createState() => _MeetingActionBarState();
}

class _MeetingActionBarState extends State<MeetingActionBar> {

  UserResponse? user;

@override
  void initState() {
            final state = context.read<GlobalState>();
 WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        setState(() => user = state.user);
      }
    });
    // TODO: implement initState
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          PopupMenuButton(
              position: PopupMenuPosition.under,
              padding: const EdgeInsets.all(0),
              color: black700,
              icon: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: red),
                  color: red,
                ),
                padding: const EdgeInsets.all(8),
                child: const Icon(
                  Icons.call_end,
                  size: 30,
                  color: Colors.white,
                ),
              ),
              offset: const Offset(0, -185),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onSelected: (value) => {
                    if (value == "leave")
                      widget.onCallLeaveButtonPressed()
                    else if (value == "end")
                      {widget.onCallEndButtonPressed(),
                      }
                  },
              itemBuilder: (context) => <PopupMenuEntry>[
                            if(user!.data.type==UserType.user)

                    _buildMeetingPoupItem(
                      "leave",
                      "Leave",
                      "Only you will leave the call",
                      SvgPicture.asset("assets/ic_leave.svg"),
                    ),
                    const PopupMenuDivider(),
                                    if(user!.data.type!=UserType.user || allowedIds.contains(user!.data.id))

                    _buildMeetingPoupItem(
                      "end",
                      "End",
                      "End call for all participants",
                      SvgPicture.asset("assets/ic_end.svg"),
                    ),
                  ]),

          // Mic Control
          TouchRippleEffect(
            borderRadius: BorderRadius.circular(12),
            rippleColor: widget.isMicEnabled ? blackColor : Colors.white,
            onTap: widget.onMicButtonPressed,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: secondaryColor),
                color: widget.isMicEnabled ? blackColor : Colors.white,
              ),
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Icon(
                    widget.isMicEnabled ? Icons.mic : Icons.mic_off,
                    size: 30,
                    color: widget.isMicEnabled ? Colors.white : blackColor,
                  ),
                  GestureDetector(
                      onTapDown: (details) =>
                          {widget.onSwitchMicButtonPressed(details)},
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Icon(
                          Icons.arrow_drop_down,
                          color: widget.isMicEnabled ? Colors.white : blackColor,
                        ),
                      )),
                ],
              ),
            ),
          ),

          // Camera Control
          TouchRippleEffect(
            borderRadius: BorderRadius.circular(12),
            rippleColor: blackColor,
            onTap: widget.onCameraButtonPressed,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: secondaryColor),
                color: widget.isCamEnabled ? blackColor : Colors.white,
              ),
              padding: const EdgeInsets.all(10),
              child: SvgPicture.asset(
                widget.isCamEnabled
                    ? "assets/ic_video.svg"
                    : "assets/ic_video_off.svg",
                width: 26,
                height: 26,
                color: widget.isCamEnabled ? Colors.white : blackColor,
              ),
            ),
          ),

          TouchRippleEffect(
            borderRadius: BorderRadius.circular(12),
            rippleColor: blackColor,
            onTap: widget.onChatButtonPressed,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: secondaryColor),
                color: blackColor,
              ),
              padding: const EdgeInsets.all(10),
              child: SvgPicture.asset(
                "assets/ic_chat.svg",
                width: 26,
                height: 26,
                color: Colors.white,
              ),
            ),
          ),

          // More options
          PopupMenuButton(
              position: PopupMenuPosition.under,
              padding: const EdgeInsets.all(0),
              color: black700,
              icon: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: secondaryColor),
                  // color: red,
                ),
                padding: const EdgeInsets.all(8),
                child: const Icon(
                  Icons.more_vert,
                  size: 30,
                  color: Colors.white,
                ),
              ),
              offset: const Offset(0, -250),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onSelected: (value) => {widget.onMoreOptionSelected(value.toString())},
              itemBuilder: (context) => <PopupMenuEntry>[
                    // _buildMeetingPoupItem(
                    //   "recording",
                    //   widget.recordingState == "RECORDING_STARTED"
                    //       ? "Stop Recording"
                    //       : widget.recordingState == "RECORDING_STARTING"
                    //           ? "Recording is starting"
                    //           : "Start Recording",
                    //   null,
                    //   SvgPicture.asset("assets/ic_recording.svg"),
                    // ),
                    // const PopupMenuDivider(),
                     _buildMeetingPoupItem(
                      "Meeting Info",
                      "Meeting Info",
                     
                      null,
                      SvgPicture.asset("assets/info-empty.svg"),
                    ),
                    const PopupMenuDivider(),
                    _buildMeetingPoupItem(
                      "screenshare",
                      widget.isScreenShareEnabled
                          ? "Stop Screen Share"
                          : "Start Screen Share",
                      null,
                      SvgPicture.asset("assets/ic_screen_share.svg"),
                    ),
                    const PopupMenuDivider(),
                    _buildMeetingPoupItem(
                      "participants",
                      "Participants",
                      null,
                      SvgPicture.asset("assets/ic_participants.svg"),
                    ),
                     const PopupMenuDivider(),
                   if(user!.data.type!=UserType.user || allowedIds.contains(user!.data.id))
                    _buildMeetingPoupItem(
                      "Invite",
                      "Invite",
                      null,
                      SvgPicture.asset("assets/ic_participants.svg"),
                    ),
                  ]),
        ],
      ),
    );
  }

  PopupMenuItem<dynamic> _buildMeetingPoupItem(
      String value, String title, String? description, Widget leadingIcon) {
    return PopupMenuItem(
      value: value,
      padding: const EdgeInsets.fromLTRB(16, 0, 0, 0),
      child: Row(children: [
        leadingIcon,
        const HorizontalSpacer(12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white),
            ),
            if (description != null) const VerticalSpacer(4),
            if (description != null)
              Text(
                description,
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w500, color: black400),
              )
          ],
        )
      ]),
    );
  }
}
