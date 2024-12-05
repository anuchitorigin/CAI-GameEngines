class LoginTokenModel {
  String token;

  LoginTokenModel({
    required this.token
  });

  factory LoginTokenModel.fromJson(Map<String, dynamic> json) {
    return LoginTokenModel(
      token: json['token'],
    );
  }
}

List<LoginTokenModel> loginTokenDataFromJson(List<dynamic> json) {
  List<LoginTokenModel> list = [];

  for(var x in json) {
    list.add(LoginTokenModel.fromJson(x));
  }

  return list;
}