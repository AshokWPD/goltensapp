import 'dart:convert';
import 'dart:typed_data';

import 'package:digital_signature_flutter/digital_signature_flutter.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:goltens_core/constants/constants.dart';
import 'package:goltens_core/models/auth.dart';
import 'package:goltens_core/models/feedback.dart';
import 'package:goltens_core/models/forms.dart';
import 'package:goltens_core/services/meeting.dart';
import 'package:goltens_core/theme/theme.dart';
import 'package:goltens_core/utils/functions.dart';
import 'package:goltens_mobile/provider/global_state.dart';
import 'package:provider/provider.dart';
import 'ChecklistSignature.dart';
import 'LPS.dart';

class SafetyQuestion {
  final String text;
  final bool isHeading;
  String answer;

  SafetyQuestion(this.text, this.isHeading, this.answer);
}

class LMA extends StatefulWidget {
  const LMA({Key? key});

  @override
  State<LMA> createState() => _LMAState();
}

class _LMAState extends State<LMA> {
  UserResponse? user;
  SignatureController? controller;
  Uint8List? signature;
  String? selectedLocation;
  FeedbackData? feedback;

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
  final TextEditingController assessedController = TextEditingController();
  TextEditingController timeController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController teamController = TextEditingController();
  DateTime selectedDate = DateTime.now().toUtc();
  TextEditingController areaController = TextEditingController();
  final departmentController = SingleValueDropDownController();

  final ApiService apiService = ApiService();

  String lastGroupValue1 = "P";
  String lastGroupValue2 = "P";
  String cardGroupValue1 = "P";
  String cardGroupValue2 = "P";
  String accidentGroupValue1 = "P";
  String accidentGroupValue2 = "P";
  String accidentGroupValue3 = "P";
  String safetyGroupValue1 = "P";
  String safetyGroupValue2 = "P";
  String hopsGroupValue1 = "P";
  String hopsGroupValue2 = "P";
  String swGroupValue1 = "P";
  String communicationGroupValue1 = "P";


  List<SafetyQuestion> safetyQuestions = [
    SafetyQuestion('1. LAST SAFETY WALK ACTION PLAN', true, ''),
    SafetyQuestion(
        '1.1 Check if all actions were taken (if applicable)', false, ''),
    SafetyQuestion(
        '1.2 Check if the actions were effective to control the risks (if applicable)',
        false, ''),
    SafetyQuestion('2. SAFETY FEEDBACK - CPS', true, ''),
    SafetyQuestion(
        '2.1 Check all the feedbacks are addressed and closed with the agreed timeline', false, ''),
    SafetyQuestion(
        '2.2 Check if the improvements are being used accordingly', false, ''),
    SafetyQuestion(
        '3. Accidents / Incidents investigation and Analysis', true, ''),
    SafetyQuestion(
        '3.1 Check if the RCCAs of near misses or accidents are implemented and effective',
        false, ''),
    SafetyQuestion(
        '3.2 Check if there is any RCCA action pending',
        false, ''),
    SafetyQuestion(
        '3.3 Check if the timeline target of RCCA implementation was met',
        false, ''),
    SafetyQuestion('4. Safety Inspections', true, ''),
    SafetyQuestion('4.1 Check if all actions were taken', false, ''),
    SafetyQuestion('4.2 Check if there is any action still pending', false, ''),
    SafetyQuestion('5. Safety HOPs (Hazard Observation Process)', true, ''),
    SafetyQuestion(
        '5.1 Check if the Section Manager / Leadership meet the HOP target for the month',
        false, ''),
    SafetyQuestion(
        '5.2 Check if there were actions from Section Manager / Leadership to improve the area\'s "safety index"',
        false, ''),
    SafetyQuestion('6. SWP/RA', true, ''),
    SafetyQuestion(
        '6.1 Check if the Standard Work audit is done daily', false, ''),
    SafetyQuestion('7. Safety Communication', true, ''),
    SafetyQuestion(
        '7.1 Check if the Section Manager / Leadership has communicated recent Injury/Near Miss information',
        false, ''),
    // Add more questions or headings here
  ];
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
  void dispose() {
    controller!.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Text('Leadership and Management Accountability',
              style: TextStyle(color: Colors.black)),
        ),
        backgroundColor: primaryColor,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
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
                    return DropDownValueModel(name: department, value: department);
                  }).toList(),
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
              const Divider(thickness: 2,),
              Column(
                children: safetyQuestions.map((question) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (question.isHeading)
                        Padding(
                          padding: const EdgeInsets.only(top: 10, bottom: 10),
                          child: Text(
                            question.text,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      else
                        Text(
                          question.text,
                        ),
                      if (!question.isHeading)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Radio(
                              value: "Yes",
                              groupValue: question.answer,
                              onChanged: (value) {
                                setState(() {
                                  question.answer = value!;
                                });
                              },
                            ),
                            const Text("Yes"),
                            Radio(
                              value: "No",
                              groupValue: question.answer,
                              onChanged: (value) {
                                setState(() {
                                  question.answer = value!;
                                });
                              },
                            ),
                            const Text("No"),
                          ],
                        ),
                    ],
                  );
                }).toList(),
              ),
              const Divider(thickness: 2,),
              const SizedBox(height: 20,),
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
              const SizedBox(height: 20,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      if (areAllConditionsMet()) {
                        // Build the list of question objects
                        List<Question> formQuestions = List.generate(
                          safetyQuestions.length,
                              (index) => Question(
                            content: safetyQuestions[index].text,
                            answer: safetyQuestions[index].answer,
                            content1: "",
                            content2: "",
                            content3: "",
                            answerList: [
                              AnswerListItem(
                                answer: safetyQuestions[index].answer,
                                qusContent: "",
                              ),
                              AnswerListItem(
                                answer: safetyQuestions[index].answer == "Yes"
                                    ? "No"
                                    : "Yes",
                                qusContent: "",
                              ),
                              // Add more answer options as needed
                            ],
                          ),
                        );

                        // Calculate other values if needed
                        double totalPositiveResponses = safetyQuestions
                            .where((question) => question.answer == "Yes")
                            .length
                            .toDouble();
                        double totalResponses = safetyQuestions.length
                            .toDouble();
                        double conformancePercentage =
                            (totalPositiveResponses / totalResponses) * 100;
                        signature = await exportSignature();

                        // Create FormData object
                        FormData formData = FormData(
                          formTitle: "Leadership and Management Accountability",
                          person1: assessedController.text,
                          person2: "",
                          mainResult: "",
                          filterTitle: "Leadership and Management Accountability",
                          username: user!.data.name,
                          userId: "${user!.data.id}",
                          dateAndTime: DateTime.now().toString(),
                          description: "",
                          status: "Active",
                          formResult: "$conformancePercentage%",
                          questions: formQuestions,
                          header1: "${areaController.text}",
                          header2: departmentController.dropDownValue!.value,
                          header3: '',
                          header4: dateController.text,
                          header5: timeController.text,
                          checklistImage: '',
                          inspectorSign: base64Encode(signature!),
                        );

                        apiService.postData(formData);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('submitted successfully'),
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
                                  child: const Text("OK",
                                      style: TextStyle(color: Colors.black)),
                                ),
                              ],
                            );
                          },
                        );
                      }
                    },
                    style: ButtonStyle(
                      backgroundColor:
                      MaterialStateProperty.all<Color>(primaryColor),
                    ),
                    child: const Text(
                        "Submit", style: TextStyle(color: Colors.black)),
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

  bool areAllConditionsMet() {
    return areaController.text.isNotEmpty &&
        departmentController.dropDownValue?.value != null &&
        dateController.text.isNotEmpty &&
        timeController.text.isNotEmpty &&
        controller!.points.isNotEmpty&&
        safetyQuestions.every((question) {
          // Only check non-heading questions
          if (!question.isHeading) {
            // Ensure the answer is either "Yes" or "No"
            return question.answer == "Yes" || question.answer == "No";
          }
          return true; // Heading questions are always considered as met
        });
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
