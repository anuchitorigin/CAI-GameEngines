class LogSysModel {
  int id;
  String created_at;
  String sysid;
  String incident;
  String logdetail;

  LogSysModel({
    required this.id,
    required this.created_at,
    required this.sysid,
    required this.incident,
    required this.logdetail,
  });

  factory LogSysModel.fromJson(Map<String, dynamic> input) {
    return LogSysModel(
      id: input['id'],
      created_at: input['created_at'],
      sysid: input['sysid'],
      incident: input['incident'],
      logdetail: input['logdetail'],
    );
  }

  static List<LogSysModel> logsysDataFromJson(List<dynamic> input) {
    List<LogSysModel> list = [];

    for(var x in input) {
      list.add(LogSysModel.fromJson(x));
    }

    return list;
  }
}