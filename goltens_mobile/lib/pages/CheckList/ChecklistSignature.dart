import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:digital_signature_flutter/digital_signature_flutter.dart';

class ChecklistSignature extends StatefulWidget {
  @override
  State<ChecklistSignature> createState() => _ChecklistSignatureState();
}

class _ChecklistSignatureState extends State<ChecklistSignature> {
  double _dialogHeight = 0.0;
  final double _dialogWidth = 400;
  SignatureController? controller;
  Uint8List? signature;

  @override
  void initState() {
    super.initState();
    controller = SignatureController(penStrokeWidth: 2, penColor: Colors.black);

    Future.delayed(const Duration(milliseconds: 50), () {
      setState(() {
        _dialogHeight = 600;
      });
    });
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
              const SizedBox(height: 15),
              const Text('Please put the signature here',
                  style: TextStyle(fontSize: 20, color: Colors.black)),
              const SizedBox(height: 15),
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
              // buttonWidgets(),
              const SizedBox(height: 30),
              signature != null
                  ? Column(
                children: [
                  Center(child: Image.memory(signature!)),
                  const SizedBox(height: 10),
                  MaterialButton(
                    onPressed: () {
                      // Call your API or perform any other action here
                      // _addMemberToAttendedList(signature);
                      print('Signature captured');
                      Navigator.pop(context);
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

  buttonWidgets() {
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
              style: TextStyle(fontSize: 20, color: Colors.blue)),
        ),
        TextButton(
          onPressed: () {
            controller?.clear();
            setState(() {
              signature = null;
            });
          },
          child: const Text("Clear",
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

    // clean up the memory
    exportController.dispose();

    return signature;
  }

  @override
  void dispose() {
    controller!.dispose();
    super.dispose();
  }
}
