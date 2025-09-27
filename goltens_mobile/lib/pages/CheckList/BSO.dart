import 'dart:convert';
import 'dart:typed_data';

import 'package:digital_signature_flutter/digital_signature_flutter.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:goltens_core/constants/constants.dart';
import 'package:goltens_core/models/auth.dart';
import 'package:goltens_core/models/feedback.dart';
import 'package:goltens_core/theme/theme.dart';
import 'package:goltens_core/utils/functions.dart';
import 'package:goltens_mobile/provider/global_state.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'ChecklistSignature.dart';

class BSO extends StatefulWidget {
  const BSO({Key? key});

  @override
  State<BSO> createState() => _BSOState();
}

const apiUrl = 'https://goltens.in/api/v1/forms/createForm';

class _BSOState extends State<BSO> {
  UserResponse? user;
  SignatureController? controller;
  Uint8List? signature;

  @override
  void initState() {
    final state = context.read<GlobalState>();
    controller = SignatureController();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        setState(() => user = state.user);
        observer1Controller.text =
            "${user!.data.name} ${user!.data.employeeNumber}";
      }
    });
    super.initState();
    dateController.text = formatDateTime(selectedDate, 'd/MM/y');
    timeController.text = formatDateTime(selectedDate, 'hh:mm aa');
  }

  FeedbackData? feedback;
  String? selectedLocation;
  DateTime selectedDate = DateTime.now().toUtc();
  TextEditingController description1Controller = TextEditingController();
  TextEditingController description2Controller = TextEditingController();
  TextEditingController description3Controller = TextEditingController();
  final TextEditingController areaController = TextEditingController();
  final TextEditingController observer1Controller = TextEditingController();
  final TextEditingController employeeController = TextEditingController();
  final TextEditingController taskController = TextEditingController();
  final TextEditingController observer2Controller = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  TextEditingController timeController = TextEditingController();
  final departmentController = SingleValueDropDownController();

  String PPE1 = "P";
  String PPE2 = "P";
  String PPE3 = "P";
  String PPE4 = "P";
  String body1 = "P";
  String body2 = "P";
  String body3 = "P";
  String body4 = "P";
  String body5 = "P";
  String body6 = "P";
  String body7 = "P";
  String body8 = "P";
  String chemical1 = "P";
  String chemical2 = "P";
  String chemical3 = "P";
  String chemical4 = "P";
  String procedure1 = "P";
  String procedure2 = "P";
  String procedure3 = "P";
  String procedure4 = "P";
  String house1 = "P";
  String house2 = "P";
  String house3 = "P";
  String house4 = "P";
  String house5 = "P";
  String tools1 = "P";
  String tools2 = "P";
  String tools3 = "P";
  String tools4 = "P";
  String tools5 = "P";
  String tools6 = "P";
  String tools7 = "P";

  bool isDescription1Filled = false;
  bool isDescription2Filled = false;
  bool isDescription3Filled = false;

  bool areAllConditionsMet() {
    return PPE1 != "P" &&
        PPE2 != "P" &&
        PPE3 != "P" &&
        PPE4 != "P" &&
        body1 != "P" &&
        body2 != "P" &&
        body3 != "P" &&
        body4 != "P" &&
        body5 != "P" &&
        body6 != "P" &&
        body7 != "P" &&
        body8 != "P" &&
        chemical1 != "P" &&
        chemical2 != "P" &&
        chemical3 != "P" &&
        chemical4 != "P" &&
        procedure1 != "P" &&
        procedure2 != "P" &&
        procedure3 != "P" &&
        procedure4 != "P" &&
        house1 != "P" &&
        house2 != "P" &&
        house3 != "P" &&
        house4 != "P" &&
        house5 != "P" &&
        tools1 != "P" &&
        tools2 != "P" &&
        tools3 != "P" &&
        tools4 != "P" &&
        tools5 != "P" &&
        tools6 != "P" &&
        tools7 != "P" &&
        areaController.text.isNotEmpty &&
        observer1Controller.text.isNotEmpty &&
        controller!.points.isNotEmpty &&
        departmentController.dropDownValue!.value != null;
  }

  @override
  void dispose() {
    description1Controller.dispose();
    description2Controller.dispose();
    description3Controller.dispose();

    super.dispose();
  }

  Future<void> sendSurveyResponses() async {
    final accountabiltyData = {
      "formTitle": "Behaviour Safety Observation",
      "formResult": "",
      "person1": observer1Controller.text,
      "person2": observer2Controller.text,
      "username": user!.data.name,
      "userId": "${user!.data.id}",
      "mainResult": "",
      "filterTitle": "Behaviour Safety Observation",
      "dateAndTime": DateTime.now().toString(),
      "description": "",
      "status": "Active",
      "header1": "${areaController.text}",
      "header2": departmentController.dropDownValue!.value,
      "header3": taskController.text,
      "header4": dateController.text,
      "header5": timeController.text,
      "checklistImage": '',
      "inspectorSign": base64Encode(signature!),
      'questions': [
        {
          "content": "PPE worn",
          "answer": "",
          "content1": "Content 1",
          "content2": "Content 2",
          "content3": "Content 3",
          "answerList": [
            {"answer": PPE1, "qusContent": ""},
          ]
        },
        {
          "content": "PPE meets job requirements",
          "answer": "",
          "content1": "Content 1",
          "content2": "Content 2",
          "content3": "Content 3",
          "answerList": [
            {"answer": PPE2, "qusContent": ""},
          ]
        },
        {
          "content": "Worn correctly",
          "answer": "",
          "content1": "Content 1",
          "content2": "Content 2",
          "content3": "Content 3",
          "answerList": [
            {"answer": PPE3, "qusContent": ""},
          ]
        },
        {
          "content": "Acceptable condition",
          "answer": "",
          "content1": "Content 1",
          "content2": "Content 2",
          "content3": "Content 3",
          "answerList": [
            {"answer": PPE4, "qusContent": ""},
          ]
        },
        {
          "content": "Exertion: Pushing / pulling / lifting / reaching",
          "answer": "",
          "content1": "Content 1",
          "content2": "Content 2",
          "content3": "Content 3",
          "answerList": [
            {"answer": body1, "qusContent": ""},
          ]
        },
        {
          "content": "Proper lifting carrying mechanism",
          "answer": "",
          "content1": "Content 1",
          "content2": "Content 2",
          "content3": "Content 3",
          "answerList": [
            {"answer": body2, "qusContent": ""},
          ]
        },
        {
          "content": "Clear of 'line of fire'",
          "answer": "",
          "content1": "Content 1",
          "content2": "Content 2",
          "content3": "Content 3",
          "answerList": [
            {"answer": body3, "qusContent": ""},
          ]
        },
        {
          "content": "Eyes on path",
          "answer": "",
          "content1": "Content 1",
          "content2": "Content 2",
          "content3": "Content 3",
          "answerList": [
            {"answer": body4, "qusContent": ""},
          ]
        },
        {
          "content": "Eyes on work",
          "answer": "",
          "content1": "Content 1",
          "content2": "Content 2",
          "content3": "Content 3",
          "answerList": [
            {"answer": body5, "qusContent": ""},
          ]
        },
        {
          "content": "Clear of pinch points",
          "answer": "",
          "content1": "Content 1",
          "content2": "Content 2",
          "content3": "Content 3",
          "answerList": [
            {"answer": body6, "qusContent": ""},
          ]
        },
        {
          "content": "Clear of sharp edges",
          "answer": "",
          "content1": "Content 1",
          "content2": "Content 2",
          "content3": "Content 3",
          "answerList": [
            {"answer": body7, "qusContent": ""},
          ]
        },
        {
          "content": "Clear of hot surfaces",
          "answer": "",
          "content1": "Content 1",
          "content2": "Content 2",
          "content3": "Content 3",
          "answerList": [
            {"answer": body8, "qusContent": ""},
          ]
        },
        {
          "content": "SDS available",
          "answer": "",
          "content1": "Content 1",
          "content2": "Content 2",
          "content3": "Content 3",
          "answerList": [
            {"answer": chemical1, "qusContent": ""},
          ]
        },
        {
          "content": "Chemicals are stored appropriately",
          "answer": "",
          "content1": "Content 1",
          "content2": "Content 2",
          "content3": "Content 3",
          "answerList": [
            {"answer": chemical2, "qusContent": ""},
          ]
        },
        {
          "content": "Contaminated rugs are disposed correctly",
          "answer": "",
          "content1": "Content 1",
          "content2": "Content 2",
          "content3": "Content 3",
          "answerList": [
            {"answer": chemical3, "qusContent": ""},
          ]
        },
        {
          "content": "Established and understood",
          "answer": "",
          "content1": "Content 1",
          "content2": "Content 2",
          "content3": "Content 3",
          "answerList": [
            {"answer": procedure1, "qusContent": ""},
          ]
        },
        {
          "content": "Employee authorized to operate",
          "answer": "",
          "content1": "Content 1",
          "content2": "Content 2",
          "content3": "Content 3",
          "answerList": [
            {"answer": procedure2, "qusContent": ""},
          ]
        },
        {
          "content": "Maintained and followed",
          "answer": "",
          "content1": "Content 1",
          "content2": "Content 2",
          "content3": "Content 3",
          "answerList": [
            {"answer": procedure3, "qusContent": ""},
          ]
        },
        {
          "content": "Adequate for task",
          "answer": "",
          "content1": "Content 1",
          "content2": "Content 2",
          "content3": "Content 3",
          "answerList": [
            {"answer": procedure4, "qusContent": ""},
          ]
        },
        {
          "content": "Area is clear of obstructions",
          "answer": "",
          "content1": "Content 1",
          "content2": "Content 2",
          "content3": "Content 3",
          "answerList": [
            {"answer": house1, "qusContent": ""},
          ]
        },
        {
          "content": "Area is used for its intended purpose",
          "answer": "",
          "content1": "Content 1",
          "content2": "Content 2",
          "content3": "Content 3",
          "answerList": [
            {"answer": house2, "qusContent": ""},
          ]
        },
        {
          "content": "Materials are stored in a safe manner",
          "answer": "",
          "content1": "Content 1",
          "content2": "Content 2",
          "content3": "Content 3",
          "answerList": [
            {"answer": house3, "qusContent": ""},
          ]
        },
        {
          "content": "Uncover / Unbent nails",
          "answer": "",
          "content1": "Content 1",
          "content2": "Content 2",
          "content3": "Content 3",
          "answerList": [
            {"answer": house4, "qusContent": ""},
          ]
        },
        {
          "content": "Necessary signs / posters",
          "answer": "",
          "content1": "Content 1",
          "content2": "Content 2",
          "content3": "Content 3",
          "answerList": [
            {"answer": house5, "qusContent": ""},
          ]
        },
        {
          "content": "Selection of tools",
          "answer": "",
          "content1": "Content 1",
          "content2": "Content 2",
          "content3": "Content 3",
          "answerList": [
            {"answer": tools1, "qusContent": ""},
          ]
        },
        {
          "content": "Proper use of tools/equipment",
          "answer": "",
          "content1": "Content 1",
          "content2": "Content 2",
          "content3": "Content 3",
          "answerList": [
            {"answer": tools2, "qusContent": ""},
          ]
        },
        {
          "content": "Condition of tools/equipment",
          "answer": "",
          "content1": "Content 1",
          "content2": "Content 2",
          "content3": "Content 3",
          "answerList": [
            {"answer": tools3, "qusContent": ""},
          ]
        },
        {
          "content": "Guards in place",
          "answer": "",
          "content1": "Content 1",
          "content2": "Content 2",
          "content3": "Content 3",
          "answerList": [
            {"answer": tools4, "qusContent": " "},
          ]
        },
        {
          "content": "Safety latch in LG working well",
          "answer": "",
          "content1": "Content 1",
          "content2": "Content 2",
          "content3": "Content 3",
          "answerList": [
            {"answer": tools5, "qusContent": ""},
          ]
        },
        {
          "content": "Equipment within calibration due dates",
          "answer": "",
          "content1": "Content 1",
          "content2": "Content 2",
          "content3": "Content 3",
          "answerList": [
            {"answer": tools6, "qusContent": ""},
          ]
        },
        {
          "content": "Tools placed in position after use",
          "answer": "",
          "content1": "Content 1",
          "content2": "Content 2",
          "content3": "Content 3",
          "answerList": [
            {"answer": tools7, "qusContent": ""},
          ]
        },
        {
          "content": "At Risk Behaviour / Improvement Required",
          "answer": "",
          "content1": "Content 1",
          "content2": "Content 2",
          "content3": "Content 3",
          "answerList": [
            {"answer": description1Controller.text, "qusContent": ""},
          ]
        },
        {
          "content":
              "Suggestions from employee to improve the At-risk behaviour",
          "answer": "",
          "content1": "Content 1",
          "content2": "Content 2",
          "content3": "Content 3",
          "answerList": [
            {"answer": description2Controller.text, "qusContent": ""},
          ]
        },
        {
          "content": "Observers Feedback given to Employee",
          "answer": "",
          "content1": "Content 1",
          "content2": "Content 2",
          "content3": "Content 3",
          "answerList": [
            {"answer": description3Controller.text, "qusContent": ""},
          ]
        },
      ],
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: json.encode(accountabiltyData),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 201) {
        print('Survey responses successfully sent to the API');
        print('API Response: ${response.body}');
        Navigator.pop(context);
      } else {
        Navigator.pop(context);
        print(
            'Failed to send survey responses. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending survey responses: $e');
    }
  }

  List<String> locations = [
    '2nd Level Office',
    '2nd Level Non Service Warehouse',
    '2nd Level In-situ Shop',
    'ISD Shop',
    'Chrome Shop',
    'Machine Shop',
    'Welding Shop',
    'SCM Store & Logistic Office',
    'In-situ & Workshop Storage Room',
    'Engine Storage Room',
    'SCM & GT & GWW Office',
    'Reception Area',
    'GT Production Office',
    'Car Park & Open Yard'
  ];

  Future<Uint8List?> exportSignature() async {
    final exportController = SignatureController(
      penStrokeWidth: 2,
      exportBackgroundColor: Colors.white,
      penColor: Colors.black,
      points: controller!.points,
    );

    final signature = exportController.toPngBytes();

    exportController.dispose();

    return signature;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Text('Behaviour Safety Observation',
                  style: TextStyle(color: Colors.black))),
          backgroundColor: primaryColor,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: areaController,
                      //readOnly: true,
                      onTap: () {
                        // Show the dropdown options using PopupMenuButton
                        // showLocationMenu();
                      },
                      decoration: InputDecoration(
                        labelText: 'Area',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.arrow_drop_down),
                    onPressed: () {
                      // Show the dropdown options using PopupMenuButton
                      showLocationMenu();
                    },
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: DropDownTextField(
                  listTextStyle: const TextStyle(fontSize: 14),
                  clearOption: false,
                  controller: departmentController,
                  validator: (value) {
                    if (value != null && value.isEmpty) {
                      return 'Please select your department';
                    }
                    return null;
                  },
                  textFieldDecoration: InputDecoration(
                    labelText: 'Department',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                  dropDownItemCount: departmentList.length,
                  dropDownList: departmentList.map((department) {
                    return DropDownValueModel(
                        name: department, value: department);
                  }).toList(),
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: observer1Controller,
                decoration: InputDecoration(
                  labelText: 'Observer 1',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: observer2Controller,
                decoration: InputDecoration(
                  labelText: 'Observer 2',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              // TextField(
              //   controller: employeeController,
              //   decoration: InputDecoration(labelText: 'Assessed By',
              //     border: OutlineInputBorder(
              //       borderRadius: BorderRadius.circular(20.0),
              //     ),
              //   ),
              // ),
              // SizedBox(height: 16.0),
              TextField(
                controller: taskController,
                decoration: InputDecoration(
                  labelText: 'Task',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: dateController,
                      enabled: false,
                      decoration: InputDecoration(
                        labelText: 'Date',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: TextFormField(
                      controller: timeController,
                      enabled: false,
                      decoration: InputDecoration(
                        labelText: 'Time',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              const Divider(
                thickness: 2,
              ),
              SizedBox(height: 16.0),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text("S - Safe",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text("AR - At Risk",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              const Divider(
                thickness: 2,
              ),
              const Text("PPE",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(
                height: 20,
              ),
              Column(
                children: [
                  const Text('PPE worn'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Radio(
                        value: "Yes",
                        groupValue: PPE1,
                        onChanged: (value) {
                          setState(() {
                            PPE1 = value!;
                          });
                        },
                      ),
                      const Text("S"),
                      Radio(
                        value: "No",
                        groupValue: PPE1,
                        onChanged: (value) {
                          setState(() {
                            PPE1 = value!;
                          });
                        },
                      ),
                      const Text("AR"),
                    ],
                  ),
                  const Text('PPE meets job requirements'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Radio(
                        value: "Yes",
                        groupValue: PPE2,
                        onChanged: (value) {
                          setState(() {
                            PPE2 = value!;
                          });
                        },
                      ),
                      const Text("S"),
                      Radio(
                        value: "No",
                        groupValue: PPE2,
                        onChanged: (value) {
                          setState(() {
                            PPE2 = value!;
                          });
                        },
                      ),
                      const Text("AR"),
                    ],
                  ),
                  const Text('Worn correctly'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Radio(
                        value: "Yes",
                        groupValue: PPE3,
                        onChanged: (value) {
                          setState(() {
                            PPE3 = value!;
                          });
                        },
                      ),
                      const Text("S"),
                      Radio(
                        value: "No",
                        groupValue: PPE3,
                        onChanged: (value) {
                          setState(() {
                            PPE3 = value!;
                          });
                        },
                      ),
                      const Text("AR"),
                    ],
                  ),
                  const Text('Acceptable condition'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Radio(
                        value: "Yes",
                        groupValue: PPE4,
                        onChanged: (value) {
                          setState(() {
                            PPE4 = value!;
                          });
                        },
                      ),
                      const Text("S"),
                      Radio(
                        value: "No",
                        groupValue: PPE4,
                        onChanged: (value) {
                          setState(() {
                            PPE4 = value!;
                          });
                        },
                      ),
                      const Text("AR"),
                    ],
                  ),
                ],
              ),
              const Divider(
                thickness: 2,
              ),
              const SizedBox(
                height: 20,
              ),
              Text(
                "Body Position and Ergonomics".toUpperCase(),
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 20,
              ),
              Column(
                children: [
                  const Text('Exertion: Pushing /pulling /lifting/reaching'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Radio(
                        value: "Yes",
                        groupValue: body1,
                        onChanged: (value) {
                          setState(() {
                            body1 = value!;
                          });
                        },
                      ),
                      const Text("S"),
                      Radio(
                        value: "No",
                        groupValue: body1,
                        onChanged: (value) {
                          setState(() {
                            body1 = value!;
                          });
                        },
                      ),
                      const Text("AR"),
                    ],
                  ),
                  const Text('Proper lifting carrying mechanism'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Radio(
                        value: "Yes",
                        groupValue: body2,
                        onChanged: (value) {
                          setState(() {
                            body2 = value!;
                          });
                        },
                      ),
                      const Text("S"),
                      Radio(
                        value: "No",
                        groupValue: body2,
                        onChanged: (value) {
                          setState(() {
                            body2 = value!;
                          });
                        },
                      ),
                      const Text("AR"),
                    ],
                  ),
                  const Text('Clear of "line of fire"'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Radio(
                        value: "Yes",
                        groupValue: body3,
                        onChanged: (value) {
                          setState(() {
                            body3 = value!;
                          });
                        },
                      ),
                      const Text("S"),
                      Radio(
                        value: "No",
                        groupValue: body3,
                        onChanged: (value) {
                          setState(() {
                            body3 = value!;
                          });
                        },
                      ),
                      const Text("AR"),
                    ],
                  ),
                  const Text('Eyes on path'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Radio(
                        value: "Yes",
                        groupValue: body4,
                        onChanged: (value) {
                          setState(() {
                            body4 = value!;
                          });
                        },
                      ),
                      const Text("S"),
                      Radio(
                        value: "No",
                        groupValue: body4,
                        onChanged: (value) {
                          setState(() {
                            body4 = value!;
                          });
                        },
                      ),
                      const Text("AR"),
                    ],
                  ),
                  const Text('Eyes on work'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Radio(
                        value: "Yes",
                        groupValue: body5,
                        onChanged: (value) {
                          setState(() {
                            body5 = value!;
                          });
                        },
                      ),
                      const Text("S"),
                      Radio(
                        value: "No",
                        groupValue: body5,
                        onChanged: (value) {
                          setState(() {
                            body5 = value!;
                          });
                        },
                      ),
                      const Text("AR"),
                    ],
                  ),
                  const Text('Clear of pinch points'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Radio(
                        value: "Yes",
                        groupValue: body6,
                        onChanged: (value) {
                          setState(() {
                            body6 = value!;
                          });
                        },
                      ),
                      const Text("S"),
                      Radio(
                        value: "No",
                        groupValue: body6,
                        onChanged: (value) {
                          setState(() {
                            body6 = value!;
                          });
                        },
                      ),
                      const Text("AR"),
                    ],
                  ),
                  const Text('Clear of sharp edges'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Radio(
                        value: "Yes",
                        groupValue: body7,
                        onChanged: (value) {
                          setState(() {
                            body7 = value!;
                          });
                        },
                      ),
                      const Text("S"),
                      Radio(
                        value: "No",
                        groupValue: body7,
                        onChanged: (value) {
                          setState(() {
                            body7 = value!;
                          });
                        },
                      ),
                      const Text("AR"),
                    ],
                  ),
                  const Text('clear of hot surfaces'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Radio(
                        value: "Yes",
                        groupValue: body8,
                        onChanged: (value) {
                          setState(() {
                            body8 = value!;
                          });
                        },
                      ),
                      const Text("S"),
                      Radio(
                        value: "No",
                        groupValue: body8,
                        onChanged: (value) {
                          setState(() {
                            body8 = value!;
                          });
                        },
                      ),
                      const Text("AR"),
                    ],
                  ),
                ],
              ),
              const Divider(
                thickness: 2,
              ),
              const SizedBox(
                height: 20,
              ),
              Text(
                "CHEMICALS".toUpperCase(),
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 20,
              ),
              Column(
                children: [
                  const Text('SDS available'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Radio(
                        value: "Yes",
                        groupValue: chemical1,
                        onChanged: (value) {
                          setState(() {
                            chemical1 = value!;
                          });
                        },
                      ),
                      const Text("S"),
                      Radio(
                        value: "No",
                        groupValue: chemical1,
                        onChanged: (value) {
                          setState(() {
                            chemical1 = value!;
                          });
                        },
                      ),
                      const Text("AR"),
                    ],
                  ),
                  const Text('Chemicals are stored appropriately'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Radio(
                        value: "Yes",
                        groupValue: chemical2,
                        onChanged: (value) {
                          setState(() {
                            chemical2 = value!;
                          });
                        },
                      ),
                      const Text("S"),
                      Radio(
                        value: "No",
                        groupValue: chemical2,
                        onChanged: (value) {
                          setState(() {
                            chemical2 = value!;
                          });
                        },
                      ),
                      const Text("AR"),
                    ],
                  ),
                  const Text('Contaminated rugs are disposed correctly'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Radio(
                        value: "Yes",
                        groupValue: chemical3,
                        onChanged: (value) {
                          setState(() {
                            chemical3 = value!;
                          });
                        },
                      ),
                      const Text("S"),
                      Radio(
                        value: "No",
                        groupValue: chemical3,
                        onChanged: (value) {
                          setState(() {
                            chemical3 = value!;
                          });
                        },
                      ),
                      const Text("AR"),
                    ],
                  ),
                  const Text('Chemicals are stored appropriately'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Radio(
                        value: "Yes",
                        groupValue: chemical4,
                        onChanged: (value) {
                          setState(() {
                            chemical4 = value!;
                          });
                        },
                      ),
                      const Text("S"),
                      Radio(
                        value: "No",
                        groupValue: chemical4,
                        onChanged: (value) {
                          setState(() {
                            chemical4 = value!;
                          });
                        },
                      ),
                      const Text("AR"),
                    ],
                  ),
                ],
              ),
              const Divider(
                thickness: 2,
              ),
              const SizedBox(
                height: 20,
              ),
              Text(
                "PROCEDURE".toUpperCase(),
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 20,
              ),
              Column(
                children: [
                  const Text('Established and understood'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Radio(
                        value: "Yes",
                        groupValue: procedure1,
                        onChanged: (value) {
                          setState(() {
                            procedure1 = value!;
                          });
                        },
                      ),
                      const Text("S"),
                      Radio(
                        value: "No",
                        groupValue: procedure1,
                        onChanged: (value) {
                          setState(() {
                            procedure1 = value!;
                          });
                        },
                      ),
                      const Text("AR"),
                    ],
                  ),
                  const Text('Employee authorized to operate'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Radio(
                        value: "Yes",
                        groupValue: procedure2,
                        onChanged: (value) {
                          setState(() {
                            procedure2 = value!;
                          });
                        },
                      ),
                      const Text("S"),
                      Radio(
                        value: "No",
                        groupValue: procedure2,
                        onChanged: (value) {
                          setState(() {
                            procedure2 = value!;
                          });
                        },
                      ),
                      const Text("AR"),
                    ],
                  ),
                  const Text('Maintained and followed'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Radio(
                        value: "Yes",
                        groupValue: procedure3,
                        onChanged: (value) {
                          setState(() {
                            procedure3 = value!;
                          });
                        },
                      ),
                      const Text("S"),
                      Radio(
                        value: "No",
                        groupValue: procedure3,
                        onChanged: (value) {
                          setState(() {
                            procedure3 = value!;
                          });
                        },
                      ),
                      const Text("AR"),
                    ],
                  ),
                  const Text('Adequate for task'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Radio(
                        value: "Yes",
                        groupValue: procedure4,
                        onChanged: (value) {
                          setState(() {
                            procedure4 = value!;
                          });
                        },
                      ),
                      const Text("S"),
                      Radio(
                        value: "No",
                        groupValue: procedure4,
                        onChanged: (value) {
                          setState(() {
                            procedure4 = value!;
                          });
                        },
                      ),
                      const Text("AR"),
                    ],
                  ),
                ],
              ),
              const Divider(
                thickness: 2,
              ),
              const SizedBox(
                height: 20,
              ),
              Text(
                "HOUSEKEEPING".toUpperCase(),
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 20,
              ),
              Column(
                children: [
                  const Text('Area is clear of obstructions'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Radio(
                        value: "Yes",
                        groupValue: house1,
                        onChanged: (value) {
                          setState(() {
                            house1 = value!;
                          });
                        },
                      ),
                      const Text("S"),
                      Radio(
                        value: "No",
                        groupValue: house1,
                        onChanged: (value) {
                          setState(() {
                            house1 = value!;
                          });
                        },
                      ),
                      const Text("AR"),
                    ],
                  ),
                  const Text('Area is used for its intended purpose'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Radio(
                        value: "Yes",
                        groupValue: house2,
                        onChanged: (value) {
                          setState(() {
                            house2 = value!;
                          });
                        },
                      ),
                      const Text("S"),
                      Radio(
                        value: "No",
                        groupValue: house2,
                        onChanged: (value) {
                          setState(() {
                            house2 = value!;
                          });
                        },
                      ),
                      const Text("AR"),
                    ],
                  ),
                  const Text('Materials is stored in safe Manner'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Radio(
                        value: "Yes",
                        groupValue: house3,
                        onChanged: (value) {
                          setState(() {
                            house3 = value!;
                          });
                        },
                      ),
                      const Text("S"),
                      Radio(
                        value: "No",
                        groupValue: house3,
                        onChanged: (value) {
                          setState(() {
                            house3 = value!;
                          });
                        },
                      ),
                      const Text("AR"),
                    ],
                  ),
                  const Text('Uncover / Unbent nails'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Radio(
                        value: "Yes",
                        groupValue: house4,
                        onChanged: (value) {
                          setState(() {
                            house4 = value!;
                          });
                        },
                      ),
                      const Text("S"),
                      Radio(
                        value: "No",
                        groupValue: house4,
                        onChanged: (value) {
                          setState(() {
                            house4 = value!;
                          });
                        },
                      ),
                      const Text("AR"),
                    ],
                  ),
                  const Text('Necessary Signs / Posters'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Radio(
                        value: "Yes",
                        groupValue: house5,
                        onChanged: (value) {
                          setState(() {
                            house5 = value!;
                          });
                        },
                      ),
                      const Text("S"),
                      Radio(
                        value: "No",
                        groupValue: house5,
                        onChanged: (value) {
                          setState(() {
                            house5 = value!;
                          });
                        },
                      ),
                      const Text("AR"),
                    ],
                  ),
                ],
              ),
              const Divider(
                thickness: 2,
              ),
              const SizedBox(
                height: 20,
              ),
              Text(
                "Tools and Equipment".toUpperCase(),
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 20,
              ),
              Column(
                children: [
                  const Text('Selection of tools'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Radio(
                        value: "Yes",
                        groupValue: tools1,
                        onChanged: (value) {
                          setState(() {
                            tools1 = value!;
                          });
                        },
                      ),
                      const Text("S"),
                      Radio(
                        value: "No",
                        groupValue: tools1,
                        onChanged: (value) {
                          setState(() {
                            tools1 = value!;
                          });
                        },
                      ),
                      const Text("AR"),
                    ],
                  ),
                  const Text('Proper use of tools/equipment'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Radio(
                        value: "Yes",
                        groupValue: tools2,
                        onChanged: (value) {
                          setState(() {
                            tools2 = value!;
                          });
                        },
                      ),
                      const Text("S"),
                      Radio(
                        value: "No",
                        groupValue: tools2,
                        onChanged: (value) {
                          setState(() {
                            tools2 = value!;
                          });
                        },
                      ),
                      const Text("AR"),
                    ],
                  ),
                  const Text('Condition of tools/equipemnt'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Radio(
                        value: "Yes",
                        groupValue: tools3,
                        onChanged: (value) {
                          setState(() {
                            tools3 = value!;
                          });
                        },
                      ),
                      const Text("S"),
                      Radio(
                        value: "No",
                        groupValue: tools3,
                        onChanged: (value) {
                          setState(() {
                            tools3 = value!;
                          });
                        },
                      ),
                      const Text("AR"),
                    ],
                  ),
                  const Text('Guards in place'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Radio(
                        value: "Yes",
                        groupValue: tools4,
                        onChanged: (value) {
                          setState(() {
                            tools4 = value!;
                          });
                        },
                      ),
                      const Text("S"),
                      Radio(
                        value: "No",
                        groupValue: tools4,
                        onChanged: (value) {
                          setState(() {
                            tools4 = value!;
                          });
                        },
                      ),
                      const Text("AR"),
                    ],
                  ),
                  const Text('Safety latch in LG working well'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Radio(
                        value: "Yes",
                        groupValue: tools5,
                        onChanged: (value) {
                          setState(() {
                            tools5 = value!;
                          });
                        },
                      ),
                      const Text("S"),
                      Radio(
                        value: "No",
                        groupValue: tools5,
                        onChanged: (value) {
                          setState(() {
                            tools5 = value!;
                          });
                        },
                      ),
                      const Text("AR"),
                    ],
                  ),
                  const Text('Equipment within calibration due dates'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Radio(
                        value: "Yes",
                        groupValue: tools6,
                        onChanged: (value) {
                          setState(() {
                            tools6 = value!;
                          });
                        },
                      ),
                      const Text("S"),
                      Radio(
                        value: "No",
                        groupValue: tools6,
                        onChanged: (value) {
                          setState(() {
                            tools6 = value!;
                          });
                        },
                      ),
                      const Text("AR"),
                    ],
                  ),
                  const Text('Tools placed in position after use'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Radio(
                        value: "Yes",
                        groupValue: tools7,
                        onChanged: (value) {
                          setState(() {
                            tools7 = value!;
                          });
                        },
                      ),
                      const Text("S"),
                      Radio(
                        value: "No",
                        groupValue: tools7,
                        onChanged: (value) {
                          setState(() {
                            tools7 = value!;
                          });
                        },
                      ),
                      const Text("AR"),
                    ],
                  ),
                ],
              ),
              const Divider(
                thickness: 2,
              ),
              const SizedBox(
                height: 20,
              ),
              const Text("Positive Observations (List 2) :",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(
                height: 20,
              ),
              const Text("At Risk Behaviour / Improvement Required",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: TextField(
                  controller: description1Controller,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  maxLines: 3,
                  onChanged: (value) {
                    // Handle the description input
                    setState(() {
                      isDescription1Filled = value.isNotEmpty;
                    });
                  },
                ),
              ),
              const Divider(
                thickness: 2,
              ),
              const Text(
                  "Suggestions from employee to improve the At-risk behaviour",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: TextField(
                  controller: description2Controller,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  maxLines: 3,
                  onChanged: (value) {
                    // Handle the description input
                    setState(() {
                      isDescription2Filled = value.isNotEmpty;
                    });
                  },
                ),
              ),
              const Text("Observers Feedback given to Employee",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: TextField(
                  controller: description3Controller,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  maxLines: 3,
                  onChanged: (value) {
                    // Handle the description input
                    setState(() {
                      isDescription3Filled = value.isNotEmpty;
                    });
                  },
                ),
              ),
              const Divider(
                thickness: 2,
              ),
              Text('Please put the signature here',
                  style: TextStyle(fontSize: 20, color: Colors.black)),
              const SizedBox(height: 15),
              Stack(
                children: [
                  Center(
                    child: Signature(
                      height: 200,
                      width: 350,
                      controller: controller!,
                      backgroundColor: Colors.grey.shade100,
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 16,
                    child: IconButton(
                      icon: Icon(
                        Icons.cancel_outlined,
                        color: Colors.redAccent,
                      ), // Replace 'your_icon' with the desired icon
                      onPressed: () {
                        controller?.clear();
                        setState(() {
                          signature = null;
                        });
                      },
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      if (areAllConditionsMet()) {
                        signature = await exportSignature();
                        sendSurveyResponses();

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('submitted successfully'),
                            duration: Duration(
                                seconds: 2), // You can adjust the duration
                          ),
                        );
                        print("Submitted");
                      } else {
                        // Show a message that conditions are not met
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text("Error"),
                              content:
                                  const Text("Please answer all questions."),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text("OK"),
                                ),
                              ],
                            );
                          },
                        );
                      }
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                          primaryColor), // Set the color here
                    ),
                    child: const Text(
                      "Submit",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  // ElevatedButton(
                  //   onPressed: () {
                  //     showDialog(
                  //       context: context,
                  //       builder: (BuildContext context) {
                  //         return AlertDialog(
                  //           content: ChecklistSignature(),
                  //         );
                  //       },
                  //     );
                  //   },
                  //   style: ButtonStyle(
                  //     backgroundColor: MaterialStateProperty.all<Color>(primaryColor),
                  //   ),
                  //   child:Text('Signature', style: TextStyle(color: Colors.black)),)
                ],
              ),
            ]),
          ),
        ));
  }

  void showLocationMenu() {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(3, 1, 2, 1),
      items: locations.map((location) {
        return PopupMenuItem<String>(
          value: location,
          child: Text(location),
        );
      }).toList(),
    ).then((value) {
      if (value != null) {
        setState(() {
          selectedLocation = value;
          areaController.text = value;
        });
      }
    });
  }
}
