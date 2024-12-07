class QuizModel {
  int id;
  String created_at;
  String? updated_at;
  bool belocked;
  bool becancelled;
  int docstatus;
  int exam_id;
  int quizno;
  double quizminute;
  String question;
  String contentid;
  String? mediaid;
  String? released_at;
  List<QuizChoiceModel>? choices;

  QuizModel({
    required this.id,
    required this.created_at,
    this.updated_at,
    required this.belocked,
    required this.becancelled,
    required this.docstatus,
    required this.exam_id,
    required this.quizno,
    required this.quizminute,
    required this.question,
    required this.contentid,
    this.mediaid,
    this.released_at,
    this.choices
  });

  factory QuizModel.fromJson(Map<String, dynamic> input) {
    return QuizModel(
      id: input['id'],
      created_at: input['created_at'],
      updated_at: input['updated_at'],
      belocked: input['belocked'] != 0,
      becancelled: input['becancelled'] != 0,
      docstatus: input['docstatus'],
      exam_id: input['exam_id'],
      quizno: input['quizno'],
      quizminute: input['quizminute'],
      question: input['question'],
      contentid: input['contentid'],
      mediaid: input['mediaid'],
      released_at: input['released_at'],
      choices: input['choices'] != null ? QuizChoiceModel.quizchoiceDataFromJson(input['choices']) : input['choices']
    );
  }

  static List<QuizModel> quizDataFromJson(List<dynamic> input) {
    List<QuizModel> list = [];

    for(var x in input) {
      list.add(QuizModel.fromJson(x));
    }

    return list;
  }
}

class QuizChoiceModel {
  int id;
  String created_at;
  String? updated_at;
  int quiz_id;
  String answer;
  int choiceno;
  int choicescore;
  bool becorrect;
  String? mediaid;
  String feedbackid;

  QuizChoiceModel({
    required this.id,
    required this.created_at,
    this.updated_at,
    required this.quiz_id,
    required this.answer,
    required this.choiceno,
    required this.choicescore,
    required this.becorrect,
    this.mediaid,
    required this.feedbackid
  });

  factory QuizChoiceModel.fromJson(Map<String, dynamic> input) {
    return QuizChoiceModel(
      id: input['id'],
      created_at: input['created_at'],
      updated_at: input['updated_at'],
      quiz_id: input['quiz_id'],
      answer: input['answer'],
      choiceno: input['choiceno'],
      choicescore: input['choicescore'],
      becorrect: input['becorrect'] != 0,
      mediaid: input['mediaid'],
      feedbackid: input['feedbackid'],
    );
  }

  static List<QuizChoiceModel> quizchoiceDataFromJson(List<dynamic> input) {
    List<QuizChoiceModel> list = [];

    for(var x in input) {
      list.add(QuizChoiceModel.fromJson(x));
    }

    return list;
  }
}