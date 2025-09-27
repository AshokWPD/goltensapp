import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:goltens_core/models/auth.dart';
import 'package:goltens_core/theme/theme.dart';
import 'package:goltens_core/utils/functions.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../provider/global_state.dart';

class FeedbackModel {
  final String username;
  final String userId;
  final String date;
  final String time;
  final String category;
  final String description;
  final String groupId;
  final String groupName;
  final String imgURL;

  FeedbackModel(
      {required this.username,
      required this.userId,
      required this.date,
      required this.time,
      required this.category,
      required this.description,
      required this.groupId,
      required this.groupName,
      required this.imgURL});

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'userId': userId,
      'date': date,
      'time': time,
      'category': category,
      'description': description,
      'groupId': groupId,
      'groupName': groupName,
      'imgURL': imgURL
    };
  }
}

class AppFeedback extends StatefulWidget {
  @override
  _AppFeedbackState createState() => _AppFeedbackState();
}

class _AppFeedbackState extends State<AppFeedback> {
  List<bool> isTypeSelected = [false, false, false, false, false, false];
  final TextEditingController personController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  XFile? _selectedImage;
  String? _imageName;
  final TextEditingController _textController = TextEditingController();
  final _maxLines = 4;
  String? imageUrl;
  List<String> selectedCategories = [];

  void selectImage(ImageSource source) async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: source);

    if (image != null) {
      setState(() {
        _selectedImage = image;
        _imageName = image.name;
      });

      print("Selected Image Path: ${_selectedImage!.path}");
      pickAndUploadImage();
      Navigator.pop(context);
    }
  }

  Future<void> pickAndUploadImage() async {
    if (_selectedImage == null) {
      print('No image selected.');
      return;
    }

    var request = http.MultipartRequest(
        'POST', Uri.parse('https://goltens.in/api/v1/review/uploadFile'));
    request.files
        .add(await http.MultipartFile.fromPath('file', _selectedImage!.path));

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final respStr = await response.stream.bytesToString();
      print('Response: $respStr');

      Map<String, dynamic> responseData = jsonDecode(respStr);
      if (responseData.containsKey('fileUrl')) {
        setState(() {
          imageUrl = responseData['fileUrl'];
        });
        print('Image URL: $imageUrl');
      } else {
        print('fileUrl key not found in response.');
      }
    } else {
      print('Failed to upload image: ${response.reasonPhrase}');
    }
  }

  void clearImage() {
    setState(() {
      _selectedImage = null;
      _imageName = null;
      imageUrl = null;
    });
  }

  void showImageSelectionBottomSheet() {
    if (_selectedImage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'You can only upload one image at a time. Please delete the existing image to upload a new one.'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (builder) => SizedBox(
          height: 200,
          width: MediaQuery.of(context).size.width,
          child: Card(
            margin: const EdgeInsets.all(18.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 20,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      bottomSheetIcon(
                        Icons.camera_alt,
                        Colors.indigo,
                        "Camera",
                        () => selectImage(ImageSource.camera),
                      ),
                      const SizedBox(width: 40),
                      bottomSheetIcon(
                        Icons.photo,
                        Colors.pink,
                        "Gallery",
                        () => selectImage(ImageSource.gallery),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }

  UserResponse? user;
  DateTime selectedDate = DateTime.now().toUtc();
  @override
  void initState() {
    final state = context.read<GlobalState>();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        setState(() => user = state.user);
        personController.text = "${user!.data.name}";
      }
    });
    super.initState();
    dateController.text = formatDateTime(selectedDate, 'd/MM/y');
    String formattedTime = DateFormat('hh:mm aa').format(selectedDate);
    timeController.text = formattedTime;
  }

  Widget bottomSheetIcon(
    IconData icons,
    Color color,
    String text,
    void Function() onPress,
  ) {
    return InkWell(
      onTap: onPress,
      borderRadius: const BorderRadius.all(Radius.circular(100.0)),
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: color,
            child: Icon(
              icons,
              size: 29,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            text,
            style: const TextStyle(fontSize: 12),
          )
        ],
      ),
    );
  }

  Future<void> addFeedback() async {
    FeedbackModel feedback = FeedbackModel(
        username: personController.text,
        userId: "${user!.data.id}",
        date: dateController.text,
        time: timeController.text,
        category: selectedCategories.join(', '),
        description: _textController.text,
        groupId: user!.data.employeeNumber,
        groupName: user!.data.department,
        imgURL: imageUrl ?? '');

    var url = Uri.parse('https://goltens.in/api/v1/review/createAppReview');
    try {
      var response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(feedback.toJson()),
      );

      if (response.statusCode == 201) {
        print('Feedback submitted successfully');
        print(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Your Feedback Shared Successfully...'),
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.pop(context);
      } else {
        print('Failed to send feedback. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error sending feedback: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Feedback'),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(right: 6.0, left: 6.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10.0),
                TextField(
                  controller: personController,
                  decoration: InputDecoration(
                    labelText: 'Feedback By',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                ),
                SizedBox(height: 14.0),
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
                SizedBox(height: 10.0),
                Text(
                  "Please select the category for your feedback",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w400),
                ),
                SizedBox(height: 10.0),
                ...List.generate(isTypeSelected.length, (index) {
                  return GestureDetector(
                    child: buildCheckItem(
                        title: getFeedbackType(index),
                        isSelected: isTypeSelected[index]),
                    onTap: () {
                      setState(() {
                        isTypeSelected[index] = !isTypeSelected[index];
                        if (isTypeSelected[index]) {
                          selectedCategories.add(getFeedbackType(index));
                          print("${getFeedbackType(index)} selected");
                          print("Selected Categories: $selectedCategories");
                        } else {
                          print("${getFeedbackType(index)} deselected");
                        }
                      });
                    },
                  );
                }),
                SizedBox(height: 20.0),
                buildFeedbackForm(),
                SizedBox(height: 20.0),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          addFeedback();
                        },
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(primaryColor),
                          shape: MaterialStateProperty.all<OutlinedBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.send,
                                color: Colors
                                    .black), // Replace with the desired icon
                            SizedBox(
                                width:
                                    8), // Adjust the spacing between the icon and text
                            Text('Submit Feedback',
                                style: TextStyle(color: Colors.black)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String getFeedbackType(int index) {
    switch (index) {
      case 0:
        return "Communication";
      case 1:
        return "Feedback";
      case 2:
        return "Toolbox Meeting";
      case 3:
        return "Checklist";
      case 4:
        return "Other issues";
      case 5:
        return "Suggestions";
      default:
        return "";
    }
  }

  buildFeedbackForm() {
    return Column(
      children: [
        TextField(
          controller: _textController,
          maxLines: _maxLines,
          maxLength: 180,
          decoration: InputDecoration(
            contentPadding:
                EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            labelText: "Please briefly describe your feedback",
            labelStyle: TextStyle(
              fontSize: 14.0,
              color: Colors.black45,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.0),
              borderSide: BorderSide(
                color: primaryColor,
              ),
            ),
          ),
        ),
        SizedBox(height: 10.0),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
            border: Border(
              top: BorderSide(
                width: 0.5,
                color: Colors.black,
              ),
              bottom: BorderSide(
                width: 0.5,
                color: Colors.black,
              ),
              right: BorderSide(
                width: 0.5,
                color: Colors.black,
              ),
              left: BorderSide(
                width: 0.5,
                color: Colors.black,
              ),
            ),
          ),
          padding: EdgeInsets.all(8.0),
          child: Row(
            children: [
              GestureDetector(
                onTap: showImageSelectionBottomSheet,
                child: Container(
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.photo,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10.0),
              if (_selectedImage != null) ...[
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black45),
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child:
                      Image.file(File(_selectedImage!.path), fit: BoxFit.cover),
                ),
                SizedBox(width: 10.0),
                Text(
                  _imageName != null
                      ? (_imageName!.length > 10
                          ? _imageName!.substring(0, 10) + '...'
                          : _imageName!)
                      : '',
                  style: TextStyle(
                    color: Colors.black,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(width: 30.0),
                GestureDetector(
                  onTap: clearImage,
                  child: Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                ),
              ] else
                Text(
                  "Upload screenshot (optional)",
                  style: TextStyle(
                    color: Colors.black45,
                  ),
                ),
            ],
          ),
        )
      ],
    );
  }

  Widget buildCheckItem({required String title, required bool isSelected}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isSelected ? primaryColor : Colors.black45,
          ),
          SizedBox(width: 10.0),
          Text(
            title,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? primaryColor : Colors.black45),
          ),
        ],
      ),
    );
  }
}
