import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:goltens_mobile/meet/constants/file.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:videosdk/videosdk.dart';
import 'package:http/http.dart' as http;
import '../../constants/colors.dart';
import 'chat_widget.dart';

// ChatScreen
class ChatView extends StatefulWidget {
  final Room meeting;
  const ChatView({super.key, required this.meeting});

  @override
  _ChatViewState createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  // MessageTextController
  final msgTextController = TextEditingController();
  List<Map<String, dynamic>> filesArr = [];
  // PubSubMessages
  PubSubMessages? messages;

  @override
  void initState() {
    super.initState();

    // Subscribing 'CHAT' Topic
    widget.meeting.pubSub
        .subscribe("CHAT", messageHandler)
        .then((value) => setState((() => messages = value)));
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
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

  void showFileAttachmentOptions() {
    // Future<void> pickFiles(FileType fileType) async {
    //   try {
    //     if (fileType == FileType.image) {
    //       final pickedFile = await ImagePicker().pickImage(
    //         source: ImageSource.gallery,
    //       );

    //       if (pickedFile != null) {
    //         filesArr.add({'file': File(pickedFile.path), 'type': fileType});

    //         // Upload the image and get the URL
    //         await uploadFile(File(pickedFile.path));

    //         if (mounted) {
    //           Navigator.pop(context);

    //           const snackBar = SnackBar(
    //             content: Text('Photo Added'),
    //           );

    //           if (mounted) {
    //             ScaffoldMessenger.of(context).showSnackBar(snackBar);
    //           }
    //         }
    //       }

    //       return;
    //     }

    //     FilePickerResult? result = await FilePicker.platform.pickFiles(
    //       type: fileType,
    //       allowMultiple: true,
    //     );

    //     if (result != null) {
    //       List<File> files = result.paths.map((path) {
    //         if (path != null) {
    //           return File(path);
    //         } else {
    //           throw Exception('Cannot load files');
    //         }
    //       }).toList();

    //       for (var file in files) {
    //         filesArr.add({'file': file, 'type': fileType});
    //         // Upload each file and get the URL
    //         await uploadFile(file);
    //       }

    //       if (mounted) {
    //         Navigator.pop(context);

    //         final snackBar = SnackBar(
    //           content: Text('${files.length} Files Added'),
    //         );

    //         if (mounted) {
    //           ScaffoldMessenger.of(context).showSnackBar(snackBar);
    //         }
    //       }
    //     }
    //   } catch (e) {
    //     if (mounted) {
    //       Navigator.pop(context);
    //     }

    //     if (mounted) {
    //       final snackBar = SnackBar(content: Text(e.toString()));
    //       ScaffoldMessenger.of(context).showSnackBar(snackBar);
    //     }
    //   }
    // }
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

  void updateLinks(String url) async {
    var headers = {'Content-Type': 'application/json'};

    List<String> filelink = await fetchFiles(widget.meeting.id);

    setState(() {
      filelink.add(url);
    });

    var request = http.Request(
      'PUT',
      Uri.parse('https://goltens.in/api/v1/meeting/${widget.meeting.id}'),
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
          updateLinks(fileUrl.toString());
          widget.meeting.pubSub.publish(
            "CHAT",
            fileUrl.toString(),
            const PubSubPublishOptions(persist: true),
          );
          print('File URL: $fileUrl');
        });
      } else {
        print('fileUrl key not found in response.');
      }
    } else {
      print('Failed to upload file: ${response.reasonPhrase}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: secondaryColor,
      appBar: AppBar(
        flexibleSpace: Align(
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              const Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  child: Text(
                    "Chat",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: secondaryColor,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Expanded(
                child: messages == null
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        reverse: true,
                        child: Column(
                          children: messages!.messages
                              .map(
                                (e) => ChatWidget(
                                  message: e,
                                  isLocalParticipant:
                                      e.senderId ==
                                      widget.meeting.localParticipant.id,
                                  meetId: widget.meeting.id,
                                ),
                              )
                              .toList(),
                        ),
                      ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                padding: const EdgeInsets.fromLTRB(16, 4, 4, 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        controller: msgTextController,
                        onChanged: (value) => setState(() {
                          msgTextController.text;
                        }),
                        decoration: const InputDecoration(
                          hintText: "Write your message",
                          border: InputBorder.none,
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        showFileAttachmentOptions();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                        width: 45,
                        margin: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          // color:Colors.grey,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.attach_file,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: msgTextController.text.trim().isEmpty
                          ? null
                          : () => widget.meeting.pubSub
                                .publish(
                                  "CHAT",
                                  msgTextController.text,
                                  const PubSubPublishOptions(persist: true),
                                )
                                .then((value) => msgTextController.clear()),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                        width: 45,
                        margin: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: msgTextController.text.trim().isEmpty
                              ? null
                              : appbar,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.send, color: Colors.black),
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

  void messageHandler(PubSubMessage message) {
    setState(() => messages!.messages.add(message));
  }

  @override
  void dispose() {
    widget.meeting.pubSub.unsubscribe("CHAT", messageHandler);
    super.dispose();
  }
}
