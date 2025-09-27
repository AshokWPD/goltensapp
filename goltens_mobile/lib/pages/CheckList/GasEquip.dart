import 'dart:convert';
import 'dart:typed_data';

import 'package:digital_signature_flutter/digital_signature_flutter.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:goltens_core/constants/constants.dart';
import 'package:goltens_core/models/auth.dart';
import 'package:goltens_core/models/forms.dart';
import 'package:goltens_core/services/meeting.dart';
import 'package:goltens_core/theme/theme.dart';
import 'package:goltens_core/utils/functions.dart';
import 'package:goltens_mobile/provider/global_state.dart';
import 'package:provider/provider.dart';
import 'ChecklistSignature.dart';
import 'LPS.dart';
import 'OverheadCrane.dart';

class GasEquip extends StatefulWidget {
  const GasEquip({Key? key});

  @override
  State<GasEquip> createState() => _GasEquipState();
}

class _GasEquipState extends State<GasEquip> {
  UserResponse? user;

  SignatureController? controller;
  Uint8List? signature;

  final TextEditingController taskController = TextEditingController();
  final TextEditingController areaController = TextEditingController();
  final TextEditingController signedController = TextEditingController();
  final TextEditingController assessedController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  TextEditingController timeController = TextEditingController();
  String? selectedLocation;
  final departmentController = SingleValueDropDownController();

  @override
  void initState() {
    final state = context.read<GlobalState>();
    controller = SignatureController();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        setState(() => user = state.user);
        assessedController.text = "${user!.data.name} ${user!.data.employeeNumber}";
      }
    });
    super.initState();
    dateController.text = formatDateTime(selectedDate, 'd/MM/y');
    timeController.text = formatDateTime(selectedDate, 'hh:mm aa');
  }
  DateTime selectedDate = DateTime.now().toUtc();
  final ApiService apiService = ApiService();

  List<Map<String, String>> gasQuestions = [
    {'question': 'Are the acetylene and LPG cylinders stored more than 1.5m away from electrical equipment?', 'answer': 'P'},
    {'question': 'Are the gas cylinders stored in assigned places away from the staircase?', 'answer': 'P'},
    {'question': 'Are empty gas cylinders marked “EMPTY” or “MT” to show that they are empty?', 'answer': 'P'},
    {'question': 'Are cylinders protected from damage by protection caps or other effective means?', 'answer': 'P'},
    {'question': 'Are gas cylinders stored in an upright and secured position?', 'answer': 'P'},
    {'question': 'Is a cylinder key provided on the valve stem while the cylinder is in service?', 'answer': 'P'},
    {'question': 'Are the cylinders kept far enough away from the actual welding or cutting operation so that sparks, hot slag, or flame will not reach them?', 'answer': 'P'},
    {'question': 'Are approved flashback arrestors installed at the ends of the regulators and behind the gas torch?', 'answer': 'P'},
    {'question': 'Is the hose clamping device without a jubilee clip?', 'answer': 'P'},
    {'question': 'Are gas hoses free from leaks, worn out, or other defects?', 'answer': 'P'},
  ];

  bool areAllConditionsMet() {
    return taskController.text.isNotEmpty &&
        areaController.text.isNotEmpty &&
        departmentController.dropDownValue?.value != null &&
        assessedController.text.isNotEmpty &&
        controller!.points.isNotEmpty&&
        gasQuestions.every((question) => question['answer'] != 'P');
  }
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
  void dispose() {
    controller!.dispose();
    super.dispose();
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Text('Safety Checklist Of Gas Equipment', style: TextStyle(color: Colors.black)),
        ),
        backgroundColor: primaryColor,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                            labelText: 'Description of Work Location',
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
                        return DropDownValueModel(name: department, value: department);
                      }).toList(),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  TextField(
                    controller: taskController,
                    decoration: InputDecoration(labelText: 'Task Description',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  TextField(
                    controller: assessedController,
                    decoration: InputDecoration(labelText: 'Assessed by',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  // TextField(
                  //   controller: signedController,
                  //   decoration: InputDecoration(labelText: 'Signed by',
                  //     border: OutlineInputBorder(
                  //       borderRadius: BorderRadius.circular(20.0),
                  //     ),
                  //   ),
                  // ),
                  // SizedBox(height: 16.0),
                  const Divider(thickness: 2,),
                  Card(
                    elevation: 4.0,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Application',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 16.0),
                          Text('(1) This checklist shall be used whenever there is a replacement of the gas cylinders'),
                          Text('(2) It is applicable for leak check once a week'),
                          Text('(3) The completed checklist has to be kept properly for at least 3 years, readily for inspection or audit by authorized personnel'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Divider(
                    thickness: 2,
                  ),
                  Text(
                    "The existence of any one of the following key risk factors, that is, a No answer, indicates the need for corrective action.",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  const Divider(
                    thickness: 2,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text("Safety Checklist for Gas Equipment".toUpperCase(), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Column(
                children: [
                  for (int i = 0; i < gasQuestions.length; i++)
                    Column(
                      children: [
                        Text((i + 1).toString() + '. ' + gasQuestions[i]['question']!),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Radio(
                              value: "Yes",
                              groupValue: gasQuestions[i]['answer'],
                              onChanged: (value) {
                                setState(() {
                                  gasQuestions[i]['answer'] = value!;
                                });
                              },
                            ),
                            const Text("Yes"),
                            Radio(
                              value: "No",
                              groupValue: gasQuestions[i]['answer'],
                              onChanged: (value) {
                                setState(() {
                                  gasQuestions[i]['answer'] = value!;
                                });
                              },
                            ),
                            const Text("No"),
                          ],
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(
                thickness: 2,
              ),
              const SizedBox(height: 20),
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
                      icon: Icon(Icons.cancel_outlined,color: Colors.redAccent,), // Replace 'your_icon' with the desired icon
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
                        // Build the list of question objects
                        List<Question> formQuestions = List.generate(
                          gasQuestions.length,
                              (index) => Question(
                            content: gasQuestions[index]['question'] ??'',
                            answer: gasQuestions[index]['answer'] ?? '', // Provide default value
                            content1: "",
                            content2: "",
                            content3: "",
                            answerList: [
                              AnswerListItem(
                                answer: gasQuestions[index]['answer'] ?? '',
                                qusContent: "",
                              ),
                              AnswerListItem(
                                answer: gasQuestions[index]['answer'] == "Yes" ? "No" : "Yes",
                                qusContent: "",
                              ),
                              // Add more answer options as needed
                            ],
                          ),
                        );

                        // Calculate other values if needed
                        double totalPositiveResponses = gasQuestions
                            .where((question) => question['answer'] == 'Yes')
                            .length
                            .toDouble();
                        double totalResponses = gasQuestions.length.toDouble();
                        double conformancePercentage =
                            (totalPositiveResponses / totalResponses) * 100;
                        signature = await exportSignature();

                        // Create FormData object
                        FormData formData = FormData(
                          formTitle: "Safety Checklist of Gas Equipment",
                          person1: assessedController.text ?? '',
                          person2: "",
                          mainResult: "",
                          filterTitle: "Safety Checklist of Gas Equipment",
                          username: user!.data.name ?? '',
                          userId: "${user!.data.id}" ?? '',
                          dateAndTime: DateTime.now().toString(),
                          description: "",
                          status: "Active",
                          formResult: "$conformancePercentage%",
                          questions: formQuestions,
                          header1: "${areaController.text}" ?? '',
                          header2: departmentController.dropDownValue!.value ?? '',
                          header3: taskController.text ?? '',
                          header4: dateController.text ?? '',
                          header5: timeController.text ?? '',
                          checklistImage: "",
                          inspectorSign: base64Encode(signature!),
                        );

                        apiService.postData(formData);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Submitted successfully'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                        print("Submitted");
                      } else {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text("Error"),
                              content: const Text(
                                  "Please answer all questions and provide descriptions."),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text("OK", style: TextStyle(color: Colors.black)),
                                ),
                              ],
                            );
                          },
                        );
                      }
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(primaryColor),
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
            ],
          ),
        ),
      ),
    );
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