class UserModel {
  int? id;
  String userid;
  String loginid;
  int role_super;
  String firstname;
  String? lastname;

  UserModel({
    this.id,
    required this.userid,
    required this.loginid,
    required this.role_super,
    required this.firstname,
    required this.lastname,
  });

  factory UserModel.fromJson(Map<String, dynamic> input) {
    return UserModel(
      id: input['id'],
      userid: input['userid'],
      loginid: input['loginid'],
      role_super: input['role_super'],
      firstname: input['firstname'],
      lastname: input['lastname'],
    );
  }
}

List<UserModel> userDataFromJson(List<dynamic> input) {
  List<UserModel> list = [];

  for(var x in input) {
    list.add(UserModel.fromJson(x));
  }

  return list;
}