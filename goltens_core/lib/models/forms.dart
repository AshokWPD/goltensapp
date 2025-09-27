class FormData {
  String formTitle;
  String person1;
  String person2;
  String mainResult;
  String filterTitle;
  String username;
  String header1;
  String header2;
  String header3;
  String header4;
  String header5;
  String userId;
  String checklistImage;
  String inspectorSign;
  String dateAndTime;
  String description;
  String status;
  String formResult;
  List<Question> questions;

  FormData({
    required this.formTitle,
    required this.person1,
    required this.person2,
    required this.mainResult,
    required this.filterTitle,
    required this.username,
    required this.header1,
    required this.header2,
    required this.header3,
    required this.header4,
    required this.header5,
    required this.userId,
    required this.checklistImage,
    required this.inspectorSign,
    required this.dateAndTime,
    required this.description,
    required this.status,
    required this.formResult,
    required this.questions,
  });

  factory FormData.fromJson(Map<String, dynamic> json) {
    var questionsList = json['questions'] as List;
    List<Question> questions =
    questionsList.map((question) => Question.fromJson(question)).toList();

    return FormData(
      formTitle: json['formTitle'],
      person1: json['person1'],
      person2: json['person2'],
      mainResult: json['mainResult'],
      filterTitle: json['filterTitle'],
      username: json['username'],
      userId: json['userId'],
      dateAndTime: json['dateAndTime'],
      description: json['description'],
      status: json['status'],
      formResult: json['formResult'],
      questions: questions,
      header1: json['header1'],
      header2: json['header2'],
      header3: json['header3'],
      header4: json['header4'],
      header5: json['header5'],
      checklistImage: json['checklistImage'],
      inspectorSign: json['inspectorSign'],
    );
  }

  Map<String, dynamic> toJson() => {
    'formTitle': formTitle,
    'person1': person1,
    'person2': person2,
    'mainResult': mainResult,
    'filterTitle': filterTitle,
    'username': username,
    'userId': userId,
    'dateAndTime': dateAndTime,
    'description': description,
    'status': status,
    'formResult': formResult,
    'questions': questions.map((question) => question.toJson()).toList(),
    'header1':header1,
    'header2':header2,
    'header3':header3,
    'header4':header4,
    'header5':header5,
    'checklistImage':checklistImage,
    'inspectorSign':inspectorSign,
  };
}

class Question {
  String content;
  String answer;
  String content1;
  String content2;
  String content3;
  List<AnswerListItem> answerList;

  Question({
    required this.content,
    required this.answer,
    required this.content1,
    required this.content2,
    required this.content3,
    required this.answerList,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    var answerList = json['answerList'] as List;
    List<AnswerListItem> answerItems =
    answerList.map((item) => AnswerListItem.fromJson(item)).toList();

    return Question(
      content: json['content'],
      answer: json['answer'],
      content1: json['content1'],
      content2: json['content2'],
      content3: json['content3'],
      answerList: answerItems,
    );
  }

  Map<String, dynamic> toJson() => {
    'content': content,
    'answer': answer,
    'content1': content1,
    'content2': content2,
    'content3': content3,
    'answerList': answerList.map((item) => item.toJson()).toList(),
  };
}

class AnswerListItem {
  String answer;
  String qusContent;

  AnswerListItem({
    required this.answer,
    required this.qusContent,
  });

  factory AnswerListItem.fromJson(Map<String, dynamic> json) {
    return AnswerListItem(
      answer: json['answer'],
      qusContent: json['qusContent'],
    );
  }

  Map<String, dynamic> toJson() => {
    'answer': answer,
    'qusContent': qusContent,
  };
}