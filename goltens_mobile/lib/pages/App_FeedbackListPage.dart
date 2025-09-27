import 'package:flutter/material.dart';
import 'package:goltens_core/theme/theme.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class FeedbackModel {
  final int id;
  final String username;
  final String userId;
  final String date;
  final String time;
  final String category;
  final String description;
  final String? imgURL;
  final String groupName;
  final String groupId;

  FeedbackModel({
    required this.id,
    required this.username,
    required this.userId,
    required this.date,
    required this.time,
    required this.category,
    required this.description,
    this.imgURL,
    required this.groupName,
    required this.groupId,
  });

  factory FeedbackModel.fromJson(Map<String, dynamic> json) {
    return FeedbackModel(
      id: json['id'],
      username: json['username'],
      userId: json['userId'],
      date: json['date'],
      time: json['time'],
      category: json['category'],
      description: json['description'],
      imgURL: json['imgURL'],
      groupName: json['groupName'],
      groupId: json['groupId'],
    );
  }
}

class AppFeedbackListPage extends StatefulWidget {
  @override
  _AppFeedbackListPageState createState() => _AppFeedbackListPageState();
}

class _AppFeedbackListPageState extends State<AppFeedbackListPage> {
  late Future<List<FeedbackModel>> futureFeedback;

  @override
  void initState() {
    super.initState();
    futureFeedback = fetchFeedback();
  }

  Future<List<FeedbackModel>> fetchFeedback() async {
    final response = await http
        .get(Uri.parse('https://goltens.in/api/v1/review/getAllAppReviews'));

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => FeedbackModel.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load feedback');
    }
  }

  Future<void> refreshFeedback() async {
    setState(() {
      futureFeedback = fetchFeedback();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("App User's Feedbacks"),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        color: primaryColor,
        onRefresh: () => refreshFeedback(),
        child: FutureBuilder<List<FeedbackModel>>(
          future: futureFeedback,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final feedback = snapshot.data![index];
                  return Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                    child: Card(
                      color: Colors.grey.shade200,
                      margin: EdgeInsets.all(10.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Feedback By : ${feedback.username}",
                              style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              "${feedback.date} ${feedback.time}",
                              style: TextStyle(color: Colors.grey),
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              "Category : ${feedback.category}",
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.w500,
                                color: Colors.blue,
                              ),
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              "Description : ${feedback.description}",
                              style: TextStyle(fontSize: 16.0),
                            ),
                            if (feedback.imgURL != null) ...[
                              SizedBox(height: 10.0),
                              feedback.imgURL!.isNotEmpty
                                  ? Container(
                                      height: 200,
                                      width: double.infinity,
                                      child: Image.network(
                                        feedback.imgURL!,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : SizedBox(),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            } else if (snapshot.hasError) {
              return Center(child: Text('${snapshot.error}'));
            }
            return Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
