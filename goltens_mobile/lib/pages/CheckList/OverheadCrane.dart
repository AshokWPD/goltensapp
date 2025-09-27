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
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../meet/screens/common/AssignMeetNotification.dart';
import 'ChecklistSignature.dart';

class OverQuestion {
  final int index;
  final String text;

  OverQuestion(this.index, this.text);
}

class OverheadCrane extends StatefulWidget {
  const OverheadCrane({Key? key});

  @override
  State<OverheadCrane> createState() => _OverheadCraneState();
}

class _OverheadCraneState extends State<OverheadCrane> {
  UserResponse? user;
  SignatureController? controller;
  Uint8List? signature;
  Uint8List? selectedImage;
  String? selectedLocation;

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

  DateTime selectedDate = DateTime.now().toUtc();
  TextEditingController description1Controller = TextEditingController();
  TextEditingController description2Controller = TextEditingController();
  TextEditingController description3Controller = TextEditingController();
  final TextEditingController areaController = TextEditingController();
  final TextEditingController signedController = TextEditingController();
  final TextEditingController assessedController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  TextEditingController timeController = TextEditingController();
  final departmentController = SingleValueDropDownController();

  final ApiService apiService = ApiService();
  List<OverQuestion> questions = [
    OverQuestion(1, 'Is the wire rope free from kinking, crushing, corrosion, broken wires, and broken strands?'),
    OverQuestion(2, 'Is the wire rope laid in the grooves of the drum and in the rope sheaves?'),
    OverQuestion(3, 'Does the hook move freely in every allowed direction?'),
    OverQuestion(4, 'Is the safety latch working properly?'),
    OverQuestion(5, 'Do the rope sleeves rotate smoothly and freely?'),
    OverQuestion(6, 'Do the upper limit switches operate properly?'),
    OverQuestion(7, 'Does the lower limit switch operate properly?'),
    OverQuestion(8, 'Are the push button controller free from cracks or other signs of wear in the housing and for loose or broken buttons?'),
    OverQuestion(9, 'Do all push buttons and switches correspond to their intended functions and directions?'),
    OverQuestion(10, 'Does the emergency button operate properly?'),
  ];

  Map<int, String> answers = {};

  bool areAllConditionsMet() {
    return dateController.text.isNotEmpty &&
        timeController.text.isNotEmpty &&
        areaController.text.isNotEmpty &&
        departmentController.dropDownValue?.value != null &&
        selectedCrane != null &&
        assessedController.text.isNotEmpty &&
        controller!.points.isNotEmpty&&
        answers.values.every((answer) => answer != "P");
  }

  List<String> crane = [
    'LM41761L',
    'LM41762V',
    'LM41761L',
    'LM41762V',
    'LM41764N',
    'LM46655C',
    'LM60874K',
    'LM60875X',
    'LM60878V',
    'LM084246J',
    'LM289796N',
    'LM338054K',
    'LM338055P',
    'LM579335V',
    'LM579336C',
    'LM838652E',
  ];
  String? selectedCrane;


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

  void _pickImages() async {
    final ImagePicker picker = ImagePicker();

    XFile? pickedFiles = await picker.pickImage(source:ImageSource.gallery );
    if (pickedFiles!=null) {
      // Assuming you want to display the first picked image
      final Uint8List? bytes = await pickedFiles.readAsBytes();
      setState(() {
        selectedImage = bytes;
      });
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Text('Pre-use Weekly Inspection Checklist for Overhead Crane',
                style: TextStyle(color: Colors.black))),
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
                  DropdownButtonFormField<String>(
                    value: selectedCrane,
                    onChanged: (value) {
                      setState(() {
                        selectedCrane = value;
                      });
                    },
                    isExpanded: true,
                    itemHeight: 48.0,
                    items: crane.map((location) {
                      return DropdownMenuItem<String>(
                        value: location,
                        child: SizedBox(
                          width: double.infinity,
                          child: Center(
                            child: Text(
                              location,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                    decoration: InputDecoration(
                      labelText: 'Lifting Machine (LM #)',
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
                          Text(
                              '(1) This checklist shall be used on a weekly basis.'),
                          Text(
                              '(2) The completed checklist has to be kept properly for 3 years, readily for inspection or audit by authorized personnel'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Divider(
                    thickness: 2,
                  ),
                  Text(
                      "The existence of any one of the following key risk factors, that is, a No answer, indicates the need for corrective action.",
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
              const SizedBox(
                height: 20,
              ),
              Text("Inspection of the wire rope".toUpperCase(),
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(
                height: 20,
              ),
              Column(
                children: questions.map((question) {
                  return Column(
                    children: [
                      Text('${question.index}. ${question.text}'),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Radio(
                            value: "Yes",
                            groupValue: answers[question.index],
                            onChanged: (value) {
                              setState(() {
                                answers[question.index] = value!;
                              });
                            },
                          ),
                          const Text("Yes"),
                          Radio(
                            value: "No",
                            groupValue: answers[question.index],
                            onChanged: (value) {
                              setState(() {
                                answers[question.index] = value!;
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
            // ElevatedButton(
            //   onPressed: () {
            //     _pickImages();
            //   },
            //   style: ButtonStyle(
            //     backgroundColor: MaterialStateProperty.all<Color>(primaryColor),
            //   ),
            //   child: Text('Upload Image', style: TextStyle(color: Colors.black)),
            // ),
            //
            // // Display the selected image only if it is not null
            // if (selectedImage != null) Image.memory(selectedImage!),

              const SizedBox(
                height: 20,
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
              const SizedBox(
                height: 20,
              ),


              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      if (areAllConditionsMet()) {
                        // Build the list of question objects
                        List<Question> formQuestions = List.generate(
                          questions.length,
                              (index) => Question(
                            content: questions[index].text,
                            answer: answers[index + 1] ?? '', // Provide default value
                            content1: "",
                            content2: "",
                            content3: "",
                            answerList: [
                              AnswerListItem(
                                answer: answers[index + 1] ?? '', // Provide default value
                                qusContent: "",
                              ),
                              AnswerListItem(
                                answer: answers[index + 1] == "Yes" ? "No" : "Yes",
                                qusContent: "",
                              ),
                              // Add more answer options as needed
                            ],
                          ),
                        );

                        // Calculate other values if needed
                        double totalPositiveResponses = answers.values
                            .where((answer) => answer == 'Yes')
                            .length
                            .toDouble();
                        double totalResponses = questions.length.toDouble();
                        double conformancePercentage =
                            (totalPositiveResponses / totalResponses) * 100;
                        signature = await exportSignature();
                        // Create FormData object
                        FormData formData = FormData(
                          formTitle: "Pre-use Weekly Inspection Checklist for Overhead Crane",
                          person1: assessedController.text,
                          person2: "",
                          mainResult: "",
                          filterTitle: "Pre-use Weekly Inspection Checklist for Overhead Crane",
                          username: user!.data.name,
                          userId: "${user!.data.id}",
                          dateAndTime: DateTime.now().toString(),
                          description:  selectedCrane!,
                          status: "Active",
                          formResult: "$conformancePercentage%",
                          questions: formQuestions,
                          header1: "${areaController.text}",
                          header2: departmentController.dropDownValue!.value,
                          header3: '',
                          header4: dateController.text,
                          header5: timeController.text,
                          checklistImage: "",
                          inspectorSign: base64Encode(signature!) ?? '',
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
                ],
              ),
              const SizedBox(
                height: 20,
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
