class BlogModel {
  int count;
  String next;
  List<BlogResults> results;

  BlogModel({
    required this.count,
    required this.next,
    required this.results,
  });

  factory BlogModel.fromJson(Map<String, dynamic> json) {
    return BlogModel(
      count: json["count"] ?? 0,
      next: json["next"] ?? "",
      results: json["results"] == null
          ? <BlogResults>[]
          : List<BlogResults>.from(
              json["results"].map(
                (x) => BlogResults.fromJson(x),
              ),
            ),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['count'] = this.count;
    data['next'] = this.next;
    data['results'] = this.results.map((v) => v.toJson()).toList();
    return data;
  }
}

class BlogResults {
  int id;
  String title;
  String body;
  String image;
  String imageUz;
  DateTime updatedAt;

  BlogResults({
    required this.id,
    required this.title,
    required this.body,
    required this.image,
    required this.imageUz,
    required this.updatedAt,
  });

  factory BlogResults.fromJson(Map<String, dynamic> json) {
    return BlogResults(
      id: json['id'] ?? 0,
      title: json['title'] ?? "",
      body: json['body'] ?? "",
      image: json['image'] ?? "",
      imageUz: json['image_uz'] ?? "",
      updatedAt: json['updated_at'] == null
          ? DateTime.now()
          : DateTime.parse(json["updated_at"]),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['body'] = this.body;
    data['image'] = this.image;
    data['image_uz'] = this.imageUz;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
