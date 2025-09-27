import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:goltens_mobile/meet/constants/file.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:goltens_core/models/auth.dart';
import 'package:goltens_core/services/meeting.dart';
import 'package:goltens_mobile/components/update/signature.dart';
import 'package:goltens_mobile/pages/others/app_choose_page.dart';
import 'package:goltens_mobile/utils/allowed_ids.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
// import 'package:share/share.dart';
import '../../../meet_main.dart';
import 'All_SelectionPage.dart';
import '../../../provider/global_state.dart';
import 'EmployeeSelectionPage.dart';

class OfflineExit extends StatefulWidget {
  final String meetingId;
  final String CreaterName;
  final bool isscheduled;
  final String DateTime;

  const OfflineExit({
    super.key,
    required this.meetingId,
    required this.isscheduled,
    required this.CreaterName,
    required this.DateTime,
  });

  @override
  State<OfflineExit> createState() => _OfflineExitState();
}

class _OfflineExitState extends State<OfflineExit> {
  Color primaryColor = const Color(0xff80d6ff);
  UserResponse? user;
  final ApiService apiService = ApiService();
  List<Map<String, dynamic>> filesArr = [];
  @override
  void initState() {
    final state = context.read<GlobalState>();

    // TODO: implement initState
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        setState(() => user = state.user);
      }
    });
    // Timer(Duration(microseconds:1 ), ()
    // {
    //   widget.isscheduled ? showMeetDialog(context, true) : null;
    // });
    super.initState();
  }

  void _shareInviteLink(BuildContext context) {
    if (widget.meetingId.isNotEmpty) {
      // Share.
      Share.share(widget.meetingId, subject: "Meet Code");
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invite link is empty'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // void showMeetDialog(BuildContext context, bool isOnline) {
  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         backgroundColor: Colors.white,
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(20.0),
  //         ),
  //         content: Container(
  //           width: double.infinity,
  //           height: 350,
  //           padding: EdgeInsets.all(16),
  //           child: Column(
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             crossAxisAlignment: CrossAxisAlignment.center,
  //             children: [
  //               Icon(
  //                 Icons.check_circle,
  //                 color: primaryColor,
  //                 size: 60,
  //               ),
  //               SizedBox(height: 16),
  //               Text(
  //                 'Congratulations!',
  //                 style: TextStyle(
  //                   color: Colors.black,
  //                   fontSize: 20,
  //                   fontWeight: FontWeight.bold,
  //                 ),
  //               ),
  //               SizedBox(height: 16),
  //               Text(
  //                 'Your meeting has been scheduled successfully.',
  //                 style: TextStyle(
  //                   fontSize: 16,
  //                 ),
  //               ),
  //               SizedBox(height: 24),
  //               Row(
  //                 mainAxisAlignment: MainAxisAlignment.spaceAround,
  //                 children: [
  //                   ElevatedButton.icon(
  //                     onPressed: () {
  //                       print('fhndnffjn');
  //                       Navigator.push(context, MaterialPageRoute(builder: (context)=>EmpSelectionPage(
  //                         invitelink: widget.meetingId,
  //                         isSchedule: false,
  //                         channelname: widget.meetingId,
  //                         isoffline: true,
  //                         isscheduled: widget.isscheduled,
  //                         Dep: '',
  //                         location: '',
  //                         DateTime: widget.DateTime,
  //                         CreaterName: widget.CreaterName,
  //                         meetId: widget.meetingId,)));
  //                     },
  //                     style: ButtonStyle(
  //                       backgroundColor: MaterialStateProperty.all<Color>(primaryColor),
  //                       shape: MaterialStateProperty.all<OutlinedBorder>(
  //                         RoundedRectangleBorder(
  //                           borderRadius: BorderRadius.circular(20.0), // Adjust the value as needed
  //                         ),
  //                       ),
  //                     ),
  //                     icon: Icon(Icons.share, color: Colors.black),
  //                     label: Text(
  //                       'Share',
  //                       style: TextStyle(color: Colors.black),
  //                     ),
  //                   ),
  //                   ElevatedButton.icon(
  //                     onPressed: () {
  //                       Navigator.pop(context);
  //                       Navigator.pushReplacement(
  //                         context,
  //                         MaterialPageRoute(
  //                           builder: (context) => MeetMain(meetId: '',),
  //                         ),
  //                       );
  //                     },
  //                     style: ButtonStyle(
  //                       backgroundColor: MaterialStateProperty.all<Color>(primaryColor),
  //                       shape: MaterialStateProperty.all<OutlinedBorder>(
  //                         RoundedRectangleBorder(
  //                           borderRadius: BorderRadius.circular(20.0), // Adjust the value as needed
  //                         ),
  //                       ),
  //                     ),
  //                     icon: Icon(Icons.exit_to_app, color: Colors.black),
  //                     label: Text(
  //                       'Exit',
  //                       style: TextStyle(color: Colors.black),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ],
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

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
          return {'description': description, 'topic': topic};
        } else {
          print('Description field not found in response.');
          return null;
        }
      } else {
        print(
          'Failed to load meeting details. Status code: ${response.statusCode}',
        );
        return null;
      }
    } catch (error) {
      print('Error loading meeting details: $error');
      return null;
    }
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
                child: Text('Close'),
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
            title: Text('Error'),
            content: Text('Failed to load meeting details.'),
            actions: [
              TextButton(
                child: Text('Close'),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _meetcode(),
                  IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: widget.meetingId));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Copied to clipboard')),
                      );
                    },
                  ),
                ],
              ),
              _buildLottieAnimation(),
              const SizedBox(height: 20),
              user!.data.type != UserType.user ||
                      allowedIds.contains(user!.data.id)
                  ? _buildShareInviteLinkButton()
                  : const SizedBox(),
              const SizedBox(height: 20),
              user!.data.type != UserType.user ||
                      allowedIds.contains(user!.data.id)
                  ? _buildShareFilesButton()
                  : const SizedBox(),
              const SizedBox(height: 20),
              user!.data.type != UserType.user ||
                      allowedIds.contains(user!.data.id)
                  ? _buildShareInviteOthersButton()
                  : const SizedBox(),

              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  _showFileDialog(context, widget.meetingId);
                },
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all<Color>(primaryColor),
                  shape: WidgetStateProperty.all<OutlinedBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        20.0,
                      ), // Adjust the value as needed
                    ),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.attach_file, color: Colors.black),
                    SizedBox(width: 8),
                    Text(
                      'View Documents',
                      style: TextStyle(color: Colors.black),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  _showMeetingInfo(widget.meetingId);
                },
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all<Color>(primaryColor),
                  shape: WidgetStateProperty.all<OutlinedBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        20.0,
                      ), // Adjust the value as needed
                    ),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.info, color: Colors.black),
                    SizedBox(width: 8),
                    Text('Meeting Info', style: TextStyle(color: Colors.black)),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              _buildEndMeetingButton(context),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('Meet Page', style: TextStyle(color: Colors.black)),
      backgroundColor: primaryColor,
      centerTitle: true,
      iconTheme: const IconThemeData(color: Colors.black),
    );
  }

  Widget _meetcode() {
    if (widget.meetingId.isNotEmpty) {
      return Text(
        "Meet Code : ${widget.meetingId}",
        style: const TextStyle(fontSize: 16),
      );
    } else {
      // Handle case where meetingId is empty
      return const Text("No meeting code available");
    }
  }

  Widget _buildLottieAnimation() {
    return Lottie.asset(
      'assets/json/invite.json', // Replace with your animation file path
      fit: BoxFit.contain,
    );
  }

  Widget bottomSheetIcon(
    IconData icons,
    Color color,
    String text,
    void Function() onPress,
  ) {
    return InkWell(
      onTap: onPress,
      borderRadius: const BorderRadius.all(Radius.circular(100.0)),
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: color,
            child: Icon(icons, size: 29, color: Colors.white),
          ),
          const SizedBox(height: 5),
          Text(text, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  ElevatedButton _buildShareInviteLinkButton() {
    return user!.data.type == UserType.admin
        ? ElevatedButton(
            onPressed: () async {
              // _shareInviteLink();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AllSelectionPage(
                    DateTime: widget.DateTime,
                    CreaterName: user!.data.name,
                    invitelink: widget.meetingId,
                    isSchedule: false,
                    channelname: widget.meetingId,
                    isoffline: true,
                    isscheduled: false,
                    location: '',
                    Dep: '',
                    meetId: widget.meetingId,
                  ),
                ),
              );
            },
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all<Color>(primaryColor),
              shape: WidgetStateProperty.all<OutlinedBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    20.0,
                  ), // Adjust the value as needed
                ),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.group, color: Colors.black),
                SizedBox(width: 8),
                Text('Invite Employees', style: TextStyle(color: Colors.black)),
              ],
            ),
          )
        : ElevatedButton(
            onPressed: () async {
              // _shareInviteLink();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EmpSelectionPage(
                    DateTime: widget.DateTime,
                    CreaterName: user!.data.name,
                    invitelink: widget.meetingId,
                    isSchedule: false,
                    channelname: widget.meetingId,
                    isoffline: true,
                    isscheduled: false,
                    location: '',
                    Dep: '',
                    meetId: widget.meetingId,
                  ),
                ),
              );
            },
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all<Color>(primaryColor),
              shape: WidgetStateProperty.all<OutlinedBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    20.0,
                  ), // Adjust the value as needed
                ),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.group, color: Colors.black),
                SizedBox(width: 8),
                Text('Invite Employees', style: TextStyle(color: Colors.black)),
              ],
            ),
          );
  }

  void _showPreviewDialog(BuildContext context, String fileData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          // title: const Text('Files'),
          content: SizedBox(
            width: double.maxFinite,
            // height: double.maxFinite,
            child: fileData.endsWith(".pdf")
                ? const PDF(swipeHorizontal: true).cachedFromUrl(fileData)
                : Image.network(fileData),
          ),
          actions: [
            TextButton(
              onPressed: () {
                downloadFile(fileData);
              },
              child: const Text('Download'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Future<void> downloadFile(String url) async {
    // Get the filename from the URL
    String fileName = url.split('/').last;

    // Determine the directory to store the downloaded file
    Directory? directory;
    if (Platform.isAndroid) {
      directory = await getExternalStorageDirectory();
    } else if (Platform.isIOS) {
      directory = await getApplicationDocumentsDirectory();
    }

    // Create the save path
    String savePath = '${directory!.path}/$fileName';

    // Check if the file already exists
    if (await File(savePath).exists()) {
      print('File already exists. Path: $savePath');
      return;
    }

    // Start downloading
    try {
      await FlutterDownloader.enqueue(
        url: url,
        savedDir: directory.path,
        fileName: fileName,
        showNotification: true,
        openFileFromNotification: true,
      );
      print('Download successful. Path: $savePath');
    } catch (e) {
      print('Error downloading file: $e');
    }
  }

  void _showFileDialog(BuildContext context, String meetId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return FutureBuilder<List<String>>(
          future: fetchFiles(meetId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return AlertDialog(
                title: const Text('Error'),
                content: const Text('Failed to load files'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Close'),
                  ),
                ],
              );
            } else {
              return AlertDialog(
                title: const Text('Files'),
                content: SizedBox(
                  width: double.maxFinite,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: snapshot.data!.length ?? 0,
                    itemBuilder: (context, index) {
                      final file = snapshot.data![index];
                      return ListTile(
                        leading: file.endsWith(".pdf")
                            ? Image.asset("assets/sheet.png")
                            : Image.asset("assets/picture.png"),
                        title: file.endsWith(".pdf")
                            ? const Text(
                                "PDF",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              )
                            : const Text(
                                "Image",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                        trailing: IconButton(
                          icon: const Icon(Icons.open_in_new),
                          onPressed: () {
                            _showPreviewDialog(context, file);
                          },
                        ),
                      );
                    },
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Close'),
                  ),
                ],
              );
            }
          },
        );
      },
    );
  }

  void updateLinks(String url) async {
    var headers = {'Content-Type': 'application/json'};

    List<String> filelink = await fetchFiles(widget.meetingId);

    setState(() {
      filelink.add(url);
    });

    var request = http.Request(
      'PUT',
      Uri.parse('https://goltens.in/api/v1/meeting/${widget.meetingId}'),
    );
    request.body = json.encode({
      "membersCount": 0,
      "meetEndTime": "${DateTime.now().add(const Duration(hours: 1))}",
      "filelinks": filelink,
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
    } else {
      print(response.reasonPhrase);
    }
  }

  void showFileAttachmentOptions() {
    Future<void> pickFiles(
      FileType fileType, {
      List<String>? allowedExtensions,
    }) async {
      try {
        if (fileType == FileType.image && allowedExtensions == null) {
          final pickedFile = await ImagePicker().pickImage(
            source: ImageSource.gallery,
          );

          if (pickedFile != null) {
            filesArr.add({'file': File(pickedFile.path), 'type': fileType});
            await uploadFile(File(pickedFile.path));
            if (mounted) Navigator.pop(context);
            if (mounted) {
              const snackBar = SnackBar(content: Text('Photo Added'));
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            }
          }
          return;
        }

        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: fileType,
          allowMultiple: true,
          allowedExtensions: allowedExtensions, // Pass extensions here
        );

        if (result != null) {
          List<File> files = result.paths.map((path) {
            if (path != null) {
              return File(path);
            } else {
              throw Exception('Cannot load files');
            }
          }).toList();

          for (var file in files) {
            filesArr.add({'file': file, 'type': fileType});
            await uploadFile(file);
          }

          if (mounted) Navigator.pop(context);
          if (mounted) {
            final snackBar = SnackBar(
              content: Text('${files.length} Files Added'),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }
        }
      } catch (e) {
        if (mounted) Navigator.pop(context);
        if (mounted) {
          final snackBar = SnackBar(content: Text(e.toString()));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      }
    }

    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (builder) => SizedBox(
        height: 200,
        width: MediaQuery.of(context).size.width,
        child: Card(
          margin: const EdgeInsets.all(18.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    bottomSheetIcon(
                      Icons.insert_drive_file,
                      Colors.indigo,
                      "Document",
                      () async => await pickFiles(
                        FileType.custom,
                        allowedExtensions: ['pdf'],
                      ),
                    ),
                    const SizedBox(width: 40),
                    bottomSheetIcon(
                      Icons.photo,
                      Colors.pink,
                      "Photos",
                      () async => await pickFiles(
                        FileType.custom,
                        allowedExtensions: ['png', 'jpg', 'jpeg'],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> uploadFile(File file) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('https://goltens.in/api/v1/review/uploadFile'),
    );
    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final respStr = await response.stream.bytesToString();
      print('Response: $respStr');

      Map<String, dynamic> responseData = jsonDecode(respStr);
      if (responseData.containsKey('fileUrl')) {
        setState(() {
          var fileUrl = responseData['fileUrl'];
          print('File URL: $fileUrl');
          updateLinks(fileUrl.toString());
        });
      } else {
        print('fileUrl key not found in response.');
      }
    } else {
      print('Failed to upload file: ${response.reasonPhrase}');
    }
  }

  Widget _buildShareFilesButton() {
    return ElevatedButton(
      onPressed: () async {
        showFileAttachmentOptions();
      },
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all<Color>(primaryColor),
        shape: WidgetStateProperty.all<OutlinedBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              20.0,
            ), // Adjust the value as needed
          ),
        ),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.attach_file, color: Colors.black),
          SizedBox(width: 8),
          Text('Share Documents', style: TextStyle(color: Colors.black)),
        ],
      ),
    );
  }

  ElevatedButton _buildShareInviteOthersButton() {
    return ElevatedButton(
      onPressed: () {
        _shareInviteLink(context);
      },
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all<Color>(primaryColor),
        shape: WidgetStateProperty.all<OutlinedBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              20.0,
            ), // Adjust the value as needed
          ),
        ),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.share, color: Colors.black),
          SizedBox(width: 8),
          Padding(
            padding: EdgeInsets.all(10.0),
            child: Text(
              'Share Invite Link',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  ElevatedButton _buildEndMeetingButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        if (user!.data.type != UserType.admin) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const MeetMain(meetId: '')),
            ModalRoute.withName('/sub-admin-meeting'),
          );
          _showAnimatedDialog(
            context,
            EmpDigitalSignature(meetingId: widget.meetingId),
          );
        } else {
          await apiService.updateMeeting(
            5,
            "",
            "${DateTime.now().add(const Duration(hours: 1))}",
            widget.meetingId,
          );
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const MeetMain(meetId: '')),
            ModalRoute.withName('/sub-admin-meeting'),
          );
        }
      },
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all<Color>(Colors.red),
        shape: WidgetStateProperty.all<OutlinedBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              20.0,
            ), // Adjust the value as needed
          ),
        ),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.video_call, color: Colors.white),
          SizedBox(width: 8),
          Text('End Meeting', style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  void _showAnimatedDialog(BuildContext context, var val) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(backgroundColor: Colors.transparent, child: val);
      },
    );
  }
}
