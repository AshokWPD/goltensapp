import 'dart:io';

import 'package:date_time_format/date_time_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:goltens_mobile/meet/constants/file.dart';
import 'package:goltens_mobile/utils/functions.dart';
import 'package:path_provider/path_provider.dart';
import 'package:videosdk/videosdk.dart';
import '../../constants/colors.dart';
import '../../utils/toast.dart';

class ChatWidget extends StatefulWidget {
  final bool isLocalParticipant;
  final PubSubMessage message;
  String? meetId;
  ChatWidget(
      {Key? key,
      required this.isLocalParticipant,
      required this.message,
      this.meetId})
      : super(key: key);

  @override
  State<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  @override
  Widget build(BuildContext context) {
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

    void showPreviewDialog(BuildContext context, String fileData) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              // title: const Text('Files'),
              content: SizedBox(
                  width: double.maxFinite,
                  // height: double.maxFinite,
                  child: fileData.endsWith(".pdf")
                      ? const PDF(
                          swipeHorizontal: true,
                        ).cachedFromUrl(fileData)
                      : Image.network(fileData)),
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
          });
    }

    void showFileDialog(
      BuildContext context,
      String meetId,
    ) {
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
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    )
                                  : const Text("Image",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                              trailing: IconButton(
                                icon: const Icon(Icons.open_in_new),
                                onPressed: () {
                                  showPreviewDialog(context, file);
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
                });
          });
    }

    Future<File?> fetchFile(String url) async {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (_) {
          return const Dialog(
            // The background color
            backgroundColor: Colors.white,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 15),
                  Text('Loading...')
                ],
              ),
            ),
          );
        },
      );

      File file;

      try {
        file = await loadFileFromNetwork(url);
        if (mounted) Navigator.of(context).pop();
        return file;
      } catch (e) {
        if (mounted) {
          final snackBar = SnackBar(content: Text(e.toString()));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      }

      if (mounted) Navigator.of(context).pop();
      return null;
    }

    var width = MediaQuery.of(context).size.width;
    return Align(
      alignment: widget.isLocalParticipant
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: () {
          Clipboard.setData(ClipboardData(text: widget.message.message));
          showSnackBarMessage(
              message: "Message has been copied", context: context);
        },
        child: Container(
          margin: const EdgeInsets.all(4),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: black600,
          ),
          child: IntrinsicWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.isLocalParticipant ? "You" : widget.message.senderName,
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                    color: black400,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                widget.message.message.endsWith(".jpg") ||
                        widget.message.message.endsWith(".png") ||
                        widget.message.message.endsWith(".jpeg")
                    ? InkWell(
                        onTap: () {
                          showFileDialog(context, widget.meetId ?? "");

                          //  var file = await fetchFile(widget.message.message);

                          //               if (file != null) {
                          //                 if (mounted) {
                          //                   Navigator.pushNamed(
                          //                     context,
                          //                     '/file-viewer',
                          //                     arguments: FileViewerPageArgs(
                          //                       file: file,
                          //                       url: widget.message.message,
                          //                       fileType: FileType.image,
                          //                     ),
                          //                   );
                          //                 }
                          //               }
                        },
                        child: SizedBox(
                            width: width * 0.52,
                            child: Image.network(widget.message.message)),
                      )
                    : widget.message.message.endsWith(".pdf")
                        ? SizedBox(
                            width: width * 0.3,
                            child: InkWell(
                                onTap: () {
                                  showFileDialog(context, widget.meetId ?? "");
                                  //  var file = await fetchFile(widget.message.message);

                                  //             if (file != null) {
                                  //               if (mounted) {
                                  //                 Navigator.pushNamed(
                                  //                   context,
                                  //                   '/file-viewer',
                                  //                   arguments: FileViewerPageArgs(
                                  //                     file: file,
                                  //                     url: widget.message.message,
                                  //                     fileType: FileType.any,

                                  //                   ),
                                  //                 );
                                  //               }
                                  //             }
                                },
                                child: Image.asset("assets/sheet.png")))
                        : Text(
                            widget.message.message,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600),
                          ),
                const SizedBox(height: 4),
                Container(
                  alignment: Alignment.centerRight,
                  child: Text(
                    widget.message.timestamp.toLocal().format('h:i a'),
                    textAlign: TextAlign.end,
                    style: const TextStyle(
                        color: black400,
                        fontSize: 10,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
