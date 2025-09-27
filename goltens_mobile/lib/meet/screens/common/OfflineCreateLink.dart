import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:goltens_core/models/auth.dart';
import 'package:goltens_core/models/meeting.dart';
import 'package:goltens_core/services/meeting.dart';

import 'package:goltens_mobile/provider/global_state.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import 'All_SelectionPage.dart';
import 'OfflineExit.dart';

class OfflineCreateMeetLink extends StatefulWidget {
  final bool isSchedule;
  final bool isscheduled;
  final String location;
  final String Dep;
  final String DateTime;
  final String meetingSubTitle;
  final String description;


  OfflineCreateMeetLink({Key? key, required this.isSchedule, required this.isscheduled, required this.location, required this.Dep, required this.DateTime, required this.meetingSubTitle, required this.description}) : super(key: key);

  @override
  State<OfflineCreateMeetLink> createState() => _OfflineCreateMeetLinkState();
}

class _OfflineCreateMeetLinkState extends State<OfflineCreateMeetLink> {
  Color primaryColor = const Color(0xff80d6ff);
  late TextEditingController inviteLinkController;
  final TextEditingController meetingTitleController = TextEditingController();
  late int _meetingCode;
  final ApiService apiService = ApiService();
  UserResponse? user;

  @override
  void initState() {
    super.initState();
    var uuid = const Uuid();
    _meetingCode = int.parse(uuid.v1().substring(0, 5), radix: 16);
    inviteLinkController = TextEditingController(text: _meetingCode.toString());
meetingTitleController.text=widget.meetingSubTitle;
    final state = context.read<GlobalState>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() => user = state.user);
      }
    });
  }
  // void _shareInviteLink() {
  //   if (inviteLinkController.text.isNotEmpty) {
  //     // Use the Share.share method to share the invite link
  //     Share.share(inviteLinkController.text);
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text('Invite link is empty'),
  //         duration: Duration(seconds: 2),
  //       ),
  //     );
  //   }
  // }

  void _createMeeting() async {
    try {
      String meetingTitle = meetingTitleController.text;
      int meetingId = int.parse(inviteLinkController.text); // Parse the text to int
      print('Meeting ID: $meetingId');

      Meeting newMeeting = Meeting(
        meetTitle: meetingTitle,
        meetDateTime: DateTime.now().toLocal().toIso8601String(),
        meetCreater: user!.data.name,
        meetingTime: 1,
        meetingId: "$meetingId",
        department: user!.data.department,
        createrId: user!.data.id,
        membersCount: 5,
        isOnline: false,
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

      await apiService.createMeeting(newMeeting);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => OfflineExit(
            meetingId: "$meetingId",
            isscheduled: widget.isscheduled,
            CreaterName:user!.data.name,
            DateTime: widget.DateTime,),
        ),
      );
    } catch (error) {
      print('Error creating meeting: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildLottieAnimation(),
              TextFormField(
                controller: meetingTitleController,
                decoration: InputDecoration(
                  labelText: 'Meeting Title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
              ),
              SizedBox(height: 30,),
              const SizedBox(height: 20),
              _buildInviteLinkTextField(),
              // const SizedBox(height: 25),
              // _buildShareInviteLinkButton(),
              const SizedBox(height: 25),
              _buildStartMeetingButton(),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('Meet Code',style: TextStyle(color: Colors.black),),
      backgroundColor: primaryColor,
      centerTitle: true,
      iconTheme: const IconThemeData(color: Colors.black),
    );
  }

  Widget _buildLottieAnimation() {
    return Lottie.asset(
      'assets/json/invite.json', // Replace with your animation file path
      fit: BoxFit.contain,
    );
  }

  TextFormField _buildInviteLinkTextField() {
    return TextFormField(
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        labelText: 'Invite Link',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        suffixIcon: GestureDetector(
          onTap: () => _copyToClipboard(),
          child: const Icon(Icons.copy,color: Colors.black,),
        ),
      ),
      controller: inviteLinkController,
      validator: (value) {
        if (value != null && value.isEmpty) {
          return 'Please enter the invite link';
        }
        return null;
      },
    );
  }

  void _copyToClipboard() {
    if (inviteLinkController.text.isNotEmpty) {
      Clipboard.setData(
        ClipboardData(text: inviteLinkController.text),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invite link copied to clipboard'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }


  ElevatedButton _buildStartMeetingButton() {
    return ElevatedButton(
      onPressed: () async{
        _createMeeting();
        print("$_createMeeting");


      },
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(primaryColor),
        shape: MaterialStateProperty.all<OutlinedBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0), // Adjust the value as needed
          ),
        ),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.video_call, color: Colors.black),
          SizedBox(width: 8),
          Text('Start Meeting', style: TextStyle(color: Colors.black)),
        ],
      ),
    );
  }
}