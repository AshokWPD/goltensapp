import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class FileItem {
  final String name;
  final String type;

  FileItem({required this.name, required this.type});

  factory FileItem.fromJson(Map<String, dynamic> json) {
    return FileItem(
      name: json['name'],
      type: json['type'],
    );
  }

  IconData get icon {
    switch (type) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'png':
        return Icons.image;
      case 'jpg':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }
}

Future<List<String>> fetchFiles(String meetId) async {
  final response = await http
      .get(Uri.parse('https://goltens.in/api/v1/meeting/$meetId/filelinks'));

  if (response.statusCode == 200) {
    List<dynamic> data = jsonDecode(response.body);
    return data.cast<String>();
  } else {
    throw Exception('Failed to load files');
  }
}
