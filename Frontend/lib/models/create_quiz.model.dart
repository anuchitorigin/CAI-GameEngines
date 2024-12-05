class CreateQuizModel {
  int exam_id;
  int quizno;
  double? quizminute;
  String question;
  String? contentid;
  String? mediaid;
  List<CreateQuizChoiceModel> choices;

  CreateQuizModel({
    required this.exam_id,
    required this.quizno,
    this.quizminute,
    required this.question,
    this.contentid,
    this.mediaid,
    required this.choices
  });

  factory CreateQuizModel.fromJson(Map<String, dynamic> input) {
    return CreateQuizModel(
      exam_id: input['exam_id'],
      quizno: input['quizno'],
      quizminute: input['quizminute'],
      question: input['question'],
      contentid: input['contentid'],
      mediaid: input['mediaid'],
      choices: CreateQuizChoiceModel.createquizchoiceDataFromJson(input['choices'])
    );
  }

  static List<CreateQuizModel> createquizDataFromJson(List<dynamic> input) {
    List<CreateQuizModel> list = [];

    for(var x in input) {
      list.add(CreateQuizModel.fromJson(x));
    }

    return list;
  }
}

class CreateQuizChoiceModel {
  String answer;
  int choiceno;
  int choicescore;
  bool becorrect;
  String? mediaid;
  String? feedbackid;

  CreateQuizChoiceModel({
    required this.answer,
    required this.choiceno,
    required this.choicescore,
    required this.becorrect,
    this.mediaid,
    this.feedbackid
  });

  factory CreateQuizChoiceModel.fromJson(Map<String, dynamic> input) {
    return CreateQuizChoiceModel(
      answer: input['answer'],
      choiceno: input['choiceno'],
      choicescore: input['choicescore'],
      becorrect: input['becorrect'] != 0,
      mediaid: input['mediaid'],
      feedbackid: input['feedbackid'],
    );
  }

  static List<CreateQuizChoiceModel> createquizchoiceDataFromJson(List<dynamic> input) {
    List<CreateQuizChoiceModel> list = [];

    for(var x in input) {
      list.add(CreateQuizChoiceModel.fromJson(x));
    }

    return list;
  }
}