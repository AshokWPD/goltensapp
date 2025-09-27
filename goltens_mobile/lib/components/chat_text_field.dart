import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:goltens_core/components/admin/scrollable_data_table.dart';
import 'package:goltens_core/constants/constants.dart';
import 'package:goltens_core/models/admin.dart';
import 'package:goltens_core/services/admin.dart';
import 'package:image_picker/image_picker.dart';

class ChatTextField extends StatefulWidget {
  bool? isSingleMessage = false;
  int? groupId;
  final Function(String, String, int, List<Map<String, dynamic>>, String?)
      onMessageSend;

  ChatTextField({
    super.key,
    this.isSingleMessage,
    this.groupId,
    required this.onMessageSend,
  });

  @override
  State<ChatTextField> createState() => _ChatTextFieldState();
}

class _ChatTextFieldState extends State<ChatTextField> {
  TextEditingController titleTextController = TextEditingController();
  TextEditingController contentTextController = TextEditingController();
  bool isSending = false;
  int timer = 60;
  List<Map<String, dynamic>> filesArr = [];
  List<int> selectedUserToAdd = [];
  List<GetSearchUsersToAssignData> searchMembers = [];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Colors.white,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 6.0,
          vertical: 10.0,
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25.0),
            color: Colors.grey.shade200,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 80.0),
            child: Stack(
              children: [
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                    child: TextField(
                      controller: contentTextController,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.newline,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      decoration: const InputDecoration(
                        focusedBorder: InputBorder.none,
                        hintText: 'Type a message',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16.0),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  child: IconButton(
                    onPressed: showFileAttachmentOptions,
                    icon: const Icon(Icons.attach_file, color: Colors.grey),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: SizedBox(
                    width: 100.0,
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: showTimerOptions,
                          icon: const Icon(Icons.alarm, color: Colors.grey),
                        ),
                        IconButton(
                          onPressed: showConfirmationDialog,
                          icon: const Icon(Icons.send, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<GetSearchUsersToAssignResponse?> searchUsersToAssignFeedback(
    String search,
  ) async {
    try {
      var res = await AdminService.searchUsersToAssignForFeedback(
        searchTerm: search,
      );

      return res;
    } catch (e) {
      if (mounted) {
        final snackBar = SnackBar(content: Text(e.toString()));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
      return null;
    }
  }

  GetGroupResponseData? groupdata;

  void showConfirmationDialog() async{
      if (widget.groupId != null) {
      var res = await AdminService.getGroup(id: widget.groupId!);
      setState(() {
        groupdata = res.data;
      });
    }
    // ignore: use_build_context_synchronously
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Center(child: Text("Confirm Your Message")),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
          ),
          content: StatefulBuilder(
            builder: (
              BuildContext context,
              StateSetter setState,
            ) {
              var formKey = GlobalKey<FormState>();
              var searchTextController = TextEditingController();
              var timerTextController = TextEditingController(
                text: timer.toString(),
              );

              return SizedBox(
                width: 410,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      const SizedBox(height: 16.0),
                      Form(
                        key: formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: titleTextController,
                              maxLines: null,
                              decoration: InputDecoration(
                                labelText: 'Title',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                              ),
                              validator: (value) {
                                if (value != null && value.isEmpty) {
                                  return 'Please enter title';
                                }

                                return null;
                              },
                            ),
                            const SizedBox(height: 16.0),
                            TextFormField(
                              controller: contentTextController,
                              maxLines: null,
                              decoration: InputDecoration(
                                labelText: 'Content',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                              ),
                              validator: (value) {
                                if (value != null && value.isEmpty) {
                                  return 'Please enter content';
                                }

                                return null;
                              },
                            ),
                            const SizedBox(height: 16.0),
                            TextFormField(
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Time in (Seconds)',
                                helperText:
                                    'Time for user to read this message',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                              ),
                              controller: timerTextController,
                              onChanged: (String newTime) {
                                timer = int.parse(newTime);
                              },
                              validator: (value) {
                                if (value != null && value.isEmpty) {
                                  return 'Please enter valid second';
                                }

                                return null;
                              },
                            ),
                            const SizedBox(height: 16.0),
                            if (widget.isSingleMessage != null &&
                                widget.isSingleMessage!) ...[
                              if (groupdata == null)
                                TextFormField(
                                  controller: searchTextController,
                                  decoration: InputDecoration(
                                    labelText: 'Search...',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                    suffixIcon: IconButton(
                                      onPressed: () async {
                                        if (searchTextController.text.isEmpty) {
                                          const snackBar = SnackBar(
                                            content: Text(
                                              'Enter something to search for...,',
                                            ),
                                          );

                                          if (mounted) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              snackBar,
                                            );
                                          }

                                          return;
                                        }

                                        var users =
                                            await searchUsersToAssignFeedback(
                                          searchTextController.text,
                                        );

                                        if (users != null) {
                                          setState(() {
                                            searchMembers = users.data;
                                          });
                                        }
                                      },
                                      icon: const Icon(Icons.search),
                                    ),
                                  ),
                                ),
                              if (groupdata == null)
                                const SizedBox(height: 12.0),
                              (searchMembers.isNotEmpty ||
                                      (groupdata != null &&
                                          groupdata!.members.isNotEmpty))
                                  ? SizedBox(
                                      height: 200,
                                      child: ScrollableDataTable(
                                        child: DataTable(
                                          showCheckboxColumn: true,
                                          columns: const <DataColumn>[
                                            DataColumn(label: Text('Avatar')),
                                            DataColumn(label: Text('Name')),
                                            DataColumn(label: Text('Email')),
                                            DataColumn(label: Text('Phone')),
                                            DataColumn(
                                                label: Text('Department')),
                                            DataColumn(
                                                label: Text('Employee Number')),
                                            DataColumn(label: Text('Type')),
                                          ],
                                          rows: (groupdata != null &&
                                                  groupdata!.members
                                                      .isNotEmpty)
                                              ? groupdata!.members
                                                  .map(
                                                    (user) => DataRow(
                                                      cells: <DataCell>[
                                                        DataCell(
                                                          CircleAvatar(
                                                            radius: 16,
                                                            child: user.avatar!
                                                                        .isNotEmpty ==
                                                                    true
                                                                ? ClipRRect(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(
                                                                      100.0,
                                                                    ),
                                                                    child: Image
                                                                        .network(
                                                                      '$apiUrl/$avatar/${user.avatar}',
                                                                      fit: BoxFit
                                                                          .contain,
                                                                      height:
                                                                          500,
                                                                      width:
                                                                          500,
                                                                      errorBuilder:
                                                                          (
                                                                        context,
                                                                        obj,
                                                                        stacktrace,
                                                                      ) {
                                                                        return Container();
                                                                      },
                                                                    ),
                                                                  )
                                                                : Text(user
                                                                    .name[0]),
                                                          ),
                                                        ),
                                                        DataCell(
                                                            Text(user.name)),
                                                        DataCell(
                                                            Text(user.email)),
                                                        DataCell(
                                                            Text(user.phone)),
                                                        DataCell(Text(
                                                            user.department)),
                                                        DataCell(Text(user
                                                            .employeeNumber)),
                                                        DataCell(Text(
                                                            user.type.name)),
                                                      ],
                                                      selected:
                                                          selectedUserToAdd
                                                              .contains(
                                                                  user.id),
                                                      onSelectChanged:
                                                          (isItemSelected) {
                                                        setState(() {
                                                          selectedUserToAdd
                                                                  .contains(
                                                                      user.id)
                                                              ? selectedUserToAdd
                                                                  .remove(
                                                                      user.id)
                                                              : selectedUserToAdd
                                                                  .add(user.id);
                                                        });
                                                      },
                                                    ),
                                                  )
                                                  .toList()
                                              : searchMembers
                                                  .map(
                                                    (user) => DataRow(
                                                      cells: <DataCell>[
                                                        DataCell(
                                                          CircleAvatar(
                                                            radius: 16,
                                                            child: user.avatar
                                                                        .isNotEmpty ==
                                                                    true
                                                                ? ClipRRect(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(
                                                                      100.0,
                                                                    ),
                                                                    child: Image
                                                                        .network(
                                                                      '$apiUrl/$avatar/${user.avatar}',
                                                                      fit: BoxFit
                                                                          .contain,
                                                                      height:
                                                                          500,
                                                                      width:
                                                                          500,
                                                                      errorBuilder:
                                                                          (
                                                                        context,
                                                                        obj,
                                                                        stacktrace,
                                                                      ) {
                                                                        return Container();
                                                                      },
                                                                    ),
                                                                  )
                                                                : Text(user
                                                                    .name[0]),
                                                          ),
                                                        ),
                                                        DataCell(
                                                            Text(user.name)),
                                                        DataCell(
                                                            Text(user.email)),
                                                        DataCell(
                                                            Text(user.phone)),
                                                        DataCell(Text(
                                                            user.department)),
                                                        DataCell(Text(user
                                                            .employeeNumber)),
                                                        DataCell(Text(
                                                            user.type.name)),
                                                      ],
                                                      selected:
                                                          selectedUserToAdd
                                                              .contains(
                                                                  user.id),
                                                      onSelectChanged:
                                                          (isItemSelected) {
                                                        setState(() {
                                                          selectedUserToAdd
                                                                  .contains(
                                                                      user.id)
                                                              ? selectedUserToAdd
                                                                  .remove(
                                                                      user.id)
                                                              : selectedUserToAdd
                                                                  .add(user.id);
                                                        });
                                                      },
                                                    ),
                                                  )
                                                  .toList(),
                                        ),
                                      ),
                                    )
                                  : Container(),
                              const SizedBox(height: 15.0),
                              Text("To message everyone, skip the list above",
                                  textAlign: TextAlign.left,
                                  style: Theme.of(context).textTheme.bodySmall),
                              const SizedBox(height: 15.0),
                              Column(
                                children: filesArr.map((fileObj) {
                                  var icon = Icons.insert_drive_file;

                                  switch (fileObj['type']) {
                                    case FileType.image:
                                      icon = Icons.photo;
                                      break;
                                    case FileType.video:
                                      icon = Icons.video_camera_back_rounded;
                                      break;
                                    case FileType.audio:
                                      icon = Icons.headset;
                                      break;
                                    default:
                                  }

                                  return ListTile(
                                    leading: Icon(icon),
                                    title: Text(
                                      '${fileObj['file'].path.split('/').last}',
                                      overflow: TextOverflow.clip,
                                    ),
                                    trailing: IconButton(
                                      onPressed: () {
                                        filesArr.removeWhere(
                                          (elem) =>
                                              elem['file'] == fileObj['file'],
                                        );

                                        setState(() => filesArr = filesArr);
                                      },
                                      icon: const Icon(Icons.close),
                                    ),
                                    onTap: () {},
                                  );
                                }).toList(),
                              ),
                              // const SizedBox(height: 15.0),
                              // ElevatedButton(
                              //   style: ElevatedButton.styleFrom(
                              //     shape: RoundedRectangleBorder(
                              //       borderRadius: BorderRadius.circular(20.0),
                              //     ),
                              //   ),
                              //   onPressed: searchMembers.isNotEmpty
                              //       ? () {
                              //           Navigator.pop(context);
                              //         }
                              //       : null,
                              //   child: const Row(
                              //     mainAxisAlignment: MainAxisAlignment.center,
                              //     children: [
                              //       Icon(Icons.group_add),
                              //       SizedBox(width: 5.0),
                              //       Text('Assign User')
                              //     ],
                              //   ),
                              // ),
                            ],
                            const SizedBox(height: 15.0),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.send),
                              label: const Text('Send Message'),
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size.fromHeight(40),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                              ),
                              onPressed: () async {
                                if (formKey.currentState?.validate() == true) {
                                  formKey.currentState?.save();
                                  Navigator.pop(context);
                                  sendMessage();
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void sendMessage() {
    widget.onMessageSend(
      titleTextController.text,
      contentTextController.text,
      timer,
      filesArr,
      selectedUserToAdd != [] ? selectedUserToAdd.join(',') : "",
    );

    contentTextController.clear();

    setState(() {
      timer = 60;
      filesArr = [];
    });
  }

  void showFileAttachmentOptions() {
    Future<void> pickFiles(FileType fileType, {List<String>? allowedExtensions}) async {
  try {
    if (fileType == FileType.image && allowedExtensions == null) {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );

      if (pickedFile != null) {
        filesArr.add({'file': pickedFile, 'type': fileType});

        if (mounted) {
          Navigator.pop(context);

          const snackBar = SnackBar(content: Text('Photo Added'));

          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      }
      return;
    }

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: allowedExtensions != null ? FileType.custom : fileType,
      allowedExtensions: allowedExtensions,
      allowMultiple: true,
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
      }

      if (mounted) {
        Navigator.pop(context);

        final snackBar = SnackBar(content: Text('${files.length} Files Added'));

        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }
  } catch (e) {
    if (mounted) {
      Navigator.pop(context);

      final snackBar = SnackBar(content: Text(e.toString()));

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }
}


    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (builder) => SizedBox(
        height: 270,
        width: MediaQuery.of(context).size.width,
        child: Card(
          margin: const EdgeInsets.all(18.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 20,
            ),
            child: Column(
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
                        allowedExtensions: ['pdf'],),
                    ),
                    const SizedBox(width: 40),
                    bottomSheetIcon(
                      Icons.photo,
                      Colors.pink,
                      "Photos",
                      () async => await pickFiles(
                        FileType.custom,
                        allowedExtensions: ['png', 'jpg', 'jpeg'],),
                    ),
                  ],
                ),
                Visibility(
                  visible: !Platform.isIOS,
                  child: Column(
                    children: [
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          bottomSheetIcon(
                            Icons.headset,
                            Colors.orange,
                            "Audio",
                            () async => await pickFiles(FileType.audio),
                          ),
                          const SizedBox(width: 40),
                          bottomSheetIcon(
                            Icons.video_camera_back_rounded,
                            Colors.teal,
                            "Video",
                            () async => await pickFiles(FileType.video),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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
            child: Icon(
              icons,
              size: 29,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            text,
            style: const TextStyle(fontSize: 12),
          )
        ],
      ),
    );
  }

  void showTimerOptions() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              final formKey = GlobalKey<FormState>();

              final timerTextController = TextEditingController(
                text: timer.toString(),
              );

              return Padding(
                padding: const EdgeInsets.only(
                  top: 16,
                  left: 16,
                  right: 16,
                  bottom: 0,
                ),
                child: SizedBox(
                  height: 200.0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Message Timer',
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 25.0),
                      Form(
                        key: formKey,
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          autofocus: true,
                          decoration: InputDecoration(
                            labelText: 'Time in (Seconds)',
                            helperText: 'Time for user to read this message',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                          ),
                          controller: timerTextController,
                          validator: (value) {
                            if (value != null && value.isEmpty) {
                              return 'Please enter valid second';
                            }

                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 15.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              if (formKey.currentState?.validate() == true) {
                                setState(() {
                                  Navigator.pop(context);
                                  timer = int.parse(timerTextController.text);
                                });
                              }
                            },
                            child: const Text('OK'),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
