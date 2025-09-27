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
import 'package:provider/provider.dart';
import 'ChecklistSignature.dart';
import 'LMA.dart';
import 'package:http/http.dart' as http;

class ConditionsForm extends StatefulWidget {
  const ConditionsForm({Key? key});

  @override
  State<ConditionsForm> createState() => _ConditionsFormState();
}

const apiUrl = 'https://goltens.in/api/v1/forms/createForm';

class conditionform {
  final double totalConformanceIndex;
  final double totalResponses;
  final double conformancePercentage;
  final double totalNegativeResponses;

  conditionform({
    required this.totalConformanceIndex,
    required this.totalResponses,
    required this.conformancePercentage,
    required this.totalNegativeResponses,
  });
}

class _ConditionsFormState extends State<ConditionsForm> {
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

  TextEditingController areaController = TextEditingController();
  TextEditingController timeController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController observer1Controller = TextEditingController();
  TextEditingController observer2Controller = TextEditingController();
  final departmentController = SingleValueDropDownController();
  final TextEditingController taskController = TextEditingController();

  DateTime selectedDate = DateTime.now().toUtc();
  String? selectedLocation;
  FeedbackData? feedback;

  String typedLocation = '';

  String layoutGroupValue1 = "P";
  String layoutGroupValue2 = "P";
  String layoutGroupValue3 = "P";
  String flourGroupValue1 = "P";
  String flourGroupValue2 = "P";
  String flourGroupValue3 = "P";
  String flourGroupValue4 = "P";
  String toolsGroupValue1 = "P";
  String toolsGroupValue2 = "P";
  String toolsGroupValue3 = "P";
  String devicesGroupValue1 = "P";
  String devicesGroupValue2 = "P";
  String devicesGroupValue3 = "P";
  String devicesGroupValue4 = "P";
  String devicesGroupValue5 = "P";
  String ladderGroupValue = "P";
  String sGroupValue1 = "P";
  String sGroupValue2 = "P";
  String chemicalGroupValue1 = "P";
  String chemicalGroupValue2 = "P";
  String chemicalGroupValue3 = "P";
  String chemicalGroupValue4 = "P";
  String liftGroupValue1 = "P";
  String liftGroupValue2 = "P";
  String liftGroupValue3 = "P";
  String liftGroupValue4 = "P";
  String liftGroupValue5 = "P";
  String emergencyGroupValue1 = "P";
  String emergencyGroupValue2 = "P";
  String emergencyGroupValue3 = "P";
  String emergencyGroupValue4 = "P";
  String machineGroupValue1 = "P";
  String machineGroupValue2 = "P";
  String machineGroupValue3 = "P";
  String machineGroupValue4 = "P";
  String environmentGroupValue1 = "P";
  String environmentGroupValue2 = "P";
  String environmentGroupValue3 = "P";

  bool areAllConditionsMet() {
    return layoutGroupValue1 != "P" &&
        layoutGroupValue2 != "P" &&
        layoutGroupValue3 != "P" &&
        flourGroupValue1 != "P" &&
        flourGroupValue2 != "P" &&
        flourGroupValue3 != "P" &&
        flourGroupValue4 != "P" &&
        toolsGroupValue1 != "P" &&
        toolsGroupValue2 != "P" &&
        toolsGroupValue3 != "P" &&
        devicesGroupValue1 != "P" &&
        devicesGroupValue2 != "P" &&
        devicesGroupValue3 != "P" &&
        devicesGroupValue4 != "P" &&
        devicesGroupValue5 != "P" &&
        ladderGroupValue != "P" &&
        sGroupValue1 != "P" &&
        sGroupValue2 != "P" &&
        chemicalGroupValue1 != "P" &&
        chemicalGroupValue2 != "P" &&
        chemicalGroupValue3 != "P" &&
        chemicalGroupValue4 != "P" &&
        liftGroupValue1 != "P" &&
        liftGroupValue2 != "P" &&
        liftGroupValue3 != "P" &&
        liftGroupValue4 != "P" &&
        liftGroupValue5 != "P" &&
        emergencyGroupValue1 != "P" &&
        emergencyGroupValue2 != "P" &&
        emergencyGroupValue3 != "P" &&
        emergencyGroupValue4 != "P" &&
        machineGroupValue1 != "P" &&
        machineGroupValue2 != "P" &&
        machineGroupValue3 != "P" &&
        machineGroupValue4 != "P" &&
        environmentGroupValue1 != "P" &&
        environmentGroupValue2 != "P" &&
        environmentGroupValue3 != "P" &&
        areaController.text.isNotEmpty &&
        timeController.text.isNotEmpty &&
        dateController.text.isNotEmpty &&
        observer1Controller.text.isNotEmpty &&
        taskController.text.isNotEmpty &&
        controller!.points.isNotEmpty &&
        departmentController.dropDownValue!.value != null;
  }

  Future<void> sendSurveyResponses() async {
    conditionform Conditionresponse = ConformanceCalculator();
    final conditionData = {
      "formTitle": "Employee Safety Walk",
      "filterTitle": "Employee Safety Walk",
      "person1": observer1Controller.text,
      "person2": observer2Controller.text,
      "mainResult": "",
      "formResult": "",
      "username": user!.data.name,
      "userId": "${user!.data.id}",
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
      "questions": [
        {
          "content":
              "Check if there is enough space to walk around the machines, tools, and equipment",
          "answer": "",
          "content1": "Content 1",
          "content2": "Content 2",
          "content3": "Content 3",
          "answerList": [
            {"answer": layoutGroupValue1, "qusContent": ""},
          ]
        },
        {
          "content": "Check if there is light enough to perform the operation",
          "answer": '',
          "content1": "Content 1",
          "content2": "Content 2",
          "content3": "Content 3",
          "answerList": [
            {"answer": layoutGroupValue2, "qusContent": ""},
          ]
        },
        {
          "content":
              "Check if all relevant documents are available (SW, Checklist, etc.)",
          "answer": "",
          "content1": "Content 1",
          "content2": "Content 2",
          "content3": "Content 3",
          "answerList": [
            {"answer": layoutGroupValue3, "qusContent": ""},
          ]
        },
        {
          "content": "Check if the floor is damaged or needs repair",
          "answer": "",
          "content1": "Content 1",
          "content2": "Content 2",
          "content3": "Content 3",
          "answerList": [
            {"answer": flourGroupValue1, "qusContent": ""},
          ]
        },
        {
          "content":
              "Check if the floor level differences are properly identified (trip hazards)",
          "answer": "",
          "content1": "Content 1",
          "content2": "Content 2",
          "content3": "Content 3",
          "answerList": [
            {"answer": flourGroupValue2, "qusContent": ""},
          ]
        },
        {
          "content":
              "Check if there are leaks/puddles on the floor (oil, water, grease, etc.)",
          "answer": "",
          "content1": "Content 1",
          "content2": "Content 2",
          "content3": "Content 3",
          "answerList": [
            {"answer": flourGroupValue3, "qusContent": ""},
          ]
        },
        {
          "content":
              "Check if there are pits or man lifts without proper protection (fall risks)",
          "answer": "",
          "content1": "Content 1",
          "content2": "Content 2",
          "content3": "Content 3",
          "answerList": [
            {"answer": flourGroupValue4, "qusContent": ""},
          ]
        },
        {
          "content":
              "Check if the tools are in good condition (not broken, cracked, excessive abrasion)",
          "answer": "",
          "content1": "Content 1",
          "content2": "Content 2",
          "content3": "Content 3",
          "answerList": [
            {"answer": toolsGroupValue1, "qusContent": ""},
          ]
        },
        {
          "content":
              "Check if hammers, drivers, or pins are in good condition with NO 'mushroom effect'",
          "answer": "",
          "content1": "Content 1",
          "content2": "Content 2",
          "content3": "Content 3",
          "answerList": [
            {"answer": toolsGroupValue2, "qusContent": ""},
          ]
        },
        {
          "content":
              "Check if the torque tools are in good condition and have reaction bars if required",
          "answer": "",
          "content1": "Content 1",
          "content2": "Content 2",
          "content3": "Content 3",
          "answerList": [
            {"answer": toolsGroupValue3, "qusContent": ""},
          ]
        },
        {
          "content":
              "Check if cranes and hoist inspection tags have been completed",
          "answer": "",
          "content1": "Content 1",
          "content2": "Content 2",
          "content3": "Content 3",
          "answerList": [
            {"answer": devicesGroupValue1, "qusContent": ""},
          ]
        },
        {
          "content":
              "Check if the cranes and hoist buttons are functioning properly",
          "answer": "",
          "content1": "Content 1",
          "content2": "Content 2",
          "content3": "Content 3",
          "answerList": [
            {"answer": devicesGroupValue2, "qusContent": ""},
          ]
        },
        {
          "content":
              "Check if the lifting straps are still good to be used (slots, tears, etc...)",
          "answer": "",
          "content1": "Content 1",
          "content2": "Content 2",
          "content3": "Content 3",
          "answerList": [
            {"answer": devicesGroupValue3, "qusContent": ""},
          ]
        },
        {
          "content":
              "Check if the magnets are clean and working, including the safe click",
          "answer": "",
          "content1": "Content 1",
          "content2": "Content 2",
          "content3": "Content 3",
          "answerList": [
            {"answer": devicesGroupValue4, "qusContent": ""},
          ]
        },
        {
          "content":
              "Check if the lifting devices have current inspection tags",
          "answer": "",
          "content1": "Content 1",
          "content2": "Content 2",
          "content3": "Content 3",
          "answerList": [
            {"answer": devicesGroupValue5, "qusContent": ""},
          ]
        },
        {
          "content":
              "Check if the ladders are in good condition (no corrosion, stability, etc...)",
          "answer": "",
          "content1": "Content 1",
          "content2": "Content 2",
          "content3": "Content 3",
          "answerList": [
            {"answer": ladderGroupValue, "qusContent": ""},
          ]
        },
        {
          "content": "Check if the area is clean and well organized.",
          "answer": "",
          "content1": "Content 1",
          "content2": "Content 2",
          "content3": "Content 3",
          "answerList": [
            {"answer": sGroupValue1, "qusContent": ""},
          ]
        },
        {
          "content":
              "Equipment and tools have the proper location defined and marked",
          "answer": "",
          "content1": "Content 1",
          "content2": "Content 2",
          "content3": "Content 3",
          "answerList": [
            {"answer": sGroupValue2, "qusContent": ""},
          ]
        },
        {
          "content":
              "Check if chemical products are properly packaged (packing, bottle)",
          "answer": "",
          "content1": "Content 1",
          "content2": "Content 2",
          "content3": "Content 3",
          "answerList": [
            {"answer": chemicalGroupValue1, "qusContent": ""},
          ]
        },
        {
          "content": "Check if chemical products are properly labeled",
          "answer": "",
          "content1": "Content 1",
          "content2": "Content 2",
          "content3": "Content 3",
          "answerList": [
            {"answer": chemicalGroupValue2, "qusContent": ""},
          ]
        },
        {
          "content":
              "Check if chemical products are properly stored (containment basin / area)",
          "answer": "",
          "content1": "Content 1",
          "content2": "Content 2",
          "content3": "Content 3",
          "answerList": [
            {"answer": chemicalGroupValue3, "qusContent": ""},
          ]
        },
        {
          "content":
              "Check if chemical products instruction sheet are close and easy to access.",
          "answer": "",
          "content1": "Content 1",
          "content2": "Content 2",
          "content3": "Content 3",
          "answerList": [
            {"answer": chemicalGroupValue4, "qusContent": ""},
          ]
        },
        {
          "content": "Check if the tires are good",
          "answer": "",
          "content1": "Content 1",
          "content2": "Content 2",
          "content3": "Content 3",
          "answerList": [
            {"answer": liftGroupValue1, "qusContent": ""},
          ]
        },
        {
          "content": "Check if there is not leaks",
          "answer": "",
          "content1": "Content 1",
          "content2": "Content 2",
          "content3": "Content 3",
          "answerList": [
            {"answer": liftGroupValue2, "qusContent": ""},
          ]
        },
        {
          "content":
              "Check if the safety items are working (seat belt, horn, light, etc.)",
          "answer": "",
          "content1": "Content 1",
          "content2": "Content 2",
          "content3": "Content 3",
          "answerList": [
            {"answer": liftGroupValue3, "qusContent": ""},
          ]
        },
        {
          "content":
              "Check if the check list is fulfilled before start the activities",
          "answer": "",
          "content1": "Content 1",
          "content2": "Content 2",
          "content3": "Content 3",
          "answerList": [
            {"answer": liftGroupValue4, "qusContent": ""},
          ]
        },
        {
          "content": "Check if the battery's lock is working safely",
          "answer": "",
          "content1": "Content 1",
          "content2": "Content 2",
          "content3": "Content 3",
          "answerList": [
            {"answer": liftGroupValue5, "qusContent": ""},
          ]
        },
        {
          "content": "Check if the fire extinguisher have current inspection",
          "answer": "",
          "content1": "Content 1",
          "content2": "Content 2",
          "content3": "Content 3",
          "answerList": [
            {"answer": emergencyGroupValue1, "qusContent": ""},
          ]
        },
        {
          "content":
              "Check if emergency or medical equipment identified (if applicable)",
          "answer": "",
          "content1": "Content 1",
          "content2": "Content 2",
          "content3": "Content 3",
          "answerList": [
            {"answer": emergencyGroupValue2, "qusContent": ""},
          ]
        },
        {
          "content": "Check if the area has emergency light / alarm",
          "answer": "",
          "content1": "Content 1",
          "content2": "Content 2",
          "content3": "Content 3",
          "answerList": [
            {"answer": emergencyGroupValue3, "qusContent": ""},
          ]
        },
        {
          "content": "Check if the eye wash is working (if applicable)",
          "answer": "",
          "content1": "Content 1",
          "content2": "Content 2",
          "content3": "Content 3",
          "answerList": [
            {"answer": emergencyGroupValue4, "qusContent": ""},
          ]
        },
        {
          "content": "Check if the machines have protection guards in place",
          "answer": "",
          "content1": "Content 1",
          "content2": "Content 2",
          "content3": "Content 3",
          "answerList": [
            {"answer": machineGroupValue1, "qusContent": ""},
          ]
        },
        {
          "content": "Check if the machines have redundant protection systems",
          "answer": "",
          "content1": "Content 1",
          "content2": "Content 2",
          "content3": "Content 3",
          "answerList": [
            {"answer": machineGroupValue2, "qusContent": ""},
          ]
        },
        {
          "content": "Check if the emergency items are in place and active",
          "answer": "",
          "content1": "Content 1",
          "content2": "Content 2",
          "content3": "Content 3",
          "answerList": [
            {"answer": machineGroupValue3, "qusContent": ""},
          ]
        },
        {
          "content": "Check if the ergonomic improvements are being used",
          "answer": "",
          "content1": "Content 1",
          "content2": "Content 2",
          "content3": "Content 3",
          "answerList": [
            {"answer": machineGroupValue4, "qusContent": ""},
          ]
        },
        {
          "content": "Check if the trash and waste collectors are identified",
          "answer": "",
          "content1": "Content 1",
          "content2": "Content 2",
          "content3": "Content 3",
          "answerList": [
            {"answer": environmentGroupValue1, "qusContent": ""},
          ]
        },
        {
          "content": "Check if the waste are segregated correctly",
          "answer": "",
          "content1": "Content 1",
          "content2": "Content 2",
          "content3": "Content 3",
          "answerList": [
            {"answer": environmentGroupValue2, "qusContent": ""},
          ]
        },
        {
          "content":
              "Check if the waste is place correctly (empty box unassembled, etc.)",
          "answer": "",
          "content1": "Content 1",
          "content2": "Content 2",
          "content3": "Content 3",
          "answerList": [
            {"answer": environmentGroupValue3, "qusContent": ""},
          ]
        },
      ]
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: json.encode(conditionData),
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

  conditionform ConformanceCalculator() {
    double totalConformanceIndex = (layoutGroupValue1 != "P" ? 1.0 : 0.0) +
        (layoutGroupValue2 != "P" ? 1.0 : 0.0) +
        (layoutGroupValue3 != "P" ? 1.0 : 0.0) +
        (flourGroupValue1 != "P" ? 1.0 : 0.0) +
        (flourGroupValue2 != "P" ? 1.0 : 0.0) +
        (flourGroupValue3 != "P" ? 1.0 : 0.0) +
        (flourGroupValue4 != "P" ? 1.0 : 0.0) +
        (toolsGroupValue1 != "P" ? 1.0 : 0.0) +
        (toolsGroupValue2 != "P" ? 1.0 : 0.0) +
        (toolsGroupValue3 != "P" ? 1.0 : 0.0) +
        (devicesGroupValue1 != "P" ? 1.0 : 0.0) +
        (devicesGroupValue2 != "P" ? 1.0 : 0.0) +
        (devicesGroupValue3 != "P" ? 1.0 : 0.0) +
        (devicesGroupValue4 != "P" ? 1.0 : 0.0) +
        (devicesGroupValue5 != "P" ? 1.0 : 0.0) +
        (ladderGroupValue != "P" ? 1.0 : 0.0) +
        (sGroupValue1 != "P" ? 1.0 : 0.0) +
        (sGroupValue2 != "P" ? 1.0 : 0.0) +
        (chemicalGroupValue1 != "P" ? 1.0 : 0.0) +
        (chemicalGroupValue2 != "P" ? 1.0 : 0.0) +
        (chemicalGroupValue3 != "P" ? 1.0 : 0.0) +
        (chemicalGroupValue4 != "P" ? 1.0 : 0.0) +
        (liftGroupValue1 != "P" ? 1.0 : 0.0) +
        (liftGroupValue2 != "P" ? 1.0 : 0.0) +
        (liftGroupValue3 != "P" ? 1.0 : 0.0) +
        (liftGroupValue4 != "P" ? 1.0 : 0.0) +
        (liftGroupValue5 != "P" ? 1.0 : 0.0) +
        (emergencyGroupValue1 != "P" ? 1.0 : 0.0) +
        (emergencyGroupValue2 != "P" ? 1.0 : 0.0) +
        (emergencyGroupValue3 != "P" ? 1.0 : 0.0) +
        (emergencyGroupValue4 != "P" ? 1.0 : 0.0) +
        (machineGroupValue1 != "P" ? 1.0 : 0.0) +
        (machineGroupValue2 != "P" ? 1.0 : 0.0) +
        (machineGroupValue3 != "P" ? 1.0 : 0.0) +
        (machineGroupValue4 != "P" ? 1.0 : 0.0) +
        (environmentGroupValue1 != "P" ? 1.0 : 0.0) +
        (environmentGroupValue2 != "P" ? 1.0 : 0.0) +
        (environmentGroupValue3 != "P" ? 1.0 : 0.0);

    double totalResponses = (layoutGroupValue1 != "P" ? 1 : 0) +
        (layoutGroupValue2 != "P" ? 1 : 0) +
        (layoutGroupValue3 != "P" ? 1 : 0) +
        (flourGroupValue1 != "P" ? 1 : 0) +
        (flourGroupValue2 != "P" ? 1 : 0) +
        (flourGroupValue3 != "P" ? 1 : 0) +
        (flourGroupValue4 != "P" ? 1 : 0) +
        (toolsGroupValue1 != "P" ? 1 : 0) +
        (toolsGroupValue2 != "P" ? 1 : 0) +
        (toolsGroupValue3 != "P" ? 1 : 0) +
        (devicesGroupValue1 != "P" ? 1 : 0) +
        (devicesGroupValue2 != "P" ? 1 : 0) +
        (devicesGroupValue3 != "P" ? 1 : 0) +
        (devicesGroupValue4 != "P" ? 1 : 0) +
        (devicesGroupValue5 != "P" ? 1 : 0) +
        (ladderGroupValue != "P" ? 1 : 0) +
        (sGroupValue1 != "P" ? 1 : 0) +
        (sGroupValue2 != "P" ? 1 : 0) +
        (chemicalGroupValue1 != "P" ? 1 : 0) +
        (chemicalGroupValue2 != "P" ? 1 : 0) +
        (chemicalGroupValue3 != "P" ? 1 : 0) +
        (chemicalGroupValue4 != "P" ? 1 : 0) +
        (liftGroupValue1 != "P" ? 1 : 0) +
        (liftGroupValue2 != "P" ? 1 : 0) +
        (liftGroupValue3 != "P" ? 1 : 0) +
        (liftGroupValue4 != "P" ? 1 : 0) +
        (liftGroupValue5 != "P" ? 1 : 0) +
        (emergencyGroupValue1 != "P" ? 1 : 0) +
        (emergencyGroupValue2 != "P" ? 1 : 0) +
        (emergencyGroupValue3 != "P" ? 1 : 0) +
        (emergencyGroupValue4 != "P" ? 1 : 0) +
        (machineGroupValue1 != "P" ? 1 : 0) +
        (machineGroupValue2 != "P" ? 1 : 0) +
        (machineGroupValue3 != "P" ? 1 : 0) +
        (machineGroupValue4 != "P" ? 1 : 0) +
        (environmentGroupValue1 != "P" ? 1 : 0) +
        (environmentGroupValue2 != "P" ? 1 : 0) +
        (environmentGroupValue3 != "P" ? 1 : 0);

    double conformancePercentage = (totalResponses != 0)
        ? ((totalConformanceIndex / totalResponses) * 100).clamp(0.0, 100.0)
        : 0.0;

    double totalNegativeResponses = totalResponses - totalConformanceIndex;

    print("Total Positive Responses: $totalConformanceIndex");
    print("Total Negative Responses: $totalNegativeResponses");
    print("Conformance Percentage: $conformancePercentage%");

    return conditionform(
      totalConformanceIndex: totalConformanceIndex,
      totalResponses: totalResponses,
      conformancePercentage: conformancePercentage,
      totalNegativeResponses: totalNegativeResponses,
    );
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
  void dispose() {
    controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Safety Walk Checklist',
            style: TextStyle(color: Colors.black)),
        backgroundColor: primaryColor,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch, // Added this line
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
                    return DropDownValueModel(
                        name: department, value: department);
                  }).toList(),
                ),
              ),

              // SizedBox(height: 16.0),
              // TextField(
              //   controller: teamController,
              //   decoration: InputDecoration(labelText: 'Team',
              //     border: OutlineInputBorder(
              //       borderRadius: BorderRadius.circular(20.0),
              //     ),
              //   ),
              // ),
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
              const Text("1. LAYOUT",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(
                height: 20,
              ),
              Column(
                children: [
                  const Text(
                      '1.1 Check if there is enough space to walk around the machines, tools, and equipment'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Radio(
                        value: "Yes",
                        groupValue: layoutGroupValue1,
                        onChanged: (value) {
                          setState(() {
                            layoutGroupValue1 = value!;
                          });
                        },
                      ),
                      const Text("Yes"),
                      Radio(
                        value: "No",
                        groupValue: layoutGroupValue1,
                        onChanged: (value) {
                          setState(() {
                            layoutGroupValue1 = value!;
                          });
                        },
                      ),
                      const Text("No"),
                    ],
                  ),
                  const Text(
                      '1.2 Check if there is light enough to perform the operation'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Radio(
                        value: "Yes",
                        groupValue: layoutGroupValue2,
                        onChanged: (value) {
                          setState(() {
                            layoutGroupValue2 = value!;
                          });
                        },
                      ),
                      const Text("Yes"),
                      Radio(
                        value: "No",
                        groupValue: layoutGroupValue2,
                        onChanged: (value) {
                          setState(() {
                            layoutGroupValue2 = value!;
                          });
                        },
                      ),
                      const Text("No"),
                    ],
                  ),
                  const Text(
                      '1.3 Check if all relevant documents are available (SWP,RA, etc.）'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Radio(
                        value: "Yes",
                        groupValue: layoutGroupValue3,
                        onChanged: (value) {
                          setState(() {
                            layoutGroupValue3 = value!;
                          });
                        },
                      ),
                      const Text("Yes"),
                      Radio(
                        value: "No",
                        groupValue: layoutGroupValue3,
                        onChanged: (value) {
                          setState(() {
                            layoutGroupValue3 = value!;
                          });
                        },
                      ),
                      const Text("No"),
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
              const Text(
                "2.FLOOR",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 20,
              ),
              Column(
                children: [
                  const Text(
                      '2.1 Check if the floor is damaged or needs repair'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Radio(
                        value: "Yes",
                        groupValue: flourGroupValue1,
                        onChanged: (value) {
                          setState(() {
                            flourGroupValue1 = value!;
                          });
                        },
                      ),
                      const Text("Yes"),
                      Radio(
                        value: "No",
                        groupValue: flourGroupValue1,
                        onChanged: (value) {
                          setState(() {
                            flourGroupValue1 = value!;
                          });
                        },
                      ),
                      const Text("No"),
                    ],
                  ),
                  const Text(
                      '2.2 Check if the floor level differences are properly identified (trip hazards）'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Radio(
                        value: "Yes",
                        groupValue: flourGroupValue2,
                        onChanged: (value) {
                          setState(() {
                            flourGroupValue2 = value!;
                          });
                        },
                      ),
                      const Text("Yes"),
                      Radio(
                        value: "No",
                        groupValue: flourGroupValue2,
                        onChanged: (value) {
                          setState(() {
                            flourGroupValue2 = value!;
                          });
                        },
                      ),
                      const Text("No"),
                    ],
                  ),
                  const Text(
                      '2.3 Check  if there are leaks/puddles on the floor (oil, water, grease, etc.))'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Radio(
                        value: "Yes",
                        groupValue: flourGroupValue3,
                        onChanged: (value) {
                          setState(() {
                            flourGroupValue3 = value!;
                          });
                        },
                      ),
                      const Text("Yes"),
                      Radio(
                        value: "No",
                        groupValue: flourGroupValue3,
                        onChanged: (value) {
                          setState(() {
                            flourGroupValue3 = value!;
                          });
                        },
                      ),
                      const Text("No"),
                    ],
                  ),
                  const Text(
                      '2.4 Check if there are pits or man lifts without proper protection (fall risks)'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Radio(
                        value: "Yes",
                        groupValue: flourGroupValue4,
                        onChanged: (value) {
                          setState(() {
                            flourGroupValue4 = value!;
                          });
                        },
                      ),
                      const Text("Yes"),
                      Radio(
                        value: "No",
                        groupValue: flourGroupValue4,
                        onChanged: (value) {
                          setState(() {
                            flourGroupValue4 = value!;
                          });
                        },
                      ),
                      const Text("No"),
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
              const Text(
                "3.TOOLS(Hand Tools)",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 20,
              ),
              Column(
                children: [
                  const Text(
                      '3.1 Check if the tools are in good condition (not  broken, cracked, excessive abrasion)'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Radio(
                        value: "Yes",
                        groupValue: toolsGroupValue1,
                        onChanged: (value) {
                          setState(() {
                            toolsGroupValue1 = value!;
                          });
                        },
                      ),
                      const Text("Yes"),
                      Radio(
                        value: "No",
                        groupValue: toolsGroupValue1,
                        onChanged: (value) {
                          setState(() {
                            toolsGroupValue1 = value!;
                          });
                        },
                      ),
                      const Text("No"),
                    ],
                  ),
                  const Text(
                      '3.2 Check if hammers, drivers, or pins are in good condition with NO  "mushroom effect"'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Radio(
                        value: "Yes",
                        groupValue: toolsGroupValue2,
                        onChanged: (value) {
                          setState(() {
                            toolsGroupValue2 = value!;
                          });
                        },
                      ),
                      const Text("Yes"),
                      Radio(
                        value: "No",
                        groupValue: toolsGroupValue2,
                        onChanged: (value) {
                          setState(() {
                            toolsGroupValue2 = value!;
                          });
                        },
                      ),
                      const Text("No"),
                    ],
                  ),
                  const Text(
                      '3.3 Check if the torque tools are in good condition and have reaction bars if required'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Radio(
                        value: "Yes",
                        groupValue: toolsGroupValue3,
                        onChanged: (value) {
                          setState(() {
                            toolsGroupValue3 = value!;
                          });
                        },
                      ),
                      const Text("Yes"),
                      Radio(
                        value: "No",
                        groupValue: toolsGroupValue3,
                        onChanged: (value) {
                          setState(() {
                            toolsGroupValue3 = value!;
                          });
                        },
                      ),
                      const Text("No"),
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
              const Text(
                "4.LIFTING DEVICES",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 20,
              ),
              Column(
                children: [
                  const Text(
                      '4.1 Check if cranes and hoist inspection tags have been completed'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Radio(
                        value: "Yes",
                        groupValue: devicesGroupValue1,
                        onChanged: (value) {
                          setState(() {
                            devicesGroupValue1 = value!;
                          });
                        },
                      ),
                      const Text("Yes"),
                      Radio(
                        value: "No",
                        groupValue: devicesGroupValue1,
                        onChanged: (value) {
                          setState(() {
                            devicesGroupValue1 = value!;
                          });
                        },
                      ),
                      const Text("No"),
                    ],
                  ),
                  const Text(
                      '4.2 Check if the cranes and hoist buttons are functioning properly'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Radio(
                        value: "Yes",
                        groupValue: devicesGroupValue2,
                        onChanged: (value) {
                          setState(() {
                            devicesGroupValue2 = value!;
                          });
                        },
                      ),
                      const Text("Yes"),
                      Radio(
                        value: "No",
                        groupValue: devicesGroupValue2,
                        onChanged: (value) {
                          setState(() {
                            devicesGroupValue2 = value!;
                          });
                        },
                      ),
                      const Text("No"),
                    ],
                  ),
                  const Text(
                      '4.3 Check if the lifting straps are still good to be used (slots, tears, etc...)'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Radio(
                        value: "Yes",
                        groupValue: devicesGroupValue3,
                        onChanged: (value) {
                          setState(() {
                            devicesGroupValue3 = value!;
                          });
                        },
                      ),
                      const Text("Yes"),
                      Radio(
                        value: "No",
                        groupValue: devicesGroupValue3,
                        onChanged: (value) {
                          setState(() {
                            devicesGroupValue3 = value!;
                          });
                        },
                      ),
                      const Text("No"),
                    ],
                  ),
                  const Text(
                      '4.4 Check if the magnets are clean and working , including the safe click'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Radio(
                        value: "Yes",
                        groupValue: devicesGroupValue4,
                        onChanged: (value) {
                          setState(() {
                            devicesGroupValue4 = value!;
                          });
                        },
                      ),
                      const Text("Yes"),
                      Radio(
                        value: "No",
                        groupValue: devicesGroupValue4,
                        onChanged: (value) {
                          setState(() {
                            devicesGroupValue4 = value!;
                          });
                        },
                      ),
                      const Text("No"),
                    ],
                  ),
                  const Text(
                      '4.5 Check if the lifting devices have current inspection tags'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Radio(
                        value: "Yes",
                        groupValue: devicesGroupValue5,
                        onChanged: (value) {
                          setState(() {
                            devicesGroupValue5 = value!;
                          });
                        },
                      ),
                      const Text("Yes"),
                      Radio(
                        value: "No",
                        groupValue: devicesGroupValue5,
                        onChanged: (value) {
                          setState(() {
                            devicesGroupValue5 = value!;
                          });
                        },
                      ),
                      const Text("No"),
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
              const Text(
                "5.LADDER",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 20,
              ),
              Column(
                children: [
                  const Text(
                      '5.1 Check if the ladders are in good condition (no corrosion, stability, etc...)'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Radio(
                        value: "Yes",
                        groupValue: ladderGroupValue,
                        onChanged: (value) {
                          setState(() {
                            ladderGroupValue = value!;
                          });
                        },
                      ),
                      const Text("Yes"),
                      Radio(
                        value: "No",
                        groupValue: ladderGroupValue,
                        onChanged: (value) {
                          setState(() {
                            ladderGroupValue = value!;
                          });
                        },
                      ),
                      const Text("No"),
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
              const Text(
                "6.5S's",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 20,
              ),
              Column(
                children: [
                  const Text(
                      '6.1 Check if the area is clean and well organized.'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Radio(
                        value: "Yes",
                        groupValue: sGroupValue1,
                        onChanged: (value) {
                          setState(() {
                            sGroupValue1 = value!;
                          });
                        },
                      ),
                      const Text("Yes"),
                      Radio(
                        value: "No",
                        groupValue: sGroupValue1,
                        onChanged: (value) {
                          setState(() {
                            sGroupValue1 = value!;
                          });
                        },
                      ),
                      const Text("No"),
                    ],
                  ),
                  const Text(
                      '6.2 Equipment and tools have the proper location defined and marked'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Radio(
                        value: "Yes",
                        groupValue: sGroupValue2,
                        onChanged: (value) {
                          setState(() {
                            sGroupValue2 = value!;
                          });
                        },
                      ),
                      const Text("Yes"),
                      Radio(
                        value: "No",
                        groupValue: sGroupValue2,
                        onChanged: (value) {
                          setState(() {
                            sGroupValue2 = value!;
                          });
                        },
                      ),
                      const Text("No"),
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
              const Text(
                "7.CHEMICAL SUBSTANCES",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 20,
              ),
              Column(
                children: [
                  const Text(
                      '7.1 Check if chemical products are properly packaged (packing, bottle)'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Radio(
                        value: "Yes",
                        groupValue: chemicalGroupValue1,
                        onChanged: (value) {
                          setState(() {
                            chemicalGroupValue1 = value!;
                          });
                        },
                      ),
                      const Text("Yes"),
                      Radio(
                        value: "No",
                        groupValue: chemicalGroupValue1,
                        onChanged: (value) {
                          setState(() {
                            chemicalGroupValue1 = value!;
                          });
                        },
                      ),
                      const Text("No"),
                    ],
                  ),
                  const Text(
                      '7.2 Check if chemical products are properly labeled'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Radio(
                        value: "Yes",
                        groupValue: chemicalGroupValue2,
                        onChanged: (value) {
                          setState(() {
                            chemicalGroupValue2 = value!;
                          });
                        },
                      ),
                      const Text("Yes"),
                      Radio(
                        value: "No",
                        groupValue: chemicalGroupValue2,
                        onChanged: (value) {
                          setState(() {
                            chemicalGroupValue2 = value!;
                          });
                        },
                      ),
                      const Text("No"),
                    ],
                  ),
                  const Text(
                      '7.3 Check if chemical products are properly stored (containment basin / area)'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Radio(
                        value: "Yes",
                        groupValue: chemicalGroupValue3,
                        onChanged: (value) {
                          setState(() {
                            chemicalGroupValue3 = value!;
                          });
                        },
                      ),
                      const Text("Yes"),
                      Radio(
                        value: "No",
                        groupValue: chemicalGroupValue3,
                        onChanged: (value) {
                          setState(() {
                            chemicalGroupValue3 = value!;
                          });
                        },
                      ),
                      const Text("No"),
                    ],
                  ),
                  const Text(
                      '7.4 Check if chemical products instruction sheet are close and easy to access.'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Radio(
                        value: "Yes",
                        groupValue: chemicalGroupValue4,
                        onChanged: (value) {
                          setState(() {
                            chemicalGroupValue4 = value!;
                          });
                        },
                      ),
                      const Text("Yes"),
                      Radio(
                        value: "No",
                        groupValue: chemicalGroupValue4,
                        onChanged: (value) {
                          setState(() {
                            chemicalGroupValue4 = value!;
                          });
                        },
                      ),
                      const Text("No"),
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
              const Text(
                "8.FORKLIFT,EQUIPMENT(If Applicable)",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 20,
              ),
              Column(
                children: [
                  const Text('8.1 Check if the tires are good'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Radio(
                        value: "Yes",
                        groupValue: liftGroupValue1,
                        onChanged: (value) {
                          setState(() {
                            liftGroupValue1 = value!;
                          });
                        },
                      ),
                      const Text("Yes"),
                      Radio(
                        value: "No",
                        groupValue: liftGroupValue1,
                        onChanged: (value) {
                          setState(() {
                            liftGroupValue1 = value!;
                          });
                        },
                      ),
                      const Text("No"),
                    ],
                  ),
                  const Text('8.2 Check if there is not leaks'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Radio(
                        value: "Yes",
                        groupValue: liftGroupValue2,
                        onChanged: (value) {
                          setState(() {
                            liftGroupValue2 = value!;
                          });
                        },
                      ),
                      const Text("Yes"),
                      Radio(
                        value: "No",
                        groupValue: liftGroupValue2,
                        onChanged: (value) {
                          setState(() {
                            liftGroupValue2 = value!;
                          });
                        },
                      ),
                      const Text("No"),
                    ],
                  ),
                  const Text(
                      '8.3 Check if the safety items are working (seat belt, horn, light, etc.)'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Radio(
                        value: "Yes",
                        groupValue: liftGroupValue3,
                        onChanged: (value) {
                          setState(() {
                            liftGroupValue3 = value!;
                          });
                        },
                      ),
                      const Text("Yes"),
                      Radio(
                        value: "No",
                        groupValue: liftGroupValue3,
                        onChanged: (value) {
                          setState(() {
                            liftGroupValue3 = value!;
                          });
                        },
                      ),
                      const Text("No"),
                    ],
                  ),
                  const Text(
                      '8.4 Check if the check list is fulfilled before start the activities'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Radio(
                        value: "Yes",
                        groupValue: liftGroupValue4,
                        onChanged: (value) {
                          setState(() {
                            liftGroupValue4 = value!;
                          });
                        },
                      ),
                      const Text("Yes"),
                      Radio(
                        value: "No",
                        groupValue: liftGroupValue4,
                        onChanged: (value) {
                          setState(() {
                            liftGroupValue4 = value!;
                          });
                        },
                      ),
                      const Text("No"),
                    ],
                  ),
                  const Text(
                      "8.5 Check if the battery's lock is working safely"),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Radio(
                        value: "Yes",
                        groupValue: liftGroupValue5,
                        onChanged: (value) {
                          setState(() {
                            liftGroupValue5 = value!;
                          });
                        },
                      ),
                      const Text("Yes"),
                      Radio(
                        value: "No",
                        groupValue: liftGroupValue5,
                        onChanged: (value) {
                          setState(() {
                            liftGroupValue5 = value!;
                          });
                        },
                      ),
                      const Text("No"),
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
              const Text(
                "9.EMERGENCY EQUIPMENT",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 20,
              ),
              Column(
                children: [
                  const Text(
                      '9.1 Check if the fire extinguisher have current inspection'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Radio(
                        value: "Yes",
                        groupValue: emergencyGroupValue1,
                        onChanged: (value) {
                          setState(() {
                            emergencyGroupValue1 = value!;
                          });
                        },
                      ),
                      const Text("Yes"),
                      Radio(
                        value: "No",
                        groupValue: emergencyGroupValue1,
                        onChanged: (value) {
                          setState(() {
                            emergencyGroupValue1 = value!;
                          });
                        },
                      ),
                      const Text("No"),
                    ],
                  ),
                  const Text(
                      '9.2 Check if emergency or medical  equipment identified (if applicable)'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Radio(
                        value: "Yes",
                        groupValue: emergencyGroupValue2,
                        onChanged: (value) {
                          setState(() {
                            emergencyGroupValue2 = value!;
                          });
                        },
                      ),
                      const Text("Yes"),
                      Radio(
                        value: "No",
                        groupValue: emergencyGroupValue2,
                        onChanged: (value) {
                          setState(() {
                            emergencyGroupValue2 = value!;
                          });
                        },
                      ),
                      const Text("No"),
                    ],
                  ),
                  const Text(
                      '9.3 Check if the area has emergency light / alarm'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Radio(
                        value: "Yes",
                        groupValue: emergencyGroupValue3,
                        onChanged: (value) {
                          setState(() {
                            emergencyGroupValue3 = value!;
                          });
                        },
                      ),
                      const Text("Yes"),
                      Radio(
                        value: "No",
                        groupValue: emergencyGroupValue3,
                        onChanged: (value) {
                          setState(() {
                            emergencyGroupValue3 = value!;
                          });
                        },
                      ),
                      const Text("No"),
                    ],
                  ),
                  const Text(
                      '9.4 Check if the eye wash is working  (if applicable)'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Radio(
                        value: "Yes",
                        groupValue: emergencyGroupValue4,
                        onChanged: (value) {
                          setState(() {
                            emergencyGroupValue4 = value!;
                          });
                        },
                      ),
                      const Text("Yes"),
                      Radio(
                        value: "No",
                        groupValue: emergencyGroupValue4,
                        onChanged: (value) {
                          setState(() {
                            emergencyGroupValue4 = value!;
                          });
                        },
                      ),
                      const Text("No"),
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
              const Text(
                "10.MACHINE CENTERS(If Applicable)",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 20,
              ),
              Column(
                children: [
                  const Text(
                      '10.1 Check if the machines have protection guards in place'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Radio(
                        value: "Yes",
                        groupValue: machineGroupValue1,
                        onChanged: (value) {
                          setState(() {
                            machineGroupValue1 = value!;
                          });
                        },
                      ),
                      const Text("Yes"),
                      Radio(
                        value: "No",
                        groupValue: machineGroupValue1,
                        onChanged: (value) {
                          setState(() {
                            machineGroupValue1 = value!;
                          });
                        },
                      ),
                      const Text("No"),
                    ],
                  ),
                  const Text(
                      '10.2 Check if the machines have redundant protection systems'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Radio(
                        value: "Yes",
                        groupValue: machineGroupValue2,
                        onChanged: (value) {
                          setState(() {
                            machineGroupValue2 = value!;
                          });
                        },
                      ),
                      const Text("Yes"),
                      Radio(
                        value: "No",
                        groupValue: machineGroupValue2,
                        onChanged: (value) {
                          setState(() {
                            machineGroupValue2 = value!;
                          });
                        },
                      ),
                      const Text("No"),
                    ],
                  ),
                  const Text(
                      '10.3 Check if the emergency items are in place and active'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Radio(
                        value: "Yes",
                        groupValue: machineGroupValue3,
                        onChanged: (value) {
                          setState(() {
                            machineGroupValue3 = value!;
                          });
                        },
                      ),
                      const Text("Yes"),
                      Radio(
                        value: "No",
                        groupValue: machineGroupValue3,
                        onChanged: (value) {
                          setState(() {
                            machineGroupValue3 = value!;
                          });
                        },
                      ),
                      const Text("No"),
                    ],
                  ),
                  const Text(
                      '10.4 Check if the ergonomic improvements are being used'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Radio(
                        value: "Yes",
                        groupValue: machineGroupValue4,
                        onChanged: (value) {
                          setState(() {
                            machineGroupValue4 = value!;
                          });
                        },
                      ),
                      const Text("Yes"),
                      Radio(
                        value: "No",
                        groupValue: machineGroupValue4,
                        onChanged: (value) {
                          setState(() {
                            machineGroupValue4 = value!;
                          });
                        },
                      ),
                      const Text("No"),
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
              const Text(
                "11.ENVIRONMENT",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 20,
              ),
              Column(
                children: [
                  const Text(
                      '11.1 Check if the  trash and waste collectors are identified'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Radio(
                        value: "Yes",
                        groupValue: environmentGroupValue1,
                        onChanged: (value) {
                          setState(() {
                            environmentGroupValue1 = value!;
                          });
                        },
                      ),
                      const Text("Yes"),
                      Radio(
                        value: "No",
                        groupValue: environmentGroupValue1,
                        onChanged: (value) {
                          setState(() {
                            environmentGroupValue1 = value!;
                          });
                        },
                      ),
                      const Text("No"),
                    ],
                  ),
                  const Text(
                      '11.2 Check if the waste are segregated correctly'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Radio(
                        value: "Yes",
                        groupValue: environmentGroupValue2,
                        onChanged: (value) {
                          setState(() {
                            environmentGroupValue2 = value!;
                          });
                        },
                      ),
                      const Text("Yes"),
                      Radio(
                        value: "No",
                        groupValue: environmentGroupValue2,
                        onChanged: (value) {
                          setState(() {
                            environmentGroupValue2 = value!;
                          });
                        },
                      ),
                      const Text("No"),
                    ],
                  ),
                  const Text(
                      '11.3 Check if the waste is place correctly (empty box unassembled, etc.)'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Radio(
                        value: "Yes",
                        groupValue: environmentGroupValue3,
                        onChanged: (value) {
                          setState(() {
                            environmentGroupValue3 = value!;
                          });
                        },
                      ),
                      const Text("Yes"),
                      Radio(
                        value: "No",
                        groupValue: environmentGroupValue3,
                        onChanged: (value) {
                          setState(() {
                            environmentGroupValue3 = value!;
                          });
                        },
                      ),
                      const Text("No"),
                    ],
                  ),
                ],
              ),
              const Divider(
                thickness: 2,
              ),
              Center(
                child: Text('Please put the signature here',
                    style: TextStyle(fontSize: 20, color: Colors.black)),
              ),
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
              const SizedBox(height: 15),
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
                  //     backgroundColor: MaterialStateProperty.all<Color>(
                  //         primaryColor),
                  //   ),
                  //   child: Text(
                  //       'Signature', style: TextStyle(color: Colors.black)),)
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
