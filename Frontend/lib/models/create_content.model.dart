class CreateContentModel {
  String contentid;

  CreateContentModel({
    required this.contentid
  });

  factory CreateContentModel.fromJson(Map<String, dynamic> json) {
    return CreateContentModel(
      contentid: json['bucketid']
    );
  }

  static List<CreateContentModel> createContentDataFromJson(List<dynamic> input) {
    List<CreateContentModel> list = [];

    for(var x in input) {
      list.add(CreateContentModel.fromJson(x));
    }

    return list;
  }
}