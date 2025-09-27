import 'dart:convert';
import 'package:goltens_mobile/components/ptpMessage/ptpModel.dart';
import 'package:http/http.dart' as http;

class PtpMessageService {
  final String baseUrl =
      'https://goltens.in/api/v1/ptpmessage'; // Replace with your actual server URL

  // Create a new PtpMessage
  Future<PtpMessage?> createPtpMessage(
    String fromID,
    String toID,
    String message,
  ) async {
    PtpMessage messagedata = PtpMessage.forApiCreation(
        fromID: fromID,
        toID: toID,
        message: message,
        dateTime: DateTime.now().toString(),
        isRead: false);
    final response = await http.post(
      Uri.parse('$baseUrl/createPtpMessage'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(messagedata.toCreationMap()),
    );

    if (response.statusCode == 201) {
      return PtpMessage.fromMap(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create PtpMessage');
    }
  }

  // Update PtpMessage by ID
  Future<PtpMessage?> updatePtpMessageById(int id, PtpMessage message) async {
    final response = await http.put(
      Uri.parse('$baseUrl/updatePtpMessage/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(message.toMap()),
    );

    if (response.statusCode == 200) {
      return PtpMessage.fromMap(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update PtpMessage');
    }
  }

  // Get newest PtpMessages with a limit by fromID or toID
  Future<List<PtpMessage>> getNewestPtpMessages(String id,
      {int limit = 10}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/getNewestPtpMessages/$id?limit=$limit'),
    );

    if (response.statusCode == 200) {
      Iterable list = jsonDecode(response.body);
      return list.map((message) => PtpMessage.fromMap(message)).toList();
    } else {
      throw Exception('Failed to load PtpMessages');
    }
  }

  // Delete PtpMessage by ID
  Future<void> deletePtpMessageById(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/deletePtpMessage/$id'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete PtpMessage');
    }
  }
}
