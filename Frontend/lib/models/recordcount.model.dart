class RecordCountModel {
  int RecordCount;

  RecordCountModel({
    required this.RecordCount
  });

  factory RecordCountModel.fromJson(Map<String, dynamic> input) {
    return RecordCountModel(
      RecordCount: input['RecordCount'],
    );
  }

  static List<RecordCountModel> recordcountDataFromJson(List<dynamic> input) {
    List<RecordCountModel> list = [];

    for(var x in input) {
      list.add(RecordCountModel.fromJson(x));
    }

    return list;
  }
}