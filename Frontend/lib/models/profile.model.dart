import 'dart:convert';

class ProfileModel {
  int? id;
  String? createdAt;
  int? belocked;
  String? userid;
  String loginid;
  Map roleparam;
  String firstname;
  String? lastname;
  String? employeeid;
  String? remark;
  String? expiredAt;

  ProfileModel({
    required this.id,
    required this.createdAt,
    required this.belocked,
    required this.userid,
    required this.loginid,
    required this.roleparam,
    required this.firstname,
    required this.lastname,
    required this.employeeid,
    required this.remark,
    required this.expiredAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> input) {
    return ProfileModel(
      id: input['id'],
      createdAt: input['created_at'],
      belocked: input['belocked'],
      userid: input['userid'],
      loginid: input['loginid'],
      roleparam: jsonDecode(input['roleparam']),
      firstname: input['firstname'],
      lastname: input['lastname'],
      employeeid: input['employeeid'],
      remark: input['remark'],
      expiredAt: input['expired_at'],
    );
  }
}

List<ProfileModel> profileDataFromJson(List<dynamic> input) {
  List<ProfileModel> list = [];

  for(var x in input) {
    list.add(ProfileModel.fromJson(x));
  }

  return list;
}