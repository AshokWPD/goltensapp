import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:goltens_core/theme/theme.dart';
import 'package:goltens_mobile/utils/functions.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'dart:typed_data';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:printing/printing.dart';

class MeetingDetailsPage extends StatefulWidget {
  final String meetingId;

  const MeetingDetailsPage({super.key, required this.meetingId});

  @override
  _MeetingDetailsPageState createState() => _MeetingDetailsPageState();
}

class _MeetingDetailsPageState extends State<MeetingDetailsPage> {
  Map<String, dynamic>? meetingDetails;
  bool isLoading = true;
  bool showBeforeMeetingDetails = false;
  bool showAfterMeetingDetails = false;

  @override
  void initState() {
    super.initState();
    fetchMeetingDetails();
  }

  Future<void> fetchMeetingDetails() async {
    final String apiUrl =
        'https://goltens.in/api/v1/meeting/${widget.meetingId}';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        setState(() {
          meetingDetails = data;
          isLoading = false;
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

  void _showDeleteDialog(
    BuildContext context,
    String meetId,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this meeting?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final response = await http.delete(
                  Uri.parse(
                      'https://goltens.in/api/v1/meeting/deleteMeeting/$meetId'),
                );
                print(meetId);
                if (response.statusCode == 200) {
                  print('Meeting deleted successfully');
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Meeting deleted successfully')),
                  );
                  fetchMeetingDetails();
                  Navigator.pop(context);
                } else {
                  Navigator.of(context).pop();
                  print('Failed to delete the meeting');

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Failed to delete the meeting')),
                  );
                }
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Future<pw.Document> generateMeetingDetailsPdf(
      Map<String, dynamic> meetingDetails, Uint8List logoImage) async {
    String formatDateTime(String? dateTimeString) {
      if (dateTimeString == null || dateTimeString.isEmpty) {
        return 'N/A';
      }
      final dateTime = DateTime.parse(dateTimeString);
      final formattedDate = DateFormat.yMd().add_jm().format(dateTime);
      return formattedDate;
    }

    List<dynamic> membersAttended =
        meetingDetails['data']?['membersAttended'] ?? [];
    final List<pw.TableRow> allRows = [];

    for (var i = 0; i < membersAttended.length; i++) {
      final currentCounter = i + 1;
      final memberName = membersAttended[i]['membersName'] ?? 'N/A';
      final signatureUrl = membersAttended[i]['digitalSignatureFile'];

      // Adding the signature image if available
      final pw.Widget signatureWidget;
      if (signatureUrl != null && signatureUrl.isNotEmpty) {
        // If signature URL exists, load the image from the URL
        final signatureImage = await networkImage(signatureUrl);
        signatureWidget = pw.Image(signatureImage, height: 30, width: 50);
      } else {
        // If no signature is available, display 'N/A'
        signatureWidget =
            pw.Text('N/A', style: const pw.TextStyle(fontSize: 10));
      }

      allRows.add(
        pw.TableRow(
          verticalAlignment: pw.TableCellVerticalAlignment.middle,
          children: [
            pw.Center(
                child: pw.Text('$currentCounter',
                    style: const pw.TextStyle(fontSize: 10))),
            pw.Center(
              child: pw.Flexible(
                  child: pw.Center(
                child: pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 5),
                  child: pw.Text(memberName,
                      softWrap: true, style: const pw.TextStyle(fontSize: 10)),
                ),
              )),
            ),
            pw.Center(
              child: pw.Flexible(
                child: pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 5),
                  child: signatureWidget, // Adding the signature column here
                ),
              ),
            ),
            pw.Center(
              child: pw.Flexible(
                child: pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 5),
                  child: pw.Text('${membersAttended[i]['remark'] ?? 'N/A'}',
                      softWrap: true, style: const pw.TextStyle(fontSize: 10)),
                ),
              ),
            )
          ],
        ),
      );
    }

    final pdf = pw.Document();
    final pw.TableRow header = pw.TableRow(
      verticalAlignment: pw.TableCellVerticalAlignment.middle,
      decoration: const pw.BoxDecoration(
        color: PdfColors.grey300,
      ),
      children: [
        pw.Center(
            child: pw.Text('S.No',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
        pw.Center(
            child: pw.Text('Name',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
        pw.Center(
            child: pw.Text('Signature',
                style: pw.TextStyle(
                    fontWeight:
                        pw.FontWeight.bold))), // New column for Signature
        pw.Center(
            child: pw.Text('Remarks',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
      ],
    );

    if (membersAttended.isEmpty) {
      final pdfContent = pw.Column(
        mainAxisAlignment: pw.MainAxisAlignment.start,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(children: [
            pw.Image(pw.MemoryImage(logoImage), width: 70.0, height: 70.0),
            pw.SizedBox(width: 90),
            pw.Text('Toolbox Meeting',
                style:
                    pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 20)),
          ]),
          pw.SizedBox(height: 15),
          pw.Container(
              // height: "${meetingDetails['data']['description']}".length < 100
              //     ? 200
              //     : 300,
              width: double.infinity,
              decoration: pw.BoxDecoration(
                border: pw.Border.all(),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
              ),
              child: pw.Wrap(children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(15),
                  child: pw.Column(
                    children: [
                      pw.Row(
                        children: [
                          pw.Container(
                            width: 450,
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Row(
                                  children: [
                                    pw.Container(
                                      width: 120,
                                      child: pw.Text('Conducted By ',
                                          style: pw.TextStyle(
                                              fontWeight: pw.FontWeight.bold)),
                                    ),
                                    pw.Text(
                                        '${meetingDetails['data']?['meetCreater'] ?? 'N/A'}'),
                                  ],
                                ),
                                pw.SizedBox(height: 5),
                                pw.Row(
                                  children: [
                                    pw.Container(
                                      width: 120,
                                      child: pw.Text('Department ',
                                          style: pw.TextStyle(
                                              fontWeight: pw.FontWeight.bold)),
                                    ),
                                    pw.Text(
                                        '${meetingDetails['data']?['department'] ?? 'N/A'}'),
                                  ],
                                ),
                                pw.SizedBox(height: 5),
                                pw.Row(
                                  children: [
                                    pw.Container(
                                      width: 120,
                                      child: pw.Text('Meeting Date ',
                                          style: pw.TextStyle(
                                              fontWeight: pw.FontWeight.bold)),
                                    ),
                                    pw.Text(meetingDetails['data']
                                                ?['meetDateTime'] !=
                                            null
                                        ? DateFormat('dd-MM-yyyy').format(
                                            DateTime.parse(
                                                meetingDetails['data']
                                                    ['meetDateTime']))
                                        : 'N/A'),
                                  ],
                                ),
                                pw.SizedBox(height: 5),
                                pw.Row(
                                  children: [
                                    pw.Container(
                                      width: 120,
                                      child: pw.Text('Meeting Time ',
                                          style: pw.TextStyle(
                                              fontWeight: pw.FontWeight.bold)),
                                    ),
                                    pw.Text(meetingDetails['data']
                                                ?['meetDateTime'] !=
                                            null
                                        ? DateFormat('hh:mm a').format(
                                            DateTime.parse(
                                                meetingDetails['data']
                                                    ['meetDateTime']))
                                        : 'N/A'),
                                  ],
                                ),
                                pw.SizedBox(height: 5),
                                pw.Row(
                                  children: [
                                    pw.Container(
                                      width: 120,
                                      child: pw.Text('Topic ',
                                          style: pw.TextStyle(
                                              fontWeight: pw.FontWeight.bold)),
                                    ),
                                    pw.Expanded(
                                      child: pw.Text(
                                          '${meetingDetails['data']?['meetTitle'] ?? 'N/A'}',
                                          softWrap: true),
                                    )
                                  ],
                                ),
                                pw.SizedBox(height: 5),
                                pw.Row(
                                  crossAxisAlignment:
                                      pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Container(
                                      width: 120,
                                      child: pw.Text('Summary ',
                                          style: pw.TextStyle(
                                              fontWeight: pw.FontWeight.bold)),
                                    ),
                                    pw.Expanded(
                                      child: pw.Text(
                                        ('${meetingDetails['data']['description']}' ==
                                                "")
                                            ? "N/A"
                                            : '${meetingDetails['data']['description']}',
                                        softWrap: true,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ])),
          pw.SizedBox(height: 20),
          pw.Container(
              width: double.infinity,
              decoration: pw.BoxDecoration(
                border: pw.Border.all(),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
              ),
              child: pw.Center(
                child: pw.Padding(
                  padding: const pw.EdgeInsets.all(15),
                  child: pw.Text('No members attended the meeting.',
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold, fontSize: 15)),
                ),
              )),
        ],
      );
      pdf.addPage(pw.Page(build: (pw.Context context) => pdfContent));
    } else {
      for (var chunkIndex = 0; chunkIndex < allRows.length;) {
        // Determine the number of rows for the current page
        int rowsPerPage = (chunkIndex == 0) ? 10 : 20;

        // Get the current chunk of rows
        var rowsChunk = allRows.sublist(
          chunkIndex,
          chunkIndex + rowsPerPage < allRows.length
              ? chunkIndex + rowsPerPage
              : allRows.length,
        );

        // Update the chunk index for the next iteration
        chunkIndex += rowsPerPage;

        // Create the PDF content
        final pdfContent = pw.Column(
          mainAxisAlignment: pw.MainAxisAlignment.start,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Logo and title
            pw.Row(children: [
              pw.Image(pw.MemoryImage(logoImage), width: 70.0, height: 70.0),
              pw.SizedBox(width: 90),
              pw.Text('Toolbox Meetings',
                  style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold, fontSize: 20)),
            ]),
            pw.SizedBox(height: 15),

            // Meeting details - Add on the first page only
            if (chunkIndex <= rowsPerPage) ...[
              pw.Container(
                width: double.infinity,
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(),
                  borderRadius:
                      const pw.BorderRadius.all(pw.Radius.circular(5)),
                ),
                child: pw.Padding(
                  padding: const pw.EdgeInsets.all(15),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Row(
                        children: [
                          pw.Container(
                            width: 120,
                            child: pw.Text('Conducted By ',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold)),
                          ),
                          pw.Text(
                              '${meetingDetails['data']?['meetCreater'] ?? 'N/A'}'),
                        ],
                      ),
                      pw.SizedBox(height: 5),
                      pw.Row(
                        children: [
                          pw.Container(
                            width: 120,
                            child: pw.Text('Department ',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold)),
                          ),
                          pw.Text(
                              '${meetingDetails['data']?['department'] ?? 'N/A'}'),
                        ],
                      ),
                      pw.SizedBox(height: 5),
                      pw.Row(
                        children: [
                          pw.Container(
                            width: 120,
                            child: pw.Text('Meeting Date ',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold)),
                          ),
                          pw.Text(meetingDetails['data']?['meetDateTime'] !=
                                  null
                              ? DateFormat('dd-MM-yyyy').format(DateTime.parse(
                                  meetingDetails['data']['meetDateTime']))
                              : 'N/A'),
                        ],
                      ),
                      pw.SizedBox(height: 5),
                      pw.Row(
                        children: [
                          pw.Container(
                            width: 120,
                            child: pw.Text('Meeting Time ',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold)),
                          ),
                          pw.Text(
                              meetingDetails['data']?['meetDateTime'] != null
                                  ? DateFormat('hh:mm a').format(DateTime.parse(
                                      meetingDetails['data']['meetDateTime']))
                                  : 'N/A'),
                        ],
                      ),
                      pw.SizedBox(height: 5),
                      pw.Row(
                        children: [
                          pw.Container(
                            width: 120,
                            child: pw.Text('Topic ',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold)),
                          ),
                          pw.Expanded(
                            child: pw.Text(
                                '${meetingDetails['data']?['meetTitle'] ?? 'N/A'}',
                                softWrap: true),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 5),
                      pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Container(
                            width: 120,
                            child: pw.Text('Summary ',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold)),
                          ),
                          pw.Expanded(
                            child: pw.Text(
                              ('${meetingDetails['data']['description']}' == "")
                                  ? "N/A"
                                  : '${meetingDetails['data']['description']}',
                              softWrap: true,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],

            pw.SizedBox(height: 20),

            // Table for the current chunk
            pw.Table(
              border: pw.TableBorder.all(),
              columnWidths: {
                0: const pw.FixedColumnWidth(35),
                1: const pw.FixedColumnWidth(160),
                2: const pw.FixedColumnWidth(115),
                3: const pw.FlexColumnWidth(),
              },
              children: [
                header, // Add the table header row
                ...rowsChunk, // Add the chunked rows
              ],
            ),
          ],
        );

        pdf.addPage(
          pw.Page(
            build: (pw.Context context) => pdfContent,
          ),
        );
      }
    }

    return pdf;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Meeting Info',
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: primaryColor,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.black),
          actions: [
            IconButton(
                onPressed: () {
                  _showDeleteDialog(context, widget.meetingId);
                },
                icon: const Icon(
                  Icons.delete,
                  color: Colors.red,
                ))
          ],
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : meetingDetails!.isEmpty
                ? const Text('No data available')
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              'Conducted by: ${meetingDetails?['data']?['meetCreater'] ?? 'N/A'}'),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                              'Department: ${meetingDetails?['data']?['department'] ?? 'N/A'}'),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            'Meeting Date: ${meetingDetails?['data']?['meetDateTime'] != null ? DateFormat('dd-MM-yyyy').format(DateTime.parse(meetingDetails?['data']['meetDateTime'])) : 'N/A'}',
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            'Meeting Time: ${meetingDetails?['data']?['meetDateTime'] != null ? DateFormat('hh:mm a').format(DateTime.parse(meetingDetails?['data']['meetDateTime'])) : 'N/A'}',
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                              'Topic: ${meetingDetails?['data']?['meetingSubTitle'] ?? 'N/A'}'),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                              'Summary: ${meetingDetails?['data']?['description'] ?? 'N/A'}'),
                          const SizedBox(
                            height: 20,
                          ),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                DataTable(
                                  columns: const [
                                    DataColumn(label: Text('Avatar')),
                                    DataColumn(label: Text('Member Name')),
                                    DataColumn(
                                        label: Text('Member Department')),
                                    DataColumn(
                                        label: Text('Member Mobile Number')),
                                    DataColumn(label: Text('Member Email')),
                                    DataColumn(label: Text('Date & Time')),
                                    // DataColumn(label: Text('Out Time')),
                                    DataColumn(label: Text('Signature')),
                                    DataColumn(label: Text('Remarks')),
                                  ],
                                  rows: (meetingDetails?['data']
                                                  ?['membersAttended']
                                              as List<dynamic>? ??
                                          [])
                                      .map<DataRow>((member) {
                                    final formattedInTime = _formatDateTime(
                                        member?['memberInTime']);
                                    final formattedOutTime = _formatDateTime(
                                        member?['memberOutTime']);
                                    return DataRow(
                                      cells: [
                                        DataCell(
                                          CircleAvatar(
                                            backgroundColor: primaryColor,
                                            child: Text(
                                              member['membersName']
                                                          ?.isNotEmpty ==
                                                      true
                                                  ? member['membersName'][0]
                                                      .toUpperCase()
                                                  : 'N',
                                              style: const TextStyle(
                                                  color: Colors.black),
                                            ),
                                          ),
                                        ),
                                        DataCell(Text(
                                            '${member?['membersName'] ?? 'N/A'}')),
                                        DataCell(Text(
                                            '${member?['memberdep'] ?? 'N/A'}')),
                                        DataCell(Text(
                                            '${member?['memberphone'] ?? 'N/A'}')),
                                        DataCell(Text(
                                            '${member?['memberemail'] ?? 'N/A'}')),

                                        DataCell(
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(formattedInTime
                                                  .split('\n')[0]),
                                              Text(formattedInTime
                                                  .split('\n')[1]),
                                            ],
                                          ),
                                        ),
                                        //
                                        // DataCell(
                                        //   Column(
                                        //     crossAxisAlignment: CrossAxisAlignment.start,
                                        //     children: [
                                        //       Text('${formattedOutTime.split('\n')[0]}'),
                                        //       Text('${formattedOutTime.split('\n')[1]}'),
                                        //     ],
                                        //   ),
                                        // ),
                                        DataCell(
                                          Image.network(
                                            member?['digitalSignatureFile'] ??
                                                '',
                                            height: 40,
                                            width: 80,
                                          ),
                                        ),
                                        DataCell(Text(
                                            '${member?['remark'] ?? 'N/A'}')),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: primaryColor,
          onPressed: () async {
            try {
              final ByteData image =
                  await rootBundle.load('assets/images/logo.png');
              Uint8List logoImage = (image).buffer.asUint8List();
              final pdf =
                  await generateMeetingDetailsPdf(meetingDetails!, logoImage);
              final directory = await getDownloadsDirectoryPath();
              final pdfPath =
                  '$directory/${DateTime.now().millisecondsSinceEpoch}_report.pdf';
              final file = File(pdfPath);
              await file.writeAsBytes(await pdf.save());

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('PDF successfully generated and saved!'),
                  duration: Duration(seconds: 2),
                ),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Error generating or saving PDF.'),
                ),
              );
            }
          },
          tooltip: 'Open PDF',
          child: const Icon(Icons.download, color: Colors.black),
        ));
  }

  String _formatDateTime(String? dateTimeString) {
    if (dateTimeString != null && dateTimeString.isNotEmpty) {
      final dateTime = DateTime.parse(dateTimeString);
      final formattedDate = DateFormat.yMd().format(dateTime);
      final formattedTime = DateFormat.jm().format(dateTime);
      return '$formattedDate\n$formattedTime';
    }
    return 'N/A\nN/A';
  }

  // static Future<pw.Document> generateMeetingDetailsPdf(Map<String, dynamic> meetingDetails, dynamic logoImage) async {
  //   String _formatDateTime(String? dateTimeString) {
  //     if (dateTimeString == null || dateTimeString.isEmpty) {
  //       return 'N/A';
  //     }
  //     final dateTime = DateTime.parse(dateTimeString);
  //     final formattedDate = DateFormat.yMd().add_jm().format(dateTime);
  //     return formattedDate;
  //   }
  //   int counter = 1;
  //
  //   Future<Uint8List> _loadNetworkImage(String imageUrl) async {
  //     final Completer<Uint8List> completer = Completer();
  //
  //     final image = NetworkImage(imageUrl);
  //     final configuration = ImageConfiguration.empty;
  //
  //     final Completer<ImageInfo> imageInfoCompleter = Completer<ImageInfo>();
  //     image.resolve(configuration as ImageConfiguration).addListener(ImageStreamListener((ImageInfo image, bool synchronousCall) {
  //       imageInfoCompleter.complete(image);
  //     }));
  //
  //     ImageInfo imageInfo = await imageInfoCompleter.future;
  //     ByteData? byteData = await imageInfo.image.toByteData(format: ui.ImageByteFormat.png);
  //     Uint8List? uint8List = byteData?.buffer.asUint8List();
  //
  //     completer.complete(uint8List);
  //     return completer.future;
  //   }
  //
  //   // Create a TableRow for the header
  //   final pw.TableRow header = pw.TableRow(
  //     decoration: pw.BoxDecoration(
  //       color: PdfColors.grey300,
  //     ),
  //     children: [
  //       pw.Center(child: pw.Text('S.No', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
  //       pw.Center(child: pw.Text('Name',style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
  //       pw. Center(child:pw. Text('Signature',style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
  //       pw. Center(child:pw. Text('Remarks',style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
  //     ],
  //   );
  //
  //   // Add the header as the first element in the rows list
  //   final List<pw.TableRow> rows = [
  //     header,
  //     ...await Future.wait(
  //       (meetingDetails?['data']?['membersAttended'] as List<dynamic>? ?? [])
  //           .map<Future<pw.TableRow>>((member) async {
  //         Uint8List signatureImage = await _loadNetworkImage(member?['digitalSignatureFile'] ?? '');
  //
  //         // Display the counter value in the S.No column
  //         final currentCounter = counter++;
  //         return pw.TableRow(
  //           children: [
  //             pw.Center(child: pw.Text('$currentCounter')),
  //             pw.Center(child: pw.Text('${member?['membersName'] ?? 'N/A'}')),
  //             pw.Center(child: pw.Image(pw.MemoryImage(signatureImage), height: 40, width: 80)),
  //             pw.Center(child: pw.Text('${member?['remark'] ?? 'N/A'}')),
  //           ],
  //         );
  //       }),
  //     ),
  //   ];
  //
  //   // Use the rows list in your table
  //   final pdfContent = pw.Column(
  //     mainAxisAlignment: pw.MainAxisAlignment.start,
  //     crossAxisAlignment: pw.CrossAxisAlignment.start,
  //     children: [
  //       pw.Row(children: [
  //         pw.Image(
  //           pw.MemoryImage(logoImage),
  //           width: 70.0, // Adjust the width as needed
  //           height: 70.0, // Adjust the height as needed
  //         ),
  //         pw.SizedBox(width: 90),
  //         pw.Text('Toolbox Meeting',style: pw.TextStyle(fontWeight: pw.FontWeight.bold,fontSize: 20)),
  //
  //       ]),
  //       pw.SizedBox(height: 15),
  //       pw.Container(
  //         height: 150,
  //         width: double.infinity,
  //         decoration: pw.BoxDecoration(
  //           border: pw.Border.all(),
  //           borderRadius: pw.BorderRadius.all(pw.Radius.circular(5)),
  //         ),
  //         child: pw.Padding(
  //           padding: pw.EdgeInsets.all(15),
  //           child: pw.Column(
  //             children: [
  //               pw.Row(
  //
  //                 children: [
  //                   pw.Container(
  //                     width: 120,
  //
  //                     child: pw.Column(
  //                       crossAxisAlignment: pw.CrossAxisAlignment.start,
  //                       children: [
  //                         pw.Text('Conducted By', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
  //                         pw.Text('Department', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
  //                         pw.Text('Meeting Date', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
  //                         pw.Text('Meeting Time', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
  //                         pw.Text('Topic', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
  //                         pw.Text('Summary ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
  //                       ],
  //                     ),
  //                   ),
  //                   pw.Container(
  //                     child: pw.Column(
  //                       crossAxisAlignment: pw.CrossAxisAlignment.start,
  //                       children: [
  //                         pw.Text('${meetingDetails?['data']?['meetCreater'] ?? 'N/A'}'),
  //                         pw.SizedBox(height: 1),
  //                         pw.Text('${meetingDetails?['data']?['department'] ?? 'N/A'}'),
  //                         pw.SizedBox(height: 1),
  //                         pw.Text('${meetingDetails?['data']?['meetDateTime'] != null ? DateFormat('dd-MM-yyyy').format(DateTime.parse(meetingDetails?['data']['meetDateTime'])) : 'N/A'}',
  //                         ),
  //                         pw.SizedBox(height: 1),
  //                         pw.Text(
  //                           '${meetingDetails?['data']?['meetDateTime'] != null ? DateFormat('hh:mm a').format(DateTime.parse(meetingDetails?['data']['meetDateTime'])) : 'N/A'}',
  //                         ),
  //                         pw.SizedBox(height: 1),
  //                         pw.Text(' ${meetingDetails?['data']?['meetTitle'] ?? 'N/A'}'),
  //                         pw.SizedBox(height: 1),
  //                         pw.Text(' ${meetingDetails?['data']?['description'] ?? 'N/A'}'),
  //                       ],
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //       pw.SizedBox(height: 30),
  //       pw.Table(
  //         border: pw.TableBorder.all(),
  //         columnWidths: {
  //
  //           0: const pw.FlexColumnWidth(1.5),
  //           1: const pw.FlexColumnWidth(2),
  //           2: const pw.FlexColumnWidth(2),
  //           3: const pw.FlexColumnWidth(3),
  //         },
  //         children: rows,
  //       ),
  //     ],
  //   );
  //
  //   final pdf = pw.Document();
  //   pdf.addPage(pw.MultiPage(
  //     build: (pw.Context context) {
  //       return [pdfContent];
  //     },
  //   ));
  //
  //   // final Uint8List bytes = await pdf.save();
  //   // final html.Blob blob = html.Blob([bytes]);
  //   // final String url = html.Url.createObjectUrlFromBlob(blob);
  //   // // html.window.open(url, '_blank');
  //   // html.Url.revokeObjectUrl(url);
  //
  //   return pdf;
  // }
}
