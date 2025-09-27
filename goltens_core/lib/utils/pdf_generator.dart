// import 'package:collection/collection.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/foundation.dart';
// import 'package:goltens_core/utils/functions.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pdf;
// import 'dart:typed_data';
// import 'package:flutter/services.dart';
// import 'package:intl/intl.dart';
// import 'package:pdf/widgets.dart' as pw;
// // import 'dart:html' as html;
// import 'package:flutter/services.dart' show rootBundle;
import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:goltens_core/utils/functions.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pdf;
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:ui' as ui;

import 'dart:io';

class PDFGenerator {
  static pdf.Column generateHeader(
    dynamic logoImage,
    String title,
  ) {
    return pdf.Column(
      mainAxisAlignment: pdf.MainAxisAlignment.center,
      //  crossAxisAlignment: pdf.CrossAxisAlignment.center,
      children: [
        pdf.Row(
            mainAxisAlignment: pdf.MainAxisAlignment.start,
            crossAxisAlignment: pdf.CrossAxisAlignment.center,
            children: [
              kIsWeb
                  ? pdf.Image(
                      pdf.MemoryImage(logoImage),
                      width: 60,
                      height: 60,
                      alignment: pdf.Alignment.center,
                    )
                  : pdf.Image(
                      pdf.MemoryImage(logoImage),
                      width: 60,
                      height: 60,
                      alignment: pdf.Alignment.center,
                    ),
            ]),
        pdf.SizedBox(height: 20),
        pdf.SizedBox(
          width: 500,
          child: pdf.Text(title,
              textAlign: pdf.TextAlign.center,
              style: const pdf.TextStyle(
                decoration: pdf.TextDecoration.underline,
                fontSize: 20.0,
              ),
              maxLines: 4),
        ),
        pdf.SizedBox(width: 10)
      ],
    );
  }

  static Future<Uint8List> generateReadStatus(
    int id,
    String content,
    DateTime createdAt,
    dynamic logoImage,
    List<dynamic> readUsers,
    List<dynamic> unReadUsers,
  ) async {
    final pdf.Document doc = pdf.Document();

    List<List<dynamic>> data = [
      ['Name', 'Email', 'Read/Unread'],
    ];

    for (var user in readUsers) {
      data.add([user.name, user.email, 'Read']);
    }

    for (var user in unReadUsers) {
      data.add([user.name, user.email, 'Unread']);
    }

    List<pdf.TableRow> tableRows = [];

    for (var rowData in data) {
      List<pdf.Widget> row = [];

      for (var cellData in rowData) {
        row.add(
          pdf.Paragraph(
            margin: const pdf.EdgeInsets.all(5.0),
            text: cellData,
          ),
        );
      }

      tableRows.add(pdf.TableRow(children: row));
    }

    var messageId = formatDateTime(createdAt, 'yyMM\'SN\'$id');

    doc.addPage(
      pdf.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pdf.Context context) {
          return [
            generateHeader(logoImage, 'Read Status of $content - $messageId'),
            pdf.SizedBox(height: 20),
            pdf.Table(
              border: pdf.TableBorder.all(width: 1),
              children: tableRows,
            ),
          ];
        },
      ),
    );

    return await doc.save();
  }

  static generateMessageChanges(
    int id,
    String content,
    dynamic logoImage,
    DateTime createdAt,
    List<dynamic> data,
  ) async {
    var messageId = formatDateTime(createdAt, 'yyMM\'SN\'$id');
    final doc = pdf.Document();

    doc.addPage(
      pdf.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pdf.Context context) {
          return [
            generateHeader(
              logoImage,
              'Message Changes - ($messageId) $content',
            ),
            pdf.SizedBox(height: 20.0),
            pdf.Column(
              children: data.map((item) {
                var readInfo = item.reads.map((e) {
                  var time = formatDateTime(e.readAt, 'HH:mm dd/mm/y');

                  return '${item.reads.indexOf(e) + 1}) ${e.reply} (${e.mode}) - $time';
                }).join('\n');

                return pdf.Column(
                  mainAxisAlignment: pdf.MainAxisAlignment.start,
                  crossAxisAlignment: pdf.CrossAxisAlignment.start,
                  children: [
                    pdf.Text(
                      '${item.name} (${item.email})',
                      style: const pdf.TextStyle(fontSize: 18.0),
                      textAlign: pdf.TextAlign.left,
                    ),
                    pdf.SizedBox(height: 8),
                    pdf.Text(readInfo),
                    pdf.Divider(),
                  ],
                );
              }).toList(),
            ),
          ];
        },
      ),
    );

    return await doc.save();
  }

  // static Future<Uint8List> generateMessageChanges(
  //     int id,
  //     String content,
  //     dynamic logoImage,
  //     DateTime createdAt,
  //     List<dynamic> data,
  //     ) async {
  //   var messageId = formatDateTime(createdAt, 'yyMM\'SN\'$id');
  //   final doc = pdf.Document();

  //   doc.addPage(
  //     pdf.MultiPage(
  //       pageFormat: PdfPageFormat.a4,
  //       build: (pdf.Context context) {
  //         return [
  //           generateHeader(
  //             logoImage,
  //             'Message Changes - ($messageId) $content',
  //           ),
  //           pdf.SizedBox(height: 20.0),
  //           pdf.Column(
  //             children: data.map((item) {
  //               var readInfo = item.reads.mapIndexed((index, e) {
  //                 var time = formatDateTime(e.readAt, 'HH:mm dd/mm/y');

  //                 return '${index + 1}) ${e.reply} (${e.mode}) - $time';
  //               }).join('\n');

  //               return pdf.Column(
  //                 mainAxisAlignment: pdf.MainAxisAlignment.start,
  //                 crossAxisAlignment: pdf.CrossAxisAlignment.start,
  //                 children: [
  //                   pdf.Text(
  //                     '${item.name} (${item.email})',
  //                     style: const pdf.TextStyle(fontSize: 18.0),
  //                     textAlign: pdf.TextAlign.left,
  //                   ),
  //                   pdf.SizedBox(height: 8),
  //                   pdf.Text(readInfo),
  //                   pdf.Divider(),
  //                 ],
  //               );
  //             }).toList(),
  //           ),
  //         ];
  //       },
  //     ),
  //   );

  //   return await doc.save();
  // }

  static Future<Uint8List> generateFeedbackDetail(
    int id,
    String createdName,
    String createdEmail,
    String createdPhone,
    String location,
    String organizationName,
    String date,
    String time,
    String feedback,
    String source,
    String color,
    String selectedValues,
    String description,
    String reportedBy,
    String responsiblePerson,
    String actionTaken,
    String status,
    dynamic logoImage,
    List<dynamic> files,
    List<dynamic> images,
    List<dynamic> actionTakenFiles,
    List<dynamic> actionTakenImages,
  ) async {
    final doc = pdf.Document();

    doc.addPage(
      pdf.Page(
        build: (pdf.Context context) {
          return pdf.Column(
            mainAxisAlignment: pdf.MainAxisAlignment.center,
            crossAxisAlignment: pdf.CrossAxisAlignment.start,
            mainAxisSize: pdf.MainAxisSize.max,
            children: [
              generateHeader(
                logoImage,
                'Feedback Report - FB$id',
              ),
              pdf.SizedBox(height: 20.0),
              pdf.Container(
                decoration: pdf.BoxDecoration(
                  borderRadius: const pdf.BorderRadius.all(
                    pdf.Radius.circular(15.0),
                  ),
                  border: pdf.Border.all(
                    width: 1,
                    color: PdfColors.black,
                  ),
                ),
                child: pdf.Padding(
                  padding: const pdf.EdgeInsets.all(16.0),
                  child: pdf.Column(
                    crossAxisAlignment: pdf.CrossAxisAlignment.stretch,
                    mainAxisAlignment: pdf.MainAxisAlignment.start,
                    children: [
                      pdf.Text(
                        'Sender Details',
                        textAlign: pdf.TextAlign.center,
                        style: const pdf.TextStyle(
                          fontSize: 20.0,
                          decoration: pdf.TextDecoration.underline,
                        ),
                      ),
                      pdf.SizedBox(height: 8.0),
                      pdf.RichText(
                        text: pdf.TextSpan(
                          children: <pdf.TextSpan>[
                            pdf.TextSpan(
                              text: 'Name: ',
                              style: pdf.TextStyle(
                                fontWeight: pdf.FontWeight.bold,
                              ),
                            ),
                            pdf.TextSpan(
                              text: createdName,
                            )
                          ],
                        ),
                      ),
                      pdf.SizedBox(height: 8.0),
                      pdf.RichText(
                        text: pdf.TextSpan(
                          children: <pdf.TextSpan>[
                            pdf.TextSpan(
                              text: 'Email: ',
                              style: pdf.TextStyle(
                                fontWeight: pdf.FontWeight.bold,
                              ),
                            ),
                            pdf.TextSpan(
                              text: createdEmail,
                            )
                          ],
                        ),
                      ),
                      pdf.SizedBox(height: 8.0),
                      pdf.RichText(
                        text: pdf.TextSpan(
                          children: <pdf.TextSpan>[
                            pdf.TextSpan(
                              text: 'Phone: ',
                              style: pdf.TextStyle(
                                fontWeight: pdf.FontWeight.bold,
                              ),
                            ),
                            pdf.TextSpan(
                              text: createdPhone,
                            )
                          ],
                        ),
                      ),
                      pdf.SizedBox(height: 8.0),
                    ],
                  ),
                ),
              ),
              pdf.SizedBox(height: 10.0),
              pdf.SizedBox(height: 10.0),
              pdf.Container(
                decoration: pdf.BoxDecoration(
                  borderRadius: const pdf.BorderRadius.all(
                    pdf.Radius.circular(15.0),
                  ),
                  border: pdf.Border.all(
                    width: 1,
                    color: PdfColors.black,
                  ),
                ),
                child: pdf.Padding(
                  padding: const pdf.EdgeInsets.all(16.0),
                  child: pdf.Column(
                    crossAxisAlignment: pdf.CrossAxisAlignment.stretch,
                    mainAxisAlignment: pdf.MainAxisAlignment.start,
                    children: [
                      pdf.Text(
                        'Form Details',
                        textAlign: pdf.TextAlign.center,
                        style: const pdf.TextStyle(
                          fontSize: 20.0,
                          decoration: pdf.TextDecoration.underline,
                        ),
                      ),
                      pdf.SizedBox(height: 8.0),
                      pdf.RichText(
                        text: pdf.TextSpan(
                          children: <pdf.TextSpan>[
                            pdf.TextSpan(
                              text: 'Location: ',
                              style: pdf.TextStyle(
                                fontWeight: pdf.FontWeight.bold,
                              ),
                            ),
                            pdf.TextSpan(
                              text: location,
                            )
                          ],
                        ),
                      ),
                      pdf.SizedBox(height: 8.0),
                      pdf.RichText(
                        text: pdf.TextSpan(
                          children: <pdf.TextSpan>[
                            pdf.TextSpan(
                              text: 'Organization Name: ',
                              style: pdf.TextStyle(
                                fontWeight: pdf.FontWeight.bold,
                              ),
                            ),
                            pdf.TextSpan(
                              text: organizationName,
                            )
                          ],
                        ),
                      ),
                      pdf.SizedBox(height: 8.0),
                      pdf.RichText(
                        text: pdf.TextSpan(
                          children: <pdf.TextSpan>[
                            pdf.TextSpan(
                              text: 'Date: ',
                              style: pdf.TextStyle(
                                fontWeight: pdf.FontWeight.bold,
                              ),
                            ),
                            pdf.TextSpan(
                              text: date,
                            )
                          ],
                        ),
                      ),
                      pdf.SizedBox(height: 8.0),
                      pdf.RichText(
                        text: pdf.TextSpan(
                          children: <pdf.TextSpan>[
                            pdf.TextSpan(
                              text: 'Time: ',
                              style: pdf.TextStyle(
                                fontWeight: pdf.FontWeight.bold,
                              ),
                            ),
                            pdf.TextSpan(
                              text: time,
                            )
                          ],
                        ),
                      ),
                      pdf.SizedBox(height: 8.0),
                      pdf.RichText(
                        text: pdf.TextSpan(
                          children: <pdf.TextSpan>[
                            pdf.TextSpan(
                              text: 'Feedback: ',
                              style: pdf.TextStyle(
                                fontWeight: pdf.FontWeight.bold,
                              ),
                            ),
                            pdf.TextSpan(
                              text: feedback,
                            )
                          ],
                        ),
                      ),
                      pdf.SizedBox(height: 8.0),
                      pdf.RichText(
                        text: pdf.TextSpan(
                          children: <pdf.TextSpan>[
                            pdf.TextSpan(
                              text: 'Source: ',
                              style: pdf.TextStyle(
                                fontWeight: pdf.FontWeight.bold,
                              ),
                            ),
                            pdf.TextSpan(
                              text: source,
                            )
                          ],
                        ),
                      ),
                      pdf.SizedBox(height: 8.0),
                      pdf.RichText(
                        text: pdf.TextSpan(
                          children: <pdf.TextSpan>[
                            pdf.TextSpan(
                              text: 'Color: ',
                              style: pdf.TextStyle(
                                fontWeight: pdf.FontWeight.bold,
                              ),
                            ),
                            pdf.TextSpan(
                              text: color,
                            )
                          ],
                        ),
                      ),
                      pdf.SizedBox(height: 8.0),
                      pdf.RichText(
                        text: pdf.TextSpan(
                          children: <pdf.TextSpan>[
                            pdf.TextSpan(
                              text: 'Selected Values: ',
                              style: pdf.TextStyle(
                                fontWeight: pdf.FontWeight.bold,
                              ),
                            ),
                            pdf.TextSpan(
                              text: selectedValues,
                            )
                          ],
                        ),
                      ),
                      pdf.SizedBox(height: 8.0),
                      pdf.RichText(
                        text: pdf.TextSpan(
                          children: <pdf.TextSpan>[
                            pdf.TextSpan(
                              text: 'Description: ',
                              style: pdf.TextStyle(
                                fontWeight: pdf.FontWeight.bold,
                              ),
                            ),
                            pdf.TextSpan(
                              text: description,
                            )
                          ],
                        ),
                      ),
                      pdf.SizedBox(height: 8.0),
                      pdf.RichText(
                        text: pdf.TextSpan(
                          children: <pdf.TextSpan>[
                            pdf.TextSpan(
                              text: 'Reported By: ',
                              style: pdf.TextStyle(
                                fontWeight: pdf.FontWeight.bold,
                              ),
                            ),
                            pdf.TextSpan(
                              text: reportedBy,
                            )
                          ],
                        ),
                      ),
                      pdf.SizedBox(height: 8.0),
                    ],
                  ),
                ),
              ),
              pdf.SizedBox(height: 10.0),
              pdf.SizedBox(height: 10.0),
              pdf.Container(
                decoration: pdf.BoxDecoration(
                  borderRadius: const pdf.BorderRadius.all(
                    pdf.Radius.circular(15.0),
                  ),
                  border: pdf.Border.all(
                    width: 1,
                    color: PdfColors.black,
                  ),
                ),
                child: pdf.Padding(
                  padding: const pdf.EdgeInsets.all(16.0),
                  child: pdf.Column(
                    crossAxisAlignment: pdf.CrossAxisAlignment.stretch,
                    mainAxisAlignment: pdf.MainAxisAlignment.start,
                    children: [
                      pdf.Text(
                        'Admin Response',
                        textAlign: pdf.TextAlign.center,
                        style: const pdf.TextStyle(
                          fontSize: 20.0,
                          decoration: pdf.TextDecoration.underline,
                        ),
                      ),
                      pdf.RichText(
                        text: pdf.TextSpan(
                          children: <pdf.TextSpan>[
                            pdf.TextSpan(
                              text: 'Responsible Person: ',
                              style: pdf.TextStyle(
                                fontWeight: pdf.FontWeight.bold,
                              ),
                            ),
                            pdf.TextSpan(
                              text: responsiblePerson,
                            )
                          ],
                        ),
                      ),
                      pdf.SizedBox(height: 8.0),
                      pdf.RichText(
                        text: pdf.TextSpan(
                          children: <pdf.TextSpan>[
                            pdf.TextSpan(
                              text: 'Action Taken: ',
                              style: pdf.TextStyle(
                                fontWeight: pdf.FontWeight.bold,
                              ),
                            ),
                            pdf.TextSpan(
                              text: actionTaken,
                            )
                          ],
                        ),
                      ),
                      pdf.SizedBox(height: 8.0),
                      pdf.RichText(
                        text: pdf.TextSpan(
                          children: <pdf.TextSpan>[
                            pdf.TextSpan(
                              text: 'Status: ',
                              style: pdf.TextStyle(
                                fontWeight: pdf.FontWeight.bold,
                              ),
                            ),
                            pdf.TextSpan(
                              text: status,
                            )
                          ],
                        ),
                      ),
                      pdf.SizedBox(height: 8.0),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    doc.addPage(
      pdf.Page(
        build: (pdf.Context context) {
          return pdf.Column(
            children: [
              generateHeader(logoImage, 'Images'),
              pdf.SizedBox(height: 20),
              pdf.GridView(
                crossAxisCount: 2,
                childAspectRatio: 1.0,
                children: files.isNotEmpty
                    ? files.mapIndexed((index, file) {
                        return kIsWeb
                            ? pdf.Image(
                                pdf.MemoryImage(images[index]!),
                                height: 220,
                              )
                            : pdf.Image(
                                pdf.MemoryImage(images[index]!),
                                height: 220,
                              );
                      }).toList()
                    : [
                        pdf.Text('No Images Were Attached'),
                      ],
              ),
            ],
          );
        },
      ),
    );

    doc.addPage(
      pdf.Page(
        build: (pdf.Context context) {
          return pdf.Column(
            children: [
              generateHeader(logoImage, 'Images'),
              pdf.SizedBox(height: 20),
              pdf.GridView(
                crossAxisCount: 2,
                childAspectRatio: 1.0,
                children: actionTakenFiles.isNotEmpty
                    ? actionTakenFiles.mapIndexed((index, file) {
                        return kIsWeb
                            ? pdf.Image(
                                pdf.MemoryImage(actionTakenImages[index]!),
                                height: 220,
                              )
                            : pdf.Image(
                                pdf.MemoryImage(actionTakenImages[index]!),
                                height: 220,
                              );
                      }).toList()
                    : [
                        pdf.Text('No Images Were Attached'),
                      ],
              ),
            ],
          );
        },
      ),
    );

    return await doc.save();
  }

  static Future<Uint8List> generateAcknowledgeFeedbackDetail(
    int id,
    String createdName,
    String createdEmail,
    String createdPhone,
    String location,
    String organizationName,
    String date,
    String time,
    String feedback,
    String source,
    String color,
    String selectedValues,
    String description,
    String acknowledgement,
    String reportedBy,
    String responsiblePerson,
    String actionTaken,
    String status,
    dynamic logoImage,
    List<dynamic> files,
    List<dynamic> images,
    List<dynamic> actionTakenFiles,
    List<dynamic> actionTakenImages,
  ) async {
    final doc = pdf.Document();

    doc.addPage(
      pdf.Page(
        build: (pdf.Context context) {
          return pdf.Column(
            mainAxisAlignment: pdf.MainAxisAlignment.center,
            crossAxisAlignment: pdf.CrossAxisAlignment.start,
            mainAxisSize: pdf.MainAxisSize.max,
            children: [
              generateHeader(
                logoImage,
                'Acknowledged Feedback - FB$id',
              ),
              pdf.SizedBox(height: 20.0),
              pdf.Container(
                decoration: pdf.BoxDecoration(
                  borderRadius: const pdf.BorderRadius.all(
                    pdf.Radius.circular(15.0),
                  ),
                  border: pdf.Border.all(
                    width: 1,
                    color: PdfColors.black,
                  ),
                ),
                child: pdf.Padding(
                  padding: const pdf.EdgeInsets.all(16.0),
                  child: pdf.Column(
                    crossAxisAlignment: pdf.CrossAxisAlignment.stretch,
                    mainAxisAlignment: pdf.MainAxisAlignment.start,
                    children: [
                      pdf.Text(
                        'Sender Details',
                        textAlign: pdf.TextAlign.center,
                        style: const pdf.TextStyle(
                          fontSize: 20.0,
                          decoration: pdf.TextDecoration.underline,
                        ),
                      ),
                      pdf.SizedBox(height: 8.0),
                      pdf.RichText(
                        text: pdf.TextSpan(
                          children: <pdf.TextSpan>[
                            pdf.TextSpan(
                              text: 'Name: ',
                              style: pdf.TextStyle(
                                fontWeight: pdf.FontWeight.bold,
                              ),
                            ),
                            pdf.TextSpan(
                              text: createdName,
                            )
                          ],
                        ),
                      ),
                      pdf.SizedBox(height: 8.0),
                      pdf.RichText(
                        text: pdf.TextSpan(
                          children: <pdf.TextSpan>[
                            pdf.TextSpan(
                              text: 'Email: ',
                              style: pdf.TextStyle(
                                fontWeight: pdf.FontWeight.bold,
                              ),
                            ),
                            pdf.TextSpan(
                              text: createdEmail,
                            )
                          ],
                        ),
                      ),
                      pdf.SizedBox(height: 8.0),
                      pdf.RichText(
                        text: pdf.TextSpan(
                          children: <pdf.TextSpan>[
                            pdf.TextSpan(
                              text: 'Phone: ',
                              style: pdf.TextStyle(
                                fontWeight: pdf.FontWeight.bold,
                              ),
                            ),
                            pdf.TextSpan(
                              text: createdPhone,
                            )
                          ],
                        ),
                      ),
                      pdf.SizedBox(height: 8.0),
                    ],
                  ),
                ),
              ),
              pdf.SizedBox(height: 10.0),
              pdf.SizedBox(height: 10.0),
              pdf.Container(
                decoration: pdf.BoxDecoration(
                  borderRadius: const pdf.BorderRadius.all(
                    pdf.Radius.circular(15.0),
                  ),
                  border: pdf.Border.all(
                    width: 1,
                    color: PdfColors.black,
                  ),
                ),
                child: pdf.Padding(
                  padding: const pdf.EdgeInsets.all(16.0),
                  child: pdf.Column(
                    crossAxisAlignment: pdf.CrossAxisAlignment.stretch,
                    mainAxisAlignment: pdf.MainAxisAlignment.start,
                    children: [
                      pdf.Text(
                        'Form Details',
                        textAlign: pdf.TextAlign.center,
                        style: const pdf.TextStyle(
                          fontSize: 20.0,
                          decoration: pdf.TextDecoration.underline,
                        ),
                      ),
                      pdf.SizedBox(height: 8.0),
                      pdf.RichText(
                        text: pdf.TextSpan(
                          children: <pdf.TextSpan>[
                            pdf.TextSpan(
                              text: 'Location: ',
                              style: pdf.TextStyle(
                                fontWeight: pdf.FontWeight.bold,
                              ),
                            ),
                            pdf.TextSpan(
                              text: location,
                            )
                          ],
                        ),
                      ),
                      pdf.SizedBox(height: 8.0),
                      pdf.RichText(
                        text: pdf.TextSpan(
                          children: <pdf.TextSpan>[
                            pdf.TextSpan(
                              text: 'Organization Name: ',
                              style: pdf.TextStyle(
                                fontWeight: pdf.FontWeight.bold,
                              ),
                            ),
                            pdf.TextSpan(
                              text: organizationName,
                            )
                          ],
                        ),
                      ),
                      pdf.SizedBox(height: 8.0),
                      pdf.RichText(
                        text: pdf.TextSpan(
                          children: <pdf.TextSpan>[
                            pdf.TextSpan(
                              text: 'Date: ',
                              style: pdf.TextStyle(
                                fontWeight: pdf.FontWeight.bold,
                              ),
                            ),
                            pdf.TextSpan(
                              text: date,
                            )
                          ],
                        ),
                      ),
                      pdf.SizedBox(height: 8.0),
                      pdf.RichText(
                        text: pdf.TextSpan(
                          children: <pdf.TextSpan>[
                            pdf.TextSpan(
                              text: 'Time: ',
                              style: pdf.TextStyle(
                                fontWeight: pdf.FontWeight.bold,
                              ),
                            ),
                            pdf.TextSpan(
                              text: time,
                            )
                          ],
                        ),
                      ),
                      pdf.SizedBox(height: 8.0),
                      pdf.RichText(
                        text: pdf.TextSpan(
                          children: <pdf.TextSpan>[
                            pdf.TextSpan(
                              text: 'Feedback: ',
                              style: pdf.TextStyle(
                                fontWeight: pdf.FontWeight.bold,
                              ),
                            ),
                            pdf.TextSpan(
                              text: feedback,
                            )
                          ],
                        ),
                      ),
                      pdf.SizedBox(height: 8.0),
                      pdf.RichText(
                        text: pdf.TextSpan(
                          children: <pdf.TextSpan>[
                            pdf.TextSpan(
                              text: 'Source: ',
                              style: pdf.TextStyle(
                                fontWeight: pdf.FontWeight.bold,
                              ),
                            ),
                            pdf.TextSpan(
                              text: source,
                            )
                          ],
                        ),
                      ),
                      pdf.SizedBox(height: 8.0),
                      pdf.RichText(
                        text: pdf.TextSpan(
                          children: <pdf.TextSpan>[
                            pdf.TextSpan(
                              text: 'Color: ',
                              style: pdf.TextStyle(
                                fontWeight: pdf.FontWeight.bold,
                              ),
                            ),
                            pdf.TextSpan(
                              text: color,
                            )
                          ],
                        ),
                      ),
                      pdf.SizedBox(height: 8.0),
                      pdf.RichText(
                        text: pdf.TextSpan(
                          children: <pdf.TextSpan>[
                            pdf.TextSpan(
                              text: 'Selected Values: ',
                              style: pdf.TextStyle(
                                fontWeight: pdf.FontWeight.bold,
                              ),
                            ),
                            pdf.TextSpan(
                              text: selectedValues,
                            )
                          ],
                        ),
                      ),
                      pdf.SizedBox(height: 8.0),
                      pdf.RichText(
                        text: pdf.TextSpan(
                          children: <pdf.TextSpan>[
                            pdf.TextSpan(
                              text: 'Description: ',
                              style: pdf.TextStyle(
                                fontWeight: pdf.FontWeight.bold,
                              ),
                            ),
                            pdf.TextSpan(
                              text: description,
                            )
                          ],
                        ),
                      ),
                      pdf.SizedBox(height: 8.0),
                      pdf.RichText(
                        text: pdf.TextSpan(
                          children: <pdf.TextSpan>[
                            pdf.TextSpan(
                              text: 'Acknowledgement: ',
                              style: pdf.TextStyle(
                                fontWeight: pdf.FontWeight.bold,
                              ),
                            ),
                            pdf.TextSpan(
                              text: acknowledgement,
                            )
                          ],
                        ),
                      ),
                      pdf.SizedBox(height: 8.0),
                      pdf.RichText(
                        text: pdf.TextSpan(
                          children: <pdf.TextSpan>[
                            pdf.TextSpan(
                              text: 'Reported By: ',
                              style: pdf.TextStyle(
                                fontWeight: pdf.FontWeight.bold,
                              ),
                            ),
                            pdf.TextSpan(
                              text: reportedBy,
                            )
                          ],
                        ),
                      ),
                      pdf.SizedBox(height: 8.0),
                    ],
                  ),
                ),
              ),
              pdf.SizedBox(height: 10.0),
              pdf.SizedBox(height: 10.0),
              pdf.Container(
                decoration: pdf.BoxDecoration(
                  borderRadius: const pdf.BorderRadius.all(
                    pdf.Radius.circular(15.0),
                  ),
                  border: pdf.Border.all(
                    width: 1,
                    color: PdfColors.black,
                  ),
                ),
                child: pdf.Padding(
                  padding: const pdf.EdgeInsets.all(16.0),
                  child: pdf.Column(
                    crossAxisAlignment: pdf.CrossAxisAlignment.stretch,
                    mainAxisAlignment: pdf.MainAxisAlignment.start,
                    children: [
                      pdf.Text(
                        'Admin Response',
                        textAlign: pdf.TextAlign.center,
                        style: const pdf.TextStyle(
                          fontSize: 20.0,
                          decoration: pdf.TextDecoration.underline,
                        ),
                      ),
                      pdf.RichText(
                        text: pdf.TextSpan(
                          children: <pdf.TextSpan>[
                            pdf.TextSpan(
                              text: 'Responsible Person: ',
                              style: pdf.TextStyle(
                                fontWeight: pdf.FontWeight.bold,
                              ),
                            ),
                            pdf.TextSpan(
                              text: responsiblePerson,
                            )
                          ],
                        ),
                      ),
                      pdf.SizedBox(height: 8.0),
                      pdf.RichText(
                        text: pdf.TextSpan(
                          children: <pdf.TextSpan>[
                            pdf.TextSpan(
                              text: 'Action Taken: ',
                              style: pdf.TextStyle(
                                fontWeight: pdf.FontWeight.bold,
                              ),
                            ),
                            pdf.TextSpan(
                              text: actionTaken,
                            )
                          ],
                        ),
                      ),
                      pdf.SizedBox(height: 8.0),
                      pdf.RichText(
                        text: pdf.TextSpan(
                          children: <pdf.TextSpan>[
                            pdf.TextSpan(
                              text: 'Status: ',
                              style: pdf.TextStyle(
                                fontWeight: pdf.FontWeight.bold,
                              ),
                            ),
                            pdf.TextSpan(
                              text: status,
                            )
                          ],
                        ),
                      ),
                      pdf.SizedBox(height: 8.0),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    doc.addPage(
      pdf.Page(
        build: (pdf.Context context) {
          return pdf.Column(
            children: [
              generateHeader(logoImage, 'Images'),
              pdf.SizedBox(height: 20),
              pdf.GridView(
                crossAxisCount: 2,
                childAspectRatio: 1.0,
                children: files.isNotEmpty
                    ? files.mapIndexed((index, file) {
                        return kIsWeb
                            ? pdf.Image(
                                pdf.MemoryImage(images[index]!),
                                height: 220,
                              )
                            : pdf.Image(
                                pdf.MemoryImage(images[index]!),
                                height: 220,
                              );
                      }).toList()
                    : [
                        pdf.Text('No Images Were Attached'),
                      ],
              ),
            ],
          );
        },
      ),
    );

    doc.addPage(
      pdf.Page(
        build: (pdf.Context context) {
          return pdf.Column(
            children: [
              generateHeader(logoImage, 'Images'),
              pdf.SizedBox(height: 20),
              pdf.GridView(
                crossAxisCount: 2,
                childAspectRatio: 1.0,
                children: actionTakenFiles.isNotEmpty
                    ? actionTakenFiles.mapIndexed((index, file) {
                        return kIsWeb
                            ? pdf.Image(
                                pdf.MemoryImage(actionTakenImages[index]!),
                                height: 220,
                              )
                            : pdf.Image(
                                pdf.MemoryImage(actionTakenImages[index]!),
                                height: 220,
                              );
                      }).toList()
                    : [
                        pdf.Text('No Images Were Attached'),
                      ],
              ),
            ],
          );
        },
      ),
    );

    return await doc.save();
  }

  static Future<Uint8List> generateUserOrientationReadInfo(
    int id,
    String name,
    DateTime createdAt,
    dynamic logoImage,
    List<dynamic> userOrientationReads,
  ) async {
    final pdf.Document doc = pdf.Document();

    List<List<dynamic>> data = [
      ['Name', 'Email', 'Read At'],
    ];

    for (var userRead in userOrientationReads) {
      data.add(
        [
          userRead.user.name,
          userRead.user.email,
          formatDateTime(userRead.readAt, 'HH:mm dd/mm/y')
        ],
      );
    }

    List<pdf.TableRow> tableRows = [];

    for (var rowData in data) {
      List<pdf.Widget> row = [];

      for (var cellData in rowData) {
        row.add(
          pdf.Paragraph(
            margin: const pdf.EdgeInsets.all(5.0),
            text: cellData,
          ),
        );
      }

      tableRows.add(pdf.TableRow(children: row));
    }

    var messageId = 'User Orientation Info ($name) - $id';

    doc.addPage(
      pdf.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pdf.Context context) {
          return [
            generateHeader(logoImage, messageId),
            pdf.SizedBox(height: 20),
            pdf.Table(
              border: pdf.TableBorder.all(width: 1),
              children: tableRows,
            ),
          ];
        },
      ),
    );

    return await doc.save();
  }

  static Future<Uint8List> generateMeetingData(
      List<Map<String, dynamic>> meetings) async {
    final pdf.Document doc = pdf.Document();

    List<List<dynamic>> data = [
      [
        'Meeting ID',
        'Meeting Host',
        'Meeting type',
        'Department',
        'Title',
        'Date & Time',
        // 'Start Time',
        // 'End Time'
      ],
    ];

    for (var meeting in meetings) {
      data.add([
        meeting['meetingId'],
        meeting['meetCreater'],
        meeting['isOnline'] == true ? "Online" : "Offline",
        meeting['department'],
        meeting['meetTitle'],
        DateTime.tryParse(meeting['meetDateTime']) != null
            ? DateFormat("dd-MM-yyyy")
                .format(DateTime.parse(meeting['meetDateTime']))
            : meeting['meetDateTime'],
        // meeting['meetDateTime'],
        // meeting[
        //     'meetDateTime'], // Assuming start time and date are the same for simplicity
        // meeting['meetEndTime'],
      ]);
    }

    List<pdf.TableRow> tableRows = [];

    for (var rowData in data) {
      List<pdf.Widget> row = [];

      for (var cellData in rowData) {
        row.add(
          pdf.Paragraph(
            margin: const pdf.EdgeInsets.all(5.0),
            text: '$cellData',
          ),
        );
      }

      tableRows.add(pdf.TableRow(children: row));
    }

    doc.addPage(
      pdf.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pdf.Context context) {
          return [
            pdf.Table(
              border: pdf.TableBorder.all(width: 1),
              children: tableRows,
            ),
          ];
        },
      ),
    );

    return await doc.save();
  }

  static Future<Uint8List> generateChecklistData(
      List<dynamic> checklistData) async {
    final pdf.Document doc = pdf.Document();

    List<List<dynamic>> data = [
      ['Form ID', 'User', 'Form Title', 'Date and Time'],
    ];

    for (var checklistItem in checklistData) {
      data.add([
        checklistItem['formId'],
        checklistItem['username'],
        checklistItem['formTitle'],
        checklistItem['dateAndTime'],
      ]);
    }

    List<pdf.TableRow> tableRows = [];

    for (var rowData in data) {
      List<pdf.Widget> row = [];

      for (var cellData in rowData) {
        row.add(
          pdf.Paragraph(
            margin: const pdf.EdgeInsets.all(5.0),
            text: '$cellData',
          ),
        );
      }

      tableRows.add(pdf.TableRow(children: row));
    }

    doc.addPage(
      pdf.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pdf.Context context) {
          return [
            pdf.Table(
              border: pdf.TableBorder.all(width: 1),
              children: tableRows,
            ),
          ];
        },
      ),
    );

    return await doc.save();
  }

  static Future<pw.Document> generatePdfFile(
      Map<String, dynamic> cardData) async {
    final pdf = pw.Document();
    final ByteData image = await rootBundle.load('assets/images/logo.png');
    Uint8List logoImage = image.buffer.asUint8List();
    Uint8List signatureImage =
        await _loadNetworkImage(cardData['userSign'] ?? '');

    pw.Widget buildFormField(String label, String value) {
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            '$label: $value',
            style: pw.TextStyle(
              fontSize: 16.0,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 8.0),
        ],
      );
    }

    pw.Widget buildSignatureSection(Uint8List signatureImage) {
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Signature',
              style:
                  pw.TextStyle(fontSize: 18.0, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.Container(
            width: 200,
            height: 150,
            child:
                pw.Image(pw.MemoryImage(signatureImage), height: 40, width: 80),
          ),
        ],
      );
    }

    pdf.addPage(
      pw.MultiPage(
        build: (pw.Context context) => [
          // Page 1
          pw.Column(
            children: [
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Container(
                      child: pw.Image(
                        pw.MemoryImage(logoImage),
                        width: 100.0,
                        height: 100.0,
                      ),
                    ),
                    pw.SizedBox(height: 8.0),
                    pw.Text(
                      ' ${cardData['formTitle']}',
                      style: const pw.TextStyle(fontSize: 20),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Page 2
          pw.Container(
            padding: const pw.EdgeInsets.all(16.0),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                buildFormField('Inspected By', cardData['username']),
                buildFormField('Area', cardData['header1']),
                buildFormField('Department', cardData['header2']),
                if (cardData['filterTitle'] != 'OVERHEADCRANE' &&
                    cardData['filterTitle'] != 'LMA' &&
                    cardData['filterTitle'] != 'LPS')
                  buildFormField('Observer', cardData['person2']),
                if (cardData['filterTitle'] != 'OVERHEADCRANE' &&
                    cardData['filterTitle'] != 'LMA' &&
                    cardData['filterTitle'] != 'LPS')
                  buildFormField('Task', cardData['header3']),
                if (cardData['filterTitle'] == 'OVERHEADCRANE')
                  buildFormField('Lifting Machine', cardData['description']),
                pw.Text(
                  'Date: ${DateFormat.yMd().format(DateTime.parse(cardData['dateAndTime']))}',
                  style: pw.TextStyle(
                    fontSize: 16.0,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  'Time: ${DateFormat.jm().format(DateTime.parse(cardData['dateAndTime']))}',
                  style: pw.TextStyle(
                    fontSize: 16.0,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8.0),
                pw.Divider(thickness: 8.0),
                pw.Center(
                  child: pw.Text(
                    'Questions and Answers',
                    style: pw.TextStyle(
                      fontSize: 18.0,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.SizedBox(height: 10.0),
                for (var question in cardData['questions'])
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        ' ${question['content']}',
                        style: pw.TextStyle(
                          fontSize: 16.0,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        ' ${question['answerList'][0]['answer']}',
                        style: const pw.TextStyle(
                          fontSize: 14.0,
                        ),
                      ),
                      pw.Text(
                        ' ${question['answerList'][0]['qusContent']}',
                        style: const pw.TextStyle(
                          fontSize: 14.0,
                        ),
                      ),
                      pw.Divider(thickness: 1.0),
                    ],
                  ),
                pw.SizedBox(height: 20),

                // Signature Section
                pw.Row(mainAxisAlignment: pw.MainAxisAlignment.end, children: [
                  buildSignatureSection(signatureImage),
                ])
              ],
            ),
          ),
        ],
      ),
    );

    return pdf;
  }

  static Future<Uint8List> _loadNetworkImage(String imageUrl) async {
    final Completer<Uint8List> completer = Completer();

    if (imageUrl.isEmpty) {
      // Provide a fallback image
      completer.complete(Uint8List.fromList(
          [])); // You can replace this with the appropriate fallback image data
      return completer.future;
    }

    final image = NetworkImage(imageUrl);
    const configuration = ImageConfiguration.empty;

    final Completer<ImageInfo> imageInfoCompleter = Completer<ImageInfo>();
    image.resolve(configuration).addListener(
        ImageStreamListener((ImageInfo image, bool synchronousCall) {
      imageInfoCompleter.complete(image);
    }));

    ImageInfo imageInfo = await imageInfoCompleter.future;
    ByteData? byteData =
        await imageInfo.image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List? uint8List = byteData?.buffer.asUint8List();

    completer.complete(uint8List);
    return completer.future;
  }

// for fpoc
  static Future<pw.Document> generateFPOCPdf(
      Map<String, dynamic> cardData) async {
    PdfColor? getColorForRowIndex(int index) {
      var coloredRows = [3, 6, 8, 11];

      if (coloredRows.contains(index)) {
        return const PdfColor.fromInt(0xFFFFFF00); // Yellow color in PDF
      }

      return null;
    }

    final pdf = pw.Document();
    final ByteData image = await rootBundle.load('assets/images/logo.png');
    Uint8List logoImage = image.buffer.asUint8List();
    Uint8List signatureImage =
        await _loadNetworkImage(cardData['userSign'] ?? '');

    pw.Widget buildSignatureSection(Uint8List signatureImage) {
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Signature',
              style:
                  pw.TextStyle(fontSize: 18.0, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.Container(
            width: 200,
            height: 150,
            child:
                pw.Image(pw.MemoryImage(signatureImage), height: 40, width: 80),
          ),
        ],
      );
    }

    pdf.addPage(
      pw.MultiPage(
        build: (pw.Context context) {
          return [
            pw.Center(
              child: pw.Column(
                children: [
                  pw.Container(
                    child: pw.Image(
                      pw.MemoryImage(logoImage),
                      width: 100.0, // Adjust the width as needed
                      height: 100.0, // Adjust the height as needed
                    ),
                  ),
                  pw.SizedBox(height: 8.0),
                  pw.Text('${cardData['formTitle']}',
                      style: const pw.TextStyle(fontSize: 20)),
                ],
              ),
            ),
            pw.Container(
              padding: const pw.EdgeInsets.all(16.0),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Forklift Driver: ${cardData['username']}',
                    style: pw.TextStyle(
                      fontSize: 16.0,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 5.0),
                  pw.Text(
                    'Area: ${cardData['header1']}',
                    style: pw.TextStyle(
                      fontSize: 16.0,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 5.0),
                  pw.Text(
                    'Department: ${cardData['header2']}',
                    style: pw.TextStyle(
                      fontSize: 16.0,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 5.0),
                  pw.Text(
                    'Weeks: ${cardData['header3']}',
                    style: pw.TextStyle(
                      fontSize: 16.0,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 5.0),
                  pw.Text(
                    'Machine No:: ${cardData['person2']}',
                    style: pw.TextStyle(
                      fontSize: 16.0,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 5.0),
                  pw.Text(
                    'Date: ${DateFormat.yMd().format(DateTime.parse(cardData['dateAndTime']))}',
                    style: pw.TextStyle(
                      fontSize: 16.0,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 5.0),
                  pw.Text(
                    'Time: ${DateFormat.jm().format(DateTime.parse(cardData['dateAndTime']))}',
                    style: pw.TextStyle(
                      fontSize: 16.0,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 5.0),
                  pw.Text(
                    'Forklift Pre-Operational Checklist ${cardData['description']}',
                    style: pw.TextStyle(
                      fontSize: 15.0,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 8.0),
                  pw.Divider(thickness: 8.0),
                  pw.SizedBox(height: 8.0),
                  pw.Container(
                    child: pw.Padding(
                      padding: const pw.EdgeInsets.all(14.0),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                        children: [
                          pw.Text(
                            'Procedures:',
                            style: pw.TextStyle(
                                fontSize: 20, fontWeight: pw.FontWeight.bold),
                          ),
                          pw.SizedBox(height: 8),
                          pw.Text(
                              '1. First user of forklift shall check and ensure the following items are in proper order on a daily basis.'),
                          pw.SizedBox(height: 8),
                          pw.Text(
                              '2. Any deficiency found in the checklist must be immediately brought to the attention of the SCM Supervisor'),
                          pw.SizedBox(height: 8),
                          pw.Text(
                            '3. The truck shall not be used and the SCM Supervisor shall tag it OUT OF SERVICE  DO NOT OPERATE until repair is completed.',
                          ),
                        ],
                      ),
                    ),
                  ),
                  pw.Table(
                    border: pw.TableBorder.all(),
                    columnWidths: {
                      0: const pw.FlexColumnWidth(0.5),
                      1: const pw.FlexColumnWidth(1.5),
                      2: const pw.FlexColumnWidth(1.5),
                    },
                    children: [
                      pw.TableRow(
                        children: [
                          pw.Center(
                            child: pw.Text('S/N',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold)),
                          ),
                          pw.Center(
                            child: pw.Text('Item',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold)),
                          ),
                          pw.Center(
                            child: pw.Text('Remarks',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold)),
                          )
                        ],
                      ),
                      for (var index = 0;
                          index < cardData['questions'].length;
                          index++)
                        pw.TableRow(
                          children: [
                            pw.Center(
                              child: pw.Text('${index + 1}'),
                            ),
                            pw.Center(
                              child: pw.Text(
                                  cardData['questions'][index]['content']),
                            ),
                            pw.Center(
                              child: pw.Text(
                                cardData['questions'][index]['answerList']
                                        .isNotEmpty
                                    ? cardData['questions'][index]['answerList']
                                            [0]['qusContent']
                                        .toString()
                                    : 'N/A',
                              ),
                            )
                          ],
                          decoration: pw.BoxDecoration(
                            color: getColorForRowIndex(index) ??
                                const PdfColor.fromInt(0x00FFFFFF),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 8.0),
            pw.Divider(thickness: 8.0),
            pw.SizedBox(height: 20.0),
            pw.Row(mainAxisAlignment: pw.MainAxisAlignment.end, children: [
              buildSignatureSection(signatureImage),
            ])
          ];
        },
      ),
    );

    return pdf;
  }

  // For meeting
  // static Future<pw.Document> generateMeetingDetailsPdf(
  //     Map<String, dynamic> meetingDetails, Uint8List logoImage) async {
  //   String formatDateTime(String? dateTimeString) {
  //     if (dateTimeString == null || dateTimeString.isEmpty) {
  //       return 'N/A';
  //     }
  //     final dateTime = DateTime.parse(dateTimeString);
  //     final formattedDate = DateFormat.yMd().add_jm().format(dateTime);
  //     return formattedDate;
  //   }

  //   List<Uint8List> signatureImages = [];

  //   for (var member in meetingDetails['data']?['membersAttended'] ?? []) {
  //     Uint8List signatureImage =
  //         await _loadNetworkImage(member?['digitalSignatureFile'] ?? '');
  //     signatureImages.add(signatureImage);
  //   }

  //   final List<pw.TableRow> allRows = [];
  //   for (var i = 0; i < signatureImages.length; i += 10) {
  //     final List<pw.TableRow> currentPageRows = [];
  //     for (var j = i; j < i + 10 && j < signatureImages.length; j++) {
  //       final currentCounter = j + 1;
  //       currentPageRows.add(
  //         pw.TableRow(
  //           children: [
  //             pw.Center(
  //                 child: pw.Text('$currentCounter',
  //                     style: const pw.TextStyle(fontSize: 10))),
  //             pw.Center(
  //                 child: pw.Text(
  //                     '${meetingDetails['data']?['membersAttended'][j]['membersName'] ?? 'N/A'}',
  //                     style: const pw.TextStyle(fontSize: 10))),
  //             pw.Center(
  //                 child: pw.Image(pw.MemoryImage(signatureImages[j]),
  //                     height: 40, width: 80)),
  //             pw.Center(
  //                 child: pw.Text(
  //                     '${meetingDetails['data']?['membersAttended'][j]['remark'] ?? 'N/A'}',
  //                     style: const pw.TextStyle(fontSize: 10))),
  //           ],
  //         ),
  //       );
  //     }
  //     allRows.addAll(currentPageRows);
  //   }

  //   final pdf = pw.Document();
  //   final pw.TableRow header = pw.TableRow(
  //     decoration: const pw.BoxDecoration(
  //       color: PdfColors.grey300,
  //     ),
  //     children: [
  //       pw.Center(
  //           child: pw.Text('S.No',
  //               style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
  //       pw.Center(
  //           child: pw.Text('Name',
  //               style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
  //       pw.Center(
  //           child: pw.Text('Signature',
  //               style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
  //       pw.Center(
  //           child: pw.Text('Remarks',
  //               style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
  //     ],
  //   );

  //   for (var chunkIndex = 0; chunkIndex < allRows.length; chunkIndex += 10) {
  //     final rowsChunk = allRows.sublist(chunkIndex,
  //         chunkIndex + 10 < allRows.length ? chunkIndex + 10 : allRows.length);
  //     final pdfContent = pw.Column(
  //       mainAxisAlignment: pw.MainAxisAlignment.start,
  //       crossAxisAlignment: pw.CrossAxisAlignment.start,
  //       children: [
  //         pw.Row(children: [
  //           pw.Image(
  //             pw.MemoryImage(logoImage),
  //             width: 70.0, // Adjust the width as needed
  //             height: 70.0, // Adjust the height as needed
  //           ),
  //           pw.SizedBox(width: 90),
  //           pw.Text('Toolbox Meeting',
  //               style:
  //                   pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 20)),
  //         ]),
  //         pw.SizedBox(height: 15),
  //         if (chunkIndex == 0) ...[
  //           pw.Container(
  //             height: "${meetingDetails['data']['description']}".length < 100
  //                 ? 200
  //                 : 300,
  //             width: double.infinity,
  //             decoration: pw.BoxDecoration(
  //               border: pw.Border.all(),
  //               borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
  //             ),
  //             child: pw.Padding(
  //               padding: const pw.EdgeInsets.all(15),
  //               child: pw.Column(
  //                 children: [
  //                   pw.Row(
  //                     children: [
  //                       pw.Container(
  //                         width: 500,
  //                         child: pw.Column(
  //                           crossAxisAlignment: pw.CrossAxisAlignment.start,
  //                           children: [
  //                             pw.Text(
  //                                 'Conducted By :  ${meetingDetails['data']?['meetCreater'] ?? 'N/A'}',
  //                                 style: pw.TextStyle(
  //                                     fontWeight: pw.FontWeight.bold)),
  //                             pw.Text(
  //                                 'Department :  ${meetingDetails['data']?['department'] ?? 'N/A'}',
  //                                 style: pw.TextStyle(
  //                                     fontWeight: pw.FontWeight.bold)),
  //                             pw.Text(
  //                                 'Meeting Date :  ${meetingDetails['data']?['meetDateTime'] != null ? DateFormat('dd-MM-yyyy').format(DateTime.parse(meetingDetails['data']['meetDateTime'])) : 'N/A'}',
  //                                 style: pw.TextStyle(
  //                                     fontWeight: pw.FontWeight.bold)),
  //                             pw.Text(
  //                                 'Meeting Time :  ${meetingDetails['data']?['meetDateTime'] != null ? DateFormat('hh:mm a').format(DateTime.parse(meetingDetails['data']['meetDateTime'])) : 'N/A'}',
  //                                 style: pw.TextStyle(
  //                                     fontWeight: pw.FontWeight.bold)),
  //                             pw.Text(
  //                                 'Topic :  ${meetingDetails['data']?['meetTitle'] ?? 'N/A'}',
  //                                 style: pw.TextStyle(
  //                                     fontWeight: pw.FontWeight.bold)),
  //                             pw.SizedBox(height: 7),
  //                             pw.Text(
  //                                 'Summary :  ${('${meetingDetails['data']['description']}' == "") ? "N/A" : '${meetingDetails['data']['description']}'}',
  //                                 style: pw.TextStyle(
  //                                     fontWeight: pw.FontWeight.bold)),
  //                           ],
  //                         ),
  //                       ),
  //                       // pw.Container(
  //                       //   width: 310,
  //                       //   child: pw.Column(
  //                       //     crossAxisAlignment: pw.CrossAxisAlignment.start,
  //                       //     children: [
  //                       //       pw.Text(
  //                       //           '${meetingDetails['data']?['meetCreater'] ?? 'N/A'}'),
  //                       //       pw.SizedBox(height: 1),
  //                       //       pw.Text(
  //                       //           '${meetingDetails['data']?['department'] ?? 'N/A'}'),
  //                       //       pw.SizedBox(height: 1),
  //                       //       pw.Text(meetingDetails['data']?['meetDateTime'] !=
  //                       //               null
  //                       //           ? DateFormat('dd-MM-yyyy').format(
  //                       //               DateTime.parse(meetingDetails['data']
  //                       //                   ['meetDateTime']))
  //                       //           : 'N/A'),
  //                       //       pw.SizedBox(height: 1),
  //                       //       pw.Text(meetingDetails['data']?['meetDateTime'] !=
  //                       //               null
  //                       //           ? DateFormat('hh:mm a').format(DateTime.parse(
  //                       //               meetingDetails['data']['meetDateTime']))
  //                       //           : 'N/A'),
  //                       //       pw.SizedBox(height: 1),
  //                       //       pw.Text(
  //                       //           '${meetingDetails['data']?['meetTitle'] ?? 'N/A'}'),
  //                       //       pw.SizedBox(height: 5),
  //                       //       pw.Text(
  //                       //           ('${meetingDetails['data']['description']}' ==
  //                       //                   "")
  //                       //               ? "N/A"
  //                       //               : '${meetingDetails['data']['description']}',
  //                       //           softWrap: true),
  //                       //     ],
  //                       //   ),
  //                       // ),
  //                     ],
  //                   ),

  //                   // pw.Row(
  //                   //   children: [
  //                   //     pw.Container(
  //                   //       width: 120,
  //                   //       child: pw.Column(
  //                   //         crossAxisAlignment: pw.CrossAxisAlignment.start,
  //                   //         children: [
  //                   //           pw.Text('Conducted By', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
  //                   //           pw.Text('Department', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
  //                   //           pw.Text('Meeting Date', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
  //                   //           pw.Text('Meeting Time', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
  //                   //           pw.Text('Topic', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
  //                   //           pw.Text('Summary', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
  //                   //         ],
  //                   //       ),
  //                   //     ),
  //                   //     pw.Container(
  //                   //       child: pw.Column(
  //                   //         crossAxisAlignment: pw.CrossAxisAlignment.start,
  //                   //         children: [
  //                   //           pw.Text('${meetingDetails?['data']?['meetCreater'] ?? 'N/A'}'),
  //                   //           pw.SizedBox(height: 1),
  //                   //           pw.Text('${meetingDetails?['data']?['department'] ?? 'N/A'}'),
  //                   //           pw.SizedBox(height: 1),
  //                   //           pw.Text('${meetingDetails?['data']?['meetDateTime'] != null ? DateFormat('dd-MM-yyyy').format(DateTime.parse(meetingDetails?['data']['meetDateTime'])) : 'N/A'}'),
  //                   //           pw.SizedBox(height: 1),
  //                   //           pw.Text('${meetingDetails?['data']?['meetDateTime'] != null ? DateFormat('hh:mm a').format(DateTime.parse(meetingDetails?['data']['meetDateTime'])) : 'N/A'}'),
  //                   //           pw.SizedBox(height: 1),
  //                   //           pw.Text(' ${meetingDetails?['data']?['meetTitle'] ?? 'N/A'}'),
  //                   //           pw.SizedBox(height: 1),
  //                   //           pw.Text(' ${meetingDetails?['data']?['description'] ?? 'N/A'}'),
  //                   //         ],
  //                   //       ),
  //                   //     ),
  //                   //   ],
  //                   // ),
  //                 ],
  //               ),
  //             ),
  //           ),
  //           pw.SizedBox(height: 20),
  //           pw.Table(
  //             border: pw.TableBorder.all(),
  //             columnWidths: {
  //               0: const pw.FlexColumnWidth(1.5),
  //               1: const pw.FlexColumnWidth(2),
  //               2: const pw.FlexColumnWidth(2),
  //               3: const pw.FlexColumnWidth(3),
  //             },
  //             children: [
  //               header,
  //               ...rowsChunk,
  //             ],
  //           ),
  //         ] else ...[
  //           pw.Table(
  //             border: pw.TableBorder.all(),
  //             columnWidths: {
  //               0: const pw.FlexColumnWidth(1.5),
  //               1: const pw.FlexColumnWidth(2),
  //               2: const pw.FlexColumnWidth(2),
  //               3: const pw.FlexColumnWidth(3),
  //             },
  //             children: rowsChunk,
  //           ),
  //         ],
  //       ],
  //     );
  //     pdf.addPage(pw.Page(build: (pw.Context context) => pdfContent));
  //   }
  //   return pdf;
  // }

  // for meeting
  // static Future<pw.Document> generateMeetingDetailsPdf(Map<String, dynamic> meetingDetails, dynamic logoImage) async {
  //
  //   final ByteData image = await rootBundle.load('assets/images/logo.png');
  //   Uint8List logoImage = image.buffer.asUint8List();
  //   int counter = 1;
  //
  //   String _formatDateTime(String? dateTimeString) {
  //     if (dateTimeString == null || dateTimeString.isEmpty) {
  //       return 'N/A';
  //     }
  //     final dateTime = DateTime.parse(dateTimeString);
  //     final formattedDate = DateFormat.yMd().add_jm().format(dateTime);
  //     return formattedDate;
  //   }
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
  //
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
  //       pw.Center(child: pw.Text('Toolbox Meeting',style: pw.TextStyle(fontWeight: pw.FontWeight.bold,fontSize: 20))),
  //       pw.SizedBox(height: 15),
  //       pw.Container(
  //         height: 150,
  //         width: double.infinity,
  //         decoration: pw.BoxDecoration(
  //           border: pw.Border.all(),
  //           borderRadius: pw.BorderRadius.all(pw.Radius.circular(5)),
  //         ),
  //         child: pw.Padding(
  //           padding: pw.EdgeInsets.all(15), // Add padding here
  //           child: pw.Row(
  //             children: [
  //               pw.Image(
  //                 pw.MemoryImage(logoImage),
  //                 width: 70.0, // Adjust the width as needed
  //                 height: 70.0, // Adjust the height as needed
  //               ),
  //               pw.SizedBox(width: 20), // Add space between image and text
  //               pw.Container(
  //                 height: 150,
  //                 width: double.infinity,
  //                 decoration: pw.BoxDecoration(
  //                   border: pw.Border.all(),
  //                   borderRadius: pw.BorderRadius.all(pw.Radius.circular(5)),
  //                 ),
  //                 child: pw.Padding(
  //                   padding: pw.EdgeInsets.all(15),
  //                   child: pw.Column(
  //                     children: [
  //                       pw.Row(
  //
  //                         children: [
  //                           pw.Container(
  //                             width: 120,
  //
  //                             child: pw.Column(
  //                               crossAxisAlignment: pw.CrossAxisAlignment.start,
  //                               children: [
  //                                 pw.Text('Conducted By', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
  //                                 pw.Text('Department', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
  //                                 pw.Text('Meeting Date', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
  //                                 pw.Text('Meeting Time', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
  //                                 pw.Text('Topic', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
  //                                 pw.Text('Summary', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
  //                               ],
  //                             ),
  //                           ),
  //                           pw.Container(
  //                             child: pw.Column(
  //                               crossAxisAlignment: pw.CrossAxisAlignment.start,
  //                               children: [
  //                                 pw.Text('${meetingDetails?['data']?['meetCreater'] ?? 'N/A'}'),
  //                                 pw.SizedBox(height: 1),
  //                                 pw.Text('${meetingDetails?['data']?['department'] ?? 'N/A'}'),
  //                                 pw.SizedBox(height: 1),
  //                                 pw.Text('${meetingDetails?['data']?['meetDateTime'] != null ? DateFormat('dd-MM-yyyy').format(DateTime.parse(meetingDetails?['data']['meetDateTime'])) : 'N/A'}',
  //                                 ),
  //                                 pw.SizedBox(height: 1),
  //                                 pw.Text(
  //                                   '${meetingDetails?['data']?['meetDateTime'] != null ? DateFormat('hh:mm a').format(DateTime.parse(meetingDetails?['data']['meetDateTime'])) : 'N/A'}',
  //                                 ),
  //                                 pw.SizedBox(height: 1),
  //                                 pw.Text(' ${meetingDetails?['data']?['meetTitle'] ?? 'N/A'}'),
  //                                 pw.SizedBox(height: 1),
  //                                 pw.Text(' ${meetingDetails?['data']?['description'] ?? 'N/A'}'),
  //                               ],
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //
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














// static pdf.Row generateFormHistoryHeader() {
//     return pdf.Row(
//       mainAxisAlignment: pdf.MainAxisAlignment.spaceBetween,
//       crossAxisAlignment: pdf.CrossAxisAlignment.center,
//       children:  [
//         pdf.Text('Form History', style: pdf.TextStyle(fontSize: 20.0)),
//       ],
//     );
//   }

//   static Future<Uint8List> generateFormHistoryPDF(List<Map<String, dynamic>> formData) async {
//     final pdf.Document doc = pdf.Document();

//     List<List<dynamic>> data = [
//       [
//         'FormId',
//         'FormTitle',
//         'Person1',
//         'Person2',
//         'MainResult',
//         'FilterTitle',
//         'Username',
//         'UserId',
//         'DateAndTime',
//         'Description',
//         'Status',
//         'FormResult',
//       ],
//     ];

//     for (var form in formData) {
//       data.add([
//         form['formId'].toString(),
//         form['formTitle'].toString(),
//         form['person1'].toString(),
//         form['person2'].toString(),
//         form['mainResult'].toString(),
//         form['filterTitle'].toString(),
//         form['username'].toString(),
//         form['userId'].toString(),
//         form['dateAndTime'].toString(),
//         form['description'].toString(),
//         form['status'].toString(),
//         form['formResult'].toString(),
//       ]);
//     }

//     List<pdf.TableRow> tableRows = [];

//     for (var rowData in data) {
//       List<pdf.Widget> row = [];

//       for (var cellData in rowData) {
//         row.add(
//           pdf.Paragraph(
//             margin: const pdf.EdgeInsets.all(5.0),
//             text: cellData.toString(),
//           ),
//         );
//       }

//       tableRows.add(pdf.TableRow(children: row));
//     }

//     doc.addPage(
//       pdf.MultiPage(
//         pageFormat: PdfPageFormat.a4,
//         build: (pdf.Context context) {
//           return [
//             generateFormHistoryHeader(),
//             pdf.SizedBox(height: 20),
//             pdf.Table(
//               border: pdf.TableBorder.all(width: 1),
//               children: tableRows,
//             ),
//           ];
//         },
//       ),
//     );

//     return await doc.save();
//   }