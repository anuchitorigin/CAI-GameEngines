class ResetPasswordSuccessModel {
  String passcode;

  ResetPasswordSuccessModel({
    required this.passcode,
  });

  factory ResetPasswordSuccessModel.fromJson(Map<String, dynamic> input) {
    return ResetPasswordSuccessModel(
      passcode: input['passcode'],
    );
  }
}

List<ResetPasswordSuccessModel> resetpassDataFromJson(List<dynamic> input) {
  List<ResetPasswordSuccessModel> list = [];

  for(var x in input) {
    list.add(ResetPasswordSuccessModel.fromJson(x));
  }

  return list;
}