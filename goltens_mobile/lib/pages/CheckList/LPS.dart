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
import 'BSO.dart';
import 'ChecklistSignature.dart';

class LPS extends StatefulWidget {
  const LPS({Key? key});

  @override
  State<LPS> createState() => _LPSState();
}

class _LPSState extends State<LPS> {
  UserResponse? user;
  SignatureController? controller;
  Uint8List? signature;
  String? selectedLocation;
  FeedbackData? feedback;

  @override
  void initState() {
    final state = context.read<GlobalState>();
    controller = SignatureController();

    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      if (mounted) {
        setState(() => user = state.user);
        assessedController.text = "${user!.data.name} ${user!.data.employeeNumber}";
      }
    });
    super.initState();
    dateController.text = formatDateTime(selectedDate, 'd/MM/y');
    timeController.text = formatDateTime(selectedDate, 'hh:mm aa');
  }

  final ApiService apiService = ApiService();

  List<String> questions = [
    "Do you feel you are working in a safe workplace?",
    "Are you aware of hazards in your work? Are there any protective measures present? Give examples:",
    "Does your section manager stop any unsafe work? Give examples:",
    "When you report hazards to your section manager, does he/she reply back to you and give solutions? Give example:",
    "Do you feel and see the supervisors and managers showing their commitment to safety? Give examples:"
  ];

  List<String> questionAnswers = ["P", "P", "P", "P", "P"];
  List<bool> isDescriptionFilled = [false, false, false, false, false];
  List<String> descriptions = ["", "", "", "", ""];

  bool areAllConditionsMet() {
    bool areDescriptionsFilled = isDescriptionFilled.every((filled) => filled);

    return questionAnswers.every((answer) => answer != "P") &&
        areDescriptionsFilled &&
        controller!.points.isNotEmpty; // Check if signature is provided
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


  final TextEditingController assessedController = TextEditingController();
  TextEditingController timeController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController teamController = TextEditingController();
  DateTime selectedDate = DateTime.now().toUtc();
  TextEditingController areaController = TextEditingController();
  final departmentController = SingleValueDropDownController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Text(
            'Leadership Perception Survey',
            style: TextStyle(color: Colors.black),
          ),
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
              for (int i = 0; i < questions.length; i++) ...[
                Column(
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      "${i + 1}. ${questions[i]}",
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Radio(
                          value: "Yes",
                          groupValue: questionAnswers[i],
                          onChanged: (value) {
                            setState(() {
                              questionAnswers[i] = value!;
                            });
                          },
                        ),
                        const Text("Yes"),
                        Radio(
                          value: "No",
                          groupValue: questionAnswers[i],
                          onChanged: (value) {
                            setState(() {
                              questionAnswers[i] = value!;
                            });
                          },
                        ),
                        const Text("No"),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        maxLines: 3,
                        onChanged: (value) {
                          setState(() {
                            isDescriptionFilled[i] = value.isNotEmpty;
                            descriptions[i] = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const Divider(
                  thickness: 2,
                ),
              ],
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
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      if (areAllConditionsMet()) {
                        List<Question> formQuestions = List.generate(
                          questions.length,
                              (index) => Question(
                            content: questions[index],
                            answer: questionAnswers[index],
                            content1: "",
                            content2: "",
                            content3: "",
                            answerList: [
                              AnswerListItem(
                                answer: questionAnswers[index],
                                qusContent: descriptions[index],
                              ),
                              AnswerListItem(
                                answer: questionAnswers[index] == "Yes" ? "No" : "Yes",
                                qusContent: "",
                              ),
                            ],
                          ),
                        );

                        double totalPositiveResponses = questionAnswers.where((answer) => answer == "Yes").length.toDouble();
                        double totalResponses = questionAnswers.length.toDouble();
                        double conformancePercentage = (totalPositiveResponses / totalResponses) * 100;
                        signature = await exportSignature();
                        FormData formData = FormData(
                          formTitle: "Leadership Perception Survey",
                          person1: assessedController.text,
                          person2: "",
                          mainResult: "",
                          filterTitle: "Leadership Perception Survey",
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



                        // Now you can use 'signature' as needed (e.g., send it to the server).
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
                              content: const Text("Please answer all questions and provide descriptions."),
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
                    child: const Text("Submit", style: TextStyle(color: Colors.black)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
