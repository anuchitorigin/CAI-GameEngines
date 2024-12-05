import 'dart:typed_data';

class BucketModel {
  String bucketname;
  String buckettype;
  BucketDataModel bucketdata;

  BucketModel({
    required this.bucketname,
    required this.buckettype,
    required this.bucketdata
  });

  factory BucketModel.fromJson(Map<String, dynamic> json) {
    return BucketModel(
      bucketname: json['bucketname'],
      buckettype: json['buckettype'],
      bucketdata: BucketDataModel.bucketDataFromJson(json['bucketdata'])
    );
  }

  static List<BucketModel> bucketFromJson(List<dynamic> input) {
    List<BucketModel> list = [];

    for(var x in input) {
      list.add(BucketModel.fromJson(x));
    }

    return list;
  }
}

class BucketDataModel {
  String type;
  Uint8List data;

  BucketDataModel({
    required this.type,
    required this.data
  });

  factory BucketDataModel.fromJson(Map<String, dynamic> json) {
    return BucketDataModel(
      type: json['type'],
      data: Uint8List.fromList(json['data'].cast<int>().toList())
    );
  }

  static BucketDataModel bucketDataFromJson(Map<String, dynamic> input) {
    return BucketDataModel.fromJson(input);
  }
}