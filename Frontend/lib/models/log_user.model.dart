class LogUserModel {
  int id;
  String created_at;
  String userid;
  String incident;
  String logdetail;

  LogUserModel({
    required this.id,
    required this.created_at,
    required this.userid,
    required this.incident,
    required this.logdetail,
  });

  factory LogUserModel.fromJson(Map<String, dynamic> input) {
    return LogUserModel(
      id: input['id'],
      created_at: input['created_at'],
      userid: input['userid'],
      incident: input['incident'],
      logdetail: input['logdetail'],
    );
  }

  static List<LogUserModel> loguserDataFromJson(List<dynamic> input) {
    List<LogUserModel> list = [];

    for(var x in input) {
      list.add(LogUserModel.fromJson(x));
    }

    return list;
  }
}