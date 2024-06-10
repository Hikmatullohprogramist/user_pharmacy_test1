class GetReviewModel {
  GetReviewModel({
    required this.status,
    required this.data,
  });

  int status;
  List<int> data;

  factory GetReviewModel.fromJson(Map<String, dynamic> json) => GetReviewModel(
        status: json["status"] ?? 0,
        data: json["data"] == null
            ? <int>[]
            : List<int>.from(json["data"].map((x) => x)),
      );
}
