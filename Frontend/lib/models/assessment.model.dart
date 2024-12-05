class AssessmentModel {
  int id;
  String created_at;
  String? updated_at;
  String? finished_at;
  String userid;
  String examid;
  String examcode;
  int module_id;
  int lesson_id;
  int maxscore;
  double examminute;
  String title;
  int finishscore;
  int finishminute;

  AssessmentModel({
    required this.id,
    required this.created_at,
    this.updated_at,
    this.finished_at,
    required this.userid,
    required this.examid,
    required this.examcode,
    required this.module_id,
    required this.lesson_id,
    required this.maxscore,
    required this.examminute,
    required this.title,
    required this.finishscore,
    required this.finishminute
  });

  factory AssessmentModel.fromJson(Map<String, dynamic> input) {
    return AssessmentModel(
      id: input['id'],
      created_at: input['created_at'],
      updated_at: input['updated_at'],
      finished_at: input['finished_at'],
      userid: input['userid'],
      examid: input['examid'],
      examcode: input['examcode'],
      module_id: input['module_id'],
      lesson_id: input['lesson_id'],
      maxscore: input['maxscore'],
      examminute: input['examminute'],
      title: input['title'],
      finishscore: input['finishscore'],
      finishminute: input['finishminute']
    );
  }

  static List<AssessmentModel> assessmentFromJson(List<dynamic> input) {
    List<AssessmentModel> list = [];

    for(var x in input) {
      list.add(AssessmentModel.fromJson(x));
    }

    return list;
  }
}

class CreateAssessmentResult {
  int id;
  String examid;
  String examcode;
  int module_id;
  int lesson_id;
  int maxscore;
  double examminute;
  String title;
  String caption;
  String descr;
  String coverid;
  int assessment_id;
  List<CreateAssessmentQuiz> quizzes;

  CreateAssessmentResult({
    required this.id,
    required this.examid,
    required this.examcode,
    required this.module_id,
    required this.lesson_id,
    required this.maxscore,
    required this.examminute,
    required this.title,
    required this.caption,
    required this.descr,
    required this.coverid,
    required this.assessment_id,
    required this.quizzes
  });

  factory CreateAssessmentResult.fromJson(Map<String, dynamic> json) {
    return CreateAssessmentResult(
      id: json['id'],
      examid: json['examid'],
      examcode: json['examcode'],
      module_id: json['module_id'],
      lesson_id: json['lesson_id'],
      maxscore: json['maxscore'],
      examminute: json['examminute'],
      title: json['title'],
      caption: json['caption'],
      descr: json['descr'],
      coverid: json['coverid'],
      assessment_id: json['assessment_id'],
      quizzes: CreateAssessmentQuiz.quizDataFromJson(json['quizzes'])
    );
  }

  static List<CreateAssessmentResult> createassessmentresultFromJson(List<dynamic> input) {
    List<CreateAssessmentResult> list = [];

    for(var x in input) {
      list.add(CreateAssessmentResult.fromJson(x));
    }

    return list;
  }
}

class CreateAssessmentQuiz {
  int id;
  int quizno;
  int quizminute;
  String question;
  String contentid;
  String mediaid;
  List<QuizChoice> choices;

  CreateAssessmentQuiz({
    required this.id,
    required this.quizno,
    required this.quizminute,
    required this.question,
    required this.contentid,
    required this.mediaid,
    required this.choices
  });

  factory CreateAssessmentQuiz.fromJson(Map<String, dynamic> json) {
    return CreateAssessmentQuiz(
      id: json['id'],
      quizno: json['quizno'],
      quizminute: json['quizminute'],
      question: json['question'],
      contentid: json['contentid'],
      mediaid: json['mediaid'],
      choices: QuizChoice.choiceDataFromJson(json['choices'])
    );
  }

  static List<CreateAssessmentQuiz> quizDataFromJson(List<dynamic> input) {
    List<CreateAssessmentQuiz> list = [];

    for(var x in input) {
      list.add(CreateAssessmentQuiz.fromJson(x));
    }

    return list;
  }
}

class QuizChoice {
  int id;
  String answer;
  int choiceno;
  String mediaid;

  QuizChoice({
    required this.id,
    required this.answer,
    required this.choiceno,
    required this.mediaid
  });

  factory QuizChoice.fromJson(Map<String, dynamic> json) {
    return QuizChoice(
      id: json['id'],
      answer: json['answer'],
      choiceno: json['choiceno'],
      mediaid: json['mediaid']
    );
  }

  static List<QuizChoice> choiceDataFromJson(List<dynamic> input) {
    List<QuizChoice> list = [];

    for(var x in input) {
      list.add(QuizChoice.fromJson(x));
    }

    return list;
  }
}

class CreateUpdateOne {
  int id;
  int choice_id;

  CreateUpdateOne({
    required this.id,
    required this.choice_id
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'choice_id': choice_id
    };
  }
}

class CheckChoiceModel {
  int id;
  int choicescore;
  bool becorrect;
  String feedbackid;

  CheckChoiceModel({
    required this.id,
    required this.choicescore,
    required this.becorrect,
    required this.feedbackid
  });

  factory CheckChoiceModel.fromJson(Map<String, dynamic> json) {
    return CheckChoiceModel(
      id: json['id'],
      choicescore: json['choicescore'],
      becorrect: json['becorrect'] == 1,
      feedbackid: json['feedbackid']
    );
  }

  static List<CheckChoiceModel> checkchoiceDataFromJson(List<dynamic> input) {
    List<CheckChoiceModel> list = [];

    for(var x in input) {
      list.add(CheckChoiceModel.fromJson(x));
    }

    return list;
  }
}