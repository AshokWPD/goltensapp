import 'dart:convert';
import 'package:digital_signature_flutter/digital_signature_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:goltens_core/models/auth.dart';
import 'package:goltens_core/theme/theme.dart';
import 'package:goltens_mobile/meet_main.dart';
import 'package:goltens_mobile/pages/others/app_choose_page.dart';
import 'package:goltens_mobile/provider/global_state.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class EmpDigitalSignature extends StatefulWidget {
  final String meetingId;

  const EmpDigitalSignature({super.key, required this.meetingId});

  @override
  State<EmpDigitalSignature> createState() => _EmpDigitalSignatureState();
}

class _EmpDigitalSignatureState extends State<EmpDigitalSignature> {
  double _dialogHeight = 0.0;
  final double _dialogWidth = 400;
  SignatureController? controller;
  Uint8List? signature;
  UserResponse? user;
  TextEditingController remarkController = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller = SignatureController(penStrokeWidth: 2, penColor: Colors.black);

    Future.delayed(const Duration(milliseconds: 50), () {
      setState(() {
        _dialogHeight = 600;
      });
    });

    final state = context.read<GlobalState>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() => user = state.user);
      }
    });
  }

  Future<void> _addMemberToAttendedList(
      String meetingId, int memberId, Uint8List? digitalSignature) async {
    final url =
        'https://goltens.in/api/v1/meeting/updatemember/$memberId/$meetingId';

    if (user != null && user!.data.type != UserType.admin) {
      final DateFormat formatter = DateFormat('dd-MM-yyyy T HH:mm:ss');
      final Map<String, dynamic> data = {
        "membersName": user!.data.name,
        "memberInTime": DateTime.now().toLocal().toIso8601String(),
        "memberOutTime": DateTime.now().toLocal().toIso8601String(),
        "dateTime": DateTime.now().toLocal().toIso8601String(),
        "location": "1",
        "remark": remarkController.text,
        "memberdep": user!.data.department,
        "memberphone": user!.data.phone,
        "memberemail": user!.data.email,
        "latitude": 40.7128,
        "longitude": -74.006,
        "digitalSignature": base64Encode(digitalSignature!),
      };

      final response = await http.put(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );
      print(jsonEncode(data));
      if (response.statusCode == 200) {
        Navigator.pop(
          context,
        );

        print('Member added to attended list successfully');
      } else {
        Navigator.pushReplacementNamed(context, '/sub-admin-meeting');

        print(
            'Failed to add member to attended list. Status code: ${response.statusCode}');
      }
    } else {
      Navigator.pop(
        context,
      );
      print('User authentication data is not available');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      height: _dialogHeight,
      width: _dialogWidth,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Your Remarks and Signature',
                  style: TextStyle(fontSize: 20, color: Colors.black)),
              const SizedBox(height: 10),
              TextField(
                controller: remarkController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Remarks',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Card(
                elevation: 10,
                child: Center(
                  child: Signature(
                    height: 200,
                    width: 350,
                    controller: controller!,
                    backgroundColor: Colors.grey.shade100,
                  ),
                ),
              ),
              buttonWidgets(context)!,
              const SizedBox(height: 30),
              signature != null
                  ? Column(
                      children: [
                        Center(child: Image.memory(signature!)),
                        const SizedBox(height: 10),
                        MaterialButton(
                          color: primaryColor,
                          onPressed: () {
                            _addMemberToAttendedList(widget.meetingId,
                                user?.data.id ?? 0, signature);
                          },
                          child: const Text(
                            "Submit",
                            style: TextStyle(
                              fontSize: 12,
                            ),
                          ),
                        )
                      ],
                    )
                  : Container(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  buttonWidgets(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        TextButton(
          onPressed: () async {
            if (controller!.isNotEmpty) {
              final sign = await exportSignature();
              setState(() {
                signature = sign;
              });
            } else {
              // showMessage: Please put your signature;
            }
          },
          child: const Text("Preview",
              style: TextStyle(fontSize: 20, color: primaryColor)),
        ),
        TextButton(
          onPressed: () {
            controller?.clear();
            setState(() {
              signature = null;
            });
          },
          child: const Text("Cancel",
              style: TextStyle(fontSize: 20, color: Colors.red)),
        ),
      ],
    );
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
}
