class MinSum {
  MinSum({
    required this.min,
  });

  int min;

  factory MinSum.fromJson(Map<String, dynamic> json) => MinSum(
        min: json["min"] ?? 0,
      );
}
