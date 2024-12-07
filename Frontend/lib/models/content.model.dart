import 'dart:typed_data';

class ContentModel {
  String bucketname;
  String buckettype;
  ContentDataModel bucketdata;

  ContentModel({
    required this.bucketname,
    required this.buckettype,
    required this.bucketdata
  });

  factory ContentModel.fromJson(Map<String, dynamic> json) {
    return ContentModel(
      bucketname: json['bucketname'],
      buckettype: json['buckettype'],
      bucketdata: ContentDataModel.contentDataFromJson(json['bucketdata'])
    );
  }

  static List<ContentModel> contentFromJson(List<dynamic> input) {
    List<ContentModel> list = [];

    for(var x in input) {
      list.add(ContentModel.fromJson(x));
    }

    return list;
  }
}

class ContentDataModel {
  String type;
  Uint8List data;

  ContentDataModel({
    required this.type,
    required this.data
  });

  factory ContentDataModel.fromJson(Map<String, dynamic> json) {
    return ContentDataModel(
      type: json['type'],
      data: Uint8List.fromList(json['data'].cast<int>().toList())
    );
  }

  static ContentDataModel contentDataFromJson(Map<String, dynamic> input) {
    return ContentDataModel.fromJson(input);
  }
}