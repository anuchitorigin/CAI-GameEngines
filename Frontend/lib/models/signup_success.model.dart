class SignupSuccessModel {
  String loginid;
  String passcode;

  SignupSuccessModel({
    required this.loginid,
    required this.passcode,
  });

  factory SignupSuccessModel.fromJson(Map<String, dynamic> input) {
    return SignupSuccessModel(
      loginid: input['loginid'],
      passcode: input['passcode'],
    );
  }
}

List<SignupSuccessModel> signupDataFromJson(List<dynamic> input) {
  List<SignupSuccessModel> list = [];

  for(var x in input) {
    list.add(SignupSuccessModel.fromJson(x));
  }

  return list;
}