import 'dart:convert';

class RoleModel {
  String roleid;
  String rolename;
  Map roleparam;

  RoleModel({
    required this.roleid,
    required this.rolename,
    required this.roleparam,
  });

  factory RoleModel.fromJson(Map<String, dynamic> input) {
    return RoleModel(
      roleid: input['roleid'],
      rolename: input['rolename'],
      roleparam: jsonDecode(input['roleparam']),
    );
  }
}

List<RoleModel> roleDataFromJson(List<dynamic> input) {
  List<RoleModel> list = [];

  for(var x in input) {
    list.add(RoleModel.fromJson(x));
  }

  return list;
}