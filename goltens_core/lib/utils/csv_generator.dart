import 'package:csv/csv.dart';
import 'package:goltens_core/constants/constants.dart';
import 'package:goltens_core/utils/functions.dart';
import 'package:intl/intl.dart';

class CSVGenerator {
  static String generateReadStatus(
    List<dynamic> readUsers,
    List<dynamic> unReadUsers,
  ) {
    List<List<dynamic>> data = [
      ['Name', 'Email', 'Read/Unread'],
    ];

    for (var user in readUsers) {
      data.add([user.name, user.email, 'Read']);
    }

    for (var user in unReadUsers) {
      data.add([user.name, user.email, 'Unread']);
    }

    return const ListToCsvConverter().convert(data);
  }

  static String generateFeedbacks(
    List<dynamic> feedbacks,
  ) {
    String getColorStatusString(String color) {
      if (color == 'red') return 'Stop Work and Report';
      if (color == 'yellow') return 'Use Caution and Report';
      if (color == 'green') return 'Continue and Report';
      throw Exception('$color Not Supported');
    }

    List<List<dynamic>> data = [
      [
        'id',
        'location',
        'organizationName',
        'date',
        'time',
        'feedback',
        'source',
        'feedbackType',
        'selectedValues',
        'description',
        'reportedBy',
        'responsiblePerson',
        'actionTaken',
        'status',
      ],
    ];

    for (var feedback in feedbacks) {
      data.add([
        feedback.id,
        feedback.location,
        feedback.organizationName,
        feedback.date,
        feedback.time,
        feedback.feedback,
        feedback.source,
        getColorStatusString(feedback.color),
        feedback.selectedValues.split(",").join(","),
        feedback.description,
        feedback.reportedBy,
        feedback.responsiblePerson,
        feedback.actionTaken,
        feedback.status ?? '-'
      ]);
    }

    return const ListToCsvConverter().convert(data);
  }

  static String generateMasterList(
    List<dynamic> groupsData,
    List<dynamic> masterListData,
  ) {
    List<List<dynamic>> data = [];

    List<String> columns = [
      'SNO',
      'Title',
      'Group\'s Assigned',
      'Created By',
      'Created Date',
      'Time',
      'File Link',
    ];

    for (var group in groupsData) {
      columns.add(
        '${group.name}\n(Read / Clarify / Unread)',
      );
    }

    data.add(columns);

    for (var item in masterListData) {
      final createdDate = formatDateTime(item.createdAt, 'dd/MM/y');
      final time = formatDateTime(item.createdAt, 'HH:mm');

      final messageId = formatDateTime(
        item.createdAt,
        'yyMM\'SN${item.id}\'',
      );

      final Uri url;

      if (item.files.isNotEmpty) {
        url = Uri.parse('$apiUrl/$groupData/${item.files[0].name}');
      } else {
        url = Uri.parse('');
      }

      final groupsAssigned = item.groups.map((e) => e.name).toList();

      final row = [
        messageId,
        item.title,
        groupsAssigned.join('/'),
        item.createdBy.name,
        createdDate,
        time,
        item.files.isNotEmpty ? url.toString() : '-',
      ];

      for (var group in groupsData) {
        final groupExists = item.groups.any((el) => el.id == group.id);

        // Added ("") Quotes Because Excel Converts Them To Date
        if (groupExists) {
          final value = item.groups.firstWhere((el) => el.id == group.id);
          final readCount = value.readUsersCount;
          final clarifyCount = value.clarifyUsersCount;
          final unreadCount = value.unReadUsersCount;
          row.add('"$readCount / $clarifyCount / $unreadCount"');
        } else {
          row.add('"0 / 0 / 0"');
        }
      }

      data.add(row);
    }

    return const ListToCsvConverter().convert(data);
  }

  static String generateGroupMembersList(
    String groupName,
    List<dynamic> members,
  ) {
    List<List<dynamic>> data = [
      ['Members List Of $groupName'],
      ['Name', 'Email', 'Phone', 'Department', 'Type'],
    ];

    for (var user in members) {
      data.add([
        user.name,
        user.email,
        user.phone,
        user.department,
        user.type,
      ]);
    }

    return const ListToCsvConverter().convert(data);
  }

  static String generateUserOrientationReadInfo(
    List<dynamic> userOrientationReads,
  ) {
    List<List<dynamic>> data = [
      ['Name', 'Email', 'Read At'],
    ];

    for (var userRead in userOrientationReads) {
      data.add(
        [
          userRead.user.name,
          userRead.user.email,
          formatDateTime(userRead.readAt, 'HH:mm dd/mm/y')
        ],
      );
    }

    return const ListToCsvConverter().convert(data);
  }

  static String generateMeetingData(List<Map<String, dynamic>> meetings) {
    List<List<dynamic>> data = [
      [
        'Meeting ID',
        'Meeting Host',
        'Meeting type',
        'Department',
        'Title',
        'Date & Time',
      ],
    ];

    for (var meeting in meetings) {
      data.add([
        meeting['meetingId'],
        meeting['meetCreater'],
        meeting['isOnline'] == true ? "Online" : "Offline",
        meeting['department'],
        meeting['meetTitle'],
        DateTime.tryParse(meeting['meetDateTime']) != null
            ? DateFormat("dd-MM-yyyy")
                .format(DateTime.parse(meeting['meetDateTime']))
            : meeting['meetDateTime'],
        // meeting['meetDateTime'], // Assuming start time and date are the same for simplicity
        // meeting['meetEndTime'],
      ]);
    }

    return const ListToCsvConverter().convert(data);
  }

  static String generateChecklistData(List<dynamic> checklistData) {
    List<List<dynamic>> data = [
      ['Form ID', 'User', 'Form Title', 'Date and Time'],
    ];

    for (var checklistItem in checklistData) {
      data.add([
        checklistItem['formId'],
        checklistItem['username'],
        checklistItem['formTitle'],
        checklistItem['dateAndTime'],
      ]);
    }

    return const ListToCsvConverter().convert(data);
  }
}






// static String generateAdminMeetingList(List<Map<String, dynamic>> meetingData) {
//     List<List<dynamic>> data = [
//       [
//         'Meeting ID',
//         'Meeting Creator',
//         'Meeting Date and Time',
//         'Meeting Title',
//         'Department',
//         'Is Online',
//         'Meeting End Time',
//       ],
//     ];

//     for (var meeting in meetingData) {
//       data.add([
//         meeting['meetingId'],
//         meeting['meetCreater'],
//         meeting['meetDateTime'],
//         meeting['meetTitle'],
//         meeting['department'],
//         meeting['isOnline'] ? 'Yes' : 'No',
//         meeting['meetEndTime'],
//       ]);
//     }

//     return const ListToCsvConverter().convert(data);
//   }

//  static String generateFormHistoryCSV(List<Map<String, dynamic>> formData) {
//     final List<List<String>> csvData = [
//       [
//         'FormId',
//         'FormTitle',
//         'Person1',
//         'Person2',
//         'MainResult',
//         'FilterTitle',
//         'Username',
//         'UserId',
//         'DateAndTime',
//         'Description',
//         'Status',
//         'FormResult',
//       ],
//     ];

//     for (var form in formData) {
//       csvData.add([
//         form['formId'].toString(),
//         form['formTitle'].toString(),
//         form['person1'].toString(),
//         form['person2'].toString(),
//         form['mainResult'].toString(),
//         form['filterTitle'].toString(),
//         form['username'].toString(),
//         form['userId'].toString(),
//         form['dateAndTime'].toString(),
//         form['description'].toString(),
//         form['status'].toString(),
//         form['formResult'].toString(),
//       ]);
//     }

//     final csvString = List.generate(
//       csvData.length,
//       (index) => csvData[index].join(','),
//     ).join('\n');

//     return csvString;
//   }


