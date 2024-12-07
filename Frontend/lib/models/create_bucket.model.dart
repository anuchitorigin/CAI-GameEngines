class CreateBucketModel {
  String bucketid;

  CreateBucketModel({
    required this.bucketid
  });

  factory CreateBucketModel.fromJson(Map<String, dynamic> json) {
    return CreateBucketModel(
      bucketid: json['bucketid']
    );
  }

  static List<CreateBucketModel> createBucketDataFromJson(List<dynamic> input) {
    List<CreateBucketModel> list = [];

    for(var x in input) {
      list.add(CreateBucketModel.fromJson(x));
    }

    return list;
  }
}