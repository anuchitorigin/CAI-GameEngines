import 'dart:convert';

class LessonModel {
  int id;
  String created_at;
  String? updated_at;
  bool belocked;
  bool becancelled;
  int docstatus;
  String lessonid;
  String lessoncode;
  int module_id;
  int lessonno;
  String title;
  String? descr;
  String? coverid;
  String contentid;
  String? mediaid;
  List<String> tags;
  String? released_at;

  LessonModel({
    required this.id,
    required this.created_at,
    this.updated_at,
    required this.belocked,
    required this.becancelled,
    required this.docstatus,
    required this.lessonid,
    required this.lessoncode,
    required this.module_id,
    required this.lessonno,
    required this.title,
    this.descr,
    this.coverid,
    required this.contentid,
    required this.mediaid,
    required this.tags,
    this.released_at
  });

  factory LessonModel.fromJson(Map<String, dynamic> input) {
    return LessonModel(
      id: input['id'],
      created_at: input['created_at'],
      updated_at: input['updated_at'],
      belocked: input['belocked'] != 0,
      becancelled: input['becancelled'] != 0,
      docstatus: input['docstatus'],
      lessonid: input['lessonid'],
      lessoncode: input['lessoncode'],
      module_id: input['module_id'],
      lessonno: input['lessonno'],
      title: input['title'],
      descr: input['descr'],
      coverid: input['coverid'],
      contentid: input['contentid'],
      mediaid: input['mediaid'],
      tags: (jsonDecode(input['tags']) as List).map((e) => e.toString()).toList(),
      released_at: input['released_at'],
    );
  }

  static List<LessonModel> lessonDataFromJson(List<dynamic> input) {
    List<LessonModel> list = [];

    for(var x in input) {
      list.add(LessonModel.fromJson(x));
    }

    return list;
  }
}