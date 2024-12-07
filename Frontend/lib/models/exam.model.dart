import 'dart:convert';

class ExamModel {
  int id;
  String created_at;
  String? updated_at;
  bool belocked;
  bool becancelled;
  int docstatus;
  String examid;
  String examcode;
  int module_id;
  int lesson_id;
  int maxscore;
  double examminute;
  String title;
  String caption;
  String? descr;
  String? coverid;
  int maturityrating;
  List<String> tags;
  String? released_at;

  ExamModel({
    required this.id,
    required this.created_at,
    this.updated_at,
    required this.belocked,
    required this.becancelled,
    required this.docstatus,
    required this.examid,
    required this.examcode,
    required this.module_id,
    required this.lesson_id,
    required this.maxscore,
    required this.examminute,
    required this.title,
    required this.caption,
    this.descr,
    this.coverid,
    required this.maturityrating,
    required this.tags,
    this.released_at
  });

  factory ExamModel.fromJson(Map<String, dynamic> input) {
    return ExamModel(
      id: input['id'],
      created_at: input['created_at'],
      updated_at: input['updated_at'],
      belocked: input['belocked'] != 0,
      becancelled: input['becancelled'] != 0,
      docstatus: input['docstatus'],
      examid: input['examid'],
      examcode: input['examcode'],
      module_id: input['module_id'],
      lesson_id: input['lesson_id'],
      maxscore: input['maxscore'],
      examminute: input['examminute'],
      title: input['title'],
      caption: input['caption'],
      descr: input['descr'],
      coverid: input['coverid'],
      maturityrating: input['maturityrating'],
      tags: (jsonDecode(input['tags']) as List).map((e) => e.toString()).toList(),
      released_at: input['released_at'],
    );
  }

  static List<ExamModel> examDataFromJson(List<dynamic> input) {
    List<ExamModel> list = [];

    for(var x in input) {
      list.add(ExamModel.fromJson(x));
    }

    return list;
  }
}