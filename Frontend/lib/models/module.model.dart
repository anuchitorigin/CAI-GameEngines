import 'dart:convert';

class ModuleModel {
  int id;
  String created_at;
  String? updated_at;
  bool belocked;
  bool becancelled;
  int docstatus;
  String moduleid;
  String modulecode;
  String title;
  String caption;
  String? descr;
  String? coverid;
  int maturityrating;
  List<String> tags;
  String? released_at;

  ModuleModel({
    required this.id,
    required this.created_at,
    this.updated_at,
    required this.belocked,
    required this.becancelled,
    required this.docstatus,
    required this.moduleid,
    required this.modulecode,
    required this.title,
    required this.caption,
    this.descr,
    this.coverid,
    required this.maturityrating,
    required this.tags,
    this.released_at
  });

  factory ModuleModel.fromJson(Map<String, dynamic> input) {
    return ModuleModel(
      id: input['id'],
      created_at: input['created_at'],
      updated_at: input['updated_at'],
      belocked: input['belocked'] != 0,
      becancelled: input['becancelled'] != 0,
      docstatus: input['docstatus'],
      moduleid: input['moduleid'],
      modulecode: input['modulecode'],
      title: input['title'],
      caption: input['caption'],
      descr: input['descr'],
      coverid: input['coverid'],
      maturityrating: input['maturityrating'],
      tags: (jsonDecode(input['tags']) as List).map((e) => e.toString()).toList(),
      released_at: input['released_at'],
    );
  }

  static List<ModuleModel> moduleDataFromJson(List<dynamic> input) {
    List<ModuleModel> list = [];

    for(var x in input) {
      list.add(ModuleModel.fromJson(x));
    }

    return list;
  }
}