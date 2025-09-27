import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:goltens_core/theme/theme.dart';
import 'package:goltens_core/utils/pdf_generator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../../../utils/functions.dart';

class MoreInfoPage extends StatefulWidget {
  final int formId;

  MoreInfoPage({Key? key, required this.formId}) : super(key: key);

  @override
  State<MoreInfoPage> createState() => _MoreInfoPageState();
}

class _MoreInfoPageState extends State<MoreInfoPage> {
  Map<String, dynamic> cardData = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final response = await http.get(Uri.parse(
          'https://goltens.in/api/v1/forms/Getform/${widget.formId}'));
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData.containsKey('data') &&
            responseData['data'] is Map<String, dynamic>) {
          final Map<String, dynamic> data = responseData['data'];

          setState(() {
            cardData = data;
            isLoading = false;
          });
        } else {
          throw Exception('Invalid data structure in the API response');
        }
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> refreshData() async {
    setState(() {
      isLoading = true;
    });
    await fetchData();
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'More Info',
            style: const TextStyle(color: Colors.black),
          ),
          backgroundColor: primaryColor,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: RefreshIndicator(
            onRefresh: refreshData,
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : cardData['filterTitle'] == 'Forklift Checklist'
                    ? FPOCContentWidget(cardData: cardData)
                    : DefaultContentWidget(cardData: cardData),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: primaryColor,
          onPressed: () async {
            try {
              if (cardData['filterTitle'] == 'Forklift Checklist') {
                // Generate FPOC PDF
                final pdf = await PDFGenerator.generateFPOCPdf(cardData);
                final directory = await getDownloadsDirectoryPath();
                final pdfPath =
                    '$directory/${DateTime.now().millisecondsSinceEpoch}_FPOC_report.pdf';
                final file = File(pdfPath);
                await file.writeAsBytes(await pdf.save());
              } else {
                // Generate Default PDF
                final pdf = await PDFGenerator.generatePdfFile(cardData);
                final directory = await getDownloadsDirectoryPath();
                final pdfPath =
                    '$directory/${DateTime.now().millisecondsSinceEpoch}_report.pdf';
                final file = File(pdfPath);
                await file.writeAsBytes(await pdf.save());
              }

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('PDF successfully generated and saved!'),
                  duration: Duration(seconds: 2),
                ),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error generating or saving PDF.'),
                  duration: Duration(seconds: 2),
                ),
              );
            }
          },
          tooltip: 'Open PDF',
          child: Icon(Icons.download, color: Colors.black),
        ));
  }
}

class DefaultContentWidget extends StatelessWidget {
  final Map<String, dynamic> cardData;

  DefaultContentWidget({required this.cardData});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              ' ${cardData['formTitle']}',
              style: const TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16.0),
          Card(
            elevation: 15.0,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFormField('Inspected By', cardData['username']),
                  _buildFormField('Area', cardData['header1']),
                  _buildFormField('Department', cardData['header2']),

                  // Conditional rendering for Observer based on 'filterTitle'
                  if (cardData['filterTitle'] !=
                          'Pre-use Weekly Inspection Checklist for Overhead Crane' &&
                      cardData['filterTitle'] !=
                          'Leadership and Management Accountability' &&
                      cardData['filterTitle'] !=
                          'Leadership Perception Survey' &&
                      cardData['filterTitle'] !=
                          'Safety Checklist Of Welding Equipment' &&
                      cardData['filterTitle'] !=
                          'Safety Checklist of Gas Equipment')
                    _buildFormField('Observer', cardData['person2']),

                  // Conditional rendering for Task based on 'filterTitle'
                  if (cardData['filterTitle'] !=
                          'Pre-use Weekly Inspection Checklist for Overhead Crane' &&
                      cardData['filterTitle'] !=
                          'Leadership and Management Accountability' &&
                      cardData['filterTitle'] != 'Leadership Perception Survey')
                    _buildFormField('Task', cardData['header3']),

                  // Conditional rendering for Lifting Machine based on 'filterTitle'
                  if (cardData['filterTitle'] ==
                      'Pre-use Weekly Inspection Checklist for Overhead Crane')
                    _buildFormField('Lifting Machine', cardData['description']),

                  Text(
                    'Date: ${DateFormat.yMd().format(DateTime.parse(cardData['dateAndTime']))}',
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Time: ${DateFormat.jm().format(DateTime.parse(cardData['dateAndTime']))}',
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8.0),
                  const Divider(
                    thickness: 8.0,
                  ),
                  const Center(
                    child: Text(
                      'Questions and Answers',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var question in cardData['questions'])
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ' ${question['content']}',
                              style: const TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              ' ${question['answerList'][0]['answer']}',
                              style: const TextStyle(
                                fontSize: 14.0,
                              ),
                            ),
                            Text(
                              ' ${question['answerList'][0]['qusContent']}',
                              style: const TextStyle(
                                fontSize: 14.0,
                              ),
                            ),
                            const Divider(
                              thickness: 1.0,
                            ),
                          ],
                        ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Signature',
                          style: const TextStyle(
                              fontSize: 18.0, fontWeight: FontWeight.bold)),
                      SizedBox(
                        height: 8,
                      ),
                      cardData['userSign'] != null
                          ? Image.network(
                              cardData['userSign']!,
                              height: 150,
                              width: 200,
                            )
                          : Text('No signature available'),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: $value',
          style: const TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8.0),
      ],
    );
  }
}

class FPOCContentWidget extends StatelessWidget {
  final Map<String, dynamic> cardData;

  FPOCContentWidget({required this.cardData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Forklift Driver: ${cardData['username']}',
                style: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Area: ${cardData['header1']}',
                style: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Department: ${cardData['header2']}',
                style: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Weeks: ${cardData['header3']}',
                style: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Machine No:: ${cardData['person2']}',
                style: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Date: ${DateFormat.yMd().format(DateTime.parse(cardData['dateAndTime']))}',
                style: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Time: ${DateFormat.jm().format(DateTime.parse(cardData['dateAndTime']))}',
                style: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Forklift Pre-Operational Checklist (Tonnage: ${cardData['description']})',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Card(
                elevation: 5,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Procedures:',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '1. First user of forklift shall check and ensure the following items are in proper order on a daily basis.\n'
                        '2. Any deficiency found in the checklist must be immediately brought to the attention of the SCM Supervisor\n'
                        '3. The truck shall not be used and the SCM Supervisor shall tag it “OUT OF SERVICE – DO NOT OPERATE” until repair is completed.',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FPOCFormInfo(
                cardData: cardData,
              ),
              const SizedBox(height: 16),
              const Card(
                elevation: 5,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Legends:',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.square, color: Colors.yellowAccent),
                          SizedBox(width: 8),
                          Text("Critical items in the checklist"),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 5,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Checked by:',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Signature',
                              style: const TextStyle(
                                  fontSize: 18.0, fontWeight: FontWeight.bold)),
                          SizedBox(
                            height: 8,
                          ),
                          cardData['userSign'] != null
                              ? Image.network(
                                  cardData['userSign']!,
                                  height: 150,
                                  width: 200,
                                )
                              : Text('No signature available'),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FPOCFormInfo extends StatelessWidget {
  final Map<String, dynamic>? cardData;

  const FPOCFormInfo({Key? key, required this.cardData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (cardData == null) {
      return const Text('No form data available');
    }
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(
                  label: Text('S/N',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('Item',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              // DataColumn(label: Text('What to check', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('Remarks',
                      style: TextStyle(fontWeight: FontWeight.bold))),
            ],
            rows: List.generate(
              cardData!['questions'].length,
              (index) => DataRow(
                cells: [
                  DataCell(Text('${index + 1}')),
                  DataCell(Text(cardData!['questions'][index]['content'])),
                  // DataCell(Text(cardData!['questions'][index]['content1'])),
                  DataCell(
                    Text(
                      cardData!['questions'][index]['answerList'].isNotEmpty
                          ? cardData!['questions'][index]['answerList'][0]
                                  ['qusContent']
                              .toString()
                          : 'N/A', // Display 'N/A' if 'answerList' is empty
                    ),
                  ),
                ],
                color:
                    MaterialStateColor.resolveWith((Set<MaterialState> states) {
                  return getColorForRowIndex(index) ?? Colors.transparent;
                }),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color? getColorForRowIndex(int index) {
    List<int> coloredRows = [3, 6, 8, 11];

    if (coloredRows.contains(index)) {
      return Colors.yellowAccent;
    }

    return null;
  }
}
