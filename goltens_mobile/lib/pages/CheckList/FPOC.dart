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

class FPOC extends StatefulWidget {
  FPOC({Key? key}) : super(key: key);

  @override
  State<FPOC> createState() => _FPOCState();
}

class _FPOCState extends State<FPOC> {
  UserResponse? user;
  SignatureController? controller;
  Uint8List? signature;
  String? selectedWeek;

  final TextEditingController tonnageController = TextEditingController();
  TextEditingController areaController = TextEditingController();
  DateTime selectedDate = DateTime.now().toUtc();
  TextEditingController timeController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController _ForkliftDirver = TextEditingController();
  TextEditingController machineController = TextEditingController();
  final departmentController = SingleValueDropDownController();
  String? selectedLocation;

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


  List<String> weeks = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
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

  List<TextEditingController> remarksControllers = List.generate(12, (index) => TextEditingController());

  @override
  void initState() {
    final state = context.read<GlobalState>();
    controller = SignatureController();

    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      if (mounted) {
        setState(() => user = state.user);
        _ForkliftDirver.text= "${user!.data.name} ${user!.data.employeeNumber}";
      }
    });
    super.initState();
    selectedWeek = weeks.first;
    dateController.text = formatDateTime(selectedDate, 'd/MM/y');
    timeController.text = formatDateTime(selectedDate, 'hh:mm aa');
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Text('Forklift Pre-Operational Checklist', style: TextStyle(color: Colors.black))),
        backgroundColor: primaryColor,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    const Text(
                      'Pre-Operational Checklist for Forklift (Tonnage: ',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      width: 60,
                      child: TextFormField(
                        controller: tonnageController,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Enter Here',
                        ),
                      ),
                    ),
                    const Text(')', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
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
              SizedBox(
                width: double.infinity,
                child: TextFormField(
                  controller: _ForkliftDirver,
                  decoration: InputDecoration(
                    labelText: 'Name of forklift driver',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
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
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedWeek,
                      onChanged: (value) {
                        setState(() {
                          selectedWeek = value;
                        });
                      },
                      isExpanded: true,
                      itemHeight: 48.0,
                      items: weeks.map((weeks) {
                        return DropdownMenuItem<String>(
                          value: weeks,
                          child: SizedBox(
                            width: double.infinity,
                            child: Text(
                              weeks,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        );
                      }).toList(),
                      decoration: InputDecoration(
                        labelText: 'Week',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.0),
                  Expanded(
                    child: TextField(
                      controller: machineController,
                      decoration: InputDecoration(
                        labelText: 'Machine No:',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                    ),
                  ),
                ],
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
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
              Center(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DataTable(
                          columns: const [
                            DataColumn(label: Text('S/N', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Item', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('What to check', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Remarks', style: TextStyle(fontWeight: FontWeight.bold))),
                          ],
                          rows: List.generate(
                            12,
                                (index) => DataRow(
                              cells: [
                                DataCell(Text('${index + 1}')),
                                DataCell(Text(getItemName(index))),
                                DataCell(Text(getWhatToCheck(index))),
                                DataCell(
                                  TextFormField(
                                    controller: remarksControllers[index],
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                              ],
                              color: MaterialStateColor.resolveWith((Set<MaterialState> states) {
                                return getColorForRowIndex(index) ?? Colors.transparent;
                              }),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
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
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Checked by:',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: Stack(
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
                      ),
                    ],

                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      if (areAllConditionsMet()) {
                        signature = await exportSignature();
                        FormData formData = FormData(
                          formTitle: "Forklift Checklist",
                          person1: _ForkliftDirver.text,
                          person2: machineController.text,
                          mainResult: "",
                          filterTitle: "Forklift Checklist",
                          username: user!.data.name,
                          userId: "${user!.data.id}",
                          dateAndTime: DateTime.now().toString(),
                          description: tonnageController.text,
                          status: "Active",
                          formResult: "",
                          header1: areaController.text,
                          header2: departmentController.dropDownValue?.value ?? '',
                          header3: selectedWeek!,
                          header4: '',
                          header5: '',
                          checklistImage: '',
                          inspectorSign: base64Encode(signature!),
                          questions: List.generate(
                            12,
                                (index) => Question(
                              content: getItemName(index),
                              answer: "",
                              content1: "",
                              content2: "",
                              content3: "",
                              answerList: [
                                AnswerListItem(
                                  answer: "Remarks",
                                  qusContent: remarksControllers[index].text,
                                ),
                              ],
                            ),
                          ),
                        );

                        ApiService().postData(formData);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Submitted successfully'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      } else {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text("Error"),
                              content: const Text("Please answer all questions."),
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
                    child: Text("Submit", style: TextStyle(color: Colors.black)),
                  ),
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

  Color? getColorForRowIndex(int index) {
    List<int> coloredRows = [4, 7, 9, 12];

    if (coloredRows.contains(index + 1)) {
      return Colors.yellowAccent;
    }

    return null;
  }

  String getItemName(int index) {
    List<String> itemNames = [
      'Brake oil',
      'Fire extinguisher',
      'Forks / Mast',
      'Horn',
      'Instrumental panel',
      'Lamps / Lights',
      'Lifting pins',
      'Load handling system',
      'Parking brake',
      'Safety belt',
      'Steering wheel',
      'Wheels',
    ];
    return itemNames[index];
  }

  String getWhatToCheck(int index) {
    List<String> whatToCheck = [
      'Level of oil',
      'Working condition',
      'Forks / Masts condition',
      'Sound condition',
      'Working condition',
      'Condition / Bulbs',
      'Working condition',
      'Lifting & tilting condition',
      'Operating force',
      'Working condition',
      'Steering wheel free play & abnormal sound',
      'Wear and tear of tyres / rim hub nut',
    ];
    return whatToCheck[index];
  }

  bool areAllConditionsMet() {
    return tonnageController.text.isNotEmpty &&
        machineController.text.isNotEmpty &&
        areaController.text.isNotEmpty &&
        departmentController.dropDownValue != null &&
        selectedWeek != null;
  }
}
